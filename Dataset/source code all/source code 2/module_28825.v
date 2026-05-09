`timescale 1ns / 1ps
`timescale 1ns / 1ps
module jt51_noise(
	input			rst,
	input			clk,
	input	[4:0]	nfrq,
	input	[9:0]	eg,
	input			op31_no,
	output	reg [10:0]	out
);
reg 		base;
reg [3:0]	cnt;
always @(posedge clk)
	if( rst ) begin
		cnt  <= 5'b0;
	end
	else begin
		if( op31_no ) begin
			if ( &cnt ) begin				
				cnt  <= nfrq[4:1]; 
			end
			else cnt <= cnt + 1'b1;
			base <= &cnt;
		end
		else base <= 1'b0;
	end
wire rnd_sign;
always @(posedge clk)
	if( op31_no )
		out <= { rnd_sign, {10{~rnd_sign}}^eg };
jt51_noise_lfsr #(.init(90)) u_lfsr (
	.rst	( rst ),
	.clk	( clk ),
	.base	( base ),
	.out	( rnd_sign )
);
endmodule
