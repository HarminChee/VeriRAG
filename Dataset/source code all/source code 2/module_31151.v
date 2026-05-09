module mux #(parameter WIDTH=8) (
								input clk,
								input rst,  
								input [WIDTH-1:0] a, 
								input [WIDTH-1:0] b, 
								output reg [WIDTH-1:0] c);
wire [WIDTH-1:0] c_wire;
always @(posedge clk) begin
	if (rst) begin
		c <= 0;
	end
	else begin
		c <= c_wire;
	end
end
assign c_wire = (a<b) ? a : b ;
endmodule
