module hex_ssd (BIN, SSD);
  input [3:0] BIN;
  output reg [6:0] SSD;
  always @* begin
    case(BIN)
      4'h0: SSD = 7'b0111111;
      4'h1: SSD = 7'b0000110;
      4'h2: SSD = 7'b1011011;
      4'h3: SSD = 7'b1001111;
      4'h4: SSD = 7'b1100110;
      4'h5: SSD = 7'b1101101;
      4'h6: SSD = 7'b1111101;
      4'h7: SSD = 7'b0000111;
      4'h8: SSD = 7'b1111111;
      4'h9: SSD = 7'b1101111;
      4'hA: SSD = 7'b1110111;
      4'hB: SSD = 7'b1111001;
      4'hC: SSD = 7'b0111000;
      4'hD: SSD = 7'b1011110;
      4'hE: SSD = 7'b1111001;
      4'hF: SSD = 7'b1110001;
      default: SSD = 7'bx;
    endcase
  end
endmodule

module lab4_part4 (CLOCK_50, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, KEY);
  input CLOCK_50;
  input [3:0] KEY;
  output [15:0] LEDR;
  output [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

  wire [25:0] Q;
  wire [3:0] Q2;
  reg Clr = 0;
  reg Clr2 = 0;

  counter_26bit C0 (CLOCK_50, Clr, Q);
  counter_4bit DISPLAY (CLOCK_50, Clr, Clr2, Q2);

  always @(posedge CLOCK_50) begin
    if (Q >= 50000000 - 1) begin
      Clr <= 1;
    end else begin
      Clr <= 0;
    end
  end

  always @(posedge Clr) begin
    if (Q2 >= 9) begin
      Clr2 <= 1;
    end else begin
      Clr2 <= 0;
    end
  end

  t_flipflop T0 (CLOCK_50, Clr, LEDR[4]);
  b2d_ssd H0 (Q2, HEX0);
  hex_ssd H1 (Q2, HEX1);
  hex_ssd H2 (Q2, HEX2);
  hex_ssd H3 (Q2, HEX3);
  hex_ssd H4 (Q2, HEX4);
  hex_ssd H5 (Q2, HEX5);
  hex_ssd H6 (Q2, HEX6);
  hex_ssd H7 (Q2, HEX7);

endmodule

module b2d_ssd (X, SSD);
  input [3:0] X;
  output reg [6:0] SSD;
  always @* begin
    case(X)
      4'h0: SSD = 7'b0111111;
      4'h1: SSD = 7'b0000110;
      4'h2: SSD = 7'b1011011;
      4'h3: SSD = 7'b1001111;
      4'h4: SSD = 7'b1100110;
      4'h5: SSD = 7'b1101101;
      4'h6: SSD = 7'b1111101;
      4'h7: SSD = 7'b0000111;
      4'h8: SSD = 7'b1111111;
      4'h9: SSD = 7'b1101111;
      default: SSD = 7'bx;
    endcase
  end
endmodule

module counter_26bit (
    input clk,
    input rst,
    output reg [25:0] count
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0;
    end else begin
        count <= count + 1;
    end
end

endmodule

module counter_4bit (
    input clk,
    input rst,
    input enable,
    output reg [3:0] count
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0;
    end else if (enable) begin
        count <= count + 1;
    end
end

endmodule

module t_flipflop (
    input clk,
    input rst,
    output reg q
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        q <= 0;
    end else begin
        q <= ~q;
    end
end

endmodule