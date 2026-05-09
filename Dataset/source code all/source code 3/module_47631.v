module Amber
(
  input  wire           clk,            
  input  wire           dblscan,        
  input  wire [  2-1:0] lr_filter,      
  input  wire [  2-1:0] hr_filter,      
  input  wire [  2-1:0] scanline,       
  input  wire [  9-1:1] htotal,         
  input  wire           hires,          
  input  wire           osd_blank,      
  input  wire           osd_pixel,      
  input  wire [  4-1:0] red_in,         
  input  wire [  4-1:0] green_in,       
  input  wire [  4-1:0] blue_in,        
  input  wire           _hsync_in,      
  input  wire           _vsync_in,      
  input  wire           _csync_in,      
  output reg  [  4-1:0] red_out,        
  output reg  [  4-1:0] green_out,      
  output reg  [  4-1:0] blue_out,       
  output reg            _hsync_out,     
  output reg            _vsync_out      
);
localparam [  4-1:0] OSD_R = 4'b1110;
localparam [  4-1:0] OSD_G = 4'b1110;
localparam [  4-1:0] OSD_B = 4'b1110;
reg            _hsync_in_del;           
reg            hss;                     
always @ (posedge clk) begin
  _hsync_in_del <= #1 _hsync_in;
  hss <= #1 ~_hsync_in & _hsync_in_del;
end
reg            hi_en;                   
reg  [  4-1:0] r_in_d;                  
reg  [  4-1:0] g_in_d;                  
reg  [  4-1:0] b_in_d;                  
wire [  5-1:0] hi_r;                    
wire [  5-1:0] hi_g;                    
wire [  5-1:0] hi_b;                    
reg  [ 11-1:0] sd_lbuf_wr;              
always @ (posedge clk) begin
`ifdef MINIMIG_VIDEO_FILTER
  if (hss) hi_en <= #1 hires ? hr_filter[0] : lr_filter[0];
`else
  hi_en <= #1 1'b0;
`endif
end
always @ (posedge clk) begin
  if (sd_lbuf_wr[0])  begin 
    r_in_d <= red_in;
    g_in_d <= green_in;
    b_in_d <= blue_in;
  end
end
assign hi_r = hi_en ? ({1'b0, red_in}   + {1'b0, r_in_d}) : {red_in[3:0]  , 1'b0};
assign hi_g = hi_en ? ({1'b0, green_in} + {1'b0, g_in_d}) : {green_in[3:0], 1'b0};
assign hi_b = hi_en ? ({1'b0, blue_in}  + {1'b0, b_in_d}) : {blue_in[3:0] , 1'b0};
reg  [ 18-1:0] sd_lbuf [0:1024-1];      
reg  [ 18-1:0] sd_lbuf_o;               
reg  [ 18-1:0] sd_lbuf_o_d;             
reg  [ 11-1:0] sd_lbuf_rd;              
always @ (posedge clk) begin
  if (hss || !dblscan)
    sd_lbuf_wr <= #1 11'd0;
  else
    sd_lbuf_wr <= #1 sd_lbuf_wr + 11'd1;
end
always @ (posedge clk) begin
  if (hss || !dblscan || (sd_lbuf_rd == {htotal[8:1],2'b11})) 
    sd_lbuf_rd <= #1 11'd0;
  else
    sd_lbuf_rd <= #1 sd_lbuf_rd + 11'd1;
end
always @ (posedge clk) begin
  if (dblscan) begin
    sd_lbuf[sd_lbuf_wr[10:1]] <= #1 {_hsync_in, osd_blank, osd_pixel, hi_r, hi_g, hi_b};
    sd_lbuf_o <= #1 sd_lbuf[sd_lbuf_rd[9:0]];
    sd_lbuf_o_d <= #1 sd_lbuf_o;
  end
end
reg            vi_en;                   
reg  [ 18-1:0] vi_lbuf [0:1024-1];      
reg  [ 18-1:0] vi_lbuf_o;               
wire [  6-1:0] vi_r_tmp;                
wire [  6-1:0] vi_g_tmp;                
wire [  6-1:0] vi_b_tmp;                
wire [  4-1:0] vi_r;                    
wire [  4-1:0] vi_g;                    
wire [  4-1:0] vi_b;                    
always @ (posedge clk) begin
`ifdef MINIMIG_VIDEO_FILTER
  if (hss) vi_en <= #1 hires ? hr_filter[1] : lr_filter[1];
