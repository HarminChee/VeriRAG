module fifo
#(
  parameter DATA_BITS = 8,
  parameter ADDR_BITS = 3
)
(
  input  wire                 clk,      
  input  wire                 reset,    
  input  wire                 rd_en,    
  input  wire                 wr_en,    
  input  wire [DATA_BITS-1:0] wr_data,  
  output wire [DATA_BITS-1:0] rd_data,  
  output wire                 full,     
  output wire                 empty     
);
reg  [ADDR_BITS-1:0] q_rd_ptr;
wire [ADDR_BITS-1:0] d_rd_ptr;
reg  [ADDR_BITS-1:0] q_wr_ptr;
wire [ADDR_BITS-1:0] d_wr_ptr;
reg                  q_empty;
wire                 d_empty;
reg                  q_full;
wire                 d_full;
reg  [DATA_BITS-1:0] q_data_array [2**ADDR_BITS-1:0];
wire [DATA_BITS-1:0] d_data;
wire rd_en_prot;
wire wr_en_prot;
always @(posedge clk)
  begin
    if (reset)
      begin
        q_rd_ptr <= 0;
        q_wr_ptr <= 0;
        q_empty  <= 1'b1;
        q_full   <= 1'b0;
      end
    else
      begin
        q_rd_ptr               <= d_rd_ptr;
        q_wr_ptr               <= d_wr_ptr;
        q_empty                <= d_empty;
        q_full                 <= d_full;
        q_data_array[q_wr_ptr] <= d_data;
      end
  end
assign rd_en_prot = (rd_en && !q_empty);
assign wr_en_prot = (wr_en && !q_full);
assign d_wr_ptr = (wr_en_prot)  ? q_wr_ptr + 1'h1 : q_wr_ptr;
assign d_data   = (wr_en_prot)  ? wr_data         : q_data_array[q_wr_ptr];
assign d_rd_ptr = (rd_en_prot)  ? q_rd_ptr + 1'h1 : q_rd_ptr;
wire [ADDR_BITS-1:0] addr_bits_wide_1;
assign addr_bits_wide_1 = 1;
assign d_empty = ((q_empty && !wr_en_prot) ||
                  (((q_wr_ptr - q_rd_ptr) == addr_bits_wide_1) && rd_en_prot));
assign d_full  = ((q_full && !rd_en_prot) ||
                  (((q_rd_ptr - q_wr_ptr) == addr_bits_wide_1) && wr_en_prot));
assign rd_data = q_data_array[q_rd_ptr];
assign full    = q_full;
assign empty   = q_empty;
endmodule
