module _AND_(A, B, Y);
input A, B;
output Y;
assign Y = A & B;
endmodule
module _OR_(A, B, Y);
input A, B;
output Y;
assign Y = A | B;
endmodule
module _XOR_(A, B, Y);
input A, B;
output Y;
assign Y = A ^ B;
endmodule
module _MUX_(A, B, S, Y);
input A, B, S;
output reg Y;
always @* begin
	if (S)
		Y = B;
	else
		Y = A;
end
endmodule
module _DFF_N_(D, Q, C);
input D, C;
output reg Q;
always @(negedge C) begin
	Q <= D;
end
endmodule
module _DFF_P_(D, Q, C);
input D, C;
output reg Q;
always @(posedge C) begin
	Q <= D;
end
endmodule
module _DFF_NN0_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(negedge C or negedge R) begin
	if (R == 0)
		Q <= 0;
	else
		Q <= D;
end
endmodule
module _DFF_NN1_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(negedge C or negedge R) begin
	if (R == 0)
		Q <= 1;
	else
		Q <= D;
end
endmodule
module _DFF_NP0_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(negedge C or posedge R) begin
	if (R == 1)
		Q <= 0;
	else
		Q <= D;
end
endmodule
module _DFF_NP1_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(negedge C or posedge R) begin
	if (R == 1)
		Q <= 1;
	else
		Q <= D;
end
endmodule
module _DFF_PN0_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(posedge C or negedge R) begin
	if (R == 0)
		Q <= 0;
	else
		Q <= D;
end
endmodule
module _DFF_PN1_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(posedge C or negedge R) begin
	if (R == 0)
		Q <= 1;
	else
		Q <= D;
end
endmodule
module _DFF_PP0_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(posedge C or posedge R) begin
	if (R == 1)
		Q <= 0;
	else
		Q <= D;
end
endmodule
module _DFF_PP1_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(posedge C or posedge R) begin
	if (R == 1)
		Q <= 1;
	else
		Q <= D;
end
endmodule
module _NOT_(A, Y);
input A;
output Y;
assign Y = ~A;
endmodule
module _AND_(A, B, Y);
input A, B;
output Y;
assign Y = A & B;
endmodule
module _OR_(A, B, Y);
input A, B;
output Y;
assign Y = A | B;
endmodule
module _XOR_(A, B, Y);
input A, B;
output Y;
assign Y = A ^ B;
endmodule
module _MUX_(A, B, S, Y);
input A, B, S;
output reg Y;
always @* begin
	if (S)
		Y = B;
	else
		Y = A;
end
endmodule
module _DFF_N_(D, Q, C);
input D, C;
output reg Q;
always @(negedge C) begin
	Q <= D;
end
endmodule
module _DFF_P_(D, Q, C);
input D, C;
output reg Q;
always @(posedge C) begin
	Q <= D;
end
endmodule
module _DFF_NN0_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(negedge C or negedge R) begin
	if (R == 0)
		Q <= 0;
	else
		Q <= D;
end
endmodule
module _DFF_NN1_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(negedge C or negedge R) begin
	if (R == 0)
		Q <= 1;
	else
		Q <= D;
end
endmodule
module _DFF_NP0_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(negedge C or posedge R) begin
	if (R == 1)
		Q <= 0;
	else
		Q <= D;
end
endmodule
module _DFF_NP1_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(negedge C or posedge R) begin
	if (R == 1)
		Q <= 1;
	else
		Q <= D;
end
endmodule
module _DFF_PN0_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(posedge C or negedge R) begin
	if (R == 0)
		Q <= 0;
	else
		Q <= D;
end
endmodule
module _DFF_PN1_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(posedge C or negedge R) begin
	if (R == 0)
		Q <= 1;
	else
		Q <= D;
end
endmodule
module _DFF_PP0_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(posedge C or posedge R) begin
	if (R == 1)
		Q <= 0;
	else
		Q <= D;
end
endmodule
module _DFF_PP1_(D, Q, C, R);
input D, C, R;
output reg Q;
always @(posedge C or posedge R) begin
	if (R == 1)
		Q <= 1;
	else
		Q <= D;
end
endmodule
