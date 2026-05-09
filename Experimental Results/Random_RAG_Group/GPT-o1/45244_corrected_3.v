`timescale 1ns/1ps
module GE_patch
   (
    SYS_CLK,
    GMII_TXCLK,
    GMII_GTXCLK,
    GMII_GE_IND,
    ENET0_GMII_TX_CLK,
    ENET0_MDIO_I,
    ENET0_MDIO_O,
    ENET0_MDIO_T,
    GMII_MDIO,
    test_i,
    scan_clk
  );
  input SYS_CLK;
  input GMII_TXCLK;
  output GMII_GTXCLK;
  input GMII_GE_IND;
  output ENET0_GMII_TX_CLK;
  output ENET0_MDIO_I;
  input ENET0_MDIO_O;
  input ENET0_MDIO_T;
  inout GMII_MDIO;
  input test_i;
  input scan_clk;

  wire clk_125M;
  wire dft_clk;
  wire mdio_in;
  reg GMII_GE_IND_reg;
  reg [27:0] GMII_GE_TIMER;

  assign dft_clk = test_i ? scan_clk : clk_125M;

  clk_wiz_0 pll
  (
    .clk_in1 (SYS_CLK),
    .clk_out1(clk_125M)
  );

  IOBUF GMII_MDIO_BUF
  (
    .I (ENET0_MDIO_O),
    .IO(GMII_MDIO),
    .O (mdio_in),
    .T (ENET0_MDIO_T)
  );

  assign ENET0_MDIO_I = mdio_in;

  always @ (posedge dft_clk) begin
    if (GMII_GE_IND == 1'b1) begin
      GMII_GE_IND_reg <= 1'b1;
      GMII_GE_TIMER <= 28'h0000000;
    end else begin
      if (GMII_GE_TIMER == 28'hffffff)
        GMII_GE_IND_reg <= 1'b0;
      else
        GMII_GE_TIMER <= GMII_GE_TIMER + 1'b1;
    end
  end

  assign GMII_GTXCLK = dft_clk;
  assign ENET0_GMII_TX_CLK = (GMII_GE_IND_reg == 1'b1) ? dft_clk : GMII_TXCLK;
endmodule

module clk_wiz_0
(
  input clk_in1,
  output clk_out1
);
endmodule