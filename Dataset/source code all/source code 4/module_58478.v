module altera_up_edge_detection_sobel_operator (
	clk,
	reset,
	data_in,
	data_en,
	data_out
);
parameter WIDTH	= 640; 
input						clk;
input						reset;
input			[ 8: 0]	data_in;
input						data_en;
output		[ 9: 0]	data_out;
wire			[ 8: 0]	shift_reg_out[ 1: 0];
reg			[ 8: 0]	original_line_1[ 2: 0];
reg			[ 8: 0]	original_line_2[ 2: 0];
reg			[ 8: 0]	original_line_3[ 2: 0];
reg			[11: 0]	gx_level_1[ 3: 0];
reg			[11: 0]	gx_level_2[ 1: 0];
reg			[11: 0]	gx_level_3;
reg			[11: 0]	gy_level_1[ 3: 0];
reg			[11: 0]	gy_level_2[ 1: 0];
reg			[11: 0]	gy_level_3;
reg			[11: 0]	gx_magnitude;
reg			[11: 0]	gy_magnitude;
reg			[ 1: 0]	gx_sign;
reg			[ 1: 0]	gy_sign;
reg			[11: 0]	g_magnitude;
reg						gy_over_gx;
reg			[ 9: 0]	result;
integer					i;
always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		for (i = 2; i >= 0; i = i-1)
		begin
			original_line_1[i] <= 9'h000;
			original_line_2[i] <= 9'h000;
			original_line_3[i] <= 9'h000;
		end
		gx_level_1[0] <= 12'h000;
		gx_level_1[1] <= 12'h000;
		gx_level_1[2] <= 12'h000;
		gx_level_1[3] <= 12'h000;
		gx_level_2[0] <= 12'h000;
		gx_level_2[1] <= 12'h000;
		gx_level_3	  <= 12'h000;
		gy_level_1[0] <= 12'h000;
		gy_level_1[1] <= 12'h000;
		gy_level_1[2] <= 12'h000;
		gy_level_1[3] <= 12'h000;
		gy_level_2[0] <= 12'h000;
		gy_level_2[1] <= 12'h000;
		gy_level_3	  <= 12'h000;
		gx_magnitude  <= 12'h000;
		gy_magnitude  <= 12'h000;
		gx_sign		  <= 2'h0;
		gy_sign		  <= 2'h0;
		g_magnitude	  <= 12'h000;
		gy_over_gx	  <= 1'b0;
		result		  <= 9'h000;
	end
	else if (data_en == 1'b1)
	begin	
		for (i = 2; i > 0; i = i-1)
		begin
			original_line_1[i] <= original_line_1[i-1];
			original_line_2[i] <= original_line_2[i-1];
			original_line_3[i] <= original_line_3[i-1];
		end
		original_line_1[0] <= data_in;
		original_line_2[0] <= shift_reg_out[0];
		original_line_3[0] <= shift_reg_out[1];
		gx_level_1[0] <= {3'h0,original_line_1[0]} + {3'h0,original_line_3[0]};
		gx_level_1[1] <= {2'h0,original_line_2[0], 1'b0};
		gx_level_1[2] <= {3'h0,original_line_1[2]} + {3'h0,original_line_3[2]};
		gx_level_1[3] <= {2'h0,original_line_2[2], 1'b0};
		gx_level_2[0] <= gx_level_1[0] + gx_level_1[1];
		gx_level_2[1] <= gx_level_1[2] + gx_level_1[3];
		gx_level_3    <= gx_level_2[0] - gx_level_2[1];
		gy_level_1[0] <= {3'h0,original_line_1[0]} + {3'h0,original_line_1[2]};
		gy_level_1[1] <= {2'h0,original_line_1[1], 1'b0};
		gy_level_1[2] <= {3'h0,original_line_3[0]} + {3'h0,original_line_3[2]};
		gy_level_1[3] <= {2'h0,original_line_3[1], 1'b0};
		gy_level_2[0] <= gy_level_1[0] + gy_level_1[1];
		gy_level_2[1] <= gy_level_1[2] + gy_level_1[3];
		gy_level_3    <= gy_level_2[0] - gy_level_2[1];
		gx_magnitude  <= (gx_level_3[11]) ? (~gx_level_3) + 12'h001 : gx_level_3; 
		gy_magnitude  <= (gy_level_3[11]) ? (~gy_level_3) + 12'h001 : gy_level_3; 
		gx_sign		  <= {gx_sign[0], gx_level_3[11]};
		gy_sign		  <= {gy_sign[0], gy_level_3[11]};
		g_magnitude	  <= gx_magnitude + gy_magnitude;
		gy_over_gx	  <= (gx_magnitude >= gy_magnitude) ? 1'b0 : 1'b1;
		result[9]	  <= gx_sign[1] ^ gy_sign[1];
		result[8]	  <= gx_sign[1] ^ gy_sign[1] ^ gy_over_gx;
		result[7:0]	  <= (g_magnitude[11:10] == 2'h0) ? g_magnitude[9:2] : 8'hFF;
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
