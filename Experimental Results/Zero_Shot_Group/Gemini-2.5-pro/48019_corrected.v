`timescale 1ps/1ps

module dcm_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Asynchronous reset input
  output        CLK_OUT,       // Corrected: single bit output
  output        COUNT
 );

  localparam C_W = 16;

  // Internal signals
  wire           clk_int;
  wire           clk;
  wire           clk_n;
  reg            rst_sync;
  reg            rst_sync_int;
  reg            rst_sync_int1;
  reg            rst_sync_int2; // Synchronized reset
  reg  [C_W-1:0] counter;

  // Instantiate the DCM/Clocking primitive
  // Assuming 'dcm' module exists and generates clk_int from CLK_IN1
  dcm clknetwork
   (
    .CLK_IN            (CLK_IN1),
    .CLK_OUT           (clk_int)
   );

  // Assign internal clock signals
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Output Driver using ODDR2 (FPGA specific primitive)
  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT),    // Corrected: Connect to single bit CLK_OUT
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0)
   );

  // Asynchronous Reset Synchronizer
  // Stage 1: Capture asynchronous reset edge
  always @(posedge clk or posedge COUNTER_RESET) begin
    if (COUNTER_RESET) begin
      rst_sync <= 1'b1;
    end else begin
      rst_sync <= 1'b0;
    end
  end

  // Stages 2, 3, 4: Synchronize reset to the clock domain
  always @(posedge clk) begin
    rst_sync_int  <= rst_sync;
    rst_sync_int1 <= rst_sync_int;
    rst_sync_int2 <= rst_sync_int1; // rst_sync_int2 is the synchronized reset signal
  end

  // Counter with synchronous reset using the synchronized reset signal
  always @(posedge clk) begin
    if (rst_sync_int2) begin // Use the synchronized reset
      counter <= #TCQ {C_W{1'b0}};
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  // Assign MSB of counter to output COUNT
  assign COUNT = counter[C_W-1];

endmodule

// Note: The definition for the 'dcm' module is required for simulation/synthesis.
// This code assumes 'dcm' exists and has the specified ports.
// Example placeholder for 'dcm' if needed for basic simulation:
/*
module dcm (
  input CLK_IN,
  output CLK_OUT
);
  assign CLK_OUT = CLK_IN; // Simplistic pass-through
endmodule
*/