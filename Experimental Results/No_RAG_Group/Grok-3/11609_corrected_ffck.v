module hex_ssd (BIN, SSD);
  input [15:0] BIN;
  output reg [0:6] SSD;
  always @(*) begin
    case(BIN)
      0: SSD = 7'b0000001;
      1: SSD = 7'b1001111;
      2: SSD = 7'b0010010;
      3: SSD = 7'b0000110;
      4: SSD = 7'b1001100;
      5: SSD = 7'b0100100;
      6: SSD = 7'b0100000;
      7: SSD = 7'b0001111;
      8: SSD = 7'b0000000;
      9: SSD = 7'b0001100;
      10: SSD = 7'b0001000;
      11: SSD = 7'b1100000;
      12: SSD = 7'b0110001;
      13: SSD = 7'b1000010;
      14: SSD = 7'b0110000;
      15: SSD = 7'b0111000;
      default: SSD = 7'b1111111;
    endcase
  end
endmodule

module lab4_part4_corrected_ffc (CLOCK_50, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, KEY);
  input CLOCK_50;
  input [3:0] KEY;
  output reg [15:0] LEDR;
  output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
  wire [25:0] Q;
  wire [15:0] Q2;
  reg Clr, Clr2;
  
  counter_26bit C0 (
    .enable(1'b1),
    .clk(CLOCK_50),
    .clr(Clr),
    .count(Q)
  );
  
  counter_16bit DISPLAY (
    .enable(1'b1),
    .clk(CLOCK_50),
    .clr(Clr2),
    .count(Q2)
  );
  
  always @(posedge CLOCK_50) begin
    if (Q >= 50000000)
      Clr <= 1'b1;
    else
      Clr <= 1'b0;
  end
  
  always @(posedge CLOCK_50) begin
    if (Q2 >= 9)
      Clr2 <= 1'b1;
    else
      Clr2 <= 1'b0;
  end
  
  always @(posedge CLOCK_50) begin
    LEDR[4] <= Q2[0];
  end
  
  b2d_ssd H0 (
    .X(Q2[3:0]),
    .SSD(HEX0)
  );
  
  assign HEX7 = 7'b1111111;
  assign HEX6 = 7'b1111111;
  assign HEX5 = 7'b1111111;
  assign HEX4 = 7'b1111111;
  assign HEX3 = 7'b1111111;
  assign HEX2 = 7'b1111111;
  assign HEX1 = 7'b1111111;
endmodule

module b2d_ssd (X, SSD);
  input [3:0] X;
  output reg [0:6] SSD;
  always @(*) begin
    case(X)
      0: SSD = 7'b0000001;
      1: SSD = 7'b1001111;
      2: SSD = 7'b0010010;
      3: SSD = 7'b0000110;
      4: SSD = 7'b1001100;
      5: SSD = 7'b0100100;
      6: SSD = 7'b0100000;
      7: SSD = 7'b0001111;
      8: SSD = 7'b0000000;
      9: SSD = 7'b0001100;
      default: SSD = 7'b1111111;
    endcase
  end
endmodule

module counter_26bit (enable, clk, clr, count);
  input enable, clk, clr;
  output reg [25:0] count;
  always @(posedge clk or posedge clr) begin
    if (clr)
      count <= 26'b0;
    else if (enable)
      count <= count + 1;
  end
endmodule

module counter_16bit (enable, clk, clr, count);
  input enable, clk, clr;
  output reg [15:0] count;
  always @(posedge clk or posedge clr) begin
    if (clr)
      count <= 16'b0;
    else if (enable)
      count <= count + 1;
  end
endmodule