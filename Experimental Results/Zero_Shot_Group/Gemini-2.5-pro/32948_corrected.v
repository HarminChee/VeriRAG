`timescale 1ns / 1ps

module jtag_comm (
	input wire rx_hash_clk,
	input wire rx_golden_nonce_found,
	input wire [59:0] rx_golden_nonce,
	output reg tx_new_work,
	output reg [55:0] tx_fixed_data = 56'd0,
	output reg [159:0] tx_target_hash = 160'd0,
	output reg [59:0] tx_start_nonce = 60'd0
);
	localparam JOB_WIDTH = 160 + 56 + 60; // target_hash + fixed_data + start_nonce
	localparam DR_WIDTH = 38;

	reg [JOB_WIDTH-1:0] current_job = {JOB_WIDTH{1'b0}};
	reg [159:0] target_hash = 160'd0;
	reg [55:0]  fixed_data = 56'd0;
	reg [59:0]  start_nonce = 60'd0;
	reg         new_work_flag = 1'b0;

	wire jt_capture;
	wire jt_drck; // Note: Typically unused with BSCAN primitive, use TCK
	wire jt_reset;
	wire jt_sel;
	wire jt_shift;
	wire jt_tck;
	wire jt_tdi;
	wire jt_tdo;
	wire jt_update;

	// Note: Ensure BSCAN_SPARTAN6 primitive is available in your environment/target FPGA
	// Check documentation for correct instantiation and port connections if not Spartan-6
	BSCAN_SPARTAN6 # (
		.JTAG_CHAIN(1)
	) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),       // Consider if DRCK is needed or if TCK drives logic directly
		.RESET(jt_reset),
		.RUNTEST(),         // Unconnected output
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck),
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(),             // Unconnected output
		.UPDATE(jt_update)
	);

	reg [3:0]  addr = 4'hF;
	reg [DR_WIDTH-1:0] dr;
	reg checksum;
	wire checksum_valid = ~checksum; // Assumes odd parity check, init to 1, final should be 0

	wire jtag_we = dr[DR_WIDTH-2]; // Bit 36
	wire [3:0] jtag_addr = dr[DR_WIDTH-3:32]; // Bits 35:32

	reg [60:0] golden_nonce_buf;
	reg [60:0] golden_nonce;

	// Synchronize golden nonce inputs to rx_hash_clk domain
	always @ (posedge rx_hash_clk) begin
		golden_nonce_buf <= {rx_golden_nonce_found, rx_golden_nonce};
		golden_nonce     <= golden_nonce_buf;
	end

	// Assign TDO based on the least significant bit of the shift register
	assign jt_tdo = dr[0];

	// JTAG state machine logic (operates on jt_tck)
	always @ (posedge jt_tck or posedge jt_reset) begin
		if (jt_reset) begin
			dr <= {DR_WIDTH{1'b0}};
			addr <= 4'hF;
			target_hash <= 160'd0;
			fixed_data <= 56'd0;
			start_nonce <= 60'd0;
			checksum <= 1'b0; // Initialize checksum on reset
			current_job <= {JOB_WIDTH{1'b0}};
		end
		else begin
			if (jt_capture) begin
				checksum <= 1'b1; // Initialize parity check for new capture
				dr[DR_WIDTH-1:32] <= 6'd0; // Clear control bits initially
				// Load data into DR based on current address for TDI->TDO path
				case (addr)
					4'h0: dr[31:0] <= 32'h01000100; // Example ID or version
					4'h1: dr[31:0] <= target_hash[31:0];
					4'h2: dr[31:0] <= target_hash[63:32];
					4'h3: dr[31:0] <= target_hash[95:64];
					4'h4: dr[31:0] <= target_hash[127:96];
					4'h5: dr[31:0] <= target_hash[159:128];
					4'h6: dr[31:0] <= fixed_data[31:0];
					4'h7: dr[31:0] <= {8'd0, fixed_data[55:32]}; // Pad to 32 bits
					4'h8: dr[31:0] <= start_nonce[31:0];
					4'h9: dr[31:0] <= {4'd0, start_nonce[59:32]}; // Pad to 32 bits
					4'hA: dr[31:0] <= 32'hFFFFFFFF; // Test Read?
					4'hB: dr[31:0] <= 32'hFFFFFFFF; // Test Read?
					4'hC: dr[31:0] <= 32'h55555555; // Test Read?
					4'hD: dr[31:0] <= golden_nonce[31:0];
					4'hE: dr[31:0] <= {3'd0, golden_nonce[60:32]}; // Pad to 32 bits
					default: dr[31:0] <= 32'hFFFFFFFF; // Default/Invalid address read
				endcase
			end
			else if (jt_shift) begin
				dr <= {jt_tdi, dr[DR_WIDTH-1:1]}; // Shift data in from TDI
				checksum <= checksum ^ jt_tdi; // Update checksum (odd parity)
			end
			else if (jt_update) begin
			    // Only process update if checksum is valid
				if (checksum_valid) begin
				    // Update the address register for the *next* capture phase
					addr <= jtag_addr;
					// Write to internal registers if write enable is asserted
					if (jtag_we) begin
						case (jtag_addr)
							4'h1: target_hash[31:0]   <= dr[31:0];
							4'h2: target_hash[63:32]  <= dr[31:0];
							4'h3: target_hash[95:64]  <= dr[31:0];
							4'h4: target_hash[127:96] <= dr[31:0];
							4'h5: target_hash[159:128]<= dr[31:0];
							4'h6: fixed_data[31:0]    <= dr[31:0];
							4'h7: fixed_data[55:32]   <= dr[23:0]; // Use lower 24 bits
							4'h8: start_nonce[31:0]   <= dr[31:0];
							4'h9: start_nonce[59:32]  <= dr[27:0]; // Use lower 28 bits
							// Default: No action for other addresses on write
						endcase

						// If the last piece of the job (start_nonce upper part) was written,
						// assemble the complete job and toggle the flag
						if (jtag_addr == 4'h9) begin
						    // Combine the newly written upper bits with the existing lower bits
						    reg [59:0] updated_start_nonce;
						    updated_start_nonce = {dr[27:0], start_nonce[31:0]};
							// Assemble the full job using the most up-to-date register values
							current_job <= {updated_start_nonce, fixed_data, target_hash};
							new_work_flag <= ~new_work_flag; // Toggle flag to signal new job
						end
					end
				end
				// Optionally reset checksum here if required after every update regardless of validity
				// checksum <= 1'b0;
			end
		end
	end

	// Synchronization and output logic (operates on rx_hash_clk)
	reg [JOB_WIDTH-1:0] tx_buffer = {JOB_WIDTH{1'b0}};
	reg [2:0] tx_work_flag_sync = 3'b0;

	always @ (posedge rx_hash_clk) begin
		// Buffer the job data assembled in the JTAG clock domain
		tx_buffer <= current_job;

		// Assign buffered job data to outputs
		// Order: {tx_start_nonce[59:0], tx_fixed_data[55:0], tx_target_hash[159:0]}
		tx_start_nonce <= tx_buffer[JOB_WIDTH-1 -: 60]; // Bits [275:216]
		tx_fixed_data  <= tx_buffer[159+56-1 -: 56];   // Bits [215:160]
		tx_target_hash <= tx_buffer[159:0];           // Bits [159:0]

		// Synchronize the new work flag from JTAG domain to rx_hash_clk domain
		tx_work_flag_sync <= {tx_work_flag_sync[1:0], new_work_flag};

		// Generate a single-cycle pulse on tx_new_work when the flag changes
		tx_new_work <= tx_work_flag_sync[2] ^ tx_work_flag_sync[1];
	end

endmodule