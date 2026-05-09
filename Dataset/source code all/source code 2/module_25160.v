module Raster_Laser_Projector_Video_In_video_decoder_0 (
	clk,
	reset,
	TD_CLK27,
	TD_DATA,
	TD_HS,
	TD_VS,
	clk27_reset,
	stream_out_ready,
	TD_RESET,
	overflow_flag,
	stream_out_data,
	stream_out_startofpacket,
	stream_out_endofpacket,
	stream_out_empty,
	stream_out_valid
);
parameter IW		= 7;
parameter OW		= 15;
parameter FW		= 17;
parameter PIXELS	= 1280;
input						clk;
input						reset;
input						TD_CLK27;
input			[ 7: 0]	TD_DATA;
input						TD_HS;
input						TD_VS;
input 						clk27_reset;
input						stream_out_ready;
output					TD_RESET;
output reg				overflow_flag;
output		[OW: 0]	stream_out_data;
output					stream_out_startofpacket;
output					stream_out_endofpacket;
output					stream_out_empty;
output					stream_out_valid;
wire						video_clk;
wire						video_clk_reset;
wire			[OW: 0]	decoded_pixel;
wire						decoded_startofpacket;
wire						decoded_endofpacket;
wire						decoded_valid;
wire			[FW: 0]	data_from_fifo;
wire			[ 6: 0]	fifo_used_words;
wire			[ 6: 0]	wrusedw;
wire						wrfull;
wire						rdempty;
reg						reached_start_of_frame;
always @(posedge video_clk)
begin
	if (video_clk_reset)
		overflow_flag <= 1'b0;
	else if (decoded_valid & reached_start_of_frame & wrfull)
		overflow_flag <= 1'b1;
end
always @(posedge video_clk)
begin
	if (video_clk_reset)
		reached_start_of_frame <= 1'b0;
	else if (decoded_valid & decoded_startofpacket)
		reached_start_of_frame <= 1'b1;
end
assign TD_RESET						= 1'b1;
assign stream_out_data				= data_from_fifo[OW: 0];
assign stream_out_startofpacket	= data_from_fifo[(FW - 1)];
assign stream_out_endofpacket		= data_from_fifo[FW];
assign stream_out_empty				= 1'b0;
assign stream_out_valid				= ~rdempty;
assign video_clk						= TD_CLK27;
assign video_clk_reset					= clk27_reset;
altera_up_video_itu_656_decoder ITU_R_656_Decoder (
	.clk				(video_clk),
	.reset			(video_clk_reset),
	.TD_DATA			(TD_DATA),
	.ready			(decoded_valid & ~wrfull),
	.data				(decoded_pixel),
	.startofpacket	(decoded_startofpacket),
	.endofpacket	(decoded_endofpacket),
	.valid			(decoded_valid)
);
altera_up_video_dual_clock_fifo Video_In_Dual_Clock_FIFO (
	.wrclk			(video_clk),
	.wrreq			(decoded_valid & reached_start_of_frame & ~wrfull),
	.data				({decoded_endofpacket, decoded_startofpacket, decoded_pixel}),
	.rdclk			(clk),
	.rdreq			(stream_out_valid & stream_out_ready),
	.wrusedw			(wrusedw),
	.wrfull			(wrfull),
	.q					(data_from_fifo),
	.rdusedw			(fifo_used_words),
	.rdempty			(rdempty)
);
defparam 
	Video_In_Dual_Clock_FIFO.DW = (FW + 1);
endmodule
