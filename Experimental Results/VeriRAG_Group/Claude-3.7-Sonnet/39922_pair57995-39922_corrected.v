`timescale 1ns/1ns
`timescale 1ns/1ns
module c1_regs(
	input nICOM_ZONE,
	input RW,
	inout [15:8] M68K_DATA,
	inout [7:0] SDD,
	input nSDZ80R, nSDZ80W, nSDZ80CLR,
	input scan_clk,
	input test_mode,
	output nSDW
);
	reg [7:0] SDD_LATCH_CMD;
	reg [7:0] SDD_LATCH_REP;
	wire dft_sdz80w;
	wire dft_sdw;
	wire dft_sdz80clr;

	assign dft_sdz80w = test_mode ? scan_clk : nSDZ80W;
	assign dft_sdw = test_mode ? scan_clk : nSDW;
	assign dft_sdz80clr = test_mode ? scan_clk : nSDZ80CLR;

	assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD;
	always @(posedge dft_sdz80w)	
	begin
		$display("Z80 -> 68K: %H", SDD);		
		SDD_LATCH_REP <= SDD;
	end
	assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;
	assign nSDW = (RW | nICOM_ZONE);		
	always @(negedge dft_sdw)
		$display("68K -> Z80: %H", M68K_DATA);
	always @(negedge nICOM_ZONE or negedge dft_sdz80clr)		
	begin
		if (!dft_sdz80clr)
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