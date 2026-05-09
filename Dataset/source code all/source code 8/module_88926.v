module f2_test(input [3:0] in, input [1:0] select, output reg out);
always @( in or select)
    case (select)
	    0: out = in[0];
	    1: out = in[1];
	    2: out = in[2];
	    3: out = in[3];
	endcase
endmodule	
module f3_test(input [7:0] in, input [2:0] select, output reg out);
always @( in or select)
    case (select)
	    0: out = in[0];
	    1: out = in[1];
	    2: out = in[2];
	    3: out = in[3];
	    4: out = in[4];
	    5: out = in[5];
	    6: out = in[6];
	    7: out = in[7];
	endcase
endmodule
module f4_test(input [7:0] in, output out);
assign out = ~^in;
endmodule
module f5_test(input in, output out);
assign out = ~in;
endmodule
module f6_test(input in, output out);
assign out = in;
endmodule
module f7_test(output out);
assign out = 1'b0;
endmodule
module f8_test(input in, output out);
assign out = ~in;
endmodule
module f1_test(input [1:0] in, input select, output reg out);
always @( in or select)
    case (select)
	    0: out = in[0];
	    1: out = in[1];
	endcase
endmodule	
module f2_test(input [3:0] in, input [1:0] select, output reg out);
always @( in or select)
    case (select)
	    0: out = in[0];
	    1: out = in[1];
	    2: out = in[2];
	    3: out = in[3];
	endcase
endmodule	
module f3_test(input [7:0] in, input [2:0] select, output reg out);
always @( in or select)
    case (select)
	    0: out = in[0];
	    1: out = in[1];
	    2: out = in[2];
	    3: out = in[3];
	    4: out = in[4];
	    5: out = in[5];
	    6: out = in[6];
	    7: out = in[7];
	endcase
endmodule
module f4_test(input [7:0] in, output out);
assign out = ~^in;
endmodule
module f5_test(input in, output out);
assign out = ~in;
endmodule
module f6_test(input in, output out);
assign out = in;
endmodule
module f7_test(output out);
assign out = 1'b0;
endmodule
module f8_test(input in, output out);
assign out = ~in;
endmodule
