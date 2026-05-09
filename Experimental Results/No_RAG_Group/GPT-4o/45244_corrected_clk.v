module GE_patch_corrected_clk
   (
    SYS_CLK,
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
  wire pll_locked;
  wire pll_reset;
  reg GMII_GE_IND_reg;
  reg[27:0] GMII_GE_TIMER;
  
  wire primary_clk;
  assign primary_clk = SYS_CLK;

  IOBUF GMII_MDIO_BUF
  (
  .I(ENET0_MDIO_O),
  .IO(GMII_MDIO),
  .O(ENET0_MDIO_I),
  .T(ENET0_MDIO_T)
  );
always @ (posedge primary_clk)
begin
  if ( GMII_GE_IND==1'b1 ) begin
    GMII_GE_IND_reg <= 1'b1;
    GMII_GE_TIMER <= 28'h0000000;
  end
  else begin
    if ( GMII_GE_TIMER==28'hffffff ) GMII_GE_IND_reg <= 1'b0;
    else GMII_GE_TIMER <= GMII_GE_TIMER+1'b1;
  end
end
assign GMII_GTXCLK = primary_clk;
assign ENET0_GMII_TX_CLK = (GMII_GE_IND_reg==1'b1)? primary_clk:GMII_TXCLK;
endmodule