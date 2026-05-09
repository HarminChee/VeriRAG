`timescale 1ps/1ps
module GE_patch
(
    input  test_i,
    input  SYS_CLK,
    input  GMII_TXCLK,
    output GMII_GTXCLK,
    input  GMII_GE_IND,
    output ENET0_GMII_TX_CLK,
    output ENET0_MDIO_I,
    input  ENET0_MDIO_O,
    input  ENET0_MDIO_T,
    inout  GMII_MDIO
);

wire        clk_125M;
wire        clk_125M_dft_mux;
wire        clk_125M_dft;
reg         GMII_GE_IND_reg;
reg  [27:0] GMII_GE_TIMER;

clk_wiz_0 pll
(
  .clk_in1 (SYS_CLK),
  .clk_out1(clk_125M)
);

assign clk_125M_dft_mux = test_i ? SYS_CLK : clk_125M;

BUFGCE clk_125M_dft_buf
(
  .O  (clk_125M_dft),
  .CE (1'b1),
  .I  (clk_125M_dft_mux)
);

IOBUF GMII_MDIO_BUF
(
  .I (ENET0_MDIO_O),
  .IO(GMII_MDIO),
  .O (ENET0_MDIO_I),
  .T (ENET0_MDIO_T)
);

always @(posedge clk_125M_dft)
begin
  if (GMII_GE_IND == 1'b1) begin
    GMII_GE_IND_reg <= 1'b1;
    GMII_GE_TIMER   <= 28'h0000000;
  end
  else begin
    if (GMII_GE_TIMER == 28'hffffff)
      GMII_GE_IND_reg <= 1'b0;
    else
      GMII_GE_TIMER <= GMII_GE_TIMER + 1'b1;
  end
end

assign GMII_GTXCLK       = clk_125M;
assign ENET0_GMII_TX_CLK = (GMII_GE_IND_reg == 1'b1) ? clk_125M : GMII_TXCLK;

endmodule