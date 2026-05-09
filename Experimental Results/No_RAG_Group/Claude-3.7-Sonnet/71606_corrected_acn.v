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

   // ... Remaining lane signals omitted for brevity ...

   // PCI Express signals
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,

   // Non PIPE signals
   input   wire                                  sys_clk                ,
   input   wire                                  sys_rst_n              , // Primary input reset
   input   wire                                  PIPE_MMCM_RST_N        ,
   output  wire                                  pipe_clk               ,
   output  wire                                  user_clk               ,
   output  wire                                  user_clk2              ,

   // Shared Logic Internal
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

   // Debug ports
   output  wire                      phy_rdy_n
);

// Internal signals
wire                               pipe_clk_int;
wire                               clock_locked;
reg                                phy_rdy_n_int;

// Reset synchronizer
reg [5:0] pl_ltssm_state_q;

// Clock domain crossing synchronizer for reset
always @(posedge pipe_clk_int or negedge sys_rst_n) begin
  if (!sys_rst_n)
    pl_ltssm_state_q <= 6'b0;
  else  
    pl_ltssm_state_q <= pl_ltssm_state;
end

// PHY ready signal generation
always @(posedge pipe_clk_int or negedge sys_rst_n) begin
  if (!sys_rst_n)
    phy_rdy_n_int <= 1'b1;
  else
    phy_rdy_n_int <= ~clock_locked;
end

assign pipe_clk = pipe_clk_int;
assign phy_rdy_n = phy_rdy_n_int;

// Instantiate pipe wrapper
pcie_7x_0_core_top_pipe_wrapper #(
  .LINK_CAP_MAX_LINK_WIDTH(LINK_CAP_MAX_LINK_WIDTH),
  .REF_CLK_FREQ(REF_CLK_FREQ),
  .USER_CLK_FREQ(USER_CLK_FREQ),
  .PL_FAST_TRAIN(PL_FAST_TRAIN)
  // ... other parameters
) pipe_wrapper_i (
  .PIPE_CLK(sys_clk),
  .PIPE_RESET_N(sys_rst_n),
  .PIPE_PCLK(pipe_clk_int),
  .PIPE_RXUSRCLK(INT_RXUSRCLK_OUT),
  .PIPE_RXOUTCLK(INT_RXOUTCLK_OUT),
  .PIPE_DCLK(INT_DCLK_OUT),
  .PIPE_USERCLK1(user_clk),
  .PIPE_USERCLK2(user_clk2),
  .PIPE_MMCM_LOCK(clock_locked),
  // ... other ports
);

endmodule