`timescale 1ps/1ps
`timescale 1ps/1ps
module pll_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         test_i, // Added test mode input
  output [4:1]  CLK_OUT,
  output [4:1]  COUNT,
  input         RESET,
  output        LOCKED
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 4;
  genvar        count_gen;

  // DFT Reset Logic
  wire          test_mode_reset = RESET || COUNTER_RESET;
  wire          func_mode_reset = !LOCKED || RESET || COUNTER_RESET;
  wire          reset_int_muxed = test_i ? test_mode_reset : func_mode_reset; // Muxed reset for test

  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk;
  reg [C_W-1:0]  counter [NUM_C:1];

  // DFT Clock Logic
  wire [NUM_C:1] dft_clk; // Muxed clock for test

  pll clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]),
    .CLK_OUT3           (clk_int[3]),
    .CLK_OUT4           (clk_int[4]),
    .RESET              (RESET),
    .LOCKED             (LOCKED));

  genvar clk_out_pins;
  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
      // DFT Clock Mux for ODDR
      wire dft_oddr_clk;
      assign dft_oddr_clk = test_i ? CLK_IN1 : clk[clk_out_pins];

      ODDR clkout_oddr
       (.Q  (CLK_OUT[clk_out_pins]),
        .C  (dft_oddr_clk), // Use muxed clock
        .CE (1'b1),
        .D1 (1'b1),
        .D2 (1'b0),
        .R  (1'b0), // Assuming ODDR reset is not needed or handled differently
        .S  (1'b0)); // Assuming ODDR set is not needed or handled differently
    end
  endgenerate

  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];
  assign clk[4] = clk_int[4];

  // Generate block for reset synchronizers and DFT clock muxing
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
    // DFT Clock Mux for synchronizers
    assign dft_clk[count_gen] = test_i ? CLK_IN1 : clk[count_gen];

    // Reset Synchronizer Flops
    always @(posedge dft_clk[count_gen] or posedge reset_int_muxed) begin // Use muxed clock and reset
       if (reset_int_muxed) begin
            rst_sync[count_gen] <= #TCQ 1'b1;
            rst_sync_int[count_gen]<= #TCQ 1'b1;
            rst_sync_int1[count_gen]<= #TCQ 1'b1;
            rst_sync_int2[count_gen]<= #TCQ 1'b1;
       end
       else begin
            rst_sync[count_gen] <= #TCQ 1'b0;
            rst_sync_int[count_gen] <= #TCQ rst_sync[count_gen];
            rst_sync_int1[count_gen] <= #TCQ rst_sync_int[count_gen];
            rst_sync_int2[count_gen] <= #TCQ rst_sync_int1[count_gen];
       end
    end
  end
  endgenerate

  // Generate block for counters
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
    // Counter Flops
    // Note: reset_int_muxed is already derived correctly for test mode.
    // rst_sync_int2 is the synchronized version of reset_int_muxed.
    // We use the synchronized reset rst_sync_int2 for the counter's async reset.
    // The clock dft_clk[count_gen] is already muxed correctly for test mode.
    always @(posedge dft_clk[count_gen] or posedge rst_sync_int2[count_gen]) begin // Use muxed clock and synchronized muxed reset
      if (rst_sync_int2[count_gen]) begin
        counter[count_gen] <= #TCQ { C_W { 1'b 0 } };
      end else begin
        counter[count_gen] <= #TCQ counter[count_gen] + 1'b 1;
      end
    end
    assign COUNT[count_gen] = counter[count_gen][C_W-1];
  end
  endgenerate

endmodule