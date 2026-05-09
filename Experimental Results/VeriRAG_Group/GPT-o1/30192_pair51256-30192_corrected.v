`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ps2_receiver(
    input wire  test_i,
    input wire  scan_clk,
    input wire  clk,
    input wire  clr,
    input wire  ps2c,
    input wire  ps2d,
    output wire [15:0] xkey
    );

  wire dft_clk;
  assign dft_clk = test_i ? scan_clk : clk;

  reg  PS2Cf, PS2Df;
  reg  [ 7:0] ps2c_filter, ps2d_filter;
  reg  [10:0] shift1, shift2;
  reg         old_PS2Cf;

  assign xkey = {shift2[8:1], shift1[8:1]};

  always @(posedge dft_clk or posedge clr)
  begin
    if (clr)
    begin
      ps2c_filter <= 8'b0;
      ps2d_filter <= 8'b0;
      PS2Cf       <= 1'b1;
      PS2Df       <= 1'b1;
    end
    else
    begin
      ps2c_filter <= {ps2c, ps2c_filter[7:1]};
      ps2d_filter <= {ps2d, ps2d_filter[7:1]};
      if (ps2c_filter == 8'b1111_1111)
        PS2Cf <= 1'b1;
      else if (ps2c_filter == 8'b0000_0000)
        PS2Cf <= 1'b0;
      if (ps2d_filter == 8'b1111_1111)
        PS2Df <= 1'b1;
      else if (ps2d_filter == 8'b0000_0000)
        PS2Df <= 1'b0;
    end
  end

  always @(posedge dft_clk or posedge clr)
  begin
    if (clr)
    begin
      shift1    <= 11'b0;
      shift2    <= 11'b1;
      old_PS2Cf <= 1'b1;
    end
    else
    begin
      old_PS2Cf <= PS2Cf;
      if (!PS2Cf && old_PS2Cf)
      begin
        shift1 <= {PS2Df, shift1[10:1]};
        shift2 <= {shift1[0], shift2[10:1]};
      end
    end
  end

endmodule