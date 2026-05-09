`timescale 1ps/1ps
module pll_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [2:1]  CLK_OUT,
  output [2:1]  COUNT
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 2;
  genvar        count_gen;
  wire          reset_int = COUNTER_RESET;
  reg  [NUM_C:1] rst_sync;
  reg  [NUM_C:1] rst_sync_int;
  reg  [NUM_C:1] rst_sync_int1;
  reg  [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk_n;
  wire [NUM_C:1] clk;
  reg  [C_W-1:0] counter [NUM_C:1];

  pll clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2])
   );

  genvar clk_out_pins;
  generate 
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1) 
    begin: gen_outclk_oddr
      assign clk_n[clk_out_pins] = ~clk[clk_out_pins];
      ODDR2 clkout_oddr
       (
        .Q  (CLK_OUT[clk_out_pins]),
        .C0 (clk[clk_out_pins]),
        .C1 (clk_n[clk_out_pins]),
        .CE (1'b1),
        .D0 (1'b1),
        .D1 (1'b0),
        .R  (1'b0),
        .S  (1'b0)
       );
    end
  endgenerate

  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];

  generate 
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) 
    begin: counters_1
      always @(posedge reset_int or posedge clk[count_gen]) 
      begin
        if (reset_int) 
        begin
          rst_sync[count_gen]     <= #TCQ 1'b1;
          rst_sync_int[count_gen] <= #TCQ 1'b1;
          rst_sync_int1[count_gen]<= #TCQ 1'b1;
          rst_sync_int2[count_gen]<= #TCQ 1'b1;
        end
        else 
        begin
          rst_sync[count_gen]     <= #TCQ 1'b0;
          rst_sync_int[count_gen] <= #TCQ rst_sync[count_gen];     
          rst_sync_int1[count_gen]<= #TCQ rst_sync_int[count_gen]; 
          rst_sync_int2[count_gen]<= #TCQ rst_sync_int1[count_gen];
        end
      end
    end
  endgenerate

  generate 
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) 
    begin: counters
      always @(posedge clk[count_gen] or posedge rst_sync_int2[count_gen]) 
      begin
        if (rst_sync_int2[count_gen]) 
        begin
          counter[count_gen] <= #TCQ {C_W{1'b0}};
        end 
        else 
        begin
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1;
        end
      end
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate
endmodule