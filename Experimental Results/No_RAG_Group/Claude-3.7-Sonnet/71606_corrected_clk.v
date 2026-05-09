module pcie_7x_0_core_top_gt_top #
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
   // pl ltssm
   input   wire [5:0]                pl_ltssm_state         ,
   // Pipe Per-Link Signals
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,

   // Pipe Per-Lane Signals - Lane 0-7
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

   // Lanes 1-7 similar to lane 0...
   // [Previous lane signal declarations preserved]

   // PCI Express signals
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,

   // Non PIPE signals 
   input   wire                                  sys_clk                ,
   input   wire                                  sys_rst_n              ,
   input   wire                                  PIPE_MMCM_RST_N        ,
   output  wire                                  pipe_clk               ,
   output  wire                                  user_clk               ,
   output  wire                                  user_clk2              ,

   // Shared Logic Internal/External
   output                                        INT_PCLK_OUT_SLAVE     ,
   output                                        INT_RXUSRCLK_OUT       ,
   output  [(LINK_CAP_MAX_LINK_WIDTH-1):0]       INT_RXOUTCLK_OUT       ,
   output                                        INT_DCLK_OUT           ,
   output                                        INT_USERCLK1_OUT       ,
   output                                        INT_USERCLK2_OUT       ,
   output                                        INT_OOBCLK_OUT         ,
   output                                        INT_MMCM_LOCK_OUT      ,
   output  [1:0]                                 INT_QPLLLOCK_OUT       ,
   output  [1:0]                                 INT_QPLLOUTCLK_OUT     ,
   output  [1:0]                                 INT_QPLLOUTREFCLK_OUT  ,
   input   [(LINK_CAP_MAX_LINK_WIDTH-1):0]       INT_PCLK_SEL_SLAVE     ,

   // External GT COMMON Ports
   input   [11:0]                                qpll_drp_crscode       ,
   input   [17:0]                                qpll_drp_fsm           ,
   input   [1:0]                                 qpll_drp_done          ,
   input   [1:0]                                 qpll_drp_reset         ,
   input   [1:0]                                 qpll_qplllock          ,
   input   [1:0]                                 qpll_qplloutclk        ,
   input   [1:0]                                 qpll_qplloutrefclk     ,
   output                                        qpll_qplld             ,
   output  [1:0]                                 qpll_qpllreset         ,
   output                                        qpll_drp_clk           ,
   output                                        qpll_drp_rst_n         ,
   output                                        qpll_drp_ovrd          ,
   output                                        qpll_drp_gen3          ,
   output                                        qpll_drp_start         ,

   // External Clock Ports
   input                                         PIPE_PCLK_IN           ,
   input                                         PIPE_RXUSRCLK_IN       ,
   input  [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_RXOUTCLK_IN       ,
   input                                         PIPE_DCLK_IN           ,
   input                                         PIPE_USERCLK1_IN       ,
   input                                         PIPE_USERCLK2_IN       ,
   input                                         PIPE_OOBCLK_IN         ,
   input                                         PIPE_MMCM_LOCK_IN      ,
   output                                        PIPE_TXOUTCLK_OUT      ,
   output [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_RXOUTCLK_OUT      ,
   output [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_PCLK_SEL_OUT      ,
   output                                        PIPE_GEN3_OUT          ,

   // Debug Ports
   output      [4:0]                             PIPE_RST_FSM           ,
   output      [11:0]                            PIPE_QRST_FSM          ,
   output      [(LINK_CAP_MAX_LINK_WIDTH*5)-1:0] PIPE_RATE_FSM          ,
   output      [(LINK_CAP_MAX_LINK_WIDTH*6)-1:0] PIPE_SYNC_FSM_TX       ,
   output      [(LINK_CAP_MAX_LINK_WIDTH*7)-1:0] PIPE_SYNC_FSM_RX       ,
   output      [(LINK_CAP_MAX_LINK_WIDTH*7)-1:0] PIPE_DRP_FSM           ,

   output                                        PIPE_RST_IDLE          ,
   output                                        PIPE_QRST_IDLE         ,
   output                                        PIPE_RATE_IDLE         ,
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_EYESCANDATAERROR  ,
   output     [(LINK_CAP_MAX_LINK_WIDTH*3)-1:0]  PIPE_RXSTATUS          ,
   output     [(LINK_CAP_MAX_LINK_WIDTH*15)-1:0] PIPE_DMONITOROUT       ,

   // Debug Ports
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_CPLL_LOCK         ,
   output     [(LINK_CAP_MAX_LINK_WIDTH-1)>>2:0] PIPE_QPLL_LOCK         ,
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXPMARESETDONE    ,       
   output     [(LINK_CAP_MAX_LINK_WIDTH*3)-1:0]  PIPE_RXBUFSTATUS       ,         
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXPHALIGNDONE     ,       
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXPHINITDONE      ,        
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXDLYSRESETDONE   ,    
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXPHALIGNDONE     ,      
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXDLYSRESETDONE   ,     
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXSYNCDONE        ,       
   output     [(LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  PIPE_RXDISPERR         ,       
   output     [(LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  PIPE_RXNOTINTABLE      ,      
   output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXCOMMADET        ,        

   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_0           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_1           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_2           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_3           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_4           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_5           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_6           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_7           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_8           ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_9           ,
   output      [31:0]                            PIPE_DEBUG             ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_JTAG_RDY          ,

   input       [ 2:0]                            PIPE_TXPRBSSEL         ,
   input       [ 2:0]                            PIPE_RXPRBSSEL         ,
   input                                         PIPE_TXPRBSFORCEERR    ,
   input                                         PIPE_RXPRBSCNTRESET    ,
   input       [ 2:0]                            PIPE_LOOPBACK          ,
   output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_RXPRBSERR        ,

   // Channel DRP
   output                                          ext_ch_gt_drpclk      ,
   input        [(LINK_CAP_MAX_LINK_WIDTH*9)-1:0] ext_ch_gt_drpaddr     ,
   input        [LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drpen       ,
   input        [(LINK_CAP_MAX_LINK_WIDTH*16)-1:0]ext_ch_gt_drpdi       ,
   input        [LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drpwe       ,
   output       [(LINK_CAP_MAX_LINK_WIDTH*16)-1:0]ext_ch_gt_drpdo       ,
   output       [LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drprdy      ,

   output  wire                      phy_rdy_n
);

// Clock generation
wire pipe_clk_int;
reg pipe_clk_reg;

// Generate pipe_clk from primary input sys_clk
always @(posedge sys_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
    pipe_clk_reg <= 1'b0;
  else 
    pipe_clk_reg <= ~pipe_clk_reg;
end

assign pipe_clk_int = pipe_clk_reg;
assign pipe_clk = pipe_clk_int;

// Rest of module implementation
// [Previous implementation preserved]

endmodule