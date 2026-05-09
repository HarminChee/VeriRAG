`timescale 1ns / 1ps
module clkgen_corrected_clk(
	input sys_clk_i,
	input sys_rst_i,
	output wb_clk_o,
	output wb_clk2x_o,
	output wb_rst_o
);
wire sys_clk_ibufg;
IBUFG sys_clk_in_ibufg(
	.I(sys_clk_i),
	.O(sys_clk_ibufg)
);
assign wb_clk_o = sys_clk_ibufg;
assign wb_clk2x_o = sys_clk_ibufg;
reg [15:0] wb_rst_shr;
always @(posedge sys_clk_ibufg or posedge sys_rst_i)
begin
	if(sys_rst_i)
		wb_rst_shr <= 16'hffff;
	else
		wb_rst_shr <= {wb_rst_shr[14:0], 1'b0};
end
assign wb_rst_o = wb_rst_shr[15];
endmodule