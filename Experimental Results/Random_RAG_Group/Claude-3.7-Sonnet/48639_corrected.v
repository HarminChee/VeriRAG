`timescale 1ps/1ps
`timescale 1ps/1ps
module ddr3_clkgen_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [3:1]  CLK_OUT,
  output [3:1]  COUNT,
  input         RESET,
  input         test_mode_i,
  output        LOCKED
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 3;
  genvar        count_gen;
  wire          reset_int = !LOCKED || RESET || COUNTER_RESET;
  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk;
  wire [NUM_C:1] dft_clk;
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
  assign dft_clk[1] = test_mode_i ? CLK_IN1 : clk_int[1];
  assign dft_clk[2] = test_mode_i ? CLK_IN1 : clk_int[2];
  assign dft_clk[3] = test_mode_i ? CLK_IN1 : clk_int[3];
  assign clk[1] = dft_clk[1];
  assign clk[2] = dft_clk[2];
  assign clk[3] = dft_clk[3];
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
    always @(posedge CLK_IN1 or posedge reset_int) begin
       if (reset_int) begin
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
    always @(posedge clk[count_gen] or posedge rst_sync_int2[count_gen]) begin
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