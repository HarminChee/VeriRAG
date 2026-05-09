`timescale 1ps/1ps
`timescale 1ps/1ps
module bclk_dll_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  input         RESET,
  output        LOCKED,
  input         test_i // Added test mode input
 );
  localparam    C_W       = 16;

  // Internal signals
  wire          clk_in1_buf;
  wire          clk_int; // Functional clock from DLL
  wire          locked_internal; // Internal wire for LOCKED output
  reg  [C_W-1:0] counter;

  // DFT signals
  wire          test_clk;
  wire          test_reset;
  wire          dft_clk;
  wire          func_reset; // Functional reset logic
  wire          reset_sync_source; // Input to reset synchronizer chain

  // Reset synchronizer registers
  reg rst_sync;
  reg rst_sync_int;
  reg rst_sync_int1;
  reg rst_sync_int2; // Final synchronized reset for counter

  // Clock Buffering
  BUFG clkin1_buf_inst
   (.O (clk_in1_buf),
    .I (CLK_IN1));

  // DLL Instantiation
  bclk_dll clknetwork
   (
    .clk133in            (clk_in1_buf),
    .clk133           (clk_int),
    .RESET              (RESET), // Use primary RESET for DLL reset
    .LOCKED             (locked_internal)); // Connect to internal wire

  // Assign outputs
  assign CLK_OUT[1] = clk_int; // Functional clock output
  assign LOCKED = locked_internal; // Assign internal signal to output port
  assign COUNT = counter[C_W-1];

  // DFT Logic Implementation
  assign test_clk = CLK_IN1; // Use primary clock for test clock
  assign test_reset = RESET; // Use primary reset for test reset

  // Clock Mux: Selects test_clk in test mode, functional clk otherwise
  assign dft_clk = test_i ? test_clk : clk_int;

  // Functional Reset Logic: Combines primary resets and internal !LOCKED
  assign func_reset = !locked_internal || RESET || COUNTER_RESET;

  // Reset Source Mux: Selects test_reset in test mode, functional reset otherwise
  assign reset_sync_source = test_i ? test_reset : func_reset;

  // Reset Synchronizer Chain (using DFT clock and synchronous logic)
  // This synchronizes the potentially asynchronous 'reset_sync_source' to 'dft_clk'
  always @(posedge dft_clk) begin
    rst_sync      <= #TCQ reset_sync_source;
    rst_sync_int  <= #TCQ rst_sync;
    rst_sync_int1 <= #TCQ rst_sync_int;
    rst_sync_int2 <= #TCQ rst_sync_int1; // This is the synchronized reset for the counter
  end

  // Counter Logic (using DFT clock and synchronized reset)
  always @(posedge dft_clk) begin
    if (rst_sync_int2) begin // Use the synchronized reset signal
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

endmodule