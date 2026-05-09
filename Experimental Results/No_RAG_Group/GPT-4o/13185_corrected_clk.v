`timescale 1ns/1ns

module PCIEBus_gt_top #
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
   input   wire [5:0]                pl_ltssm_state,
   input   wire                      pipe_tx_rcvr_det,
   input   wire                      pipe_tx_reset,
   input   wire                      pipe_tx_rate,
   input   wire                      pipe_tx_deemph,
   input   wire [2:0]                pipe_tx_margin,
   input   wire                      pipe_tx_swing,
   input   wire                      PIPE_PCLK_IN,
   input   wire                      PIPE_RXUSRCLK_IN,
   input   wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,
   input   wire                      PIPE_DCLK_IN,
   input   wire                      PIPE_USERCLK1_IN,
   input   wire                      PIPE_USERCLK2_IN,
   input   wire                      PIPE_OOBCLK_IN,
   input   wire                      PIPE_MMCM_LOCK_IN,
   output  wire                      PIPE_TXOUTCLK_OUT,
   output  wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,
   output  wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,
   output  wire                      PIPE_GEN3_OUT,
   output  wire [(LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn,
   output  wire [(LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp,
   input   wire [(LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn,
   input   wire [(LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp,
   input   wire                      sys_clk,
   input   wire                      sys_rst_n,
   input   wire                      PIPE_MMCM_RST_N,
   output  wire                      pipe_clk,
   output  wire                      user_clk,
   output  wire                      user_clk2,
   output  wire                      phy_rdy_n
);

  parameter                          TCQ  = 1;      
  localparam                         USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                                                        (USER_CLK_FREQ == 4) ? 3 :
                                                        (USER_CLK_FREQ == 3) ? 2 :
                                                         USER_CLK_FREQ;
  localparam                         PCIE_LPM_DFE    = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
  localparam                         PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;
  localparam                         PCIE_OOBCLK_MODE_ENABLE =  1;
  localparam                         PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 4 : 2;

  reg [5:0] pl_ltssm_state_q;
  wire pipe_clk_int;
  reg phy_rdy_n_int;
  reg reg_clock_locked;
  wire all_phystatus_rst;
  wire clock_locked;

  always @(posedge pipe_clk_int or negedge clock_locked) begin
    if (!clock_locked)
      pl_ltssm_state_q <= #TCQ 6'b0;
    else
      pl_ltssm_state_q <= #TCQ pl_ltssm_state;
  end

  assign pipe_clk = pipe_clk_int;
  wire plm_in_l0 = (pl_ltssm_state_q == 6'h16);
  wire plm_in_rs = (pl_ltssm_state_q == 6'h1f);

  always @(posedge pipe_clk_int or negedge clock_locked) begin
    if (!clock_locked)
      reg_clock_locked <= #TCQ 1'b0;
    else
      reg_clock_locked <= #TCQ 1'b1;
  end

  always @(posedge pipe_clk_int) begin
    if (!reg_clock_locked)
      phy_rdy_n_int <= #TCQ 1'b0;
    else
      phy_rdy_n_int <= #TCQ all_phystatus_rst;
  end

  assign all_phystatus_rst = 1'b1;  // 确保所有物理层状态复位
  assign phy_rdy_n = phy_rdy_n_int;

endmodule