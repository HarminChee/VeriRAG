`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module sequencer_scc_sv_phase_decode
    # (parameter
    AVL_DATA_WIDTH          =   32,
    DLL_DELAY_CHAIN_LENGTH  =   6
    )
    (
    avl_writedata,
	dqsi_phase,	
    dqs_phase,	
    dq_phase,	
    dqse_phase
);
	input [AVL_DATA_WIDTH - 1:0] avl_writedata;
	output [2:0] dqsi_phase;	
	output [6:0] dqs_phase;	
	output [6:0] dq_phase;	
	output [5:0] dqse_phase;
	reg [2:0] dqsi_phase;
	reg [6:0] dqs_phase;
	reg [6:0] dq_phase;
	reg [5:0] dqse_phase;
	always @ (*) begin
		dqsi_phase = 3'b010;
		dqs_phase  = 7'b1110110;
		dq_phase   = 7'b0110100;
		dqse_phase = 6'b000110;
		case (avl_writedata[4:0])
		5'b00000: 
			begin
				dqs_phase  = 7'b0010110;
				dq_phase   = 7'b1000110;
				dqse_phase = 6'b000010;
			end
		5'b00001: 
			begin
				dqs_phase  = 7'b0110110;
				dq_phase   = 7'b1100110;
				dqse_phase = 6'b000011;
			end
		5'b00010: 
			begin
				dqs_phase  = 7'b1010110;
				dq_phase   = 7'b0010110;
				dqse_phase = 6'b000100;
			end
		5'b00011: 
			begin
				dqs_phase  = 7'b1110111;
				dq_phase   = 7'b0110110;
				dqse_phase = 6'b000101;
			end
		5'b00100: 
			begin
				dqs_phase  = 7'b0000111;
				dq_phase   = 7'b1010110;
				dqse_phase = 6'b000110;
			end
		5'b00101: 
			begin
				dqs_phase  = 7'b0100111;
				dq_phase   = 7'b1110111;
				dqse_phase = 6'b001111;
			end
		5'b00110: 
			begin
				dqs_phase  = 7'b1001000;
				dq_phase   = 7'b0000111;
				dqse_phase = 6'b001000;
			end
		5'b00111: 
			begin
				dqs_phase  = 7'b1101000;
				dq_phase   = 7'b0100111;
				dqse_phase = 6'b001001;
			end
		5'b01000: 
			begin
				dqs_phase  = 7'b0011000;
				dq_phase   = 7'b1001000;
			end
		5'b01001: 
			begin
				dqs_phase  = 7'b0111000;
				dq_phase   = 7'b1101000;
			end
		5'b01010: 
			begin
				dqs_phase  = 7'b1011000;
				dq_phase   = 7'b0011000;
			end
		5'b01011: 
			begin
				dqs_phase  = 7'b1111001;
				dq_phase   = 7'b0111000;
			end
		5'b01100: 
			begin
				dqs_phase  = 7'b0001001;
				dq_phase   = 7'b1011000;
			end
		5'b01101: 
			begin
				dqs_phase  = 7'b0101001;
				dq_phase   = 7'b1111001;
			end
		5'b01110: 
			begin
				dqs_phase  = 7'b1001010;
				dq_phase   = 7'b0001001;
			end
		5'b01111: 
			begin
				dqs_phase  = 7'b1101010;
				dq_phase   = 7'b0101001;
			end
		5'b10000: 
			begin
				dqs_phase  = 7'b0011010;
				dq_phase   = 7'b1001010;
			end
		5'b10001: 
			begin
				dqs_phase  = 7'b0111010;
				dq_phase   = 7'b1101010;
			end
		5'b10010: 
			begin
				dqs_phase  = 7'b1011010;
				dq_phase   = 7'b0011010;
			end
		5'b10011: 
			begin
				dqs_phase  = 7'b1111011;
				dq_phase   = 7'b0111010;
			end
		5'b10100: 
			begin
				dqs_phase  = 7'b0001011;
				dq_phase   = 7'b1011010;
			end
		5'b10101: 
			begin
				dqs_phase  = 7'b0101011;
				dq_phase   = 7'b1111011;
			end
		default : begin end
		endcase
	end
endmodule
