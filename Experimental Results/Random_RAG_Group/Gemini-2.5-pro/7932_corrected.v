`timescale 1ps/1ps
// Note: Duplicate timescale directive removed
module sdram_clk_gen_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i, // Added test mode input for DFT
  input         CLK_IN1,
  input         COUNTER_RESET, // Primary input reset
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;
  // Removed redundant wire reset_int = COUNTER_RESET; Use COUNTER_RESET directly

   // Reset synchronizer registers
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;

  wire           clk_int; // Output of clock generator
  wire           clk_n;
  wire           clk;     // Functional clock (from clk_int)
  wire           clk_muxed; // Clock selected for DFT compliance
  wire           clk_muxed_n; // Inverted muxed clock

  reg  [C_W-1:0] counter;

  // Clock generator instance
  sdram_clk_gen clknetwork
   (
    .clk_in            (CLK_IN1),
    .clk_out           (clk_int));

  // Assign functional clock
  assign clk = clk_int;

  // DFT Clock Mux: Select Primary Input Clock (CLK_IN1) in test mode (test_i=1)
  //                Select Generated Clock (clk) in functional mode (test_i=0)
  // Fixes potential CLKNPI/FFCKNP violations for FFs clocked by clk/clk_n
  assign clk_muxed = test_i ? CLK_IN1 : clk;
  assign clk_muxed_n = ~clk_muxed; // Needed for ODDR

  // ODDR using muxed clock for DFT compliance
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk_muxed),     // Use muxed clock
    .C1 (clk_muxed_n),   // Use inverted muxed clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0), // Tied off reset - OK
    .S  (1'b0)); // Tied off set - OK

    // Reset Synchronizer using muxed clock
    // Asynchronous reset is COUNTER_RESET (Primary Input) - OK for ACNCPI
    always @(posedge clk_muxed or posedge COUNTER_RESET) begin // Use muxed clock, PI async reset
       if (COUNTER_RESET) begin
            rst_sync <= 1'b1;
            rst_sync_int <= 1'b1;
            rst_sync_int1 <= 1'b1;
            rst_sync_int2 <= 1'b1;
       end
       else begin
            rst_sync <= 1'b0;
            rst_sync_int <= rst_sync;
            rst_sync_int1 <= rst_sync_int;
            rst_sync_int2 <= rst_sync_int1;
       end
    end

  // Counter logic
  // Original had async reset posedge rst_sync_int2 (ACNCPI violation as rst_sync_int2 is internal)
  // Changed to synchronous reset using rst_sync_int2
  // Uses muxed clock (clk_muxed) for CLKNPI compliance
  always @(posedge clk_muxed) begin // Use muxed clock, synchronous reset
    if (rst_sync_int2) begin // Synchronous reset check
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // Output assignment
  assign COUNT = counter[C_W-1];

endmodule