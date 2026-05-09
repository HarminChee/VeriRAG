`timescale 1ps/1ps

module SystemClockUnit_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Asynchronous reset input
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );

  localparam C_W = 16;

  // Internal signals
  wire          clk_int; // Clock from SystemClockUnit
  wire          clk;     // Internal clock buffer/signal
  wire          clk_n;   // Inverted clock for ODDR2

  wire          reset_int; // Combined reset condition (!LOCKED or external reset)
  reg           rst_sync;      // Reset synchronizer stage 1
  reg           rst_sync_int;  // Reset synchronizer stage 2
  reg           rst_sync_int1; // Reset synchronizer stage 3
  reg           rst_sync_int2; // Reset synchronizer stage 4 (synchronized reset)

  reg  [C_W-1:0] counter; // Counter register

  // Instantiate the clocking unit
  SystemClockUnit clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int), // Connect to internal wire
    .LOCKED             (LOCKED)
   );

  // Assign internal clock and generate inverted clock
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Generate combined reset signal (active high)
  // Reset is active if clock is not locked OR external reset is asserted
  assign reset_int = !LOCKED || COUNTER_RESET;

  // Reset Synchronizer
  // Synchronizes the potentially asynchronous 'reset_int' signal to the 'clk' domain.
  // Uses external COUNTER_RESET for asynchronous reset of the synchronizer itself.
  always @(posedge clk or posedge COUNTER_RESET) begin
     if (COUNTER_RESET) begin // Asynchronous reset asserted
         rst_sync      <= #TCQ 1'b1;
         rst_sync_int  <= #TCQ 1'b1;
         rst_sync_int1 <= #TCQ 1'b1;
         rst_sync_int2 <= #TCQ 1'b1;
     end else begin             // Synchronous operation
         rst_sync      <= #TCQ reset_int;     // Capture input on clock edge
         rst_sync_int  <= #TCQ rst_sync;
         rst_sync_int1 <= #TCQ rst_sync_int;
         rst_sync_int2 <= #TCQ rst_sync_int1; // Output synchronized reset
     end
  end

  // Counter logic with synchronous reset
  // Uses the synchronized reset signal 'rst_sync_int2'
  always @(posedge clk) begin
    if (rst_sync_int2) begin // Check synchronized reset condition
      counter <= #TCQ {C_W{1'b0}}; // Reset counter
    end else begin
      counter <= #TCQ counter + 1'b1; // Increment counter
    end
  end

  // Output Assignments
  assign COUNT = counter[C_W-1]; // Assign MSB of counter to COUNT output

  // Output clock buffer (using ODDR2 primitive as in original code)
  // This drives CLK_OUT[1] with the 'clk' signal.
  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]), // Output pin
    .C0 (clk),        // Clock input
    .C1 (clk_n),      // Inverted clock input
    .CE (1'b1),       // Clock Enable (always enabled)
    .D0 (1'b1),       // Data input for posedge C0
    .D1 (1'b0),       // Data input for posedge C1
                      // Effectively Q = clk ? 1 : 0; which follows clk
    .R  (1'b0),       // Reset (tied low)
    .S  (1'b0)        // Set (tied low)
   );

endmodule