`timescale 1ps/1ps
module Clock70MHz_exdes_corrected_clk
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,        // Primary clock input (functional and test)
  input         COUNTER_RESET,  // Functional asynchronous reset input
  input         test_mode,      // Test mode enable signal
  input         test_reset,     // Asynchronous test reset input
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );

  localparam C_W = 16;

  // Internal signals
  wire clk_int; // Clock from the generator
  wire clk_gen_locked; // Locked signal from the generator

  // Clock generator instance (definition not provided, assumed)
  Clock70MHz clknetwork (
    .CLK_IN1(CLK_IN1),
    .CLK_OUT1(clk_int),
    .LOCKED(clk_gen_locked) // Use a separate wire for the generator's locked output
  );

  // Assign LOCKED output based on test mode
  // Pass through the generator's locked signal. Behavior in test mode depends on test strategy.
  assign LOCKED = clk_gen_locked;

  // Select clock based on test_mode: Use CLK_IN1 as test clock
  wire scan_clk;
  assign scan_clk = test_mode ? CLK_IN1 : clk_int;
  wire scan_clk_n = ~scan_clk;

  // Define the effective asynchronous reset based on mode
  wire effective_reset_async;
  // Functional reset depends on LOCKED and COUNTER_RESET
  wire func_reset_int = !clk_gen_locked || COUNTER_RESET;
  // Select between functional reset and test reset
  assign effective_reset_async = test_mode ? test_reset : func_reset_int;

  // Synchronize the effective asynchronous reset to the scan_clk domain
  reg  effective_reset_sync_r1;
  reg  effective_reset_sync_r2;
  wire effective_reset_sync;

  // Asynchronous reset for the synchronizer FFs themselves
  always @(posedge scan_clk or posedge effective_reset_async) begin
    if (effective_reset_async) begin
      effective_reset_sync_r1 <= 1'b1;
      effective_reset_sync_r2 <= 1'b1;
    end else begin
      effective_reset_sync_r1 <= 1'b0;
      effective_reset_sync_r2 <= effective_reset_sync_r1;
    end
  end
  assign effective_reset_sync = effective_reset_sync_r2; // Use the synchronized reset for logic

  // Counter logic using synchronous reset
  reg [C_W-1:0] counter;
  always @(posedge scan_clk) begin
    if (effective_reset_sync) begin // Use active-high synchronous reset
      counter <= #TCQ {C_W{1'b0}};
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  // Assign COUNT output
  assign COUNT = counter[C_W-1];

  // Output clock generation using ODDR2
  // Use scan_clk and control reset based on test_mode
  ODDR2 clkout_oddr (
    .Q  (CLK_OUT[1]),
    .C0 (scan_clk),
    .C1 (scan_clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (test_mode ? test_reset : 1'b0), // Use async test_reset in test mode
    .S  (1'b0)
   );

endmodule