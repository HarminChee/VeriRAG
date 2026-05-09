module hex_ssd (BIN, SSD);
  input [3:0] BIN;
  output reg [0:6] SSD;
  always @(*) begin
    case(BIN)
      4'd0: SSD = 7'b0000001;
      4'd1: SSD = 7'b1001111;
      4'd2: SSD = 7'b0010010;
      4'd3: SSD = 7'b0000110;
      4'd4: SSD = 7'b1001100;
      4'd5: SSD = 7'b0100100;
      4'd6: SSD = 7'b0100000;
      4'd7: SSD = 7'b0001111;
      4'd8: SSD = 7'b0000000;
      4'd9: SSD = 7'b0001100;
      4'd10: SSD = 7'b0001000;
      4'd11: SSD = 7'b1100000;
      4'd12: SSD = 7'b0110001;
      4'd13: SSD = 7'b1000010;
      4'd14: SSD = 7'b0110000;
      4'd15: SSD = 7'b0111000;
      default: SSD = 7'b1111111; // Default case to handle unknown values
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

  counter_26bit C0 (1, CLOCK_50, Clr, Q);
  counter_16bit DISPLAY (1, Clr, Clr2, Q2);

  always @(posedge CLOCK_50) begin
    if (Q >= 50000000) begin
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

  t_flipflop T0 (1, Clr, 0, LEDR[4]);
  b2d_ssd H0 (Q2[3:0], HEX0);
endmodule

module b2d_ssd (X, SSD);
  input [3:0] X;
  output reg [0:6] SSD;
  always @(*) begin
    case(X)
      4'd0: SSD = 7'b0000001;
      4'd1: SSD = 7'b1001111;
      4'd2: SSD = 7'b0010010;
      4'd3: SSD = 7'b0000110;
      4'd4: SSD = 7'b1001100;
      4'd5: SSD = 7'b0100100;
      4'd6: SSD = 7'b0100000;
      4'd7: SSD = 7'b0001111;
      4'd8: SSD = 7'b0000000;
      4'd9: SSD = 7'b0001100;
      default: SSD = 7'b1111111; // Default case to handle unknown values
    endcase
  end
endmodule