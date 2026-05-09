`timescale 1ps/1ps
// `timescale 1ps/1ps // Duplicate timescale removed
module clk_wiz_v3_6_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         test_i, // Added test mode input
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;
  wire          reset_int = COUNTER_RESET;
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_in1_buf; // Added wire declaration
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  wire           dft_clk; // Added DFT clock wire
  reg  [C_W-1:0] counter;

  BUFG clkin1_buf
   (.O (clk_in1_buf),
    .I (CLK_IN1));

  // Instance of the clock wizard - using original port names from input file
  clk_wiz_v3_6 clknetwork
   (
    .clk            (clk_in1_buf), // Input clock to the wizard
    .clk_20MHz      (clk_int)      // Output clock from the wizard
   );

  assign clk = clk_int;
  assign clk_n = ~clk;
  assign dft_clk = test_i ? clk_in1_buf : clk; // MUX for clock selection

  ODDR2 clkout_oddr // Keep original clocking for ODDR
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

    // Reset synchronizer - uses dft_clk and primary async reset
    // Async reset is reset_int (primary input), which is DFT compliant.
    always @(posedge dft_clk or posedge reset_int) begin // Changed clock to dft_clk
       if (reset_int) begin
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

  // Counter - uses dft_clk and primary async reset
  always @(posedge dft_clk or posedge reset_int) begin // Changed clock to dft_clk, Changed reset to reset_int
    if (reset_int) begin // Changed async reset from rst_sync_int2 to reset_int (ACNCPI fix)
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule