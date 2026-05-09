module jtag_comm (
	input wire test_mode, // Added for DFT
	input wire test_clk, // Added for DFT
	input wire test_reset, // Added for DFT (active high)
	input rx_hash_clk,
	input rx_golden_nonce_found,
	input [59:0] rx_golden_nonce,
	output reg tx_new_work,
	output reg [55:0] tx_fixed_data = 56'd0,
	output reg [159:0] tx_target_hash = 160'd0,
	output reg [59:0] tx_start_nonce = 60'd0
);
	reg [56+160+60-1:0] current_job = 276'd0;
	reg [55:0] fixed_data = 56'd0;
	reg [159:0] target_hash = 160'd0;
	reg [59:0] start_nonce = 60'd0;
	reg new_work_flag = 1'b0;
	wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
	wire jt_tdo;
	BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),
		.RESET(jt_reset),
		.RUNTEST(),
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck), // This is the clock output from BSCAN, not the primary TCK input to chip
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(),
		.UPDATE(jt_update)
	);
	reg [3:0] addr = 4'hF;
	reg [37:0] dr;
	reg checksum;
	wire checksum_valid = ~checksum;
	wire jtag_we = dr[36];
	wire [3:0] jtag_addr = dr[35:32];
	reg [60:0] golden_nonce_buf, golden_nonce;

	// DFT Muxing for clock and reset of the JTAG-controlled FFs
	wire dft_clk;
	wire dft_jt_reset; // Muxed version of jt_reset

	assign dft_clk = test_mode ? test_clk : jt_tck;
	assign dft_jt_reset = test_mode ? test_reset : jt_reset;


	always @ (posedge rx_hash_clk)
	begin
		golden_nonce_buf <= {rx_golden_nonce_found, rx_golden_nonce};
		golden_nonce <= golden_nonce_buf;
	end

	assign jt_tdo = dr[0];

	// Modified always block using DFT muxed clock and reset
	always @ (posedge dft_clk or posedge dft_jt_reset)
	begin
		if (dft_jt_reset == 1'b1) // Use muxed reset signal
		begin
			// Reset all registers controlled by this clock domain during test reset
			dr <= 38'd0;
			checksum <= 1'b0; // Use a defined reset state
			addr <= 4'hF; // Use a defined reset state
			target_hash <= 160'd0;
			fixed_data <= 56'd0;
			start_nonce <= 60'd0;
			current_job <= 276'd0;
			new_work_flag <= 1'b0;
		end
		// Functional logic (Note: jt_capture, jt_shift, jt_update are synchronous to jt_tck)
		// Behavior in test_mode might differ if test_clk is asynchronous to jt_tck
		else if (jt_capture == 1'b1)
		begin
			checksum <= 1'b1;
			dr[37:32] <= 6'd0;
			// addr <= 4'hF; // addr is updated in update state, keep current value for capture
			case (addr)
				4'h0: dr[31:0] <= 32'h01000100;
				4'h1: dr[31:0] <= target_hash[31:0];
				4'h2: dr[31:0] <= target_hash[63:32];
				4'h3: dr[31:0] <= target_hash[95:64];
				4'h4: dr[31:0] <= target_hash[127:96];
				4'h5: dr[31:0] <= target_hash[159:128];
				4'h6: dr[31:0] <= fixed_data[31:0];
				4'h7: dr[31:0] <= fixed_data[55:32];
				4'h8: dr[31:0] <= start_nonce[31:0];
				4'h9: dr[31:0] <= start_nonce[59:32];
				4'hA: dr[31:0] <= 32'hFFFFFFFF;
				4'hB: dr[31:0] <= 32'hFFFFFFFF;
				4'hC: dr[31:0] <= 32'h55555555;
				4'hD: dr[31:0] <= golden_nonce[31:0];
				4'hE: dr[31:0] <= golden_nonce[60:32];
				4'hF: dr[31:0] <= 32'hFFFFFFFF;
			endcase
		end
		else if (jt_shift == 1'b1)
		begin
			dr <= {jt_tdi, dr[37:1]};
			checksum <= checksum ^ jt_tdi;
		end
		else if (jt_update & checksum_valid) // Only update if checksum is valid
		begin
			addr <= jtag_addr; // Update address register
			if (jtag_we) // Check write enable bit
			begin
				case (jtag_addr) // Use the address captured during shift
					4'h1: target_hash[31:0] <= dr[31:0];
					4'h2: target_hash[63:32] <= dr[31:0];
					4'h3: target_hash[95:64] <= dr[31:0];
					4'h4: target_hash[127:96] <= dr[31:0];
					4'h5: target_hash[159:128] <= dr[31:0];
					4'h6: fixed_data[31:0] <= dr[31:0];
					4'h7: fixed_data[55:32] <= dr[23:0]; // Corrected width
					4'h8: start_nonce[31:0] <= dr[31:0];
					4'h9: start_nonce[59:32] <= dr[27:0]; // Corrected width
				endcase
			end
			// Update current_job and new_work_flag only when writing the last piece (addr 9)
			if (jtag_we && jtag_addr == 4'h9)
			begin
				// Construct current_job using the potentially updated values
				current_job <= {dr[27:0], start_nonce[31:0], fixed_data[55:0], target_hash[159:0]};
				new_work_flag <= ~new_work_flag;
			end
		end
	end

	reg [275:0] tx_buffer = 276'd0;
	reg [2:0] tx_work_flag = 3'b0;
	always @ (posedge rx_hash_clk) // This block uses primary input clock rx_hash_clk - OK
	begin
		tx_buffer <= current_job;
		{tx_start_nonce, tx_fixed_data, tx_target_hash} <= tx_buffer;
		tx_work_flag <= {tx_work_flag[1:0], new_work_flag};
		tx_new_work <= tx_work_flag[2] ^ tx_work_flag[1]; // Edge detection
	end
endmodule