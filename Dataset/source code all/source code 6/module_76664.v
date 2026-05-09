module altera_up_audio_in_deserializer (
	clk,
	reset,
	bit_clk_rising_edge,
	bit_clk_falling_edge,
	left_right_clk_rising_edge,
	left_right_clk_falling_edge,
	done_channel_sync,
	serial_audio_in_data,
	read_left_audio_data_en,
	read_right_audio_data_en,
	left_audio_fifo_read_space,
	right_audio_fifo_read_space,
	left_channel_data,
	right_channel_data
);
parameter DW					= 15;
parameter BIT_COUNTER_INIT	= 5'h0F;
input						clk;
input						reset;
input						bit_clk_rising_edge;
input						bit_clk_falling_edge;
input						left_right_clk_rising_edge;
input						left_right_clk_falling_edge;
input						done_channel_sync;
input						serial_audio_in_data;
input						read_left_audio_data_en;
input						read_right_audio_data_en;
output reg	[ 7: 0]	left_audio_fifo_read_space;
output reg	[ 7: 0]	right_audio_fifo_read_space;
output		[DW: 0]	left_channel_data;
output		[DW: 0]	right_channel_data;
wire						valid_audio_input;
wire						left_channel_fifo_is_empty;
wire						right_channel_fifo_is_empty;
wire						left_channel_fifo_is_full;
wire						right_channel_fifo_is_full;
wire			[ 6: 0]	left_channel_fifo_used;
wire			[ 6: 0]	right_channel_fifo_used;
reg			[DW: 0]	data_in_shift_reg;
always @(posedge clk)
begin
	if (reset == 1'b1)
		left_audio_fifo_read_space			<= 8'h00;
	else
	begin
		left_audio_fifo_read_space[7]		<= left_channel_fifo_is_full;
		left_audio_fifo_read_space[6:0]	<= left_channel_fifo_used;
	end
end
always @(posedge clk)
begin
	if (reset == 1'b1)
		right_audio_fifo_read_space		<= 8'h00;
	else
	begin
		right_audio_fifo_read_space[7]	<= right_channel_fifo_is_full;
		right_audio_fifo_read_space[6:0]	<= right_channel_fifo_used;
	end
end
always @(posedge clk)
begin
	if (reset == 1'b1)
		data_in_shift_reg	<= 'h0;
	else if (bit_clk_rising_edge & valid_audio_input)
		data_in_shift_reg	<= 
			{data_in_shift_reg[(DW - 1):0], 
			 serial_audio_in_data};
end
altera_up_audio_bit_counter Audio_Out_Bit_Counter (
	.clk									(clk),
	.reset								(reset),
	.bit_clk_rising_edge				(bit_clk_rising_edge),
	.bit_clk_falling_edge			(bit_clk_falling_edge),
	.left_right_clk_rising_edge	(left_right_clk_rising_edge),
	.left_right_clk_falling_edge	(left_right_clk_falling_edge),
	.counting							(valid_audio_input)
);
defparam 
	Audio_Out_Bit_Counter.BIT_COUNTER_INIT	= BIT_COUNTER_INIT;
altera_up_sync_fifo Audio_In_Left_Channel_FIFO(
	.clk									(clk),
	.reset								(reset),
	.write_en							(left_right_clk_falling_edge & ~left_channel_fifo_is_full & done_channel_sync),
	.write_data							(data_in_shift_reg),
	.read_en								(read_left_audio_data_en & ~left_channel_fifo_is_empty),
	.fifo_is_empty						(left_channel_fifo_is_empty),
	.fifo_is_full						(left_channel_fifo_is_full),
	.words_used							(left_channel_fifo_used),
	.read_data							(left_channel_data)
);
defparam 
	Audio_In_Left_Channel_FIFO.DW				= DW,
	Audio_In_Left_Channel_FIFO.DATA_DEPTH	= 128,
	Audio_In_Left_Channel_FIFO.AW				= 6;
altera_up_sync_fifo Audio_In_Right_Channel_FIFO(
	.clk									(clk),
	.reset								(reset),
	.write_en							(left_right_clk_rising_edge & ~right_channel_fifo_is_full & done_channel_sync),
	.write_data							(data_in_shift_reg),
	.read_en								(read_right_audio_data_en & ~right_channel_fifo_is_empty),
	.fifo_is_empty						(right_channel_fifo_is_empty),
	.fifo_is_full						(right_channel_fifo_is_full),
	.words_used							(right_channel_fifo_used),
	.read_data							(right_channel_data)
);
defparam 
	Audio_In_Right_Channel_FIFO.DW			= DW,
	Audio_In_Right_Channel_FIFO.DATA_DEPTH	= 128,
	Audio_In_Right_Channel_FIFO.AW			= 6;
endmodule
