module k580ww55(
	input clk, input reset, input[1:0] addr, input we_n,
	input[7:0] idata, output reg[7:0] odata,
	input[7:0] ipa, output reg[7:0] opa,
	input[7:0] ipb, output reg[7:0] opb,
	input[7:0] ipc, output reg[7:0] opc);
always begin
	case (addr)
	2'b00: odata = ipa;
	2'b01: odata = ipb;
	2'b10: odata = ipc;
	2'b11: odata = 8'h00;
	endcase
end
always @(posedge clk or posedge reset) begin
	if (reset) begin
		{opa,opb,opc} <= {8'hFF,8'hFF,8'hFF};
	end else
	if (~we_n) begin
		if (addr==2'b00) opa <= idata;
		if (addr==2'b01) opb <= idata;
		if (addr==2'b10) opc <= idata;
		if (addr==2'b11 && ~idata[7]) opc[idata[3:1]] <= idata[0];
	end
end
endmodule
