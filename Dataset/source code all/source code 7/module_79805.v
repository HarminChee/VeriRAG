module altera_up_video_clipper_add (
	clk,
	reset,
	stream_in_data,
	stream_in_startofpacket,
	stream_in_endofpacket,
	stream_in_empty,
	stream_in_valid,
	stream_out_ready,
	stream_in_ready,
	stream_out_data,
	stream_out_startofpacket,
	stream_out_endofpacket,
	stream_out_empty,
	stream_out_valid
);
parameter DW						=  15; 
parameter EW						=   0; 
parameter IMAGE_WIDTH			= 640; 
parameter IMAGE_HEIGHT			= 480; 
parameter WW						=   9; 
parameter HW						=   8; 
parameter ADD_PIXELS_AT_START	=   0;
parameter ADD_PIXELS_AT_END	=   0;
parameter ADD_LINES_AT_START	=   0;
parameter ADD_LINES_AT_END		=   0;
parameter ADD_DATA				= 16'h0; 
input						clk;
input						reset;
input			[DW: 0]	stream_in_data;
input						stream_in_startofpacket;
input						stream_in_endofpacket;
input			[EW: 0]	stream_in_empty;
input						stream_in_valid;
input						stream_out_ready;
output					stream_in_ready;
output reg	[DW: 0]	stream_out_data;
output reg				stream_out_startofpacket;
output reg				stream_out_endofpacket;
output reg	[EW: 0]	stream_out_empty;
output reg				stream_out_valid;
wire						increment_counters;
wire						new_startofpacket;
wire						new_endofpacket;
wire						pass_inner_frame;
always @(posedge clk)
begin
	if (reset)
	begin
		stream_out_data				<=  'h0;
		stream_out_startofpacket	<= 1'b0;
		stream_out_endofpacket		<= 1'b0;
		stream_out_empty				<=  'h0;
		stream_out_valid				<= 1'b0;
	end
	else if (stream_out_ready | ~stream_out_valid)
	begin
		if (pass_inner_frame)
			stream_out_data			<= stream_in_data;
		else
			stream_out_data			<= ADD_DATA;
		stream_out_startofpacket	<= new_startofpacket;
		stream_out_endofpacket		<= new_endofpacket;
		stream_out_empty				<=  'h0;
		if (pass_inner_frame)
			stream_out_valid			<= stream_in_valid;
		else
			stream_out_valid			<= 1'b1;
	end
end
assign stream_in_ready		= pass_inner_frame & (~stream_out_valid | stream_out_ready);
assign increment_counters	= (~stream_out_valid | stream_out_ready) & 
									  (~pass_inner_frame | stream_in_valid);
altera_up_video_clipper_counters Clipper_Add_Counters (
	.clk							(clk),
	.reset						(reset),
	.increment_counters		(increment_counters),
	.start_of_outer_frame	(new_startofpacket),
	.end_of_outer_frame		(new_endofpacket),
	.start_of_inner_frame	(),
	.end_of_inner_frame		(),
	.inner_frame_valid		(pass_inner_frame)
);
defparam	
	Clipper_Add_Counters.IMAGE_WIDTH		= IMAGE_WIDTH,
	Clipper_Add_Counters.IMAGE_HEIGHT	= IMAGE_HEIGHT,
	Clipper_Add_Counters.WW					= WW,
	Clipper_Add_Counters.HW					= HW,
	Clipper_Add_Counters.LEFT_OFFSET		= ADD_PIXELS_AT_START,
	Clipper_Add_Counters.RIGHT_OFFSET	= ADD_PIXELS_AT_END,
	Clipper_Add_Counters.TOP_OFFSET		= ADD_LINES_AT_START,
	Clipper_Add_Counters.BOTTOM_OFFSET	= ADD_LINES_AT_END;
endmodule
