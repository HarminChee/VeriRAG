module denise_colortable
(
  input  wire           clk,              
  input  wire           clk7_en,          
  input  wire [  9-1:1] reg_address_in,   
  input  wire [ 12-1:0] data_in,          
  input  wire [  8-1:0] select,           
  input  wire [  8-1:0] bplxor,           
  input  wire [  3-1:0] bank,             
  input  wire           loct,             
  input  wire           ehb_en,           
  output reg  [ 24-1:0] rgb               
);
parameter COLORBASE = 9'h180;         
wire [ 8-1:0] select_xored = select;
wire [ 8-1:0] wr_adr = {bank[2:0], reg_address_in[5:1]};
wire          wr_en  = (reg_address_in[8:6] == COLORBASE[8:6]) && clk7_en;
wire [32-1:0] wr_dat = {4'b0, data_in[11:0], 4'b0, data_in[11:0]};
wire [ 4-1:0] wr_bs  = loct ? 4'b0011 : 4'b1111;
wire [ 8-1:0] rd_adr = ehb_en ? {3'b000, select_xored[4:0]} : select_xored;
wire [32-1:0] rd_dat;
reg           ehb_sel;
denise_colortable_ram_mf clut
(
  .clock      (clk    ),
  .enable     (1'b1   ),
  .wraddress  (wr_adr ),
  .wren       (wr_en  ),
  .byteena_a  (wr_bs  ),
  .data       (wr_dat ),
  .rdaddress  (rd_adr ),
  .q          (rd_dat )
);
always @ (posedge clk) begin
  ehb_sel <= #1 select_xored[5];
end
wire [12-1:0] color_hi = rd_dat[12-1+16:0+16];
wire [12-1:0] color_lo = rd_dat[12-1+ 0:0+ 0];
wire [24-1:0] color = {color_hi[11:8], color_lo[11:8], color_hi[7:4], color_lo[7:4], color_hi[3:0], color_lo[3:0]};
always @ (*) begin
  if (ehb_sel && ehb_en) 
    rgb = {1'b0,color[23:17],1'b0,color[15:9],1'b0,color[7:1]};
  else 
    rgb = color;
end
endmodule
