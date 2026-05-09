`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module gmii_if
    (
        RESET,
        GMII_TXD,
        GMII_TX_EN,
        GMII_TX_ER,
        GMII_TX_CLK,
        GMII_RXD,
        GMII_RX_DV,
        GMII_RX_ER,
        TXD_FROM_MAC,
        TX_EN_FROM_MAC,
        TX_ER_FROM_MAC,
        TX_CLK,
        RXD_TO_MAC,
        RX_DV_TO_MAC,
        RX_ER_TO_MAC,
        RX_CLK);
  input  RESET;
  output [7:0] GMII_TXD;
  output GMII_TX_EN;
  output GMII_TX_ER;
  output GMII_TX_CLK;
  input  [7:0] GMII_RXD;
  input  GMII_RX_DV;
  input  GMII_RX_ER;
  input  [7:0] TXD_FROM_MAC;
  input  TX_EN_FROM_MAC;
  input  TX_ER_FROM_MAC;
  input  TX_CLK;
  output [7:0] RXD_TO_MAC;
  output RX_DV_TO_MAC;
  output RX_ER_TO_MAC;
  input  RX_CLK;
  reg  [7:0] RXD_TO_MAC;
  reg  RX_DV_TO_MAC;
  reg  RX_ER_TO_MAC;
  reg  [7:0] GMII_TXD;
  reg  GMII_TX_EN;
  reg  GMII_TX_ER;
  wire [7:0] GMII_RXD_DLY;
  wire GMII_RX_DV_DLY;
  wire GMII_RX_ER_DLY;
  ODDR gmii_tx_clk_oddr (
      .Q(GMII_TX_CLK),
      .C(TX_CLK),
      .CE(1'b1),
      .D1(1'b0),
      .D2(1'b1),
      .R(RESET),
      .S(1'b0)
  );
  always @(posedge TX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
          GMII_TX_EN <= 1'b0;
          GMII_TX_ER <= 1'b0;
          GMII_TXD   <= 8'h00;
      end
      else
      begin
          GMII_TX_EN <= TX_EN_FROM_MAC;
          GMII_TX_ER <= TX_ER_FROM_MAC;
          GMII_TXD   <= TXD_FROM_MAC;
      end
  end        
  IDELAY ideld0(.I(GMII_RXD[0]), .O(GMII_RXD_DLY[0]), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideld0.IOBDELAY_TYPE = "FIXED";
  defparam ideld0.IOBDELAY_VALUE = 0;
  IDELAY ideld1(.I(GMII_RXD[1]), .O(GMII_RXD_DLY[1]), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideld1.IOBDELAY_TYPE = "FIXED";
  defparam ideld1.IOBDELAY_VALUE = 0;
  IDELAY ideld2(.I(GMII_RXD[2]), .O(GMII_RXD_DLY[2]), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideld2.IOBDELAY_TYPE = "FIXED";
  defparam ideld2.IOBDELAY_VALUE = 0;
  IDELAY ideld3(.I(GMII_RXD[3]), .O(GMII_RXD_DLY[3]), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideld3.IOBDELAY_TYPE = "FIXED";
  defparam ideld3.IOBDELAY_VALUE = 0;
  IDELAY ideld4(.I(GMII_RXD[4]), .O(GMII_RXD_DLY[4]), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideld4.IOBDELAY_TYPE = "FIXED";
  defparam ideld4.IOBDELAY_VALUE = 0;
  IDELAY ideld5(.I(GMII_RXD[5]), .O(GMII_RXD_DLY[5]), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideld5.IOBDELAY_TYPE = "FIXED";
  defparam ideld5.IOBDELAY_VALUE = 0;
  IDELAY ideld6(.I(GMII_RXD[6]), .O(GMII_RXD_DLY[6]), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideld6.IOBDELAY_TYPE = "FIXED";
  defparam ideld6.IOBDELAY_VALUE = 0;
  IDELAY ideld7(.I(GMII_RXD[7]), .O(GMII_RXD_DLY[7]), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideld7.IOBDELAY_TYPE = "FIXED";
  defparam ideld7.IOBDELAY_VALUE = 0;
  IDELAY ideldv(.I(GMII_RX_DV), .O(GMII_RX_DV_DLY), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideldv.IOBDELAY_TYPE = "FIXED";
  defparam ideldv.IOBDELAY_VALUE = 0;
  IDELAY ideler(.I(GMII_RX_ER), .O(GMII_RX_ER_DLY), .C(1'b0), .CE(1'b0), .INC(1'b0), .RST(1'b0));
  defparam ideler.IOBDELAY_TYPE = "FIXED";
  defparam ideler.IOBDELAY_VALUE = 0;
  always @(posedge RX_CLK, posedge RESET)
  begin
      if (RESET == 1'b1)
      begin
          RX_DV_TO_MAC <= 1'b0;
          RX_ER_TO_MAC <= 1'b0;
          RXD_TO_MAC   <= 8'h00;
      end
      else
      begin
          RX_DV_TO_MAC <= GMII_RX_DV_DLY;
          RX_ER_TO_MAC <= GMII_RX_ER_DLY;
          RXD_TO_MAC   <= GMII_RXD_DLY;
      end
  end
endmodule
