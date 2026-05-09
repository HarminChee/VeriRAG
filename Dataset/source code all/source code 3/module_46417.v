`timescale 1 ps/1 ps
`timescale 1 ps/1 ps
module axi_pipe (
   input                   axi_tclk,
   input                   axi_tresetn,
   input       [7:0]       rx_axis_fifo_tdata_in,
   input                   rx_axis_fifo_tvalid_in,
   input                   rx_axis_fifo_tlast_in,
   output                  rx_axis_fifo_tready_in,
   output      [7:0]       rx_axis_fifo_tdata_out,
   output                  rx_axis_fifo_tvalid_out,
   output                  rx_axis_fifo_tlast_out,
   input                   rx_axis_fifo_tready_out
);
reg      [5:0]             rd_addr;
reg      [5:0]             wr_addr;
reg                        wea;
reg                        rx_axis_fifo_tready_int;
reg                        rx_axis_fifo_tvalid_int;
wire     [1:0]             wr_block;
wire     [1:0]             rd_block;
assign rx_axis_fifo_tready_in  = rx_axis_fifo_tready_int;
assign rx_axis_fifo_tvalid_out = rx_axis_fifo_tvalid_int;
always @(rx_axis_fifo_tvalid_in or rx_axis_fifo_tready_int)
begin
   wea = rx_axis_fifo_tvalid_in & rx_axis_fifo_tready_int;
end
always @(posedge axi_tclk)
begin
   if (!axi_tresetn) begin
      wr_addr <= 0;
   end
   else begin
      if (rx_axis_fifo_tvalid_in & rx_axis_fifo_tready_int)
         wr_addr <= wr_addr + 1;   
   end
end
always @(posedge axi_tclk)
begin
   if (!axi_tresetn) begin
      rd_addr <= 0;
   end
   else begin
      if (rx_axis_fifo_tvalid_int & rx_axis_fifo_tready_out)
         rd_addr <= rd_addr + 1;   
   end
end
assign wr_block = wr_addr[5:4];
assign rd_block = rd_addr[5:4]-1;
always @(posedge axi_tclk)
begin
   if (!axi_tresetn) begin
      rx_axis_fifo_tready_int <= 0;
   end
   else begin
      if (wr_block == rd_block)
         rx_axis_fifo_tready_int <= 0;
      else
         rx_axis_fifo_tready_int <= 1;
   end
end
always @(rd_addr or wr_addr)
begin
   if (rd_addr == wr_addr)
      rx_axis_fifo_tvalid_int <= 0;
   else
      rx_axis_fifo_tvalid_int <= 1;
end
genvar i;  
generate
  for (i=0; i<=7; i=i+1) begin
  RAM64X1D RAM64X1D_inst (
      .DPO     (rx_axis_fifo_tdata_out[i]), 
      .SPO     (), 
      .A0      (wr_addr[0]),
      .A1      (wr_addr[1]),
      .A2      (wr_addr[2]),
      .A3      (wr_addr[3]),
      .A4      (wr_addr[4]),
      .A5      (wr_addr[5]),
      .D       (rx_axis_fifo_tdata_in[i]), 
      .DPRA0   (rd_addr[0]),
      .DPRA1   (rd_addr[1]),
      .DPRA2   (rd_addr[2]),
      .DPRA3   (rd_addr[3]),
      .DPRA4   (rd_addr[4]),
      .DPRA5   (rd_addr[5]),
      .WCLK    (axi_tclk),
      .WE      (wea)
    );
   end
endgenerate
RAM64X1D RAM64X1D_inst_last (
    .DPO     (rx_axis_fifo_tlast_out), 
    .SPO     (), 
    .A0      (wr_addr[0]),
    .A1      (wr_addr[1]),
    .A2      (wr_addr[2]),
    .A3      (wr_addr[3]),
    .A4      (wr_addr[4]),
    .A5      (wr_addr[5]),
    .D       (rx_axis_fifo_tlast_in), 
    .DPRA0   (rd_addr[0]),
    .DPRA1   (rd_addr[1]),
    .DPRA2   (rd_addr[2]),
    .DPRA3   (rd_addr[3]),
    .DPRA4   (rd_addr[4]),
    .DPRA5   (rd_addr[5]),
    .WCLK    (axi_tclk),
    .WE      (wea)
  );
endmodule
