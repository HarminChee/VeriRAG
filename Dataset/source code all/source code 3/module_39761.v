`timescale 1ns/1ns
`timescale 1ns/1ns
module neo_f0(
	input nRESET,
	input nDIPRD0,
	input nDIPRD1,					
	input nBITWD0,
	input [7:0] DIPSW,
	input [7:4] M68K_ADDR,
	inout [7:0] M68K_DATA,
	input SYSTEMB,
	output [5:0] nSLOT,
	output SLOTA, SLOTB, SLOTC,
	output reg [2:0] LED_LATCH,
	output reg [7:0] LED_DATA,
	input RTC_DOUT, RTC_TP,
	output RTC_DIN, RTC_CLK, RTC_STROBE
);
	reg [2:0] REG_RTCCTRL;
	reg [2:0] SLOTS;
	assign RTC_DIN = REG_RTCCTRL[0];
	assign RTC_CLK = REG_RTCCTRL[1];
	assign RTC_STROBE = REG_RTCCTRL[2];
	assign M68K_DATA = (nDIPRD0) ? 8'bzzzzzzzz :
								(M68K_ADDR[7]) ? 8'b11000000 :
								DIPSW;
	assign M68K_DATA = (nDIPRD1) ? 8'bzzzzzzzz :
									{RTC_DOUT, RTC_TP, 1'b1, 5'b11111};
	always @(nRESET, nBITWD0)
	begin
		if (!nRESET)
		begin
			SLOTS <= 3'b000;
			REG_RTCCTRL <= 3'b000;
		end
		else if (!nBITWD0)
		begin
			if (M68K_ADDR[6:4] == 3'b010)
				$display("SELECT SLOT %d", M68K_DATA[2:0]);
			else if (M68K_ADDR[6:4] == 3'b011)
				$display("SET LED LATCHES to %b", M68K_DATA[5:3]);
			else if (M68K_ADDR[6:4] == 3'b100)
				$display("SET LED DATA to %b", M68K_DATA[7:0]);
			else if (M68K_ADDR[6:4] == 3'b101)
				$display("SET RTCCTRL to %b", M68K_DATA[2:0]);
			case (M68K_ADDR[6:4])
				3'b010:
					SLOTS <= M68K_DATA[2:0];			
				3'b011:
					LED_LATCH <= M68K_DATA[5:3];		
				3'b100:
					LED_DATA <= M68K_DATA[7:0];		
				3'b101:
					REG_RTCCTRL <= M68K_DATA[2:0];	
			endcase
		end
	end
	assign {SLOTC, SLOTB, SLOTA} = SYSTEMB ? SLOTS : 3'b000;	
	assign nSLOT = SYSTEMB ? 
						(SLOTS == 3'b000) ? 6'b111110 :
						(SLOTS == 3'b001) ? 6'b111101 :
						(SLOTS == 3'b010) ? 6'b111011 :
						(SLOTS == 3'b011) ? 6'b110111 :
						(SLOTS == 3'b100) ? 6'b101111 :
						(SLOTS == 3'b101) ? 6'b011111 :
						6'b111111 :		
						6'b111111 ;		
endmodule
