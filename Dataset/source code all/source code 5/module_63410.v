`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module v6_emac_v1_3
(
    EMACCLIENTRXCLIENTCLKOUT,
    CLIENTEMACRXCLIENTCLKIN,
    EMACCLIENTRXD,
    EMACCLIENTRXDVLD,
    EMACCLIENTRXDVLDMSW,
    EMACCLIENTRXGOODFRAME,
    EMACCLIENTRXBADFRAME,
    EMACCLIENTRXFRAMEDROP,
    EMACCLIENTRXSTATS,
    EMACCLIENTRXSTATSVLD,
    EMACCLIENTRXSTATSBYTEVLD,
    EMACCLIENTTXCLIENTCLKOUT,
    CLIENTEMACTXCLIENTCLKIN,
    CLIENTEMACTXD,
    CLIENTEMACTXDVLD,
    CLIENTEMACTXDVLDMSW,
    EMACCLIENTTXACK,
    CLIENTEMACTXFIRSTBYTE,
    CLIENTEMACTXUNDERRUN,
    EMACCLIENTTXCOLLISION,
    EMACCLIENTTXRETRANSMIT,
    CLIENTEMACTXIFGDELAY,
    EMACCLIENTTXSTATS,
    EMACCLIENTTXSTATSVLD,
    EMACCLIENTTXSTATSBYTEVLD,
    CLIENTEMACPAUSEREQ,
    CLIENTEMACPAUSEVAL,
    GTX_CLK,
    PHYEMACTXGMIIMIICLKIN,
    EMACPHYTXGMIIMIICLKOUT,
    GMII_TXD,
    GMII_TX_EN,
    GMII_TX_ER,
    GMII_RXD,
    GMII_RX_DV,
    GMII_RX_ER,
    GMII_RX_CLK,
    MMCM_LOCKED,
    RESET
);
    output          EMACCLIENTRXCLIENTCLKOUT;
    input           CLIENTEMACRXCLIENTCLKIN;
    output   [7:0]  EMACCLIENTRXD;
    output          EMACCLIENTRXDVLD;
    output          EMACCLIENTRXDVLDMSW;
    output          EMACCLIENTRXGOODFRAME;
    output          EMACCLIENTRXBADFRAME;
    output          EMACCLIENTRXFRAMEDROP;
    output   [6:0]  EMACCLIENTRXSTATS;
    output          EMACCLIENTRXSTATSVLD;
    output          EMACCLIENTRXSTATSBYTEVLD;
    output          EMACCLIENTTXCLIENTCLKOUT;
    input           CLIENTEMACTXCLIENTCLKIN;
    input    [7:0]  CLIENTEMACTXD;
    input           CLIENTEMACTXDVLD;
    input           CLIENTEMACTXDVLDMSW;
    output          EMACCLIENTTXACK;
    input           CLIENTEMACTXFIRSTBYTE;
    input           CLIENTEMACTXUNDERRUN;
    output          EMACCLIENTTXCOLLISION;
    output          EMACCLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMACTXIFGDELAY;
    output          EMACCLIENTTXSTATS;
    output          EMACCLIENTTXSTATSVLD;
    output          EMACCLIENTTXSTATSBYTEVLD;
    input           CLIENTEMACPAUSEREQ;
    input   [15:0]  CLIENTEMACPAUSEVAL;
    input           GTX_CLK;
    output          EMACPHYTXGMIIMIICLKOUT;
    input           PHYEMACTXGMIIMIICLKIN;
    output   [7:0]  GMII_TXD;
    output          GMII_TX_EN;
    output          GMII_TX_ER;
    input    [7:0]  GMII_RXD;
    input           GMII_RX_DV;
    input           GMII_RX_ER;
    input           GMII_RX_CLK;
    input           MMCM_LOCKED;
    input           RESET;
    wire    [15:0]  client_rx_data_i;
    wire    [15:0]  client_tx_data_i;
    assign EMACCLIENTRXD = client_rx_data_i[7:0];
    assign #4000 client_tx_data_i = {8'b00000000, CLIENTEMACTXD};
    TEMAC_SINGLE #(
       .EMAC_PHYINITAUTONEG_ENABLE         ("FALSE"),
       .EMAC_PHYISOLATE                    ("FALSE"),
       .EMAC_PHYLOOPBACKMSB                ("FALSE"),
       .EMAC_PHYPOWERDOWN                  ("FALSE"),
       .EMAC_PHYRESET                      ("TRUE"),
       .EMAC_GTLOOPBACK                    ("FALSE"),
       .EMAC_UNIDIRECTION_ENABLE           ("FALSE"),
       .EMAC_LINKTIMERVAL                  (9'h000),
       .EMAC_MDIO_IGNORE_PHYADZERO         ("FALSE"),
       .EMAC_MDIO_ENABLE                   ("FALSE"),
       .EMAC_SPEED_LSB                     ("FALSE"),
       .EMAC_SPEED_MSB                     ("TRUE"),
       .EMAC_USECLKEN                      ("FALSE"),
       .EMAC_BYTEPHY                       ("FALSE"),
       .EMAC_RGMII_ENABLE                  ("FALSE"),
       .EMAC_SGMII_ENABLE                  ("FALSE"),
       .EMAC_1000BASEX_ENABLE              ("FALSE"),
       .EMAC_HOST_ENABLE                   ("FALSE"),
       .EMAC_TX16BITCLIENT_ENABLE          ("FALSE"),
       .EMAC_RX16BITCLIENT_ENABLE          ("FALSE"),
       .EMAC_ADDRFILTER_ENABLE             ("FALSE"),
       .EMAC_LTCHECK_DISABLE               ("FALSE"),
       .EMAC_CTRLLENCHECK_DISABLE          ("FALSE"),
       .EMAC_RXFLOWCTRL_ENABLE             ("FALSE"),
       .EMAC_TXFLOWCTRL_ENABLE             ("FALSE"),
       .EMAC_TXRESET                       ("FALSE"),
       .EMAC_TXJUMBOFRAME_ENABLE           ("FALSE"),
       .EMAC_TXINBANDFCS_ENABLE            ("FALSE"),
       .EMAC_TX_ENABLE                     ("TRUE"),
       .EMAC_TXVLAN_ENABLE                 ("FALSE"),
       .EMAC_TXHALFDUPLEX                  ("FALSE"),
       .EMAC_TXIFGADJUST_ENABLE            ("FALSE"),
       .EMAC_RXRESET                       ("FALSE"),
       .EMAC_RXJUMBOFRAME_ENABLE           ("FALSE"),
       .EMAC_RXINBANDFCS_ENABLE            ("FALSE"),
       .EMAC_RX_ENABLE                     ("TRUE"),
       .EMAC_RXVLAN_ENABLE                 ("FALSE"),
       .EMAC_RXHALFDUPLEX                  ("FALSE"),
       .EMAC_PAUSEADDR                     (48'hFFEEDDCCBBAA),
       .EMAC_UNICASTADDR                   (48'h000000000000),
       .EMAC_DCRBASEADDR                   (8'h00)
    )
    v6_emac
    (
        .RESET                    (RESET),
        .EMACCLIENTRXCLIENTCLKOUT (EMACCLIENTRXCLIENTCLKOUT),
        .CLIENTEMACRXCLIENTCLKIN  (CLIENTEMACRXCLIENTCLKIN),
        .EMACCLIENTRXD            (client_rx_data_i),
        .EMACCLIENTRXDVLD         (EMACCLIENTRXDVLD),
        .EMACCLIENTRXDVLDMSW      (EMACCLIENTRXDVLDMSW),
        .EMACCLIENTRXGOODFRAME    (EMACCLIENTRXGOODFRAME),
        .EMACCLIENTRXBADFRAME     (EMACCLIENTRXBADFRAME),
        .EMACCLIENTRXFRAMEDROP    (EMACCLIENTRXFRAMEDROP),
        .EMACCLIENTRXSTATS        (EMACCLIENTRXSTATS),
        .EMACCLIENTRXSTATSVLD     (EMACCLIENTRXSTATSVLD),
        .EMACCLIENTRXSTATSBYTEVLD (EMACCLIENTRXSTATSBYTEVLD),
        .EMACCLIENTTXCLIENTCLKOUT (EMACCLIENTTXCLIENTCLKOUT),
        .CLIENTEMACTXCLIENTCLKIN  (CLIENTEMACTXCLIENTCLKIN),
        .CLIENTEMACTXD            (client_tx_data_i),
        .CLIENTEMACTXDVLD         (CLIENTEMACTXDVLD),
        .CLIENTEMACTXDVLDMSW      (CLIENTEMACTXDVLDMSW),
        .EMACCLIENTTXACK          (EMACCLIENTTXACK),
        .CLIENTEMACTXFIRSTBYTE    (CLIENTEMACTXFIRSTBYTE),
        .CLIENTEMACTXUNDERRUN     (CLIENTEMACTXUNDERRUN),
        .EMACCLIENTTXCOLLISION    (EMACCLIENTTXCOLLISION),
        .EMACCLIENTTXRETRANSMIT   (EMACCLIENTTXRETRANSMIT),
        .CLIENTEMACTXIFGDELAY     (CLIENTEMACTXIFGDELAY),
        .EMACCLIENTTXSTATS        (EMACCLIENTTXSTATS),
        .EMACCLIENTTXSTATSVLD     (EMACCLIENTTXSTATSVLD),
        .EMACCLIENTTXSTATSBYTEVLD (EMACCLIENTTXSTATSBYTEVLD),
        .CLIENTEMACPAUSEREQ       (CLIENTEMACPAUSEREQ),
        .CLIENTEMACPAUSEVAL       (CLIENTEMACPAUSEVAL),
        .PHYEMACGTXCLK            (GTX_CLK),
        .EMACPHYTXGMIIMIICLKOUT   (EMACPHYTXGMIIMIICLKOUT),
        .PHYEMACTXGMIIMIICLKIN    (PHYEMACTXGMIIMIICLKIN),
        .PHYEMACRXCLK             (GMII_RX_CLK),
        .PHYEMACRXD               (GMII_RXD),
        .PHYEMACRXDV              (GMII_RX_DV),
        .PHYEMACRXER              (GMII_RX_ER),
        .EMACPHYTXCLK             (),
        .EMACPHYTXD               (GMII_TXD),
        .EMACPHYTXEN              (GMII_TX_EN),
        .EMACPHYTXER              (GMII_TX_ER),
        .PHYEMACMIITXCLK          (1'b0),
        .PHYEMACCOL               (1'b0),
        .PHYEMACCRS               (1'b0),
        .CLIENTEMACDCMLOCKED      (MMCM_LOCKED),
        .EMACCLIENTANINTERRUPT    (),
        .PHYEMACSIGNALDET         (1'b0),
        .PHYEMACPHYAD             (5'b00000),
        .EMACPHYENCOMMAALIGN      (),
        .EMACPHYLOOPBACKMSB       (),
        .EMACPHYMGTRXRESET        (),
        .EMACPHYMGTTXRESET        (),
        .EMACPHYPOWERDOWN         (),
        .EMACPHYSYNCACQSTATUS     (),
        .PHYEMACRXCLKCORCNT       (3'b000),
        .PHYEMACRXBUFSTATUS       (2'b00),
        .PHYEMACRXCHARISCOMMA     (1'b0),
        .PHYEMACRXCHARISK         (1'b0),
        .PHYEMACRXDISPERR         (1'b0),
        .PHYEMACRXNOTINTABLE      (1'b0),
        .PHYEMACRXRUNDISP         (1'b0),
        .PHYEMACTXBUFERR          (1'b0),
        .EMACPHYTXCHARDISPMODE    (),
        .EMACPHYTXCHARDISPVAL     (),
        .EMACPHYTXCHARISK         (),
        .EMACPHYMCLKOUT           (),
        .PHYEMACMCLKIN            (1'b0),
        .PHYEMACMDIN              (1'b1),
        .EMACPHYMDOUT             (),
        .EMACPHYMDTRI             (),
        .EMACSPEEDIS10100         (),
        .HOSTCLK                  (1'b0),
        .HOSTOPCODE               (2'b00),
        .HOSTREQ                  (1'b0),
        .HOSTMIIMSEL              (1'b0),
        .HOSTADDR                 (10'b0000000000),
        .HOSTWRDATA               (32'h00000000),
        .HOSTMIIMRDY              (),
        .HOSTRDDATA               (),
        .DCREMACCLK               (1'b0),
        .DCREMACABUS              (10'h000),
        .DCREMACREAD              (1'b0),
        .DCREMACWRITE             (1'b0),
        .DCREMACDBUS              (32'h00000000),
        .EMACDCRACK               (),
        .EMACDCRDBUS              (),
        .DCREMACENABLE            (1'b0),
        .DCRHOSTDONEIR            ()
    );
endmodule
`timescale 1 ps / 1 ps
module gmii_if (
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
  RX_CLK
);
  input        RESET;
  output [7:0] GMII_TXD;
  output       GMII_TX_EN;
  output       GMII_TX_ER;
  output       GMII_TX_CLK;
  input  [7:0] GMII_RXD;
  input        GMII_RX_DV;
  input        GMII_RX_ER;
  input  [7:0] TXD_FROM_MAC;
  input        TX_EN_FROM_MAC;
  input        TX_ER_FROM_MAC;
  input        TX_CLK;
  output [7:0] RXD_TO_MAC;
  output       RX_DV_TO_MAC;
  output       RX_ER_TO_MAC;
  input        RX_CLK;
  reg    [7:0] RXD_TO_MAC;
  reg          RX_DV_TO_MAC;
  reg          RX_ER_TO_MAC;
  reg    [7:0] GMII_TXD;
  reg          GMII_TX_EN;
  reg          GMII_TX_ER;
  wire   [7:0] GMII_RXD_DLY;
  wire         GMII_RX_DV_DLY;
  wire         GMII_RX_ER_DLY;
  ODDR gmii_tx_clk_oddr (
     .Q  (GMII_TX_CLK),
     .C  (TX_CLK),
     .CE (1'b1),
     .D1 (1'b0),
     .D2 (1'b1),
     .R  (RESET),
     .S  (1'b0)
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
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld0 (
    .IDATAIN(GMII_RXD[0]),
    .DATAOUT(GMII_RXD_DLY[0]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
 IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld1 (
    .IDATAIN(GMII_RXD[1]),
    .DATAOUT(GMII_RXD_DLY[1]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld2 (
    .IDATAIN(GMII_RXD[2]),
    .DATAOUT(GMII_RXD_DLY[2]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld3 (
    .IDATAIN(GMII_RXD[3]),
    .DATAOUT(GMII_RXD_DLY[3]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld4 (
    .IDATAIN(GMII_RXD[4]),
    .DATAOUT(GMII_RXD_DLY[4]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld5 (
    .IDATAIN(GMII_RXD[5]),
    .DATAOUT(GMII_RXD_DLY[5]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld6 (
    .IDATAIN(GMII_RXD[6]),
    .DATAOUT(GMII_RXD_DLY[6]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld7 (
    .IDATAIN(GMII_RXD[7]),
    .DATAOUT(GMII_RXD_DLY[7]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideldv(
    .IDATAIN(GMII_RX_DV),
    .DATAOUT(GMII_RX_DV_DLY),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
 );
 IODELAY #(
   .IDELAY_TYPE           ("FIXED"),
   .IDELAY_VALUE          (0),
   .HIGH_PERFORMANCE_MODE ("TRUE")
 )
 ideler(
   .IDATAIN(GMII_RX_ER),
   .DATAOUT(GMII_RX_ER_DLY),
   .DATAIN(1'b0),
   .ODATAIN(1'b0),
   .C(1'b0),
   .CE(1'b0),
   .INC(1'b0),
   .T(1'b0),
   .RST(1'b0)
 );
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
module v6_emac_v1_3_block
(
    TX_CLK_OUT,
    TX_CLK,
    EMACCLIENTRXD,
    EMACCLIENTRXDVLD,
    EMACCLIENTRXGOODFRAME,
    EMACCLIENTRXBADFRAME,
    EMACCLIENTRXFRAMEDROP,
    EMACCLIENTRXSTATS,
    EMACCLIENTRXSTATSVLD,
    EMACCLIENTRXSTATSBYTEVLD,
    CLIENTEMACTXD,
    CLIENTEMACTXDVLD,
    EMACCLIENTTXACK,
    CLIENTEMACTXFIRSTBYTE,
    CLIENTEMACTXUNDERRUN,
    EMACCLIENTTXCOLLISION,
    EMACCLIENTTXRETRANSMIT,
    CLIENTEMACTXIFGDELAY,
    EMACCLIENTTXSTATS,
    EMACCLIENTTXSTATSVLD,
    EMACCLIENTTXSTATSBYTEVLD,
    CLIENTEMACPAUSEREQ,
    CLIENTEMACPAUSEVAL,
    PHY_RX_CLK,
    GTX_CLK,
    GMII_TXD,
    GMII_TX_EN,
    GMII_TX_ER,
    GMII_TX_CLK,
    GMII_RXD,
    GMII_RX_DV,
    GMII_RX_ER,
    GMII_RX_CLK,
    RESET
);
    output          TX_CLK_OUT;
    input           TX_CLK;
    output   [7:0]  EMACCLIENTRXD;
    output          EMACCLIENTRXDVLD;
    output          EMACCLIENTRXGOODFRAME;
    output          EMACCLIENTRXBADFRAME;
    output          EMACCLIENTRXFRAMEDROP;
    output   [6:0]  EMACCLIENTRXSTATS;
    output          EMACCLIENTRXSTATSVLD;
    output          EMACCLIENTRXSTATSBYTEVLD;
    input    [7:0]  CLIENTEMACTXD;
    input           CLIENTEMACTXDVLD;
    output          EMACCLIENTTXACK;
    input           CLIENTEMACTXFIRSTBYTE;
    input           CLIENTEMACTXUNDERRUN;
    output          EMACCLIENTTXCOLLISION;
    output          EMACCLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMACTXIFGDELAY;
    output          EMACCLIENTTXSTATS;
    output          EMACCLIENTTXSTATSVLD;
    output          EMACCLIENTTXSTATSBYTEVLD;
    input           CLIENTEMACPAUSEREQ;
    input   [15:0]  CLIENTEMACPAUSEVAL;
    input           PHY_RX_CLK;
    input           GTX_CLK;
    output   [7:0]  GMII_TXD;
    output          GMII_TX_EN;
    output          GMII_TX_ER;
    output          GMII_TX_CLK;
    input    [7:0]  GMII_RXD;
    input           GMII_RX_DV;
    input           GMII_RX_ER;
    input           GMII_RX_CLK;
    input           RESET;
    wire            reset_ibuf_i;
    wire            reset_i;
    wire            rx_client_clk_out_i;
    wire            rx_client_clk_in_i;
    wire            tx_client_clk_out_i;
    wire            tx_client_clk_in_i;
    wire            tx_gmii_mii_clk_out_i;
    wire            tx_gmii_mii_clk_in_i;
    wire            gmii_tx_en_i;
    wire            gmii_tx_er_i;
    wire     [7:0]  gmii_txd_i;
    wire            gmii_rx_dv_r;
    wire            gmii_rx_er_r;
    wire     [7:0]  gmii_rxd_r;
    wire            gmii_rx_clk_i;
    wire            gtx_clk_ibufg_i;
    assign reset_ibuf_i = RESET;
    assign reset_i = reset_ibuf_i;
    gmii_if gmii (
        .RESET          (reset_i),
        .GMII_TXD       (GMII_TXD),
        .GMII_TX_EN     (GMII_TX_EN),
        .GMII_TX_ER     (GMII_TX_ER),
        .GMII_TX_CLK    (GMII_TX_CLK),
        .GMII_RXD       (GMII_RXD),
        .GMII_RX_DV     (GMII_RX_DV),
        .GMII_RX_ER     (GMII_RX_ER),
        .TXD_FROM_MAC   (gmii_txd_i),
        .TX_EN_FROM_MAC (gmii_tx_en_i),
        .TX_ER_FROM_MAC (gmii_tx_er_i),
        .TX_CLK         (tx_gmii_mii_clk_in_i),
        .RXD_TO_MAC     (gmii_rxd_r),
        .RX_DV_TO_MAC   (gmii_rx_dv_r),
        .RX_ER_TO_MAC   (gmii_rx_er_r),
        .RX_CLK         (GMII_RX_CLK)
    );
    assign gtx_clk_ibufg_i = GTX_CLK;
    assign tx_gmii_mii_clk_in_i = TX_CLK;
    assign gmii_rx_clk_i = PHY_RX_CLK;
    assign tx_client_clk_in_i = TX_CLK;
    assign rx_client_clk_in_i = gmii_rx_clk_i;
    assign TX_CLK_OUT = tx_gmii_mii_clk_out_i;
    v6_emac_v1_3 v6_emac_v1_3_inst
    (
        .EMACCLIENTRXCLIENTCLKOUT    (rx_client_clk_out_i),
        .CLIENTEMACRXCLIENTCLKIN     (rx_client_clk_in_i),
        .EMACCLIENTRXD               (EMACCLIENTRXD),
        .EMACCLIENTRXDVLD            (EMACCLIENTRXDVLD),
        .EMACCLIENTRXDVLDMSW         (),
        .EMACCLIENTRXGOODFRAME       (EMACCLIENTRXGOODFRAME),
        .EMACCLIENTRXBADFRAME        (EMACCLIENTRXBADFRAME),
        .EMACCLIENTRXFRAMEDROP       (EMACCLIENTRXFRAMEDROP),
        .EMACCLIENTRXSTATS           (EMACCLIENTRXSTATS),
        .EMACCLIENTRXSTATSVLD        (EMACCLIENTRXSTATSVLD),
        .EMACCLIENTRXSTATSBYTEVLD    (EMACCLIENTRXSTATSBYTEVLD),
        .EMACCLIENTTXCLIENTCLKOUT    (tx_client_clk_out_i),
        .CLIENTEMACTXCLIENTCLKIN     (tx_client_clk_in_i),
        .CLIENTEMACTXD               (CLIENTEMACTXD),
        .CLIENTEMACTXDVLD            (CLIENTEMACTXDVLD),
        .CLIENTEMACTXDVLDMSW         (1'b0),
        .EMACCLIENTTXACK             (EMACCLIENTTXACK),
        .CLIENTEMACTXFIRSTBYTE       (CLIENTEMACTXFIRSTBYTE),
        .CLIENTEMACTXUNDERRUN        (CLIENTEMACTXUNDERRUN),
        .EMACCLIENTTXCOLLISION       (EMACCLIENTTXCOLLISION),
        .EMACCLIENTTXRETRANSMIT      (EMACCLIENTTXRETRANSMIT),
        .CLIENTEMACTXIFGDELAY        (CLIENTEMACTXIFGDELAY),
        .EMACCLIENTTXSTATS           (EMACCLIENTTXSTATS),
        .EMACCLIENTTXSTATSVLD        (EMACCLIENTTXSTATSVLD),
        .EMACCLIENTTXSTATSBYTEVLD    (EMACCLIENTTXSTATSBYTEVLD),
        .CLIENTEMACPAUSEREQ          (CLIENTEMACPAUSEREQ),
        .CLIENTEMACPAUSEVAL          (CLIENTEMACPAUSEVAL),
        .GTX_CLK                     (gtx_clk_ibufg_i),
        .EMACPHYTXGMIIMIICLKOUT      (tx_gmii_mii_clk_out_i),
        .PHYEMACTXGMIIMIICLKIN       (tx_gmii_mii_clk_in_i),
        .GMII_TXD                    (gmii_txd_i),
        .GMII_TX_EN                  (gmii_tx_en_i),
        .GMII_TX_ER                  (gmii_tx_er_i),
        .GMII_RXD                    (gmii_rxd_r),
        .GMII_RX_DV                  (gmii_rx_dv_r),
        .GMII_RX_ER                  (gmii_rx_er_r),
        .GMII_RX_CLK                 (gmii_rx_clk_i),
        .MMCM_LOCKED                 (1'b1),
        .RESET                       (reset_i)
    );
endmodule
`timescale 1 ps / 1 ps
module v6_emac_v1_3
(
    EMACCLIENTRXCLIENTCLKOUT,
    CLIENTEMACRXCLIENTCLKIN,
    EMACCLIENTRXD,
    EMACCLIENTRXDVLD,
    EMACCLIENTRXDVLDMSW,
    EMACCLIENTRXGOODFRAME,
    EMACCLIENTRXBADFRAME,
    EMACCLIENTRXFRAMEDROP,
    EMACCLIENTRXSTATS,
    EMACCLIENTRXSTATSVLD,
    EMACCLIENTRXSTATSBYTEVLD,
    EMACCLIENTTXCLIENTCLKOUT,
    CLIENTEMACTXCLIENTCLKIN,
    CLIENTEMACTXD,
    CLIENTEMACTXDVLD,
    CLIENTEMACTXDVLDMSW,
    EMACCLIENTTXACK,
    CLIENTEMACTXFIRSTBYTE,
    CLIENTEMACTXUNDERRUN,
    EMACCLIENTTXCOLLISION,
    EMACCLIENTTXRETRANSMIT,
    CLIENTEMACTXIFGDELAY,
    EMACCLIENTTXSTATS,
    EMACCLIENTTXSTATSVLD,
    EMACCLIENTTXSTATSBYTEVLD,
    CLIENTEMACPAUSEREQ,
    CLIENTEMACPAUSEVAL,
    GTX_CLK,
    PHYEMACTXGMIIMIICLKIN,
    EMACPHYTXGMIIMIICLKOUT,
    GMII_TXD,
    GMII_TX_EN,
    GMII_TX_ER,
    GMII_RXD,
    GMII_RX_DV,
    GMII_RX_ER,
    GMII_RX_CLK,
    MMCM_LOCKED,
    RESET
);
    output          EMACCLIENTRXCLIENTCLKOUT;
    input           CLIENTEMACRXCLIENTCLKIN;
    output   [7:0]  EMACCLIENTRXD;
    output          EMACCLIENTRXDVLD;
    output          EMACCLIENTRXDVLDMSW;
    output          EMACCLIENTRXGOODFRAME;
    output          EMACCLIENTRXBADFRAME;
    output          EMACCLIENTRXFRAMEDROP;
    output   [6:0]  EMACCLIENTRXSTATS;
    output          EMACCLIENTRXSTATSVLD;
    output          EMACCLIENTRXSTATSBYTEVLD;
    output          EMACCLIENTTXCLIENTCLKOUT;
    input           CLIENTEMACTXCLIENTCLKIN;
    input    [7:0]  CLIENTEMACTXD;
    input           CLIENTEMACTXDVLD;
    input           CLIENTEMACTXDVLDMSW;
    output          EMACCLIENTTXACK;
    input           CLIENTEMACTXFIRSTBYTE;
    input           CLIENTEMACTXUNDERRUN;
    output          EMACCLIENTTXCOLLISION;
    output          EMACCLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMACTXIFGDELAY;
    output          EMACCLIENTTXSTATS;
    output          EMACCLIENTTXSTATSVLD;
    output          EMACCLIENTTXSTATSBYTEVLD;
    input           CLIENTEMACPAUSEREQ;
    input   [15:0]  CLIENTEMACPAUSEVAL;
    input           GTX_CLK;
    output          EMACPHYTXGMIIMIICLKOUT;
    input           PHYEMACTXGMIIMIICLKIN;
    output   [7:0]  GMII_TXD;
    output          GMII_TX_EN;
    output          GMII_TX_ER;
    input    [7:0]  GMII_RXD;
    input           GMII_RX_DV;
    input           GMII_RX_ER;
    input           GMII_RX_CLK;
    input           MMCM_LOCKED;
    input           RESET;
    wire    [15:0]  client_rx_data_i;
    wire    [15:0]  client_tx_data_i;
    assign EMACCLIENTRXD = client_rx_data_i[7:0];
    assign #4000 client_tx_data_i = {8'b00000000, CLIENTEMACTXD};
    TEMAC_SINGLE #(
       .EMAC_PHYINITAUTONEG_ENABLE         ("FALSE"),
       .EMAC_PHYISOLATE                    ("FALSE"),
       .EMAC_PHYLOOPBACKMSB                ("FALSE"),
       .EMAC_PHYPOWERDOWN                  ("FALSE"),
       .EMAC_PHYRESET                      ("TRUE"),
       .EMAC_GTLOOPBACK                    ("FALSE"),
       .EMAC_UNIDIRECTION_ENABLE           ("FALSE"),
       .EMAC_LINKTIMERVAL                  (9'h000),
       .EMAC_MDIO_IGNORE_PHYADZERO         ("FALSE"),
       .EMAC_MDIO_ENABLE                   ("FALSE"),
       .EMAC_SPEED_LSB                     ("FALSE"),
       .EMAC_SPEED_MSB                     ("TRUE"),
       .EMAC_USECLKEN                      ("FALSE"),
       .EMAC_BYTEPHY                       ("FALSE"),
       .EMAC_RGMII_ENABLE                  ("FALSE"),
       .EMAC_SGMII_ENABLE                  ("FALSE"),
       .EMAC_1000BASEX_ENABLE              ("FALSE"),
       .EMAC_HOST_ENABLE                   ("FALSE"),
       .EMAC_TX16BITCLIENT_ENABLE          ("FALSE"),
       .EMAC_RX16BITCLIENT_ENABLE          ("FALSE"),
       .EMAC_ADDRFILTER_ENABLE             ("FALSE"),
       .EMAC_LTCHECK_DISABLE               ("FALSE"),
       .EMAC_CTRLLENCHECK_DISABLE          ("FALSE"),
       .EMAC_RXFLOWCTRL_ENABLE             ("FALSE"),
       .EMAC_TXFLOWCTRL_ENABLE             ("FALSE"),
       .EMAC_TXRESET                       ("FALSE"),
       .EMAC_TXJUMBOFRAME_ENABLE           ("FALSE"),
       .EMAC_TXINBANDFCS_ENABLE            ("FALSE"),
       .EMAC_TX_ENABLE                     ("TRUE"),
       .EMAC_TXVLAN_ENABLE                 ("FALSE"),
       .EMAC_TXHALFDUPLEX                  ("FALSE"),
       .EMAC_TXIFGADJUST_ENABLE            ("FALSE"),
       .EMAC_RXRESET                       ("FALSE"),
       .EMAC_RXJUMBOFRAME_ENABLE           ("FALSE"),
       .EMAC_RXINBANDFCS_ENABLE            ("FALSE"),
       .EMAC_RX_ENABLE                     ("TRUE"),
       .EMAC_RXVLAN_ENABLE                 ("FALSE"),
       .EMAC_RXHALFDUPLEX                  ("FALSE"),
       .EMAC_PAUSEADDR                     (48'hFFEEDDCCBBAA),
       .EMAC_UNICASTADDR                   (48'h000000000000),
       .EMAC_DCRBASEADDR                   (8'h00)
    )
    v6_emac
    (
        .RESET                    (RESET),
        .EMACCLIENTRXCLIENTCLKOUT (EMACCLIENTRXCLIENTCLKOUT),
        .CLIENTEMACRXCLIENTCLKIN  (CLIENTEMACRXCLIENTCLKIN),
        .EMACCLIENTRXD            (client_rx_data_i),
        .EMACCLIENTRXDVLD         (EMACCLIENTRXDVLD),
        .EMACCLIENTRXDVLDMSW      (EMACCLIENTRXDVLDMSW),
        .EMACCLIENTRXGOODFRAME    (EMACCLIENTRXGOODFRAME),
        .EMACCLIENTRXBADFRAME     (EMACCLIENTRXBADFRAME),
        .EMACCLIENTRXFRAMEDROP    (EMACCLIENTRXFRAMEDROP),
        .EMACCLIENTRXSTATS        (EMACCLIENTRXSTATS),
        .EMACCLIENTRXSTATSVLD     (EMACCLIENTRXSTATSVLD),
        .EMACCLIENTRXSTATSBYTEVLD (EMACCLIENTRXSTATSBYTEVLD),
        .EMACCLIENTTXCLIENTCLKOUT (EMACCLIENTTXCLIENTCLKOUT),
        .CLIENTEMACTXCLIENTCLKIN  (CLIENTEMACTXCLIENTCLKIN),
        .CLIENTEMACTXD            (client_tx_data_i),
        .CLIENTEMACTXDVLD         (CLIENTEMACTXDVLD),
        .CLIENTEMACTXDVLDMSW      (CLIENTEMACTXDVLDMSW),
        .EMACCLIENTTXACK          (EMACCLIENTTXACK),
        .CLIENTEMACTXFIRSTBYTE    (CLIENTEMACTXFIRSTBYTE),
        .CLIENTEMACTXUNDERRUN     (CLIENTEMACTXUNDERRUN),
        .EMACCLIENTTXCOLLISION    (EMACCLIENTTXCOLLISION),
        .EMACCLIENTTXRETRANSMIT   (EMACCLIENTTXRETRANSMIT),
        .CLIENTEMACTXIFGDELAY     (CLIENTEMACTXIFGDELAY),
        .EMACCLIENTTXSTATS        (EMACCLIENTTXSTATS),
        .EMACCLIENTTXSTATSVLD     (EMACCLIENTTXSTATSVLD),
        .EMACCLIENTTXSTATSBYTEVLD (EMACCLIENTTXSTATSBYTEVLD),
        .CLIENTEMACPAUSEREQ       (CLIENTEMACPAUSEREQ),
        .CLIENTEMACPAUSEVAL       (CLIENTEMACPAUSEVAL),
        .PHYEMACGTXCLK            (GTX_CLK),
        .EMACPHYTXGMIIMIICLKOUT   (EMACPHYTXGMIIMIICLKOUT),
        .PHYEMACTXGMIIMIICLKIN    (PHYEMACTXGMIIMIICLKIN),
        .PHYEMACRXCLK             (GMII_RX_CLK),
        .PHYEMACRXD               (GMII_RXD),
        .PHYEMACRXDV              (GMII_RX_DV),
        .PHYEMACRXER              (GMII_RX_ER),
        .EMACPHYTXCLK             (),
        .EMACPHYTXD               (GMII_TXD),
        .EMACPHYTXEN              (GMII_TX_EN),
        .EMACPHYTXER              (GMII_TX_ER),
        .PHYEMACMIITXCLK          (1'b0),
        .PHYEMACCOL               (1'b0),
        .PHYEMACCRS               (1'b0),
        .CLIENTEMACDCMLOCKED      (MMCM_LOCKED),
        .EMACCLIENTANINTERRUPT    (),
        .PHYEMACSIGNALDET         (1'b0),
        .PHYEMACPHYAD             (5'b00000),
        .EMACPHYENCOMMAALIGN      (),
        .EMACPHYLOOPBACKMSB       (),
        .EMACPHYMGTRXRESET        (),
        .EMACPHYMGTTXRESET        (),
        .EMACPHYPOWERDOWN         (),
        .EMACPHYSYNCACQSTATUS     (),
        .PHYEMACRXCLKCORCNT       (3'b000),
        .PHYEMACRXBUFSTATUS       (2'b00),
        .PHYEMACRXCHARISCOMMA     (1'b0),
        .PHYEMACRXCHARISK         (1'b0),
        .PHYEMACRXDISPERR         (1'b0),
        .PHYEMACRXNOTINTABLE      (1'b0),
        .PHYEMACRXRUNDISP         (1'b0),
        .PHYEMACTXBUFERR          (1'b0),
        .EMACPHYTXCHARDISPMODE    (),
        .EMACPHYTXCHARDISPVAL     (),
        .EMACPHYTXCHARISK         (),
        .EMACPHYMCLKOUT           (),
        .PHYEMACMCLKIN            (1'b0),
        .PHYEMACMDIN              (1'b1),
        .EMACPHYMDOUT             (),
        .EMACPHYMDTRI             (),
        .EMACSPEEDIS10100         (),
        .HOSTCLK                  (1'b0),
        .HOSTOPCODE               (2'b00),
        .HOSTREQ                  (1'b0),
        .HOSTMIIMSEL              (1'b0),
        .HOSTADDR                 (10'b0000000000),
        .HOSTWRDATA               (32'h00000000),
        .HOSTMIIMRDY              (),
        .HOSTRDDATA               (),
        .DCREMACCLK               (1'b0),
        .DCREMACABUS              (10'h000),
        .DCREMACREAD              (1'b0),
        .DCREMACWRITE             (1'b0),
        .DCREMACDBUS              (32'h00000000),
        .EMACDCRACK               (),
        .EMACDCRDBUS              (),
        .DCREMACENABLE            (1'b0),
        .DCRHOSTDONEIR            ()
    );
endmodule
`timescale 1 ps / 1 ps
module gmii_if (
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
  RX_CLK
);
  input        RESET;
  output [7:0] GMII_TXD;
  output       GMII_TX_EN;
  output       GMII_TX_ER;
  output       GMII_TX_CLK;
  input  [7:0] GMII_RXD;
  input        GMII_RX_DV;
  input        GMII_RX_ER;
  input  [7:0] TXD_FROM_MAC;
  input        TX_EN_FROM_MAC;
  input        TX_ER_FROM_MAC;
  input        TX_CLK;
  output [7:0] RXD_TO_MAC;
  output       RX_DV_TO_MAC;
  output       RX_ER_TO_MAC;
  input        RX_CLK;
  reg    [7:0] RXD_TO_MAC;
  reg          RX_DV_TO_MAC;
  reg          RX_ER_TO_MAC;
  reg    [7:0] GMII_TXD;
  reg          GMII_TX_EN;
  reg          GMII_TX_ER;
  wire   [7:0] GMII_RXD_DLY;
  wire         GMII_RX_DV_DLY;
  wire         GMII_RX_ER_DLY;
  ODDR gmii_tx_clk_oddr (
     .Q  (GMII_TX_CLK),
     .C  (TX_CLK),
     .CE (1'b1),
     .D1 (1'b0),
     .D2 (1'b1),
     .R  (RESET),
     .S  (1'b0)
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
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld0 (
    .IDATAIN(GMII_RXD[0]),
    .DATAOUT(GMII_RXD_DLY[0]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
 IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld1 (
    .IDATAIN(GMII_RXD[1]),
    .DATAOUT(GMII_RXD_DLY[1]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld2 (
    .IDATAIN(GMII_RXD[2]),
    .DATAOUT(GMII_RXD_DLY[2]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld3 (
    .IDATAIN(GMII_RXD[3]),
    .DATAOUT(GMII_RXD_DLY[3]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld4 (
    .IDATAIN(GMII_RXD[4]),
    .DATAOUT(GMII_RXD_DLY[4]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld5 (
    .IDATAIN(GMII_RXD[5]),
    .DATAOUT(GMII_RXD_DLY[5]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld6 (
    .IDATAIN(GMII_RXD[6]),
    .DATAOUT(GMII_RXD_DLY[6]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideld7 (
    .IDATAIN(GMII_RXD[7]),
    .DATAOUT(GMII_RXD_DLY[7]),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
  );
  IODELAY #(
    .IDELAY_TYPE           ("FIXED"),
    .IDELAY_VALUE          (0),
    .HIGH_PERFORMANCE_MODE ("TRUE")
  )
  ideldv(
    .IDATAIN(GMII_RX_DV),
    .DATAOUT(GMII_RX_DV_DLY),
    .DATAIN(1'b0),
    .ODATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .T(1'b0),
    .RST(1'b0)
 );
 IODELAY #(
   .IDELAY_TYPE           ("FIXED"),
   .IDELAY_VALUE          (0),
   .HIGH_PERFORMANCE_MODE ("TRUE")
 )
 ideler(
   .IDATAIN(GMII_RX_ER),
   .DATAOUT(GMII_RX_ER_DLY),
   .DATAIN(1'b0),
   .ODATAIN(1'b0),
   .C(1'b0),
   .CE(1'b0),
   .INC(1'b0),
   .T(1'b0),
   .RST(1'b0)
 );
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
