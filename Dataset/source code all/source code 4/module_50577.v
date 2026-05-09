`timescale 1ns/1ns
`timescale 1ns/1ns
module gtx_wrapper_v6 (
    TX,
    TX_,
    TxData,
    TxDataK,
    TxElecIdle,
    TxCompliance,
    RX,
    RX_,
    RxData,
    RxDataK,
    RxPolarity,
    RxValid,
    RxElecIdle,
    RxStatus,
    GTRefClkout,
    plm_in_l0,
    plm_in_rl,
    plm_in_dt,
    plm_in_rs,
    RxPLLLkDet,
    TxDetectRx,
    PhyStatus,
    TXPdownAsynch,
    PowerDown,
    Rate,
    Reset_n,
    GTReset_n,
    PCLK,
    REFCLK,
    TxDeemph,
    TxMargin,
    TxSwing,
    ChanIsAligned,
    local_pcs_reset,
    RxResetDone,
    SyncDone,
    DRPCLK,
    TxOutClk
    );
    parameter                      NO_OF_LANES = 1;
    parameter                      REF_CLK_FREQ = 0;
    parameter                      PL_FAST_TRAIN = "FALSE";
    localparam                     GTX_PLL_DIVSEL_FB  = (REF_CLK_FREQ == 0) ? 5 :
                                                        (REF_CLK_FREQ == 1) ? 4 :
                                                        (REF_CLK_FREQ == 2) ? 2 : 0;
    localparam                     SIMULATION =  (PL_FAST_TRAIN == "TRUE") ? 1 : 0;
    localparam                     RXPLL_CP_CFG = (REF_CLK_FREQ == 0) ? 8'h05 :
                                                  (REF_CLK_FREQ == 1) ? 8'h05 :
                                                  (REF_CLK_FREQ == 2) ? 8'h05 : 8'h05;
    localparam                     TXPLL_CP_CFG = (REF_CLK_FREQ == 0) ? 8'h05 :
                                                  (REF_CLK_FREQ == 1) ? 8'h05 :
                                                  (REF_CLK_FREQ == 2) ? 8'h05 : 8'h05;
    localparam                     RX_CLK25_DIVIDER = (REF_CLK_FREQ == 0) ? 4  :
                                                      (REF_CLK_FREQ == 1) ? 5  :
                                                      (REF_CLK_FREQ == 2) ? 10 : 10 ;
    localparam                     TX_CLK25_DIVIDER = (REF_CLK_FREQ == 0) ? 4  :
                                                      (REF_CLK_FREQ == 1) ? 5  :
                                                      (REF_CLK_FREQ == 2) ? 10 : 10 ;
    output       [NO_OF_LANES-1:0] TX;
    output       [NO_OF_LANES-1:0] TX_;
    input   [(NO_OF_LANES*16)-1:0] TxData;
    input    [(NO_OF_LANES*2)-1:0] TxDataK;
    input        [NO_OF_LANES-1:0] TxElecIdle;
    input        [NO_OF_LANES-1:0] TxCompliance;
    input        [NO_OF_LANES-1:0] RX;
    input        [NO_OF_LANES-1:0] RX_;
    output  [(NO_OF_LANES*16)-1:0] RxData;
    output   [(NO_OF_LANES*2)-1:0] RxDataK;
    input        [NO_OF_LANES-1:0] RxPolarity;
    output       [NO_OF_LANES-1:0] RxValid;
    output       [NO_OF_LANES-1:0] RxElecIdle;
    output   [(NO_OF_LANES*3)-1:0] RxStatus;
    output       [NO_OF_LANES-1:0] GTRefClkout;
    input                          plm_in_l0;
    input                          plm_in_rl;
    input                          plm_in_dt;
    input                          plm_in_rs;
    output       [NO_OF_LANES-1:0] RxPLLLkDet;
    input                          TxDetectRx;
    output       [NO_OF_LANES-1:0] PhyStatus;
    input                          PCLK;
    output       [NO_OF_LANES-1:0] ChanIsAligned;
    input                          TXPdownAsynch;
    input    [(NO_OF_LANES*2)-1:0] PowerDown;
    input                          Rate;
    input                          Reset_n;
    input                          GTReset_n;
    input                          REFCLK;
    input                          TxDeemph;
    input                          TxMargin;
    input                          TxSwing;
    input                          local_pcs_reset;
    output                         RxResetDone;
    output                         SyncDone;
    input                          DRPCLK;
    output                         TxOutClk;
    genvar                         i;
    wire                    [15:0] RxData_dummy;
    wire                     [1:0] RxDataK_dummy;
    wire                    [15:0] TxData_dummy;
    wire                     [1:0] TxDataK_dummy;
    wire    [(NO_OF_LANES*16)-1:0] GTX_TxData       = TxData;
    wire     [(NO_OF_LANES*2)-1:0] GTX_TxDataK      = TxDataK;
    wire       [(NO_OF_LANES)-1:0] GTX_TxElecIdle   = TxElecIdle;
    wire       [(NO_OF_LANES-1):0] GTX_TxCompliance = TxCompliance;
    wire       [(NO_OF_LANES)-1:0] GTX_RXP          = RX[(NO_OF_LANES)-1:0];
    wire       [(NO_OF_LANES)-1:0] GTX_RXN          = RX_[(NO_OF_LANES)-1:0];
    wire       [(NO_OF_LANES)-1:0] GTX_TXP;
    wire       [(NO_OF_LANES)-1:0] GTX_TXN;
    wire    [(NO_OF_LANES*16)-1:0] GTX_RxData;
    wire     [(NO_OF_LANES*2)-1:0] GTX_RxDataK;
    wire       [(NO_OF_LANES)-1:0] GTX_RxPolarity   = RxPolarity ;
    wire       [(NO_OF_LANES)-1:0] GTX_RxValid;
    wire       [(NO_OF_LANES)-1:0] GTX_RxElecIdle;
    wire       [(NO_OF_LANES-1):0] GTX_RxResetDone;
    wire     [(NO_OF_LANES*3)-1:0] GTX_RxChbondLevel;
    wire     [(NO_OF_LANES*3)-1:0] GTX_RxStatus;
    wire                     [3:0] RXCHBOND [NO_OF_LANES+1:0];
    wire                     [3:0] TXBYPASS8B10B     = 4'b0000;
    wire                           RXDEC8B10BUSE     = 1'b1;
    wire         [NO_OF_LANES-1:0] GTX_PhyStatus;
    wire                           RESETDONE [NO_OF_LANES-1:0];
    wire                           REFCLK;
    wire                           GTXRESET          = 1'b0;
    wire         [NO_OF_LANES-1:0] SYNC_DONE;
    wire         [NO_OF_LANES-1:0] OUT_DIV_RESET;
    wire         [NO_OF_LANES-1:0] PCS_RESET;
    wire         [NO_OF_LANES-1:0] TXENPMAPHASEALIGN;
    wire         [NO_OF_LANES-1:0] TXPMASETPHASE;
    wire         [NO_OF_LANES-1:0] TXRESETDONE;
    wire         [NO_OF_LANES-1:0] TXRATEDONE;
    wire         [NO_OF_LANES-1:0] PHYSTATUS;
    wire         [NO_OF_LANES-1:0] RXVALID;
    wire         [NO_OF_LANES-1:0] RATE_CLK_SEL;
    wire         [NO_OF_LANES-1:0] TXOCLK;
    wire         [NO_OF_LANES-1:0] TXDLYALIGNDISABLE;
    wire         [NO_OF_LANES-1:0] TXDLYALIGNRESET;
    reg          [(NO_OF_LANES-1):0] GTX_RxResetDone_q;
    reg          [(NO_OF_LANES-1):0] TXRESETDONE_q;
    wire           [NO_OF_LANES-1:0] RxValid;
    wire       [(NO_OF_LANES*8-1):0] daddr;
    wire           [NO_OF_LANES-1:0] den;
    wire      [(NO_OF_LANES*16-1):0] din;
    wire           [NO_OF_LANES-1:0] dwe;
    wire       [(NO_OF_LANES*4-1):0] drpstate;
    wire           [NO_OF_LANES-1:0] drdy;
    wire      [(NO_OF_LANES*16-1):0] dout;
    wire                             write_drp_cb_fts;
    wire                             write_drp_cb_ts1;
    assign RxResetDone                 = &(GTX_RxResetDone_q[(NO_OF_LANES)-1:0]);
    assign TX[(NO_OF_LANES)-1:0]       = GTX_TXP[(NO_OF_LANES)-1:0];
    assign TX_[(NO_OF_LANES)-1:0]      = GTX_TXN[(NO_OF_LANES)-1:0];
    assign RXCHBOND[0]                 = 4'b0000;
    assign TxData_dummy                = 16'b0;
    assign TxDataK_dummy               = 2'b0;
    assign SyncDone                    = &(SYNC_DONE[(NO_OF_LANES)-1:0]);
    assign TxOutClk                    = TXOCLK[0];
    assign write_drp_cb_fts            = plm_in_l0;
    assign write_drp_cb_ts1            = plm_in_rl | plm_in_dt;
    always @ (posedge PCLK) begin
      GTX_RxResetDone_q[(NO_OF_LANES)-1:0]  <= GTX_RxResetDone[(NO_OF_LANES)-1:0];
      TXRESETDONE_q[(NO_OF_LANES)-1:0]      <= TXRESETDONE[(NO_OF_LANES)-1:0];
    end
    generate
    begin: no_of_lanes
      for (i=0; i < NO_OF_LANES; i=i+1) begin: GTXD
        assign GTX_RxChbondLevel[(3*i)+2:(3*i)] = (NO_OF_LANES-(i+1));
        GTX_DRP_CHANALIGN_FIX_3752_V6 # (
          .C_SIMULATION(SIMULATION)
        ) GTX_DRP_CHANALIGN_FIX_3752 (
          .dwe(dwe[i]),
          .din(din[(16*i)+15:(16*i)]),
          .den(den[i]),
          .daddr(daddr[(8*i)+7:(8*i)]),
          .drpstate(drpstate[(4*i)+3:(4*i)]),
          .write_ts1(write_drp_cb_ts1),
          .write_fts(write_drp_cb_fts),
          .dout(dout[(16*i)+15:(16*i)]),
          .drdy(drdy[i]),
          .Reset_n(Reset_n),
          .drp_clk(DRPCLK)
        );
        GTX_RX_VALID_FILTER_V6 # (
          .CLK_COR_MIN_LAT(28)
        )
        GTX_RX_VALID_FILTER (
          .USER_RXCHARISK   ( RxDataK[(2*i)+1:2*i] ),           
          .USER_RXDATA      ( RxData[(16*i)+15:(16*i)+0] ),     
          .USER_RXVALID     ( RxValid[i] ),                     
          .USER_RXELECIDLE  ( RxElecIdle[i] ),                  
          .USER_RX_STATUS   ( RxStatus[(3*i)+2:(3*i)] ),        
          .USER_RX_PHY_STATUS ( PhyStatus[i] ),                 
          .GT_RXCHARISK     ( GTX_RxDataK[(2*i)+1:2*i] ),       
          .GT_RXDATA        ( GTX_RxData[(16*i)+15:(16*i)+0] ), 
          .GT_RXVALID       ( GTX_RxValid[i] ),                 
          .GT_RXELECIDLE    ( GTX_RxElecIdle[i] ),              
          .GT_RX_STATUS     ( GTX_RxStatus[(3*i)+2:(3*i)] ),    
          .GT_RX_PHY_STATUS ( PHYSTATUS[i] ),
          .PLM_IN_L0        ( plm_in_l0 ),             
          .PLM_IN_RS        ( plm_in_rs ),                      
          .USER_CLK         ( PCLK ),                  
          .RESET            ( !Reset_n )               
        );
        GTX_TX_SYNC_RATE_V6 # (
          .C_SIMULATION(SIMULATION)
        )
        GTX_TX_SYNC (
          .ENPMAPHASEALIGN  ( TXENPMAPHASEALIGN[i] ),  
          .PMASETPHASE      ( TXPMASETPHASE[i] ),      
          .SYNC_DONE        ( SYNC_DONE[i] ),          
          .OUT_DIV_RESET    ( OUT_DIV_RESET[i] ),      
          .PCS_RESET        ( PCS_RESET[i] ),          
          .USER_PHYSTATUS   ( PHYSTATUS[i] ),          
          .TXALIGNDISABLE   ( TXDLYALIGNDISABLE[i] ),  
          .DELAYALIGNRESET  ( TXDLYALIGNRESET[i] ),    
          .USER_CLK         ( PCLK),                   
          .RESET            ( !Reset_n ),              
          .RATE             ( Rate ),                  
          .RATEDONE         ( TXRATEDONE[i] ),         
          .GT_PHYSTATUS     ( GTX_PhyStatus[i] ),      
          .RESETDONE        ( TXRESETDONE_q[i] & GTX_RxResetDone_q[i] )  
        );
        GTXE1 # (
          .TX_DRIVE_MODE("PIPE"),
          .TX_DEEMPH_1(5'b10010),
          .TX_MARGIN_FULL_0(7'b100_1101),
          .TX_CLK_SOURCE("RXPLL"),
          .POWER_SAVE(10'b0000110100),
          .CM_TRIM ( 2'b01 ),
          .PMA_CDR_SCAN ( 27'h640404C ),
          .PMA_CFG( 76'h0040000040000000003 ),
          .RCV_TERM_GND ("TRUE"),
          .RCV_TERM_VTTRX ("FALSE"),
          .RX_DLYALIGN_EDGESET(5'b00010),
          .RX_DLYALIGN_LPFINC(4'b0110),
          .RX_DLYALIGN_OVRDSETTING(8'b10000000),
          .TERMINATION_CTRL(5'b00000),
          .TERMINATION_OVRD("FALSE"),
          .TX_DLYALIGN_LPFINC(4'b0110),
          .TX_DLYALIGN_OVRDSETTING(8'b10000000),
          .TXPLL_CP_CFG( TXPLL_CP_CFG ),
          .OOBDETECT_THRESHOLD( 3'b011 ),
          .RXPLL_CP_CFG ( RXPLL_CP_CFG ),
          .TX_TDCC_CFG ( 2'b11 ),
          .BIAS_CFG ( 17'h00000 ),
          .AC_CAP_DIS ( "FALSE" ),
          .DFE_CFG ( 8'b00011011 ),
          .SIM_TX_ELEC_IDLE_LEVEL("1"),
          .SIM_RECEIVER_DETECT_PASS("TRUE"),
          .RX_EN_REALIGN_RESET_BUF("FALSE"),
          .TX_IDLE_ASSERT_DELAY(3'b100),          
          .TX_IDLE_DEASSERT_DELAY(3'b010),        
          .CHAN_BOND_SEQ_2_CFG(5'b11111),         
          .CHAN_BOND_KEEP_ALIGN("TRUE"),
          .RX_IDLE_HI_CNT(4'b1000),
          .RX_IDLE_LO_CNT(4'b0000),
          .RX_EN_IDLE_RESET_BUF("TRUE"),
          .TX_DATA_WIDTH(20),
          .RX_DATA_WIDTH(20),
          .ALIGN_COMMA_WORD(1),
          .CHAN_BOND_1_MAX_SKEW(7),
          .CHAN_BOND_2_MAX_SKEW(1),
          .CHAN_BOND_SEQ_1_1(10'b0001000101),     
          .CHAN_BOND_SEQ_1_2(10'b0001000101),     
          .CHAN_BOND_SEQ_1_3(10'b0001000101),     
          .CHAN_BOND_SEQ_1_4(10'b0110111100),     
          .CHAN_BOND_SEQ_1_ENABLE(4'b1111),       
          .CHAN_BOND_SEQ_2_1(10'b0100111100),     
          .CHAN_BOND_SEQ_2_2(10'b0100111100),     
          .CHAN_BOND_SEQ_2_3(10'b0110111100),     
          .CHAN_BOND_SEQ_2_4(10'b0100111100),     
          .CHAN_BOND_SEQ_2_ENABLE(4'b1111),       
          .CHAN_BOND_SEQ_2_USE("TRUE"),
          .CHAN_BOND_SEQ_LEN(4),                  
          .RX_CLK25_DIVIDER(RX_CLK25_DIVIDER),
          .TX_CLK25_DIVIDER(TX_CLK25_DIVIDER),
          .CLK_COR_ADJ_LEN(1),                    
          .CLK_COR_DET_LEN(1),                    
          .CLK_COR_INSERT_IDLE_FLAG("FALSE"),
          .CLK_COR_KEEP_IDLE("FALSE"),
          .CLK_COR_MAX_LAT(30),
          .CLK_COR_MIN_LAT(28),
          .CLK_COR_PRECEDENCE("TRUE"),
          .CLK_CORRECT_USE("TRUE"),
          .CLK_COR_REPEAT_WAIT(0),
          .CLK_COR_SEQ_1_1(10'b0100011100),      
          .CLK_COR_SEQ_1_2(10'b0000000000),
          .CLK_COR_SEQ_1_3(10'b0000000000),
          .CLK_COR_SEQ_1_4(10'b0000000000),
          .CLK_COR_SEQ_1_ENABLE(4'b1111),
          .CLK_COR_SEQ_2_1(10'b0000000000),
          .CLK_COR_SEQ_2_2(10'b0000000000),
          .CLK_COR_SEQ_2_3(10'b0000000000),
          .CLK_COR_SEQ_2_4(10'b0000000000),
          .CLK_COR_SEQ_2_ENABLE(4'b1111),
          .CLK_COR_SEQ_2_USE("FALSE"),
          .COMMA_10B_ENABLE(10'b1111111111),
          .COMMA_DOUBLE("FALSE"),
          .DEC_MCOMMA_DETECT("TRUE"),
          .DEC_PCOMMA_DETECT("TRUE"),
          .DEC_VALID_COMMA_ONLY("TRUE"),
          .MCOMMA_10B_VALUE(10'b1010000011),
          .MCOMMA_DETECT("TRUE"),
          .PCI_EXPRESS_MODE("TRUE"),
          .PCOMMA_10B_VALUE(10'b0101111100),
          .PCOMMA_DETECT("TRUE"),
          .RXPLL_DIVSEL_FB(GTX_PLL_DIVSEL_FB),     
          .TXPLL_DIVSEL_FB(GTX_PLL_DIVSEL_FB),     
          .RXPLL_DIVSEL_REF(1),                    
          .TXPLL_DIVSEL_REF(1),                    
          .RXPLL_DIVSEL_OUT(2),                    
          .TXPLL_DIVSEL_OUT(2),                    
          .RXPLL_DIVSEL45_FB(5),
          .TXPLL_DIVSEL45_FB(5),
          .RX_BUFFER_USE("TRUE"),
          .RX_DECODE_SEQ_MATCH("TRUE"),
          .RX_LOS_INVALID_INCR(8),                 
          .RX_LOSS_OF_SYNC_FSM("FALSE"),
          .RX_LOS_THRESHOLD(128),                  
          .RX_SLIDE_MODE("OFF"),                  
          .RX_XCLK_SEL ("RXREC"),
          .TX_BUFFER_USE("FALSE"),                 
          .TX_XCLK_SEL ("TXUSR"),                  
          .TXPLL_LKDET_CFG (3'b101),
          .RX_EYE_SCANMODE (2'b00),
          .RX_EYE_OFFSET (8'h4C),
          .PMA_RX_CFG ( 25'h05ce008 ),
          .TRANS_TIME_NON_P2(8'h2),               
          .TRANS_TIME_FROM_P2(12'h03c),            
          .TRANS_TIME_TO_P2(10'h064),              
          .TRANS_TIME_RATE(8'hD7),                 
          .SHOW_REALIGN_COMMA("FALSE"),
          .TX_PMADATA_OPT(1'b1),                   
          .PMA_TX_CFG( 20'h80082  ),                
          .TXOUTCLK_CTRL("TXPLLREFCLK_DIV1")
        )
        GTX (
          .COMFINISH            (),
          .COMINITDET           (),
          .COMSASDET            (),
          .COMWAKEDET           (),
          .DADDR                (daddr[(8*i)+7:(8*i)]),
          .DCLK                 (DRPCLK),
          .DEN                  (den[i]),
          .DFECLKDLYADJ         ( 6'h0 ),
          .DFECLKDLYADJMON      (),
          .DFEDLYOVRD           ( 1'b0 ),
          .DFEEYEDACMON         (),
          .DFESENSCAL           (),
          .DFETAP1              (0),
          .DFETAP1MONITOR       (),
          .DFETAP2              (5'h0),
          .DFETAP2MONITOR       (),
          .DFETAP3              (4'h0),
          .DFETAP3MONITOR       (),
          .DFETAP4              (4'h0),
          .DFETAP4MONITOR       (),
          .DFETAPOVRD           ( 1'b1 ),
          .DI                   (din[(16*i)+15:(16*i)]),
          .DRDY                 (drdy[i]),
          .DRPDO                (dout[(16*i)+15:(16*i)]),
          .DWE                  (dwe[i]),
          .GATERXELECIDLE       ( 1'b0 ),
          .GREFCLKRX            (0),
          .GREFCLKTX            (0),
          .GTXRXRESET           ( ~GTReset_n ),
          .GTXTEST              ( {11'b10000000000,OUT_DIV_RESET[i],1'b0} ),
          .GTXTXRESET           ( ~GTReset_n ),
          .LOOPBACK             ( 3'b000 ),
          .MGTREFCLKFAB         (),
          .MGTREFCLKRX          ( {1'b0,REFCLK} ),
          .MGTREFCLKTX          ( {1'b0,REFCLK} ),
          .NORTHREFCLKRX        (0),
          .NORTHREFCLKTX        (0),
          .PHYSTATUS            ( GTX_PhyStatus[i] ),
          .PLLRXRESET           ( 1'b0 ),
          .PLLTXRESET           ( 1'b0 ),
          .PRBSCNTRESET         ( 1'b0 ),
          .RXBUFRESET           ( 1'b0 ),
          .RXBUFSTATUS          (),
          .RXBYTEISALIGNED      (),
          .RXBYTEREALIGN        (),
          .RXCDRRESET           ( 1'b0 ),
          .RXCHANBONDSEQ        (),
          .RXCHANISALIGNED      ( ChanIsAligned[i] ),
          .RXCHANREALIGN        (),
          .RXCHARISCOMMA        (),
          .RXCHARISK            ( {RxDataK_dummy[1:0], GTX_RxDataK[(2*i)+1:2*i]} ),
          .RXCHBONDI            ( RXCHBOND[i] ),
          .RXCHBONDLEVEL        ( GTX_RxChbondLevel[(3*i)+2:(3*i)] ),
          .RXCHBONDMASTER       ( (i == 0) ),
          .RXCHBONDO            ( RXCHBOND[i+1] ),
          .RXCHBONDSLAVE        ( (i > 0) ),
          .RXCLKCORCNT          (),
          .RXCOMMADET           (),
          .RXCOMMADETUSE        ( 1'b1 ),
          .RXDATA               ( {RxData_dummy[15:0],GTX_RxData[(16*i)+15:(16*i)+0]} ),
          .RXDATAVALID          (),
          .RXDEC8B10BUSE        ( RXDEC8B10BUSE ),
          .RXDISPERR            (),
          .RXDLYALIGNDISABLE    ( 1'b1),
          .RXELECIDLE           ( GTX_RxElecIdle[i] ),
          .RXENCHANSYNC         ( 1'b1 ),
          .RXENMCOMMAALIGN      ( 1'b1 ),
          .RXENPCOMMAALIGN      ( 1'b1 ),
          .RXENPMAPHASEALIGN    ( 1'b0 ),
          .RXENPRBSTST          ( 3'b0 ),
          .RXENSAMPLEALIGN      ( 1'b0 ),
          .RXDLYALIGNMONENB     ( 1'b1 ),
          .RXEQMIX              ( 10'b0110000011 ),
          .RXGEARBOXSLIP        ( 1'b0 ),
          .RXHEADER             (),
          .RXHEADERVALID        (),
          .RXLOSSOFSYNC         (),
          .RXN                  ( GTX_RXN[i] ),
          .RXNOTINTABLE         (),
          .RXOVERSAMPLEERR      (),
          .RXP                  ( GTX_RXP[i] ),
          .RXPLLLKDET           ( RxPLLLkDet[i] ),
          .RXPLLLKDETEN         ( 1'b1 ),
          .RXPLLPOWERDOWN       ( 1'b0 ),
          .RXPLLREFSELDY        ( 3'b000 ),
          .RXPMASETPHASE        ( 1'b0 ),
          .RXPOLARITY           ( GTX_RxPolarity[i] ),
          .RXPOWERDOWN          ( PowerDown[(2*i)+1:(2*i)] ),
          .RXPRBSERR            (),
          .RXRATE               ( {1'b1, Rate} ),
          .RXRATEDONE           ( ),
          .RXRECCLK             ( RXRECCLK ),
          .RXRECCLKPCS          ( ),
          .RXRESET              ( ~GTReset_n | local_pcs_reset | PCS_RESET[i] ),
          .RXRESETDONE          ( GTX_RxResetDone[i] ),
          .RXRUNDISP            (),
          .RXSLIDE              ( 1'b0 ),
          .RXSTARTOFSEQ         (),
          .RXSTATUS             ( GTX_RxStatus[(3*i)+2:(3*i)] ),
          .RXUSRCLK             ( PCLK ),
          .RXUSRCLK2            ( PCLK ),
          .RXVALID              (GTX_RxValid[i]),
          .SOUTHREFCLKRX        (0),
          .SOUTHREFCLKTX        (0),
          .TSTCLK0              ( 1'b0 ),
          .TSTCLK1              ( 1'b0 ),
          .TSTIN                ( {20{1'b1}} ),
          .TSTOUT               (),
          .TXBUFDIFFCTRL        ( 3'b111 ),
          .TXBUFSTATUS          (),
          .TXBYPASS8B10B        ( TXBYPASS8B10B[3:0] ),
          .TXCHARDISPMODE       ( {3'b000, GTX_TxCompliance[i]} ),
          .TXCHARDISPVAL        ( 4'b0000 ),
          .TXCHARISK            ( {TxDataK_dummy[1:0], GTX_TxDataK[(2*i)+1:2*i]} ),
          .TXCOMINIT            ( 1'b0 ),
          .TXCOMSAS             ( 1'b0 ),
          .TXCOMWAKE            ( 1'b0 ),
          .TXDATA               ( {TxData_dummy[15:0], GTX_TxData[(16*i)+15:(16*i)+0]} ),
          .TXDEEMPH             ( TxDeemph ),
          .TXDETECTRX           ( TxDetectRx ),
          .TXDIFFCTRL           ( 4'b1111 ),
          .TXDLYALIGNDISABLE    ( TXDLYALIGNDISABLE[i] ),
          .TXDLYALIGNRESET      ( TXDLYALIGNRESET[i] ),
          .TXELECIDLE           ( GTX_TxElecIdle[i] ),
          .TXENC8B10BUSE        ( 1'b1 ),
          .TXENPMAPHASEALIGN    ( TXENPMAPHASEALIGN[i] ),
          .TXENPRBSTST          (),
          .TXGEARBOXREADY       (),
          .TXHEADER             (0),
          .TXINHIBIT            ( 1'b0 ),
          .TXKERR               (),
          .TXMARGIN             ( {TxMargin, 2'b00} ),
          .TXN                  ( GTX_TXN[i] ),
          .TXOUTCLK             ( TXOCLK[i] ),
          .TXOUTCLKPCS          (),
          .TXP                  ( GTX_TXP[i] ),
          .TXPDOWNASYNCH        ( TXPdownAsynch ),
          .TXPLLLKDET           ( ),
          .TXPLLLKDETEN         ( 1'b0 ),
          .TXPLLPOWERDOWN       ( 1'b0 ),
          .TXPLLREFSELDY        ( 3'b000 ),
          .TXPMASETPHASE        ( TXPMASETPHASE[i] ),
          .TXPOLARITY           ( 1'b0 ),
          .TXPOSTEMPHASIS       (0),
          .TXPOWERDOWN          ( PowerDown[(2*i)+1:(2*i)] ),
          .TXPRBSFORCEERR       (0),
          .TXPREEMPHASIS        (0),
          .TXRATE               ( {1'b1, Rate} ),
          .TXRESET              ( ~GTReset_n | local_pcs_reset  | PCS_RESET[i] ),
          .TXRESETDONE          ( TXRESETDONE[i] ),
          .TXRUNDISP            (),
          .TXSEQUENCE           (0),
          .TXSTARTSEQ           (0),
          .TXSWING              ( TxSwing ),
          .TXUSRCLK             ( PCLK ),
          .TXUSRCLK2            ( PCLK ),
          .USRCODEERR           (0),
          .IGNORESIGDET         (0),
          .PERFCLKRX            (0),
          .PERFCLKTX            (0),
          .RXDLYALIGNMONITOR    (),
          .RXDLYALIGNOVERRIDE   ( 1'b0 ),
          .RXDLYALIGNRESET      (0),
          .RXDLYALIGNSWPPRECURB ( 1'b1 ),
          .RXDLYALIGNUPDSW      ( 1'b0 ),
          .TXDLYALIGNMONITOR    (),
          .TXDLYALIGNOVERRIDE   ( 1'b0 ),
          .TXDLYALIGNUPDSW      ( 1'b0 ),
          .TXDLYALIGNMONENB     ( 1'b1 ),
          .TXRATEDONE           ( TXRATEDONE[i] )
        );
      end
    end
    endgenerate
endmodule
