module altera_up_edge_detection_hysteresis (
	clk,
	reset,
	data_in,
	data_en,
	data_out
);
parameter WIDTH	= 640; 
input						clk;
input						reset;
input			[ 7: 0]	data_in;
input						data_en;
output		[ 7: 0]	data_out;
wire			[ 8: 0]	shift_reg_out[ 1: 0];
wire						data_above_high_threshold;
wire			[ 8: 0]	data_to_shift_register_1;
wire						above_threshold;
wire						overflow;
reg			[ 8: 0]	data_line_2[ 1: 0];
reg			[ 2: 0]	thresholds[ 2: 0];
reg			[ 7: 0]	result;
integer					i;
always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		data_line_2[0] <= 8'h00;
		data_line_2[1] <= 8'h00;
		for (i = 2; i >= 0; i = i-1)
			thresholds[i] <= 3'h0;
	end
	else if (data_en == 1'b1)
	begin
		data_line_2[1] <= data_line_2[0] | {9{data_line_2[0][8]}};
		data_line_2[0] <= {1'b0, shift_reg_out[0][7:0]} + 32;
		thresholds[0] <= {thresholds[0][1:0], data_above_high_threshold};
		thresholds[1] <= {thresholds[1][1:0], shift_reg_out[0][8]};
		thresholds[2] <= {thresholds[2][1:0], shift_reg_out[1][8]};
		result <= (above_threshold) ? data_line_2[1][7:0] : 8'h00;
	end
end
assign data_out = result; 
assign data_above_high_threshold = (data_in >= 8'h0A) ? 1'b1 : 1'b0;
assign data_to_shift_register_1  = {data_above_high_threshold,data_in};
assign above_threshold = 
		((|(thresholds[0])) | (|(thresholds[1])) | (|(thresholds[2])));
altera_up_edge_detection_data_shift_register shift_register_1 (
	.clock		(clk),
	.clken		(data_en),
	.shiftin		(data_to_shift_register_1),
	.shiftout	(shift_reg_out[0]),
	.taps			()
);
defparam
	shift_register_1.DW		= 9,
	shift_register_1.SIZE	= WIDTH;
altera_up_edge_detection_data_shift_register shift_register_2 (
	.clock		(clk),
	.clken		(data_en),
	.shiftin		(shift_reg_out[0]),
	.shiftout	(shift_reg_out[1]),
	.taps			()
);
defparam
	shift_register_2.DW		= 9,
	shift_register_2.SIZE	= WIDTH;
endmodule
