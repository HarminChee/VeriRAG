module vga_lcd (
    input clk,              
    input rst,
    input shift_reg1,       
    input graphics_alpha,   
    output [17:1] csr_adr_o,
    input  [15:0] csr_dat_i,
    output        csr_stb_o,
    input  [3:0] pal_addr,
    input        pal_we,
    output [7:0] pal_read,
    input  [7:0] pal_write,
    input        dac_we,
    input  [1:0] dac_read_data_cycle,
    input  [7:0] dac_read_data_register,
    output [3:0] dac_read_data,
    input  [1:0] dac_write_data_cycle,
    input  [7:0] dac_write_data_register,
    input  [3:0] dac_write_data,
    output reg [3:0] vga_red_o,
    output reg [3:0] vga_green_o,
    output reg [3:0] vga_blue_o,
    output reg       horiz_sync,
    output reg       vert_sync,
    input [5:0] cur_start,
    input [5:0] cur_end,
    input [4:0] vcursor,
    input [6:0] hcursor,
    input [6:0] horiz_total,
    input [6:0] end_horiz,
    input [6:0] st_hor_retr,
    input [4:0] end_hor_retr,
    input [9:0] vert_total,
    input [9:0] end_vert,
    input [9:0] st_ver_retr,
    input [3:0] end_ver_retr,
    input x_dotclockdiv2,
    output v_retrace,
    output vh_retrace
  );
  reg        video_on_v;
  reg        video_on_h_i;
  reg [1:0]  video_on_h_p;
  reg [9:0]  h_count;   
  reg [9:0]  v_count;   
  wire [9:0] hor_disp_end;
  wire [9:0] hor_scan_end;
  wire [9:0] ver_disp_end;
  wire [9:0] ver_sync_beg;
  wire [3:0] ver_sync_end;
  wire [9:0] ver_scan_end;
  wire       video_on;
  wire [3:0] attr_wm;
  wire [3:0] attr_tm;
  wire [3:0] attr;
  wire [7:0] index;
  wire [7:0] index_pal;
  wire [7:0] color;
  reg  [7:0] index_gm;
  wire video_on_h_tm;
  wire video_on_h_wm;
  wire video_on_h_gm;
  wire video_on_h;
  reg       horiz_sync_i;
  reg [1:0] horiz_sync_p;
  wire      horiz_sync_tm;
  wire      horiz_sync_wm;
  wire      horiz_sync_gm;
  wire [16:1] csr_tm_adr_o;
  wire        csr_tm_stb_o;
  wire [17:1] csr_wm_adr_o;
  wire        csr_wm_stb_o;
  wire [17:1] csr_gm_adr_o;
  wire        csr_gm_stb_o;
  wire        csr_stb_o_tmp;
  wire [3:0] red;
  wire [3:0] green;
  wire [3:0] blue;
  vga_text_mode text_mode (
    .clk (clk),
    .rst (rst),
    .csr_adr_o (csr_tm_adr_o),
    .csr_dat_i (csr_dat_i),
    .csr_stb_o (csr_tm_stb_o),
    .h_count      (h_count),
    .v_count      (v_count),
    .horiz_sync_i (horiz_sync_i),
    .video_on_h_i (video_on_h_i),
    .video_on_h_o (video_on_h_tm),
    .cur_start  (cur_start),
    .cur_end    (cur_end),
    .vcursor    (vcursor),
    .hcursor    (hcursor),
    .attr         (attr_tm),
    .horiz_sync_o (horiz_sync_tm)
  );
  vga_planar planar (
    .clk (clk),
    .rst (rst),
    .csr_adr_o (csr_wm_adr_o),
    .csr_dat_i (csr_dat_i),
    .csr_stb_o (csr_wm_stb_o),
    .attr_plane_enable (4'hf),
    .x_dotclockdiv2    (x_dotclockdiv2),
    .h_count      (h_count),
    .v_count      (v_count),
    .horiz_sync_i (horiz_sync_i),
    .video_on_h_i (video_on_h_i),
    .video_on_h_o (video_on_h_wm),
    .attr         (attr_wm),
    .horiz_sync_o (horiz_sync_wm)
  );
  vga_linear linear (
    .clk (clk),
    .rst (rst),
    .csr_adr_o (csr_gm_adr_o),
    .csr_dat_i (csr_dat_i),
    .csr_stb_o (csr_gm_stb_o),
    .h_count      (h_count),
    .v_count      (v_count),
    .horiz_sync_i (horiz_sync_i),
    .video_on_h_i (video_on_h_i),
    .video_on_h_o (video_on_h_gm),
    .color        (color),
    .horiz_sync_o (horiz_sync_gm)
  );
  vga_palette_regs palette_regs (
    .clk (clk),
    .attr  (attr),
    .index (index_pal),
    .address    (pal_addr),
    .write      (pal_we),
    .read_data  (pal_read),
    .write_data (pal_write)
  );
  vga_dac_regs dac_regs (
    .clk (clk),
    .index (index),
    .red   (red),
    .green (green),
    .blue  (blue),
    .write (dac_we),
    .read_data_cycle    (dac_read_data_cycle),
    .read_data_register (dac_read_data_register),
    .read_data          (dac_read_data),
    .write_data_cycle    (dac_write_data_cycle),
    .write_data_register (dac_write_data_register),
    .write_data          (dac_write_data)
  );
  assign hor_scan_end = { horiz_total[6:2] + 1'b1, horiz_total[1:0], 3'h7 };
  assign hor_disp_end = { end_horiz, 3'h7 };
  assign ver_scan_end = vert_total + 10'd1;
  assign ver_disp_end = end_vert + 10'd1;
  assign ver_sync_beg = st_ver_retr;
  assign ver_sync_end = end_ver_retr + 4'd1;
  assign video_on     = video_on_h && video_on_v;
  assign attr  = graphics_alpha ? attr_wm : attr_tm;
  assign index = (graphics_alpha & shift_reg1) ? index_gm : index_pal;
  assign video_on_h    = video_on_h_p[1];
  assign csr_adr_o = graphics_alpha ?
    (shift_reg1 ? csr_gm_adr_o : csr_wm_adr_o) : { 1'b0, csr_tm_adr_o };
  assign csr_stb_o_tmp = graphics_alpha ?
    (shift_reg1 ? csr_gm_stb_o : csr_wm_stb_o) : csr_tm_stb_o;
  assign csr_stb_o     = csr_stb_o_tmp & (video_on_h_i | video_on_h) & video_on_v;
  assign v_retrace   = !video_on_v;
  assign vh_retrace  = v_retrace | !video_on_h;
  always @(posedge clk)
    index_gm <= rst ? 8'h0 : color;
  always @(posedge clk)
    if (rst)
      begin
        h_count      <= 10'b0;
        horiz_sync_i <= 1'b1;
        v_count      <= 10'b0;
        vert_sync    <= 1'b1;
        video_on_h_i <= 1'b1;
        video_on_v   <= 1'b1;
      end
    else
      begin
        h_count      <= (h_count==hor_scan_end) ? 10'b0 : h_count + 10'b1;
        horiz_sync_i <= horiz_sync_i ? (h_count[9:3]!=st_hor_retr)
                                     : (h_count[7:3]==end_hor_retr);
        v_count      <= (v_count==ver_scan_end && h_count==hor_scan_end) ? 10'b0
                      : ((h_count==hor_scan_end) ? v_count + 10'b1 : v_count);
        vert_sync    <= vert_sync ? (v_count!=ver_sync_beg)
                                  : (v_count[3:0]==ver_sync_end);
        video_on_h_i <= (h_count==hor_scan_end) ? 1'b1
                      : ((h_count==hor_disp_end) ? 1'b0 : video_on_h_i);
        video_on_v   <= (v_count==10'h0) ? 1'b1
                      : ((v_count==ver_disp_end) ? 1'b0 : video_on_v);
      end
  always @(posedge clk)
    { horiz_sync, horiz_sync_p } <= rst ? 3'b0
       : { horiz_sync_p[1:0], graphics_alpha ?
         (shift_reg1 ? horiz_sync_gm : horiz_sync_wm) : horiz_sync_tm };
  always @(posedge clk)
    video_on_h_p <= rst ? 2'b0 : { video_on_h_p[0],
      graphics_alpha ? (shift_reg1 ? video_on_h_gm : video_on_h_wm)
                     : video_on_h_tm };
  always @(posedge clk)
    if (rst)
      begin
        vga_red_o     <= 4'b0;
        vga_green_o   <= 4'b0;
        vga_blue_o    <= 4'b0;
      end
    else
      begin
        vga_blue_o  <= video_on ? blue : 4'h0;
        vga_green_o <= video_on ? green : 4'h0;
        vga_red_o   <= video_on ? red : 4'h0;
      end
endmodule
