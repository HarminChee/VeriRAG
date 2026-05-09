`timescale 1ps/1ps

module clk_gen_83M_exdes_corrected 
 #(
   parameter TCQ = 100
 )
 (
   input  [3:1]  CLK_IN,
   input         COUNTER_RESET,
   output [3:1]  COUNT,
   input         RESET,
   output        LOCKED
 );

  localparam    C_W   = 16;
  localparam    NUM_C = 3;

  genvar        count_gen;

  wire          reset_int = RESET || COUNTER_RESET;
  assign LOCKED = 1'b1;

  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2;

  reg [C_W-1:0] counter [NUM_C:1];

  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin : counters_reset
      always @(posedge reset_int or posedge CLK_IN[count_gen]) begin
        if (reset_int) begin
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
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin : counters
      always @(posedge CLK_IN[count_gen] or posedge rst_sync_int2[count_gen]) begin
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