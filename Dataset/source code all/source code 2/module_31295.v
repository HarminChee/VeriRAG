module denise_hamgenerator
(
  input  wire           clk,              
  input  wire           clk7_en,          
  input  wire [  9-1:1] reg_address_in,   
  input  wire [ 12-1:0] data_in,          
  input  wire [  8-1:0] select,           
  input  wire [  8-1:0] bplxor,           
  input  wire [  3-1:0] bank,             
  input  wire           loct,             
  input  wire           ham8,             
  output reg  [ 24-1:0] rgb               
);
parameter COLORBASE = 9'h180;         
wire [ 8-1:0] select_xored = select ^ bplxor;
wire [ 8-1:0] wr_adr = {bank[2:0], reg_address_in[5:1]};
wire          wr_en  = (reg_address_in[8:6] == COLORBASE[8:6]) && clk7_en;
wire [32-1:0] wr_dat = {4'b0, data_in[11:0], 4'b0, data_in[11:0]};
wire [ 4-1:0] wr_bs  = loct ? 4'b0011 : 4'b1111;
wire [ 8-1:0] rd_adr = ham8 ? {2'b00, select_xored[7:2]} : select_xored;
wire [32-1:0] rd_dat;
reg  [24-1:0] rgb_prev;
reg  [ 8-1:0] select_r;
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
wire [12-1:0] color_hi = rd_dat[12-1+16:0+16];
wire [12-1:0] color_lo = rd_dat[12-1+ 0:0+ 0];
wire [24-1:0] color = {color_hi[11:8], color_lo[11:8], color_hi[7:4], color_lo[7:4], color_hi[3:0], color_lo[3:0]};
always @ (posedge clk) begin
  rgb_prev <= #1 rgb;
end
always @ (posedge clk) begin
  select_r <= #1 select_xored;
end
always @ (*) begin
  if (ham8) begin
    case (select_r[1:0])
      2'b00: 
        rgb = color;
      2'b01: 
        rgb = {rgb_prev[23:8],select_r[7:2],rgb_prev[1:0]};
      2'b10: 
        rgb = {select_r[7:2],rgb_prev[17:16],rgb_prev[15:0]};
      2'b11: 
        rgb = {rgb_prev[23:16],select_r[7:2],rgb_prev[9:8],rgb_prev[7:0]};
      default:
        rgb = color;
    endcase
  end else begin
    case (select_r[5:4])
      2'b00: 
        rgb = color;
      2'b01: 
        rgb = {rgb_prev[23:8],select_r[3:0],select_r[3:0]};
      2'b10: 
        rgb = {select_r[3:0],select_r[3:0],rgb_prev[15:0]};
      2'b11: 
        rgb = {rgb_prev[23:16],select_r[3:0],select_r[3:0],rgb_prev[7:0]};
      default:
        rgb = color;
    endcase
  end
end
endmodule
