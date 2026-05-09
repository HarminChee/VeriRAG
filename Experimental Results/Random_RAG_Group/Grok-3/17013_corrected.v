`timescale 1 ns / 1 ps
module dac_control
(
  input wire test_i,
  input wire clk,
  input wire rst,
  input wire enable_update,
  input wire enable,
  input wire [7:0] dbA,
  input wire [7:0] dbB,
  input wire [7:0] dbC,
  input wire [7:0] dbD,
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
wire dft_clk;
assign dft_clk = test_i ? clk : clk_int;
always @(posedge clk or posedge rst) begin
  if (rst) begin
    clk_div <= 8'd0;
    clk_int <= 1'b0;
  end else begin
    clk_div <= clk_div + 1;
    clk_int <= (clk_div == 8'hFF);
  end
end
assign clr_n = enable;
assign pd_n = 1'b1;
reg [7:0] dbA_prev;
reg [7:0] dbB_prev;
reg [7:0] dbC_prev;
reg [7:0] dbD_prev;
reg update_trigger;
always @(posedge dft_clk or posedge rst) begin
  if (rst) begin
    dbA_prev <= 8'd0;
    dbB_prev <= 8'd0;
    dbC_prev <= 8'd0;
    dbD_prev <= 8'd0;
    update_trigger <= 1'b0;
  end else if (enable_update) begin
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
always @(posedge dft_clk or posedge rst) begin
  if (rst) begin
    cntr <= 4'd0;
    A <= 2'b00;
    db <= 8'd0;
    wr_n <= 1'b1;
    ldac_n <= 1'b1;
  end else if ((update_trigger == 1'b1) || (cntr != 4'd0)) begin
    cntr <= (cntr + 1) % 11;
    case (cntr)
      4'd0 : begin
        A <= 2'b00;
        db <= dbA;
        wr_n <= 1'b0;
      end
      4'd1 : begin
        wr_n <= 1'b1;
      end
      4'd2 : begin
        A <= 2'b01;
        db <= dbB;
        wr_n <= 1'b0;
      end
      4'd3 : begin
        wr_n <= 1'b1;
      end
      4'd4 : begin
        A <= 2'b10;
        db <= dbC;
        wr_n <= 1'b0;
      end
      4'd5 : begin
        wr_n <= 1'b1;
      end
      4'd6 : begin
        A <= 2'b11;
        db <= dbD;
        wr_n <= 1'b0;
      end
      4'd7 : begin
        wr_n <= 1'b1;
      end
      4'd8 : begin
        wr_n <= 1'b0;
      end
      4'd9 : begin
        ldac_n <= 1'b1;
      end
      4'd10 : begin
        ldac_n <= 1'b0;
      end
    endcase
  end
end
endmodule