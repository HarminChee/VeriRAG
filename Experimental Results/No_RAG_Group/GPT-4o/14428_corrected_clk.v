module bcode_encoder_corrected_clk(
	input			clk,
	input			pps,
	input			rst_n,
	input			clk_reload_n,
	input			utc_cnv_end,
	input	[5 : 0]	sec_bin,
	input	[5 : 0]	min_bin,
	input	[4 : 0]	hour_bin,
	input	[8 : 0]	day_bin,
	input	[15: 0]	year_bin,
	input	[63: 0]	tai_sec,
	input	[7 : 0]	time_zone,
	input	[63: 0]	dst_ing,
	input	[63: 0]	dst_eng,
	input	[63: 0]	leap_occur,
	input			leap_direct,
	input	[3 : 0] time_quality,
	input	[16: 0]	sec_of_day,
	output			bcode_trans
);
localparam	CODE_P				= 4'd7;
localparam	CODE_1				= 4'd4;
localparam	CODE_0				= 4'd1;
localparam	BCD_WAIT_PPS		= 11'b1;
localparam	BCD_WAIT_UTC_CNV	= 11'b10;
localparam	BCD_CNV_SEC_START	= 11'b100;
localparam	BCD_CNV_SEC			= 11'b1000;
localparam	BCD_CNV_MIN_START	= 11'b10000;
localparam	BCD_CNV_MIN			= 11'b100000;
localparam	BCD_CNV_HOUR_START	= 11'b1000000;
localparam	BCD_CNV_HOUR		= 11'b10000000;
localparam	BCD_CNV_DAY_START	= 11'b100000000;
localparam	BCD_CNV_DAY			= 11'b1000000000;
localparam	BCD_ECC				= 11'b10000000000;
localparam	ITR_WAIT_PPS		= 11'b1;
localparam	ITR_SEND_SEC		= 11'b10;
localparam	ITR_SEND_MIN		= 11'b100;
localparam	ITR_SEND_HOUR		= 11'b1000;
localparam	ITR_SEND_DAY_LOW	= 11'b10000;
localparam	ITR_SEND_DAY_HIGH	= 11'b100000;
localparam	ITR_SEND_YEAR		= 11'b1000000;
localparam	ITR_SEND_CTRL_FLAG	= 11'b10000000;
localparam	ITR_SEND_ECC		= 11'b100000000;
localparam	ITR_SEND_SBS_LOW	= 11'b1000000000;
localparam	ITR_SEND_SBS_HIGH	= 11'b10000000000;
wire					pps_forward;
wire					clk_100hz;
wire					clk_1khz;
wire					pps_forward_ok;
wire					clk_100hz_ok;
wire					clk_1khz_ok;
reg			[1	: 0]	pps_catch;
reg			[1	: 0]	pps_catch_100hz;
reg			[1	: 0]	pps_catch_1khz;
wire					pps_redge_catch;
wire					pps_redge_catch_100hz;
wire					pps_redge_catch_1khz;
reg			[10	: 0]	bcd_cnv_state;
reg			[10	: 0]	bcd_next_state;
reg			[10 : 0]	itr_cnv_state;
reg			[10 : 0]	itr_next_state;
reg						cnv_ok;
reg			[3	: 0]	bit_count;
wire					bit_count_less_than_9;
reg			[7	: 0]	sec_bcd;
reg			[7	: 0]	min_bcd;
reg			[7	: 0]	hour_bcd;
reg			[11	: 0]	day_bcd;
reg			[7	: 0]	year_bcd;
reg			[63	: 0]	tai_plus_59;
reg	signed	[7	: 0]	time_offset;
reg						dst_flag;
reg						leap_precast;
reg						dst_precast;
reg						time_offset_sign;
reg			[3	: 0]	time_offset_hour;
reg						time_offset_half_hour;
reg						ecc_bit;
wire					is_not_dst_period;
wire		[4	: 0]	time_offset_complete;
reg			[8	: 0]	shifter;
reg			[3	: 0]	rz_code;
reg			[8	: 0]	bcd_bin_num;
reg						bcd_start;
reg			[15	: 0]	l_bcd_bin_num;
reg						l_bcd_start;
wire					bcd_end;
wire		[11	: 0]	bcd_rslt;
wire					l_bcd_end;
wire		[19	: 0]	l_bcd_rslt;
reg			[3	: 0]	rz_encode_timer;
reg						bcode_gen;
always @ (posedge clk or negedge clk_reload_n)
begin
	if (!clk_reload_n) begin
		pps_catch <= 2'b11;
	end
	else begin
		pps_catch[0] <= pps_forward;
		pps_catch[1] <= pps_catch[0];
	end
