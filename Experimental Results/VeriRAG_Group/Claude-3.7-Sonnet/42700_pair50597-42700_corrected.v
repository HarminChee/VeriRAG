`timescale 1ns/1ns
module pcie_7x_v1_11_0_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8, 
   parameter               REF_CLK_FREQ = 0,            
   parameter               USER_CLK2_DIV2 = "FALSE",    
   parameter  integer      USER_CLK_FREQ = 3,           
   parameter               PL_FAST_TRAIN = "FALSE",     
   parameter               PCIE_EXT_CLK = "FALSE",      
   parameter               PCIE_USE_MODE = "1.0",       
   parameter               PCIE_GT_DEVICE = "GTX",      
   parameter               PCIE_PLL_SEL   = "CPLL",     
   parameter               PCIE_ASYNC_EN  = "FALSE",    
   parameter               PCIE_TXBUF_EN  = "FALSE",    
   parameter               PCIE_CHAN_BOND = 0
)
(
   input   wire [5:0]                pl_ltssm_state         ,
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   input                             pipe_clk_ext           ,
   input                             PIPE_PCLK_IN,
   input                             PIPE_RXUSRCLK_IN,
   input [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,
   input                             PIPE_DCLK_IN,
   input                             PIPE_USERCLK1_IN,
   input                             PIPE_USERCLK2_IN,
   input                             PIPE_OOBCLK_IN,
   input                             PIPE_MMCM_LOCK_IN,
   output                            PIPE_TXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,
   output                            PIPE_GEN3_OUT,
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
   // ... existing port declarations ...
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,
   input   wire                      sys_clk                ,
   input   wire                      sys_rst_n              ,
   input   wire                      PIPE_MMCM_RST_N        ,
   input        [3:0]                i_tx_diff_ctr          ,
   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,
   output       [15:0]               o_rx_data,
   output       [1:0]                o_rx_data_k,
   output       [1:0]                o_rx_byte_is_comma,
   output                            o_rx_byte_is_aligned,
   output  wire                      phy_rdy_n,
   input                             test_mode
);

// ... existing parameter and wire declarations ...

wire pipe_clk_int;
wire pipe_clk_sel;
wire pipe_clk_mux;

assign pipe_clk_mux = test_mode ? pipe_clk_ext : pipe_clk_int;
assign pipe_clk = pipe_clk_mux;

// ... rest of existing code ...

endmodule