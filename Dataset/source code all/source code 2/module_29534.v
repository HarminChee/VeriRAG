`timescale 1ps/1ps
`timescale 1ps/1ps
module v_axi4s_vid_out_v3_0_vid_out_formatter
#( 
parameter  DATA_WIDTH = 24
 )
( 
  input  wire                    video_out_clk, 
  input  wire                    rst   ,        
  input  wire                    vid_ce,        
  input  wire  [DATA_WIDTH -1:0] odf_data  ,    
  input  wire                    odf_vsync ,    
  input  wire                    odf_hsync ,  
  input  wire                    odf_vblank,  
  input  wire                    odf_hblank, 
  input  wire                    odf_act_vid,
  input  wire                    odf_field_id, 
  input  wire                    locked    ,    
  input  wire                    fifo_rd_en,    
  output  wire                    video_de    ,  
  output  wire                    video_vsync ,  
  output  wire                    video_hsync ,  
  output  wire                    video_vblank,  
  output  wire                    video_hblank,  
  output  wire                    video_field_id,
  output  wire [DATA_WIDTH -1:0]  video_data     
);
  reg    [DATA_WIDTH -1:0]   in_data_mux;  
  reg                        in_de_mux;  
  reg                        in_vsync_mux;  
  reg                        in_hsync_mux;  
  reg                        in_vblank_mux;  
  reg                        in_hblank_mux; 
  reg                        in_field_id_mux; 
  reg                        first_full_frame = 0;  
  reg                        odf_vblank_1 = 0;      
  reg                        vblank_rising = 0;     
  assign video_data   = in_data_mux;
  assign video_vsync  = in_vsync_mux;
  assign video_hsync  = in_hsync_mux;
  assign video_vblank = in_vblank_mux;
  assign video_hblank = in_hblank_mux;
  assign video_de     = in_de_mux;
  assign video_field_id = in_field_id_mux;
  always @ (posedge video_out_clk) begin
    if (vid_ce) begin
      odf_vblank_1      <= odf_vblank;
      vblank_rising <= odf_vblank && !odf_vblank_1;
    end
  end
  always @ (posedge video_out_clk)begin
    if (rst || !locked) begin
     first_full_frame <= 0;
    end
    else if (vblank_rising & vid_ce) begin
     first_full_frame <= 1;
   end 
  end	 
  always @ (posedge video_out_clk)begin
    if (!locked || rst || !first_full_frame) begin
      in_de_mux     <= 0;
      in_vsync_mux  <= 0;
      in_hsync_mux  <= 0;    
      in_vblank_mux <= 0;
      in_hblank_mux <= 0;
      in_field_id_mux <= 0;    
      in_data_mux   <= 0;
    end
    else if (vid_ce) begin
      in_de_mux     <= odf_act_vid;
      in_vsync_mux  <= odf_vsync;
      in_hsync_mux  <= odf_hsync;
      in_vblank_mux <= odf_vblank;
      in_hblank_mux <= odf_hblank;
	  in_field_id_mux <= odf_field_id;
      if (fifo_rd_en)
        in_data_mux  <= odf_data;
    end
  end
endmodule
