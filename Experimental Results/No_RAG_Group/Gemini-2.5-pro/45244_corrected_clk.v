// 1_corrected_clk.v
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
    test_mode // Added test_mode input for DFT
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
  input test_mode; // Added test_mode input for DFT

  wire clk_125M;
  wire pll_locked; // Unused, but kept from original
  wire pll_reset;  // Unused, but kept from original
  reg GMII_GE_IND_reg;
  reg[27:0] GMII_GE_TIMER;
  wire dft_clk; // Clock signal selected for functional or test mode

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

// Clock MUX for DFT: Selects SYS_CLK in test_mode, clk_125M in functional mode
assign dft_clk = test_mode ? SYS_CLK : clk_125M;

// Changed clock source from clk_125M to dft_clk
always @ (posedge dft_clk)
begin
  // Assuming asynchronous reset is not required or handled elsewhere for DFT
  // If synchronous reset is needed, it should be added here based on a test reset signal
  if ( GMII_GE_IND==1'b1 ) begin
    GMII_GE_IND_reg <= 1'b1;
    GMII_GE_TIMER <= 28'h0000000;
  end
  else begin
    if ( GMII_GE_TIMER==28'hffffff ) GMII_GE_IND_reg <= 1'b0;
    else GMII_GE_TIMER <= GMII_GE_TIMER+1'b1;
  end
end

// GTXCLK driven by PLL output directly (usually acceptable if it's an output clock)
assign GMII_GTXCLK = clk_125M;

// This multiplexed clock output remains a potential DFT issue for downstream logic,
// but the CLKNPI for the internal FFs (GMII_GE_IND_reg, GMII_GE_TIMER) is resolved.
// Further DFT improvements might involve redesigning this clock generation.
assign ENET0_GMII_TX_CLK = (GMII_GE_IND_reg==1'b1)? clk_125M:GMII_TXCLK;

endmodule