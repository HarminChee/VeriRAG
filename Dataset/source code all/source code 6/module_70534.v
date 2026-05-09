`define BITS 32         
`define BITS 32         
module 	syn7(clock, 
		in1_reg,
		in2_reg,
		in3_reg, 
		in4_reg,
		in5_reg,
		out_1,
		out_2,
		out_3,
		out_4
);
input	clock;
input [`BITS-1:0] in1_reg;
input [`BITS-1:0] in2_reg;
input [`BITS-1:0] in3_reg;
input [`BITS-1:0] in4_reg;
input [`BITS-1:0] in5_reg;
reg [`BITS-1:0] in1;
reg [`BITS-1:0] in2;
reg [`BITS-1:0] in3;
reg [`BITS-1:0] in4;
reg [`BITS-1:0] in5;
output [`BITS-1:0] out_1;
output [`BITS-1:0] out_2;
output [`BITS-1:0] out_3;
output [`BITS-1:0] out_4;
wire [`BITS-1:0] le5;
wire [`BITS-1:0] le6;
wire [`BITS-1:0] le7;
wire [`BITS-1:0] le8;
wire [`BITS-1:0] le9;
wire [`BITS-1:0] le10;
wire [`BITS-1:0] le11;
wire [`BITS-1:0] le12;
wire [`BITS-1:0] le13;
wire [`BITS-1:0] le14;
wire [`BITS-1:0] le15;
wire [`BITS-1:0] le16;
wire [`BITS-1:0] le17;
wire [`BITS-1:0] le18;
wire [`BITS-1:0] le19;
wire [`BITS-1:0] le20;
wire [`BITS-1:0] le21;
wire [`BITS-1:0] le22;
wire [`BITS-1:0] le23;
wire [`BITS-1:0] le24;
wire [`BITS-1:0] le25;
wire [`BITS-1:0] le26;
wire [`BITS-1:0] le27;
wire [`BITS-1:0] le28;
wire [`BITS-1:0] le29;
wire [`BITS-1:0] le30;
wire [`BITS-1:0] le31;
wire [`BITS-1:0] le32;
wire [`BITS-1:0] le33;
wire [`BITS-1:0] le34;
wire [`BITS-1:0] le35;
wire [`BITS-1:0] le36;
wire [`BITS-1:0] le37;
wire [`BITS-1:0] le38;
wire [`BITS-1:0] le39;
wire [`BITS-1:0] le40;
wire [`BITS-1:0] le41;
wire [`BITS-1:0] le42;
wire [`BITS-1:0] le43;
wire [`BITS-1:0] le44;
wire [`BITS-1:0] le45;
wire [`BITS-1:0] le46;
wire [`BITS-1:0] le47;
wire [`BITS-1:0] le48;
wire [`BITS-1:0] le49;
wire [`BITS-1:0] le50;
wire [`BITS-1:0] le51;
wire [`BITS-1:0] le52;
wire [`BITS-1:0] le53;
wire [`BITS-1:0] le54;
wire [7:0] le5_control;
fpu_add le5_add
( 
	.clk(clock), 
	.opa(in1), 
	.opb(in2), 
	.out(le5), 
	.control(le5_control) 
);
wire [7:0] le6_control;
fpu_mul le6_mul
( 
	.clk(clock), 
	.opa(in3), 
	.opb(in4), 
	.out(le6), 
	.control(le6_control) 
);
wire [7:0] le7_control;
fpu_add le7_add
( 
	.clk(clock), 
	.opa(in3), 
	.opb(in1), 
	.out(le7), 
	.control(le7_control) 
);
wire [7:0] le8_control;
fpu_mul le8_mul
( 
	.clk(clock), 
	.opa(in5), 
	.opb(in4), 
	.out(le8), 
	.control(le8_control) 
);
wire [7:0] le9_control;
fpu_add le9_add
( 
	.clk(clock), 
	.opa(le5), 
	.opb(le6), 
	.out(le9), 
	.control(le9_control) 
);
wire [7:0] le10_control;
fpu_mul le10_mul
( 
	.clk(clock), 
	.opa(le7), 
	.opb(le8), 
	.out(le10), 
	.control(le10_control) 
);
wire [7:0] le11_control;
fpu_add le11_add
(
    .clk(clock),
    .opa(le9),
    .opb(le10),
    .out(le11),
    .control(le11_control)
);
wire [7:0] le12_control;
fpu_mul le12_mul
(
    .clk(clock),
    .opa(le9),
    .opb(le10),
    .out(le12),
    .control(le12_control)
);
wire [7:0] le13_control;
fpu_add le13_add
(
    .clk(clock),
    .opa(le5),
    .opb(le6),
    .out(le13),
    .control(le13_control)
);
wire [7:0] le14_control;
fpu_mul le14_mul
(
    .clk(clock),
    .opa(le7),
    .opb(le8),
    .out(le14),
    .control(le14_control)
);
wire [7:0] le15_control;
fpu_add le15_add
(
    .clk(clock),
    .opa(le13),
    .opb(le14),
    .out(le15),
    .control(le15_control)
);
wire [7:0] le16_control;
fpu_mul le16_mul
(
    .clk(clock),
    .opa(le9),
    .opb(le13),
    .out(le16),
    .control(le16_control)
);
wire [7:0] le17_control;
fpu_add le17_add
(
    .clk(clock),
    .opa(le13),
    .opb(le14),
    .out(le17),
    .control(le17_control)
);
wire [7:0] le18_control;
fpu_mul le18_mul
(
    .clk(clock),
    .opa(le10),
    .opb(le14),
    .out(le18),
    .control(le18_control)
);
wire [7:0] le19_control;
fpu_add le19_add
(
    .clk(clock),
    .opa(le15),
    .opb(le17),
    .out(le19),
    .control(le19_control)
);
wire [7:0] le20_control;
fpu_mul le20_mul
(
    .clk(clock),
    .opa(le20),
    .opb(le15),
    .out(le20),
    .control(le20_control)
);
wire [7:0] le21_control;
fpu_add le21_add
(
    .clk(clock),
    .opa(le12),
    .opb(le18),
    .out(le21),
    .control(le21_control)
);
wire [7:0] le22_control;
fpu_mul le22_mul
(
    .clk(clock),
    .opa(le19),
    .opb(le20),
    .out(le22),
    .control(le22_control)
);
wire [7:0] le23_control;
fpu_add le23_add
(
    .clk(clock),
    .opa(le20),
    .opb(le21),
    .out(le23),
    .control(le23_control)
);
wire [7:0] le24_control;
fpu_mul le24_mul
(
    .clk(clock),
    .opa(le19),
    .opb(le21),
    .out(le24),
    .control(le24_control)
);
wire [7:0] le25_control;
fpu_add le25_add
(
    .clk(clock),
    .opa(le22),
    .opb(le23),
    .out(le25),
    .control(le25_control)
);
wire [7:0] le26_control;
fpu_mul le26_mul
(
    .clk(clock),
    .opa(le51),
    .opb(le52),
    .out(le26),
    .control(le26_control)
);
wire [7:0] le27_control;
fpu_add le27_add
(
    .clk(clock),
    .opa(le52),
    .opb(le54),
    .out(le27),
    .control(le27_control)
);
wire [7:0] le28_control;
fpu_mul le28_mul
(
    .clk(clock),
    .opa(le53),
    .opb(le54),
    .out(le28),
    .control(le28_control)
);
wire [7:0] le29_control;
fpu_add le29_add
(
    .clk(clock),
    .opa(le26),
    .opb(le27),
    .out(le29),
    .control(le29_control)
);
wire [7:0] le30_control;
fpu_mul le30_mul
(
    .clk(clock),
    .opa(le26),
    .opb(le28),
    .out(le30),
    .control(le30_control)
);
wire [7:0] le31_control;
fpu_add le31_add
(
    .clk(clock),
    .opa(le27),
    .opb(le28),
    .out(le31),
    .control(le31_control)
);
wire [7:0] le32_control;
fpu_mul le32_mul
(
    .clk(clock),
    .opa(le26),
    .opb(le28),
    .out(le32),
    .control(le32_control)
);
wire [7:0] le33_control;
fpu_add le33_add
(
    .clk(clock),
    .opa(le27),
    .opb(le28),
    .out(le33),
    .control(le33_control)
);
wire [7:0] le34_control;
fpu_mul le34_mul
(
    .clk(clock),
    .opa(le30),
    .opb(le32),
    .out(le34),
    .control(le34_control)
);
wire [7:0] le35_control;
fpu_add le35_add
(
    .clk(clock),
    .opa(le29),
    .opb(le31),
    .out(le35),
    .control(le35_control)
);
wire [7:0] le36_control;
fpu_mul le36_mul
(
    .clk(clock),
    .opa(le31),
    .opb(le33),
    .out(le36),
    .control(le36_control)
);
wire [7:0] le37_control;
fpu_add le37_add
(
    .clk(clock),
    .opa(le32),
    .opb(le33),
    .out(le37),
    .control(le37_control)
);
wire [7:0] le38_control;
fpu_mul le38_mul
(
    .clk(clock),
    .opa(le34),
    .opb(le35),
    .out(le38),
    .control(le38_control)
);
wire [7:0] le39_control;
fpu_add le39_add
(
    .clk(clock),
    .opa(le34),
    .opb(le37),
    .out(le39),
    .control(le39_control)
);
wire [7:0] le40_control;
fpu_mul le40_mul
(
    .clk(clock),
    .opa(le35),
    .opb(le36),
    .out(le40),
    .control(le40_control)
);
wire [7:0] le41_control;
fpu_add le41_add
(
    .clk(clock),
    .opa(le36),
    .opb(le37),
    .out(le41),
    .control(le41_control)
);
wire [7:0] le42_control;
fpu_mul le42_mul
(
    .clk(clock),
    .opa(le11),
    .opb(le16),
    .out(le42),
    .control(le42_control)
);
wire [7:0] le43_control;
fpu_add le43_add
(
    .clk(clock),
    .opa(le19),
    .opb(le42),
    .out(le43),
    .control(le43_control)
);
wire [7:0] le44_control;
fpu_mul le44_mul
(
    .clk(clock),
    .opa(le21),
    .opb(le42),
    .out(le44),
    .control(le44_control)
);
wire [7:0] le45_control;
fpu_add le45_add
(
    .clk(clock),
    .opa(le22),
    .opb(le43),
    .out(le45),
    .control(le45_control)
);
wire [7:0] le46_control;
fpu_mul le46_mul
(
    .clk(clock),
    .opa(le24),
    .opb(le43),
    .out(le46),
    .control(le46_control)
);
wire [7:0] le47_control;
fpu_add le47_add
(
    .clk(clock),
    .opa(le24),
    .opb(le44),
    .out(le47),
    .control(le47_control)
);
wire [7:0] le48_control;
fpu_mul le48_mul
(
    .clk(clock),
    .opa(le45),
    .opb(le46),
    .out(le48),
    .control(le48_control)
);
wire [7:0] le49_control;
fpu_add le49_add
(
    .clk(clock),
    .opa(le45),
    .opb(le47),
    .out(le49),
    .control(le49_control)
);
wire [7:0] le50_control;
fpu_mul le50_mul
(
    .clk(clock),
    .opa(le25),
    .opb(le45),
    .out(le50),
    .control(le50_control)
);
wire [7:0] le51_control;
fpu_add le51_add
(
    .clk(clock),
    .opa(le48),
    .opb(le50),
    .out(le51),
    .control(le51_control)
);
wire [7:0] le52_control;
fpu_mul le52_mul
(
    .clk(clock),
    .opa(le49),
    .opb(le50),
    .out(le52),
    .control(le52_control)
);
wire [7:0] le53_control;
fpu_add le53_add
(
    .clk(clock),
    .opa(le48),
    .opb(le50),
    .out(le53),
    .control(le53_control)
);
wire [7:0] le54_control;
fpu_mul le54_mul
(
    .clk(clock),
    .opa(le49),
    .opb(le50),
    .out(le54),
    .control(le54_control)
);
assign	out_1 = le38;
assign 	out_2 = le39;
assign	out_3 = le40;
assign	out_4 = le41;
always @(posedge clock)
begin
	in1 <= in1_reg;
	in2 <= in2_reg;
	in3 <= in3_reg;
	in4 <= in4_reg;
	in5 <= in5_reg;
end
endmodule
