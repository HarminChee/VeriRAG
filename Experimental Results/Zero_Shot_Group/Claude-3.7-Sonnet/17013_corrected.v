`timescale 1 ns / 1 ps
module dac_control
(
  input clk,
  input enable_update,
  input enable,
  input [7:0]dbA,
  input [7:0]dbB,
  input [7:0]dbC,
  input [7:0]dbD,
  output reg [7:0]db,
  output wire clr_n,
  output wire pd_n,
  output reg cs_n,
  output reg wr_n,
  output reg [1:0]A,
  output reg ldac_n
);
reg [7:0] clk_div;
reg clk_int;
always @(posedge clk) begin
  clk_div <= clk_div + 1;
  clk_int <= (clk_div == 8'HFF);
end
assign clr_n = enable;
assign pd_n = 1;
reg [7:0]dbA_prev;
reg [7:0]dbB_prev;
reg [7:0]dbC_prev;
reg [7:0]dbD_prev;
reg update_trigger;
always @(posedge clk_int) begin
  if (enable_update) begin
    if ((dbA != dbA_prev) || (dbB != dbB_prev) || (dbC != dbC_prev) || (dbD != dbD_prev))
      update_trigger <= 1;
    else
      update_trigger <= 0;
    dbA_prev <= dbA;
    dbB_prev <= dbB;
    dbC_prev <= dbC;
    dbD_prev <= dbD;
  end
end
reg [3:0] cntr;
always @(posedge clk_int) begin
  if ((update_trigger == 1) || (cntr != 4'b0000)) begin
    cntr <= (cntr + 1) % 10;
    case (cntr)
      4'b0000 : begin
        A <= 2'b00;
        db <= dbA;
        wr_n <= 0;
      end
      4'b0001 :
        wr_n <= 1;
      4'b0010 : begin
        A <= 2'b01;
        db <= dbB;
        wr_n <= 0;
      end
      4'b0011 :
        wr_n <= 1;
      4'b0100 : begin
        A <= 2'b10;
        db <= dbC;
        wr_n <= 0;
      end
      4'b0101 :
        wr_n <= 1;
      4'b0110 : begin
        A <= 2'b11;
        db <= dbD;
        wr_n <= 0;
      end
      4'b0111 :
        wr_n <= 1;
      4'b1000 :
        ldac_n <= 0;
      4'b1001 :
        ldac_n <= 1;
      default : ;
    endcase
  end
end
initial begin
  clk_div = 0;
  cntr = 0;
  wr_n = 1;
  ldac_n = 1;
  cs_n = 0;
end
endmodule