module gpmc_to_fifo
  #(parameter PTR_WIDTH = 2, parameter ADDR_WIDTH = 10, parameter LAST_ADDR = 10'h3ff)
  (input [15:0] EM_D, input [ADDR_WIDTH:1] EM_A, input EM_CLK, input EM_WE,
   input clk, input reset, input clear, input arst,
   output [17:0] data_o, output src_rdy_o, input dst_rdy_i,
   output reg have_space);
    reg gpmc_state;
    reg [ADDR_WIDTH:1] addr;
    reg [PTR_WIDTH:0] gpmc_ptr, next_gpmc_ptr;
    localparam GPMC_STATE_START = 0;
    localparam GPMC_STATE_FILL = 1;
    reg [1:0] fifo_state;
    reg [ADDR_WIDTH-1:0] counter;
    reg [ADDR_WIDTH-1:0] last_counter;
    reg [ADDR_WIDTH-1:0] last_xfer;
    reg [PTR_WIDTH:0] fifo_ptr;
    localparam FIFO_STATE_CLAIM = 0;
    localparam FIFO_STATE_EMPTY = 1;
    localparam FIFO_STATE_PRE = 2;
    always @(negedge EM_CLK or posedge arst) begin
        if (arst) begin
            gpmc_state <= GPMC_STATE_START;
            gpmc_ptr <= 0;
            next_gpmc_ptr <= 0;
            addr <= 0;
        end
        else if (EM_WE) begin
            addr <= EM_A + 1;
            case(gpmc_state)
            GPMC_STATE_START: begin
                if (EM_A == 0) begin
                    gpmc_state <= GPMC_STATE_FILL;
                    next_gpmc_ptr <= gpmc_ptr + 1;
                end
            end
            GPMC_STATE_FILL: begin
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
    wire bram_available_to_empty = safe_gpmc_ptr != fifo_ptr;
    wire [PTR_WIDTH:0] safe_next_gpmc_ptr;
    cross_clock_reader #(.WIDTH(PTR_WIDTH+1)) read_next_gpmc_ptr
        (.clk(clk), .rst(reset | clear), .in(next_gpmc_ptr), .out(safe_next_gpmc_ptr));
    wire [PTR_WIDTH:0] fifo_ptr_next = fifo_ptr + 1;
    always @(posedge clk)
        if (reset | clear) have_space <= 0;
        else               have_space <= (fifo_ptr ^ (1 << PTR_WIDTH)) != safe_next_gpmc_ptr;
    always @(posedge clk) begin
        if (reset | clear) begin
            fifo_state <= FIFO_STATE_CLAIM;
            fifo_ptr <= 0;
            counter <= 0;
        end
        else begin
            case(fifo_state)
            FIFO_STATE_CLAIM: begin
                if (bram_available_to_empty && data_o[16]) fifo_state <= FIFO_STATE_PRE;
                counter <= 0;
            end
            FIFO_STATE_PRE: begin
                fifo_state <= FIFO_STATE_EMPTY;
                counter <= counter + 1;
            end
            FIFO_STATE_EMPTY: begin
                if (src_rdy_o && dst_rdy_i && data_o[17]) begin
                    fifo_state <= FIFO_STATE_CLAIM;
                    fifo_ptr <= fifo_ptr + 1;
                    counter <= 0;
                end
                else if (src_rdy_o && dst_rdy_i) begin
                    counter <= counter + 1;
                end
            end
            endcase 
        end
    end 
    wire enable = (fifo_state != FIFO_STATE_EMPTY) || dst_rdy_i;
    assign src_rdy_o = fifo_state == FIFO_STATE_EMPTY;
    ram_2port #(.DWIDTH(16),.AWIDTH(PTR_WIDTH + ADDR_WIDTH)) async_fifo_bram
     (.clka(~EM_CLK),.ena(1'b1),.wea(EM_WE),
      .addra({gpmc_ptr[PTR_WIDTH-1:0], addr}),.dia(EM_D),.doa(),
      .clkb(clk),.enb(enable),.web(1'b0),
      .addrb({fifo_ptr[PTR_WIDTH-1:0], counter}),.dib(18'h3ffff),.dob(data_o[15:0]));
    always @(posedge clk) begin
        if (src_rdy_o && dst_rdy_i && data_o[16]) begin
            last_xfer <= {data_o[ADDR_WIDTH-2:0], 1'b0};
        end
    end
    always @(posedge clk) if (enable) last_counter <= counter;
    assign data_o[17] = !data_o[16] && ((last_counter + 1'b1) == last_xfer);
    assign data_o[16] = last_counter == 0;
endmodule 
