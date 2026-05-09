`timescale 1ns/1ns
module PCIeGen2x8If128_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8,          
   parameter               REF_CLK_FREQ            = 0,          
   parameter               USER_CLK2_DIV2          = "FALSE",    
   parameter  integer      USER_CLK_FREQ           = 3,          
   parameter               PL_FAST_TRAIN           = "FALSE",    
   parameter               PCIE_EXT_CLK            = "FALSE",    
   parameter               PCIE_USE_MODE           = "1.0",      
   parameter               PCIE_GT_DEVICE          = "GTX",      
   parameter               PCIE_PLL_SEL            = "CPLL",     
   parameter               PCIE_ASYNC_EN           = "FALSE",    
   parameter               PCIE_TXBUF_EN           = "FALSE",    
   parameter               PCIE_EXT_GT_COMMON      = "FALSE", 
   parameter               EXT_CH_GT_DRP           = "FALSE",  
   parameter               TX_MARGIN_FULL_0        = 7'b1001111, 
   parameter               TX_MARGIN_FULL_1        = 7'b1001110, 
   parameter               TX_MARGIN_FULL_2        = 7'b1001101, 
   parameter               TX_MARGIN_FULL_3        = 7'b1001100, 
   parameter               TX_MARGIN_FULL_4        = 7'b1000011, 
   parameter               TX_MARGIN_LOW_0         = 7'b1000101, 
   parameter               TX_MARGIN_LOW_1         = 7'b1000110, 
   parameter               TX_MARGIN_LOW_2         = 7'b1000011, 
   parameter               TX_MARGIN_LOW_3         = 7'b1000010, 
   parameter               TX_MARGIN_LOW_4         = 7'b1000000,   
   parameter               PCIE_CHAN_BOND          = 0,
   parameter               TCQ                     = 1           
)
(
   input   wire [5:0]                pl_ltssm_state         ,
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   output  wire [ 1:0]               pipe_rx0_char_is_k     ,
   output  wire [15:0]               pipe_rx0_data          ,
   output  wire                      pipe_rx0_valid         ,
   output  wire                      pipe_rx0_chanisaligned ,
   output  wire [ 2:0]               pipe_rx0_status        ,
   output  wire                      pipe_rx0_phy_status    ,
   output  wire                      pipe_rx0_elec_idle     ,
   input   wire                      pipe_rx0_polarity      ,
   input   wire                      pipe_tx0_compliance    ,
   input   wire [ 1:0]               pipe_tx0_char_is_k     ,
   input   wire [15:0]               pipe_tx0_data          ,
   input   wire                      pipe_tx0_elec_idle     ,
   input   wire [ 1:0]               pipe_tx0_powerdown     ,
   output  wire [ 1:0]               pipe_rx1_char_is_k     ,
   output  wire [15:0]               pipe_rx1_data          ,
   output  wire                      pipe_rx1_valid         ,
   output  wire                      pipe_rx1_chanisaligned ,
   output  wire [ 2:0]               pipe_rx1_status        ,
   output  wire                      pipe_rx1_phy_status    ,
   output  wire                      pipe_rx1_elec_idle     ,
   input   wire                      pipe_rx1_polarity      ,
   input   wire                      pipe_tx1_compliance    ,
   input   wire [ 1:0]               pipe_tx1_char_is_k     ,
   input   wire [15:0]               pipe_tx1_data          ,
   input   wire                      pipe_tx1_elec_idle     ,
   input   wire [ 1:0]               pipe_tx1_powerdown     ,
   output  wire [ 1:0]               pipe_rx2_char_is_k     ,
   output  wire [15:0]               pipe_rx2_data          ,
   output  wire                      pipe_rx2_valid         ,
   output  wire                      pipe_rx2_chanisaligned ,
   output  wire [ 2:0]               pipe_rx2_status        ,
   output  wire                      pipe_rx2_phy_status    ,
   output  wire                      pipe_rx2_elec_idle     ,
   input   wire                      pipe_rx2_polarity      ,
   input   wire                      pipe_tx2_compliance    ,
   input   wire [ 1:0]               pipe_tx2_char_is_k     ,
   input   wire [15:0]               pipe_tx2_data          ,
   input   wire                      pipe_tx2_elec_idle     ,
   input   wire [ 1:0]               pipe_tx2_powerdown     ,
   output  wire [ 1:0]               pipe_rx3_char_is_k     ,
   output  wire [15:0]               pipe_rx3_data          ,
   output  wire                      pipe_rx3_valid         ,
   output  wire                      pipe_rx3_chanisaligned ,
   output  wire [ 2:0]               pipe_rx3_status        ,
   output  wire                      pipe_rx3_phy_status    ,
   output  wire                      pipe_rx3_elec_idle     ,
   input   wire                      pipe_rx3_polarity      ,
   input   wire                      pipe_tx3_compliance    ,
   input   wire [ 1:0]               pipe_tx3_char_is_k     ,
   input   wire [15:0]               pipe_tx3_data          ,
   input   wire                      pipe_tx3_elec_idle     ,
   input   wire [ 1:0]               pipe_tx3_powerdown     ,
   output  wire [ 1:0]               pipe_rx4_char_is_k     ,
   output  wire [15:0]               pipe_rx4_data          ,
   output  wire                      pipe_rx4_valid         ,
   output  wire                      pipe_rx4_chanisaligned ,
   output  wire [ 2:0]               pipe_rx4_status        ,
   output  wire                      pipe_rx4_phy_status    ,
   output  wire                      pipe_rx4_elec_idle     ,
   input   wire                      pipe_rx4_polarity      ,
   input   wire                      pipe_tx4_compliance    ,
   input   wire [ 1:0]               pipe_tx4_char_is_k     ,
   input   wire [15:0]               pipe_tx4_data          ,
   input   wire                      pipe_tx4_elec_idle     ,
   input   wire [ 1:0]               pipe_tx4_powerdown     ,
   output  wire [ 1:0]               pipe_rx5_char_is_k     ,
   output  wire [15:0]               pipe_rx5_data          ,
   output  wire                      pipe_rx5_valid         ,
   output  wire                      pipe_rx5_chanisaligned ,
   output  wire [ 2:0]               pipe_rx5_status        ,
   output  wire                      pipe_rx5_phy_status    ,
   output  wire                      pipe_rx5_elec_idle     ,
   input   wire                      pipe_rx5_polarity      ,
   input   wire                      pipe_tx5_compliance    ,
   input   wire [ 1:0]               pipe_tx5_char_is_k     ,
   input   wire [15:0]               pipe_tx5_data          ,
   input   wire                      pipe_tx5_elec_idle     ,
   input   wire [ 1:0]               pipe_tx5_powerdown     ,
   output  wire [ 1:0]               pipe_rx6_char_is_k     ,
   output  wire [15:0]               pipe_rx6_data          ,
   output  wire                      pipe_rx6_valid         ,
   output  wire                      pipe_rx6_chanisaligned ,
   output  wire [ 2:0]               pipe_rx6_status        ,
   output  wire                      pipe_rx6_phy_status    ,
   output  wire                      pipe_rx6_elec_idle     ,
   input   wire                      pipe_rx6_polarity      ,
   input   wire                      pipe_tx6_compliance    ,
   input   wire [ 1:0]               pipe_tx6_char_is_k     ,
   input   wire [15:0]               pipe_tx6_data          ,
   input   wire                      pipe_tx6_elec_idle     ,
   input   wire [ 1:0]               pipe_tx6_powerdown     ,
   output  wire [ 1:0]               pipe_rx7_char_is_k     ,
   output  wire [15:0]               pipe_rx7_data          ,
   output  wire                      pipe_rx7_valid         ,
   output  wire                      pipe_rx7_chanisaligned ,
   output  wire [ 2:0]               pipe_rx7_status        ,
   output  wire                      pipe_rx7_phy_status    ,
   output  wire                      pipe_rx7_elec_idle     ,
   input   wire                      pipe_rx7_polarity      ,
   input   wire                      pipe_tx7_compliance    ,
   input   wire [ 1:0]               pipe_tx7_char_is_k     ,
   input   wire [15:0]               pipe_tx7_data          ,
   input   wire                      pipe_tx7_elec_idle     ,
   input   wire [ 1:0]               pipe_tx7_powerdown     ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,
   input   wire                                  sys_clk                ,
   input   wire                                  sys_rst_n              ,
   input   wire                                  PIPE_MMCM_RST_N        ,
   output  wire                                  pipe_clk               ,
   output  wire                                  user_clk               ,
   output  wire                                  user_clk2              ,
  output                                        INT_PCLK_OUT_SLAVE,     
  output                                        INT_RXUSRCLK_OUT,       
  output  [(LINK_CAP_MAX_LINK_WIDTH-1):0]       INT_RXOUTCLK_OUT,       
  output                                        INT_DCLK_OUT,           
  output                                        INT_USERCLK1_OUT,       
  output                                        INT_USERCLK2_OUT,       
  output                                        INT_OOBCLK_OUT,         
  output                                        INT_MMCM_LOCK_OUT,      
  output  [1:0]                                 INT_QPLLLOCK_OUT,
  output  [1:0]                                 INT_QPLLOUTCLK_OUT,
  output  [1:0]                                 INT_QPLLOUTREFCLK_OUT,
  input   [(LINK_CAP_MAX_LINK_WIDTH-1):0]       INT_PCLK_SEL_SLAVE,
  input   [11:0]                                qpll_drp_crscode,
  input   [17:0]                                qpll_drp_fsm,
  input   [1:0]                                 qpll_drp_done,
  input   [1:0]                                 qpll_drp_reset,
  input   [1:0]                                 qpll_qplllock,
  input   [1:0]                                 qpll_qplloutclk,
  input   [1:0]                                 qpll_qplloutrefclk,
  output                                        qpll_qplld,
  output  [1:0]                                 qpll_qpllreset,
  output                                        qpll_drp_clk,
  output                                        qpll_drp_rst_n,
  output                                        qpll_drp_ovrd,
  output                                        qpll_drp_gen3,
  output                                        qpll_drp_start,
  input                                         PIPE_PCLK_IN,           
  input                                         PIPE_RXUSRCLK_IN,       
  input  [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_RXOUTCLK_IN,       
  input                                         PIPE_DCLK_IN,           
  input                                         PIPE_USERCLK1_IN,       
  input                                         PIPE_USERCLK2_IN,       
  input                                         PIPE_OOBCLK_IN,         
  input                                         PIPE_MMCM_LOCK_IN,      
  output                                        PIPE_TXOUTCLK_OUT,      
  output [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_RXOUTCLK_OUT,      
  output [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_PCLK_SEL_OUT,      
  output                                        PIPE_GEN3_OUT ,          
  output      [4:0]                             PIPE_RST_FSM,
  output      [11:0]                            PIPE_QRST_FSM,
  output      [(LINK_CAP_MAX_LINK_WIDTH*5)-1:0] PIPE_RATE_FSM,
  output      [(LINK_CAP_MAX_LINK_WIDTH*6)-1:0] PIPE_SYNC_FSM_TX,
  output      [(LINK_CAP_MAX_LINK_WIDTH*7)-1:0] PIPE_SYNC_FSM_RX,
  output      [(LINK_CAP_MAX_LINK_WIDTH*7)-1:0] PIPE_DRP_FSM,
  output                                        PIPE_RST_IDLE,
  output                                        PIPE_QRST_IDLE,
  output                                        PIPE_RATE_IDLE,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_EYESCANDATAERROR,
  output     [(LINK_CAP_MAX_LINK_WIDTH*3)-1:0]  PIPE_RXSTATUS,
  output     [(LINK_CAP_MAX_LINK_WIDTH*15)-1:0] PIPE_DMONITOROUT,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_CPLL_LOCK,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_QPLL_LOCK,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXPMARESETDONE,       
  output     [(LINK_CAP_MAX_LINK_WIDTH*3)-1:0]  PIPE_RXBUFSTATUS,         
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXPHALIGNDONE,       
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXPHINITDONE,        
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXDLYSRESETDONE,    
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXPHALIGNDONE,      
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXDLYSRESETDONE,     
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXSYNCDONE,       
  output     [(LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  PIPE_RXDISPERR,       
  output     [(LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  PIPE_RXNOTINTABLE,      
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXCOMMADET,        
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_0,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_1,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_2,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_3,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_4,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_5,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_6,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_7,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_8,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_9,
  output      [31:0]                            PIPE_DEBUG,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_JTAG_RDY,
  input       [ 2:0]                            PIPE_TXPRBSSEL,
  input       [ 2:0]                            PIPE_RXPRBSSEL,
  input                                         PIPE_TXPRBSFORCEERR,
  input                                         PIPE_RXPRBSCNTRESET,
  input       [ 2:0]                            PIPE_LOOPBACK,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_RXPRBSERR,
  input       [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_TXINHIBIT,
  output                                          ext_ch_gt_drpclk,
  input        [(LINK_CAP_MAX_LINK_WIDTH*9)-1:0] ext_ch_gt_drpaddr,
  input        [LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drpen,
  input        [(LINK_CAP_MAX_LINK_WIDTH*16)-1:0]ext_ch_gt_drpdi,
  input        [LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drpwe,
  output       [(LINK_CAP_MAX_LINK_WIDTH*16)-1:0]ext_ch_gt_drpdo,
  output       [LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drprdy,
  output  wire                      phy_rdy_n,
  input wire                      scan_clk, // Added for DFT
  input wire                      test_i    // Added for DFT
);
  localparam                         USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                                                        (USER_CLK_FREQ == 4) ? 3 :
                                                        (USER_CLK_FREQ == 3) ? 2 :
                                                         USER_CLK_FREQ;
  localparam                         PCIE_LPM_DFE    = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
  localparam                         PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;
  localparam                         PCIE_OOBCLK_MODE_ENABLE = 1;  
  localparam              PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 3'd4 : 3'd2;
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rx_phy_status_wire        ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rxchanisaligned_wire      ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*2-1):0] gt_rx_data_k_wire            ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*16-1):0] gt_rx_data_wire              ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rx_elec_idle_wire         ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*3-1):0] gt_rx_status_wire            ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rx_valid_wire             ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rx_polarity               ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*2-1):0] gt_power_down                ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_tx_char_disp_mode         ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*2-1):0] gt_tx_data_k                 ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*16-1):0] gt_tx_data                   ; 
  wire                               gt_tx_detect_rx_loopback     ;
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_tx_elec_idle              ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rx_elec_idle_reset        ; 
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] phystatus_rst                ;
  wire                               clock_locked                 ;
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rx_phy_status_wire_filter ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*2-1):0] gt_rx_data_k_wire_filter     ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*16-1):0] gt_rx_data_wire_filter       ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rx_elec_idle_wire_filter  ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH*3-1):0] gt_rx_status_wire_filter     ; 
  wire [  (LINK_CAP_MAX_LINK_WIDTH-1):0] gt_rx_valid_wire_filter      ; 
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] gt_eyescandataerror          ;
  wire                               pipe_clk_int;
  reg                                phy_rdy_n_int;
  reg                                reg_clock_locked;
  wire                               all_phystatus_rst;
  wire                               dft_pipe_clk; // Added for DFT

  assign dft_pipe_clk = test_i ? scan_clk : pipe_clk_int; // Added for DFT

reg [5:0] pl_ltssm_state_q;
always @(posedge dft_pipe_clk or negedge clock_locked) begin // Modified for DFT
  if (!clock_locked)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end
  assign pipe_clk = pipe_clk_int ; // Keep original output assignment
  wire                               plm_in_l0 = (pl_ltssm_state_q == 6'h16);
  wire                               plm_in_rl = (pl_ltssm_state_q == 6'h1c);
  wire                               plm_in_dt = (pl_ltssm_state_q == 6'h2d);
  wire                               plm_in_rs = (pl_ltssm_state_q == 6'h1f);
genvar i;
generate for (i=0; i<LINK_CAP_MAX_LINK_WIDTH; i=i+1)
 begin : gt_rx_valid_filter
PCIeGen2x8If128_gt_rx_valid_filter_7x # (
     .CLK_COR_MIN_LAT(28)
   )
   GT_RX_VALID_FILTER_7x_inst (
     .USER_RXCHARISK   ( gt_rx_data_k_wire   [(2*i)+1 : (2*i)] ),        // Corrected Indexing
     .USER_RXDATA      ( gt_rx_data_wire     [(16*i)+15: (16*i)] ),      // Corrected Indexing
     .USER_RXVALID     ( gt_rx_valid_wire    [i] ),                                       
     .USER_RXELECIDLE  ( gt_rx_elec_idle_wire[i] ),                                   
     .USER_RX_STATUS   ( gt_rx_status_wire   [(3*i)+2 : (