end
assign pps_redge_catch = (pps_catch == 2'b01) ? 1 : 0;
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		bcd_cnv_state <= BCD_WAIT_PPS;
	end
	else begin
		bcd_cnv_state <= bcd_next_state;
	end
end
always @ (*)
begin
	case (bcd_cnv_state)
		BCD_WAIT_PPS		: begin
			if (pps_redge_catch) begin
				bcd_next_state = BCD_WAIT_UTC_CNV;
			end
			else begin
				bcd_next_state = BCD_WAIT_PPS;
			end
		end
		BCD_WAIT_UTC_CNV	: begin
			if (utc_cnv_end) begin
				bcd_next_state = BCD_CNV_SEC_START;
			end
			else begin
				bcd_next_state = BCD_WAIT_UTC_CNV;
			end
		end
		BCD_CNV_SEC_START	: begin
			bcd_next_state = BCD_CNV_SEC;
		end
		BCD_CNV_SEC			: begin
			if (bcd_end) begin
				bcd_next_state = BCD_CNV_MIN_START;
			end
			else begin
				bcd_next_state = BCD_CNV_SEC;
			end
		end
		BCD_CNV_MIN_START	: begin
			bcd_next_state = BCD_CNV_MIN;
		end
		BCD_CNV_MIN			: begin
			if (bcd_end) begin
				bcd_next_state = BCD_CNV_HOUR_START;
			end
			else begin
				bcd_next_state = BCD_CNV_MIN;
			end
		end
		BCD_CNV_HOUR_START	: begin
			bcd_next_state = BCD_CNV_HOUR;
		end
		BCD_CNV_HOUR		: begin
			if (bcd_end) begin
				bcd_next_state = BCD_CNV_DAY_START;
			end
			else begin
				bcd_next_state = BCD_CNV_HOUR;
			end
		end
		BCD_CNV_DAY_START	: begin
			bcd_next_state = BCD_CNV_DAY;
		end
		BCD_CNV_DAY			: begin
			if (bcd_end) begin
				bcd_next_state = BCD_ECC;
			end
			else begin
				bcd_next_state = BCD_CNV_DAY;
			end
		end
		BCD_ECC				: begin
			bcd_next_state = BCD_WAIT_PPS;
		end
	endcase
end
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		cnv_ok <= 0;
	end
	else begin
		case (bcd_cnv_state)
			BCD_WAIT_PPS			: begin
				if (pps_redge_catch) begin
					cnv_ok <= 0;
				end
				else begin
					cnv_ok <= cnv_ok;
				end
			end
			BCD_WAIT_UTC_CNV		: begin
				bcd_bin_num <= sec_bin;
				bcd_start <= 0;
				l_bcd_bin_num <= year_bin;
				l_bcd_start <= 0;
			end
			BCD_CNV_SEC_START		: begin
				bcd_start <= 1;
				l_bcd_start <= 1;
				tai_plus_59 <= tai_sec + 64'd59;
				time_offset <= $signed(time_zone) +
					((is_not_dst_period) ?
					($signed(8'd0)) : ($signed(8'd2)));
				dst_flag <= (is_not_dst_period) ? 0 : 1;
			end
			BCD_CNV_SEC				: begin
				bcd_start <= 0;
				l_bcd_start <= 0;
				sec_bcd <= bcd_rslt;
			end
			BCD_CNV_MIN_START		: begin
				bcd_bin_num <= min_bin;
				bcd_start <= 1;
				if ((tai_plus_59 < leap_occur) ||
					(tai_sec > leap_occur)) begin
					leap_precast <= 0;
				end
				else begin
					leap_precast <= 1;
				end
				if ((tai_plus_59 < dst_ing) ||
					(tai_sec > dst_ing)) begin
					dst_precast <= 0;
				end
				else begin
					dst_precast <= 1;
				end
				if (time_offset < 0) begin
					time_offset_sign <= 1;
					time_offset_hour <= time_offset_complete[4 : 1];
					time_offset_half_hour <= time_offset_complete[0];
				end
				else begin
					time_offset_sign <= 0;
					time_offset_hour <= time_offset[4 : 1];
					time_offset_half_hour <= time_offset[0];
				end
			end
			BCD_CNV_MIN				: begin
				bcd_start <= 0;
				min_bcd <= bcd_rslt;
				year_bcd <= l_bcd_rslt;
			end
			BCD_CNV_HOUR_START		: begin
				bcd_bin_num <= hour_bin;
				bcd_start <= 1;
			end
			BCD_CNV_HOUR			: begin
				bcd_start <= 0;
				hour_bcd <= bcd_rslt;
			end
			BCD_CNV_DAY_START		: begin
				bcd_bin_num <= day_bin;
				bcd_start <= 1;
			end
			BCD_CNV_DAY				: begin
				bcd_start <= 0;
				day_bcd <= bcd_rslt;
			end
			BCD_ECC					: begin
				ecc_bit <=
					!(^{sec_bcd,
						min_bcd,
						hour_bcd,
						day_bcd,
						year_bcd,
						leap_precast,
						leap_direct,
						dst_precast,
						dst_flag,
						time_offset_sign,
						time_offset_hour,
						time_offset_half_hour,
						time_quality});
				cnv_ok <= 1;
			end
		endcase
	end
end
assign is_not_dst_period = ((tai_sec < dst_ing) || (tai_sec > dst_eng)) ? 1 : 0;
assign time_offset_complete = ~(time_offset[4 : 0]) + 1;
bin2bcd #(
	.BIN_BITS(9)
	)bin2bcd_short (
	.clk(clk),
	.rst(rst_n),
	.start(bcd_start),
	.bin_num_in(bcd_bin_num),
	.bcd_out(bcd_rslt),
	.end_of_cnv(bcd_end)
	);
