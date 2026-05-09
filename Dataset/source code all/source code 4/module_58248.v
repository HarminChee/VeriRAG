`timescale 1ns / 1ps
`timescale 1ns / 1ps
module HandshakeSynchronizer(
	input wire clk_a,
	input wire en_a,
	output reg ack_a = 0,
	output wire busy_a,
	input wire clk_b,
	output reg en_b = 0,
	input wire ack_b
	);
	reg tx_en_in = 0;
	wire tx_en_out;
	reg tx_ack_in = 0;
	wire tx_ack_out;
	ThreeStageSynchronizer sync_tx_en
		(.clk_in(clk_a), .din(tx_en_in), .clk_out(clk_b), .dout(tx_en_out));
	ThreeStageSynchronizer sync_tx_ack
		(.clk_in(clk_b), .din(tx_ack_in), .clk_out(clk_a), .dout(tx_ack_out));
	reg[1:0] state_a = 0;
	assign busy_a = state_a[1] || en_a;
	always @(posedge clk_a) begin
		ack_a <= 0;
		case(state_a)
			0: begin
				if(en_a) begin
					tx_en_in <= 1;
					state_a <= 1;
				end
			end
			1: begin
				if(tx_ack_out) begin
					tx_en_in <= 0;
					state_a <= 2;
				end
			end
			2: begin
				if(!tx_ack_out) begin
					ack_a <= 1;
					state_a <= 0;
				end
			end
		endcase
	end
	reg[1:0] state_b = 0;
	always @(posedge clk_b) begin
		en_b <= 0;
		case(state_b)
			0: begin
				if(tx_en_out) begin
					en_b <= 1;
					state_b <= 1;
				end
			end
			1: begin
				if(ack_b) begin
					tx_ack_in <= 1;
					state_b <= 2;
				end
			end
			2: begin
				if(!tx_en_out) begin
					state_b <= 0;
					tx_ack_in <= 0;
				end
			end
		endcase
	end
endmodule
