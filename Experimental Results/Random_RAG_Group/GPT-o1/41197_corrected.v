`timescale 1ps/1ps
`timescale 1ps/1ps
module pll_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         scan_clk,
  input         test_i,
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

  wire          reset_int = (!LOCKED || RESET || COUNTER_RESET);
  wire          dft_reset_int;
  assign        dft_reset_int = test_i ? 1'b0 : reset_int;

  reg  [NUM_C:1] rst_sync;
  reg  [NUM_C:1] rst_sync_int;
  reg  [NUM_C:1] rst_sync_int1;
  reg  [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] dft_clk_int;
  wire [NUM_C:1] clk;
  reg  [C_W-1:0] counter [NUM_C:1];

  pll clknetwork
   (
    .CLK_IN1  (CLK_IN1),
    .CLK_OUT1 (clk_int[1]),
    .CLK_OUT2 (clk_int[2]),
    .CLK_OUT3 (clk_int[3]),
    .CLK_OUT4 (clk_int[4]),
    .RESET    (RESET),
    .LOCKED   (LOCKED)
   );

  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: gen_outclk_oddr
      ODDR clkout_oddr
       (
        .Q  (CLK_OUT[count_gen]),
        .C  (clk[count_gen]),
        .CE (1'b1),
        .D1 (1'b1),
        .D2 (1'b0),
        .R  (1'b0),
        .S  (1'b0)
       );
    end
  endgenerate

  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: assign_clks
      assign dft_clk_int[count_gen] = test_i ? scan_clk : clk_int[count_gen];
      assign clk[count_gen]         = dft_clk_int[count_gen];
    end
  endgenerate

  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: counters_1
      always @(posedge dft_reset_int or posedge clk[count_gen]) begin
         if (dft_reset_int) begin
              rst_sync[count_gen]      <= 1'b1;
              rst_sync_int[count_gen]  <= 1'b1;
              rst_sync_int1[count_gen] <= 1'b1;
              rst_sync_int2[count_gen] <= 1'b1;
         end else begin
              rst_sync[count_gen]      <= 1'b0;
              rst_sync_int[count_gen]  <= rst_sync[count_gen];
              rst_sync_int1[count_gen] <= rst_sync_int[count_gen];
              rst_sync_int2[count_gen] <= rst_sync_int1[count_gen];
         end
      end
    end
  endgenerate

  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: counters
      always @(posedge clk[count_gen] or posedge rst_sync_int2[count_gen]) begin
        if (rst_sync_int2[count_gen]) begin
          counter[count_gen] <= #TCQ { C_W { 1'b0 } };
        end else begin
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1;
        end
      end
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate
endmodule