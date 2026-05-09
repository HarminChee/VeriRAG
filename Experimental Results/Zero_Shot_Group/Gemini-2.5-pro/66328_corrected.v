/*!
   btcminer -- BTCMiner for ZTEX USB-FPGA Modules: HDL code for ZTEX USB-FPGA Module 1.15b (one double hash pipe)
   Copyright (C) 2011 ZTEX GmbH
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

`define IDX(x) (((x)+1)*(32)-1):((x)*(32))

// Assuming sha256_pipe129 module exists with the specified interface
// module sha256_pipe129 (
//     input clk,
//     input [255:0] state,
//     input [511:0] data,
//     output [255:0] hash
// );
//     // Internal implementation of the SHA-256 pipeline
// endmodule

module miner130 (
    input clk,
    input reset,
    input [255:0] midstate,
    input [95:0] data,
    output reg [31:0] golden_nonce,
    output reg [31:0] nonce2,
    output reg [31:0] hash2
);

	parameter NONCE_OFFS = 32'd0;
	parameter NONCE_INCR = 32'd1;

	reg [31:0] nonce;
	wire [255:0] hash;

	reg [7:0] cnt;
	reg feedback;
	reg is_golden_nonce;
	reg feedback_b1, feedback_b2, feedback_b3, feedback_b4, feedback_b5, feedback_b6;
	// Removed reset_b1, reset_b2 as direct reset is used

	reg [255:0] state_buf;
	reg [511:0] data_buf;

	// Instantiation of the SHA-256 pipeline module
	sha256_pipe129 p (
		.clk(clk),
		.state(state_buf),
		.data(data_buf),
		.hash(hash)
	);

	always @ (posedge clk)
	begin
		if (reset) // Synchronous reset for all registers
		begin
		    cnt <= 8'd0;
		    feedback <= 1'b0; // Start in non-feedback mode
		    nonce <= NONCE_OFFS;
		    golden_nonce <= 32'd0;
		    nonce2 <= NONCE_OFFS; // Reset to initial nonce value
		    hash2 <= 32'd0;
		    is_golden_nonce <= 1'b0;
		    feedback_b1 <= 1'b0;
		    feedback_b2 <= 1'b0;
		    feedback_b3 <= 1'b0;
		    feedback_b4 <= 1'b0;
		    feedback_b5 <= 1'b0;
		    feedback_b6 <= 1'b0;
		    state_buf <= midstate; // Initial state for first round
		    // Initial data for first round (assuming 'data' input is valid or ignored during reset)
		    data_buf <= {384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, NONCE_OFFS, data};
		end else begin
		    // Capture previous feedback state for pipelined control
		    feedback_b1 <= feedback;
		    feedback_b2 <= feedback;
		    feedback_b3 <= feedback;
		    feedback_b4 <= feedback;
		    feedback_b5 <= feedback;
		    feedback_b6 <= feedback;

		    // Counter and feedback toggle logic
		    if ( cnt == 8'd129 ) // Runs for 130 cycles (0 to 129)
		    begin
		        feedback <= ~feedback;
		        cnt <= 8'd0;
		    end else begin
		        cnt <= cnt + 8'd1;
		    end

		    // Determine SHA pipe inputs based on previous feedback state
		    if ( feedback_b1 ) // Prepare for second round (feedback path)
		    begin
		        data_buf <= { 256'h0000010000000000000000000000000000000000000000000000000080000000, // Padding and length (256 bits)
		                      hash[`IDX(7)] + midstate[`IDX(7)], // Check if this addition is intended vs. just hash
		                      hash[`IDX(6)] + midstate[`IDX(6)],
		                      hash[`IDX(5)] + midstate[`IDX(5)],
		                      hash[`IDX(4)] + midstate[`IDX(4)],
		                      hash[`IDX(3)] + midstate[`IDX(3)],
		                      hash[`IDX(2)] + midstate[`IDX(2)],
		                      hash[`IDX(1)] + midstate[`IDX(1)],
		                      hash[`IDX(0)] + midstate[`IDX(0)]
		                    };
		    end else begin // Prepare for first round (non-feedback path)
		        // Padding (80...), length (0x280 = 640 bits), current nonce, and input data
		        data_buf <= {384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, nonce, data};
		    end

		    if ( feedback_b2 ) // Set state for second round
		    begin
		        // Standard SHA-256 initial hash value H(0)
		        state_buf <= 256'h6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19;
		    end else begin // Set state for first round
		        state_buf <= midstate;
		    end

	        // Increment nonce if not in previous feedback state
	        if ( !feedback_b3 )
		    begin
		        nonce <= nonce + NONCE_INCR;
		    end

		    // Update golden_nonce if a golden nonce was found in the previous cycle
	        if ( is_golden_nonce ) // is_golden_nonce is from previous cycle's hash check
	    	begin
		        golden_nonce <= nonce2; // nonce2 captured the corresponding nonce from previous cycle
		    end

		    // Update outputs based on previous feedback state and current hash result
		    if ( !feedback_b4 )
		    begin
		        hash2 <= hash[255:224]; // Capture top 32 bits of current hash result
		    end

		    if ( !feedback_b5 )
		    begin
		        nonce2 <= nonce; // Capture current nonce (associated with current hash result)
		    end

		    // Check if current hash result is the golden nonce target
		    if ( !feedback_b6 )
		    begin
		        is_golden_nonce <= (hash[255:224] == 32'ha41f32e7); // Specific target hash
		    end

		end // End of non-reset logic
	end // End of always @ (posedge clk)

endmodule