module dyn_pll_ctrl # (parameter SPEED_MHZ = 25, parameter SPEED_LIMIT = 100, parameter SPEED_MIN = 25, parameter OSC_MHZ = 100)
	(clk,
	clk_valid,
	speed_in,
	start,
	progclk,
	progdata,
	progen,
	reset,
	locked,
	status);

	input clk;				// NB Assumed to be 12.5MHz uart_clk
	input clk_valid;		// Drive from LOCKED output of first dcm (ie uart_clk valid)
	input [7:0] speed_in;
	input start;
	output reg progclk = 0;
	output reg progdata = 0;
	output reg progen = 0;
	output reg reset = 0;
	input locked;
	input [2:1] status; // NB: This input is declared but not used in the logic.

	// NB spec says to use (dval-1) and (mval-1), but I don't think we need to be that accurate
	//    and this saves an adder. Feel free to amend it.
	reg [23:0] watchdog = 0;
	reg [7:0] state = 0;
	reg [7:0] dval_shift_reg; // Temporary register for shifting D value
	reg [7:0] mval_shift_reg; // Temporary register for shifting M value
	reg start_d1 = 0;

	// Initialize shift registers from parameters (or input speed)
	initial begin
		dval_shift_reg = OSC_MHZ;
		mval_shift_reg = SPEED_MHZ;
	end

	always @ (posedge clk)
	begin
		// Default assignments
		reset <= 1'b0;
		progclk <= ~progclk; // Generate programming clock (clk/2)
		start_d1 <= start;

		// Watchdog logic
		if (locked) begin
			watchdog <= 0;
		end else begin
			watchdog <= watchdog + 1'b1;
			if (watchdog[23]) begin // Approx 670mS at 12.5MHz
				watchdog <= 0;
				reset <= 1'b1; // Assert reset for one cycle
			end
		end

		// Main state machine logic - only run when input clock is valid
		if (~clk_valid) begin
			progen <= 0;
			progdata <= 0;
			state <= 0;
			// Consider resetting watchdog here as well if desired
			// watchdog <= 0;
		end else begin

			// Start condition detection (on positive edge of progclk)
			if ((start || start_d1) && state == 0 && speed_in >= SPEED_MIN && speed_in <= SPEED_LIMIT && progclk == 1) begin
				progen <= 0; // Ensure progen is low before starting
				progdata <= 0;
				mval_shift_reg <= speed_in; // Load new M value
				dval_shift_reg <= OSC_MHZ;  // Load D value (parameter)
				state <= 1;                 // Start state machine
			end

			// State transition and actions
			// Increment state only if not in idle (state 0)
			if (state != 0) begin
				state <= state + 1'd1; // Increment state counter

				// State machine actions (triggered on specific state counts)
				// Using 'case' for clarity, actions occur based on the *next* state value
				case (state)
					// Send D command (01) + D value (8 bits)
					2: begin // Start D command
						progen <= 1;
						progdata <= 1; // D command bit 1
					end
					4: begin
						progdata <= 0; // D command bit 0
					end
					// Shift out D value LSB first (states 6, 8, ..., 20)
					6,8,10,12,14,16,18,20: begin
						progdata <= dval_shift_reg[0];       // Output LSB
						dval_shift_reg <= dval_shift_reg >> 1; // Right shift D value
					end
					22: begin // End D command phase
						progen <= 0;
						progdata <= 0;
					end

					// Send M command (10) + M value (8 bits)
					32: begin // Start M command
						progen <= 1;
						progdata <= 1; // M command bit 1
					end
                    34: begin // M command bit 0 (State 34 for correct timing after state 32)
                        progdata <= 0;
                    end
					// Shift out M value LSB first (states 36, 38, ..., 50)
					36,38,40,42,44,46,48,50: begin
						progdata <= mval_shift_reg[0];       // Output LSB
						mval_shift_reg <= mval_shift_reg >> 1; // Right shift M value
					end
					52: begin // End M command phase
						progen <= 0;
						progdata <= 0;
					end

					// Send GO command (11) - NB 1 clock cycle for command bits
					62: begin // Start GO command
						progen <= 1;
						progdata <= 1; // GO command bit 1 (assert progen)
					end
                    64: begin // GO command bit 0
                        progdata <= 1; // GO command bit 0 (keep progen asserted)
                        // progen remains 1 from state 62
                    end
					66: begin // End GO command phase
						progen <= 0;
						progdata <= 0; // Deassert progen
					end

					// Wait state / Return to idle
					// State 254 provides a long delay before potentially restarting
					254: begin
						state <= 0; // Return to idle state
					end
					default: begin
						// No action in intermediate or unused states
					end
				endcase
            end // end if(state != 0)
		end // end else (if ~clk_valid)
	end // end always @ (posedge clk)

endmodule