`timescale 1ns/1ns
module c1_regs(
	input test_i, nICOM_ZONE,
	input RW,
	inout [15:8] M68K_DATA,
	inout [7:0] SDD,
	input nSDZ80R, nSDZ80W, nSDZ80CLR,
	output nSDW
);
	reg [7:0] SDD_LATCH_CMD;
	reg [7:0] SDD_LATCH_REP;
	assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD;

	always @(posedge nSDZ80W)	
	begin
		$display("Z80 -> 68K: %H", SDD);		
		SDD_LATCH_REP <= SDD;
	end

	assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;
	assign nSDW = (RW | nICOM_ZONE);		

	always @(negedge nSDW)
		$display("68K -> Z80: %H", M68K_DATA);

	always @(negedge nICOM_ZONE or posedge test_i)		
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