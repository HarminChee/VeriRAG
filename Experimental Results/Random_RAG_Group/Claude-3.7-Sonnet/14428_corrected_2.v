module bcode_encoder(
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
	input	[63: 0] dst_eng,
	input	[63: 0] leap_occur,
	input			leap_direct,
	input	[3 : 0] time_quality,
	input	[16: 0]	sec_of_day,
	input           test_i,
	output			bcode_trans
);

// ... existing code ...

wire clk_100hz_mux;
wire clk_1khz_mux;
wire pps_forward_mux;
wire dft_clk;
reg [1:0] pps_catch_100hz;
reg [1:0] pps_catch_1khz;
reg [3:0] rz_encode_timer;
reg bcode_gen;
reg [2:0] itr_cnv_state;
reg [2:0] itr_next_state;
reg [63:0] shifter;
reg [6:0] bit_count;
reg [3:0] rz_code;

parameter ITR_WAIT_PPS = 3'b000;
parameter CODE_P = 4'b0001;

assign dft_clk = test_i ? clk : 1'b0;
assign clk_100hz_mux = test_i ? dft_clk : clk_100hz;
assign clk_1khz_mux = test_i ? dft_clk : clk_1khz;
assign pps_forward_mux = test_i ? dft_clk : pps_forward;

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		pps_catch_100hz <= 2'b11;
	end
	else begin
		pps_catch_100hz[0] <= pps_forward_mux;
		pps_catch_100hz[1] <= pps_catch_100hz[0];
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		itr_cnv_state <= ITR_WAIT_PPS;
	end
	else begin
		itr_cnv_state <= itr_next_state;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		shifter <= 0;
		bit_count <= 0;
		rz_code <= CODE_P;
	end
	else begin
		case (itr_cnv_state)
		// ... existing code ...
		endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n) begin
		pps_catch_1khz <= 2'b11;
	end
	else begin
		pps_catch_1khz[0] <= pps_forward_mux;
		pps_catch_1khz[1] <= pps_catch_1khz[0];
	end
end

always @(posedge clk or negedge rst_n)
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

// ... existing code ...

endmodule