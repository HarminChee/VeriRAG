`default_nettype none
`default_nettype none
module dsp_multioption_counter (countClock, count, reset, countout);
	parameter clip_count = 1; 
	parameter clip_reset = 1;
	input countClock;
	input count;
	input reset;
	output [31:0] countout;
	wire [47:0] DSPOUT;
	wire CARRYOUT;
	wire [1:0] OPMODE_X = 2'b11; 
	wire [1:0] OPMODE_Z = 2'b10; 
	wire final_count;
	wire final_reset;
	generate
		if (clip_count == 0) assign final_count = count; else
		if (clip_count == 1)
		begin
			wire clipped_count;
			signal_clipper countclip (	.sig(count),	.CLK(countClock),	.clipped_sig(clipped_count));
			assign final_count = clipped_count;
		end else	begin 
			reg piped_count;
			always@(posedge countClock) 
			begin
				piped_count <= count;
			end
			assign final_count = piped_count;
		end
		if (clip_reset == 0) assign final_reset = reset; else
		begin
			wire clipped_reset;
			signal_clipper resetclip (	.sig(reset),	.CLK(countClock),	.clipped_sig(clipped_reset));
			assign final_reset = clipped_reset;
		end
	endgenerate
	DSP48A1 #(
		.A0REG ( 0 ),
		.A1REG ( 0 ),
		.B0REG ( 0 ),
		.B1REG ( 0 ),
		.CARRYINREG ( 0 ),
		.CARRYINSEL ( "OPMODE5" ), 
		.CREG ( 0 ),
		.DREG ( 0 ),
		.MREG ( 0 ),
		.OPMODEREG ( 0 ),
		.PREG ( 1 ),
		.RSTTYPE ( "SYNC" ),
		.CARRYOUTREG ( 0 ))
	DSP48A1_SLICE (
		.CLK(countClock),
		.A(18'b0),
		.B(18'b10_00000000_00000000),	
		.C(48'b0),
		.D(18'b0),
		.CEA(1'b0),
		.CEB(1'b0),
		.CEC(1'b0),
		.CED(1'b0),
		.CEM(1'b0),
		.CEP(final_count),
		.CEOPMODE(1'b0),
		.CECARRYIN(1'b0),
		.RSTA(1'b0),
		.RSTB(1'b0),
		.RSTC(1'b0),
		.RSTD(1'b0),
		.RSTM(1'b0),
		.RSTP(final_reset),
		.RSTOPMODE(1'b0),
		.RSTCARRYIN(1'b0),
		.CARRYIN(1'b0),
		.PCIN(48'b0),
		.CARRYOUTF(CARRYOUT),	
		.CARRYOUT(),	
		.BCOUT(),		
		.PCOUT(),		
		.M(),				
		.P(DSPOUT),
		.OPMODE({4'b0000,OPMODE_Z,OPMODE_X})
		);
	reg overflow;
	always@(posedge countClock) 
	begin
		if (final_reset == 1'b1) overflow <= 0;
		else overflow <= overflow || CARRYOUT;
	end			
	assign countout[30:0] = DSPOUT[47:17];
   assign countout[31] = overflow;
endmodule
