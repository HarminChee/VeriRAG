module buffer_builder #(
  parameter                           MEM_DEPTH   = 13,   
  parameter                           DATA_WIDTH  = 32
)(
  input                               mem_clk,
  input                               rst,
  input           [1:0]               i_ppfifo_wr_en,     
  output  reg                         o_ppfifo_wr_fin,    
  input                               i_bram_we,
  input           [MEM_DEPTH  - 1: 0] i_bram_addr,
  input           [DATA_WIDTH - 1: 0] i_bram_din,
  input                               ppfifo_clk,
  input           [23:0]              i_data_count,
  input           [1:0]               i_write_ready,
  output  reg     [1:0]               o_write_activate,
  input           [23:0]              i_write_size,
  output  reg                         o_write_stb,
  output          [DATA_WIDTH - 1:0]  o_write_data
);
localparam        IDLE        = 0;
localparam        WRITE_SETUP = 1;
localparam        WRITE       = 2;
localparam        FINISHED    = 3;
localparam        BASE0_OFFSET  = 0;
localparam        BASE1_OFFSET  = ((2 ** MEM_DEPTH) / 2);
reg   [3:0]                           state;
reg   [23:0]                          count;
reg   [MEM_DEPTH - 1: 0]              r_ppfifo_mem_addr;
reg   [MEM_DEPTH - 1: 0]              r_addr;
dpb #(
  .DATA_WIDTH     (DATA_WIDTH           ),
  .ADDR_WIDTH     (MEM_DEPTH            )
) local_buffer (
  .clka           (mem_clk              ),
  .wea            (i_bram_we            ),
  .addra          (i_bram_addr          ),
  .douta          (                     ),
  .dina           (i_bram_din           ),
  .clkb           (ppfifo_clk           ),
  .web            (1'b0                 ),
  .addrb          (r_addr               ),
  .dinb           (32'h00000000         ),
  .doutb          (o_write_data         )
);
always @ (posedge ppfifo_clk) begin
  o_write_stb                     <= 0;
  if (rst) begin
    o_write_activate              <= 0;
    o_ppfifo_wr_fin               <= 0;
    count                         <= 0;
    r_addr                        <= 0;
    state                         <= IDLE;
  end
  else begin
    case (state)
      IDLE: begin
        o_ppfifo_wr_fin           <= 0;
        o_write_activate          <= 0;
        r_addr                    <= 0;
        count                     <= 0;
        if (i_ppfifo_wr_en > 0) begin
          if (i_ppfifo_wr_en[0]) begin
            r_addr                <= BASE0_OFFSET;
          end
          else begin
            r_addr                <= BASE1_OFFSET;
          end
          state                   <= WRITE_SETUP;
        end
      end
      WRITE_SETUP: begin
        if ((i_write_ready > 0) && (o_write_activate == 0)) begin
          if (i_write_ready[0]) begin
            o_write_activate[0]   <= 1;
          end
          else begin
            o_write_activate[1]   <= 1;
          end
          state                   <= WRITE;
        end
      end
      WRITE: begin
        if (count < i_data_count) begin
          r_addr                  <= r_addr + 1;
          o_write_stb             <= 1;
          count                   <= count + 1;
        end
        else begin
          o_write_activate        <= 0;
          state                   <= FINISHED;
        end
      end
      FINISHED: begin
        o_ppfifo_wr_fin           <= 1;
        if (i_ppfifo_wr_en == 0) begin
          o_ppfifo_wr_fin         <= 0;
          state                   <= IDLE;
        end
      end
      default: begin
        state                     <= IDLE;
      end
    endcase
  end
end
endmodule
