module sequencer_scc_siii_phase_decode
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
		dqs_phase = 0;
		dq_phase_reset = 0;
		dq_phase = 0;
		dqse_phase_reset = 0;
		dqse_phase = 0;
		case (DLL_DELAY_CHAIN_LENGTH)
		6: begin
			dqsi_phase = 3'b000;
			dqs_phase  = 7'b0010100;
			dq_phase   = 7'b0001100;
			dqse_phase = 6'b001000;
			dqs_phase_reset = 7'b0011010;
			dq_phase_reset = 7'b0010010;
			dqse_phase_reset = 6'b000110;
			case (avl_writedata[4:0])
			5'b00000: 
				begin
					dqs_phase  = 7'b0010100;
					dq_phase   = 7'b0001100;
					dqse_phase = 6'b001000;
				end
			5'b00001: 
				begin
					dqs_phase  = 7'b0011100;
					dq_phase   = 7'b0010100;
					dqse_phase = 6'b001100;
				end
			5'b00010: 
				begin
					dqs_phase  = 7'b0100110;
					dq_phase   = 7'b0011100;
					dqse_phase = 6'b000110;
				end
			5'b00011: 
				begin
					dqs_phase  = 7'b0010010;
					dq_phase   = 7'b0001010;
					dqse_phase = 6'b001011;
				end
			5'b00100: 
				begin
					dqs_phase  = 7'b0011010;
					dq_phase   = 7'b0010010;
					dqse_phase = 6'b001111;
				end
			5'b00101: 
				begin
					dqs_phase  = 7'b0100001;
					dq_phase   = 7'b0011010;
					dqse_phase = 6'b000101;
				end
			5'b00110: 
				begin
					dqs_phase  = 7'b0010101;
					dq_phase   = 7'b0001101;
				end
			5'b00111: 
				begin
					dqs_phase  = 7'b0011101;
					dq_phase   = 7'b0010101;
				end
			5'b01000: 
				begin
					dqs_phase  = 7'b0100111;
					dq_phase   = 7'b0011101;
				end
			5'b01001: 
				begin
					dqs_phase  = 7'b0010011;
					dq_phase   = 7'b0001011;
				end
			5'b01010: 
				begin
					dqs_phase  = 7'b0011011;
					dq_phase   = 7'b0010011;
				end
			default : begin end
			endcase
		end
		8: begin
			dqsi_phase = 3'b001;
			dqs_phase  = 7'b0010100;
			dq_phase   = 7'b0000100;
			dqse_phase = 6'b001000;
			dqs_phase_reset = 7'b0100010;
			dq_phase_reset = 7'b0010010;
			dqse_phase_reset = 6'b001010;
			case (avl_writedata[4:0])
			5'b00000: 
				begin
					dqs_phase  = 7'b0010100;
					dq_phase   = 7'b0000100;
					dqse_phase = 6'b001000;
				end
			5'b00001: 
				begin
					dqs_phase  = 7'b0011100;
					dq_phase   = 7'b0001100;
					dqse_phase = 6'b001100;
				end
			5'b00010: 
				begin
					dqs_phase  = 7'b0100100;
					dq_phase   = 7'b0010100;
					dqse_phase = 6'b010000;
				end
			5'b00011: 
				begin
					dqs_phase  = 7'b0101110;
					dq_phase   = 7'b0011100;
					dqse_phase = 6'b000110;
				end
			5'b00100: 
				begin
					dqs_phase  = 7'b0010010;
					dq_phase   = 7'b0000000;
					dqse_phase = 6'b001010;
				end
			5'b00101: 
				begin
					dqs_phase  = 7'b0011010;
					dq_phase   = 7'b0001010;
					dqse_phase = 6'b001111;
				end
			5'b00110: 
				begin
					dqs_phase  = 7'b0100010;
					dq_phase   = 7'b0010010;
					dqse_phase = 6'b010011;
				end
			5'b00111: 
				begin
					dqs_phase  = 7'b0101001;
					dq_phase   = 7'b0011010;
					dqse_phase = 6'b000101;
				end
			5'b01000: 
				begin
					dqs_phase  = 7'b0010101;
					dq_phase   = 7'b0000110;
				end
			5'b01001: 
				begin
					dqs_phase  = 7'b0011101;
					dq_phase   = 7'b0001101;
				end
			5'b01010: 
				begin
					dqs_phase  = 7'b0100101;
					dq_phase   = 7'b0010101;
				end
			5'b01011: 
				begin
					dqs_phase  = 7'b0101111;
					dq_phase   = 7'b0011101;
				end
			5'b01100: 
				begin
					dqs_phase  = 7'b0010011;
					dq_phase   = 7'b0000001;
				end
			5'b01101: 
				begin
					dqs_phase  = 7'b0011011;
					dq_phase   = 7'b0001011;
				end
			5'b01110: 
				begin
					dqs_phase  = 7'b0100011;
					dq_phase   = 7'b0010011;
				end
			default : begin end
			endcase
		end
		10: begin
			dqsi_phase = 3'b001;
			dqs_phase  = 7'b0010100;
			dq_phase   = 7'b0000100;
			dqse_phase = 6'b001100;
			dqs_phase_reset = 7'b0100010;
			dq_phase_reset = 7'b0010010;
			dqse_phase_reset = 6'b001010;
			case (avl_writedata[4:0])
			5'b00000: 
				begin
					dqs_phase  = 7'b0010100;
					dq_phase   = 7'b0000100;
					dqse_phase = 6'b001100;
				end
			5'b00001: 
				begin
					dqs_phase  = 7'b0011100;
					dq_phase   = 7'b0001100;
					dqse_phase = 6'b010000;
				end
			5'b00010: 
				begin
					dqs_phase  = 7'b0100100;
					dq_phase   = 7'b0010100;
					dqse_phase = 6'b010100;
				end
			5'b00011: 
				begin
					dqs_phase  = 7'b0101110;
					dq_phase   = 7'b0011100;
					dqse_phase = 6'b000110;
				end
			5'b00100: 
				begin
					dqs_phase  = 7'b0110110;
					dq_phase   = 7'b0100100;
					dqse_phase = 6'b001010;
				end
			5'b00101: 
				begin
					dqs_phase  = 7'b0010010;
					dq_phase   = 7'b0000010;
					dqse_phase = 6'b001111;
				end
			5'b00110: 
				begin
					dqs_phase  = 7'b0011010;
					dq_phase   = 7'b0001010;
					dqse_phase = 6'b010011;
				end
			5'b00111: 
				begin
					dqs_phase  = 7'b0100010;
					dq_phase   = 7'b0010010;
					dqse_phase = 6'b010111;
				end
			5'b01000: 
				begin
					dqs_phase  = 7'b0101001;
					dq_phase   = 7'b0011010;
					dqse_phase = 6'b000101;
				end
			5'b01001: 
				begin
					dqs_phase  = 7'b0110001;
					dq_phase   = 7'b0100010;
					dqse_phase = 6'b001001;
				end
			5'b01010: 
				begin
					dqs_phase  = 7'b0010101;
					dq_phase   = 7'b0000101;
				end
			5'b01011: 
				begin
					dqs_phase  = 7'b0011101;
					dq_phase   = 7'b0001101;
				end
			5'b01100: 
				begin
					dqs_phase  = 7'b0100101;
					dq_phase   = 7'b0010101;
				end
			5'b01101: 
				begin
					dqs_phase  = 7'b0101111;
					dq_phase   = 7'b0011101;
				end
			5'b01110: 
				begin
					dqs_phase  = 7'b0110111;
					dq_phase   = 7'b0100101;
				end
			5'b01111: 
				begin
					dqs_phase  = 7'b0010011;
					dq_phase   = 7'b0000011;
				end
			5'b10000: 
				begin
					dqs_phase  = 7'b0011011;
					dq_phase   = 7'b0001011;
				end
			5'b10001: 
				begin
					dqs_phase  = 7'b0100011;
					dq_phase   = 7'b0010011;
				end
			default : begin end
			endcase
		end
		12: begin
			dqsi_phase = 3'b001;
			dqs_phase  = 7'b0010100;
			dq_phase   = 7'b0000100;
			dqse_phase = 6'b001100;
			dqs_phase_reset = 7'b0100010;
			dq_phase_reset = 7'b0010010;
			dqse_phase_reset = 6'b001110;
			case (avl_writedata[4:0])
			5'b00000: 
				begin
					dqs_phase  = 7'b0010100;
					dq_phase   = 7'b0000100;
					dqse_phase = 6'b001100;
				end
			5'b00001: 
				begin
					dqs_phase  = 7'b0011100;
					dq_phase   = 7'b0001100;
					dqse_phase = 6'b010000;
				end
			5'b00010: 
				begin
					dqs_phase  = 7'b0100100;
					dq_phase   = 7'b0010100;
					dqse_phase = 6'b010100;
				end
			5'b00011: 
				begin
					dqs_phase  = 7'b0101100;
					dq_phase   = 7'b0011100;
					dqse_phase = 6'b011000;
				end
			5'b00100: 
				begin
					dqs_phase  = 7'b0110110;
					dq_phase   = 7'b0100100;
					dqse_phase = 6'b000110;
				end
			5'b00101: 
				begin
					dqs_phase  = 7'b0111110;
					dq_phase   = 7'b0101100;
					dqse_phase = 6'b001010;
				end
			5'b00110: 
				begin
					dqs_phase  = 7'b0010010;
					dq_phase   = 7'b0000010;
					dqse_phase = 6'b001110;
				end
			5'b00111: 
				begin
					dqs_phase  = 7'b0011010;
					dq_phase   = 7'b0001010;
					dqse_phase = 6'b010011;
				end
			5'b01000: 
				begin
					dqs_phase  = 7'b0100010;
					dq_phase   = 7'b0010010;
					dqse_phase = 6'b010111;
				end
			5'b01001: 
				begin
					dqs_phase  = 7'b0101010;
					dq_phase   = 7'b0011010;
					dqse_phase = 6'b011011;
				end
			5'b01010: 
				begin
					dqs_phase  = 7'b0110001;
					dq_phase   = 7'b0100010;
					dqse_phase = 6'b000101;
				end
			5'b01011: 
				begin
					dqs_phase  = 7'b0111001;
					dq_phase   = 7'b0101010;
					dqse_phase = 6'b001001;
				end
			5'b01100: 
				begin
					dqs_phase  = 7'b0010101;
					dq_phase   = 7'b0000101;
				end
			5'b01101: 
				begin
					dqs_phase  = 7'b0011101;
					dq_phase   = 7'b0001101;
				end
			5'b01110: 
				begin
					dqs_phase  = 7'b0100101;
					dq_phase   = 7'b0010101;
				end
			5'b01111: 
				begin
					dqs_phase  = 7'b0101101;
					dq_phase   = 7'b0011101;
				end
			5'b10000: 
				begin
					dqs_phase  = 7'b0110111;
					dq_phase   = 7'b0100101;
				end
			5'b10001: 
				begin
					dqs_phase  = 7'b0111111;
					dq_phase   = 7'b0101101;
				end
			5'b10010: 
				begin
					dqs_phase  = 7'b0010011;
					dq_phase   = 7'b0000011;
				end
			5'b10011: 
				begin
					dqs_phase  = 7'b0011011;
					dq_phase   = 7'b0001011;
				end
			5'b10100: 
				begin
					dqs_phase  = 7'b0100011;
					dq_phase   = 7'b0010011;
				end
			5'b10101: 
				begin
					dqs_phase  = 7'b0101011;
					dq_phase   = 7'b0011011;
				end
			default : begin end
			endcase
		end
		default : begin end
		endcase
	end
endmodule
