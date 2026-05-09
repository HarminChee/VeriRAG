`timescale 1ps/1ps
`timescale 1ps/1ps
module afifo #
(
 parameter TCQ           = 100,
 parameter DSIZE = 32,
 parameter FIFO_DEPTH = 16,
 parameter ASIZE = 4,
 parameter SYNC = 1   
)
(
input              wr_clk, 
input              rst,
input              wr_en,
input [DSIZE-1:0]  wr_data,
input              rd_en, 
input              rd_clk, 
output [DSIZE-1:0] rd_data,
output reg         full,
output reg         empty,
output reg         almost_full
);
reg [DSIZE-1:0] mem [0:FIFO_DEPTH-1];
reg [ASIZE:0] rd_gray_nxt;
reg [ASIZE:0]    rd_gray;
reg [ASIZE:0]    rd_capture_ptr;
reg [ASIZE:0]    pre_rd_capture_gray_ptr;
reg [ASIZE:0]    rd_capture_gray_ptr;
reg [ASIZE:0]    wr_gray;
reg [ASIZE:0] wr_gray_nxt;
reg [ASIZE:0] wr_capture_ptr;
reg [ASIZE:0] pre_wr_capture_gray_ptr;
reg [ASIZE:0] wr_capture_gray_ptr;
wire [ASIZE:0] buf_avail;
wire [ASIZE:0] buf_filled;
wire [ASIZE-1:0] wr_addr, rd_addr;
reg [ASIZE:0]   wr_ptr, rd_ptr;
integer i,j,k;
generate
if (SYNC == 1) begin: RDSYNC
   always @ (rd_ptr)
     rd_capture_ptr = rd_ptr;
end
endgenerate
generate
if (SYNC == 1) begin: WRSYNC
always @ (wr_ptr)
    wr_capture_ptr = wr_ptr;
end
endgenerate
assign wr_addr = wr_ptr;
assign rd_data = mem[rd_addr];
always @(posedge wr_clk)
begin
if (wr_en && !full)
  mem[wr_addr] <= #TCQ wr_data;
end
assign rd_addr = rd_ptr[ASIZE-1:0];
assign rd_strobe = rd_en && !empty;
integer n;
reg [ASIZE:0] rd_ptr_tmp;
always @ (rd_ptr)
begin
  rd_gray_nxt[ASIZE] = rd_ptr[ASIZE];
  for (n=0; n < ASIZE; n=n+1) 
       rd_gray_nxt[n] = rd_ptr[n] ^ rd_ptr[n+1];
end       
always @(posedge rd_clk)
begin
if (rst)
   begin
        rd_ptr <= #TCQ 'b0;
        rd_gray <= #TCQ 'b0;
   end
else begin
    if (rd_strobe)
        rd_ptr <= #TCQ rd_ptr + 1;
    rd_ptr_tmp <= #TCQ rd_ptr;
    rd_gray <= #TCQ rd_gray_nxt;
end
end
assign buf_filled = wr_capture_ptr - rd_ptr;
always @ (posedge rd_clk )
begin
   if (rst)
        empty <= #TCQ 1'b1;
   else if ((buf_filled == 0) || (buf_filled == 1 && rd_strobe))
        empty <= #TCQ 1'b1;
   else
        empty <= #TCQ 1'b0;
end        
reg [ASIZE:0] wbin;
wire [ASIZE:0] wgraynext, wbinnext;
always @(posedge rd_clk)
begin
if (rst)
   begin
        wr_ptr <= #TCQ 'b0;
        wr_gray <= #TCQ 'b0;
   end
else begin
    if (wr_en)
        wr_ptr <= #TCQ wr_ptr + 1;
    wr_gray <= #TCQ wr_gray_nxt;
end
end
always @ (wr_ptr)
begin
    wr_gray_nxt[ASIZE] = wr_ptr[ASIZE];
    for (n=0; n < ASIZE; n=n+1)
       wr_gray_nxt[n] = wr_ptr[n] ^ wr_ptr[n+1];
end       
assign buf_avail = (rd_capture_ptr + FIFO_DEPTH) - wr_ptr;
always @ (posedge wr_clk )
begin
   if (rst) 
        full <= #TCQ 1'b0;
   else if ((buf_avail == 0) || (buf_avail == 1 && wr_en))
        full <= #TCQ 1'b1;
   else
        full <= #TCQ 1'b0;
end        
always @ (posedge wr_clk )
begin
   if (rst) 
        almost_full <= #TCQ 1'b0;
   else if ((buf_avail == FIFO_DEPTH - 2 ) || ((buf_avail == FIFO_DEPTH -3) && wr_en))
        almost_full <= #TCQ 1'b1;
   else
        almost_full <= #TCQ 1'b0;
end        
endmodule
