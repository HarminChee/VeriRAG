module CC_DLatch(en, d, q);
  parameter WIDTH=1;
  input en;
  input [WIDTH-1:0] d;
  output [WIDTH-1:0] q;
  wire [WIDTH-1:0] reg_out;

  // Use named port mapping consistently and provide the reset signal
  // Assuming active-low reset for the flop based on typical latch behavior modeling with a flop
  // Or tie reset to inactive state if no reset needed for the latch itself. Using 1'b0 (inactive high reset).
  CC_DFlipFlop #(WIDTH) r (
    .clk(~en),
    .en(1'b1),
    .reset(1'b0), // Assuming reset is not used or tied low
    .d(d),
    .q(reg_out)
  );

  // Logic remains the same as provided, implementing level-sensitive behavior
  assign q = en ? d : reg_out;
endmodule

module CC_Bidir(sel_in, io, in, out);
  parameter WIDTH=1;
  input sel_in;
  inout [WIDTH-1:0] io;
  output [WIDTH-1:0] in;
  input [WIDTH-1:0] out;

  // Assign 'z' when not selected
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

  // Corrected instantiation with named ports and providing reset
  // Assuming reset should be tied low (inactive) if not provided as an input
  CC_DFlipFlop #(WIDTH) reg_a (
    .clk(clk),
    .en(en),
    .reset(1'b0), // Assuming reset tied low
    .d(in_a),
    .q(out_a)
  );

  CC_DFlipFlop #(WIDTH) reg_b (
    .clk(clk),
    .en(en),
    .reset(1'b0), // Assuming reset tied low
    .d(in_b),
    .q(out_b)
  );

  // Mux logic remains the same
  assign out = sel ? out_a : out_b;
endmodule

module CC_Decoder(in, out);
  parameter IN_WIDTH=8;
  // Ensure OUT_WIDTH calculation is correct for Verilog
  parameter OUT_WIDTH=(1 << IN_WIDTH);
  input [IN_WIDTH-1:0] in;
  output [OUT_WIDTH-1:0] out;

  // Use a combinatorial assignment for decoder logic
  // The generate block is okay, but a direct assignment might be clearer/simpler for synthesis
  // Keeping the generate block as it was provided and is functionally correct
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
  input reset; // Assuming active-high reset based on always block sensitivity
  input [WIDTH-1:0] d;
  output reg [WIDTH-1:0] q; // Corrected output declaration

  // Standard DFF with synchronous enable and asynchronous reset
  always @ (posedge clk or posedge reset)
    if (reset)
      q <= {WIDTH{1'b0}}; // Use replication operator for multi-bit reset
    else if (en)
      q <= d;
    // else q remains unchanged (implicitly)
endmodule

module CC_Delay(clk, reset, d, q);
  parameter WIDTH=1;
  parameter DELAY=1;

  input clk;
  input reset; // Assuming active-high reset consistent with CC_DFlipFlop
  input [WIDTH-1:0] d;
  output [WIDTH-1:0] q;

  // Corrected logic for delay chain using an array
  wire [WIDTH*(DELAY+1)-1:0] chain_data;
  assign chain_data[WIDTH-1:0] = d; // Input to the first stage

  genvar i;
  generate
    // Ensure DELAY is at least 1
    if (DELAY > 0) begin
      for (i = 0; i < DELAY; i = i + 1)
      begin: DFF_CHAIN
        // Instantiate DFF for each stage of the delay
        CC_DFlipFlop #(WIDTH) chain_reg (
            .clk(clk),
            .en(1'b1), // Delay element is always enabled
            .reset(reset),
            // Corrected indexing using slicing based on start index and width
            .d(chain_data[i*WIDTH +: WIDTH]),
            .q(chain_data[(i+1)*WIDTH +: WIDTH])
        );
      end
      // Assign output from the last stage
      assign q = chain_data[DELAY*WIDTH +: WIDTH];
    end else begin // Handle DELAY=0 case (direct connection)
        assign q = d;
    end
  endgenerate

endmodule

// Removed duplicate module definitions