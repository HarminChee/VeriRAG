`timescale 1ns/1ns
module c1_regs(
	input nICOM_ZONE,
	input RW,
	input test_i,
	input clk_i,
	inout [15:8] M68K_DATA,
	inout [7:0] SDD,
	input nSDZ80R, nSDZ80W, nSDZ80CLR,
	output nSDW
);
	reg [7:0] SDD_LATCH_CMD;
	reg [7:0] SDD_LATCH_REP;
	wire dft_clk;
	assign dft_clk = test_i ? clk_i : nSDZ80W;
	assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD;
	always @(posedge dft_clk)	
	begin
		$display("Z80 -> 68K: %H", SDD);		
		SDD_LATCH_REP <= SDD;
	end
	assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;
	assign nSDW = (RW | nICOM_ZONE);		
	always @(negedge nSDW)
		$display("68K -> Z80: %H", M68K_DATA);
	always @(posedge clk_i)		
	begin
		if (!nSDZ80CLR)
		begin
			SDD_LATCH_CMD <= 8'b00000000;
		end
		else if (!nICOM_ZONE)
		begin
			if (!RW)
				SDD_LATCH_CMD <= M68K_DATA;
		end
	end
endmodule