`timescale 1ps / 1ps
`define PCI_EXP_EP_OUI                           24'h000A35
`define PCI_EXP_EP_DSN_1                         {{8'h1},`PCI_EXP_EP_OUI}
`define PCI_EXP_EP_DSN_2                         32'h00000001
`timescale 1ps / 1ps
`define PCI_EXP_EP_OUI                           24'h000A35
`define PCI_EXP_EP_DSN_1                         {{8'h1},`PCI_EXP_EP_OUI}
`define PCI_EXP_EP_DSN_2                         32'h00000001
module  pcie_app_7x#(
  parameter C_DATA_WIDTH = 64,            
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8,              
  parameter TCQ        = 1
)(
  input                         user_clk,
  input                         user_reset,
  input                         user_lnk_up,
  output                        tx_cfg_gnt,
  input                         s_axis_tx_tready,
  output  [C_DATA_WIDTH-1:0]    s_axis_tx_tdata,
  output  [KEEP_WIDTH-1:0]      s_axis_tx_tkeep,
  output  [3:0]                 s_axis_tx_tuser,
  output                        s_axis_tx_tlast,
  output                        s_axis_tx_tvalid,
  output                        rx_np_ok,
  output                        rx_np_req,
  input  [C_DATA_WIDTH-1:0]     m_axis_rx_tdata,
  input  [KEEP_WIDTH-1:0]       m_axis_rx_tkeep,
  input                         m_axis_rx_tlast,
  input                         m_axis_rx_tvalid,
  output                        m_axis_rx_tready,
  input    [21:0]               m_axis_rx_tuser,
  output [2:0]                  fc_sel,
  output                        cfg_err_cor,
  output                        cfg_err_ur,
  output                        cfg_err_ecrc,
  output                        cfg_err_cpl_timeout,
  output                        cfg_err_cpl_unexpect,
  output                        cfg_err_cpl_abort,
  output                        cfg_err_atomic_egress_blocked,
  output                        cfg_err_internal_cor,
  output                        cfg_err_malformed,
  output                        cfg_err_mc_blocked,
  output                        cfg_err_poisoned,
  output                        cfg_err_norecovery,
  output                        cfg_err_acs,
  output                        cfg_err_internal_uncor,
  output                        cfg_pm_halt_aspm_l0s,
  output                        cfg_pm_halt_aspm_l1,
  output                        cfg_pm_force_state_en,
  output [1:0]                  cfg_pm_force_state,
  output                        cfg_err_posted,
  output                        cfg_err_locked,
  output [47:0]                 cfg_err_tlp_cpl_header,
  output                        cfg_interrupt,
  output                        cfg_interrupt_assert,
  output [7:0]                  cfg_interrupt_di,
  output                        cfg_turnoff_ok,
  input                         cfg_to_turnoff,
  output                        cfg_trn_pending,
  output                        cfg_pm_wake,
  input   [7:0]                 cfg_bus_number,
  input   [4:0]                 cfg_device_number,
  input   [2:0]                 cfg_function_number,
  output                        cfg_interrupt_stat,
  output  [4:0]                 cfg_pciecap_interrupt_msgnum,
  output  [1:0]                 pl_directed_link_change,
  output  [1:0]                 pl_directed_link_width,
  output                        pl_directed_link_speed,
  output                        pl_directed_link_auton,
  output                        pl_upstream_prefer_deemph,
  output [127:0]                cfg_err_aer_headerlog,
  output   [4:0]                cfg_aer_interrupt_msgnum,
  output [31:0]                 cfg_mgmt_di,
  output  [3:0]                 cfg_mgmt_byte_en,
  output  [9:0]                 cfg_mgmt_dwaddr,
  output                        cfg_mgmt_wr_en,
  output                        cfg_mgmt_rd_en,
  output                        cfg_mgmt_wr_readonly,
  output [63:0]                 cfg_dsn
);
  assign fc_sel = 3'b0;
  assign rx_np_ok = 1'b1;                          
  assign rx_np_req = 1'b1;                         
  assign s_axis_tx_tuser[0] = 1'b0;                
  assign s_axis_tx_tuser[1] = 1'b0;                
  assign s_axis_tx_tuser[2] = 1'b0;                
  assign tx_cfg_gnt = 1'b1;                        
  assign cfg_err_cor = 1'b0;                       
  assign cfg_err_ur = 1'b0;                        
  assign cfg_err_ecrc = 1'b0;                      
  assign cfg_err_cpl_timeout = 1'b0;               
  assign cfg_err_cpl_abort = 1'b0;                 
  assign cfg_err_cpl_unexpect = 1'b0;              
  assign cfg_err_posted = 1'b0;                    
  assign cfg_err_locked = 1'b0;                    
  assign cfg_pm_wake = 1'b0;                       
  assign cfg_trn_pending = 1'b0;                   
  assign cfg_err_atomic_egress_blocked = 1'b0;     
  assign cfg_err_internal_cor = 1'b0;              
  assign cfg_err_malformed = 1'b0;                 
  assign cfg_err_mc_blocked = 1'b0;                
  assign cfg_err_poisoned = 1'b0;                  
  assign cfg_err_norecovery = 1'b0;                
  assign cfg_err_acs = 1'b0;                       
  assign cfg_err_internal_uncor = 1'b0;            
  assign cfg_pm_halt_aspm_l0s = 1'b0;              
  assign cfg_pm_halt_aspm_l1 = 1'b0;               
  assign cfg_pm_force_state_en  = 1'b0;            
  assign cfg_pm_force_state  = 2'b00;              
  assign cfg_err_aer_headerlog = 128'h0;           
  assign cfg_aer_interrupt_msgnum = 5'b00000;      
  assign cfg_interrupt_stat = 1'b0;                
  assign cfg_pciecap_interrupt_msgnum = 5'b00000;  
  assign cfg_interrupt_assert = 1'b0;              
  assign cfg_interrupt = 1'b0;                     
  assign pl_directed_link_change = 2'b00;          
  assign pl_directed_link_width = 2'b00;          
  assign pl_directed_link_speed = 1'b0;            
  assign pl_directed_link_auton = 1'b0;            
  assign pl_upstream_prefer_deemph = 1'b1;         
  assign cfg_interrupt_di = 8'b0;                  
  assign cfg_err_tlp_cpl_header = 48'h0;           
  assign cfg_mgmt_di = 32'h0;                      
  assign cfg_mgmt_byte_en = 4'h0;                  
  assign cfg_mgmt_dwaddr = 10'h0;                  
  assign cfg_mgmt_wr_en = 1'b0;                    
  assign cfg_mgmt_rd_en = 1'b0;                    
  assign cfg_mgmt_wr_readonly = 1'b0;              
  assign cfg_dsn = {`PCI_EXP_EP_DSN_2, `PCI_EXP_EP_DSN_1};  
  wire [15:0] cfg_completer_id      = { cfg_bus_number, cfg_device_number, cfg_function_number };
  reg         s_axis_tx_tready_i ;
  always @(posedge user_clk)
  begin
   if (user_reset)
      s_axis_tx_tready_i <= #TCQ 1'b0;
   else
      s_axis_tx_tready_i <= #TCQ s_axis_tx_tready;
  end
  PIO  #(
    .C_DATA_WIDTH( C_DATA_WIDTH ),
    .KEEP_WIDTH( KEEP_WIDTH ),
    .TCQ( TCQ )
  ) PIO (
    .user_clk ( user_clk ),                         
    .user_reset ( user_reset ),                     
    .user_lnk_up ( user_lnk_up ),                   
    .s_axis_tx_tready ( s_axis_tx_tready_i ),         
    .s_axis_tx_tdata ( s_axis_tx_tdata ),           
    .s_axis_tx_tkeep ( s_axis_tx_tkeep ),           
    .s_axis_tx_tlast ( s_axis_tx_tlast ),           
    .s_axis_tx_tvalid ( s_axis_tx_tvalid ),         
    .tx_src_dsc ( s_axis_tx_tuser[3] ),             
    .m_axis_rx_tdata( m_axis_rx_tdata ),            
    .m_axis_rx_tkeep( m_axis_rx_tkeep ),            
    .m_axis_rx_tlast( m_axis_rx_tlast ),            
    .m_axis_rx_tvalid( m_axis_rx_tvalid ),          
    .m_axis_rx_tready( m_axis_rx_tready ),          
    .m_axis_rx_tuser ( m_axis_rx_tuser ),           
    .cfg_to_turnoff ( cfg_to_turnoff ),             
    .cfg_turnoff_ok ( cfg_turnoff_ok ),             
    .cfg_completer_id ( cfg_completer_id )          
  );
endmodule 
