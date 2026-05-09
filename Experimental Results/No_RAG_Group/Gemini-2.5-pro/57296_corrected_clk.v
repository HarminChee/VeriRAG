`timescale 1ps/1ps
module clk32to40_exdes_corrected_clk
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1, // Primary input clock
  input         COUNTER_RESET, // Primary input reset
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;
  // Use a test clock enable signal for DFT, muxing between functional clock and test clock
  // For this fix, we'll assume CLK_IN1 is the reference for internal flops during test
  // The original internally generated clock 'clk' is problematic for DFT scan insertion

  wire          reset_int = COUNTER_RESET; // Use primary reset directly or synchronized version
  reg rst_sync;
  reg rst_sync_int;
  reg rst_sync_int1;
  reg rst_sync_int2;

  wire           clk_int; // Internally generated clock from clknetwork
  wire           clk;     // Derived internal clock (problematic for FFs)
  wire           clk_n;

  reg  [C_W-1:0] counter;

  // Instance generating the internal clock - this clock should ideally not drive scan FFs
  clk32to40 clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int)); // clk_int is the internally generated clock

  // Assign clk for use in ODDR2, but avoid using it for internal FFs
  assign clk = clk_int;
  assign clk_n = ~clk;

  // ODDR2 generating output clock based on the internal clock 'clk'
  // This is acceptable as it's generating an output, not clocking internal scan FFs
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0), // Consider connecting reset appropriately if needed
    .S  (1'b0));

  // Reset Synchronization Logic - Clocked by the primary input clock CLK_IN1
  // Use asynchronous reset input directly in the first stage for safety
  always @(posedge CLK_IN1 or posedge reset_int) begin
     if (reset_int) begin // Asynchronous reset assertion
          rst_sync <= 1'b1;
          rst_sync_int <= 1'b1;
          rst_sync_int1 <= 1'b1;
          rst_sync_int2 <= 1'b1;
     end
     else begin // Synchronous reset deassertion
          rst_sync <= 1'b0; // First stage deasserts synchronously
          rst_sync_int <= rst_sync;
          rst_sync_int1 <= rst_sync_int;
          rst_sync_int2 <= rst_sync_int1; // Final synchronized reset
     end
  end

  // Counter Logic - Clocked by the primary input clock CLK_IN1
  // Reset is synchronous using the synchronized reset rst_sync_int2
  always @(posedge CLK_IN1 or posedge rst_sync_int2) begin // Use primary clock CLK_IN1
    if (rst_sync_int2) begin // Synchronous reset
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule

// Note: The clk32to40 module definition is not provided, assumed to exist.
// It generates clk_int based on CLK_IN1.
// The core change is clocking internal flip-flops (rst_sync*, counter)
// with the primary input clock CLK_IN1 instead of the generated clock clk/clk_int.
// This makes these flip-flops scannable.
// The ODDR generating CLK_OUT still uses the generated clock 'clk', which might require
// separate DFT handling (e.g., bypassing during scan) depending on test strategy.