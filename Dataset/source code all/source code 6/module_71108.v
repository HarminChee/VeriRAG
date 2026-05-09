module i2s_audio
  (
   input             bus_clk,
   input 	     quiesce,
   input 	     clk_100,
   output reg	     audio_mclk,
   output reg	     audio_dac,
   input 	     audio_adc,
   input 	     audio_bclk,
   input 	     audio_lrclk,
   input 	     user_w_audio_wren,
   input [31:0]      user_w_audio_data,
   output 	     user_w_audio_full,
   input 	     user_w_audio_open,
   input 	     user_r_audio_rden,
   output [31:0]     user_r_audio_data,
   output 	     user_r_audio_empty,
   output 	     user_r_audio_eof,
   input 	     user_r_audio_open
   );
   reg 		     audio_adc_reg;
   reg 		     audio_bclk_reg;
   reg 		     audio_lrclk_reg;
   reg 		     audio_lrclk_reg_d;
   reg [1:0] 	     clk_div;
   reg [15:0] 	     play_shreg;
   reg [1:0] 	     bclk_d;
   reg 		     fifo_rd_en;
   wire 	     bclk_rising, bclk_falling;
   wire [31:0] 	     play_fifo_data;
   reg [31:0] 	     record_shreg;
   reg [4:0] 	     record_count;
   reg 		     write_when_done;
   reg 		     fifo_wr_en; 		     
   assign 	     user_r_audio_eof = 0;
   always @(posedge clk_100)
     begin
	clk_div <= clk_div + 1;
	audio_mclk <= clk_div[1];
     end
   assign bclk_rising = (bclk_d == 2'b01);
   assign bclk_falling = (bclk_d == 2'b10);
   always @(posedge bus_clk)
     begin
	audio_adc_reg <= audio_adc;
    	audio_bclk_reg <= audio_bclk;
    	audio_lrclk_reg <= audio_lrclk;
	bclk_d <= { bclk_d, audio_bclk_reg };
	if (bclk_rising)
	  audio_lrclk_reg_d <= audio_lrclk_reg;
	fifo_rd_en <= 0; 
	if (bclk_rising && !audio_lrclk_reg && audio_lrclk_reg_d)
	  play_shreg <= play_fifo_data[31:16]; 
	else if (bclk_rising && audio_lrclk_reg && !audio_lrclk_reg_d)
	  begin
	     play_shreg <= play_fifo_data[15:0]; 
	     fifo_rd_en <= 1;
	  end
	else if (bclk_falling)
	  begin
	     audio_dac <= play_shreg[15];
	     play_shreg <= { play_shreg, 1'b0 };
	  end
	fifo_wr_en <= 0; 
	if (bclk_rising && (record_count != 0))
	  begin
	     record_shreg <= { record_shreg, audio_adc_reg };
	     record_count <= record_count - 1;
	     if (record_count == 1)
	       begin
		  fifo_wr_en <= write_when_done;
		  write_when_done <= 0;
	       end	       
	  end
	if (bclk_rising && !audio_lrclk_reg && audio_lrclk_reg_d)
	  begin
	     record_count <= 16;
	     write_when_done <= 0;
	  end	
	else if (bclk_rising && audio_lrclk_reg && !audio_lrclk_reg_d)
	  begin
	     record_count <= 16;
	     write_when_done <= 1;
	  end
     end
   fifo_32x512 playback_fifo 
     (
      .clk(bus_clk),
      .srst(!user_w_audio_open),
      .din(user_w_audio_data), 
      .wr_en(user_w_audio_wren),
      .rd_en(fifo_rd_en),
      .dout(play_fifo_data), 
      .full(user_w_audio_full),
      .empty());
   fifo_32x512 record_fifo 
     (
      .clk(bus_clk),
      .srst(!user_r_audio_open),
      .din(record_shreg), 
      .wr_en(fifo_wr_en),
      .rd_en(user_r_audio_rden),
      .dout(user_r_audio_data), 
      .full(),
      .empty(user_r_audio_empty));
endmodule 
