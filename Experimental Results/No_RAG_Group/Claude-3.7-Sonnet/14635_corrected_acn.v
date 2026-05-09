Here's the modified Verilog code addressing the ACNCPI issue:


`default_nettype none
`timescale 1 ps / 1 ps 
module trainsim
(
	input wire        rst_in,  // Changed from output to input
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
	always @ (posedge clk) begin
		sw[2] <= 0;
	end
	always @ (posedge clk or posedge rst_in) begin
		if (rst_in)
			state <= ABOUT;
		else
			case (state)
				ABOUT:
					case (s12)
						2'b00:    state <= ABOUT;
						2'b01:    state <= BIN;
						2'b10:    state <= AIN;
						2'b11:    state <= AIN;
						default: state <= ABOUT;
					endcase
				AIN:
					case (s24)
						2'b00:    state <= AIN;
						2'b01:    state <= ABOUT;
						2'b10:    state <= BSTOP;
						2'b11:    state <= ABOUT;
						default: state <= ABOUT;
					endcase
				BIN:		
					case (s13)
						2'b00:    state <= BIN;
						2'b01:    state <= ABOUT;
						2'b10:    state <= ASTOP;
						2'b11:    state <= ABOUT;
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
	always @ (state) begin
		case (state)
			ABOUT: begin
				sw[1:0] <= 2'b00;
				dira <= 2'b01;
				dirb <= 2'b01;
			end
			AIN: begin
				sw[1:0] <= 2'b00;
				dira <= 2'b01;
				dirb <= 2'b01;
			end
			BIN: begin
				sw[1:0] <= 2'b11;
				dira <= 2'b01;
				dirb <= 2'b01;
			end
			ASTOP: begin
				sw[1:0] <= 2'b11;
				dira <= 2'b00;
				dirb <= 2'b01;
			end
			BSTOP: begin
				sw[1:0] <= 2'b00;
				dira <= 2'b01;
				dirb <= 2'b00;
			end
			default: begin
				sw[1:0] <= 2'b00;
				dira <= 2'b00;
				dirb <= 2'b00;
			end		
		endcase
	end
endmodule

module LFSR8_11D
(
	input wire       clk,
	input wire       rst_in,  // Added reset input
	output reg [7:0] LFSR
);
	wire feedback = LFSR[7] ^ (LFSR[6:0] == 7'b0000000);
	always @(posedge clk or posedge rst_in) begin
		if (rst_in)
			LFSR <= 8'b11111111;
		else begin
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