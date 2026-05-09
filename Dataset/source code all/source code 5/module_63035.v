`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module v5_emac_v1_6
(
    EMAC0CLIENTRXCLIENTCLKOUT,
    CLIENTEMAC0RXCLIENTCLKIN,
    EMAC0CLIENTRXD,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXDVLDMSW,
    EMAC0CLIENTRXGOODFRAME,
    EMAC0CLIENTRXBADFRAME,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,
    EMAC0CLIENTTXCLIENTCLKOUT,
    CLIENTEMAC0TXCLIENTCLKIN,
    CLIENTEMAC0TXD,
    CLIENTEMAC0TXDVLD,
    CLIENTEMAC0TXDVLDMSW,
    EMAC0CLIENTTXACK,
    CLIENTEMAC0TXFIRSTBYTE,
    CLIENTEMAC0TXUNDERRUN,
    EMAC0CLIENTTXCOLLISION,
    EMAC0CLIENTTXRETRANSMIT,
    CLIENTEMAC0TXIFGDELAY,
    EMAC0CLIENTTXSTATS,
    EMAC0CLIENTTXSTATSVLD,
    EMAC0CLIENTTXSTATSBYTEVLD,
    CLIENTEMAC0PAUSEREQ,
    CLIENTEMAC0PAUSEVAL,
    GTX_CLK_0,
    PHYEMAC0TXGMIIMIICLKIN,
    EMAC0PHYTXGMIIMIICLKOUT,
    GMII_TXD_0,
    GMII_TX_EN_0,
    GMII_TX_ER_0,
    GMII_RXD_0,
    GMII_RX_DV_0,
    GMII_RX_ER_0,
    GMII_RX_CLK_0,
    DCM_LOCKED_0,
    RESET
);
    output          EMAC0CLIENTRXCLIENTCLKOUT;
    input           CLIENTEMAC0RXCLIENTCLKIN;
    output   [7:0]  EMAC0CLIENTRXD;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXDVLDMSW;
    output          EMAC0CLIENTRXGOODFRAME;
    output          EMAC0CLIENTRXBADFRAME;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;
    output          EMAC0CLIENTTXCLIENTCLKOUT;
    input           CLIENTEMAC0TXCLIENTCLKIN;
    input    [7:0]  CLIENTEMAC0TXD;
    input           CLIENTEMAC0TXDVLD;
    input           CLIENTEMAC0TXDVLDMSW;
    output          EMAC0CLIENTTXACK;
    input           CLIENTEMAC0TXFIRSTBYTE;
    input           CLIENTEMAC0TXUNDERRUN;
    output          EMAC0CLIENTTXCOLLISION;
    output          EMAC0CLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMAC0TXIFGDELAY;
    output          EMAC0CLIENTTXSTATS;
    output          EMAC0CLIENTTXSTATSVLD;
    output          EMAC0CLIENTTXSTATSBYTEVLD;
    input           CLIENTEMAC0PAUSEREQ;
    input   [15:0]  CLIENTEMAC0PAUSEVAL;
    input           GTX_CLK_0;
    output          EMAC0PHYTXGMIIMIICLKOUT;
    input           PHYEMAC0TXGMIIMIICLKIN;
    output   [7:0]  GMII_TXD_0;
    output          GMII_TX_EN_0;
    output          GMII_TX_ER_0;
    input    [7:0]  GMII_RXD_0;
    input           GMII_RX_DV_0;
    input           GMII_RX_ER_0;
    input           GMII_RX_CLK_0;
    input           DCM_LOCKED_0;
    input           RESET;
    wire    [15:0]  client_rx_data_0_i;
    wire    [15:0]  client_tx_data_0_i;
    assign EMAC0CLIENTRXD = client_rx_data_0_i[7:0];
    assign #4000 client_tx_data_0_i = {8'b00000000, CLIENTEMAC0TXD};
    TEMAC v5_emac
    (
        .RESET                          (RESET),
        .EMAC0CLIENTRXCLIENTCLKOUT      (EMAC0CLIENTRXCLIENTCLKOUT),
        .CLIENTEMAC0RXCLIENTCLKIN       (CLIENTEMAC0RXCLIENTCLKIN),
        .EMAC0CLIENTRXD                 (client_rx_data_0_i),
        .EMAC0CLIENTRXDVLD              (EMAC0CLIENTRXDVLD),
        .EMAC0CLIENTRXDVLDMSW           (EMAC0CLIENTRXDVLDMSW),
        .EMAC0CLIENTRXGOODFRAME         (EMAC0CLIENTRXGOODFRAME),
        .EMAC0CLIENTRXBADFRAME          (EMAC0CLIENTRXBADFRAME),
        .EMAC0CLIENTRXFRAMEDROP         (EMAC0CLIENTRXFRAMEDROP),
        .EMAC0CLIENTRXSTATS             (EMAC0CLIENTRXSTATS),
        .EMAC0CLIENTRXSTATSVLD          (EMAC0CLIENTRXSTATSVLD),
        .EMAC0CLIENTRXSTATSBYTEVLD      (EMAC0CLIENTRXSTATSBYTEVLD),
        .EMAC0CLIENTTXCLIENTCLKOUT      (EMAC0CLIENTTXCLIENTCLKOUT),
        .CLIENTEMAC0TXCLIENTCLKIN       (CLIENTEMAC0TXCLIENTCLKIN),
        .CLIENTEMAC0TXD                 (client_tx_data_0_i),
        .CLIENTEMAC0TXDVLD              (CLIENTEMAC0TXDVLD),
        .CLIENTEMAC0TXDVLDMSW           (CLIENTEMAC0TXDVLDMSW),
        .EMAC0CLIENTTXACK               (EMAC0CLIENTTXACK),
        .CLIENTEMAC0TXFIRSTBYTE         (CLIENTEMAC0TXFIRSTBYTE),
        .CLIENTEMAC0TXUNDERRUN          (CLIENTEMAC0TXUNDERRUN),
        .EMAC0CLIENTTXCOLLISION         (EMAC0CLIENTTXCOLLISION),
        .EMAC0CLIENTTXRETRANSMIT        (EMAC0CLIENTTXRETRANSMIT),
        .CLIENTEMAC0TXIFGDELAY          (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS             (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD          (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD      (EMAC0CLIENTTXSTATSBYTEVLD),
        .CLIENTEMAC0PAUSEREQ            (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL            (CLIENTEMAC0PAUSEVAL),
        .PHYEMAC0GTXCLK                 (GTX_CLK_0),
        .EMAC0PHYTXGMIIMIICLKOUT        (EMAC0PHYTXGMIIMIICLKOUT),
        .PHYEMAC0TXGMIIMIICLKIN         (PHYEMAC0TXGMIIMIICLKIN),
        .PHYEMAC0RXCLK                  (GMII_RX_CLK_0),
        .PHYEMAC0RXD                    (GMII_RXD_0),
        .PHYEMAC0RXDV                   (GMII_RX_DV_0),
        .PHYEMAC0RXER                   (GMII_RX_ER_0),
        .EMAC0PHYTXCLK                  (),
        .EMAC0PHYTXD                    (GMII_TXD_0),
        .EMAC0PHYTXEN                   (GMII_TX_EN_0),
        .EMAC0PHYTXER                   (GMII_TX_ER_0),
        .PHYEMAC0MIITXCLK               (),
        .PHYEMAC0COL                    (1'b0),
        .PHYEMAC0CRS                    (1'b0),
        .CLIENTEMAC0DCMLOCKED           (DCM_LOCKED_0),
        .EMAC0CLIENTANINTERRUPT         (),
        .PHYEMAC0SIGNALDET              (1'b0),
        .PHYEMAC0PHYAD                  (5'b00000),
        .EMAC0PHYENCOMMAALIGN           (),
        .EMAC0PHYLOOPBACKMSB            (),
        .EMAC0PHYMGTRXRESET             (),
        .EMAC0PHYMGTTXRESET             (),
        .EMAC0PHYPOWERDOWN              (),
        .EMAC0PHYSYNCACQSTATUS          (),
        .PHYEMAC0RXCLKCORCNT            (3'b000),
        .PHYEMAC0RXBUFSTATUS            (2'b00),
        .PHYEMAC0RXBUFERR               (1'b0),
        .PHYEMAC0RXCHARISCOMMA          (1'b0),
        .PHYEMAC0RXCHARISK              (1'b0),
        .PHYEMAC0RXCHECKINGCRC          (1'b0),
        .PHYEMAC0RXCOMMADET             (1'b0),
        .PHYEMAC0RXDISPERR              (1'b0),
        .PHYEMAC0RXLOSSOFSYNC           (2'b00),
        .PHYEMAC0RXNOTINTABLE           (1'b0),
        .PHYEMAC0RXRUNDISP              (1'b0),
        .PHYEMAC0TXBUFERR               (1'b0),
        .EMAC0PHYTXCHARDISPMODE         (),
        .EMAC0PHYTXCHARDISPVAL          (),
        .EMAC0PHYTXCHARISK              (),
        .EMAC0PHYMCLKOUT                (),
        .PHYEMAC0MCLKIN                 (1'b0),
        .PHYEMAC0MDIN                   (1'b1),
        .EMAC0PHYMDOUT                  (),
        .EMAC0PHYMDTRI                  (),
        .EMAC0SPEEDIS10100              (),
        .EMAC1CLIENTRXCLIENTCLKOUT      (),
        .CLIENTEMAC1RXCLIENTCLKIN       (1'b0),
        .EMAC1CLIENTRXD                 (),
        .EMAC1CLIENTRXDVLD              (),
        .EMAC1CLIENTRXDVLDMSW           (),
        .EMAC1CLIENTRXGOODFRAME         (),
        .EMAC1CLIENTRXBADFRAME          (),
        .EMAC1CLIENTRXFRAMEDROP         (),
        .EMAC1CLIENTRXSTATS             (),
        .EMAC1CLIENTRXSTATSVLD          (),
        .EMAC1CLIENTRXSTATSBYTEVLD      (),
        .EMAC1CLIENTTXCLIENTCLKOUT      (),
        .CLIENTEMAC1TXCLIENTCLKIN       (1'b0),
        .CLIENTEMAC1TXD                 (16'h0000),
        .CLIENTEMAC1TXDVLD              (1'b0),
        .CLIENTEMAC1TXDVLDMSW           (1'b0),
        .EMAC1CLIENTTXACK               (),
        .CLIENTEMAC1TXFIRSTBYTE         (1'b0),
        .CLIENTEMAC1TXUNDERRUN          (1'b0),
        .EMAC1CLIENTTXCOLLISION         (),
        .EMAC1CLIENTTXRETRANSMIT        (),
        .CLIENTEMAC1TXIFGDELAY          (8'h00),
        .EMAC1CLIENTTXSTATS             (),
        .EMAC1CLIENTTXSTATSVLD          (),
        .EMAC1CLIENTTXSTATSBYTEVLD      (),
        .CLIENTEMAC1PAUSEREQ            (1'b0),
        .CLIENTEMAC1PAUSEVAL            (16'h0000),
        .PHYEMAC1GTXCLK                 (1'b0),
        .EMAC1PHYTXGMIIMIICLKOUT        (),
        .PHYEMAC1TXGMIIMIICLKIN         (1'b0),
        .PHYEMAC1RXCLK                  (1'b0),
        .PHYEMAC1RXD                    (8'h00),
        .PHYEMAC1RXDV                   (1'b0),
        .PHYEMAC1RXER                   (1'b0),
        .PHYEMAC1MIITXCLK               (1'b0),
        .EMAC1PHYTXCLK                  (),
        .EMAC1PHYTXD                    (),
        .EMAC1PHYTXEN                   (),
        .EMAC1PHYTXER                   (),
        .PHYEMAC1COL                    (1'b0),
        .PHYEMAC1CRS                    (1'b0),
        .CLIENTEMAC1DCMLOCKED           (1'b1),
        .EMAC1CLIENTANINTERRUPT         (),
        .PHYEMAC1SIGNALDET              (1'b0),
        .PHYEMAC1PHYAD                  (5'b00000),
        .EMAC1PHYENCOMMAALIGN           (),
        .EMAC1PHYLOOPBACKMSB            (),
        .EMAC1PHYMGTRXRESET             (),
        .EMAC1PHYMGTTXRESET             (),
        .EMAC1PHYPOWERDOWN              (),
        .EMAC1PHYSYNCACQSTATUS          (),
        .PHYEMAC1RXCLKCORCNT            (3'b000),
        .PHYEMAC1RXBUFSTATUS            (2'b00),
        .PHYEMAC1RXBUFERR               (1'b0),
        .PHYEMAC1RXCHARISCOMMA          (1'b0),
        .PHYEMAC1RXCHARISK              (1'b0),
        .PHYEMAC1RXCHECKINGCRC          (1'b0),
        .PHYEMAC1RXCOMMADET             (1'b0),
        .PHYEMAC1RXDISPERR              (1'b0),
        .PHYEMAC1RXLOSSOFSYNC           (2'b00),
        .PHYEMAC1RXNOTINTABLE           (1'b0),
        .PHYEMAC1RXRUNDISP              (1'b0),
        .PHYEMAC1TXBUFERR               (1'b0),
        .EMAC1PHYTXCHARDISPMODE         (),
        .EMAC1PHYTXCHARDISPVAL          (),
        .EMAC1PHYTXCHARISK              (),
        .EMAC1PHYMCLKOUT                (),
        .PHYEMAC1MCLKIN                 (1'b0),
        .PHYEMAC1MDIN                   (1'b0),
        .EMAC1PHYMDOUT                  (),
        .EMAC1PHYMDTRI                  (),
        .EMAC1SPEEDIS10100              (),
        .HOSTCLK                        (1'b0),
        .HOSTOPCODE                     (2'b00),
        .HOSTREQ                        (1'b0),
        .HOSTMIIMSEL                    (1'b0),
        .HOSTADDR                       (10'b0000000000),
        .HOSTWRDATA                     (32'h00000000),
        .HOSTMIIMRDY                    (),
        .HOSTRDDATA                     (),
        .HOSTEMAC1SEL                   (1'b0),
        .DCREMACCLK                     (1'b0),
        .DCREMACABUS                    (10'h000),
        .DCREMACREAD                    (1'b0),
        .DCREMACWRITE                   (1'b0),
        .DCREMACDBUS                    (32'h00000000),
        .EMACDCRACK                     (),
        .EMACDCRDBUS                    (),
        .DCREMACENABLE                  (1'b0),
        .DCRHOSTDONEIR                  ()
    );
    defparam v5_emac.EMAC0_PHYINITAUTONEG_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_PHYISOLATE = "FALSE";
    defparam v5_emac.EMAC0_PHYLOOPBACKMSB = "FALSE";
    defparam v5_emac.EMAC0_PHYPOWERDOWN = "FALSE";
    defparam v5_emac.EMAC0_PHYRESET = "TRUE";
    defparam v5_emac.EMAC0_CONFIGVEC_79 = "FALSE";
    defparam v5_emac.EMAC0_GTLOOPBACK = "FALSE";
    defparam v5_emac.EMAC0_UNIDIRECTION_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_LINKTIMERVAL = 9'h000;
    defparam v5_emac.EMAC0_MDIO_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_SPEED_LSB = "FALSE";
    defparam v5_emac.EMAC0_SPEED_MSB = "TRUE"; 
    defparam v5_emac.EMAC0_USECLKEN = "FALSE";
    defparam v5_emac.EMAC0_BYTEPHY = "FALSE";
    defparam v5_emac.EMAC0_RGMII_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_SGMII_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_1000BASEX_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_HOST_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TX16BITCLIENT_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_RX16BITCLIENT_ENABLE = "FALSE";    
    defparam v5_emac.EMAC0_ADDRFILTER_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_LTCHECK_DISABLE = "FALSE";  
    defparam v5_emac.EMAC0_RXFLOWCTRL_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TXFLOWCTRL_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TXRESET = "FALSE";  
    defparam v5_emac.EMAC0_TXJUMBOFRAME_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TXINBANDFCS_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TX_ENABLE = "TRUE";  
    defparam v5_emac.EMAC0_TXVLAN_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TXHALFDUPLEX = "FALSE";  
    defparam v5_emac.EMAC0_TXIFGADJUST_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_RXRESET = "FALSE";  
    defparam v5_emac.EMAC0_RXJUMBOFRAME_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_RXINBANDFCS_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_RX_ENABLE = "TRUE";  
    defparam v5_emac.EMAC0_RXVLAN_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_RXHALFDUPLEX = "FALSE";  
    defparam v5_emac.EMAC0_PAUSEADDR = 48'hFFEEDDCCBBAA;
    defparam v5_emac.EMAC0_UNICASTADDR = 48'h000000000000;
    defparam v5_emac.EMAC0_DCRBASEADDR = 8'h00;
endmodule
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
`timescale 1 ps / 1 ps
module v5_emac_v1_6_block
(
    TX_CLK_OUT,
    TX_CLK_0,
    EMAC0CLIENTRXD,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXGOODFRAME,
    EMAC0CLIENTRXBADFRAME,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,
    CLIENTEMAC0TXD,
    CLIENTEMAC0TXDVLD,
    EMAC0CLIENTTXACK,
    CLIENTEMAC0TXFIRSTBYTE,
    CLIENTEMAC0TXUNDERRUN,
    EMAC0CLIENTTXCOLLISION,
    EMAC0CLIENTTXRETRANSMIT,
    CLIENTEMAC0TXIFGDELAY,
    EMAC0CLIENTTXSTATS,
    EMAC0CLIENTTXSTATSVLD,
    EMAC0CLIENTTXSTATSBYTEVLD,
    CLIENTEMAC0PAUSEREQ,
    CLIENTEMAC0PAUSEVAL,
    GTX_CLK_0,
    GMII_TXD_0,
    GMII_TX_EN_0,
    GMII_TX_ER_0,
    GMII_TX_CLK_0,
    GMII_RXD_0,
    GMII_RX_DV_0,
    GMII_RX_ER_0,
    GMII_RX_CLK_0 ,
    RESET
);
    output          TX_CLK_OUT;
    input           TX_CLK_0;
    output   [7:0]  EMAC0CLIENTRXD;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXGOODFRAME;
    output          EMAC0CLIENTRXBADFRAME;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;
    input    [7:0]  CLIENTEMAC0TXD;
    input           CLIENTEMAC0TXDVLD;
    output          EMAC0CLIENTTXACK;
    input           CLIENTEMAC0TXFIRSTBYTE;
    input           CLIENTEMAC0TXUNDERRUN;
    output          EMAC0CLIENTTXCOLLISION;
    output          EMAC0CLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMAC0TXIFGDELAY;
    output          EMAC0CLIENTTXSTATS;
    output          EMAC0CLIENTTXSTATSVLD;
    output          EMAC0CLIENTTXSTATSBYTEVLD;
    input           CLIENTEMAC0PAUSEREQ;
    input   [15:0]  CLIENTEMAC0PAUSEVAL;
    input           GTX_CLK_0;
    output   [7:0]  GMII_TXD_0;
    output          GMII_TX_EN_0;
    output          GMII_TX_ER_0;
    output          GMII_TX_CLK_0;
    input    [7:0]  GMII_RXD_0;
    input           GMII_RX_DV_0;
    input           GMII_RX_ER_0;
    input           GMII_RX_CLK_0 ;
    input           RESET;
    wire            reset_ibuf_i;
    wire            reset_i;
    wire            rx_client_clk_out_0_i;
    wire            rx_client_clk_in_0_i;
    wire            tx_client_clk_out_0_i;
    wire            tx_client_clk_in_0_i;
    wire            tx_gmii_mii_clk_out_0_i;
    wire            tx_gmii_mii_clk_in_0_i;
    wire            gmii_tx_en_0_i;
    wire            gmii_tx_er_0_i;
    wire     [7:0]  gmii_txd_0_i;
    wire            gmii_rx_dv_0_r;
    wire            gmii_rx_er_0_r;
    wire     [7:0]  gmii_rxd_0_r;
    wire            gmii_rx_clk_0_i;
    wire            gtx_clk_ibufg_0_i;
    assign reset_ibuf_i = RESET;
    assign reset_i = reset_ibuf_i;
    gmii_if gmii0 (
        .RESET(reset_i),
        .GMII_TXD(GMII_TXD_0),
        .GMII_TX_EN(GMII_TX_EN_0),
        .GMII_TX_ER(GMII_TX_ER_0),
        .GMII_TX_CLK(GMII_TX_CLK_0),
        .GMII_RXD(GMII_RXD_0),
        .GMII_RX_DV(GMII_RX_DV_0),
        .GMII_RX_ER(GMII_RX_ER_0),
        .TXD_FROM_MAC(gmii_txd_0_i),
        .TX_EN_FROM_MAC(gmii_tx_en_0_i),
        .TX_ER_FROM_MAC(gmii_tx_er_0_i),
        .TX_CLK(tx_gmii_mii_clk_in_0_i),
        .RXD_TO_MAC(gmii_rxd_0_r),
        .RX_DV_TO_MAC(gmii_rx_dv_0_r),
        .RX_ER_TO_MAC(gmii_rx_er_0_r),
        .RX_CLK(gmii_rx_clk_0_i));
    assign gtx_clk_ibufg_0_i = GTX_CLK_0; 
    assign tx_gmii_mii_clk_in_0_i = TX_CLK_0;
    assign gmii_rx_clk_0_i = GMII_RX_CLK_0;    
    assign tx_client_clk_in_0_i = TX_CLK_0;
    assign rx_client_clk_in_0_i = gmii_rx_clk_0_i;
    assign TX_CLK_OUT                = tx_gmii_mii_clk_out_0_i;
    v5_emac_v1_6 v5_emac_wrapper_inst
    (
        .EMAC0CLIENTRXCLIENTCLKOUT      (rx_client_clk_out_0_i),
        .CLIENTEMAC0RXCLIENTCLKIN       (rx_client_clk_in_0_i),
        .EMAC0CLIENTRXD                 (EMAC0CLIENTRXD),
        .EMAC0CLIENTRXDVLD              (EMAC0CLIENTRXDVLD),
        .EMAC0CLIENTRXDVLDMSW           (),
        .EMAC0CLIENTRXGOODFRAME         (EMAC0CLIENTRXGOODFRAME),
        .EMAC0CLIENTRXBADFRAME          (EMAC0CLIENTRXBADFRAME),
        .EMAC0CLIENTRXFRAMEDROP         (EMAC0CLIENTRXFRAMEDROP),
        .EMAC0CLIENTRXSTATS             (EMAC0CLIENTRXSTATS),
        .EMAC0CLIENTRXSTATSVLD          (EMAC0CLIENTRXSTATSVLD),
        .EMAC0CLIENTRXSTATSBYTEVLD      (EMAC0CLIENTRXSTATSBYTEVLD),
        .EMAC0CLIENTTXCLIENTCLKOUT      (tx_client_clk_out_0_i),
        .CLIENTEMAC0TXCLIENTCLKIN       (tx_client_clk_in_0_i),
        .CLIENTEMAC0TXD                 (CLIENTEMAC0TXD),
        .CLIENTEMAC0TXDVLD              (CLIENTEMAC0TXDVLD),
        .CLIENTEMAC0TXDVLDMSW           (1'b0),
        .EMAC0CLIENTTXACK               (EMAC0CLIENTTXACK),
        .CLIENTEMAC0TXFIRSTBYTE         (CLIENTEMAC0TXFIRSTBYTE),
        .CLIENTEMAC0TXUNDERRUN          (CLIENTEMAC0TXUNDERRUN),
        .EMAC0CLIENTTXCOLLISION         (EMAC0CLIENTTXCOLLISION),
        .EMAC0CLIENTTXRETRANSMIT        (EMAC0CLIENTTXRETRANSMIT),
        .CLIENTEMAC0TXIFGDELAY          (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS             (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD          (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD      (EMAC0CLIENTTXSTATSBYTEVLD),
        .CLIENTEMAC0PAUSEREQ            (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL            (CLIENTEMAC0PAUSEVAL),
        .GTX_CLK_0                      (gtx_clk_ibufg_0_i),
        .EMAC0PHYTXGMIIMIICLKOUT        (tx_gmii_mii_clk_out_0_i),
        .PHYEMAC0TXGMIIMIICLKIN         (tx_gmii_mii_clk_in_0_i),
        .GMII_TXD_0                     (gmii_txd_0_i),
        .GMII_TX_EN_0                   (gmii_tx_en_0_i),
        .GMII_TX_ER_0                   (gmii_tx_er_0_i),
        .GMII_RXD_0                     (gmii_rxd_0_r),
        .GMII_RX_DV_0                   (gmii_rx_dv_0_r),
        .GMII_RX_ER_0                   (gmii_rx_er_0_r),
        .GMII_RX_CLK_0                  (gmii_rx_clk_0_i),
        .DCM_LOCKED_0                   (1'b1  ),
        .RESET                          (reset_i)
        );
endmodule
`timescale 1 ps / 1 ps
module v5_emac_v1_6
(
    EMAC0CLIENTRXCLIENTCLKOUT,
    CLIENTEMAC0RXCLIENTCLKIN,
    EMAC0CLIENTRXD,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXDVLDMSW,
    EMAC0CLIENTRXGOODFRAME,
    EMAC0CLIENTRXBADFRAME,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,
    EMAC0CLIENTTXCLIENTCLKOUT,
    CLIENTEMAC0TXCLIENTCLKIN,
    CLIENTEMAC0TXD,
    CLIENTEMAC0TXDVLD,
    CLIENTEMAC0TXDVLDMSW,
    EMAC0CLIENTTXACK,
    CLIENTEMAC0TXFIRSTBYTE,
    CLIENTEMAC0TXUNDERRUN,
    EMAC0CLIENTTXCOLLISION,
    EMAC0CLIENTTXRETRANSMIT,
    CLIENTEMAC0TXIFGDELAY,
    EMAC0CLIENTTXSTATS,
    EMAC0CLIENTTXSTATSVLD,
    EMAC0CLIENTTXSTATSBYTEVLD,
    CLIENTEMAC0PAUSEREQ,
    CLIENTEMAC0PAUSEVAL,
    GTX_CLK_0,
    PHYEMAC0TXGMIIMIICLKIN,
    EMAC0PHYTXGMIIMIICLKOUT,
    GMII_TXD_0,
    GMII_TX_EN_0,
    GMII_TX_ER_0,
    GMII_RXD_0,
    GMII_RX_DV_0,
    GMII_RX_ER_0,
    GMII_RX_CLK_0,
    DCM_LOCKED_0,
    RESET
);
    output          EMAC0CLIENTRXCLIENTCLKOUT;
    input           CLIENTEMAC0RXCLIENTCLKIN;
    output   [7:0]  EMAC0CLIENTRXD;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXDVLDMSW;
    output          EMAC0CLIENTRXGOODFRAME;
    output          EMAC0CLIENTRXBADFRAME;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;
    output          EMAC0CLIENTTXCLIENTCLKOUT;
    input           CLIENTEMAC0TXCLIENTCLKIN;
    input    [7:0]  CLIENTEMAC0TXD;
    input           CLIENTEMAC0TXDVLD;
    input           CLIENTEMAC0TXDVLDMSW;
    output          EMAC0CLIENTTXACK;
    input           CLIENTEMAC0TXFIRSTBYTE;
    input           CLIENTEMAC0TXUNDERRUN;
    output          EMAC0CLIENTTXCOLLISION;
    output          EMAC0CLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMAC0TXIFGDELAY;
    output          EMAC0CLIENTTXSTATS;
    output          EMAC0CLIENTTXSTATSVLD;
    output          EMAC0CLIENTTXSTATSBYTEVLD;
    input           CLIENTEMAC0PAUSEREQ;
    input   [15:0]  CLIENTEMAC0PAUSEVAL;
    input           GTX_CLK_0;
    output          EMAC0PHYTXGMIIMIICLKOUT;
    input           PHYEMAC0TXGMIIMIICLKIN;
    output   [7:0]  GMII_TXD_0;
    output          GMII_TX_EN_0;
    output          GMII_TX_ER_0;
    input    [7:0]  GMII_RXD_0;
    input           GMII_RX_DV_0;
    input           GMII_RX_ER_0;
    input           GMII_RX_CLK_0;
    input           DCM_LOCKED_0;
    input           RESET;
    wire    [15:0]  client_rx_data_0_i;
    wire    [15:0]  client_tx_data_0_i;
    assign EMAC0CLIENTRXD = client_rx_data_0_i[7:0];
    assign #4000 client_tx_data_0_i = {8'b00000000, CLIENTEMAC0TXD};
    TEMAC v5_emac
    (
        .RESET                          (RESET),
        .EMAC0CLIENTRXCLIENTCLKOUT      (EMAC0CLIENTRXCLIENTCLKOUT),
        .CLIENTEMAC0RXCLIENTCLKIN       (CLIENTEMAC0RXCLIENTCLKIN),
        .EMAC0CLIENTRXD                 (client_rx_data_0_i),
        .EMAC0CLIENTRXDVLD              (EMAC0CLIENTRXDVLD),
        .EMAC0CLIENTRXDVLDMSW           (EMAC0CLIENTRXDVLDMSW),
        .EMAC0CLIENTRXGOODFRAME         (EMAC0CLIENTRXGOODFRAME),
        .EMAC0CLIENTRXBADFRAME          (EMAC0CLIENTRXBADFRAME),
        .EMAC0CLIENTRXFRAMEDROP         (EMAC0CLIENTRXFRAMEDROP),
        .EMAC0CLIENTRXSTATS             (EMAC0CLIENTRXSTATS),
        .EMAC0CLIENTRXSTATSVLD          (EMAC0CLIENTRXSTATSVLD),
        .EMAC0CLIENTRXSTATSBYTEVLD      (EMAC0CLIENTRXSTATSBYTEVLD),
        .EMAC0CLIENTTXCLIENTCLKOUT      (EMAC0CLIENTTXCLIENTCLKOUT),
        .CLIENTEMAC0TXCLIENTCLKIN       (CLIENTEMAC0TXCLIENTCLKIN),
        .CLIENTEMAC0TXD                 (client_tx_data_0_i),
        .CLIENTEMAC0TXDVLD              (CLIENTEMAC0TXDVLD),
        .CLIENTEMAC0TXDVLDMSW           (CLIENTEMAC0TXDVLDMSW),
        .EMAC0CLIENTTXACK               (EMAC0CLIENTTXACK),
        .CLIENTEMAC0TXFIRSTBYTE         (CLIENTEMAC0TXFIRSTBYTE),
        .CLIENTEMAC0TXUNDERRUN          (CLIENTEMAC0TXUNDERRUN),
        .EMAC0CLIENTTXCOLLISION         (EMAC0CLIENTTXCOLLISION),
        .EMAC0CLIENTTXRETRANSMIT        (EMAC0CLIENTTXRETRANSMIT),
        .CLIENTEMAC0TXIFGDELAY          (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS             (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD          (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD      (EMAC0CLIENTTXSTATSBYTEVLD),
        .CLIENTEMAC0PAUSEREQ            (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL            (CLIENTEMAC0PAUSEVAL),
        .PHYEMAC0GTXCLK                 (GTX_CLK_0),
        .EMAC0PHYTXGMIIMIICLKOUT        (EMAC0PHYTXGMIIMIICLKOUT),
        .PHYEMAC0TXGMIIMIICLKIN         (PHYEMAC0TXGMIIMIICLKIN),
        .PHYEMAC0RXCLK                  (GMII_RX_CLK_0),
        .PHYEMAC0RXD                    (GMII_RXD_0),
        .PHYEMAC0RXDV                   (GMII_RX_DV_0),
        .PHYEMAC0RXER                   (GMII_RX_ER_0),
        .EMAC0PHYTXCLK                  (),
        .EMAC0PHYTXD                    (GMII_TXD_0),
        .EMAC0PHYTXEN                   (GMII_TX_EN_0),
        .EMAC0PHYTXER                   (GMII_TX_ER_0),
        .PHYEMAC0MIITXCLK               (),
        .PHYEMAC0COL                    (1'b0),
        .PHYEMAC0CRS                    (1'b0),
        .CLIENTEMAC0DCMLOCKED           (DCM_LOCKED_0),
        .EMAC0CLIENTANINTERRUPT         (),
        .PHYEMAC0SIGNALDET              (1'b0),
        .PHYEMAC0PHYAD                  (5'b00000),
        .EMAC0PHYENCOMMAALIGN           (),
        .EMAC0PHYLOOPBACKMSB            (),
        .EMAC0PHYMGTRXRESET             (),
        .EMAC0PHYMGTTXRESET             (),
        .EMAC0PHYPOWERDOWN              (),
        .EMAC0PHYSYNCACQSTATUS          (),
        .PHYEMAC0RXCLKCORCNT            (3'b000),
        .PHYEMAC0RXBUFSTATUS            (2'b00),
        .PHYEMAC0RXBUFERR               (1'b0),
        .PHYEMAC0RXCHARISCOMMA          (1'b0),
        .PHYEMAC0RXCHARISK              (1'b0),
        .PHYEMAC0RXCHECKINGCRC          (1'b0),
        .PHYEMAC0RXCOMMADET             (1'b0),
        .PHYEMAC0RXDISPERR              (1'b0),
        .PHYEMAC0RXLOSSOFSYNC           (2'b00),
        .PHYEMAC0RXNOTINTABLE           (1'b0),
        .PHYEMAC0RXRUNDISP              (1'b0),
        .PHYEMAC0TXBUFERR               (1'b0),
        .EMAC0PHYTXCHARDISPMODE         (),
        .EMAC0PHYTXCHARDISPVAL          (),
        .EMAC0PHYTXCHARISK              (),
        .EMAC0PHYMCLKOUT                (),
        .PHYEMAC0MCLKIN                 (1'b0),
        .PHYEMAC0MDIN                   (1'b1),
        .EMAC0PHYMDOUT                  (),
        .EMAC0PHYMDTRI                  (),
        .EMAC0SPEEDIS10100              (),
        .EMAC1CLIENTRXCLIENTCLKOUT      (),
        .CLIENTEMAC1RXCLIENTCLKIN       (1'b0),
        .EMAC1CLIENTRXD                 (),
        .EMAC1CLIENTRXDVLD              (),
        .EMAC1CLIENTRXDVLDMSW           (),
        .EMAC1CLIENTRXGOODFRAME         (),
        .EMAC1CLIENTRXBADFRAME          (),
        .EMAC1CLIENTRXFRAMEDROP         (),
        .EMAC1CLIENTRXSTATS             (),
        .EMAC1CLIENTRXSTATSVLD          (),
        .EMAC1CLIENTRXSTATSBYTEVLD      (),
        .EMAC1CLIENTTXCLIENTCLKOUT      (),
        .CLIENTEMAC1TXCLIENTCLKIN       (1'b0),
        .CLIENTEMAC1TXD                 (16'h0000),
        .CLIENTEMAC1TXDVLD              (1'b0),
        .CLIENTEMAC1TXDVLDMSW           (1'b0),
        .EMAC1CLIENTTXACK               (),
        .CLIENTEMAC1TXFIRSTBYTE         (1'b0),
        .CLIENTEMAC1TXUNDERRUN          (1'b0),
        .EMAC1CLIENTTXCOLLISION         (),
        .EMAC1CLIENTTXRETRANSMIT        (),
        .CLIENTEMAC1TXIFGDELAY          (8'h00),
        .EMAC1CLIENTTXSTATS             (),
        .EMAC1CLIENTTXSTATSVLD          (),
        .EMAC1CLIENTTXSTATSBYTEVLD      (),
        .CLIENTEMAC1PAUSEREQ            (1'b0),
        .CLIENTEMAC1PAUSEVAL            (16'h0000),
        .PHYEMAC1GTXCLK                 (1'b0),
        .EMAC1PHYTXGMIIMIICLKOUT        (),
        .PHYEMAC1TXGMIIMIICLKIN         (1'b0),
        .PHYEMAC1RXCLK                  (1'b0),
        .PHYEMAC1RXD                    (8'h00),
        .PHYEMAC1RXDV                   (1'b0),
        .PHYEMAC1RXER                   (1'b0),
        .PHYEMAC1MIITXCLK               (1'b0),
        .EMAC1PHYTXCLK                  (),
        .EMAC1PHYTXD                    (),
        .EMAC1PHYTXEN                   (),
        .EMAC1PHYTXER                   (),
        .PHYEMAC1COL                    (1'b0),
        .PHYEMAC1CRS                    (1'b0),
        .CLIENTEMAC1DCMLOCKED           (1'b1),
        .EMAC1CLIENTANINTERRUPT         (),
        .PHYEMAC1SIGNALDET              (1'b0),
        .PHYEMAC1PHYAD                  (5'b00000),
        .EMAC1PHYENCOMMAALIGN           (),
        .EMAC1PHYLOOPBACKMSB            (),
        .EMAC1PHYMGTRXRESET             (),
        .EMAC1PHYMGTTXRESET             (),
        .EMAC1PHYPOWERDOWN              (),
        .EMAC1PHYSYNCACQSTATUS          (),
        .PHYEMAC1RXCLKCORCNT            (3'b000),
        .PHYEMAC1RXBUFSTATUS            (2'b00),
        .PHYEMAC1RXBUFERR               (1'b0),
        .PHYEMAC1RXCHARISCOMMA          (1'b0),
        .PHYEMAC1RXCHARISK              (1'b0),
        .PHYEMAC1RXCHECKINGCRC          (1'b0),
        .PHYEMAC1RXCOMMADET             (1'b0),
        .PHYEMAC1RXDISPERR              (1'b0),
        .PHYEMAC1RXLOSSOFSYNC           (2'b00),
        .PHYEMAC1RXNOTINTABLE           (1'b0),
        .PHYEMAC1RXRUNDISP              (1'b0),
        .PHYEMAC1TXBUFERR               (1'b0),
        .EMAC1PHYTXCHARDISPMODE         (),
        .EMAC1PHYTXCHARDISPVAL          (),
        .EMAC1PHYTXCHARISK              (),
        .EMAC1PHYMCLKOUT                (),
        .PHYEMAC1MCLKIN                 (1'b0),
        .PHYEMAC1MDIN                   (1'b0),
        .EMAC1PHYMDOUT                  (),
        .EMAC1PHYMDTRI                  (),
        .EMAC1SPEEDIS10100              (),
        .HOSTCLK                        (1'b0),
        .HOSTOPCODE                     (2'b00),
        .HOSTREQ                        (1'b0),
        .HOSTMIIMSEL                    (1'b0),
        .HOSTADDR                       (10'b0000000000),
        .HOSTWRDATA                     (32'h00000000),
        .HOSTMIIMRDY                    (),
        .HOSTRDDATA                     (),
        .HOSTEMAC1SEL                   (1'b0),
        .DCREMACCLK                     (1'b0),
        .DCREMACABUS                    (10'h000),
        .DCREMACREAD                    (1'b0),
        .DCREMACWRITE                   (1'b0),
        .DCREMACDBUS                    (32'h00000000),
        .EMACDCRACK                     (),
        .EMACDCRDBUS                    (),
        .DCREMACENABLE                  (1'b0),
        .DCRHOSTDONEIR                  ()
    );
    defparam v5_emac.EMAC0_PHYINITAUTONEG_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_PHYISOLATE = "FALSE";
    defparam v5_emac.EMAC0_PHYLOOPBACKMSB = "FALSE";
    defparam v5_emac.EMAC0_PHYPOWERDOWN = "FALSE";
    defparam v5_emac.EMAC0_PHYRESET = "TRUE";
    defparam v5_emac.EMAC0_CONFIGVEC_79 = "FALSE";
    defparam v5_emac.EMAC0_GTLOOPBACK = "FALSE";
    defparam v5_emac.EMAC0_UNIDIRECTION_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_LINKTIMERVAL = 9'h000;
    defparam v5_emac.EMAC0_MDIO_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_SPEED_LSB = "FALSE";
    defparam v5_emac.EMAC0_SPEED_MSB = "TRUE"; 
    defparam v5_emac.EMAC0_USECLKEN = "FALSE";
    defparam v5_emac.EMAC0_BYTEPHY = "FALSE";
    defparam v5_emac.EMAC0_RGMII_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_SGMII_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_1000BASEX_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_HOST_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TX16BITCLIENT_ENABLE = "FALSE";
    defparam v5_emac.EMAC0_RX16BITCLIENT_ENABLE = "FALSE";    
    defparam v5_emac.EMAC0_ADDRFILTER_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_LTCHECK_DISABLE = "FALSE";  
    defparam v5_emac.EMAC0_RXFLOWCTRL_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TXFLOWCTRL_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TXRESET = "FALSE";  
    defparam v5_emac.EMAC0_TXJUMBOFRAME_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TXINBANDFCS_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TX_ENABLE = "TRUE";  
    defparam v5_emac.EMAC0_TXVLAN_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_TXHALFDUPLEX = "FALSE";  
    defparam v5_emac.EMAC0_TXIFGADJUST_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_RXRESET = "FALSE";  
    defparam v5_emac.EMAC0_RXJUMBOFRAME_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_RXINBANDFCS_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_RX_ENABLE = "TRUE";  
    defparam v5_emac.EMAC0_RXVLAN_ENABLE = "FALSE";  
    defparam v5_emac.EMAC0_RXHALFDUPLEX = "FALSE";  
    defparam v5_emac.EMAC0_PAUSEADDR = 48'hFFEEDDCCBBAA;
    defparam v5_emac.EMAC0_UNICASTADDR = 48'h000000000000;
    defparam v5_emac.EMAC0_DCRBASEADDR = 8'h00;
endmodule
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
