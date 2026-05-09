module tdm_to_i2s_converter_corrected_ffc(
	rst_i, 
	sck_i, 
	fsync_i, 
	dat_i, 
	mck_o, 
	bck_o, 
	lrck_o, 
	dat_o 
);
	input rst_i;
	input sck_i;
	input fsync_i;
	input dat_i;
	output mck_o;
	output bck_o;
	output lrck_o;
	output reg [3:0] dat_o;

	assign rst = rst_i;

	reg s_fsync;
	always @ (posedge sck_i or posedge rst) begin
		if(rst) begin
			s_fsync <= 1'b0;
		end
		else begin
			s_fsync <= fsync_i;
		end
	end

	reg [8:0] bit_cnt;
	always @ (negedge sck_i or posedge rst) begin
		if(rst) begin
			bit_cnt <= 9'b111111111;
		end
		else begin
			if(s_fsync) begin
				bit_cnt <= {~bit_cnt[8], 8'b0};
			end
			else begin
				bit_cnt <= bit_cnt + 1'b1;
			end
		end
	end

	reg [63:0] dat_0_a, dat_0_b;
	reg [63:0] dat_1_a, dat_1_b;
	reg [63:0] dat_2_a, dat_2_b;
	reg [63:0] dat_3_a, dat_3_b;

	always @ (posedge sck_i or posedge rst) begin
		if(rst) begin
			dat_0_a <= 64'b0;
			dat_1_a <= 64'b0;
			dat_2_a <= 64'b0;
			dat_3_a <= 64'b0;
			dat_0_b <= 64'b0;
			dat_1_b <= 64'b0;
			dat_2_b <= 64'b0;
			dat_3_b <= 64'b0;
		end
		else begin
			if(bit_cnt[8]) begin
				case(bit_cnt[7:6]) 
					2'b00: dat_0_a[63 - bit_cnt[5:0]] <= dat_i;
					2'b01: dat_1_a[63 - bit_cnt[5:0]] <= dat_i;
					2'b10: dat_2_a[63 - bit_cnt[5:0]] <= dat_i;
					2'b11: dat_3_a[63 - bit_cnt[5:0]] <= dat_i;
				endcase
			end
			else begin
				case(bit_cnt[7:6]) 
					2'b00: dat_0_b[63 - bit_cnt[5:0]] <= dat_i;
					2'b01: dat_1_b[63 - bit_cnt[5:0]] <= dat_i;
					2'b10: dat_2_b[63 - bit_cnt[5:0]] <= dat_i;
					2'b11: dat_3_b[63 - bit_cnt[5:0]] <= dat_i;
				endcase
			end
		end
	end

	assign mck_o = sck_i;
	assign bck_o = bit_cnt[1];
	assign lrck_o = bit_cnt[7];

	always @ (negedge sck_i or posedge rst) begin
		if(rst) begin
			dat_o <= 4'b0;
		end
		else begin
			if(bit_cnt[8]) begin
				dat_o <= {dat_3_b[63-bit_cnt[7:2]], dat_2_b[63-bit_cnt[7:2]], dat_1_b[63-bit_cnt[7:2]], dat_0_b[63-bit_cnt[7:2]]};
			end
			else begin
				dat_o <= {dat_3_a[63-bit_cnt[7:2]], dat_2_a[63-bit_cnt[7:2]], dat_1_a[63-bit_cnt[7:2]], dat_0_a[63-bit_cnt[7:2]]};
			end
		end
	end

endmodule