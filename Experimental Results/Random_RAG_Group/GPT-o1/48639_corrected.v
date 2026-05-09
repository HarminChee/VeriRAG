`timescale 1ps/1ps
`timescale 1ps/1ps
module ddr3_clkgen_exdes 
 #(
  parameter TCQ = 100
 )
 (
  input         scan_clk,
  input         test_i,
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [3:1]  CLK_OUT,
  output [3:1]  COUNT,
  input         RESET,
  output        LOCKED
 );

  localparam    C_W       = 16;
  localparam    NUM_C     = 3;

  genvar        count_gen;
  wire          func_reset = !LOCKED || RESET || COUNTER_RESET;
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk;
  wire [NUM_C:1] dft_clk;
  wire          dft_reset;

  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2;
  reg [C_W-1:0]  counter [NUM_C:1];

  assign dft_reset = test_i ? 1'b0 : func_reset;

  ddr3_clkgen clknetwork
  (
    .clk50in  (CLK_IN1),
    .clk50    (clk_int[1]),
    .clk400   (clk_int[2]),
    .clk100   (clk_int[3]),
    .RESET    (RESET),
    .LOCKED   (LOCKED)
  );

  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];
  assign CLK_OUT = clk_int;

  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: GEN_DFT_CLK
      assign dft_clk[count_gen] = test_i ? scan_clk : clk_int[count_gen];
    end
  endgenerate

  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1)
    begin: counters_1
      always @(posedge dft_reset or posedge dft_clk[count_gen]) begin
        if (dft_reset) begin
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
      always @(posedge dft_clk[count_gen] or posedge rst_sync_int2[count_gen]) begin
        if (rst_sync_int2[count_gen])
          counter[count_gen] <= #TCQ {C_W{1'b0}};
        else
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1;
      end
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate

endmodule