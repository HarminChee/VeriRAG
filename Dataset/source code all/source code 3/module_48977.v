module Computer_System_VGA_Subsystem_Char_Buf_Subsystem_ASCII_to_Image (
	clk,
	reset,
	ascii_in_channel,
	ascii_in_data,
	ascii_in_startofpacket,
	ascii_in_endofpacket,
	ascii_in_valid,
	ascii_in_ready,
	image_out_ready,
	image_out_data,
	image_out_startofpacket,
	image_out_endofpacket,
	image_out_valid
);
parameter IDW		= 7;
parameter ODW		= 0;
input						clk;
input						reset;
input			[ 5: 0]	ascii_in_channel;
input			[IDW:0]	ascii_in_data;
input						ascii_in_startofpacket;
input						ascii_in_endofpacket;
input						ascii_in_valid;
output					ascii_in_ready;
input						image_out_ready;
output reg	[ODW:0]	image_out_data;
output reg				image_out_startofpacket;
output reg				image_out_endofpacket;
output reg				image_out_valid;
wire						rom_data;
reg						internal_startofpacket;
reg						internal_endofpacket;
reg						internal_valid;
always @(posedge clk)
begin
	if (reset)
	begin
		image_out_data				<=  'h0;
		image_out_startofpacket	<= 1'b0;
		image_out_endofpacket	<= 1'b0;
		image_out_valid			<= 1'b0;
	end
	else if (image_out_ready | ~image_out_valid)
	begin
		image_out_data				<= rom_data;
		image_out_startofpacket	<= internal_startofpacket;
		image_out_endofpacket	<= internal_endofpacket;
		image_out_valid			<= internal_valid;
	end
end
always @(posedge clk)
begin
	if (reset)
	begin
		internal_startofpacket	<= 1'b0;
		internal_endofpacket		<= 1'b0;
		internal_valid				<= 1'b0;
	end
	else if (ascii_in_ready)
	begin
		internal_startofpacket	<= ascii_in_startofpacket;
		internal_endofpacket		<= ascii_in_endofpacket;
		internal_valid				<= ascii_in_valid;
	end
end
assign ascii_in_ready = ~ascii_in_valid | image_out_ready | ~image_out_valid;
altera_up_video_ascii_rom_128 ASCII_Character_Rom (
	.clk					(clk),
	.clk_en				(ascii_in_ready),
	.character			(ascii_in_data[ 6: 0]),
	.x_coordinate		(ascii_in_channel[ 2: 0]),
	.y_coordinate		(ascii_in_channel[ 5: 3]),
	.character_data	(rom_data)
);
endmodule
