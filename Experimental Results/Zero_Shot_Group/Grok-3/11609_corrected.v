module hex_ssd (BIN, SSD);
  input [15:0] BIN;
  output reg [0:6] SSD;
  always @(*) begin
    case(BIN)
      4'h0: SSD = 7'b0000001;
      4'h1: SSD = 7'b1001111;
      4'h2: SSD = 7'b0010010;
      4'h3: SSD = 7'b0000110;
      4'h4: SSD = 7'b1001100;
      4'h5: SSD = 7'b0100100;
      4'h6: SSD = 7'b0100000;
      4'h7: SSD = 7'b0001111;
      4'h8: SSD = 7'b0000000;
      4'h9: SSD = 7'b0001100;
      4'hA: SSD = 7'b0001000;
      4'hB: SSD = 7'b1100000;
      4'hC: SSD = 7'b0110001;
      4'hD: SSD = 7'b1000010;
      4'hE: SSD = 7'b0110000;
      4'hF: SSD = 7'b0111000;
      default: SSD = 7'b1111111;
    endcase
  end
endmodule

module lab4_part4 (CLOCK_50, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, KEY);
  input CLOCK_50;
  input [3:0] KEY;
  output reg [15:0] LEDR;
  output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
  
  wire [25:0] Q;
  wire [15:0] Q2;
  reg Clr, Clr2;
  
  counter_26bit C0 (.enable(1'b1), .clk(CLOCK_50), .clear(Clr), .Q(Q));
  counter_16bit DISPLAY (.enable(1'b1), .clk(CLOCK_50), .clear(Clr2), .Q(Q2));
  
  always @(negedge CLOCK_50) begin
    if (Q >= 26'd50000000) begin
      Clr = 1'b1;
    end else begin
      Clr = 1'b0;
    end
  end
  
  always @(negedge CLOCK_50) begin
    if (Q2 >= 16'd9) begin
      Clr2 = 1'b1;
    end else begin
      Clr2 = 1'b0;
    end
  end
  
  t_flipflop T0 (.T(1'b1), .clk(Clr), .reset(1'b0), .Q(LEDR[4]));
  b2d_ssd H0 (.X(Q2[3:0]), .SSD(HEX0));
  
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
      4'h0: SSD = 7'b0000001;
      4'h1: SSD = 7'b1001111;
      4'h2: SSD = 7'b0010010;
      4'h3: SSD = 7'b0000110;
      4'h4: SSD = 7'b1001100;
      4'h5: SSD = 7'b0100100;
      4'h6: SSD = 7'b0100000;
      4'h7: SSD = 7'b0001111;
      4'h8: SSD = 7'b0000000;
      4'h9: SSD = 7'b0001100;
      default: SSD = 7'b1111111;
    endcase
  end
endmodule

module counter_26bit (enable, clk, clear, Q);
  input enable, clk, clear;
  output reg [25:0] Q;
  always @(posedge clk or posedge clear) begin
    if (clear)
      Q <= 26'd0;
    else if (enable)
      Q <= Q + 1;
  end
endmodule

module counter_16bit (enable, clk, clear, Q);
  input enable, clk, clear;
  output reg [15:0] Q;
  always @(posedge clk or posedge clear) begin
    if (clear)
      Q <= 16'd0;
    else if (enable)
      Q <= Q + 1;
  end
endmodule

module t_flipflop (T, clk, reset, Q);
  input T, clk, reset;
  output reg Q;
  always @(posedge clk or posedge reset) begin
    if (reset)
      Q <= 1'b0;
    else if (T)
      Q <= ~Q;
  end
endmodule