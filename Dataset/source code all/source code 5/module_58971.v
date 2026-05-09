module Computer_System_Video_In_Subsystem_Edge_Detection_Subsystem_Edge_Detection (
	clk,
	reset,
	in_data,
	in_startofpacket,
	in_endofpacket,
	in_empty,
	in_valid,
	out_ready,
	in_ready,
	out_data,
	out_startofpacket,
	out_endofpacket,
	out_empty,
	out_valid
);
parameter WIDTH	= 720; 
input						clk;
input						reset;
input			[ 7: 0]	in_data;
input						in_startofpacket;
input						in_endofpacket;
input						in_empty;
input						in_valid;
input						out_ready;
output					in_ready;
output reg	[ 7: 0]	out_data;
output reg				out_startofpacket;
output reg				out_endofpacket;
output reg				out_empty;
output reg				out_valid;
wire						transfer_data;
wire			[ 8: 0]	filter_1_data_out;  	
wire			[ 9: 0]	filter_2_data_out;  	
wire			[ 7: 0]	filter_3_data_out;  	
wire			[ 7: 0]	filter_4_data_out;  	
wire			[ 7: 0]	final_value;			
wire			[ 1: 0]	pixel_info_in;
wire			[ 1: 0]	pixel_info_out;
reg			[ 7: 0]	data;
reg						startofpacket;
reg						endofpacket;
reg						empty;
reg						valid;
reg						flush_pipeline;
always @(posedge clk)
begin
	if (reset)
	begin
		out_data				<= 8'h00;
		out_startofpacket	<= 1'b0;
		out_endofpacket	<= 1'b0;
		out_empty			<= 1'b0;
		out_valid			<= 1'b0;
	end
	else if (transfer_data)
	begin
		out_data				<= final_value;
		out_startofpacket	<= pixel_info_out[1] & ~(&(pixel_info_out));
		out_endofpacket	<= pixel_info_out[0] & ~(&(pixel_info_out));
		out_empty			<= 1'b0;
		out_valid			<= (|(pixel_info_out));
	end
	else if (out_ready)
		out_valid			<= 1'b0;
end
always @(posedge clk)
begin
	if (reset)
	begin
		data					<= 8'h00;
		startofpacket		<= 1'b0;
		endofpacket			<= 1'b0;
		empty					<= 1'b0;
		valid					<= 1'b0;
	end
	else if (in_ready)
	begin
		data					<= in_data;
		startofpacket		<= in_startofpacket;
		endofpacket			<= in_endofpacket;
		empty					<= in_empty;
		valid					<= in_valid;
	end
end
always @(posedge clk)
begin
	if (reset)
		flush_pipeline		<= 1'b0;
	else if (in_ready & in_endofpacket)
		flush_pipeline		<= 1'b1;
	else if (in_ready & in_startofpacket)
		flush_pipeline		<= 1'b0;
end
assign in_ready 			= in_valid & (out_ready | ~out_valid);
assign transfer_data		= in_ready | 
		(flush_pipeline & (out_ready | ~out_valid));
assign final_value		= filter_4_data_out;
assign pixel_info_in[1]	= in_valid & ~in_endofpacket; 
assign pixel_info_in[0]	= in_valid & ~in_startofpacket;
altera_up_edge_detection_gaussian_smoothing_filter Filter_1 (
	.clk			(clk),
	.reset		(reset),
	.data_in		(data),
	.data_en		(transfer_data),
	.data_out	(filter_1_data_out)
);
defparam 
	Filter_1.WIDTH = WIDTH;	
altera_up_edge_detection_sobel_operator Filter_2 (
	.clk			(clk),
	.reset		(reset),
	.data_in		(filter_1_data_out),
	.data_en		(transfer_data),
	.data_out	(filter_2_data_out)
);
defparam 
	Filter_2.WIDTH = WIDTH;	
altera_up_edge_detection_nonmaximum_suppression Filter_3 (
	.clk			(clk),
	.reset		(reset),
	.data_in		(filter_2_data_out),
	.data_en		(transfer_data),
	.data_out	(filter_3_data_out)
);
defparam 
	Filter_3.WIDTH = WIDTH;	
altera_up_edge_detection_hysteresis Filter_4 (
	.clk			(clk),
	.reset		(reset),
	.data_in		(filter_3_data_out),
	.data_en		(transfer_data),
	.data_out	(filter_4_data_out)
);
defparam 
	Filter_4.WIDTH = WIDTH;	
altera_up_edge_detection_pixel_info_shift_register Pixel_Info_Shift_Register (
	.clock		(clk),
	.clken		(transfer_data),
	.shiftin		(pixel_info_in),
	.shiftout	(pixel_info_out),
	.taps			()
);
defparam 
	Pixel_Info_Shift_Register.SIZE = (WIDTH * 5) + 28;	
endmodule
