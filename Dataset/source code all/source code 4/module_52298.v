module altera_up_edge_detection_gaussian_smoothing_filter (
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
output		[ 8: 0]	data_out;
wire			[ 7: 0]	shift_reg_out[ 3: 0];
reg			[ 7: 0]	original_line_1[ 4: 0];
reg			[ 7: 0]	original_line_2[ 4: 0];
reg			[ 7: 0]	original_line_3[ 4: 0];
reg			[ 7: 0]	original_line_4[ 4: 0];
reg			[ 7: 0]	original_line_5[ 4: 0];
reg			[15: 0]	sum_level_1[12: 0];
reg			[15: 0]	sum_level_2[ 6: 0];
reg			[15: 0]	sum_level_3[ 4: 0];
reg			[15: 0]	sum_level_4[ 2: 0];
reg			[15: 0]	sum_level_5[ 1: 0];
reg			[15: 0]	sum_level_6;
reg			[ 8: 0]	sum_level_7;
integer				i;
always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		for (i = 4; i >= 0; i = i-1)
		begin
			original_line_1[i] <= 8'h00;
			original_line_2[i] <= 8'h00;
			original_line_3[i] <= 8'h00;
			original_line_4[i] <= 8'h00;
			original_line_5[i] <= 8'h00;
		end
		for (i = 12; i >= 0; i = i-1)
		begin
			sum_level_1[i] <= 16'h0000;
		end
		for (i = 6; i >= 0; i = i-1)
		begin
			sum_level_2[i] <= 16'h0000;
		end
		for (i = 4; i >= 0; i = i-1)
		begin
			sum_level_3[i] <= 16'h0000;
		end
		sum_level_4[0] <= 16'h0000;
		sum_level_4[1] <= 16'h0000;
		sum_level_4[2] <= 16'h0000;
		sum_level_5[0] <= 16'h0000;
		sum_level_5[1] <= 16'h0000;
		sum_level_6    <= 16'h0000;
		sum_level_7    <= 9'h000;
	end
	else if (data_en == 1'b1)
	begin	
		for (i = 4; i > 0; i = i-1)
		begin
			original_line_1[i] <= original_line_1[i-1];
			original_line_2[i] <= original_line_2[i-1];
			original_line_3[i] <= original_line_3[i-1];
			original_line_4[i] <= original_line_4[i-1];
			original_line_5[i] <= original_line_5[i-1];
		end
		original_line_1[0] <= data_in;
		original_line_2[0] <= shift_reg_out[0];
		original_line_3[0] <= shift_reg_out[1];
		original_line_4[0] <= shift_reg_out[2];
		original_line_5[0] <= shift_reg_out[3];
		sum_level_1[ 0] <= {7'h00,original_line_1[0], 1'b0} + {7'h00,original_line_1[4], 1'b0};
		sum_level_1[ 1] <= {7'h00,original_line_5[0], 1'b0} + {7'h00,original_line_5[4], 1'b0};
		sum_level_1[ 2] <= {6'h00,original_line_1[1], 2'h0} + {6'h00,original_line_1[3], 2'h0};
		sum_level_1[ 3] <= {6'h00,original_line_2[0], 2'h0} + {6'h00,original_line_2[4], 2'h0};
		sum_level_1[ 4] <= {6'h00,original_line_4[0], 2'h0} + {6'h00,original_line_4[4], 2'h0};
		sum_level_1[ 5] <= {6'h00,original_line_5[1], 2'h0} + {6'h00,original_line_5[3], 2'h0};
		sum_level_1[ 6] <= {8'h00,original_line_1[2]} + {8'h00,original_line_5[2]};
		sum_level_1[ 7] <= {8'h00,original_line_3[0]} + {8'h00,original_line_3[4]};
		sum_level_1[ 8] <= {8'h00,original_line_2[1]} + {8'h00,original_line_2[3]};
		sum_level_1[ 9] <= {8'h00,original_line_4[1]} + {8'h00,original_line_4[3]};
		sum_level_1[10] <= {8'h00,original_line_2[2]} + {8'h00,original_line_4[2]};
		sum_level_1[11] <= {8'h00,original_line_3[1]} + {8'h00,original_line_3[3]};
		sum_level_1[12] <= {4'h0,original_line_3[2], 4'h0} - original_line_3[2];
		sum_level_2[ 0] <= sum_level_1[ 0] + sum_level_1[ 1];
		sum_level_2[ 1] <= sum_level_1[ 2] + sum_level_1[ 3];
		sum_level_2[ 2] <= sum_level_1[ 4] + sum_level_1[ 5];
		sum_level_2[ 3] <= sum_level_1[ 6] + sum_level_1[ 7];
		sum_level_2[ 4] <= sum_level_1[ 8] + sum_level_1[ 9];
		sum_level_2[ 5] <= sum_level_1[10] + sum_level_1[11];
		sum_level_2[ 6] <= sum_level_1[12];
		sum_level_3[ 0] <= sum_level_2[ 0] + sum_level_2[ 6];
		sum_level_3[ 1] <= sum_level_2[ 1] + sum_level_2[ 2];
		sum_level_3[ 2] <= {sum_level_2[ 3], 2'h0} + sum_level_2[ 3];
		sum_level_3[ 3] <= {sum_level_2[ 4], 3'h0} + sum_level_2[ 4];
		sum_level_3[ 4] <= {sum_level_2[ 5], 3'h0} + {sum_level_2[ 5], 2'h0};
		sum_level_4[ 0] <= sum_level_3[ 0] + sum_level_3[ 1];
		sum_level_4[ 1] <= sum_level_3[ 2] + sum_level_3[ 3];
		sum_level_4[ 2] <= sum_level_3[ 4];
		sum_level_5[ 0] <= sum_level_4[ 0] + sum_level_4[ 1];
		sum_level_5[ 1] <= sum_level_4[ 2];
		sum_level_6     <= sum_level_5[ 0] + sum_level_5[ 1];
		sum_level_7     <= sum_level_6[15:7];
	end
end
assign data_out = sum_level_7; 
altera_up_edge_detection_data_shift_register shift_register_1 (
	.clock		(clk),
	.clken		(data_en),
	.shiftin		(data_in),
	.shiftout	(shift_reg_out[0]),
	.taps			()
);
defparam
	shift_register_1.DW		= 8,
	shift_register_1.SIZE	= WIDTH;
altera_up_edge_detection_data_shift_register shift_register_2 (
	.clock		(clk),
	.clken		(data_en),
	.shiftin		(shift_reg_out[0]),
	.shiftout	(shift_reg_out[1]),
	.taps			()
);
defparam
	shift_register_2.DW		= 8,
	shift_register_2.SIZE	= WIDTH;
altera_up_edge_detection_data_shift_register shift_register_3 (
	.clock		(clk),
	.clken		(data_en),
	.shiftin		(shift_reg_out[1]),
	.shiftout	(shift_reg_out[2]),
	.taps			()
);
defparam
	shift_register_3.DW		= 8,
	shift_register_3.SIZE	= WIDTH;
altera_up_edge_detection_data_shift_register shift_register_4 (
	.clock		(clk),
	.clken		(data_en),
	.shiftin		(shift_reg_out[2]),
	.shiftout	(shift_reg_out[3]),
	.taps			()
);
defparam
	shift_register_4.DW		= 8,
	shift_register_4.SIZE	= WIDTH;
endmodule
