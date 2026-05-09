module sim_pcie_axi_bridge #(
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
  input               sys_clk_p,
  input               sys_clk_n,
  input               sys_reset,
  output              user_clk_out,
  output              user_reset_out,
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
localparam            F7_ID               = 7;
reg           clk;
reg   [23:0]  r_usr_clk_count;
reg           rst;
reg   [23:0]  r_usr_rst_count;
reg   [23:0]  r_linkup_timeout;
reg   [23:0]  r_mcount;
reg   [23:0]  r_scount;
wire  [23:0]  w_func_size_map [0:7];
assign  pcie_exp_txp              = 0;
assign  pcie_exp_txn              = 0;
assign  user_clk_out              = clk;
assign  user_reset_out            = rst;
assign  w_func_size_map[CONTROL_FUNCTION_ID ] = CONTROL_PACKET_SIZE;
assign  w_func_size_map[DATA_FUNCTION_ID    ] = DATA_PACKET_SIZE;
assign  w_func_size_map[F2_ID               ] = F2_PACKET_SIZE;
assign  w_func_size_map[F3_ID               ] = F3_PACKET_SIZE;
assign  w_func_size_map[F4_ID               ] = F4_PACKET_SIZE;
assign  w_func_size_map[F5_ID               ] = F5_PACKET_SIZE;
assign  w_func_size_map[F6_ID               ] = F6_PACKET_SIZE;
assign  w_func_size_map[F7_ID               ] = F7_PACKET_SIZE;
assign  received_hot_reset        = 0;
assign  fc_nph                    = 0;
assign  fc_npd                    = 0;
assign  fc_ph                     = 0;
assign  fc_pd                     = 0;
assign  fc_cplh                   = 0;
assign  fc_cpld                   = 0;
assign  cfg_do                    = 0;
assign  cfg_rd_wr_done            = 0;
assign  cfg_err_cpl_rdy           = 0;
assign  cfg_interrupt_rdy         = 0;
assign  cfg_interrupt_do          = 0;
assign  cfg_interrupt_mmenable    = 0;
assign  cfg_interrupt_msienable   = 0;
assign  cfg_to_turnoff            = 0;
assign  cfg_pcie_link_state       = 0;
assign  cfg_bus_number            = 0;
assign  cfg_device_number         = 0;
assign  cfg_status                = 0;
assign  cfg_command               = 0;
assign  cfg_dstatus               = 0;
assign  cfg_dcommand              = 0;
assign  cfg_lstatus               = 0;
assign  cfg_lcommand              = 0;
always @ (posedge sys_clk_p) begin
  if (sys_reset) begin
    clk               <=  0;
    r_usr_clk_count   <=  0;
  end
  else begin
    if (r_usr_clk_count < USR_CLK_DIVIDE) begin
      r_usr_clk_count <=  r_usr_clk_count + 1;
    end
    else begin
      r_usr_clk_count <= 0;
      clk             <=  ~clk;
    end
  end
end
always @ (posedge sys_clk_p or posedge sys_reset) begin
  if (sys_reset) begin
    rst               <=  1;
    r_usr_rst_count   <=  0;
  end
  else begin
    if (r_usr_rst_count < RESET_OUT_TIMEOUT) begin
      r_usr_rst_count <=  r_usr_rst_count + 1;
    end
    else begin
      rst             <=  0;
    end
  end
end
always @ (posedge clk) begin
  if (rst) begin
    r_linkup_timeout    <=  0;
    user_lnk_up         <=  0;
  end
  else begin
    if (r_linkup_timeout < LINKUP_TIMEOUT) begin
      r_linkup_timeout  <=  r_linkup_timeout + 1;
    end
    else begin
      user_lnk_up       <=  1;
    end
  end
end
always @ (posedge clk) begin
  if (rst) begin
    cfg_function_number <=  0;
  end
  else begin
    cfg_function_number <= cfg_function_number; // Keep value
  end
end
reg [3:0] dm_state;
localparam  IDLE    = 0;
localparam  READY   = 1;
localparam  WRITE   = 2;
localparam  READ    = 3;
always @ (posedge clk) begin
  if (rst) begin
    m_axis_rx_tdata   <=  0;
    dm_state          <=  IDLE;
    m_axis_rx_tkeep   <=  4'b1111;
    m_axis_rx_tuser   <=  0;
    r_mcount          <=  0;
    m_axis_rx_tlast   <=  0;
    m_axis_rx_tvalid  <=  0;
  end
  else begin
    m_axis_rx_tlast     <=  0;
    m_axis_rx_tvalid    <=  0;
    case (dm_state)
      IDLE: begin
        r_mcount        <=  0;
        dm_state        <=  READY;
        m_axis_rx_tdata <=  0;
      end
      READY: begin
        if (m_axis_rx_tready) begin
          dm_state    <=  WRITE;
        end
      end
      WRITE: begin
        if (m_axis_rx_tvalid) begin
          m_axis_rx_tdata   <=  m_axis_rx_tdata + 1;
        end
        if (m_axis_rx_tready && (r_mcount < w_func_size_map[cfg_function_number])) begin
          m_axis_rx_tvalid  <=  1;
          if (r_mcount >= w_func_size_map[cfg_function_number] - 1) begin
            m_axis_rx_tlast <=  1;
          end
          r_mcount          <=  r_mcount + 1;
        end
        else begin
          dm_state      <=  IDLE;
        end
      end
      default: begin
        dm_state <= IDLE;
      end
    endcase
  end
end
reg [3:0] ds_state;
localparam IDLE_S = 0;
localparam READ_S = 1;

always @ (posedge clk) begin
  if (rst) begin
    s_axis_tx_tready  <=  0;
    tx_buf_av       <=  0;
    tx_err_drop     <=  0;
    tx_cfg_req      <=  0;
    ds_state        <=  IDLE_S;
    r_scount        <=  0;
  end
  else begin
    s_axis_tx_tready  <=  0;
    case (ds_state)
      IDLE_S: begin
        r_scount    <=  0;
        ds_state    <=  READ_S;
      end
      READ_S: begin
        if (s_axis_tx_tvalid && (r_scount < w_func_size_map[cfg_function_number])) begin
          s_axis_tx_tready    <=  1;
          r_scount <= r_scount + 1;
        end
        else begin
          ds_state  <=  IDLE_S;
        end
      end
      default: begin
        ds_state <= IDLE_S;
      end
    endcase
  end
end
endmodule