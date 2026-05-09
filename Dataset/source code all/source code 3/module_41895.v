module fifo_to_gpmc
  #(parameter PTR_WIDTH = 2, parameter ADDR_WIDTH = 10, parameter LAST_ADDR = 10'h3ff)
  (input clk, input reset, input clear, input arst,
   input [17:0] data_i, input src_rdy_i, output dst_rdy_o,
   output [15:0] EM_D, input [ADDR_WIDTH:1] EM_A, input EM_CLK, input EM_OE,
   output reg data_available);
    wire [17:0] data_o;
    reg gpmc_state;
    reg [ADDR_WIDTH:1] addr;
    reg [PTR_WIDTH:0] gpmc_ptr, next_gpmc_ptr;
    localparam GPMC_STATE_START = 0;
    localparam GPMC_STATE_EMPTY = 1;
    reg fifo_state;
    reg [ADDR_WIDTH-1:0] counter;
    reg [PTR_WIDTH:0] fifo_ptr;
    localparam FIFO_STATE_CLAIM = 0;
    localparam FIFO_STATE_FILL = 1;
    always @(posedge EM_CLK or posedge arst) begin
        if (arst) begin
            gpmc_state <= GPMC_STATE_START;
            gpmc_ptr <= 0;
            next_gpmc_ptr <= 0;
            addr <= 0;
        end
        else if (EM_OE) begin
            addr <= EM_A + 1;
            case(gpmc_state)
            GPMC_STATE_START: begin
                if (EM_A == 0) begin
                    gpmc_state <= GPMC_STATE_EMPTY;
                    next_gpmc_ptr <= gpmc_ptr + 1;
                end
            end
            GPMC_STATE_EMPTY: begin
                if (addr == LAST_ADDR) begin
                    gpmc_state <= GPMC_STATE_START;
                    gpmc_ptr <= next_gpmc_ptr;
                    addr <= 0;
                end
            end
            endcase 
        end 
    end 
    wire [PTR_WIDTH:0] safe_gpmc_ptr;
    cross_clock_reader #(.WIDTH(PTR_WIDTH+1)) read_gpmc_ptr
        (.clk(clk), .rst(reset | clear), .in(gpmc_ptr), .out(safe_gpmc_ptr));
    wire bram_available_to_fill = (fifo_ptr ^ (1 << PTR_WIDTH)) != safe_gpmc_ptr;
    wire [PTR_WIDTH:0] safe_next_gpmc_ptr;
    cross_clock_reader #(.WIDTH(PTR_WIDTH+1)) read_next_gpmc_ptr
        (.clk(clk), .rst(reset | clear), .in(next_gpmc_ptr), .out(safe_next_gpmc_ptr));
    always @(posedge clk)
        if (reset | clear) data_available <= 0;
        else               data_available <= safe_next_gpmc_ptr != fifo_ptr;
    always @(posedge clk) begin
        if (reset | clear) begin
            fifo_state <= FIFO_STATE_CLAIM;
            fifo_ptr <= 0;
            counter <= 0;
        end
        else begin
            case(fifo_state)
            FIFO_STATE_CLAIM: begin
                if (bram_available_to_fill) fifo_state <= FIFO_STATE_FILL;
                counter <= 0;
            end
            FIFO_STATE_FILL: begin
                if (src_rdy_i && dst_rdy_o && data_i[17]) begin
                    fifo_state <= FIFO_STATE_CLAIM;
                    fifo_ptr <= fifo_ptr + 1;
                end
                if (src_rdy_i && dst_rdy_o) begin
                    counter <= counter + 1;
                end
            end
            endcase 
        end
    end 
    assign dst_rdy_o = fifo_state == FIFO_STATE_FILL;
    assign EM_D = data_o[15:0];
    ram_2port #(.DWIDTH(18),.AWIDTH(PTR_WIDTH + ADDR_WIDTH)) async_fifo_bram
     (.clka(clk),.ena(1'b1),.wea(src_rdy_i && dst_rdy_o),
      .addra({fifo_ptr[PTR_WIDTH-1:0], counter}),.dia(data_i),.doa(),
      .clkb(EM_CLK),.enb(1'b1),.web(1'b0),
      .addrb({gpmc_ptr[PTR_WIDTH-1:0], addr}),.dib(18'h3ffff),.dob(data_o));
endmodule 
