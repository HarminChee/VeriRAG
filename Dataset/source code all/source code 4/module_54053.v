module mul(clk, resetn,
            opA, opB, sa,
            op,
            en,
            squashn,
            shift_result,
            hi, lo);
parameter WIDTH=32;
input clk;
input resetn;
input [WIDTH-1:0] opA;
input [WIDTH-1:0] opB;
input [5-1:0] sa;
input [2:0] op;
input en;
input squashn;
output [WIDTH-1:0] shift_result;
output [WIDTH-1:0] hi;
output [WIDTH-1:0] lo;
wire is_signed,dir, is_mul;
assign is_mul=op[2];      
assign is_signed=op[1];
assign dir=op[0];         
wire dum,dum2,dum3;
wire [WIDTH:0] opB_mux_out;
wire [5-1:0] left_sa;     
reg [WIDTH:0] decoded_sa;
assign opB_mux_out= (is_mul) ? {is_signed&opB[WIDTH-1],opB} : decoded_sa;
    lpm_mult	lpm_mult_component (
	    .sclr	(~resetn),
	    .ce		(1'b1),
	    .clk	(clk),
	    .a		({is_signed&opA[WIDTH-1],opA}),
	    .b		(opB_mux_out),
	    .p		({dum2,dum,hi,lo})
    );
wire shift_result_mux;
register shiftmux_reg((dir && |sa),clk,resetn,1'b1,shift_result_mux);
  defparam shiftmux_reg.WIDTH=1;
assign shift_result= (shift_result_mux) ? hi : lo;
assign {dum3, left_sa}= (dir) ? 32-sa : {1'b0,sa};
always@(left_sa or dir)
begin
  decoded_sa=0;
  case(left_sa)
    0: decoded_sa[0]=1;
    1: decoded_sa[1]=1;
    2: decoded_sa[2]=1;
    3: decoded_sa[3]=1;
    4: decoded_sa[4]=1;
    5: decoded_sa[5]=1;
    6: decoded_sa[6]=1;
    7: decoded_sa[7]=1;
    8: decoded_sa[8]=1;
    9: decoded_sa[9]=1;
    10: decoded_sa[10]=1;
    11: decoded_sa[11]=1;
    12: decoded_sa[12]=1;
    13: decoded_sa[13]=1;
    14: decoded_sa[14]=1;
    15: decoded_sa[15]=1;
    16: decoded_sa[16]=1;
    17: decoded_sa[17]=1;
    18: decoded_sa[18]=1;
    19: decoded_sa[19]=1;
    20: decoded_sa[20]=1;
    21: decoded_sa[21]=1;
    22: decoded_sa[22]=1;
    23: decoded_sa[23]=1;
    24: decoded_sa[24]=1;
    25: decoded_sa[25]=1;
    26: decoded_sa[26]=1;
    27: decoded_sa[27]=1;
    28: decoded_sa[28]=1;
    29: decoded_sa[29]=1;
    30: decoded_sa[30]=1;
    31: decoded_sa[31]=1;
  endcase
end
endmodule
