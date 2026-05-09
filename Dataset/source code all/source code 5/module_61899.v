`include "timescale.v"
`include "or1200_defines.v"
`include "timescale.v"
`include "or1200_defines.v"
module or1200_operandmuxes(
	clk, rst,
	id_freeze, ex_freeze, rf_dataa, rf_datab, ex_forw, wb_forw,
	simm, sel_a, sel_b, operand_a, operand_b, muxed_a, muxed_b
);
parameter width = `OR1200_OPERAND_WIDTH;
input				clk;
input				rst;
input				id_freeze;
input				ex_freeze;
input	[width-1:0]		rf_dataa;
input	[width-1:0]		rf_datab;
input	[width-1:0]		ex_forw;
input	[width-1:0]		wb_forw;
input	[width-1:0]		simm;
input	[`OR1200_SEL_WIDTH-1:0]	sel_a;
input	[`OR1200_SEL_WIDTH-1:0]	sel_b;
output	[width-1:0]		operand_a;
output	[width-1:0]		operand_b;
output	[width-1:0]		muxed_a;
output	[width-1:0]		muxed_b;
reg	[width-1:0]		operand_a;
reg	[width-1:0]		operand_b;
reg	[width-1:0]		muxed_a;
reg	[width-1:0]		muxed_b;
reg				saved_a;
reg				saved_b;
always @(posedge clk or `OR1200_RST_EVENT rst) begin
	if (rst == `OR1200_RST_VALUE) begin
		operand_a <=  32'd0;
		saved_a <=  1'b0;
	end else if (!ex_freeze && id_freeze && !saved_a) begin
		operand_a <=  muxed_a;
		saved_a <=  1'b1;
	end else if (!ex_freeze && !saved_a) begin
		operand_a <=  muxed_a;
	end else if (!ex_freeze && !id_freeze)
		saved_a <=  1'b0;
end
always @(posedge clk or `OR1200_RST_EVENT rst) begin
	if (rst == `OR1200_RST_VALUE) begin
		operand_b <=  32'd0;
		saved_b <=  1'b0;
	end else if (!ex_freeze && id_freeze && !saved_b) begin
		operand_b <=  muxed_b;
		saved_b <=  1'b1;
	end else if (!ex_freeze && !saved_b) begin
		operand_b <=  muxed_b;
	end else if (!ex_freeze && !id_freeze)
		saved_b <=  1'b0;
end
always @(ex_forw or wb_forw or rf_dataa or sel_a) begin
`ifdef OR1200_ADDITIONAL_SYNOPSYS_DIRECTIVES
	casez (sel_a)	
`else
	casez (sel_a)	
`endif
		`OR1200_SEL_EX_FORW:
			muxed_a = ex_forw;
		`OR1200_SEL_WB_FORW:
			muxed_a = wb_forw;
		default:
			muxed_a = rf_dataa;
	endcase
end
always @(simm or ex_forw or wb_forw or rf_datab or sel_b) begin
`ifdef OR1200_ADDITIONAL_SYNOPSYS_DIRECTIVES
	casez (sel_b)	
`else
	casez (sel_b)	
`endif
		`OR1200_SEL_IMM:
			muxed_b = simm;
		`OR1200_SEL_EX_FORW:
			muxed_b = ex_forw;
		`OR1200_SEL_WB_FORW:
			muxed_b = wb_forw;
		default:
			muxed_b = rf_datab;
	endcase
end
endmodule
