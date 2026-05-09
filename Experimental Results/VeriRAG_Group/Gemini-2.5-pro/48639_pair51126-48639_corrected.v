`timescale 1ps/1ps
`timescale 1ps/1ps
module ddr3_clkgen_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i,  // Added for DFT
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

  wire          reset_int = !LOCKED || RESET || COUNTER_RESET;
  wire          dft_async_reset_source = test_i ? (RESET || COUNTER_RESET) : reset_int; // DFT reset mux

   reg [NUM_C:1] rst_sync;
   reg [NUM_C:1] rst_sync_int;
   reg [NUM_C:1] rst_sync_int1;
   reg [NUM_C:1] rst_sync_int2;

  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk;
  wire [NUM_C:1] dft_clk; // DFT clock mux output

  reg [C_W-1:0]  counter [NUM_C:1];

  ddr3_clkgen clknetwork
   (
    .clk50in            (CLK_IN1),
    .clk50           (clk_int[1]),
    .clk400           (clk_int[2]),
    .clk100           (clk_int[3]),
    .RESET              (RESET),
    .LOCKED             (LOCKED));

  assign CLK_OUT =  clk_int;
  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];

  // DFT Clock Generation
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: dft_clk_gen
     assign dft_clk[count_gen] = test_i ? CLK_IN1 : clk[count_gen];
  end
  endgenerate

  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
    // Using DFT clock and DFT asynchronous reset source
    always @(posedge dft_clk[count_gen] or posedge dft_async_reset_source) begin
       if (dft_async_reset_source) begin // Use DFT reset
            rst_sync[count_gen] <= 1'b1;
            rst_sync_int[count_gen]<= 1'b1;
            rst_sync_int1[count_gen]<= 1'b1;
            rst_sync_int2[count_gen]<= 1'b1;
       end
       else begin
            rst_sync[count_gen] <= 1'b0;
            rst_sync_int[count_gen] <= rst_sync[count_gen];
            rst_sync_int1[count_gen] <= rst_sync_int[count_gen];
            rst_sync_int2[count_gen] <= rst_sync_int1[count_gen];
       end
    end
  end
  endgenerate

  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
    // Using DFT clock. rst_sync_int2 is now derived from controllable sources in test mode.
    always @(posedge dft_clk[count_gen] or posedge rst_sync_int2[count_gen]) begin
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