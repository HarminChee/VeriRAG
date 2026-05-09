module cf_ss_422to444 (
  clk,
  s422_vs,
  s422_hs,
  s422_de,
  s422_data,
  s444_vs,
  s444_hs,
  s444_de,
  s444_data,
  Cr_Cb_sel_init);
  input           clk;
  input           s422_vs;
  input           s422_hs;
  input           s422_de;
  input   [15:0]  s422_data;
  output          s444_vs;
  output          s444_hs;
  output          s444_de;
  output  [23:0]  s444_data;
  input           Cr_Cb_sel_init;
  reg             Cr_Cb_sel = 'd0;
  reg             s422_vs_d = 'd0;
  reg             s422_hs_d = 'd0;
  reg             s422_de_d = 'd0;
  reg     [23:0]  s422_data_d = 'd0;
  reg             s422_vs_2d = 'd0;
  reg             s422_hs_2d = 'd0;
  reg             s422_de_2d = 'd0;
  reg     [23:0]  s422_data_2d = 'd0;
  reg             s422_vs_3d = 'd0;
  reg             s422_hs_3d = 'd0;
  reg             s422_de_3d = 'd0;
  reg     [23:0]  s422_data_3d = 'd0;
  reg     [ 7:0]  R = 'd0;
  reg     [ 7:0]  B = 'd0;
  reg             s444_vs = 'd0;
  reg             s444_hs = 'd0;
  reg             s444_de = 'd0;
  reg     [23:0]  s444_data = 'd0;
  wire    [ 9:0]  R_s;
  wire    [ 9:0]  B_s;
  always @(posedge clk) begin
    if (s422_de == 1'b1) begin
      Cr_Cb_sel <= ~Cr_Cb_sel;
    end else begin
      Cr_Cb_sel <= Cr_Cb_sel_init;
    end
    s422_vs_d <= s422_vs;
    s422_hs_d <= s422_hs;
    s422_de_d <= s422_de;
    if (s422_de == 1'b1) begin
      if (Cr_Cb_sel == 1'b1) begin
        s422_data_d <= {s422_data[15:8], s422_data[7:0], s422_data_d[7:0]};
      end else begin
        s422_data_d <= {s422_data_d[23:16], s422_data[7:0], s422_data[15:8]};
      end
    end
    s422_vs_2d <= s422_vs_d;
    s422_hs_2d <= s422_hs_d;
    s422_de_2d <= s422_de_d;
    if (s422_de_d == 1'b1) begin
      s422_data_2d <= s422_data_d;
    end
    s422_vs_3d <= s422_vs_2d;
    s422_hs_3d <= s422_hs_2d;
    s422_de_3d <= s422_de_2d;
    if (s422_de_2d == 1'b1) begin
      s422_data_3d <= s422_data_2d;
    end
  end
  assign R_s = {2'd0, s422_data_d[23:16]} + {2'd0, s422_data_3d[23:16]} +
    {1'd0, s422_data_2d[23:16], 1'd0};
  assign B_s = {2'd0, s422_data_d[7:0]} + {2'd0, s422_data_3d[7:0]} +
    {1'd0, s422_data_2d[7:0], 1'd0};
  always @(posedge clk) begin
    R <= R_s[9:2];
    B <= B_s[9:2];
  end
  always @(posedge clk) begin
    s444_vs <= s422_vs_3d;
    s444_hs <= s422_hs_3d;
    s444_de <= s422_de_3d;
    if (s422_de_3d == 1'b0) begin
      s444_data <= 'd0;
    end else begin
      s444_data <= {R, s422_data_3d[15:8], B};
    end
  end
endmodule
