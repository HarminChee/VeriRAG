`timescale 1ps/1ps

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
  parameter integer PCIE_CHAN_BOND = 0
)(
  // 端口定义省略
);

  // 实例化和逻辑省略

  assign pipe_gen3_out = 1'b0;
  assign common_commands_out = 17'b0;
  assign pipe_tx_0_sigs = 70'b0;
  assign pipe_tx_1_sigs = 70'b0;
  assign pipe_tx_2_sigs = 70'b0;
  assign pipe_tx_3_sigs = 70'b0;
  assign pipe_tx_4_sigs = 70'b0;
  assign pipe_tx_5_sigs = 70'b0;
  assign pipe_tx_6_sigs = 70'b0;
  assign pipe_tx_7_sigs = 70'b0;

  assign icap_o = 32'h00000000;
  assign cfg_mgmt_write_wire = cfg_mgmt_write;
  assign cfg_mgmt_read_wire = cfg_mgmt_read;
  assign cfg_per_func_status_control_wire = cfg_per_func_status_control;
  assign cfg_per_function_output_request_wire = cfg_per_function_output_request;
  assign cfg_dsn_wire = cfg_dsn;
  assign cfg_power_state_change_ack_wire = cfg_power_state_change_ack;
  assign cfg_err_cor_in_wire = cfg_err_cor_in;
  assign cfg_err_uncor_in_wire = cfg_err_uncor_in;
  assign cfg_flr_done_wire = cfg_flr_done;
  assign cfg_vf_flr_done_wire = cfg_vf_flr_done;
  assign cfg_link_training_enable_wire = cfg_link_training_enable;
  assign cfg_ext_read_data_valid_wire = cfg_ext_read_data_valid;
  assign cfg_interrupt_pending_wire = cfg_interrupt_pending;
  assign cfg_interrupt_msi_select_wire = cfg_interrupt_msi_select;
  assign cfg_interrupt_msi_pending_status_wire = cfg_interrupt_msi_pending_status;
  assign cfg_config_space_enable_wire = cfg_config_space_enable;
  assign cfg_req_pm_transition_l23_ready_wire = cfg_req_pm_transition_l23_ready;
  assign cfg_hot_reset_in_wire = cfg_hot_reset_in;
  assign cfg_ds_port_number_wire = cfg_ds_port_number;
  assign cfg_ds_bus_number_wire = cfg_ds_bus_number;
  assign cfg_ds_device_number_wire = cfg_ds_device_number;
  assign cfg_ds_function_number_wire = cfg_ds_function_number;
  assign user_tph_stt_address_wire = user_tph_stt_address;
  assign user_tph_function_num_wire = user_tph_function_num;
  assign user_tph_stt_read_enable_wire = user_tph_stt_read_enable;

  assign cfg_phy_link_down = cfg_phy_link_down_wire;
  assign cfg_phy_link_status = cfg_phy_link_status_wire;
  assign cfg_ltssm_state = cfg_ltssm_state_wire;
  assign cfg_hot_reset_out = cfg_hot_reset_out_wire;

  assign pcie_drp_rdy = drp_rdy_wire;
  assign pcie_drp_do = drp_do_wire;

  assign drp_clk_wire   = pcie_drp_clk;
  assign drp_en_wire    = pcie_drp_en;
  assign drp_we_wire    = pcie_drp_we;
  assign drp_addr_wire  = pcie_drp_addr;
  assign drp_di_wire    = pcie_drp_di;

  assign s_axis_cc_tdata_wire = s_axis_cc_tdata;
  assign s_axis_cc_tkeep_wire = s_axis_cc_tkeep;
  assign s_axis_cc_tlast_wire = s_axis_cc_tlast;
  assign s_axis_cc_tvalid_wire = s_axis_cc_tvalid;
  assign s_axis_cc_tuser_wire = s_axis_cc_tuser;
  assign s_axis_cc_tready = s_axis_cc_tready_wire;

  assign m_axis_cq_tdata = m_axis_cq_tdata_wire;
  assign m_axis_cq_tlast = m_axis_cq_tlast_wire;
  assign m_axis_cq_tvalid = m_axis_cq_tvalid_wire;
  assign m_axis_cq_tuser = m_axis_cq_tuser_wire;
  assign m_axis_cq_tkeep = m_axis_cq_tkeep_wire;
  assign m_axis_cq_tready_wire = m_axis_cq_tready;

  assign s_axis_rq_tdata_wire = s_axis_rq_tdata;
  assign s_axis_rq_tkeep_wire = s_axis_rq_tkeep;
  assign s_axis_rq_tlast_wire = s_axis_rq_tlast;
  assign s_axis_rq_tvalid_wire = s_axis_rq_tvalid;
  assign s_axis_rq_tuser_wire = s_axis_rq_tuser;
  assign s_axis_rq_tready = s_axis_rq_tready_wire;

  assign m_axis_rc_tdata = m_axis_rc_tdata_wire;
  assign m_axis_rc_tlast = m_axis_rc_tlast_wire;
  assign m_axis_rc_tvalid = m_axis_rc_tvalid_wire;
  assign m_axis_rc_tuser = m_axis_rc_tuser_wire;
  assign m_axis_rc_tkeep = m_axis_rc_tkeep_wire;
  assign m_axis_rc_tready_wire = m_axis_rc_tready;

  assign cfg_msg_transmit_done = cfg_msg_transmit_done_wire;
  assign cfg_msg_transmit_wire = cfg_msg_transmit;
  assign cfg_msg_transmit_type_wire = cfg_msg_transmit_type;
  assign cfg_msg_transmit_data_wire = cfg_msg_transmit_data;

  assign pcie_rq_tag = pcie_rq_tag_wire;
  assign pcie_rq_tag_vld = pcie_rq_tag_vld_wire;
  assign pcie_tfc_nph_av = pcie_tfc_nph_av_wire;
  assign pcie_tfc_npd_av = pcie_tfc_npd_av_wire;
  assign pcie_rq_seq_num = pcie_rq_seq_num_wire;
  assign pcie_rq_seq_num_vld = pcie_rq_seq_num_vld_wire;

  assign cfg_fc_ph = cfg_fc_ph_wire;
  assign cfg_fc_nph = cfg_fc_nph_wire;
  assign cfg_fc_cplh = cfg_fc_cplh_wire;
  assign cfg_fc_pd = cfg_fc_pd_wire;
  assign cfg_fc_npd = cfg_fc_npd_wire;
  assign cfg_fc_cpld = cfg_fc_cpld_wire;
  assign cfg_fc_sel_wire = cfg_fc_sel;

  assign pcie_cq_np_req_count = pcie_cq_np_req_count_wire;
  assign pcie_cq_np_req_wire = pcie_cq_np_req;

  assign cfg_msg_received = cfg_msg_received_wire;
  assign cfg_msg_received_type = cfg_msg_received_type_wire;
  assign cfg_msg_received_data = cfg_msg_received_data_wire;

  assign cfg_interrupt_int_wire = cfg_interrupt_int;
  assign cfg_interrupt_msi_int_wire = cfg_interrupt_msi_int;
  assign cfg_interrupt_msix_int_wire = cfg_interrupt_msix_int;

  assign user_app_rdy = 1'b1;
  assign startup_cfgclk = 1'b0;
  assign startup_cfgmclk = 1'b0;
  assign startup_eos = 1'b0;
  assign startup_preq = 1'b0;
  assign user_lnk_up = user_lnk_up_int;

endmodule
