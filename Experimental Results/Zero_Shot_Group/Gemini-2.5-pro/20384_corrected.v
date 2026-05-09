module tdm_to_i2s_converter(
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

	// Removed: assign rst = rst_i; -> Use rst_i directly

	reg s_fsync;
	// Synchronize fsync_i to sck_i domain
	always @ (posedge sck_i or posedge rst_i) begin // Use rst_i
		if(rst_i) begin
			s_fsync <= 1'b0;
		end
		else begin
			s_fsync <= fsync_i;
		end
	end

	reg [8:0] bit_cnt;
	// Counter logic, sensitive to negedge sck_i for timing relative to data capture
	always @ (negedge sck_i or posedge rst_i) begin // Use rst_i
		if(rst_i) begin
			// Consider resetting to 0 or a known starting state based on protocol
			bit_cnt <= 9'b111111111; // Original reset state kept, may need adjustment
		end
		else begin
			if(s_fsync) begin // Check synchronized fsync
				// Logic assumes fsync marks a specific point in the TDM frame
				bit_cnt <= {~bit_cnt[8], 8'b0}; // Protocol-specific counter reset/toggle
			end
			else begin
				bit_cnt <= bit_cnt + 1'b1; // Increment bit counter
			end
		end
	end

	// Double buffer registers for incoming TDM data (4 channels x 64 bits)
	reg [63:0] dat_0_a, dat_0_b;
	reg [63:0] dat_1_a, dat_1_b;
	reg [63:0] dat_2_a, dat_2_b;
	reg [63:0] dat_3_a, dat_3_b;

	// Capture incoming TDM data on posedge sck_i
	always @ (posedge sck_i or posedge rst_i) begin // Use rst_i
		if(rst_i) begin
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
			// Use bit_cnt[8] to select between buffer A and B for ping-pong operation
			if(bit_cnt[8]) begin // Capture into buffer A
				case(bit_cnt[7:6]) // Select channel based on counter bits
					2'b00: dat_0_a[63-bit_cnt[5:0]] <= dat_i; // Index MSB first using lower 6 bits
					2'b01: dat_1_a[63-bit_cnt[5:0]] <= dat_i;
					2'b10: dat_2_a[63-bit_cnt[5:0]] <= dat_i;
					2'b11: dat_3_a[63-bit_cnt[5:0]] <= dat_i;
					default: ; // Added for completeness, though case covers all values
				endcase
			end
			else begin // Capture into buffer B
				case(bit_cnt[7:6]) // Select channel based on counter bits
					2'b00: dat_0_b[63-bit_cnt[5:0]] <= dat_i; // Index MSB first using lower 6 bits
					2'b01: dat_1_b[63-bit_cnt[5:0]] <= dat_i;
					2'b10: dat_2_b[63-bit_cnt[5:0]] <= dat_i;
					2'b11: dat_3_b[63-bit_cnt[5:0]] <= dat_i;
					default: ; // Added for completeness
				endcase
			end
		end
	end

	// I2S Master Clock Output
	assign mck_o = sck_i; // MCK is directly passed from SCK input

	// I2S Bit Clock Output
	// Corrected: BCK should typically be the serial clock rate. Assuming it matches sck_i here.
	assign bck_o = sck_i;

	// I2S Left/Right Clock Output
	// LRCK derived from counter bit - this depends heavily on the TDM frame structure
	// and how bit_cnt relates to samples per channel. Kept as original.
	assign lrck_o = bit_cnt[7];

	// I2S Data Output (4 parallel bits, one per channel)
	// Data changes on falling edge of bck_o (which is now sck_i)
	// Corrected sensitivity list and indexing
	always @ (negedge sck_i or posedge rst_i) begin // Use negedge sck_i (as bck_o = sck_i) and rst_i
		if(rst_i) begin
			dat_o <= 4'b0;
		end
		else begin
			// Select buffer based on bit_cnt[8] (opposite of the buffer being filled)
			if(bit_cnt[8]) begin // Output from buffer B (while A is filling)
				// Corrected Indexing: Use bit_cnt[5:0] consistent with input capture, MSB first
				dat_o <= {dat_3_b[63-bit_cnt[5:0]], dat_2_b[63-bit_cnt[5:0]], dat_1_b[63-bit_cnt[5:0]], dat_0_b[63-bit_cnt[5:0]]};
			end
			else begin // Output from buffer A (while B is filling)
				// Corrected Indexing: Use bit_cnt[5:0] consistent with input capture, MSB first
				dat_o <= {dat_3_a[63-bit_cnt[5:0]], dat_2_a[63-bit_cnt[5:0]], dat_1_a[63-bit_cnt[5:0]], dat_0_a[63-bit_cnt[5:0]]};
			end
		end
	end

endmodule