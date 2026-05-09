module sim_pcie_axi_bridge_corrected_ffc #(
  parameter USR_CLK_DIVIDE      = 4
)(
  output              pci_exp_txp,
  output              pci_exp_txn,
  input               pci_exp_rxp,
  input               pci_exp_rxn,
  output  reg         user_lnk_up,
  output  reg         s_axis_tx_tready,
  input       [31:0]  s_axis_tx_tdata,
  input       [3:0]   s_axis_tx_tkeep,
  input       [3:0]   s_axis_tx_tuser,
  input               s_axis_tx_tlast,
  input               s_axis_tx_tvalid,
  output  reg [5:0]   tx_buf_av,
  output  reg         tx_err_drop,
  input               tx_cfg_gnt,
  output  reg         tx_cfg_req,
  output  reg [31:0]  m_axis_rx_tdata,
  output  reg [3:0]   m_axis_rx_tkeep,
  output  reg         m_axis_rx_tlast,
  output  reg         m_axis_rx_tvalid,
  input               m_axis_rx_tready,
  output  reg [21:0]  m_axis_rx_tuser,
  input               rx_np_ok,
  input       [2:0]   fc_sel,
  output      [7:0]   fc_nph,
  output      [11:0]  fc_npd,
  output      [7:0]   fc_ph,
  output      [11:0]  fc_pd,
  output      [7:0]   fc_cplh,
  output      [11:0]  fc_cpld,
  output      [31:0]  cfg_do,
  output              cfg_rd_wr_done,
  input       [9:0]   cfg_dwaddr,
  input               cfg_rd_en,
  input               cfg_err_ur,
  input               cfg_err_cor,
  input               cfg_err_ecrc,
  input               cfg_err_cpl_timeout,
  input               cfg_err_cpl_abort,
  input               cfg_err_posted,
  input               cfg_err_locked,
  input      [47:0]   cfg_err_tlp_cpl_header,
  output              cfg_err_cpl_rdy,
  input               cfg_interrupt,
  output              cfg_interrupt_rdy,
  input               cfg_interrupt_assert,
  output      [7:0]   cfg_interrupt_do,
  input       [7:0]   cfg_interrupt_di,
  output      [2:0]   cfg_interrupt_mmenable,
  output              cfg_interrupt_msienable,
  input               cfg_turnoff_ok,
  output              cfg_to_turnoff,
  input               cfg_pm_wake,
  output      [2:0]   cfg_pcie_link_state,
  input               cfg_trn_pending,
  input       [63:0]  cfg_dsn,
  output      [7:0]   cfg_bus_number,
  output      [4:0]   cfg_device_number,
  output  reg [2:0]   cfg_function_number,
  output      [15:0]  cfg_status,
  output      [15:0]  cfg_command,
  output      [15:0]  cfg_dstatus,
  output      [15:0]  cfg_dcommand,
  output      [15:0]  cfg_lstatus,
  output      [15:0]  cfg_lcommand,
  input               sys_clk_p, // Primary clock input
  input               sys_clk_n,
  input               sys_reset, // Primary reset input
  output              user_clk_out, // Changed to output sys_clk_p
  output              user_reset_out, // Outputting synchronous reset 'rst'
  output              received_hot_reset
);
localparam            RESET_OUT_TIMEOUT   = 32'h00000010;
localparam            LINKUP_TIMEOUT      = 32'h00000010;
localparam            CONTROL_PACKET_SIZE = 128;
localparam            DATA_PACKET_SIZE    = 512;
localparam            F2_PACKET_SIZE      = 0;
localparam            F3_PACKET_SIZE      = 0;
localparam            F4_PACKET_SIZE      = 0;
localparam            F5_PACKET_SIZE      = 0;
localparam            F6_PACKET_SIZE      = 0;
localparam            F7_PACKET_SIZE      = 0;
localparam            CONTROL_FUNCTION_ID = 0;
localparam            DATA_FUNCTION_ID    = 1;
localparam            F2_ID               = 2;
localparam            F3_ID               = 3;
localparam            F4_ID               = 4;
localparam            F5_ID               = 5;
localparam            F6_ID               = 6;