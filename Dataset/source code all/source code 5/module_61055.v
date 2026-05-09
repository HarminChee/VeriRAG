module cf_csc_RGB2CrYCb (
  clk,
  RGB_vs,
  RGB_hs,
  RGB_de,
  RGB_data,
  CrYCb_vs,
  CrYCb_hs,
  CrYCb_de,
  CrYCb_data);
  input           clk;
  input           RGB_vs;
  input           RGB_hs;
  input           RGB_de;
  input   [23:0]  RGB_data;
  output          CrYCb_vs;
  output          CrYCb_hs;
  output          CrYCb_de;
  output  [23:0]  CrYCb_data;
  reg             CrYCb_vs = 'd0;
  reg             CrYCb_hs = 'd0;
  reg             CrYCb_de = 'd0;
  reg     [23:0]  CrYCb_data = 'd0;
  wire            Cr_vs_s;
  wire            Cr_hs_s;
  wire            Cr_de_s;
  wire    [ 7:0]  Cr_data_s;
  wire            Y_vs_s;
  wire            Y_hs_s;
  wire            Y_de_s;
  wire    [ 7:0]  Y_data_s;
  wire            Cb_vs_s;
  wire            Cb_hs_s;
  wire            Cb_de_s;
  wire    [ 7:0]  Cb_data_s;
  always @(posedge clk) begin
    CrYCb_vs <= Cr_vs_s & Y_vs_s & Cb_vs_s;
    CrYCb_hs <= Cr_hs_s & Y_hs_s & Cb_hs_s;
    CrYCb_de <= Cr_de_s & Y_de_s & Cb_de_s;
    CrYCb_data <= {Cr_data_s, Y_data_s, Cb_data_s};
  end
  cf_csc_1 i_csc_Cr (
    .clk (clk),
    .vs (RGB_vs),
    .hs (RGB_hs),
    .de (RGB_de),
    .data (RGB_data),
    .C1 (17'h00707),
    .C2 (17'h105e2),
    .C3 (17'h10124),
    .C4 (25'h0080000),
    .csc_vs (Cr_vs_s),
    .csc_hs (Cr_hs_s),
    .csc_de (Cr_de_s),
    .csc_data_1 (Cr_data_s));
  cf_csc_1 i_csc_Y (
    .clk (clk),
    .vs (RGB_vs),
    .hs (RGB_hs),
    .de (RGB_de),
    .data (RGB_data),
    .C1 (17'h0041b),
    .C2 (17'h00810),
    .C3 (17'h00191),
    .C4 (25'h0010000),
    .csc_vs (Y_vs_s),
    .csc_hs (Y_hs_s),
    .csc_de (Y_de_s),
    .csc_data_1 (Y_data_s));
  cf_csc_1 i_csc_Cb (
    .clk (clk),
    .vs (RGB_vs),
    .hs (RGB_hs),
    .de (RGB_de),
    .data (RGB_data),
    .C1 (17'h1025f),
    .C2 (17'h104a7),
    .C3 (17'h00707),
    .C4 (25'h0080000),
    .csc_vs (Cb_vs_s),
    .csc_hs (Cb_hs_s),
    .csc_de (Cb_de_s),
    .csc_data_1 (Cb_data_s));
endmodule
