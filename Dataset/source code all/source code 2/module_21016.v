`timescale 1ps/1ps
`timescale 1ps/1ps
module v_axi4s_vid_out_v3_0_out_coupler
#( 
  parameter DATA_WIDTH = 24,
  parameter RAM_ADDR_BITS = 10,    
  parameter FILL_GUARDBAND = 2
 )
( 
  input  wire                      video_out_clk,  
  input  wire                      rst        ,  
  input  wire                      vid_ce,       
  input  wire                      fifo_rst,     
  input                            aclk,         
  input                            aclken,       
  input                            aresetn,      
  input  wire  [DATA_WIDTH +2:0]   wr_data  ,    
  input                            valid   ,     
  output  reg                      ready,        
  output wire [DATA_WIDTH -1:0]    rd_data,      
  output wire                      eol,          
  output wire                      sof,          
  output wire                      fid,          
  input  wire                      rd_en,        
  output wire [RAM_ADDR_BITS -1:0] level_wr,     
  output wire [RAM_ADDR_BITS -1:0] level_rd,     
  output wire                      wr_error,   
  output wire                      rd_error  ,  
  output wire                      empty,  
  input wire                       locked        
);
  reg   [DATA_WIDTH +2:0]  fifo_wr_data;  
  wire  [DATA_WIDTH +2:0]  fifo_dout;      
  reg                      locked_1;       
  reg                      locked_2;       
  wire                     hysteresis_met; 
  wire                     full;           
  reg                      wr_en;          
  wire                     reset;
  wire [RAM_ADDR_BITS-1:0] remaining;      
  wire                     ready_comb;     
  assign reset = rst || !aresetn || fifo_rst;
  v_axi4s_vid_out_v3_0_bridge_async_fifo_2 
  #(
    .RAM_WIDTH     (DATA_WIDTH + 3),
    .RAM_ADDR_BITS (RAM_ADDR_BITS)
  )
  bridge_async_fifo_2_i
  (
   .wr_clk	        (aclk),
   .rd_clk         (video_out_clk),
   .rst            (reset),
   .wr_ce          (aclken ),
   .rd_ce          (vid_ce ),
   .wr_en          (wr_en ),
   .rd_en          (rd_en ),
   .din            (fifo_wr_data   ),
   .dout           (fifo_dout  ),
   .empty          (empty),
   .rd_error       (rd_error),
   .full           (full        ),
   .wr_error       (wr_error),
   .level_rd       (level_rd),
   .level_wr       (level_wr)
  );
assign rd_data = fifo_dout[DATA_WIDTH-1:0];
assign eol     = fifo_dout[DATA_WIDTH];
assign sof     = fifo_dout[DATA_WIDTH+1];
assign fid     = fifo_dout[DATA_WIDTH+2];
assign remaining = ~level_wr;
assign ready_comb = !(full || (remaining <= FILL_GUARDBAND));
  always @ (posedge aclk ) begin 
    if (rst) begin
	  ready <= 0;
	  wr_en <= 0;
	  fifo_wr_data <= 0;
	end
	else begin
        ready   <= ready_comb;
      if (aclken) begin
        wr_en <= valid && ready;
        fifo_wr_data<= wr_data;
      end
    end  
  end
endmodule
