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
  output        LOCKED,
  input         test_i
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
  wire [3:1] clk;
  wire [3:1] clk_dft;
  
  assign clk_dft[1] = test_i ? CLK_IN1 : clk_int[1];
  assign clk_dft[2] = test_i ? CLK_IN1 : clk_int[2];
  assign clk_dft[3] = test_i ? CLK_IN1 : clk_int[3];
  
  ddr3_clkgen clknetwork
   (
    .clk50in            (CLK_IN1),
    .clk50           (clk_int[1]),
    .clk400           (clk_int[2]),
    .clk100           (clk_int[3]),
    .RESET              (RESET),
    .LOCKED             (LOCKED));
  
  assign CLK_OUT = clk_dft;
  assign clk[1] = clk_dft[1];
  assign clk[2] = clk_dft[2];
  assign clk[3] = clk_dft[3];
  
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
    always @(posedge reset_int or posedge clk[count_gen]) begin
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
    reg [C_W-1:0] counter;
    always @(posedge clk[count_gen] or posedge rst_sync_int2[count_gen]) begin
      if (rst_sync_int2[count_gen]) begin
        counter <= #TCQ { C_W { 1'b 0 } };
      end else begin
        counter <= #TCQ counter + 1'b 1;
      end
    end
    assign COUNT[count_gen] = counter[C_W-1];
  end
  endgenerate
endmodule