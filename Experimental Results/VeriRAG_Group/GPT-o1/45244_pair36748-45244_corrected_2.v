module GE_patch
   (
    input  SYS_CLK,
    input  test_i,
    input  scan_clk,
    input  GMII_TXCLK,
    output GMII_GTXCLK,
    input  GMII_GE_IND,
    output ENET0_GMII_TX_CLK,
    input  ENET0_MDIO_T,
    output ENET0_MDIO_O,
    inout  GMII_MDIO
  );

  wire clk_125M;
  wire dft_clk;
  wire ENET0_MDIO_I;
  reg  GMII_GE_IND_reg;
  reg  [27:0] GMII_GE_TIMER;

  clk_wiz_0 pll
    (
      .clk_in1  (SYS_CLK),
      .clk_out1 (clk_125M)
    );

  assign dft_clk = test_i ? scan_clk : clk_125M;

  IOBUF GMII_MDIO_BUF
    (
      .I  (ENET0_MDIO_O),
      .IO (GMII_MDIO),
      .O  (ENET0_MDIO_I),
      .T  (ENET0_MDIO_T)
    );

  always @ (posedge dft_clk)
  begin
    if (GMII_GE_IND == 1'b1)
    begin
      GMII_GE_IND_reg <= 1'b1;
      GMII_GE_TIMER   <= 28'h0000000;
    end
    else
    begin
      if (GMII_GE_TIMER == 28'hffffff)
        GMII_GE_IND_reg <= 1'b0;
      else
        GMII_GE_TIMER   <= GMII_GE_TIMER + 1'b1;
    end
  end

  assign GMII_GTXCLK       = clk_125M;
  assign ENET0_GMII_TX_CLK = (GMII_GE_IND_reg == 1'b1) ? clk_125M : GMII_TXCLK;

endmodule