`timescale 1ps/1ps

module pll_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [4:1]  CLK_OUT,
  output [4:1]  COUNT,
  input         RESET,
  output        LOCKED
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 4;

  genvar        count_gen;
  genvar        clk_out_pins;

  wire          reset_int = !LOCKED || RESET || COUNTER_RESET;

  wire [NUM_C:1] clk_int;
  reg  [C_W-1:0] counter [NUM_C:1];

  // Reset synchronizer registers
  reg [NUM_C:1] reset_sync_0;
  reg [NUM_C:1] reset_sync_1;


  pll clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]),
    .CLK_OUT3           (clk_int[3]),
    .CLK_OUT4           (clk_int[4]),
    .RESET              (RESET), // Assuming PLL has its own reset handling
    .LOCKED             (LOCKED));


  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
      // Assumes ODDR primitive exists in the target technology
      ODDR clkout_oddr
       (.Q  (CLK_OUT[clk_out_pins]),
        .C  (clk_int[clk_out_pins]), // Clocked by direct PLL output
        .CE (1'b1),
        .D1 (1'b1),
        .D2 (1'b0),
        .R  (1'b0), // ODDR reset/set tied inactive
        .S  (1'b0));
    end
  endgenerate


  // Reset synchronizer logic (2-flop synchronizer for each clock domain)
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: reset_synchronizers
      // Synchronize the combined asynchronous reset 'reset_int' to each clock domain 'clk_int[count_gen]'
      always @(posedge clk_int[count_gen]) begin
         reset_sync_0[count_gen] <= #TCQ reset_int;
         reset_sync_1[count_gen] <= #TCQ reset_sync_0[count_gen];
      end
    end
  endgenerate


  // Counter logic with synchronous reset
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: counters
      always @(posedge clk_int[count_gen]) begin // Clocked by direct PLL output
        if (reset_sync_1[count_gen]) begin // Use synchronized reset signal
          counter[count_gen] <= #TCQ { C_W { 1'b0 } };
        end else begin
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1;
        end
      end
      // Assign MSB of each counter to the corresponding COUNT output bit
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate

endmodule

// Note: Definition for the 'pll' module and 'ODDR' primitive are assumed to exist elsewhere.
// The indexing [MSB:LSB] convention [4:1] is kept as in the original code.