`timescale 1ps/1ps

module clk_wiz_v3_6_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Asynchronous Reset Input
  output [1:1]  CLK_OUT,
  output        COUNT
 );

  localparam C_W = 16;

  // Internal signals
  wire          clk_in1_buf;
  wire          clk_int; // Output from clock wizard
  wire          clk;     // Clock used internally, driven by clk_int
  wire          clk_n;   // Inverted clock for ODDR2

  // Reset synchronization registers
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2; // Synchronized reset signal

  // Counter register
  reg  [C_W-1:0] counter;

  // Input Buffer
  BUFG clkin1_bufg_inst (
    .O (clk_in1_buf),
    .I (CLK_IN1)
  );

  // Clock Wizard Instance
  // NOTE: Port names ('CLK_IN1', 'CLK_OUT1') are assumed based on common usage.
  //       Replace with actual port names from your clk_wiz_v3_6 IP core definition.
  clk_wiz_v3_6 clknetwork_inst (
    // Clock Input Ports
    .CLK_IN1 (clk_in1_buf), // Assumed input port name
    // Clock Output Ports
    .CLK_OUT1(clk_int)      // Assumed output port name
    // Other ports like RESET, LOCKED might be needed depending on the IP configuration
  );

  // Assign internal clock and its inverse
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Output DDR Primitive
  // Generates CLK_OUT toggling at the rate of 'clk'
  ODDR2 clkout_oddr_inst (
    .Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0), // Asynchronous reset (unused)
    .S  (1'b0)  // Asynchronous set (unused)
  );

  // Reset Synchronizer (Asynchronous input, Synchronous output)
  // Synchronizes the asynchronous COUNTER_RESET to the 'clk' domain
  always @(posedge clk) begin
      rst_sync      <= COUNTER_RESET;
      rst_sync_int  <= rst_sync;
      rst_sync_int1 <= rst_sync_int;
      rst_sync_int2 <= rst_sync_int1; // Use rst_sync_int2 as the synchronous reset
  end

  // Counter Logic (Synchronous reset)
  always @(posedge clk) begin
    if (rst_sync_int2) begin // Use the synchronized reset signal
      counter <= #TCQ {C_W{1'b0}};
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  // Assign the MSB of the counter to the output COUNT
  assign COUNT = counter[C_W-1];

endmodule