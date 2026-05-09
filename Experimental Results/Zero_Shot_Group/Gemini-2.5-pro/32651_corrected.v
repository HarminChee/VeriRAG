`timescale 1ps/1ps

module Clock65MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );

  localparam    C_W       = 16;

  wire          reset_int = !LOCKED || COUNTER_RESET;

  // Reset synchronizer registers
  reg rst_sync;
  reg rst_sync_int;
  reg rst_sync_int1;
  reg rst_sync_int2; // Synchronized reset signal

  wire           clk_int;
  wire           clk_n;
  wire           clk;
  reg  [C_W-1:0] counter;

  // Clock generation module instance
  Clock65MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED)
   );

  // Assign internal clock and its inversion
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Output driver for the clock
  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0), // Asynchronous reset (not used here)
    .S  (1'b0)  // Asynchronous set (not used here)
   );

  // Reset synchronizer chain clocked by 'clk'
  // Samples the potentially asynchronous 'reset_int' signal
  // and propagates it through flip-flops to mitigate metastability.
  always @(posedge clk) begin
    rst_sync      <= #TCQ reset_int;
    rst_sync_int  <= #TCQ rst_sync;
    rst_sync_int1 <= #TCQ rst_sync_int;
    rst_sync_int2 <= #TCQ rst_sync_int1; // Output of the synchronizer
  end

  // Counter with asynchronous reset driven by the synchronized reset signal
  always @(posedge clk or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin // Check if asynchronous reset is active
      counter <= #TCQ {C_W{1'b0}};
    end else begin           // Operate on the positive clock edge if reset is inactive
      counter <= #TCQ counter + 1'b1;
    end
  end

  // Assign the most significant bit of the counter to the output COUNT
  assign COUNT = counter[C_W-1];

endmodule