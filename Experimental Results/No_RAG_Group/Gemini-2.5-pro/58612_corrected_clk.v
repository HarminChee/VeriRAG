`timescale 1ps/1ps
module bclk_dll_exdes_corrected_clk
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,         // Primary clock input
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  input         RESET,           // Primary reset input
  output        LOCKED,
  input         scan_mode        // Test mode control signal
 );

  localparam    C_W       = 16;

  wire          clk_in1_buf;     // Buffered primary clock
  wire          clk_int;         // Internally generated clock from DLL
  wire          clk_func;        // Functional clock signal (same as clk_int)
  wire          clk_mux_out;     // Clock signal selected by MUX for FFs

  // DFT Enhancement: Use test_mode signal (can be scan_mode or similar)
  wire          test_mode = scan_mode;

  // Original reset logic - Note: depends on LOCKED from DLL, potentially problematic for DFT reset control.
  // For strict CLKNPI fix, we focus on clocking. A full DFT review would address reset too.
  wire          reset_int = !LOCKED || RESET || COUNTER_RESET;

  reg rst_sync;
  reg rst_sync_int;
  reg rst_sync_int1;
  reg rst_sync_int2;
  reg [C_W-1:0] counter;

  // Buffer the primary clock input
  BUFG clkin1_buf_inst
   (.O (clk_in1_buf),
    .I (CLK_IN1));

  // Instantiate the DLL block
  bclk_dll clknetwork
   (
    .clk133in            (clk_in1_buf), // Input to DLL is buffered primary clock
    .clk133              (clk_int),     // Output is the internally generated clock
    .RESET              (RESET),
    .LOCKED             (LOCKED));

  // Assign functional clock output
  assign CLK_OUT[1] = clk_int;
  assign clk_func = clk_int; // Alias for the functional clock

  // DFT Clock MUX:
  // Selects the primary-derived clock (clk_in1_buf) during test mode (test_mode = 1)
  // Selects the functional clock (clk_func) during normal operation (test_mode = 0)
  assign clk_mux_out = test_mode ? clk_in1_buf : clk_func;

  // Reset Synchronizer: Clocked by the MUXed clock (clk_mux_out)
  // The asynchronous reset (reset_int) is retained from original code.
  always @(posedge clk_mux_out or posedge reset_int) begin
    if (reset_int) begin
      rst_sync      <= 1'b1;
      rst_sync_int  <= 1'b1;
      rst_sync_int1 <= 1'b1;
      rst_sync_int2 <= 1'b1;
    end else begin
      rst_sync      <= 1'b0;
      rst_sync_int  <= rst_sync;
      rst_sync_int1 <= rst_sync_int;
      rst_sync_int2 <= rst_sync_int1;
    end
  end

  // Counter: Clocked by the MUXed clock (clk_mux_out)
  // The asynchronous reset (rst_sync_int2) is retained from original code.
  always @(posedge clk_mux_out or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // Assign counter output
  assign COUNT = counter[C_W-1];

endmodule