bin2bcd #(
	.BIN_BITS(16)
	)bin2bcd_long (
	.clk(clk),
	.rst(rst_n),
	.start(l_bcd_start),
	.bin_num_in(l_bcd_bin_num),
	.bcd_out(l_bcd_rslt),
	.end_of_cnv(l_bcd_end)
	);
always @ (posedge clk or negedge clk_reload_n)
begin
	if (!clk_reload_n) begin
		pps_catch_100hz <= 2'b11;
	end
	else begin
		pps_catch_100hz[0] <= pps_forward;
		pps_catch_100hz[1] <= pps_catch_100hz[0];
	end
end
assign pps_redge_catch_100hz = (pps_catch_100hz == 2'b01) ? 1 : 0;
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		itr_cnv_state <= ITR_WAIT_PPS;
	end
	else begin
		itr_cnv_state <= itr_next_state;
	end
end
always @ (*)
begin
	case (itr_cnv_state)
		ITR_WAIT_PPS		: begin
			if (pps_redge_catch_100hz) begin
				itr_next_state = ITR_SEND_SEC;
			end
			else begin
				itr_next_state = ITR_WAIT_PPS;
			end
		end
		ITR_SEND_SEC		: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_SEC;
			end
			else begin
				itr_next_state = ITR_SEND_MIN;
			end
		end
		ITR_SEND_MIN		: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_MIN;
			end
			else begin
				itr_next_state = ITR_SEND_HOUR;
			end
		end
		ITR_SEND_HOUR		: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_HOUR;
			end
			else begin
				itr_next_state = ITR_SEND_DAY_LOW;
			end
		end
		ITR_SEND_DAY_LOW	: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_DAY_LOW;
			end
			else begin
				itr_next_state = ITR_SEND_DAY_HIGH;
			end
		end
		ITR_SEND_DAY_HIGH	: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_DAY_HIGH;
			end
			else begin
				itr_next_state = ITR_SEND_YEAR;
			end
		end
		ITR_SEND_YEAR		: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_YEAR;
			end
			else begin
				itr_next_state = ITR_SEND_CTRL_FLAG;
			end
		end
		ITR_SEND_CTRL_FLAG	: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_CTRL_FLAG;
			end
			else begin
				itr_next_state = ITR_SEND_ECC;
			end
		end
		ITR_SEND_ECC		: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_ECC;
			end
			else begin
				itr_next_state = ITR_SEND_SBS_LOW;
			end
		end
		ITR_SEND_SBS_LOW	: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_SBS_LOW;
			end
			else begin
				itr_next_state = ITR_SEND_SBS_HIGH;
			end
		end
		ITR_SEND_SBS_HIGH	: begin
			if (bit_count_less_than_9) begin
				itr_next_state = ITR_SEND_SBS_HIGH;
			end
			else begin
				itr_next_state = ITR_WAIT_PPS;
			end
		end
	endcase
end
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		shifter <= 0;
		bit_count <= 0;
		rz_code <= CODE_P;
	end
	else begin
		case (itr_cnv_state)
			ITR_WAIT_PPS		: begin
				if (pps_redge_catch_100hz) begin
					shifter <= {sec_bcd[4 * 1 +: 4], 
								1'b0,
								sec_bcd[4 * 0 +: 4]}
								>> 1;
					bit_count <= 2;
					rz_code <= (sec_bcd[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					bit_count <= 1;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_SEC		: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= {min_bcd[4 * 1 +: 4],
								1'b0,
								min_bcd[4 * 0 +: 4]};
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_MIN		: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= {hour_bcd[4 * 1 +: 4],
								1'b0,
								hour_bcd[4 * 0 +: 4]};
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_HOUR		: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= {day_bcd[4 * 1 +: 4],
								1'b0,
								day_bcd[4 * 0 +: 4]};
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_DAY_LOW	: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= {5'b0,
								day_bcd[4 * 2 +: 4]};
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_DAY_HIGH	: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= {year_bcd[4 * 1 +: 4],
								1'b0,
								year_bcd[4 * 0 +: 4]};
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_YEAR		: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= {time_offset_hour,
								time_offset_sign,
								dst_flag,
								dst_precast,
								leap_direct,
								leap_precast};
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_CTRL_FLAG : begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= {3'b0,
								ecc_bit,
								time_quality,
								time_offset_half_hour};
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_ECC		: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= sec_of_day[0 +: 9];
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_SBS_LOW	: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= {1'b0,
								sec_of_day[9 +: 8]};
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
			ITR_SEND_SBS_HIGH	: begin
				if (bit_count_less_than_9) begin
					shifter <= shifter >> 1;
					bit_count <= bit_count + 1;
					rz_code <= (shifter[0]) ?
								CODE_1 :
								CODE_0;
				end
				else begin
					shifter <= 9'bx;
					bit_count <= 0;
					rz_code <= CODE_P;
				end
			end
		endcase
	end
end
assign bit_count_less_than_9 = (bit_count < 9) ? 1 : 0;
always @ (posedge clk or negedge clk_reload_n)
begin
	if (!clk_reload_n) begin
		pps_catch_1khz <= 2'b11;
	end
	else begin
		pps_catch_1khz[0] <= pps_forward;
		pps_catch_1khz[1] <= pps_catch_1khz[0];
	end
end
assign pps_redge_catch_1khz = (pps_catch_1khz == 2'b01) ? 1 : 0;
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		rz_encode_timer <= 4'd1;
	end
	else begin
		if ((rz_encode_timer < rz_code) ||
			(!(rz_encode_timer < 4'd9))) begin
			bcode_gen <= 1;
		end
		else begin
			bcode_gen <= 0;
		end
		if (pps_redge_catch_1khz) begin
			rz_encode_timer <= 4'd1;
		end
		else if (rz_encode_timer < 4'd9) begin
			rz_encode_timer <= rz_encode_timer + 1;
		end
		else begin
			rz_encode_timer <= 0;
		end
	end
end
assign bcode_trans = bcode_gen;
clk_synchronizer #(
	.SYSCLK_FREQ_HZ(64'd100_000_000),
	.PPS_HIGH_LEVEL_US(64'd1_000),
	.GENCLK_FREQ_HZ(1),
	.FORWARD_OFFSET_CLK(1)
	) pps_forward_generator (
	.clk(clk),
	.rst_n(clk_reload_n),
	.pps_in(pps),
	.sync_clk_out(pps_forward),
	.clk_sync_ok_out(pps_forward_ok)
	);
clk_synchronizer #(
	.SYSCLK_FREQ_HZ(64'd100_000_000),
	.PPS_HIGH_LEVEL_US(64'd1_000),
	.GENCLK_FREQ_HZ(100),
	.FORWARD_OFFSET_CLK(0)
	) synced_100hz_generator (
	.clk(clk),
	.rst_n(clk_reload_n),
	.pps_in(pps),
	.sync_clk_out(clk_100hz),
	.clk_sync_ok_out(clk_100hz_ok)
	);
clk_synchronizer #(
	.SYSCLK_FREQ_HZ(64'd100_000_000),
	.PPS_HIGH_LEVEL_US(64'd100),
	.GENCLK_FREQ_HZ(1000),
	.FORWARD_OFFSET_CLK(0)
	) synced_1khz_generator (
	.clk(clk),
	.rst_n(clk_reload_n),
	.pps_in(pps),
	.sync_clk_out(clk_1khz),
	.clk_sync_ok_out(clk_1khz_ok)
	);
endmodule