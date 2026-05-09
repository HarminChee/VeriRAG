`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ClockManager(
	 (* buffer_type = "ibufg" *) input CLK_IN,
	 input RESET_IN,
	 output CLK_MAIN,
	 output reg RESET
	);
	parameter DELAY = 4;
	reg [DELAY - 1:0] CNT_SLOW;
	reg CLK_SLOW;
	always @ (posedge CLK_IN)
		if(RESET_IN)
			CNT_SLOW <= 0;
		else
			CNT_SLOW <= CNT_SLOW + 1;
	always @ (posedge CLK_IN)
		if(RESET_IN)
		begin
			RESET <= 1'b1;
			CLK_SLOW <= 1'b0;
		end
		else if(CNT_SLOW == (1 << DELAY) - 1)
		begin
			RESET <= 1'b0;
			CLK_SLOW <= ~CLK_SLOW;
		end
	assign CLK_MAIN = CLK_IN;
endmodule
