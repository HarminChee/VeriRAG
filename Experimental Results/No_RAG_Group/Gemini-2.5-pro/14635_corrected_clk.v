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
	localparam ABOUT = 0;
	localparam AIN   = 1;
	localparam BIN   = 2;
	localparam ASTOP = 3;
	localparam BSTOP = 4;
	reg [2:0]  state;
	reg [2:0]  next_state; // Intermediate signal for state logic

	wire [1:0] s12 = {sensor[0], sensor[1]};
	wire [1:0] s13 = {sensor[0], sensor[2]};
	wire [1:0] s24 = {sensor[1], sensor[3]};

	// Sequential logic for sw[2] - Use non-blocking assignment
	always @ (posedge clk) begin
		sw[2] <= 1'b0; // Assuming it should always be 0 based on original code
	end

	// Sequential logic for state register with synchronous reset
	always @ (posedge clk) begin
		if (rst) begin
			state <= ABOUT;
		end else begin
			state <= next_state;
		end
	end

	// Combinational logic for next_state calculation
	always @ (*) begin // Use implicit sensitivity list
		// Default assignment to avoid latches
		next_state = state;
		case (state)
			ABOUT:
				case (s12)
					'b00:    next_state = ABOUT;
					'b01:    next_state = BIN;
					'b10:    next_state = AIN;
					'b11:    next_state = AIN;
					default: next_state = ABOUT;
				endcase
			AIN:
				case (s24)
					'b00:    next_state = AIN;
					'b01:    next_state = ABOUT;
					'b10:    next_state = BSTOP;
					'b11:    next_state = ABOUT;
					default: next_state = ABOUT;
				endcase
			BIN:
				case (s13)
					'b00:    next_state = BIN;
					'b01:    next_state = ABOUT;
					'b10:    next_state = ASTOP;
					'b11:    next_state = ABOUT;
					default: next_state = ABOUT;
				endcase
			ASTOP:
				if (sensor[2])
					next_state = AIN;
				else
					next_state = ASTOP;
			BSTOP:
				if (sensor[3])
					next_state = BIN;
				else
					next_state = BSTOP;
			default:
				next_state = ABOUT;
		endcase
	end

	// Combinational logic for outputs based on current state
	always @ (*) begin // Use implicit sensitivity list
		// Default assignments
		sw[1:0] = 2'b00;
		dira = 'b00;
		dirb = 'b00;
		case (state)
			ABOUT: begin
				sw[0] = 0;
				sw[1] = 0;
				dira = 'b01;
				dirb = 'b01;
			end
			AIN: begin
				sw[0] = 0;
				sw[1] = 0;
				dira = 'b01;
				dirb = 'b01;
			end
			BIN: begin
				sw[0] = 1;
				sw[1] = 1;
				dira = 'b01;
				dirb = 'b01;
			end
			ASTOP: begin
				sw[0] = 1;
				sw[1] = 1;
				dira = 'b00;
				dirb = 'b01;
			end
			BSTOP: begin
				sw[0] = 0;
				sw[1] = 0;
				dira = 'b01;
				dirb = 'b00;
			end
			default: begin // Handles potential unknown states
				sw[0] = 0;
				sw[1] = 0;
				dira = 'b00;
				dirb = 'b00;
			end
		endcase
	end
endmodule

module LFSR8_11D
(
	input wire       clk,
	// Added reset for better testability/initialization
	input wire       rst,
	output reg [7:0] LFSR = 8'hFF // Initial value set
);
	wire feedback = LFSR[7] ^ (LFSR[6:0] == 7'b0000000);

	always @(posedge clk) begin
	    // Added synchronous reset
	    if (rst) begin
	        LFSR <= 8'hFF; // Reset to initial value
	    end else begin
    		LFSR[0] <= feedback;
    		LFSR[1] <= LFSR[0];
    		LFSR[2] <= LFSR[1] ^ feedback;
    		LFSR[3] <= LFSR[2] ^ feedback;
    		LFSR[4] <= LFSR[3] ^ feedback;
    		LFSR[5] <= LFSR[4];
    		LFSR[6] <= LFSR[5];
    		LFSR[7] <= LFSR[6];
        end
	end
endmodule