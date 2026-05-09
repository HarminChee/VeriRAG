`timescale 1ps/1ps

module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output wire   COUNT, // Changed to output wire for clarity
  output        LOCKED
 );
  localparam    C_W       = 16;

  wire           clk_int;
  wire           clk_int_n;
  wire           async_reset;
  reg            rst_s1;
  reg            sync_reset; // Synchronized reset signal

  reg  [C_W-1:0] counter;

  // Instantiate the clocking network
  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int), // Use clk_int directly
    .LOCKED             (LOCKED)
   );

  // Generate inverted clock for ODDR2 if needed
  assign clk_int_n = ~clk_int;

  // Define asynchronous reset condition
  assign async_reset = !LOCKED || COUNTER_RESET;

  // Reset synchronizer (asynchronous assert, synchronous deassert)
  // Ensures reset is cleanly removed relative to the clock domain
  always @(posedge clk_int or posedge async_reset) begin
    if (async_reset) begin // Asynchronous assertion
      rst_s1 <= 1'b1;
      sync_reset <= 1'b1;
    end else begin // Synchronous deassertion
      rst_s1 <= 1'b0;
      sync_reset <= rst_s1;
    end
  end

  // ODDR2 instance to output the clock
  // This configuration outputs the clock signal clk_int on CLK_OUT[1]
  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]), // Output connected to the single bit
    .C0 (clk_int),    // Positive edge clock
    .C1 (clk_int_n),  // Negative edge clock (inverted clk_int)
    .CE (1'b1),       // Clock enable always high
    .D0 (1'b1),       // Data for posedge clock -> output goes high
    .D1 (1'b0),       // Data for negedge clock -> output goes low
    .R  (1'b0),       // Asynchronous reset (unused)
    .S  (1'b0)        // Asynchronous set (unused)
   );

  // Counter logic with asynchronous reset
  always @(posedge clk_int or posedge sync_reset) begin
    if (sync_reset) begin // Use the synchronized reset signal
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // Assign the most significant bit of the counter to the output COUNT
  assign COUNT = counter[C_W-1];

endmodule