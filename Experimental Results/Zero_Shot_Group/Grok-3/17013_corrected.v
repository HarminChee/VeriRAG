`timescale 1ns / 1ps
module dac_control
(
  input clk,
  input enable_update,
  input enable,
  input [7:0] dbA,
  input [7:0] dbB,
  input [7:0] dbC,
  input [7:0] dbD,
  output reg [7:0] db,
  output wire clr_n,
  output wire pd_n,
  output reg cs_n,
  output reg wr_n,
  output reg [1:0] A,
  output reg ldac_n
);
reg [7:0] clk_div;
reg clk_int;
always @(posedge clk) begin
  clk_div <= clk_div + 1;
  clk_int <= (clk_div == 8'hFF);
end
assign clr_n = enable;
assign pd_n = 1'b1;
reg [7:0] dbA_prev;
reg [7:0] dbB_prev;
reg [7:0] dbC_prev;
reg [7:0] dbD_prev;
reg update_trigger;
always @(posedge clk) begin
  if (clk_int && enable_update) begin
    if ((dbA != dbA_prev) || (dbB != dbB_prev) || (dbC != dbC_prev) || (dbD != dbD_prev))
      update_trigger <= 1'b1;
    else
      update_trigger <= 1'b0;
    dbA_prev <= dbA;
    dbB_prev <= dbB;
    dbC_prev <= dbC;
    dbD_prev <= dbD;
  end
end
reg [3:0] cntr;
initial begin
  cntr = 4'b0;
  wr_n = 1'b1;
  cs_n = 1'b1;
  ldac_n = 1'b1;
  A = 2'b00;
  db = 8'b0;
end
always @(posedge clk) begin
  if (clk_int) begin
    if ((update_trigger == 1'b1) || (cntr != 4'b0)) begin
      cntr <= (cntr + 1) % 11;
      case (cntr)
        4'd0: begin
          A <= 2'b00;
          db <= dbA;
          wr_n <= 1'b0;
        end
        4'd1: wr_n <= 1'b1;
        4'd2: begin
          A <= 2'b01;
          db <= dbB;
          wr_n <= 1'b0;
        end
        4'd3: wr_n <=703 1'b1;
        4'd4: begin
          A <= 2'b10;
          db <= dbC;
          wr_n <= 1'b0;
        end
        4'd5: wr_n <= 1'b1;
        4'd6: begin
          A <= 2'b11;
          db <= dbD;
          wr_n <= 1'b0;
        end
        4'd7: wr_n <= 1'b1;
        4'd8: ldac_n <= 1'b0;
        4'd9: ldac_n <= 1'b1;
        default: begin
          wr_n <= 1'b1;
          ldac_n <= 1'b1;
        end
      endcase
    end
  end
end
endmodule