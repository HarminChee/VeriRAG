module CC_DLatch(en, d, q);
  parameter WIDTH=1;
  input en;
  input [WIDTH-1:0] d;
  output [WIDTH-1:0] q;
  wire [WIDTH-1:0] reg_out;
  CC_DFlipFlop #(.WIDTH(WIDTH)) r (.clk(~en), .en(1'b1), .reset(1'b0), .d(d), .q(reg_out));
  assign q = en ? d : reg_out;
endmodule

module CC_Bidir(sel_in, io, in, out);
  parameter WIDTH=1;
  input sel_in;
  inout [WIDTH-1:0] io;
  output [WIDTH-1:0] in;
  input [WIDTH-1:0] out;
  assign in = sel_in ? io : {WIDTH{1'bz}};
  assign io = sel_in ? {WIDTH{1'bz}} : out;
endmodule

module CC_MuxReg(sel, clk, en, in_a, in_b, out);
  parameter WIDTH=8;
  input sel;
  input clk;
  input en;
  input [WIDTH-1:0] in_a;
  input [WIDTH-1:0] in_b;
  output [WIDTH-1:0] out;
  wire [WIDTH-1:0] out_a;
  wire [WIDTH-1:0] out_b;
  CC_DFlipFlop #(.WIDTH(WIDTH)) reg_a (.clk(clk), .en(en), .reset(1'b0), .d(in_a), .q(out_a));
  CC_DFlipFlop #(.WIDTH(WIDTH)) reg_b (.clk(clk), .en(en), .reset(1'b0), .d(in_b), .q(out_b));
  assign out = sel ? out_a : out_b;
endmodule

module CC_Decoder(in, out);
  parameter IN_WIDTH=8;
  parameter OUT_WIDTH=(1 << IN_WIDTH);
  input [IN_WIDTH-1:0] in;
  output [OUT_WIDTH-1:0] out;
  genvar i;
  generate
    for (i = 0; i < OUT_WIDTH; i = i + 1)
    begin: SELECT
      assign out[i] = (i == in) ? 1'b1 : 1'b0;
    end
  endgenerate
endmodule

module CC_DFlipFlop(clk, en, reset, d, q);
  parameter WIDTH=1;
  input clk;
  input en;
  input reset;
  input [WIDTH-1:0] d;
  output reg [WIDTH-1:0] q;
  always @ (posedge clk or posedge reset)
    if (reset)
      q <= {WIDTH{1'b0}};
    else if (en)
      q <= d;
endmodule

module CC_Delay(clk, reset, d, q);
  parameter WIDTH=1;
  parameter DELAY=1;
  input clk;
  input reset;
  input [WIDTH-1:0] d;
  output [WIDTH-1:0] q;
  wire [(WIDTH*DELAY)-1:0] reg_inputs;
  wire [(WIDTH*DELAY)-1:0] reg_outputs;
  genvar i;
  generate
    for (i = 0; i < DELAY; i = i + 1)
    begin: DFF_CHAIN
      CC_DFlipFlop #(.WIDTH(WIDTH)) chain_reg (.clk(clk),
                                               .en(1'b1),
                                               .reset(reset),
                                               .d(i == 0 ? d : reg_outputs[(i*WIDTH)-1:(i-1)*WIDTH]),
                                               .q(reg_outputs[(i+1)*WIDTH-1:i*WIDTH]));
    end
  endgenerate
  assign q = reg_outputs[(DELAY*WIDTH)-1:(DELAY-1)*WIDTH];
endmodule