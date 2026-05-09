`timescale 1ps/1ps

module Clock35MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Asynchronous reset input
  output [1:1]  CLK_OUT,       // Clock output (single bit)
  output        COUNT,         // MSb of the counter
  output        LOCKED         // Lock status from Clock35MHz
 );

  localparam C_W = 16; // Width of the counter

  // Internal signals
  wire   clk_int;         // Clock output from Clock35MHz primitive
  wire   clk;             // Internal clock signal derived from clk_int
  wire   clk_n;           // Inverted internal clock
  wire   locked_internal; // Internal wire for LOCKED output
  wire   async_reset_in;  // Combined asynchronous reset condition

  // Reset synchronizer registers
  reg    rst_sync_0;
  reg    rst_sync_1;
  reg    rst_sync_2;
  wire   sync_reset;      // Synchronized reset signal

  // Counter register
  reg  [C_W-1:0] counter;

  // Instantiate the clock generator
  Clock35MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int), // Connect to internal clock wire
    .LOCKED             (locked_internal) // Connect to internal locked wire
   );

  // Assign internal clock and LOCKED signal
  assign clk = clk_int;
  assign LOCKED = locked_internal; // Drive the output port

  // Generate inverted clock for ODDR
  assign clk_n = ~clk;

  // Instantiate ODDR for clock output generation
  // Assumes ODDR2 primitive is available (e.g., Xilinx FPGA)
  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]), // Connect to the single-bit output port
    .C0 (clk),        // Rising edge clock
    .C1 (clk_n),      // Falling edge clock
    .CE (1'b1),       // Clock enable tied high
    .D0 (1'b1),       // Data input for rising edge
    .D1 (1'b0),       // Data input for falling edge
    .R  (1'b0),       // Reset tied low
    .S  (1'b0)        // Set tied low
   );

  // Define the raw asynchronous reset condition
  // Reset is active high if COUNTER_RESET is high OR if the clock is not locked
  assign async_reset_in = COUNTER_RESET || !locked_internal;

  // Reset Synchronizer (asynchronous assert, synchronous deassert)
  // Synchronizes the async_reset_in to the 'clk' domain
  always @(posedge clk or posedge async_reset_in) begin
    if (async_reset_in) begin
      rst_sync_0 <= 1'b1;
      rst_sync_1 <= 1'b1;
      rst_sync_2 <= 1'b1;
    end else begin
      rst_sync_0 <= 1'b0;
      rst_sync_1 <= rst_sync_0;
      rst_sync_2 <= rst_sync_1;
    end
  end

  // Assign the synchronized reset output
  assign sync_reset = rst_sync_2; // Use the output of the synchronizer chain

  // Counter logic with synchronous reset
  // Note: Changed from asynchronous reset in original code for robustness,
  // assuming reset should align with the clock edge after synchronization.
  // If truly asynchronous reset to the counter is needed AFTER synchronization,
  // the sensitivity list should be `posedge clk or posedge sync_reset`.
  always @(posedge clk) begin
    if (sync_reset) begin // Use the synchronized reset
      counter <= #TCQ {C_W{1'b0}};
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  // Assign the MSb of the counter to the output
  assign COUNT = counter[C_W-1];

endmodule