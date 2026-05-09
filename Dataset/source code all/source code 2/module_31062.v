`timescale 1ns / 1ps
`timescale 1ns / 1ps
module satadd(a,b,mode,y);
 input [11:0] a,b;
 input [1:0] mode;
 output [11:0] y;
 wire aSign, bSign, rSign, cout, vFlag;
 wire [12:0] r;
 add13bit u1 (.a({1'b0,a}), .b({1'b0,b}), .s(r));
 assign vFlag = (~aSign & ~bSign & rSign | aSign & bSign & ~rSign);
 assign cout = r[12];
 assign rSign = r[11];
 assign aSign = a[11];
 assign bSign = b[11];
 reg[11:0] sSatSum;
 always @* begin
 sSatSum = 'h000;
	case(vFlag)
		1'b0:
			sSatSum = r[11:0];
		1'b1:
			begin
				if(aSign == 1 & bSign == 1 & rSign == 0)
					sSatSum = 'h800;
				else
					sSatSum = 'h7FF;
			end
	endcase
 end
 reg[11:0] uSatSum;
 always @* begin
 uSatSum = 'h000;
	case(cout)
		1'b0:
			uSatSum = r[11:0];
		1'b1:
			uSatSum = 'hFFF;
	endcase	
 end
 reg[11:0] result;
 always @* begin
 result = 'h000;
	case(mode)
		2'b00:
			result = uSatSum;
		2'b01:
			result = sSatSum;
		2'b10:
			result = r[11:0];
		2'b11:
			result = r[11:0];
	endcase
 end
 assign y = result;
endmodule
