module altera_up_edge_detection_nonmaximum_suppression (
	clk,
	reset,
	data_in,
	data_en,
	data_out
);
parameter WIDTH	= 640; 
input						clk;
input						reset;
input			[ 9: 0]	data_in;
input						data_en;
output		[ 7: 0]	data_out;
wire			[ 9: 0]	shift_reg_out[ 1: 0];
reg			[ 9: 0]	original_line_1[ 2: 0];
reg			[ 9: 0]	original_line_2[ 2: 0];
reg			[ 9: 0]	original_line_3[ 2: 0];
reg			[ 7: 0]	suppress_level_1[ 4: 0];
reg			[ 8: 0]	suppress_level_2[ 2: 0];
reg			[ 7: 0]	suppress_level_3;
reg			[ 1: 0]	average_flags;
reg			[ 7: 0]	result;
integer					i;
always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		for (i = 2; i >= 0; i = i-1)
		begin
			original_line_1[i] 	<= 10'h000;
			original_line_2[i] 	<= 10'h000;
			original_line_3[i] 	<= 10'h000;
		end
		for (i = 4; i >= 0; i = i-1)
		begin
			suppress_level_1[i] 	<= 8'h00;
		end
		suppress_level_2[0] 		<= 9'h000;
		suppress_level_2[1] 		<= 9'h000;
		suppress_level_2[2] 		<= 9'h000;
		suppress_level_3   	 	<= 8'h00;
		average_flags				<= 2'h0;
	end
	else if (data_en == 1'b1)
	begin	
		for (i = 2; i > 0; i = i-1)
		begin
			original_line_1[i] 	<= original_line_1[i-1];
			original_line_2[i] 	<= original_line_2[i-1];
			original_line_3[i] 	<= original_line_3[i-1];
		end
		original_line_1[0] 		<= data_in;
		original_line_2[0] 		<= shift_reg_out[0];
		original_line_3[0] 		<= shift_reg_out[1];
		suppress_level_1[0] 		<= original_line_2[1][ 7: 0];
		case (original_line_2[1][9:8])
			2'b00 :
			begin
				suppress_level_1[1] <= original_line_1[0][ 7: 0];
				suppress_level_1[2] <= original_line_2[0][ 7: 0];
				suppress_level_1[3] <= original_line_2[2][ 7: 0];
				suppress_level_1[4] <= original_line_3[2][ 7: 0];
			end
			2'b01 :
			begin
				suppress_level_1[1] <= original_line_1[0][ 7: 0];
				suppress_level_1[2] <= original_line_1[1][ 7: 0];
				suppress_level_1[3] <= original_line_3[1][ 7: 0];
				suppress_level_1[4] <= original_line_3[2][ 7: 0];
			end
			2'b10 :
			begin
				suppress_level_1[1] <= original_line_1[1][ 7: 0];
				suppress_level_1[2] <= original_line_1[2][ 7: 0];
				suppress_level_1[3] <= original_line_3[0][ 7: 0];
				suppress_level_1[4] <= original_line_3[1][ 7: 0];
			end
			2'b11 :
			begin
				suppress_level_1[1] <= original_line_1[2][ 7: 0];
				suppress_level_1[2] <= original_line_2[2][ 7: 0];
				suppress_level_1[3] <= original_line_2[0][ 7: 0];
				suppress_level_1[4] <= original_line_3[0][ 7: 0];
			end
		endcase
		suppress_level_2[0] <= {1'b0,suppress_level_1[0]};
		suppress_level_2[1] <= {1'b0,suppress_level_1[1]} + {1'h0,suppress_level_1[2]};
		suppress_level_2[2] <= {1'b0,suppress_level_1[3]} + {1'h0,suppress_level_1[3]};
		suppress_level_3 <= suppress_level_2[0][ 7: 0];
		average_flags[0] <= (suppress_level_2[0][ 7: 0] >= suppress_level_2[1][ 8: 1]) ? 1'b1 : 1'b0;
		average_flags[1] <= (suppress_level_2[0][ 7: 0] >= suppress_level_2[2][ 8: 1]) ? 1'b1 : 1'b0;
		result <= (average_flags == 2'b11) ? suppress_level_3 : 8'h00;
	end
end
assign data_out = result; 
altera_up_edge_detection_data_shift_register shift_register_1 (
	.clock		(clk),
	.clken		(data_en),
	.shiftin		(data_in),
	.shiftout	(shift_reg_out[0]),
	.taps			()
);
defparam
	shift_register_1.DW		= 10,
	shift_register_1.SIZE	= WIDTH;
altera_up_edge_detection_data_shift_register shift_register_2 (
	.clock		(clk),
	.clken		(data_en),
	.shiftin		(shift_reg_out[0]),
	.shiftout	(shift_reg_out[1]),
	.taps			()
);
defparam
	shift_register_2.DW		= 10,
	shift_register_2.SIZE	= WIDTH;
endmodule
