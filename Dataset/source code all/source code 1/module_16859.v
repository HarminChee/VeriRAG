module cf_csc_CrYCb2RGB (
  clk,
  CrYCb_vs,
  CrYCb_hs,
  CrYCb_de,
  CrYCb_data,
  RGB_vs,
  RGB_hs,
  RGB_de,
  RGB_data);
  input           clk;
  input           CrYCb_vs;
  input           CrYCb_hs;
  input           CrYCb_de;
  input   [23:0]  CrYCb_data;
  output          RGB_vs;
  output          RGB_hs;
  output          RGB_de;
  output  [23:0]  RGB_data;
  reg             RGB_vs = 'd0;
  reg             RGB_hs = 'd0;
  reg             RGB_de = 'd0;
  reg     [23:0]  RGB_data = 'd0;
  wire            R_vs_s;
  wire            R_hs_s;
  wire            R_de_s;
  wire    [ 7:0]  R_data_s;
  wire            G_vs_s;
  wire            G_hs_s;
  wire            G_de_s;
  wire    [ 7:0]  G_data_s;
  wire            B_vs_s;
  wire            B_hs_s;
  wire            B_de_s;
  wire    [ 7:0]  B_data_s;
  always @(posedge clk) begin
    RGB_vs <= R_vs_s & G_vs_s & B_vs_s;
    RGB_hs <= R_hs_s & G_hs_s & B_hs_s;
    RGB_de <= R_de_s & G_de_s & B_de_s;
    RGB_data <= {R_data_s, G_data_s, B_data_s};
  end
  cf_csc_1 i_csc_R (
    .clk (clk),
    .vs (CrYCb_vs),
    .hs (CrYCb_hs),
    .de (CrYCb_de),
    .data (CrYCb_data),
    .C1 (17'h01989),
    .C2 (17'h012a1),
    .C3 (17'h00000),
    .C4 (25'h10deebc),
    .csc_vs (R_vs_s),
    .csc_hs (R_hs_s),
    .csc_de (R_de_s),
    .csc_data_1 (R_data_s));
  cf_csc_1 i_csc_G (
    .clk (clk),
    .vs (CrYCb_vs),
    .hs (CrYCb_hs),
    .de (CrYCb_de),
    .data (CrYCb_data),
    .C1 (17'h10d01),
    .C2 (17'h012a1),
    .C3 (17'h10644),
    .C4 (25'h0087937),
    .csc_vs (G_vs_s),
    .csc_hs (G_hs_s),
    .csc_de (G_de_s),
    .csc_data_1 (G_data_s));
  cf_csc_1 i_csc_B (
    .clk (clk),
    .vs (CrYCb_vs),
    .hs (CrYCb_hs),
    .de (CrYCb_de),
    .data (CrYCb_data),
    .C1 (17'h00000),
    .C2 (17'h012a1),
    .C3 (17'h02046),
    .C4 (25'h1114d60),
    .csc_vs (B_vs_s),
    .csc_hs (B_hs_s),
    .csc_de (B_de_s),
    .csc_data_1 (B_data_s));
endmodule
