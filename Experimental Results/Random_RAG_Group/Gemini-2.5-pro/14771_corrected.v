module CC_DLatch(test_i, test_clk_i, en, d, q); // Added test_i, test_clk_i for DFT
  parameter WIDTH=1;
  input test_i;      // DFT test mode signal
  input test_clk_i;  // DFT test clock
  input en;
  input [WIDTH-1:0] d;
  output [WIDTH-1:0] q;
  wire [WIDTH-1:0] reg_out;
  // DFT Fix: Clock for the internal FF must be controllable.
  // In test mode (test_i=1), use test_clk_i. Otherwise, use original logic (~en).
  // Note: Using ~en as a clock is generally bad practice (gated clock) and makes this behave like a latch.
  // Standard scan DFT prefers replacing latches with FF or using specific latch scan cells.
  // This fix addresses the CLKNPI rule by providing a primary clock path during test.
  wire dft_clk = test_i ? test_clk_i : ~en;
  CC_DFlipFlop #(WIDTH) r(.clk(dft_clk), .en(1'b1), .reset(1'b0), .d(d), .q(reg_out)); // Corrected reset connection to 1'b0
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

module CC_MuxReg(sel, clk, en, reset, in_a, in_b, out); // Added reset input assuming it might be needed, tied low if not used externally
  parameter WIDTH=8;
  input sel;
  input clk;
  input en;
  input reset; // Added reset input for consistency, can be tied low externally if not needed
  input [WIDTH-1:0] in_a;
  input [WIDTH-1:0] in_b;
  output [WIDTH-1:0] out;
  wire [WIDTH-1:0] out_a;
  wire [WIDTH-1:0] out_b;
  // DFT Fix: Corrected instantiation to match CC_DFlipFlop port list.
  // Assuming synchronous reset behavior is desired if reset is used.
  // If no reset was intended, the 'reset' input port can be removed and tied to 1'b0 internally.
  // Using the added 'reset' input port for flexibility.
  CC_DFlipFlop #(WIDTH) reg_a(.clk(clk), .en(en), .reset(reset), .d(in_a), .q(out_a));
  CC_DFlipFlop #(WIDTH) reg_b(.clk(clk), .en(en), .reset(reset), .d(in_b), .q(out_b));
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
  input reset; // Asynchronous reset
  input [WIDTH-1:0] d;
  output reg [WIDTH-1:0] q; // Made output reg as it's assigned in always block

  always @ (posedge clk or posedge reset)
  if (reset)
    q <= {WIDTH{1'b0}}; // Initialize to 0 on reset
  else if (en)
    q <= d;
  // Note: If 'en' is low, the flop holds its value (implicit).
endmodule

module CC_Delay(clk, reset, d, q);
  parameter WIDTH=1;
  parameter DELAY=1;
  input clk;
  input reset; // Asynchronous reset for the chain
  input [WIDTH-1:0] d;
  output [WIDTH-1:0] q;

  // Internal wires for connecting the flip-flop chain
  wire [(WIDTH*DELAY)-1:0] reg_chain_d;
  wire [(WIDTH*DELAY)-1:0] reg_chain_q;

  genvar i;
  generate
    // Instantiate DELAY number of flip-flops
    for (i = 0; i < DELAY; i = i + 1)
    begin: DFF_CHAIN
      // Determine the input for the current flip-flop
      // For the first flop (i=0), input is 'd'
      // For subsequent flops, input is the output of the previous flop
      assign reg_chain_d[(i+1)*WIDTH-1:i*WIDTH] = (i == 0) ? d : reg_chain_q[i*WIDTH-1:(i-1)*WIDTH];

      // Instantiate the flip-flop
      CC_DFlipFlop #(WIDTH) chain_reg (
          .clk(clk),
          .en(1'b1), // Always enabled
          .reset(reset), // Pass down the reset
          .d(reg_chain_d[(i+1)*WIDTH-1:i*WIDTH]),
          .q(reg_chain_q[(i+1)*WIDTH-1:i*WIDTH])
      );
    end
  endgenerate

  // Assign the output 'q' from the last flip-flop in the chain
  assign q = reg_chain_q[(DELAY*WIDTH)-1:(DELAY-1)*WIDTH];

endmodule