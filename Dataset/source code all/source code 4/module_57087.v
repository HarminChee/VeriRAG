module vga_crtc_fml (
    input         clk,              
    input         rst,
    input         enable_crtc,
    input [5:0]   cur_start,
    input [5:0]   cur_end,
    input [4:0]   vcursor,
    input [6:0]   hcursor,
    input [6:0]   horiz_total,
    input [6:0]   end_horiz,
    input [6:0]   st_hor_retr,
    input [4:0]   end_hor_retr,
    input [9:0]   vert_total,
    input [9:0]   end_vert,
    input [9:0]   st_ver_retr,
    input [3:0]   end_ver_retr,
    output reg [9:0]  h_count,      
    output reg        horiz_sync_i,
    output reg [9:0]  v_count,      
    output reg        vert_sync,
    output reg        video_on_h_i,
    output reg        video_on_v
  );
  wire [9:0] hor_disp_end;
  wire [9:0] hor_scan_end;
  wire [9:0] ver_disp_end;
  wire [9:0] ver_sync_beg;
  wire [3:0] ver_sync_end;
  wire [9:0] ver_scan_end;
  assign hor_scan_end = { horiz_total[6:2] + 1'b1, horiz_total[1:0], 3'h7 };
  assign hor_disp_end = { end_horiz, 3'h7 };
  assign ver_scan_end = vert_total + 10'd1;
  assign ver_disp_end = end_vert + 10'd1;
  assign ver_sync_beg = st_ver_retr;
  assign ver_sync_end = end_ver_retr + 4'd1;
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
      if (enable_crtc)
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
endmodule
