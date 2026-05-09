`timescale 1ps/1ps

module clk32to40_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Asynchronous Reset Input
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;

  // Internal signals
  wire          reset_int = COUNTER_RESET; // Raw reset input
  reg           rst_sync;                  // Reset synchronizer stage 1
  reg           rst_sync_int;              // Reset synchronizer stage 2
  reg           rst_sync_int1;             // Reset synchronizer stage 3 (Synchronized Reset)

  wire          clk_int; // Clock from clk32to40 primitive
  wire          clk;     // Internal clock used by logic
  wire          clk_n;   // Inverted internal clock

  reg  [C_W-1:0] counter; // Output counter

  // Instantiate the core clocking network
  clk32to40 clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int)
   );

  // Assign internal clock and its inversion
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Output Driver using ODDR primitive (FPGA specific)
  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]), // Connect to the single bit output port
    .C0 (clk),        // Positive edge clock
    .C1 (clk_n),      // Negative edge clock
    .CE (1'b1),       // Clock Enable
    .D0 (1'b1),       // Data for posedge C0
    .D1 (1'b0),       // Data for posedge C1 (negedge C0)
    .R  (1'b0),       // Async Reset (inactive)
    .S  (1'b0)        // Async Set (inactive)
   );

  // Reset Synchronizer (3 stages)
  // Synchronizes the asynchronous COUNTER_RESET input to the 'clk' domain.
  // All flip-flops are clocked by 'clk'.
  always @(posedge clk) begin
      rst_sync      <= reset_int;       // Stage 1: Sample async input
      rst_sync_int  <= rst_sync;      // Stage 2
      rst_sync_int1 <= rst_sync_int;   // Stage 3: Output synchronized reset
  end

  // Counter logic with synchronous reset
  // Uses the synchronized reset signal 'rst_sync_int1'.
  always @(posedge clk) begin
    if (rst_sync_int1) begin // Check synchronized reset
      counter <= #TCQ { C_W { 1'b 0 } }; // Reset counter
    end else begin
      counter <= #TCQ counter + 1'b 1;   // Increment counter
    end
  end

  // Assign the most significant bit of the counter to the output port
  assign COUNT = counter[C_W-1];

endmodule