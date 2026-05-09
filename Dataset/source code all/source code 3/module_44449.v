module DE1_SoCRegTest (CLOCK_50, LEDR, SW, KEY);
	input CLOCK_50;  
	output reg [9:0] LEDR;
	input [9:0] SW;
	input [3:0] KEY;
	wire clk;
	reg [6:0] hold;
	reg regWR;
	wire [1:0] slowClk;
	wire clkControl, rst, enterLow, enterHigh;
	reg [4:0] readAdd0, readAdd1, writeAdd;
	reg [31:0] writeData;
	wire [31:0] readOutput0, readOutput1;
	assign clkControl = SW[8];
	assign enterLow = SW[7];
	assign enterHigh = SW[6];
 	assign rst = SW[9];
	clkSlower counter(slowClk, CLOCK_50, rst);
	registerFile regs(clk, readAdd0, readAdd1, writeAdd, regWR, writeData, readOutput0, readOutput1);
	always @(posedge clk) begin
		if(rst) begin
			hold <= 0;
			regWR <= 1;
			LEDR <= 0;
		end else if(enterLow) begin
			regWR <= 0;
			writeData <= 32'hFFFF0000 + hold[3:0];
			writeAdd <= hold[3:0];
		end else if(enterHigh) begin
			regWR <= 0;
			writeData <= 32'h0000FFF0 + hold[3:0];
			writeAdd <= 5'b10000 + hold[3:0];
		end else begin
			regWR <= 1;
			readAdd0 <= hold[3:0];
			readAdd1 <= 16 + hold[3:0];
			LEDR[7:0] <= KEY[0] ? readOutput1[7:0] : readOutput0[7:0];
		end
		hold <= hold + 1'b1;
	end
	assign clk = clkControl ? slowClk[0] : slowClk[1];
endmodule 
