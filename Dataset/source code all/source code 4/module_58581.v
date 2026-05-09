module ppu_vga
(
  input  wire       clk_in,              
  input  wire       rst_in,              
  input  wire [5:0] sys_palette_idx_in,  
  output wire       hsync_out,           
  output wire       vsync_out,           
  output wire [2:0] r_out,               
  output wire [2:0] g_out,               
  output wire [1:0] b_out,               
  output wire [9:0] nes_x_out,           
  output wire [9:0] nes_y_out,           
  output wire [9:0] nes_y_next_out,      
  output wire       pix_pulse_out,       
  output wire       vblank_out           
);
localparam [9:0] DISPLAY_W    = 10'h280,
                 DISPLAY_H    = 10'h1E0;
localparam [9:0] NES_W        = 10'h100,
                 NES_H        = 10'h0F0;
localparam [7:0] BORDER_COLOR = 8'h49;
wire       sync_en;      
wire [9:0] sync_x;       
wire [9:0] sync_y;       
wire [9:0] sync_x_next;  
wire [9:0] sync_y_next;  
vga_sync vga_sync_blk(
  .clk(clk_in),
  .hsync(hsync_out),
  .vsync(vsync_out),
  .en(sync_en),
  .x(sync_x),
  .y(sync_y),
  .x_next(sync_x_next),
  .y_next(sync_y_next)
);
reg  [7:0] q_rgb;     
reg  [7:0] d_rgb;
reg        q_vblank;  
wire       d_vblank;
always @(posedge clk_in)
  begin
    if (rst_in)
      begin
        q_rgb    <= 8'h00;
        q_vblank <= 1'h0;
      end
    else
      begin
        q_rgb    <= d_rgb;
        q_vblank <= d_vblank;
      end
  end
wire [9:0] nes_x_next;  
wire       border;      
assign nes_x_out      = (sync_x - 10'h040) >> 1;
assign nes_y_out      = sync_y >> 1;
assign nes_x_next     = (sync_x_next - 10'h040) >> 1;
assign nes_y_next_out = sync_y_next >> 1;
assign border         = (nes_x_out >= NES_W) || (nes_y_out < 8) || (nes_y_out >= (NES_H - 8));
always @*
  begin
    if (!sync_en)
      begin
        d_rgb = 8'h00;
      end
    else if (border)
      begin
        d_rgb = BORDER_COLOR;
      end
    else
      begin
        case (sys_palette_idx_in)
          6'h00:  d_rgb = { 3'h3, 3'h3, 2'h1 };
          6'h01:  d_rgb = { 3'h1, 3'h0, 2'h2 };
          6'h02:  d_rgb = { 3'h0, 3'h0, 2'h2 };
          6'h03:  d_rgb = { 3'h2, 3'h0, 2'h2 };
          6'h04:  d_rgb = { 3'h4, 3'h0, 2'h1 };
          6'h05:  d_rgb = { 3'h5, 3'h0, 2'h0 };
          6'h06:  d_rgb = { 3'h5, 3'h0, 2'h0 };
          6'h07:  d_rgb = { 3'h3, 3'h0, 2'h0 };
          6'h08:  d_rgb = { 3'h2, 3'h1, 2'h0 };
          6'h09:  d_rgb = { 3'h0, 3'h2, 2'h0 };
          6'h0a:  d_rgb = { 3'h0, 3'h2, 2'h0 };
          6'h0b:  d_rgb = { 3'h0, 3'h1, 2'h0 };
          6'h0c:  d_rgb = { 3'h0, 3'h1, 2'h1 };
          6'h0d:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h0e:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h0f:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h10:  d_rgb = { 3'h5, 3'h5, 2'h2 };
          6'h11:  d_rgb = { 3'h0, 3'h3, 2'h3 };
          6'h12:  d_rgb = { 3'h1, 3'h1, 2'h3 };
          6'h13:  d_rgb = { 3'h4, 3'h0, 2'h3 };
          6'h14:  d_rgb = { 3'h5, 3'h0, 2'h2 };
          6'h15:  d_rgb = { 3'h7, 3'h0, 2'h1 };
          6'h16:  d_rgb = { 3'h6, 3'h1, 2'h0 };
          6'h17:  d_rgb = { 3'h6, 3'h2, 2'h0 };
          6'h18:  d_rgb = { 3'h4, 3'h3, 2'h0 };
          6'h19:  d_rgb = { 3'h0, 3'h4, 2'h0 };
          6'h1a:  d_rgb = { 3'h0, 3'h5, 2'h0 };
          6'h1b:  d_rgb = { 3'h0, 3'h4, 2'h0 };
          6'h1c:  d_rgb = { 3'h0, 3'h4, 2'h2 };
          6'h1d:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h1e:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h1f:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h20:  d_rgb = { 3'h7, 3'h7, 2'h3 };
          6'h21:  d_rgb = { 3'h1, 3'h5, 2'h3 };
          6'h22:  d_rgb = { 3'h2, 3'h4, 2'h3 };
          6'h23:  d_rgb = { 3'h5, 3'h4, 2'h3 };
          6'h24:  d_rgb = { 3'h7, 3'h3, 2'h3 };
          6'h25:  d_rgb = { 3'h7, 3'h3, 2'h2 };
          6'h26:  d_rgb = { 3'h7, 3'h3, 2'h1 };
          6'h27:  d_rgb = { 3'h7, 3'h4, 2'h0 };
          6'h28:  d_rgb = { 3'h7, 3'h5, 2'h0 };
          6'h29:  d_rgb = { 3'h4, 3'h6, 2'h0 };
          6'h2a:  d_rgb = { 3'h2, 3'h6, 2'h1 };
          6'h2b:  d_rgb = { 3'h2, 3'h7, 2'h2 };
          6'h2c:  d_rgb = { 3'h0, 3'h7, 2'h3 };
          6'h2d:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h2e:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h2f:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h30:  d_rgb = { 3'h7, 3'h7, 2'h3 };
          6'h31:  d_rgb = { 3'h5, 3'h7, 2'h3 };
          6'h32:  d_rgb = { 3'h6, 3'h6, 2'h3 };
          6'h33:  d_rgb = { 3'h6, 3'h6, 2'h3 };
          6'h34:  d_rgb = { 3'h7, 3'h6, 2'h3 };
          6'h35:  d_rgb = { 3'h7, 3'h6, 2'h3 };
          6'h36:  d_rgb = { 3'h7, 3'h5, 2'h2 };
          6'h37:  d_rgb = { 3'h7, 3'h6, 2'h2 };
          6'h38:  d_rgb = { 3'h7, 3'h7, 2'h2 };
          6'h39:  d_rgb = { 3'h7, 3'h7, 2'h2 };
          6'h3a:  d_rgb = { 3'h5, 3'h7, 2'h2 };
          6'h3b:  d_rgb = { 3'h5, 3'h7, 2'h3 };
          6'h3c:  d_rgb = { 3'h4, 3'h7, 2'h3 };
          6'h3d:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h3e:  d_rgb = { 3'h0, 3'h0, 2'h0 };
          6'h3f:  d_rgb = { 3'h0, 3'h0, 2'h0 };
        endcase
      end
  end
assign { r_out, g_out, b_out } = q_rgb;
assign pix_pulse_out           = nes_x_next != nes_x_out;
assign d_vblank = ((sync_x == 730) && (sync_y == 477)) ? 1'b1 :
                  ((sync_x == 64) && (sync_y == 519))  ? 1'b0 : q_vblank;
assign vblank_out = q_vblank;
endmodule
