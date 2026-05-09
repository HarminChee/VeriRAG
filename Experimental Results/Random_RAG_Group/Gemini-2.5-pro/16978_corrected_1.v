`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i,       // Test mode input
  input         test_clk_i,   // Test clock input (Added for DFT)
  input         CLK_IN1,      // Functional clock input
  input         COUNTER_RESET,// Functional/Test reset input
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;

  // Internal signals
  wire          reset_int; // Internal functional reset condition
  reg rst_sync;
  reg rst_sync_int;
  reg rst_sync_int1;
  reg rst_sync_int2;
  wire           clk_int;   // Functional clock from generator
  wire           clk_n;
  wire           clk;       // Functional clock used internally
  wire           dft_clk;   // Clock signal selected for FF/ODDR
  wire           dft_clk_n; // Inverted selected clock
  reg  [C_W-1:0] counter;

  // DFT Muxing logic for asynchronous resets
  wire dft_reset_sync_trigger;
  wire dft_reset_counter_trigger;

  // Instantiate the clock generator
  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));

  // Define functional reset condition
  assign reset_int = !LOCKED || COUNTER_RESET;

  // Assign functional clock
  assign clk = clk_int;
  assign clk_n = ~clk; // Functional inverted clock

  // --- DFT Modifications ---
  // Clock Mux: Select functional clock (clk) or test clock (test_clk_i)
  assign dft_clk = test_i ? test_clk_i : clk;
  assign dft_clk_n = test_i ? ~test_clk_i : clk_n; // Select inverted clock accordingly

  // Reset Mux: Select primary reset (COUNTER_RESET) during test mode
  assign dft_reset_sync_trigger = test_i ? COUNTER_RESET : reset_int;
  assign dft_reset_counter_trigger = test_i ? COUNTER_RESET : rst_sync_int2;
  // --- End DFT Modifications ---


  // ODDR2 primitive generates output clock CLK_OUT[1]
  // Clocked by the DFT-selected clock (dft_clk / dft_clk_n)
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (dft_clk),     // Use muxed clock
    .C1 (dft_clk_n),   // Use muxed inverted clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

  // Reset synchronizer chain
  // Clocked by DFT-selected clock (dft_clk)
  // Asynchronously reset by DFT-selected reset (dft_reset_sync_trigger)
  always @(posedge dft_clk or posedge dft_reset_sync_trigger) begin
     // Use functional reset condition internally to decide state
     if (reset_int) begin
          rst_sync <= #TCQ 1'b1;
          rst_sync_int <= #TCQ 1'b1;
          rst_sync_int1 <= #TCQ 1'b1;
          rst_sync_int2 <= #TCQ 1'b1;
     end
     else begin
          rst_sync <= #TCQ 1'b0;
          rst_sync_int <= #TCQ rst_sync;
          rst_sync_int1 <= #TCQ rst_sync_int;
          rst_sync_int2 <= #TCQ rst_sync_int1;
     end
  end

  // Counter
  // Clocked by DFT-selected clock (dft_clk)
  // Asynchronously reset by DFT-selected reset (dft_reset_counter_trigger)
  always @(posedge dft_clk or posedge dft_reset_counter_trigger) begin
    // Use functional reset condition internally to decide state
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule