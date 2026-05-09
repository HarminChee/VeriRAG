`timescale 1ns/1ns
`timescale 1ns/1ns
module c1_regs(
	input scan_clk_low, 
	input test_i, 
	input nICOM_ZONE,
	input RW,
	inout [15:8] M68K_DATA,
	inout [7:0] SDD,
	input nSDZ80R, nSDZ80W, nSDZ80CLR,
	output nSDW
);
	reg [7:0] SDD_LATCH_CMD;
	reg [7:0] SDD_LATCH_REP;
	wire dft_nSDZ80W;
	wire dft_nSDW;

	assign dft_nSDZ80W = test_i ? scan_clk_low : nSDZ80W;
	assign dft_nSDW = test_i ? scan_clk_low : nSDW;

	assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD;
	always @(posedge dft_nSDZ80W)	
	begin
		$display("Z80 -> 68K: %H", SDD);		
		SDD_LATCH_REP <= SDD;
	end
	assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;
	assign nSDW = (RW | nICOM_ZONE);		
	always @(negedge dft_nSDW)
		$display("68K -> Z80: %H", M68K_DATA);
	always @(negedge nICOM_ZONE or negedge nSDZ80CLR)		
	begin
		if (!nSDZ80CLR)
		begin
			SDD_LATCH_CMD <= 8'b00000000;
		end
		else
		begin
			if (!RW)
				SDD_LATCH_CMD <= M68K_DATA;
		end
	end
endmodule