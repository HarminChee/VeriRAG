`timescale 1ps/1ps
`timescale 1ps/1ps
module cf_mul (
  clk,
  data_a,
  data_b,
  data_p,
  ddata_in,
  ddata_out);
  parameter DELAY_DATA_WIDTH = 16;
  parameter DW = DELAY_DATA_WIDTH - 1;
  input           clk;
  input   [16:0]  data_a;
  input   [ 7:0]  data_b;
  output  [24:0]  data_p;
  input   [DW:0]  ddata_in;
  output  [DW:0]  ddata_out;
  reg             p1_sign = 'd0;
  reg     [DW:0]  p1_ddata = 'd0;
  reg     [23:0]  p1_data_p_0 = 'd0;
  reg     [23:0]  p1_data_p_1 = 'd0;
  reg     [23:0]  p1_data_p_2 = 'd0;
  reg     [23:0]  p1_data_p_3 = 'd0;
  reg     [23:0]  p1_data_p_4 = 'd0;
  reg             p2_sign = 'd0;
  reg     [DW:0]  p2_ddata = 'd0;
  reg     [23:0]  p2_data_p_0 = 'd0;
  reg     [23:0]  p2_data_p_1 = 'd0;
  reg             p3_sign = 'd0;
  reg     [DW:0]  p3_ddata = 'd0;
  reg     [23:0]  p3_data_p_0 = 'd0;
  reg     [DW:0]  ddata_out = 'd0;
  reg     [24:0]  data_p = 'd0;
  wire    [16:0]  p1_data_a_1p_17_s;
  wire    [16:0]  p1_data_a_1n_17_s;
  wire    [23:0]  p1_data_a_1p_s;
  wire    [23:0]  p1_data_a_1n_s;
  wire    [23:0]  p1_data_a_2p_s;
  wire    [23:0]  p1_data_a_2n_s;
  assign p1_data_a_1p_17_s = {1'b0, data_a[15:0]};
  assign p1_data_a_1n_17_s = ~p1_data_a_1p_17_s + 1'b1;
  assign p1_data_a_1p_s = {{7{p1_data_a_1p_17_s[16]}}, p1_data_a_1p_17_s};
  assign p1_data_a_1n_s = {{7{p1_data_a_1n_17_s[16]}}, p1_data_a_1n_17_s};
  assign p1_data_a_2p_s = {{6{p1_data_a_1p_17_s[16]}}, p1_data_a_1p_17_s, 1'b0};
  assign p1_data_a_2n_s = {{6{p1_data_a_1n_17_s[16]}}, p1_data_a_1n_17_s, 1'b0};
  always @(posedge clk) begin
    p1_sign <= data_a[16];
    p1_ddata <= ddata_in;
    case (data_b[1:0])
      2'b11: p1_data_p_0 <= p1_data_a_1n_s;
      2'b10: p1_data_p_0 <= p1_data_a_2n_s;
      2'b01: p1_data_p_0 <= p1_data_a_1p_s;
      default: p1_data_p_0 <= 24'd0;
    endcase
    case (data_b[3:1])
      3'b011: p1_data_p_1 <= {p1_data_a_2p_s[21:0], 2'd0};
      3'b100: p1_data_p_1 <= {p1_data_a_2n_s[21:0], 2'd0};
      3'b001: p1_data_p_1 <= {p1_data_a_1p_s[21:0], 2'd0};
      3'b010: p1_data_p_1 <= {p1_data_a_1p_s[21:0], 2'd0};
      3'b101: p1_data_p_1 <= {p1_data_a_1n_s[21:0], 2'd0};
      3'b110: p1_data_p_1 <= {p1_data_a_1n_s[21:0], 2'd0};
      default: p1_data_p_1 <= 24'd0;
    endcase
    case (data_b[5:3])
      3'b011: p1_data_p_2 <= {p1_data_a_2p_s[19:0], 4'd0};
      3'b100: p1_data_p_2 <= {p1_data_a_2n_s[19:0], 4'd0};
      3'b001: p1_data_p_2 <= {p1_data_a_1p_s[19:0], 4'd0};
      3'b010: p1_data_p_2 <= {p1_data_a_1p_s[19:0], 4'd0};
      3'b101: p1_data_p_2 <= {p1_data_a_1n_s[19:0], 4'd0};
      3'b110: p1_data_p_2 <= {p1_data_a_1n_s[19:0], 4'd0};
      default: p1_data_p_2 <= 24'd0;
    endcase
    case (data_b[7:5])
      3'b011: p1_data_p_3 <= {p1_data_a_2p_s[17:0], 6'd0};
      3'b100: p1_data_p_3 <= {p1_data_a_2n_s[17:0], 6'd0};
      3'b001: p1_data_p_3 <= {p1_data_a_1p_s[17:0], 6'd0};
      3'b010: p1_data_p_3 <= {p1_data_a_1p_s[17:0], 6'd0};
      3'b101: p1_data_p_3 <= {p1_data_a_1n_s[17:0], 6'd0};
      3'b110: p1_data_p_3 <= {p1_data_a_1n_s[17:0], 6'd0};
      default: p1_data_p_3 <= 24'd0;
    endcase
    case (data_b[7])
      1'b1: p1_data_p_4 <= {p1_data_a_1p_s[15:0], 8'd0};
      default: p1_data_p_4 <= 24'd0;
    endcase
  end
  always @(posedge clk) begin
    p2_sign <= p1_sign;
    p2_ddata <= p1_ddata;
    p2_data_p_0 <= p1_data_p_0 + p1_data_p_1 + p1_data_p_4;
    p2_data_p_1 <= p1_data_p_2 + p1_data_p_3;
  end
  always @(posedge clk) begin
    p3_sign <= p2_sign;
    p3_ddata <= p2_ddata;
    p3_data_p_0 <= p2_data_p_0 + p2_data_p_1;
  end
  always @(posedge clk) begin
    ddata_out <= p3_ddata;
    data_p <= {p3_sign, p3_data_p_0};
  end
endmodule
