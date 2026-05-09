module counter_26bit (enable, clk, reset, q);
  input enable, clk, reset;
  output reg [25:0] q;
  always @(posedge clk or posedge reset) begin
    if (reset)
      q <= 26'b0;
    else if (enable)
      q <= q + 1'b1;
  end
endmodule

module counter_16bit (enable, clk, reset, q);
  input enable, clk, reset;
  output reg [15:0] q;
  always @(posedge clk or posedge reset) begin
    if (reset)
      q <= 16'b0;
    else if (enable)
      q <= q + 1'b1;
  end
endmodule

module t_flipflop (t, clk, reset, q);
  input t, clk, reset;
  output reg q;
  always @(posedge clk or posedge reset) begin
    if (reset)
      q <= 1'b0;
    else if (t)
      q <= ~q;
  end
endmodule

module b2d_ssd (X, SSD);
  input [3:0] X;
  output reg [0:6] SSD;
  always @(*) begin
    case(X)
      4'd0:  SSD = 7'b0000001;
      4'd1:  SSD = 7'b1001111;
      4'd2:  SSD = 7'b0010010;
      4'd3:  SSD = 7'b0000110;
      4'd4:  SSD = 7'b1001100;
      4'd5:  SSD = 7'b0100100;
      4'd6:  SSD = 7'b0100000;
      4'd7:  SSD = 7'b0001111;
      4'd8:  SSD = 7'b0000000;
      4'd9:  SSD = 7'b0001100;
      default: SSD = 7'b1111111;
    endcase
  end
endmodule

module hex_ssd (BIN, SSD);
  input [15:0] BIN;
  output reg [0:6] SSD;
  always @(*) begin
    case(BIN)
      16'd0:  SSD = 7'b0000001;
      16'd1:  SSD = 7'b1001111;
      16'd2:  SSD = 7'b0010010;
      16'd3:  SSD = 7'b0000110;
      16'd4:  SSD = 7'b1001100;
      16'd5:  SSD = 7'b0100100;
      16'd6:  SSD = 7'b0100000;
      16'd7:  SSD = 7'b0001111;
      16'd8:  SSD = 7'b0000000;
      16'd9:  SSD = 7'b0001100;
      16'd10: SSD = 7'b0001000;
      16'd11: SSD = 7'b1100000;
      16'd12: SSD = 7'b0110001;
      16'd13: SSD = 7'b1000010;
      16'd14: SSD = 7'b0110000;
      16'd15: SSD = 7'b0111000;
      default: SSD = 7'b1111111;
    endcase
  end
endmodule

module lab4_part4 (CLOCK_50, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, KEY);
  input CLOCK_50;
  input [3:0] KEY;
  output [15:0] LEDR;
  output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

  wire [25:0] Q;
  wire [15:0] Q2;
  reg Clr, Clr2;

  counter_26bit C0 (1'b1, CLOCK_50, Clr, Q);
  counter_16bit DISPLAY (1'b1, Clr, Clr2, Q2);

  always @(negedge CLOCK_50) begin
    if (Q >= 26'd50000000)
      Clr <= 1'b1;
    else
      Clr <= 1'b0;
  end

  always @(negedge Clr) begin
    if (Q2 >= 16'd9)
      Clr2 <= 1'b1;
    else
      Clr2 <= 1'b0;
  end

  t_flipflop T0 (1'b1, Clr, 1'b0, LEDR[4]);
  b2d_ssd H0 (Q2[3:0], HEX0);
endmodule