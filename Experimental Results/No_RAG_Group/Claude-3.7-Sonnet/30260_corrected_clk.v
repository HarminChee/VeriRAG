`timescale 1ps/1ps
module Clock48MHZ_exdes
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [4:1]  CLK_OUT,
  output [4:1]  COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 4;
  genvar        count_gen;
  wire          reset_int = !LOCKED || COUNTER_RESET;
   reg [NUM_C:1] rst_sync;
   reg [NUM_C:1] rst_sync_int;
   reg [NUM_C:1] rst_sync_int1;
   reg [NUM_C:1] rst_sync_int2;
  //wire [NUM_C:1] clk_int;  // Remove internally generated clocks
  //wire [NUM_C:1] clk;       // Remove internally generated clocks
  reg [C_W-1:0]  counter [NUM_C:1];
  wire clk_int1, clk_int2, clk_int3, clk_int4;

  Clock48MHZ clknetwork
   (
    .CLK_100            (CLK_IN1),
    .CLK_48           (clk_int1),
    .CLK_OUT1           (clk_int2),
    .CLK_OUT2           (clk_int3),
    .CLK_OUT4           (clk_int4),
    .LOCKED             (LOCKED));

  wire [NUM_C:1] clk = {clk_int1, clk_int2, clk_int3, clk_int4}; // Group the clocks into a vector

genvar clk_out_pins;
generate 
  for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1) 
  begin: gen_outclk_oddr
  ODDR clkout_oddr
   (.Q  (CLK_OUT[clk_out_pins]),
    .C  (CLK_IN1),  // Use CLK_IN1 as the primary clock input
    .CE (1'b1),
    .D1 (1'b1),
    .D2 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
  end
endgenerate
  //assign clk[1] = clk_int[1];
  //assign clk[2] = clk_int[2];
  //assign clk[3] = clk_int[3];
  //assign clk[4] = clk_int[4];
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
    always @(posedge reset_int or posedge CLK_IN1) begin  // Use CLK_IN1
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
    always @(posedge CLK_IN1 or posedge rst_sync_int2[count_gen]) begin // Use CLK_IN1
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