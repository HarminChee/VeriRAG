`timescale 1ns/1ns
module c1_regs_corrected_cdf(
	input nICOM_ZONE,
	input RW,
	input clk,
	input test_mode,
	inout [15:8] M68K_DATA,
	inout [7:0] SDD,
	input nSDZ80R, nSDZ80W, nSDZ80CLR,
	output nSDW
);
	reg [7:0] SDD_LATCH_CMD;
	reg [7:0] SDD_LATCH_REP;
	wire [7:0] data_in_mux;

	assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD;
	
	assign data_in_mux = test_mode ? SDD : M68K_DATA;
	
	always @(posedge clk)	
	begin
		if (!nSDZ80W)
		begin
			$display("Z80 -> 68K: %H", SDD);		
			SDD_LATCH_REP <= SDD;
		end
	end
	
	assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;
	assign nSDW = (RW | nICOM_ZONE);		
	
	always @(negedge clk)
		$display("68K -> Z80: %H", M68K_DATA);
		
	always @(posedge clk)		
	begin
		if (!nSDZ80CLR)
		begin
			SDD_LATCH_CMD <= 8'b00000000;
		end
		else if (!test_mode && !RW)
		begin
			SDD_LATCH_CMD <= data_in_mux;
		end
	end
endmodule