// File: 1_corrected_acn.v

module CC_DFlipFlop(clk, en, reset, d, q);
  parameter WIDTH=1;
  input clk;
  input en;
  input reset; // Asynchronous reset input
  input [WIDTH-1:0] d;
  output reg [WIDTH-1:0] q;

  always @ (posedge clk or posedge reset)
  if (reset)
    q <= {WIDTH{1'b0}}; // Reset to 0
  else if (en)
    q <= d;
endmodule

module CC_DLatch(en, d, q, reset); // Added reset input
  parameter WIDTH=1;
  input en;
  input [WIDTH-1:0] d;
  input reset; // Added reset input port
  output [WIDTH-1:0] q;
  wire [WIDTH-1:0] reg_out;

  // Pass the reset signal to the DFlipFlop instance
  // Note: Using ~en as clock is generally bad for DFT (Gated Clock),
  // but the specific request was to fix ACNCPI.
  CC_DFlipFlop #(WIDTH) r(
    .clk(~en),
    .en(1'b1),
    .reset(reset), // Connect the reset input
    .d(d),
    .q(reg_out)
  );

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

module CC_MuxReg(sel, clk, en, reset, in_a, in_b, out); // Added reset input
  parameter WIDTH=8;
  input sel;
  input clk;
  input en;
  input reset; // Added reset input port
  input [WIDTH-1:0] in_a;
  input [WIDTH-1:0] in_b;
  output [WIDTH-1:0] out;
  wire [WIDTH-1:0] out_a;
  wire [WIDTH-1:0] out_b;

  // Connect the reset input to both DFlipFlop instances
  CC_DFlipFlop #(WIDTH) reg_a(
    .clk(clk),
    .en(en),
    .reset(reset), // Connect reset
    .d(in_a),
    .q(out_a)
   );
  CC_DFlipFlop #(WIDTH) reg_b(
    .clk(clk),
    .en(en),
    .reset(reset), // Connect reset
    .d(in_b),
    .q(out_b)
   );

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

module CC_Delay(clk, reset, d, q);
  parameter WIDTH=1;
  parameter DELAY=1;
  input clk;
  input reset; // Reset input is correctly defined here
  input [WIDTH-1:0] d;
  output [WIDTH-1:0] q;
  wire [(WIDTH*DELAY)-1:0] reg_inputs;
  wire [(WIDTH*DELAY)-1:0] reg_outputs;
  genvar i;

  generate
    // Ensure DELAY is at least 1
    if (DELAY < 1) begin
      // Handle zero or negative delay case if necessary, e.g., assign d directly to q
      assign q = d;
      // Or generate an error/warning
      // initial $error("CC_Delay DELAY parameter must be >= 1");
    end else begin : DFF_CHAIN_GEN
      for (i = 0; i < DELAY; i = i + 1)
      begin: DFF_CHAIN
        // Correctly connect reset from the module's input port
        CC_DFlipFlop #(WIDTH) chain_reg (
            .clk(clk),
            .en(1'b1),
            .reset(reset), // Pass reset through
            .d(reg_inputs[(i+1)*WIDTH-1:i*WIDTH]),
            .q(reg_outputs[(i+1)*WIDTH-1:i*WIDTH])
        );
        // Connect output of current stage to input of next stage
        // The conditional connection needs adjustment
        if (i < DELAY - 1) begin
           assign reg_inputs[(i+2)*WIDTH-1:(i+1)*WIDTH] = reg_outputs[(i+1)*WIDTH-1:i*WIDTH];
        end
      end
      // Assign the input 'd' to the input of the first flip-flop in the chain
      assign reg_inputs[WIDTH-1:0] = d;
      // Assign the output 'q' from the output of the last flip-flop in the chain
      assign q = reg_outputs[(DELAY*WIDTH)-1:(DELAY-1)*WIDTH];
    end
  endgenerate
endmodule