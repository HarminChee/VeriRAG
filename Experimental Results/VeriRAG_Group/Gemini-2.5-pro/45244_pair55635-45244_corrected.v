module GE_patch
   (
    SYS_CLK,
	input test_i, // Added test mode input
    GMII_TXCLK,
    GMII_GTXCLK,
    GMII_GE_IND,
    ENET0_GMII_TX_CLK,
    ENET0_MDIO_I,
    ENET0_MDIO_O,
    ENET0_MDIO_T,
    GMII_MDIO
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
  wire clk_125M;
  wire pll_locked;
  wire pll_reset;
  reg GMII_GE_IND_reg;
  reg[27:0] GMII_GE_TIMER;
  wire dft_clk_125M; // Added DFT clock wire

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

// Assign DFT clock: Use SYS_CLK in test mode, clk_125M otherwise
assign dft_clk_125M = test_i ? SYS_CLK : clk_125M;

always @ (posedge dft_clk_125M) // Changed clock to DFT clock
begin
  // Assuming no asynchronous reset needed for DFT, or handled elsewhere/controllable
  // If an async reset existed, it would need to be controllable from PI (e.g., PIPE_RESET_N in ref)
  if ( GMII_GE_IND==1'b1 ) begin
    GMII_GE_IND_reg <= 1'b1;
    GMII_GE_TIMER <= 28'h0000000;
  end
  else begin
    if ( GMII_GE_TIMER==28'hffffff ) GMII_GE_IND_reg <= 1'b0;
    else GMII_GE_TIMER <= GMII_GE_TIMER+1'b1;
  end
end

assign GMII_GTXCLK = clk_125M; // Functional assignment remains
assign ENET0_GMII_TX_CLK = (GMII_GE_IND_reg==1'b1)? clk_125M:GMII_TXCLK; // Functional assignment remains

endmodule