module GE_patch
   (
    input  wire SYS_CLK,
    input  wire GMII_TXCLK,
    output wire GMII_GTXCLK,
    input  wire GMII_GE_IND,
    output wire ENET0_GMII_TX_CLK,
    output wire ENET0_MDIO_I,
    input  wire ENET0_MDIO_O,
    input  wire ENET0_MDIO_T,
    inout  wire GMII_MDIO,
    input  wire test_i,
    input  wire rst
  );
  wire clk_125M;
  wire pll_locked;
  wire pll_reset;
  wire dft_clk;
  reg GMII_GE_IND_reg = 1'b0;
  reg[27:0] GMII_GE_TIMER = 28'h0000000;

  clk_wiz_0 pll
  (
    .clk_in1(SYS_CLK),
    .clk_out1(clk_125M)         
  );

  IOBUF GMII_MDIO_BUF
  (
    .I(ENET0_MDIO_O),
    .IO(GMII_MDIO),
    .O(ENET0_MDIO_I),
    .T(ENET0_MDIO_T)
  );

  assign dft_clk = test_i ? SYS_CLK : clk_125M;

  always @ (posedge dft_clk or posedge rst)
  begin
    if (rst) begin
      GMII_GE_IND_reg <= 1'b0;
      GMII_GE_TIMER <= 28'h0000000;
    end else begin
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
  end

  assign GMII_GTXCLK = clk_125M;
  assign ENET0_GMII_TX_CLK = (GMII_GE_IND_reg == 1'b1) ? clk_125M : GMII_TXCLK;

endmodule