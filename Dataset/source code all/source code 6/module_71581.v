module sequencer_scc_sv_phase_decode
    # (parameter
    AVL_DATA_WIDTH          =   32,
    DLL_DELAY_CHAIN_LENGTH  =   6
    )
    (
    avl_writedata,
	dqsi_phase,	
    dqs_phase_reset,
    dqs_phase,	
    dq_phase_reset,
    dq_phase,	
    dqse_phase_reset,
    dqse_phase
);
	input [AVL_DATA_WIDTH - 1:0] avl_writedata;
	output [2:0] dqsi_phase;	
	output [6:0] dqs_phase_reset;
	output [6:0] dqs_phase;	
	output [6:0] dq_phase_reset;
	output [6:0] dq_phase;	
	output [5:0] dqse_phase_reset;
	output [5:0] dqse_phase;
	reg [2:0] dqsi_phase;
	reg [6:0] dqs_phase_reset;
	reg [6:0] dqs_phase;
	reg [6:0] dq_phase_reset;
	reg [6:0] dq_phase;
	reg [5:0] dqse_phase_reset;
	reg [5:0] dqse_phase;
	always @ (*) begin
		dqsi_phase = 0;
		dqs_phase_reset = 0;
		dq_phase_reset = 0;
		dqse_phase_reset = 0;
		dqse_phase = 0;
		dqsi_phase = 3'b010;
		dqse_phase = 6'b001000;
		dqs_phase  = 7'b1110110;
		dq_phase   = 7'b0110100;
		dqse_phase = 6'b000110;
		case (avl_writedata[4:0])
		5'b00000: 
			begin
				dqs_phase  = 7'b0010100;
				dq_phase   = 7'b1000100;
				dqse_phase = 6'b000010;
			end
		5'b00001: 
			begin
				dqs_phase  = 7'b0110100;
				dq_phase   = 7'b1100100;
				dqse_phase = 6'b000011;
			end
		5'b00010: 
			begin
				dqs_phase  = 7'b1010100;
				dq_phase   = 7'b0010100;
				dqse_phase = 6'b000100;
			end
		5'b00011: 
			begin
				dqs_phase  = 7'b1110110;
				dq_phase   = 7'b0110100;
				dqse_phase = 6'b000101;
			end
		5'b00100: 
			begin
				dqs_phase  = 7'b0000110;
				dq_phase   = 7'b1010100;
				dqse_phase = 6'b000110;
			end
		5'b00101: 
			begin
				dqs_phase  = 7'b0100110;
				dq_phase   = 7'b1110110;
				dqse_phase = 6'b000111;
			end
		5'b00110: 
			begin
				dqs_phase  = 7'b1000110;
				dq_phase   = 7'b0000110;
				dqse_phase = 6'b000000;
			end
		5'b00111: 
			begin
				dqs_phase  = 7'b1100110;
				dq_phase   = 7'b0100110;
				dqse_phase = 6'b000000;
			end
		5'b01000: 
			begin
				dqs_phase  = 7'b0010110;
				dq_phase   = 7'b1000110;
			end
		5'b01001: 
			begin
				dqs_phase  = 7'b0110110;
				dq_phase   = 7'b1100110;
			end
		5'b01010: 
			begin
				dqs_phase  = 7'b1010110;
				dq_phase   = 7'b0010110;
			end
		5'b01011: 
			begin
				dqs_phase  = 7'b1111000;
				dq_phase   = 7'b0110110;
			end
		5'b01100: 
			begin
				dqs_phase  = 7'b0001000;
				dq_phase   = 7'b1010110;
			end
		5'b01101: 
			begin
				dqs_phase  = 7'b0101000;
				dq_phase   = 7'b1111000;
			end
		5'b01110: 
			begin
				dqs_phase  = 7'b1001000;
				dq_phase   = 7'b0001000;
			end
		5'b01111: 
			begin
				dqs_phase  = 7'b1101000;
				dq_phase   = 7'b0101000;
			end
		5'b10000: 
			begin
				dqs_phase  = 7'b0011000;
				dq_phase   = 7'b1001000;
			end
		5'b10001: 
			begin
				dqs_phase  = 7'b0111000;
				dq_phase   = 7'b1101000;
			end
		5'b10010: 
			begin
				dqs_phase  = 7'b1011000;
				dq_phase   = 7'b0011000;
			end
		5'b10011: 
			begin
				dqs_phase  = 7'b1111010;
				dq_phase   = 7'b0111000;
			end
		5'b10100: 
			begin
				dqs_phase  = 7'b0001010;
				dq_phase   = 7'b1011000;
			end
		5'b10101: 
			begin
				dqs_phase  = 7'b0101010;
				dq_phase   = 7'b1111010;
			end
		5'b10110: 
			begin
				dqs_phase  = 7'b1001010;
				dq_phase   = 7'b0001010;
			end
		5'b10111: 
			begin
				dqs_phase  = 7'b1101010;
				dq_phase   = 7'b0101010;
			end
		5'b11000: 
			begin
				dqs_phase  = 7'b0011010;
				dq_phase   = 7'b1001010;
			end
		5'b11001: 
			begin
				dqs_phase  = 7'b0111010;
				dq_phase   = 7'b1101010;
			end
		5'b11010: 
			begin
				dqs_phase  = 7'b1011010;
				dq_phase   = 7'b0011010;
			end
		5'b11011: 
			begin
				dqs_phase  = 7'b1111010;
				dq_phase   = 7'b0111010;
			end
		default : begin end
		endcase
	end
endmodule
