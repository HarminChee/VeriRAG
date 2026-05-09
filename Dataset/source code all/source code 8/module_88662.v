module dma_pcie_bridge
(
   clk,
   reset,
   dma_address,
   dma_read,
   dma_readdata,
   dma_readdatavalid,
   dma_write,
   dma_writedata,
   dma_burstcount,
   dma_byteenable,
   dma_waitrequest,
   pcie_address,
   pcie_read,
   pcie_readdata,
   pcie_readdatavalid,
   pcie_write,
   pcie_writedata,
   pcie_burstcount,
   pcie_byteenable,
   pcie_waitrequest
);
parameter DMA_WIDTH = 256;
parameter PCIE_WIDTH = 64;
parameter DMA_BURSTCOUNT = 6;
parameter PCIE_BURSTCOUNT = 10;
parameter PCIE_ADDR_WIDTH = 30;  
parameter ADDR_OFFSET = 0;
localparam DMA_WIDTH_BYTES = DMA_WIDTH / 8;
localparam PCIE_WIDTH_BYTES = PCIE_WIDTH / 8;
localparam WIDTH_RATIO = DMA_WIDTH / PCIE_WIDTH;
localparam ADDR_SHIFT = $clog2( WIDTH_RATIO );
localparam DMA_ADDR_WIDTH = PCIE_ADDR_WIDTH - $clog2( DMA_WIDTH_BYTES );
input clk;
input reset;
input [DMA_ADDR_WIDTH-1:0] dma_address;
input dma_read;
output [DMA_WIDTH-1:0 ]dma_readdata;
output dma_readdatavalid;
input dma_write;
input [DMA_WIDTH-1:0] dma_writedata;
input [DMA_BURSTCOUNT-1:0] dma_burstcount;
input [DMA_WIDTH_BYTES-1:0] dma_byteenable;
output dma_waitrequest;
output [31:0] pcie_address;
output pcie_read;
input [PCIE_WIDTH-1:0] pcie_readdata;
input pcie_readdatavalid;
output pcie_write;
output [PCIE_WIDTH-1:0] pcie_writedata;
output [PCIE_BURSTCOUNT-1:0] pcie_burstcount;
output [PCIE_WIDTH_BYTES-1:0] pcie_byteenable;
input pcie_waitrequest;
wire [31:0] dma_byte_address;
assign dma_byte_address = (dma_address * DMA_WIDTH_BYTES);
reg [DMA_WIDTH-1:0] r_buffer; 
reg [$clog2(WIDTH_RATIO)-1:0] r_wc;
reg [DMA_WIDTH-1:0] r_demux;
wire [DMA_WIDTH-1:0] r_data;
wire r_full;
wire r_waitrequest;
assign r_full = &r_wc;
assign r_waitrequest = pcie_waitrequest;
assign r_data = {pcie_readdata, r_buffer[DMA_WIDTH-PCIE_WIDTH-1:0]};
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
   begin
      r_wc <= {$clog2(DMA_WIDTH){1'b0}};
      r_buffer <= {(DMA_WIDTH){1'b0}};
   end
   else
   begin
      r_wc <= pcie_readdatavalid ? (r_wc + 1) : r_wc;
      if(pcie_readdatavalid)
         r_buffer[ r_wc*PCIE_WIDTH +: PCIE_WIDTH ] <= pcie_readdata;
   end
end
reg [$clog2(WIDTH_RATIO)-1:0] w_wc;
wire [PCIE_WIDTH_BYTES-1:0] w_byteenable;
wire [PCIE_WIDTH-1:0] w_writedata;
wire w_waitrequest;
wire w_sent;
assign w_sent = pcie_write && !pcie_waitrequest;
assign w_writedata = dma_writedata[w_wc*PCIE_WIDTH +: PCIE_WIDTH];
assign w_byteenable = dma_byteenable[w_wc*PCIE_WIDTH_BYTES +: PCIE_WIDTH_BYTES];
assign w_waitrequest = (pcie_write && !(&w_wc)) || pcie_waitrequest;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
      w_wc <= {$clog2(DMA_WIDTH){1'b0}};
   else
      w_wc <= w_sent ? (w_wc + 1) : w_wc;
end
assign pcie_address = ADDR_OFFSET + dma_byte_address;
assign pcie_read = dma_read;
assign pcie_write = dma_write;
assign pcie_writedata = w_writedata;
assign pcie_burstcount = (dma_burstcount << ADDR_SHIFT);
assign pcie_byteenable = pcie_write ? w_byteenable : dma_byteenable;
assign dma_readdata = r_data;
assign dma_readdatavalid = r_full && pcie_readdatavalid;
assign dma_waitrequest = r_waitrequest || w_waitrequest;
endmodule
