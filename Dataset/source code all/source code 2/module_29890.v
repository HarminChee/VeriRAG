`define DATA_LEN 4
module multiplier(
          input wire signed [`DATA_LEN-1:0] src1,
          input wire signed [`DATA_LEN-1:0] src2,
          input wire                src1_signed,
          input wire                src2_signed,
          input wire                sel_lohi,
          output wire [`DATA_LEN-1:0]       result
          );

   wire signed [`DATA_LEN:0]                src1_unsign = {1'b0, src1};
   wire signed [`DATA_LEN:0]                src2_unsign = {1'b0, src2};

   wire signed [2*`DATA_LEN-1:0]            res_ss = src1 * src2;
   wire signed [2*`DATA_LEN-1:0]            res_su = src1 * src2_unsign;
   wire signed [2*`DATA_LEN-1:0]            res_us = src1_unsign * src2;
   wire signed [2*`DATA_LEN-1:0]            res_uu = src1_unsign * src2_unsign;

   wire [2*`DATA_LEN-1:0]               res;

   mux_4x1 mxres(
         .sel({src1_signed, src2_signed}),
         .dat0(res_uu),
         .dat1(res_us),
         .dat2(res_su),
         .dat3(res_ss),
         .out(res)
         );

   assign result = sel_lohi ? res[`DATA_LEN+:`DATA_LEN] : res[`DATA_LEN-1:0];

endmodule // multiplier


/*`timescale 1ns / 1ps
module multiplier
    # (parameter W = 32) (
    input wire clk,
    input wire [W-1:0] Data_A_i,
    input wire [W-1:0] Data_B_i,
    output wire [2*W-1:0] Data_S_o
    );
    reg [2*W-1:0] pdt_int;
    assign Data_S_o=pdt_int;
    always@(posedge clk)
    begin
        pdt_int<= Data_A_i*Data_B_i;
    end
endmodule*/
