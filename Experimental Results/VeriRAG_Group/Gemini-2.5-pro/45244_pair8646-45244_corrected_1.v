module GE_patch
   (
    input test_i, // Added test_i input for DFT
    input rst_n,  // Added primary input reset
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
  wire clk_125M;
  // Removed unused wires pll_locked, pll_reset
  reg GMII_GE_IND_reg;
  reg[27:0] GMII_GE_TIMER;
  wire dft_clk; // Added wire for DFT clock selection

// Added instance name pll_inst
clk_wiz_0 pll_inst
  (
  .clk_in1(SYS_CLK),
  .clk_out1(clk_125M)
  );

// Added instance name mdio_buf_inst
IOBUF mdio_buf_inst
  (
  .I(ENET0_MDIO_O),
  .IO(GMII_MDIO),
  .O(ENET0_MDIO_I),
  .T(ENET0_MDIO_T)
  );

// DFT clock selection mux
assign dft_clk = test_i ? SYS_CLK : clk_125M;

// Added asynchronous reset rst_n
always @ (posedge dft_clk or negedge rst_n) // Changed clock source to dft_clk and added reset
begin
  if (!rst_n) begin // Asynchronous reset logic
    GMII_GE_IND_reg <= 1'b0; // Define reset state
    GMII_GE_TIMER   <= 28'h0;      // Define reset state
  end else begin
    if ( GMII_GE_IND==1'b1 ) begin
      GMII_GE_IND_reg <= 1'b1;
      GMII_GE_TIMER <= 28'h0000000;
    end
    else begin
      if ( GMII_GE_TIMER==28'hffffff ) GMII_GE_IND_reg <= 1'b0;
      else GMII_GE_TIMER <= GMII_GE_TIMER+1'b1;
    end
  end
end
assign GMII_GTXCLK = clk_125M;
assign ENET0_GMII_TX_CLK = (GMII_GE_IND_reg==1'b1)? clk_125M:GMII_TXCLK;
endmodule