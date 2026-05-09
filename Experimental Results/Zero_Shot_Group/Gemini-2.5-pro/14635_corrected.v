`default_nettype none
`timescale 1 ps / 1 ps

module trainsim
(
	input wire        rst,
	input wire        clk,
	input wire [4:0]  sensor,
	output reg [2:0]  sw,
	output reg [1:0]  dira,
	output reg [1:0]  dirb
);
	localparam ABOUT = 3'd0;
	localparam AIN   = 3'd1;
	localparam BIN   = 3'd2;
	localparam ASTOP = 3'd3;
	localparam BSTOP = 3'd4;

	reg [2:0]  state;

	// Wires for sensor combinations
	wire [1:0] s12 = {sensor[0], sensor[1]};
	wire [1:0] s13 = {sensor[0], sensor[2]};
	wire [1:0] s24 = {sensor[1], sensor[3]};

	// Combined state transition and output logic (Moore machine)
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			state <= ABOUT;
			// Reset outputs to match the ABOUT state
			sw <= 3'b000; // sw[2]=0, sw[1]=0, sw[0]=0
			dira <= 2'b01;
			dirb <= 2'b01;
		end else begin
			// Default assignments (hold previous value unless changed by state logic)
            // This is implicitly handled by sequential logic, but explicit can be clearer
            // state <= state; // Implicit hold
            // sw <= sw;       // Implicit hold
            // dira <= dira;   // Implicit hold
            // dirb <= dirb;   // Implicit hold

			// State transition logic based on current state and inputs
			case (state)
				ABOUT:
					case (s12)
						2'b00:    state <= ABOUT;
						2'b01:    state <= BIN;
						2'b10:    state <= AIN;
						2'b11:    state <= AIN; // Assuming '11' means AIN
						default:  state <= ABOUT; // Should not happen for 2'b input
					endcase
				AIN:
					case (s24)
						2'b00:    state <= AIN;
						2'b01:    state <= ABOUT;
						2'b10:    state <= BSTOP;
						2'b11:    state <= ABOUT; // Assuming '11' means ABOUT
						default:  state <= ABOUT; // Should not happen for 2'b input
					endcase
				BIN:
					case (s13)
						2'b00:    state <= BIN;
						2'b01:    state <= ABOUT;
						2'b10:    state <= ASTOP;
						2'b11:    state <= ABOUT; // Assuming '11' means ABOUT
						default:  state <= ABOUT; // Should not happen for 2'b input
					endcase
				ASTOP:
					if (sensor[2])
						state <= AIN;
					else
						state <= ASTOP;
				BSTOP:
					if (sensor[3])
						state <= BIN;
					else
						state <= BSTOP;
				default:
					state <= ABOUT;
			endcase

			// Output logic based on the *current* state before the transition
            // Note: sw[2] is effectively always 0 based on original code intent.
			case (state)
				ABOUT: begin
					sw <= 3'b000; // sw[2]=0, sw[1]=0, sw[0]=0
					dira <= 2'b01;
					dirb <= 2'b01;
				end
				AIN: begin
					sw <= 3'b000; // sw[2]=0, sw[1]=0, sw[0]=0
					dira <= 2'b01;
					dirb <= 2'b01;
				end
				BIN: begin
					sw <= 3'b011; // sw[2]=0, sw[1]=1, sw[0]=1
					dira <= 2'b01;
					dirb <= 2'b01;
				end
				ASTOP: begin
					sw <= 3'b011; // sw[2]=0, sw[1]=1, sw[0]=1
					dira <= 2'b00;
					dirb <= 2'b01;
				end
				BSTOP: begin
					sw <= 3'b000; // sw[2]=0, sw[1]=0, sw[0]=0
					dira <= 2'b01;
					dirb <= 2'b00;
				end
				default: begin // Safety default for outputs if state becomes invalid
					sw <= 3'b000;
					dira <= 2'b00;
					dirb <= 2'b00;
				end
			endcase
		end // else: !if(rst)
	end // always @ (posedge clk or posedge rst)
endmodule

module LFSR8_11D
(
	input wire       clk,
	output reg [7:0] LFSR = 8'd255 // Initial value set
);
	// Feedback logic (non-standard LFSR)
	// feedback = MSB ^ (all lower bits zero)
	wire feedback = LFSR[7] ^ (LFSR[6:0] == 7'b0000000);

	// Register update logic (Galois-like structure with non-standard taps)
	always @(posedge clk) begin
		LFSR[0] <= feedback;
		LFSR[1] <= LFSR[0];
		LFSR[2] <= LFSR[1] ^ feedback; // Tap?
		LFSR[3] <= LFSR[2] ^ feedback; // Tap?
		LFSR[4] <= LFSR[3] ^ feedback; // Tap?
		LFSR[5] <= LFSR[4];
		LFSR[6] <= LFSR[5];
		LFSR[7] <= LFSR[6];
	end
endmodule

`default_nettype wire // Restore default net type if needed downstream