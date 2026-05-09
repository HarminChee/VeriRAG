// 1_corrected_clk.v
module rxtx(
   input   wire            A2D_CLKn,
   input   wire            A2D_CLKp,
   input   wire            ADC_SYNC_INn,
   input   wire            ADC_SYNC_INp,
   input   wire            CH1_A2D_CLKn,
   input   wire            CH1_A2D_CLKp,
   input   wire    [6:0]   CH1_A2D_DATAn,
   input   wire    [6:0]   CH1_A2D_DATAp,
   input   wire            CH1_HV_OF,
   input   wire            CH1_LV_OF,
   input   wire            CH2_A2D_CLKn,
   input   wire            CH2_A2D_CLKp,
   input   wire    [6:0]   CH2_A2D_DATAn,
   input   wire    [6:0]   CH2_A2D_DATAp,
   input   wire            CH2_HV_OF,
   input   wire            CH2_LV_OF,
   input   wire            DAC_GDATACLKn,
   input   wire            DAC_GDATACLKp,
   input   wire            DAC_SYNC_INn,
   input   wire            DAC_SYNC_INp,
   input   wire            EXT_CLK_SDI,
   input   wire            EXT_CLK_STATUS,
   input   wire            LVCLK_200n,
   input   wire            LVCLK_200p,
   input   wire            MGT_REFCLK_n,
   input   wire            MGT_REFCLK_p,
   input   wire            PCIE_REFCLK_n,
   input   wire            PCIE_REFCLK_p,
   input   wire            PCIE_RESETn,
   input   wire            TEMP_ALERTn,
   input   wire            TEMP_THERMn,
   // DFT Ports
   input   wire            test_clk,
   input   wire            test_mode,
   output  wire            ADC_SYNC_DISABLEn,
   output  wire            ADC_SYNC_DISABLEp,
   output  wire            ADC_SYNC_OUTn,
   output  wire            ADC_SYNC_OUTp,
   output  wire            CH1_A2D_OE,
   output  wire            CH1_A2D_RESET,
   output  wire            CH1_A2D_SCLK,
   output  wire            CH1_A2D_SDATA,
   output  wire            CH1_A2D_SEN,
   output  wire            CH2_A2D_OE,
   output  wire            CH2_A2D_RESET,
   output  wire            CH2_A2D_SCLK,
   output  wire            CH2_A2D_SDATA,
   output  wire            CH2_A2D_SEN,
   output  wire            CPLD_CSn,
   output  wire            CPLD_RSTn,
   output  wire            DAC_CAL,
   output  wire            DAC_CLKDIV,
   output  wire    [11:0]  DAC_DAn,
   output  wire    [11:0]  DAC_DAp,
   output  wire    [11:0]  DAC_DBn,
   output  wire    [11:0]  DAC_DBp,
   output  wire    [11:0]  DAC_DCn,
   output  wire    [11:0]  DAC_DCp,
   output  wire    [11:0]  DAC_DDn,
   output  wire    [11:0]  DAC_DDp,
   output  wire            DAC_DELAY,
   output  wire            DAC_RF,
   output  wire            DAC_RZ,
   output  wire            DAC_SYNC_DISABLEn,
   output  wire            DAC_SYNC_DISABLEp,
   output  wire            DAC_SYNC_OUTn,
   output  wire            DAC_SYNC_OUTp,
   output  wire            EXT_CLK_CSn,
   output  wire            EXT_CLK_FUNC,
   output  wire            EXT_CLK_SCLK,
   output  wire            EXT_CLK_SDO,
   output  wire            I2C_BUS_SELECT,
   inout   wire            I2C_SCLK,
   inout   wire            I2C_SDATA
);
supply0           GND;
wire              RX_FIFO_ALMOST_EMPTY;
wire              RX_FIFO_EMPTY;
wire              TX_FIFO_ALMOST_FULL;
wire              TX_FIFO_FULL;
wire              a2dCh1FifoAlmostEmpty;
wire     [15:0]   a2dCh1FifoDataOut;
wire              a2dCh1LcbAck;
wire     [31:0]   a2dCh1LcbData;
wire              a2dCh2FifoAlmostEmpty;
wire     [15:0]   a2dCh2FifoDataOut;
wire              a2dCh2LcbAck;
wire     [31:0]   a2dCh2LcbData;
wire     [1:0]    a2dChLcbRead;
wire     [1:0]    a2dChLcbSelect;
wire     [1:0]    a2dChLcbWrite;
wire              a2dClk;
wire              a2dDcmReset;
wire     [3:0]    a2dFifoRdEn;
wire     [3:0]    a2dFifoSyncWrEn;
wire              a2dFifoWrEnable;
wire              a2d_clk_locked;
wire              a2d_clk_reset;
wire     [31:0]   absTs1pps;
wire     [31:0]   absTsSample;
wire              adcISync;
wire              adcLsSyncCtrlLcbAck;
wire     [31:0]   adcLsSyncCtrlLcbData;
wire              adcSyncDisable;
wire              adcSyncIn;
wire              adcSyncOut;
wire     [127:0]  c2sFifoDin;
wire              c2sFifoWrite;
wire     [7 : 0]  cfg_bus_number;
wire     [3 : 0]  cfg_byte_en_n;
wire     [15 : 0] cfg_command;
wire     [15 : 0] cfg_dcommand;
wire     [4 : 0]  cfg_device_number;
wire     [31 : 0] cfg_di;
wire     [31 : 0] cfg_do;
wire     [63:0]   cfg_dsn_n;
wire     [15 : 0] cfg_dstatus;
wire     [9 : 0]  cfg_dwaddr;
wire              cfg_err_cor_n;
wire              cfg_err_cpl_abort_n;
wire              cfg_err_cpl_rdy_n;
wire              cfg_err_cpl_timeout_n;
wire              cfg_err_cpl_unexpect_n;
wire              cfg_err_ecrc_n;
wire              cfg_err_posted_n;
wire     [47 : 0] cfg_err_tlp_cpl_header;
wire              cfg_err_ur_n;
wire     [2 : 0]  cfg_function_number;
wire              cfg_interrupt_assert_n;
wire     [7 : 0]  cfg_interrupt_di;
wire     [7 : 0]  cfg_interrupt_do;
wire     [2 : 0]  cfg_interrupt_mmenable;
wire              cfg_interrupt_msienable;
wire              cfg_interrupt_n;
wire              cfg_interrupt_rdy_n;
wire     [15 : 0] cfg_lcommand;
wire     [15 : 0] cfg_lstatus;
wire     [2 : 0]  cfg_pcie_link_state_n;
wire              cfg_pm_wake_n;
wire              cfg_rd_en_n;
wire              cfg_rd_wr_done_n;
wire     [15 : 0] cfg_status;
wire              cfg_to_turnoff_n;
wire              cfg_trn_pending_n;
wire              cfg_wr_en_n;
wire              clk150Mhz;
wire              clk200Mhz;
wire              clk390KHz;
wire              dacClk;
wire              dacClkLowFreqSelect;
wire              dacDcmReset;
wire              dacISync;
wire              dacLcbAck;
wire     [31:0]   dacLcbData;
wire              dacLcbRead;
wire              dacLcbSelect;
wire              dacLcbWrite;
wire              dacLsSyncCtrlLcbAck;
wire     [31:0]   dacLsSyncCtrlLcbData;
wire              dacSyncDisable;
wire              dacSyncIn;
wire              dacSyncOut;
wire              dacTrigIn;
wire     [5:0]    dacTxFifoAFullThresh;
wire              dacTxFifoAlmostFull;
wire     [255:0]  dacTxFifoData;
wire              dacTxFifoFull;
wire              dacTxFifoWrite;
wire              dac_clk_div2;
wire              dac_clk_locked;
wire              dac_reset;
wire              fast_train_simulation_only;
wire              lcbAckOr;
wire              lcbClk;
wire              lcb_clk_locked;
wire              lcb_reset;
wire              lcb_resetn;
wire     [1:0]    lsSyncCtrlLcbRead;
wire     [1:0]    lsSyncCtrlLcbSelect;
wire     [1:0]    lsSyncCtrlLcbWrite;
wire              lsiAck;
wire     [31:0]   lsiAddress;
wire              lsiCs;
wire     [31:0]   lsiDataIn;
wire     [31:0]   lsiDataOut;
wire              lsiRead;
wire              lsiWrite;
wire              mgtRefClk;
wire     [127:0]  packetDataCh0;
wire     [127:0]  packetDataCh1;
wire     [127:0]  packetDataCh2;
wire     [127:0]  packetDataCh3;
wire     [3:0]    packetWriteEnable;
wire     [7:0]    pcieC2sBusGrant;
wire     [7:0]    pcieC2sBusRequest;
wire              pcieC2sFifoAlmostFull;
wire              pcieC2sFifoFull;
wire     [7:0]    pcieC2sWriteEnable;
wire              pcieLcbAck;
wire     [31:0]   pcieLcbData;
wire              pcieLcbRead;
wire              pcieLcbSelect;
wire              pcieLcbWrite;
wire              pcie_ref_clk;
wire     [3:0]    pgBusRequest;
wire              pgLcbAck;
wire     [31:0]   pgLcbData;
wire              pgLcbRead;
wire              pgLcbSelect;
wire              pgLcbWrite;
wire              pll_reset;
wire              rcvrCh1LcbAck;
wire     [31:0]   rcvrCh1LcbData;
wire              rcvrCh2LcbAck;
wire     [31:0]   rcvrCh2LcbData;
wire     [1:0]    rcvrChLcbRead;
wire     [1:0]    rcvrChLcbSelect;
wire     [1:0]    rcvrChLcbWrite;
wire              ref_clk_out;
wire     [31:0]   relTs;
wire              reset;
wire              resetn;
wire              smBusLcbAck;
wire     [31:0]   smBusLcbData;
wire              smBusLcbRead;
wire              smBusLcbSelect;
wire              smBusLcbWrite;
wire              spiLcbAck;
wire     [31:0]   spiLcbData;
wire              spiLcbRead;
wire              spiLcbSelect;
wire              spiLcbWrite;
wire     [15:0]   testCount;
wire     [15:0]   testSignal;
wire              testStimulusLcbAck;
wire     [31:0]   testStimulusLcbData;
wire              testStimulusLcbRead;
wire              testStimulusLcbSelect;
wire              testStimulusLcbWrite;
wire              timeStampLcbAck;
wire     [31:0]   timeStampLcbData;
wire              timeStampLcbRead;
wire              timeStampLcbSelect;
wire              timeStampLcbWrite;
wire              trn_lnk_up_n;
wire     [6 : 0]  trn_rbar_hit_n;
wire              trn_rcpl_streaming_n;
wire     [63 : 0] trn_rd;
wire              trn_rdst_rdy_n;
wire              trn_reof_n;
wire              trn_rerrfwd_n;
wire              trn_reset_n;
wire              trn_rnp_ok_n;
wire     [7 : 0]  trn_rrem_n;
wire              trn_rsof_n;
wire              trn_rsrc_dsc_n;
wire              trn_rsrc_rdy_n;
wire     [3 : 0]  trn_tbuf_av;
wire     [63 : 0] trn_td;
wire              trn_tdst_dsc_n;
wire              trn_tdst_rdy_n;
wire              trn_teof_n;
wire              trn_terrfwd_n;
wire     [7 : 0]  trn_trem_n;
wire              trn_tsof_n;
wire              trn_tsrc_dsc_n;
wire              trn_tsrc_rdy_n;
wire              user_clk;
wire              user_clk_div2;
wire              user_clk_locked;
wire              user_rst_div2_n;
wire              user_rst_n;
wire     [31:0]   waveGenData;
wire              waveGenEnable;
wire              waveGenLcbAck;
wire     [10:0]   waveGenLoopAddress;
wire              waveGenRead;
wire              waveGenSelect;
wire              waveGenTrigOut;
wire              waveGenTrigPulseOut;
wire              waveGenTrigger;
wire              waveGenWrite;
wire     [7:0]    wbCh0BusGrant;
wire     [7:0]    wbCh0BusRequest;
wire              wbCh0CollFifoAlmostEmpty;
wire     [127:0]  wbCh0CollFifoDataOut;
wire              wbCh0CollFifoEmpty;
wire              wbCh0CollFifoReadEnable;
wire     [7:0]    wbCh0DestFifoAlmostFull;
wire     [7:0]    wbCh0DestFifoFull;
wire     [7:0]    wbCh0DestWrite;
wire              wbCh0DropFrameRouteCode;
wire     [31:0]   wbCh0FrameSizeBytesRouter;
wire     [3:0]    wbCh0RouteCode;
wire     [127:0]  wbCh0RouteDataOut;
wire     [7:0]    wbCh1BusGrant;
wire     [7:0]    wbCh1BusRequest;
wire              wbCh1CollFifoAlmostEmpty;
wire     [127:0]  wbCh1CollFifoDataOut;
wire              wbCh1CollFifoEmpty;
wire              wbCh1CollFifoReadEnable;
wire     [7:0]    wbCh1DestFifoAlmostFull;
wire     [7:0]    wbCh1DestFifoFull;
wire     [7:0]    wbCh1DestWrite;
wire              wbCh1DropFrameRouteCode;
wire     [31:0]   wbCh1FrameSizeBytesRouter;
wire     [3:0]    wbCh1RouteCode;
wire     [127:0]  wbCh1RouteDataOut;

