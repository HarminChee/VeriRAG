`timescale 1ns/1ns

module c1_regs(
	input nICOM_ZONE,
	input RW, // 1 for Read, 0 for Write (from 68k perspective)
	inout [15:8] M68K_DATA,
	inout [7:0] SDD,
	input nSDZ80R, // Z80 Read Strobe (active low)
	input nSDZ80W, // Z80 Write Strobe (active low)
	input nSDZ80CLR, // Z80 Clear (active low)
	output nSDW // 68k Write Strobe to Z80 (active low)
);
	reg [7:0] SDD_LATCH_CMD; // Data written by 68k, read by Z80
	reg [7:0] SDD_LATCH_REP; // Data written by Z80, read by 68k

	// Z80 Read from Command Latch: Drive SDD when nSDZ80R is low
	assign SDD = (~nSDZ80R & nSDZ80W & ~nICOM_ZONE) ? SDD_LATCH_CMD : 8'bzzzzzzzz;

	// Z80 Write to Reply Latch: Latch SDD on the falling edge of nSDZ80W
	// Assuming Z80 holds data valid before nSDZ80W goes low
	always @(negedge nSDZ80W or negedge nSDZ80CLR)
	begin
	    if (!nSDZ80CLR) begin
	        SDD_LATCH_REP <= 8'b00000000;
	    end else if (!nICOM_ZONE) begin // Ensure write happens only when zone is active
		    $display("Z80 -> 68K: %H", SDD);
		    SDD_LATCH_REP <= SDD; // Latch data from Z80
		end
	end

	// 68k Read from Reply Latch: Drive M68K_DATA when 68k reads
	assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP : 8'bzzzzzzzz;

	// Generate 68k Write Strobe for Z80 (active low)
	// Active when 68k writes (RW=0) and zone is selected (nICOM_ZONE=0)
	assign nSDW = (RW | nICOM_ZONE);

	// 68k Write to Command Latch: Latch M68K_DATA on falling edge of nSDW
	// or asynchronously clear
	always @(negedge nSDW or negedge nSDZ80CLR)
	begin
		if (!nSDZ80CLR)
		begin
			SDD_LATCH_CMD <= 8'b00000000;
		end
		// Check if it's a write cycle (nSDW just went low)
		// nSDW goes low only when RW=0 and nICOM_ZONE=0
		else if (!RW && !nICOM_ZONE) // Explicitly check conditions for write
		begin
			$display("68K -> Z80: %H", M68K_DATA);
			SDD_LATCH_CMD <= M68K_DATA; // Latch data from 68k
		end
	end

endmodule