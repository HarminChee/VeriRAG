`timescale 1ns / 1ps
`timescale 1ns / 1ps
module boardSynchroniser3 #(parameter CNT_WIDTH = 2)
	(
    input clk,
	 input synch_en,
    input toggle_en,
    input [CNT_WIDTH-1:0] cnt_n,
    input [CNT_WIDTH-1:0] cnt_m,
	 input syncIn,
	 (* IOB = "true" *) output reg syncOut = 1'b0,
	 (* equivalent_register_removal = "no" *) output reg synchroStatusInt = 1'b0, synchroStatusExt = 1'b0
    );
reg tog_a = 1'b0, tog_b = 1'b0, toggle = 1'b0;
reg [CNT_WIDTH-1:0] ctr = {CNT_WIDTH{1'b0}};
reg synch = 1'b0;
(* IOB = "true", ASYNC_REG = "TRUE" *) reg syncIn_a = 1'b0;
(* ASYNC_REG = "TRUE" *) reg syncIn_b = 1'b0;
reg synch_en_a = 1'b0, synch_en_b = 1'b0;
always @(posedge clk) begin
	synch_en_a <= synch_en;
	synch_en_b <= synch_en_a;
	syncIn_a <= syncIn;
	syncIn_b <= syncIn_a;
	tog_a <= toggle_en;
	tog_b <= tog_a;
	toggle <= tog_a & ~tog_b;
	if (toggle) begin
		ctr <= (ctr == cnt_m) ? {CNT_WIDTH{1'b0}} : ctr + 1'b1;
		if (synch_en_b) begin
			if (ctr == cnt_m) synch <= 1'b1;
			else if (ctr == cnt_n) synch <= 1'b0;
			else synch <= synch;
		end else synch <= 1'b0;
	end else begin
		ctr <= ctr;
		synch <= synch;
	end		
	synchroStatusInt <= synch;
	synchroStatusExt <= syncIn_b;
	syncOut <= ~synch; 
end 
endmodule
