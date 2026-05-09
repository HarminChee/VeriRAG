module				cog_ram
(
input				clk,
input				bclk,
input				ena,
input				bena,
input				w,
input				bw,
input		 [8:0]	a,
input		 [8:0]		ba,
input		[31:0]	d,
input		[31:0]		bd,
output reg	[31:0]	q,
output reg	[31:0]		bq
);
reg [511:0] [31:0]	r;
always @(posedge clk)
begin
	if (ena && w)
		r[a] <= d;
	if (ena)
		q <= r[a];
end
always @(posedge bclk)
begin
	if(bena && bw)
		r[ba] <= bd;
	if(bena)
		bq <= r[ba];
end
endmodule
