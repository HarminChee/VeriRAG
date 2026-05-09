module gfx_clip(clk_i, rst_i,
  clipping_enable_i, zbuffer_enable_i,
  zbuffer_base_i, target_size_x_i, target_size_y_i,
  clip_pixel0_x_i, clip_pixel0_y_i, clip_pixel1_x_i, clip_pixel1_y_i,                              
  raster_pixel_x_i, raster_pixel_y_i, raster_u_i, raster_v_i, flat_color_i, raster_write_i, ack_o, 
  cuvz_pixel_x_i, cuvz_pixel_y_i, cuvz_pixel_z_i, cuvz_u_i, cuvz_v_i, cuvz_color_i, cuvz_write_i,  
  cuvz_a_i,                                                                                        
  z_ack_i, z_addr_o, z_data_i, z_sel_o, z_request_o, wbm_busy_i,                                   
  pixel_x_o, pixel_y_o, pixel_z_o, u_o, v_o, a_o,                                                  
  bezier_factor0_i, bezier_factor1_i, bezier_factor0_o, bezier_factor1_o,                          
  color_o, write_o, ack_i                                                                          
  );
parameter point_width = 16;
input                   clk_i;
input                   rst_i;
input                   clipping_enable_i;
input                   zbuffer_enable_i;
input            [31:2] zbuffer_base_i;
input [point_width-1:0] target_size_x_i;
input [point_width-1:0] target_size_y_i;
input [point_width-1:0] clip_pixel0_x_i;
input [point_width-1:0] clip_pixel0_y_i;
input [point_width-1:0] clip_pixel1_x_i;
input [point_width-1:0] clip_pixel1_y_i;
input [point_width-1:0] cuvz_pixel_x_i;
input [point_width-1:0] cuvz_pixel_y_i;
input signed [point_width-1:0] cuvz_pixel_z_i;
input [point_width-1:0] cuvz_u_i;
input [point_width-1:0] cuvz_v_i;
input             [7:0] cuvz_a_i;
input            [31:0] cuvz_color_i;
input                   cuvz_write_i;
input [point_width-1:0] raster_pixel_x_i;
input [point_width-1:0] raster_pixel_y_i;
input [point_width-1:0] raster_u_i;
input [point_width-1:0] raster_v_i;
input            [31:0] flat_color_i;
input                   raster_write_i;
output reg              ack_o;
input             z_ack_i;
output     [31:2] z_addr_o;
input      [31:0] z_data_i;
output reg  [3:0] z_sel_o;
output reg        z_request_o;
input             wbm_busy_i;
output reg [point_width-1:0] pixel_x_o;
output reg [point_width-1:0] pixel_y_o;
output reg [point_width-1:0] pixel_z_o;
output reg [point_width-1:0] u_o;
output reg [point_width-1:0] v_o;
output reg             [7:0] a_o;
input      [point_width-1:0] bezier_factor0_i;
input      [point_width-1:0] bezier_factor1_i;
output reg [point_width-1:0] bezier_factor0_o;
output reg [point_width-1:0] bezier_factor1_o;
output reg            [31:0] color_o;
output reg write_o;
input ack_i;
reg [1:0] state;
parameter wait_state = 2'b00, z_read_state = 2'b01, write_pixel_state = 2'b10;
wire [31:0] pixel_offset = (target_size_x_i*cuvz_pixel_y_i   + {16'h0,   cuvz_pixel_x_i}) << 1; 
assign z_addr_o = zbuffer_base_i + pixel_offset[31:2];
wire [31:0] z_value_at_target32;
wire signed [point_width-1:0] z_value_at_target = z_value_at_target32[point_width-1:0];
memory_to_color memory_proc(
.color_depth_i (2'b01),
.mem_i         (z_data_i),
.mem_lsb_i     (cuvz_pixel_x_i[1:0]),
.color_o       (z_value_at_target32),
.sel_o         ()
);
always @(posedge clk_i or posedge rst_i)
if(rst_i)
begin
  u_o              <= 1'b0;
  v_o              <= 1'b0;
  bezier_factor0_o <= 1'b0;
  bezier_factor1_o <= 1'b0;
  pixel_x_o        <= 1'b0;
  pixel_y_o        <= 1'b0;
  pixel_z_o        <= 1'b0;
  color_o          <= 1'b0;
  a_o              <= 1'b0;
  z_sel_o          <= 4'b1111;
end
else
begin
  if(raster_write_i)
  begin
    u_o              <= raster_u_i;
    v_o              <= raster_v_i;
    a_o              <= 8'hff;
    color_o          <= flat_color_i;
    pixel_x_o        <= raster_pixel_x_i;
    pixel_y_o        <= raster_pixel_y_i;
    pixel_z_o        <= 1'b0;
  end
  else if(cuvz_write_i)
  begin
    u_o              <= cuvz_u_i;
    v_o              <= cuvz_v_i;
    a_o              <= cuvz_a_i;
    color_o          <= cuvz_color_i;
    pixel_x_o        <= cuvz_pixel_x_i;
    pixel_y_o        <= cuvz_pixel_y_i;
    pixel_z_o        <= cuvz_pixel_z_i;
    bezier_factor0_o <= bezier_factor0_i;
    bezier_factor1_o <= bezier_factor1_i;
  end
end
wire fail_z_check   = z_value_at_target > cuvz_pixel_z_i;
wire outside_target = raster_write_i ? (raster_pixel_x_i >= target_size_x_i) | (raster_pixel_y_i >= target_size_y_i) :
                      (cuvz_pixel_x_i >= target_size_x_i) | (cuvz_pixel_y_i >= target_size_y_i);
wire outside_clip   = raster_write_i ? (raster_pixel_x_i < clip_pixel0_x_i) | (raster_pixel_y_i < clip_pixel0_y_i) | (raster_pixel_x_i >= clip_pixel1_x_i) | (raster_pixel_y_i >= clip_pixel1_y_i) :
                      (cuvz_pixel_x_i < clip_pixel0_x_i) | (cuvz_pixel_y_i < clip_pixel0_y_i) | (cuvz_pixel_x_i >= clip_pixel1_x_i) | (cuvz_pixel_y_i >= clip_pixel1_y_i);
wire discard_pixel  = outside_target | (clipping_enable_i & outside_clip);
wire write_i        = raster_write_i | cuvz_write_i;
always @(posedge clk_i or posedge rst_i)
if(rst_i)
begin
  ack_o            <= 1'b0;
  write_o          <= 1'b0;
  z_request_o      <= 1'b0;
  z_sel_o          <= 4'b1111;
end
else
begin
  case (state)
    wait_state:
    begin
      if(write_i)
        ack_o         <= discard_pixel;
      else
        ack_o         <= 1'b0;
      if(write_i & zbuffer_enable_i)
        z_request_o   <= ~discard_pixel;
      else if(write_i)
        write_o       <= ~discard_pixel;
    end
    z_read_state:
      if(z_ack_i)
      begin
        write_o     <= ~fail_z_check;
        ack_o       <= fail_z_check;
        z_request_o <= 1'b0;
      end
      else
        z_request_o <= ~wbm_busy_i | z_request_o;
    write_pixel_state:
    begin
      write_o <= 1'b0;
      if(ack_i)
        ack_o <= 1'b1;    
    end
  endcase
end
always @(posedge clk_i or posedge rst_i)
if(rst_i)
  state <= wait_state;
else
  case (state)
    wait_state:
      if(write_i & ~discard_pixel)
      begin
        if(zbuffer_enable_i)
          state <= z_read_state;
        else 
          state <= write_pixel_state;
      end
    z_read_state:
      if(z_ack_i)
        state <= fail_z_check ? wait_state : write_pixel_state;
    write_pixel_state:
      if(ack_i)
        state <= wait_state;
  endcase
endmodule
