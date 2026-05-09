module				cog_ram
(
input				clk,
input				ena,
input				w,
input		 [8:0]	a,
input		[31:0]	d,
output reg	[31:0]	q
);
reg [511:0] [31:0]	r;
always @(posedge clk)
begin
	if (ena && w)
		r[a] <= d;
	if (ena)
		q <= r[a];
end
endmodule
