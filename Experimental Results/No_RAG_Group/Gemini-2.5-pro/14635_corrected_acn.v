`default_nettype none
`timescale 1 ps / 1 ps
module trainsim
(
	input wire        rst, // Keep rst as primary input for state FSM
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
	wire [1:0] s12 = {sensor[0], sensor[1]};
	wire [1:0] s13 = {sensor[0], sensor[2]};
	wire [1:0] s24 = {sensor[1], sensor[3]};

	// This FF for sw[2] needs a reset for proper initialization and testability
	// Adding asynchronous reset controlled by the primary input 'rst'
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			sw[2] <= 1'b0; // Define reset state
		end else begin
			sw[2] <= 1'b0; // Original logic (always 0)
		end
	end

	// State machine FFs - already correctly using primary input 'rst' for async reset
	always @ (posedge clk or posedge rst) begin
		if (rst)
			state <= ABOUT; // Use non-blocking assignment
		else
			case (state)
				ABOUT:
					case (s12)
						'b00:    state <= ABOUT;
						'b01:    state <= BIN;
						'b10:    state <= AIN;
						'b11:    state <= AIN;
						default: state <= ABOUT;
					endcase
				AIN:
					case (s24)
						'b00:    state <= AIN;
						'b01:    state <= ABOUT;
						'b10:    state <= BSTOP;
						'b11:    state <= ABOUT;
						default: state <= ABOUT;
					endcase
				BIN:
					case (s13)
						'b00:    state <= BIN;
						'b01:    state <= ABOUT;
						'b10:    state <= ASTOP;
						'b11:    state <= ABOUT;
						default: state <= ABOUT;
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
	end

	// Combinational logic for outputs - Use non-blocking assignments for outputs driven by FFs if they were in clocked blocks,
	// but here it's combinational based on 'state', so blocking is okay. However, output regs should ideally be driven by clocked blocks.
	// For minimal change based on ACNCPI, keep combinational, but ensure 'state' is resettable (which it is).
	// Use always_comb for clarity if tool supports SystemVerilog, or always @(*)
	always @ (*) begin // Better sensitivity list for combinational logic
		case (state)
			ABOUT: begin
				sw[0] = 0;
				sw[1] = 0;
				// sw[2] is handled by its own FF
				dira = 'b01;
				dirb = 'b01;
			end
			AIN: begin
				sw[0] = 0;
				sw[1] = 0;
				// sw[2] is handled by its own FF
				dira = 'b01;
				dirb = 'b01;
			end
			BIN: begin
				sw[0] = 1;
				sw[1] = 1;
				// sw[2] is handled by its own FF
				dira = 'b01;
				dirb = 'b01;
			end
			ASTOP: begin
				sw[0] = 1;
				sw[1] = 1;
				// sw[2] is handled by its own FF
				dira = 'b00;
				dirb = 'b01;
			end
			BSTOP: begin
				sw[0] = 0;
				sw[1] = 0;
				// sw[2] is handled by its own FF
				dira = 'b01;
				dirb = 'b00;
			end
			default: begin
				sw[0] = 0;
				sw[1] = 0;
				// sw[2] is handled by its own FF
				dira = 'b00;
				dirb = 'b00;
			end
		endcase
	end
endmodule

`default_nettype none
`timescale 1 ps / 1 ps
module LFSR8_11D
(
	input wire       clk,
	input wire       rst, // Added primary input reset signal for ACNCPI compliance
	output reg [7:0] LFSR // Initial value removed, reset handles initialization
);
	// Define the reset value (e.g., all ones as suggested by original code)
	localparam RESET_VALUE = 8'hFF;

	wire feedback = LFSR[7] ^ (LFSR[6:0] == 7'b0000000);

	// Added asynchronous reset controlled by primary input 'rst'
	always @(posedge clk or posedge rst) begin
		if (rst) begin // Asynchronous reset condition
			LFSR <= RESET_VALUE; // Use non-blocking assignment
		end else begin // Normal clock edge operation
			// Use non-blocking assignments for FFs
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
`default_nettype wire // Set default_nettype back to wire at the end