// DFT Clock Muxing
wire              a2dClk_muxed;
wire              clk150Mhz_muxed;
wire              clk200Mhz_muxed;
wire              clk390KHz_muxed;
wire              dacClk_muxed;
wire              lcbClk_muxed;
wire              user_clk_muxed;
wire              user_clk_div2_muxed;

assign a2dClk_muxed        = test_mode ? test_clk : a2dClk;
assign clk150Mhz_muxed     = test_mode ? test_clk : clk150Mhz;
assign clk200Mhz_muxed     = test_mode ? test_clk : clk200Mhz;
assign clk390KHz_muxed     = test_mode ? test_clk : clk390KHz;
assign dacClk_muxed        = test_mode ? test_clk : dacClk;
assign lcbClk_muxed        = test_mode ? test_clk : lcbClk;
assign user_clk_muxed      = test_mode ? test_clk : user_clk;
assign user_clk_div2_muxed = test_mode ? test_clk : user_clk_div2;

// Instance clocks updated to use muxed versions
epg128BitFrameRouter ch1_rcvr_fr(
   .clk                (clk200Mhz_muxed), // Muxed clock
   .inFifoAlmostEmpty  (wbCh0CollFifoAlmostEmpty),
   .inFifoEmpty        (wbCh0CollFifoEmpty),
   .frameDataIn        (wbCh0CollFifoDataOut),
   .frameSizeBytes     (wbCh0FrameSizeBytesRouter),
   .resetn             (resetn),
   .destBusGrant       (wbCh0BusGrant),
   .destFifoAlmostFull (wbCh0DestFifoAlmostFull),
   .destFifoFull       (wbCh0DestFifoFull),
   .routeCode          (wbCh0RouteCode[2:0]),
   .dropFrameRouteCode (wbCh0DropFrameRouteCode),
   .frameDataRead      (wbCh0CollFifoReadEnable),
   .routeDataOut       (wbCh0RouteDataOut),
   .destWrite          (wbCh0DestWrite),
   .destBusReq         (wbCh0BusRequest),
   .frameInt           ()
);
epg128BitFrameRouter ch2_rcvr_fr(
   .clk                (clk200Mhz_muxed), // Muxed clock
   .inFifoAlmostEmpty  (wbCh1CollFifoAlmostEmpty),
   .inFifoEmpty        (wbCh1CollFifoEmpty),
   .frameDataIn        (wbCh1CollFifoDataOut),
   .frameSizeBytes     (wbCh1FrameSizeBytesRouter),
   .resetn             (resetn),
   .destBusGrant       (wbCh1BusGrant),
   .destFifoAlmostFull (wbCh1DestFifoAlmostFull),
   .destFifoFull       (wbCh1DestFifoFull),
   .routeCode          (wbCh1RouteCode[2:0]),
   .dropFrameRouteCode (wbCh1DropFrameRouteCode),
   .frameDataRead      (wbCh1CollFifoReadEnable),
   .routeDataOut       (wbCh1RouteDataOut),
   .destWrite          (wbCh1DestWrite),
   .destBusReq         (wbCh1BusRequest),
   .frameInt           ()
);
epg_a2d_ads6149_interface a2dInfCh1(
   .a2dClkn            (CH1_A2D_CLKn),
   .a2dClkp            (CH1_A2D_CLKp),
   .a2dDatan           (CH1_A2D_DATAn),
   .a2dDatap           (CH1_A2D_DATAp),
   .a2dFifoSyncWrEn    (a2dFifoSyncWrEn[0:0]),
   .a2dOvrRngSpiDataIn (CH1_LV_OF),
   .a2dRdClk           (a2dClk_muxed), // Muxed clock
   .a2dRdEn            (a2dFifoRdEn[0:0]),
   .idelayRefClk       (clk200Mhz_muxed), // Muxed clock
   .lcbAddress         (lsiAddress[8:0]),
   .lcbClk             (lcbClk_muxed), // Muxed clock
   .lcbCoreSelect      (a2dChLcbSelect[0:0]),
   .lcbDataIn          (lsiDataOut),
   .lcbRead            (a2dChLcbRead[0:0]),
   .lcbWrite           (a2dChLcbWrite[0:0]),
   .resetn             (resetn),
   .serdesClk          (lcbClk_muxed), // Muxed clock
   .a2dFifoAlmostEmpty (a2dCh1FifoAlmostEmpty),
   .a2dFifoAlmostFull  (),
   .a2dFifoDataOut     (a2dCh1FifoDataOut),
   .a2dFifoEmpty       (),
   .a2dFifoFull        (),
   .a2dOE              (CH1_A2D_OE),
   .a2dReset           (CH1_A2D_RESET),
   .lcbAck             (a2dCh1LcbAck),
   .lcbDataOut         (a2dCh1LcbData),
   .spiChipSelectn     (CH1_A2D_SEN),
   .spiClk             (CH1_A2D_SCLK),
   .spiDataOut         (CH1_A2D_SDATA),
   .spiWriteEnable     ()
);
epg_a2d_ads6149_interface a2dInfCh2(
   .a2dClkn            (CH2_A2D_CLKn),
   .a2dClkp            (CH2_A2D_CLKp),
   .a2dDatan           (CH2_A2D_DATAn),
   .a2dDatap           (CH2_A2D_DATAp),
   .a2dFifoSyncWrEn    (a2dFifoSyncWrEn[1:1]),
   .a2dOvrRngSpiDataIn (CH2_LV_OF),
   .a2dRdClk           (a2dClk_muxed), // Muxed clock
   .a2dRdEn            (a2dFifoRdEn[1:1]),
   .idelayRefClk       (clk200Mhz_muxed), // Muxed clock
   .lcbAddress         (lsiAddress[8:0]),
   .lcbClk             (lcbClk_muxed), // Muxed clock
   .lcbCoreSelect      (a2dChLcbSelect[1:1]),
   .lcbDataIn          (lsiDataOut),
   .lcbRead            (a2dChLcbRead[1:1]),
   .lcbWrite           (a2dChLcbWrite[1:1]),
   .resetn             (resetn),
   .serdesClk          (lcbClk_muxed), // Muxed clock
   .a2dFifoAlmostEmpty (a2dCh2FifoAlmostEmpty),
   .a2dFifoAlmostFull  (),
   .a2dFifoDataOut     (a2dCh2FifoDataOut),
   .a2dFifoEmpty       (),
   .a2dFifoFull        (),
   .a2dOE              (CH2_A2D_OE),
   .a2dReset           (CH2_A2D_RESET),
   .lcbAck             (a2dCh2LcbAck),
   .lcbDataOut         (a2dCh2LcbData),
   .spiChipSelectn     (CH2_A2D_SEN),
   .spiClk             (CH2_A2D_SCLK),
   .spiDataOut         (CH2_A2D_SDATA),
   .spiWriteEnable     ()
);
epgA2DFifoCtrlInterface a2dFifoCtrl(
   .a2dFifoAE0      (a2dCh1FifoAlmostEmpty),
   .a2dFifoAE1      (a2dCh2FifoAlmostEmpty),
   .a2dFifoAE2      (GND),