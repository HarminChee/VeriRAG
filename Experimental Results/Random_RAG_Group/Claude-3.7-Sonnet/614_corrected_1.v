module pcie3_7x_0_pcie_3_0_7vx #(
  parameter integer TCQ = 100,
  parameter         component_name = "pcie3_7x_v3_0",
  parameter  [2:0]  PL_LINK_CAP_MAX_LINK_SPEED = 3'h4,
  parameter  [3:0]  PL_LINK_CAP_MAX_LINK_WIDTH = 4'h8,
  parameter integer USER_CLK2_FREQ = 4,
  parameter         C_DATA_WIDTH = 256,
  parameter integer PIPE_PIPELINE_STAGES = 0,
  parameter         PIPE_SIM = "FALSE",
  parameter         PIPE_SIM_MODE = "FALSE", 
  parameter         REF_CLK_FREQ = 0,
  parameter         PCIE_EXT_CLK = "TRUE",
  parameter         PCIE_EXT_GT_COMMON = "FALSE",
  parameter         EXT_CH_GT_DRP = "FALSE",
  parameter         PCIE_DRP = "FALSE",
  parameter         TRANSCEIVER_CTRL_STATUS_PORTS = "FALSE",
  parameter         PCIE_TXBUF_EN = "FALSE",
  parameter         PCIE_GT_DEVICE = "GTH",
  parameter integer PCIE_CHAN_BOND = 0,
  parameter         PCIE_CHAN_BOND_EN = "FALSE",
  parameter         PCIE_USE_MODE = "2.0",
  parameter         PCIE_LPM_DFE = "LPM",
  parameter integer PCIE_LINK_SPEED = 3,
  parameter integer KEEP_WIDTH = (C_DATA_WIDTH/32),
  parameter         TX_MARGIN_FULL_0 = 7'b1001111,
  parameter         TX_MARGIN_FULL_1 = 7'b1001110,
  parameter         TX_MARGIN_FULL_2 = 7'b1001101,
  parameter         TX_MARGIN_FULL_3 = 7'b1001100,
  parameter         TX_MARGIN_FULL_4 = 7'b1000011,
  parameter         TX_MARGIN_LOW_0 = 7'b1000101,
  parameter         TX_MARGIN_LOW_1 = 7'b1000110,
  parameter         TX_MARGIN_LOW_2 = 7'b1000011,
  parameter         TX_MARGIN_LOW_3 = 7'b1000010,
  parameter         TX_MARGIN_LOW_4 = 7'b1000000
)
(
  input test_mode_i,
  input pipe_clk_i,
  input sys_rst_n_i,
  input pipe_tx_rcvr_det,
  input pipe_tx_reset,
  input pipe_tx_rate,
  input pipe_tx_deemph,
  input [2:0] pipe_tx_margin,
  input pipe_tx_swing,
  input [5:0] pipe_tx_eqfs,
  input [5:0] pipe_tx_eqlf,
  input pipe_rx_slide,
  output pipe_rx_syncdone,
  output [5:0] cfg_ltssm_state_wire
);

  wire test_mode_sync;
  wire pipe_clk_sync;
  wire sys_rst_n_sync;

  sync_ff #(
    .STAGES(2)
  ) test_mode_sync_inst (
    .clk(pipe_clk_i),
    .rst_n(sys_rst_n_i),
    .d(test_mode_i),
    .q(test_mode_sync)
  );

  sync_ff #(
    .STAGES(2)
  ) pipe_clk_sync_inst (
    .clk(pipe_clk_i), 
    .rst_n(sys_rst_n_i),
    .d(pipe_clk_i),
    .q(pipe_clk_sync)
  );

  sync_ff #(
    .STAGES(2)
  ) sys_rst_n_sync_inst (
    .clk(pipe_clk_i),
    .rst_n(1'b1),
    .d(sys_rst_n_i), 
    .q(sys_rst_n_sync)
  );

  gt_top #(
    .TCQ(TCQ),
    .PL_LINK_CAP_MAX_LINK_SPEED(PL_LINK_CAP_MAX_LINK_SPEED),
    .PL_LINK_CAP_MAX_LINK_WIDTH(PL_LINK_CAP_MAX_LINK_WIDTH),
    .USER_CLK2_FREQ(USER_CLK2_FREQ),
    .PIPE_PIPELINE_STAGES(PIPE_PIPELINE_STAGES),
    .PIPE_SIM(PIPE_SIM),
    .PIPE_SIM_MODE(PIPE_SIM_MODE),
    .REF_CLK_FREQ(REF_CLK_FREQ),
    .PCIE_EXT_CLK(PCIE_EXT_CLK),
    .PCIE_EXT_GT_COMMON(PCIE_EXT_GT_COMMON),
    .EXT_CH_GT_DRP(EXT_CH_GT_DRP),
    .PCIE_DRP(PCIE_DRP),
    .TRANSCEIVER_CTRL_STATUS_PORTS(TRANSCEIVER_CTRL_STATUS_PORTS),
    .PCIE_TXBUF_EN(PCIE_TXBUF_EN),
    .PCIE_GT_DEVICE(PCIE_GT_DEVICE),
    .PCIE_CHAN_BOND(PCIE_CHAN_BOND),
    .PCIE_CHAN_BOND_EN(PCIE_CHAN_BOND_EN),
    .PCIE_USE_MODE(PCIE_USE_MODE),
    .PCIE_LPM_DFE(PCIE_LPM_DFE),
    .PCIE_LINK_SPEED(PCIE_LINK_SPEED)
  ) gt_top_i (
    .pipe_tx_rcvr_det(pipe_tx_rcvr_det),
    .pipe_tx_reset(pipe_tx_reset),
    .pipe_tx_rate(pipe_tx_rate),
    .pipe_tx_deemph(pipe_tx_deemph),
    .pipe_tx_margin(pipe_tx_margin),
    .pipe_tx_swing(pipe_tx_swing),
    .pipe_txeq_fs(pipe_tx_eqfs),
    .pipe_txeq_lf(pipe_tx_eqlf),
    .pipe_rxslide(pipe_rx_slide),
    .pipe_rxsync_done(pipe_rx_syncdone),
    .cfg_ltssm_state(cfg_ltssm_state_wire),
    .pipe_clk(pipe_clk_i),
    .sys_rst_n(sys_rst_n_i),
    .test_mode(test_mode_i)
  );

endmodule