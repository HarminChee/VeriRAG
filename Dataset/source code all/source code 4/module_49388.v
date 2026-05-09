module tmu2_divider17(
	input sys_clk,
	input sys_rst,
	input start,
	input [16:0] dividend,
	input [16:0] divisor,
	output ready,
	output [16:0] quotient,
	output [16:0] remainder
);
reg [33:0] qr;
assign remainder = qr[33:17];
assign quotient = qr[16:0];
reg [4:0] counter;
assign ready = (counter == 5'd0);
reg [16:0] divisor_r;
wire [17:0] diff = qr[33:16] - {1'b0, divisor_r};
always @(posedge sys_clk) begin
	if(sys_rst)
		counter = 5'd0;
	else begin
		if(start) begin
			counter = 5'd17;
			qr = {17'd0, dividend};
			divisor_r = divisor;
		end else begin
			if(~ready) begin
				if(diff[17])
					qr = {qr[32:0], 1'b0};
				else
					qr = {diff[16:0], qr[15:0], 1'b1};
				counter = counter - 5'd1;
			end
		end
	end
end
endmodule
