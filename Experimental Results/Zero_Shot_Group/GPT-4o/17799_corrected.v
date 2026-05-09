`timescale 1ns / 1ps

module PCIEBus_pipe_wrapper #(
  parameter PCIE_SIM_MODE                 = "FALSE",
  parameter PCIE_SIM_SPEEDUP              = "FALSE",
  parameter PCIE_SIM_TX_EIDLE_DRIVE_LEVEL = "1",
  parameter PCIE_GT_DEVICE                = "GTX",
  parameter PCIE_USE_MODE                 = "3.0",
  parameter PCIE_PLL_SEL                  = "CPLL",
  parameter PCIE_AUX_CDR_GEN3_EN          = "TRUE",
  parameter PCIE_LPM_DFE                  = "LPM",
  parameter PCIE_LPM_DFE_GEN3             = "DFE",
  parameter PCIE_EXT_CLK                  = "FALSE",
  parameter PCIE_POWER_SAVING             = "TRUE",
  parameter PCIE_ASYNC_EN                 = "FALSE",
  parameter PCIE_TXBUF_EN                 = "FALSE",
  parameter PCIE_RXBUF_EN                 = "TRUE",
  parameter PCIE_TXSYNC_MODE              = 0,
  parameter PCIE_DEBUG_MODE               = 0,
  parameter PCIE_EIEOS_CNT                = 6,
  parameter PCIE_RXELECIDLE_PD            = "TRUE",
  parameter integer PCIE_LANE             = 8
)(
  // 端口定义略，按实际需要补充
);

  // debug 信号赋值逻辑
  assign PIPE_DEBUG_0 = (PCIE_DEBUG_MODE == 1) ? user_clk                     : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_1 = (PCIE_DEBUG_MODE == 1) ? gt_rxelecidle               : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_2 = (PCIE_DEBUG_MODE == 1) ? gt_phystatus                : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_3 = (PCIE_DEBUG_MODE == 1) ? gt_rxvalid                  : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_4 = (PCIE_DEBUG_MODE == 1) ? clk_dclk                    : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_5 = (PCIE_DEBUG_MODE == 1) ? drp_mux_en                  : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_6 = (PCIE_DEBUG_MODE == 1) ? drp_mux_we                  : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_7 = (PCIE_DEBUG_MODE == 1) ? gt_rdy                      : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_8 = (PCIE_DEBUG_MODE == 1) ? user_rx_converge            : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG_9 = (PCIE_DEBUG_MODE == 1) ? PIPE_TXELECIDLE             : {PCIE_LANE{1'b0}};
  assign PIPE_DEBUG[ 1:0]  = (PCIE_DEBUG_MODE == 1) ? PIPE_TXEQ_CONTROL[1:0] : 2'd0;
  assign PIPE_DEBUG[ 5:2]  = (PCIE_DEBUG_MODE == 1) ? PIPE_TXEQ_PRESET[3:0]  : 4'd0;
  assign PIPE_DEBUG[31:6]  = 26'd0;

endmodule