`else
  vi_en <= #1 1'b0;
`endif
end
always @ (posedge clk) begin
  vi_lbuf[sd_lbuf_rd[9:0]] <= #1 sd_lbuf_o;
  vi_lbuf_o <= #1 vi_lbuf[sd_lbuf_rd[9:0]];
end
assign vi_r_tmp = vi_en ? ({1'b0, sd_lbuf_o_d[14:10]} + {1'b0, vi_lbuf_o[14:10]}) : {sd_lbuf_o_d[14:10], 1'b0};
assign vi_g_tmp = vi_en ? ({1'b0, sd_lbuf_o_d[ 9: 5]} + {1'b0, vi_lbuf_o[ 9: 5]}) : {sd_lbuf_o_d[ 9: 5], 1'b0};
assign vi_b_tmp = vi_en ? ({1'b0, sd_lbuf_o_d[ 4: 0]} + {1'b0, vi_lbuf_o[ 4: 0]}) : {sd_lbuf_o_d[ 4: 0], 1'b0};
assign vi_r = vi_r_tmp[6-1:2];
assign vi_g = vi_g_tmp[6-1:2];
assign vi_b = vi_b_tmp[6-1:2];
reg            sl_en;                   
reg  [  4-1:0] sl_r;                    
reg  [  4-1:0] sl_g;                    
reg  [  4-1:0] sl_b;                    
always @ (posedge clk) begin
  if (hss) 
    sl_en <= #1 1'b0;
  else if (sd_lbuf_rd == {htotal[8:1],2'b11}) 
    sl_en <= #1 1'b1;
end
always @ (posedge clk) begin
  sl_r <= #1 ((sl_en && scanline[1]) ? 4'h0 : ((sl_en && scanline[0]) ? {1'b0, vi_r[3:1]} : vi_r));
  sl_g <= #1 ((sl_en && scanline[1]) ? 4'h0 : ((sl_en && scanline[0]) ? {1'b0, vi_g[3:1]} : vi_g));
  sl_b <= #1 ((sl_en && scanline[1]) ? 4'h0 : ((sl_en && scanline[0]) ? {1'b0, vi_b[3:1]} : vi_b));
end
wire           bm_hsync;
wire           bm_vsync;
wire [  4-1:0] bm_r;
wire [  4-1:0] bm_g;
wire [  4-1:0] bm_b;
wire           bm_osd_blank;
wire           bm_osd_pixel;
assign bm_hsync     = dblscan ? sd_lbuf_o_d[17] : _csync_in;
assign bm_vsync     = dblscan ? _vsync_in : 1'b1;
assign bm_r         = dblscan ? sl_r : red_in;
assign bm_g         = dblscan ? sl_g : green_in;
assign bm_b         = dblscan ? sl_b : blue_in;
assign bm_osd_blank = dblscan ? sd_lbuf_o_d[16] : osd_blank;
assign bm_osd_pixel = dblscan ? sd_lbuf_o_d[15] : osd_pixel;
wire [  4-1:0] osd_r;
wire [  4-1:0] osd_g;
wire [  4-1:0] osd_b;
assign osd_r = (bm_osd_blank ? (bm_osd_pixel ? OSD_R : {2'b00, bm_r[3:2]}) : bm_r);
assign osd_g = (bm_osd_blank ? (bm_osd_pixel ? OSD_G : {2'b00, bm_g[3:2]}) : bm_g);
assign osd_b = (bm_osd_blank ? (bm_osd_pixel ? OSD_B : {2'b10, bm_b[3:2]}) : bm_b);
always @ (posedge clk) begin
  _hsync_out <= #1 bm_hsync;
  _vsync_out <= #1 bm_vsync;
  red_out    <= #1 osd_r;
  green_out  <= #1 osd_g;
  blue_out   <= #1 osd_b;
end
endmodule
