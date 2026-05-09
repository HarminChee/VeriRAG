module bcode_generator_corrected_clk (
    // Add test_mode input for DFT control
    input               test_mode,
	input 				clk,
	input				rst_n,
	input				clk_reload_n,
	input				pps_in,
	input	[63	: 0]	tai_sec_in,
	input	[15	: 0]	leap_sec_in,
	input	[7	: 0]	leap_direct_in,
	input	[63	: 0]	leap_occur_in,
	input	[63	: 0]	dst_ing_in,
	input	[63 : 0]	dst_eng_in,
	input	[7	: 0]	time_zone_in,
	input	[7	: 0]	time_quality_in,
	output	[55	: 0]	utc_time_out,
	output				bcode_out
);
localparam	LREF_INIT	= 3'b0;
localparam	LREF_IDLE	= 3'b1;
localparam	LREF_HOLD	= 3'b10;
localparam	LREF_DELAY	= 3'b100;
wire		[16	: 0]	year;
wire		[8	: 0]	day_of_year;
wire		[4	: 0]	hour_of_day;
wire		[5	: 0]	minute_of_hour;
wire		[5	: 0]	sec_of_minute;
wire		[16	: 0]	sec_of_day;
wire					utc_time_ok;
wire					pps_redge_catch;
reg			[1	: 0]	pps_redge_catcher;
reg			[15	: 0]	leap_sec_rec;
reg						leap_sec_refresh;
reg			[7	: 0]	lref_state;
reg			[7	: 0]	lref_next_state;
reg			[2	: 0]	lref_delay_count;

// DFT Fix: Mux potentially problematic inputs passed to sub-modules if they might be used as clocks internally.
// Assuming 'pps_in' might be misused as a clock inside 'bcode_encoder', replace it with 'clk' during test_mode.
wire bcode_encoder_pps_muxed;
assign bcode_encoder_pps_muxed = test_mode ? clk : pps_in;

// Assuming 'pps_in' might be misused as a clock inside 'tai_to_utc', replace it with 'clk' during test_mode.
wire tai_cnv_pps_muxed;
assign tai_cnv_pps_muxed = test_mode ? clk : pps_in;


assign	utc_time_out[8 * 0 +: 16] = year[15 : 0];
assign	utc_time_out[8 * 2 +: 16] = day_of_year;
assign	utc_time_out[8 * 4 +:  8] = hour_of_day;
assign	utc_time_out[8 * 5 +:  8] = minute_of_hour;
assign	utc_time_out[8 * 6 +:  8] = sec_of_minute;
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		pps_redge_catcher <= 2'b11;
	end
	else begin
		pps_redge_catcher[0] <= pps_in;
		pps_redge_catcher[1] <= pps_redge_catcher[0];
	end
end
assign	pps_redge_catch = (pps_redge_catcher == 2'b01) ? 1'b1 : 1'b0;
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		lref_state <= LREF_INIT;
	end
	else begin
		lref_state <= lref_next_state;
	end
end
always @ (*)
begin
	case (lref_state)
		LREF_INIT	: begin
			lref_next_state = LREF_IDLE;
		end
		LREF_IDLE	: begin
			if (leap_sec_rec == leap_sec_in) begin
				lref_next_state = LREF_IDLE;
			end
			else begin
				lref_next_state = LREF_HOLD;
			end
		end
		LREF_HOLD	: begin
			if (pps_redge_catch) begin
				lref_next_state = LREF_DELAY;
			end
			else begin
				lref_next_state = LREF_HOLD;
			end
		end
		LREF_DELAY	: begin
			if (lref_delay_count < 3'b111) begin
				lref_next_state = LREF_DELAY;
			end
			else begin
				lref_next_state = LREF_IDLE;
			end
		end
		default		: begin
			lref_next_state = LREF_IDLE;
		end
	endcase
end
always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		lref_delay_count <= 3'b0;
		leap_sec_refresh <= 1'b0;
        leap_sec_rec <= 16'b0; // Initialize leap_sec_rec
	end
	else begin
        // Default assignments to avoid latches for unspecified states/conditions
        lref_delay_count <= lref_delay_count;
        leap_sec_refresh <= leap_sec_refresh;
        leap_sec_rec <= leap_sec_rec;

		case (lref_state)
			LREF_INIT	: begin
                // No state update needed here based on original logic
			end
			LREF_IDLE	: begin
				if (leap_sec_rec == leap_sec_in) begin
					leap_sec_refresh <= 1'b0;
				end
				else begin
					leap_sec_refresh <= 1'b1;
                    // Update leap_sec_rec only in HOLD state as per original logic?
                    // Original code updates leap_sec_rec only in LREF_HOLD.
                    // Let's keep original logic structure.
				end
			end
			LREF_HOLD	: begin
				leap_sec_rec <= leap_sec_in; // Update happens here
                leap_sec_refresh <= 1'b0; // Ensure refresh stops once holding
                lref_delay_count <= 3'b0; // Reset delay count when entering HOLD? No, reset on exit/completion.
			end
			LREF_DELAY	: begin
                if (lref_delay_count < 3'b111) begin // Check before incrementing
				    lref_delay_count <= lref_delay_count + 1'b1;
                end else begin
                    lref_delay_count <= 3'b0; // Reset count after finishing delay
                end
                leap_sec_refresh <= 1'b0; // Refresh is off during delay
			end
			default		: begin
                // Handle default case explicitly if needed
			end
		endcase
	end
end

tai_to_utc tai_cnv(
	.clk(clk),
	.rst(rst_n), // Assuming tai_to_utc uses active high reset named rst
    // .pps_in(pps_in), // Original connection
    .pps_in(tai_cnv_pps_muxed), // Corrected connection for DFT
	.tai_sec_in(tai_sec_in),
	.leap_sec_in(leap_sec_in),
	.leap_sec_refresh_in(leap_sec_refresh),
	.leap_direct_in(leap_direct_in),
	.leap_occur_in(leap_occur_in),
	.dst_ing_in(dst_ing_in),
	.dst_eng_in(dst_eng_in),
	.time_zone_in(time_zone_in),
	.year_out(year),
	.day_of_year_out(day_of_year),
	.hour_of_day_out(hour_of_day),
	.minute_of_hour_out(minute_of_hour),
	.sec_of_minute_out(sec_of_minute),
	.sec_of_day_out(sec_of_day),
	.utc_time_ok_out(utc_time_ok)
);

bcode_encoder bcode_encoder_inst0(
	.clk(clk),
	// .pps(pps_in), // Original connection
    .pps(bcode_encoder_pps_muxed), // Corrected connection for DFT
	.rst_n(rst_n),
	.clk_reload_n(clk_reload_n), // Assuming clk_reload_n is NOT used as a clock internally
	.utc_cnv_end(utc_time_ok),
	.sec_bin(sec_of_minute),
	.min_bin(minute_of_hour),
	.hour_bin(hour_of_day),
	.day_bin(day_of_year),
	.year_bin(year),
	.tai_sec(tai_sec_in),
	.time_zone(time_zone_in),
	.dst_ing(dst_ing_in),
	.dst_eng(dst_eng_in),
	.leap_occur(leap_occur_in),
	.leap_direct(leap_direct_in[0]), // Assuming only bit 0 is needed
	.time_quality(time_quality_in),
	.sec_of_day(sec_of_day),
	.bcode_trans(bcode_out)
);
endmodule