module lp20khz_1MSa_iir_filter(input clk, input [7:0] adc_d, output rdy, output [7:0] out);
	reg [23:0] cnt = 1;
	assign rdy = cnt[0];
	always @(posedge clk)
		cnt <= {cnt[22:0], cnt[23]};		
	reg [7:0] x0 = 0;
	reg [7:0] x1 = 0;
	reg [16:0] y0 = 0;
	reg [16:0] y1 = 0;
	always @(posedge clk)
	begin
		if (rdy)
		begin
			x0 <= x1;
			x1 <= adc_d;
			y0 <= y1;
			y1 <=
				x0 + {x1, 1'b0} + adc_d + 436
				- ((y0 >> 7) + (y0 >> 6) + (y0 >> 4) + (y0 >> 2) + (y0 >> 1)) 
				+ ((y1 >> 8) + (y1 >> 7) + (y1 >> 4) + (y1 >> 2) + (y1 >> 1) + y1);
		end
	end
	assign out = y1[16:9];
endmodule
