`timescale 1ps/1ps

module pcie3_7x_0_pcie_3_0_7vx # (
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
  parameter integer PCIE_LINK_SPEED  = 3,
  parameter integer KEEP_WIDTH  = (C_DATA_WIDTH/32)
) (
  input wire sys_clk,
  input wire sys_reset,
  output wire user_clk,
  output reg user_reset,
  output wire user_lnk_up
);

  // 定义局部参数
  localparam integer USER_CLK_FREQ = (PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? 5 : 4;
  localparam [1:0] CRM_USER_CLK_FREQ = (USER_CLK2_FREQ == 4) ? 2'b10 : ((USER_CLK2_FREQ == 3) ? 2'b01 : 2'b00);
  localparam [1:0] AXISTEN_IF_WIDTH = (C_DATA_WIDTH == 256) ? 2'b10 : ((C_DATA_WIDTH == 128) ? 2'b01 : 2'b00);
  localparam CRM_CORE_CLK_FREQ_500 = (PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? "TRUE" : "FALSE";
  localparam INTERFACE_SPEED = (PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? "500 MHZ" : "250 MHZ";
  localparam ENABLE_FAST_SIM_TRAINING = "TRUE";

  // 定义时钟信号
  wire core_clk;
  wire rec_clk;
  wire pipe_clk;
  reg user_reset_int;
  wire sys_or_hot_rst;
  wire cfg_phy_link_down;
  wire [1:0] cfg_phy_link_status;

  // 生成用户时钟
  assign user_clk = core_clk;

  // 处理系统复位信号
  assign sys_or_hot_rst = sys_reset;

  always @(posedge user_clk or posedge sys_or_hot_rst) begin
    if (sys_or_hot_rst)
      user_reset_int <= #TCQ 1'b1;
    else if (cfg_phy_link_status[1] && !cfg_phy_link_down)
      user_reset_int <= #TCQ 1'b0;
  end

  always @(posedge user_clk or posedge sys_or_hot_rst) begin
    if (sys_or_hot_rst)
      user_reset <= #TCQ 1'b1;
    else
      user_reset <= #TCQ user_reset_int;
  end

  assign user_lnk_up = (cfg_phy_link_status == 2'b11) ? 1'b1 : 1'b0;

endmodule