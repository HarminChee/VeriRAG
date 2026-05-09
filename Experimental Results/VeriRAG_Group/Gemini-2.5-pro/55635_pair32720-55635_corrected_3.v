`timescale 1ns / 1ps
`timescale 1ns / 1ps
module mem_inf #( 
    parameter C0_SIMULATION          =  "FALSE",
    parameter C1_SIMULATION           = "FALSE",
    parameter C0_SIM_BYPASS_INIT_CAL  = "OFF",
    parameter C1_SIM_BYPASS_INIT_CAL = "OFF"
)
(
input               clk156_25,
input               reset156_25_n,
inout [71:0]        c0_ddr3_dq,
inout [8:0]         c0_ddr3_dqs_n,
inout [8:0]         c0_ddr3_dqs_p,
output [15:0]       c0_ddr3_addr,
output [2:0]        c0_ddr3_ba,
output              c0_ddr3_ras_n,
output              c0_ddr3_cas_n,
output              c0_ddr3_we_n,
output              c0_ddr3_reset_n,
output [1:0]        c0_ddr3_ck_p,
output [1:0]        c0_ddr3_ck_n,
output [1:0]        c0_ddr3_cke,
output [1:0]        c0_ddr3_cs_n,
output [1:0]        c0_ddr3_odt,
output              c0_ui_clk,
input test_i,
output              c0_init_calib_complete,
input               c0_sys_clk_p,
input               c0_sys_clk_n,
input               clk_ref_p,
input               clk_ref_n,
input               c1_sys_clk_p,
input               c1_sys_clk_n,
input sys_rst,
inout [71:0]        c1_ddr3_dq,
inout [8:0]         c1_ddr3_dqs_n,
inout [8:0]         c1_ddr3_dqs_p,
output [15:0]       c1_ddr3_addr,
output [2:0]        c1_ddr3_ba,
output              c1_ddr3_ras_n,
output              c1_ddr3_cas_n,
output              c1_ddr3_we_n,
output              c1_ddr3_reset_n,
output [1:0]        c1_ddr3_ck_p,
output [1:0]        c1_ddr3_ck_n,
output [1:0]        c1_ddr3_cke,
output [1:0]        c1_ddr3_cs_n,
output [1:0]        c1_ddr3_odt,
output              c1_ui_clk,
output              c1_init_calib_complete,
input               toeTX_s_axis_read_cmd_tvalid,
output              toeTX_s_axis_read_cmd_tready,
input[71:0]         toeTX_s_axis_read_cmd_tdata,
output              toeTX_m_axis_read_sts_tvalid,
input               toeTX_m_axis_read_sts_tready,
output[7:0]         toeTX_m_axis_read_sts_tdata,
output[63:0]        toeTX_m_axis_read_tdata,
output[7:0]         toeTX_m_axis_read_tkeep,
output              toeTX_m_axis_read_tlast,
output              toeTX_m_axis_read_tvalid,
input               toeTX_m_axis_read_tready,
input               toeTX_s_axis_write_cmd_tvalid,
output              toeTX_s_axis_write_cmd_tready,
input[71:0]         toeTX_s_axis_write_cmd_tdata,
output              toeTX_m_axis_write_sts_tvalid,
input               toeTX_m_axis_write_sts_tready,
output[7:0]        toeTX_m_axis_write_sts_tdata,
input[63:0]         toeTX_s_axis_write_tdata,
input[7:0]          toeTX_s_axis_write_tkeep,
input               toeTX_s_axis_write_tlast,
input               toeTX_s_axis_write_tvalid,
output              toeTX_s_axis_write_tready,
input               toeRX_s_axis_read_cmd_tvalid,
output              toeRX_s_axis_read_cmd_tready,
input[71:0]         toeRX_s_axis_read_cmd_tdata,
output              toeRX_m_axis_read_sts_tvalid,
input               toeRX_m_axis_read_sts_tready,
output[7:0]         toeRX_m_axis_read_sts_tdata,
output[63:0]        toeRX_m_axis_read_tdata,
output[7:0]         toeRX_m_axis_read_tkeep,
output              toeRX_m_axis_read_tlast,
output              toeRX_m_axis_read_tvalid,
input               toeRX_m_axis_read_tready,
input               toeRX_s_axis_write_cmd_tvalid,
output              toeRX_s_axis_write_cmd_tready,
input[71:0]         toeRX_s_axis_write_cmd_tdata,
output              toeRX_m_axis_write_sts_tvalid,
input               toeRX_m_axis_write_sts_tready,
output[7:0]        toeRX_m_axis_write_sts_tdata,
input[63:0]         toeRX_s_axis_write_tdata,
input[7:0]          toeRX_s_axis_write_tkeep,
input               toeRX_s_axis_write_tlast,
input               toeRX_s_axis_write_tvalid,
output              toeRX_s_axis_write_tready,
input               ht_s_axis_read_cmd_tvalid,
output              ht_s_axis_read_cmd_tready,
input[71:0]         ht_s_axis_read_cmd_tdata,
output              ht_m_axis_read_sts_tvalid,
input               ht_m_axis_read_sts_tready,
output[7:0]         ht_m_axis_read_sts_tdata,
output[511:0]       ht_m_axis_read_tdata,
output[63:0]        ht_m_axis_read_tkeep,
output              ht_m_axis_read_tlast,
output              ht_m_axis_read_tvalid,
input               ht_m_axis_read_tready,
input               ht_s_axis_write_cmd_tvalid,
output              ht_s_axis_write_cmd_tready,
input[71:0]         ht_s_axis_write_cmd_tdata,
output              ht_m_axis_write_sts_tvalid,
input               ht_m_axis_write_sts_tready,
output[7:0]        ht_m_axis_write_sts_tdata,
input[511:0]        ht_s_axis_write_tdata,
input[63:0]         ht_s_axis_write_tkeep,
input               ht_s_axis_write_tlast,
input               ht_s_axis_write_tvalid,
output              ht_s_axis_write_tready,
input               upd_s_axis_read_cmd_tvalid,
output              upd_s_axis_read_cmd_tready,
input[71:0]         upd_s_axis_read_cmd_tdata,
output              upd_m_axis_read_sts_tvalid,
input               upd_m_axis_read_sts_tready,
output[7:0]         upd_m_axis_read_sts_tdata,
output[511:0]       upd_m_axis_read_tdata,
output[63:0]        upd_m_axis_read_tkeep,
output              upd_m_axis_read_tlast,
output              upd_m_axis_read_tvalid,
input               upd_m_axis_read_tready,
input               upd_s_axis_write_cmd_tvalid,
output              upd_s_axis_write_cmd_tready,
input[71:0]         upd_s_axis_write_cmd_tdata,
output              upd_m_axis_write_sts_tvalid,
input               upd_m_axis_write_sts_tready,
output[7:0]        upd_m_axis_write_sts_tdata,
input[511:0]        upd_s_axis_write_tdata,
input[63:0]         upd_s_axis_write_tkeep,
input               upd_s_axis_write_tlast,
input               upd_s_axis_write_tvalid,
output              upd_s_axis_write_tready);
localparam C0_C_S_AXI_ID_WIDTH = 1;
localparam C0_C_S_AXI_ADDR_WIDTH = 33;
localparam C0_C_S_AXI_DATA_WIDTH = 512;
localparam C1_C_S_AXI_ID_WIDTH = 1;
localparam C1_C_S_AXI_ADDR_WIDTH = 33;
localparam C1_C_S_AXI_DATA_WIDTH = 512;
wire dft_c0_ui_clk,dft_c1_ui_clk;
assign dft_c0_ui_clk = test_i ? clk156_25 : c0_ui_clk ;
assign dft_c1_ui_clk = test_i ? clk156_25 : c1_ui_clk ;
wire                                    c0_ui_clk_sync_rst;
wire                                    c0_mmcm_locked;
reg                                     c0_aresetn_r; 
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_awid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_awaddr;
wire [7:0]                              c0_s_axi_awlen;
wire [2:0]                              c0_s_axi_awsize;
wire [1:0]                              c0_s_axi_awburst;
wire [0:0]                              c0_s_axi_awlock;
wire [3:0]                              c0_s_axi_awcache;
wire [2:0]                              c0_s_axi_awprot;
wire                                    c0_s_axi_awvalid;
wire                                    c0_s_axi_awready;
wire [C0_C_S_AXI_DATA_WIDTH-1:0]        c0_s_axi_wdata;
wire [(C0_C_S_AXI_DATA_WIDTH/8)-1:0]    c0_s_axi_wstrb;
wire                                    c0_s_axi_wlast;
wire                                    c0_s_axi_wvalid;
wire                                    c0_s_axi_wready;
wire                                    c0_s_axi_bready;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_bid;
wire [1:0]                              c0_s_axi_bresp;
wire                                    c0_s_axi_bvalid;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_arid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_araddr;
wire [7:0]                              c0_s_axi_arlen;
wire [2:0]                              c0_s_axi_arsize;
wire [1:0]                              c0_s_axi_arburst;
wire [0:0]                              c0_s_axi_arlock;
wire [3:0]                              c0_s_axi_arcache;
wire [2:0]                              c0_s_axi_arprot;
wire                                    c0_s_axi_arvalid;
wire                                    c0_s_axi_arready;
wire                                    c0_s_axi_rready;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_rid;
wire [C0_C_S_AXI_DATA_WIDTH-1:0]        c0_s_axi_rdata;
wire [1:0]                              c0_s_axi_rresp;
wire                                    c0_s_axi_rlast;
wire                                    c0_s_axi_rvalid;
wire                                    c1_ui_clk_sync_rst;
wire                                    c1_mmcm_locked;
reg                                     c1_aresetn_r;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_awid;
wire [C1_C_S_AXI_ADDR_WIDTH-1:0]        c1_s_axi_awaddr;
wire [7:0]                              c1_s_axi_awlen;
wire [2:0]                              c1_s_axi_awsize;
wire [1:0]                              c1_s_axi_awburst;
wire [0:0]                              c1_s_axi_awlock;
wire [3:0]                              c1_s_axi_awcache;
wire [2:0]                              c1_s_axi_awprot;
wire                                    c1_s_axi_awvalid;
wire                                    c1_s_axi_awready;
wire [C1_C_S_AXI_DATA_WIDTH-1:0]        c1_s_axi_wdata;
wire [(C1_C_S_AXI_DATA_WIDTH/8)-1:0]    c1_s_axi_wstrb;
wire                                    c1_s_axi_wlast;
wire                                    c1_s_axi_wvalid;
wire                                    c1_s_axi_wready;
wire                                    c1_s_axi_bready;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_bid;
wire [1:0]                              c1_s_axi_bresp;
wire                                    c1_s_axi_bvalid;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_arid;
wire [C1_C_S_AXI_ADDR_WIDTH-1:0]        c1_s_axi_araddr;
wire [7:0]                              c1_s_axi_arlen;
wire [2:0]                              c1_s_axi_arsize;
wire [1:0]                              c1_s_axi_arburst;
wire [0:0]                              c1_s_axi_arlock;
wire [3:0]                              c1_s_axi_arcache;
wire [2:0]                              c1_s_axi_arprot;
wire                                    c1_s_axi_arvalid;
wire                                    c1_s_axi_arready;
wire                                    c1_s_axi_rready;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_rid;
wire [C1_C_S_AXI_DATA_WIDTH-1:0]        c1_s_axi_rdata;
wire [1:0]                              c1_s_axi_rresp;
wire                                    c1_s_axi_rlast;
wire                                    c1_s_axi_rvalid;

// Wires from MIG instance outputs
wire                                    c0_app_sr_active;
wire                                    c0_app_ref_ack;
wire                                    c0_app_zq_ack;
wire                                    c0_s_axi_ctrl_awready;
wire                                    c0_s_axi_ctrl_wready;
wire                                    c0_s_axi_ctrl_bvalid;
wire [1:0]                              c0_s_axi_ctrl_bresp;
wire                                    c0_s_axi_ctrl_arready;
wire                                    c0_s_axi_ctrl_rvalid;
wire [31:0]                             c0_s_axi_ctrl_rdata;
wire [1:0]                              c0_s_axi_ctrl_rresp;
wire                                    c0_app_ecc_multiple_err;
wire                                    c1_app_sr_active;
wire                                    c1_app_ref_ack;
wire                                    c1_app_zq_ack;
wire                                    c1_s_axi_ctrl_awready;
wire                                    c1_s_axi_ctrl_wready;
wire                                    c1_s_axi_ctrl_bvalid;
wire [1:0]                              c1_s_axi_ctrl_bresp;
wire                                    c1_s_axi_ctrl_arready;
wire                                    c1_s_axi_ctrl_rvalid;
wire [31:0]                             c1_s_axi_ctrl_rdata;
wire [1:0]                              c1_s_axi_ctrl_rresp;
wire                                    c1_app_ecc_multiple_err;
wire                                    c0_interrupt_dummy; // Dummy wire for unconnected output
wire                                    c1_interrupt_dummy; // Dummy wire for unconnected output

mig_7series_0 u_mig_7series_0 (
  .c0_ddr3_addr                         (c0_ddr3_addr),            
  .c0_ddr3_ba                           (c0_ddr3_ba),              
  .c0_ddr3_cas_n                        (c0_ddr3_cas_n),           
  .c0_ddr3_ck_n                         (c0_ddr3_ck_n),            
  .c0_ddr3_ck_p                         (c0_ddr3_ck_p),            
  .c0_ddr3_cke                          (c0_ddr3_cke),             
  .c0_ddr3_ras_n                        (c0_ddr3_ras_n),           
  .c0_ddr3_reset_n                      (c0_ddr3_reset_n),         
  .c0_ddr3_we_n                         (c0_ddr3_we_n),            
  .c0_ddr3_dq                           (c0_ddr3_dq),              
  .c0_ddr3_dqs_n                        (c0_ddr3_dqs_n),           
  .c0_ddr3_dqs_p                        (c0_ddr3_dqs_p),           
  .c0_init_calib_complete               (c0_init_calib_complete),  
  .c0_ddr3_cs_n                         (c0_ddr3_cs_n),            
  .c0_ddr3_odt                          (c0_ddr3_odt),             
  .c0_ui_clk                            (c0_ui_clk),               
  .c0_ui_clk_sync_rst                   (c0_ui_clk_sync_rst),      
  .c0_mmcm_locked                       (c0_mmcm_locked),          
  .c0_aresetn                           (c0_aresetn_r),            
  .c0_app_sr_req                        (1'b0),                       
  .c0_app_ref_req                       (1'b0),                       
  .c0_app_zq_req                        (1'b0),                       
  .c0_app_sr_active                     (c0_app_sr_active),        
  .c0_app_ref_ack                       (c0_app_ref_ack),          
  .c0_app_zq_ack                        (c0_app_zq_ack),           
  .c0_s_axi_awid                        (c0_s_axi_awid),           
  .c0_s_axi_awaddr                      ({1'b0, c0_s_axi_awaddr[31:0]}),  
  .c0_s_axi_awlen                       (c0_s_axi_awlen),          
  .c0_s_axi_awsize                      (c0_s_axi_awsize),         
  .c0_s_axi_awburst                     (c0_s_axi_awburst),        
  .c0_s_axi_awlock                      (1'b0),                       
  .c0_s_axi_awcache                     (4'b0),                       
  .c0_s_axi_awprot                      (3'b0),                       
  .c0_s_axi_awqos                       (4'b0),                       
  .c0_s_axi_awvalid                     (c0_s_axi_awvalid),        
  .c0_s_axi_awready                     (c0_s_axi_awready),        
  .c0_s_axi_wdata                       (c0_s_axi_wdata),          
  .c0_s_axi_wstrb                       (c0_s_axi_wstrb),          
  .c0_s_axi_wlast                       (c0_s_axi_wlast),          
  .c0_s_axi_wvalid                      (c0_s_axi_wvalid),         
  .c0_s_axi_wready                      (c0_s_axi_wready),         
  .c0_s_axi_bid                         (c0_s_axi_bid),            
  .c0_s_axi_bresp                       (c0_s_axi_bresp),          
  .c0_s_axi_bvalid                      (c0_s_axi_bvalid),         
  .c0_s_axi_bready                      (c0_s_axi_bready),         
  .c0_s_axi_arid                        (c0_s_axi_arid),           
  .c0_s_axi_araddr                      ({1'b0, c0_s_axi_araddr[31:0]}),  
  .c0_s_axi_arlen                       (c0_s_axi_arlen),          
  .c0_s_axi_arsize                      (c0_s_axi_arsize),         
  .c0_s_axi_arburst                     (c0_s_axi_arburst),        
  .c0_s_axi_arlock                      (1'b0),                       
  .c0_s_axi_arcache                     (4'b0),                       
  .c0_s_axi_arprot                      (3'b0),                       
  .c0_s_axi_arqos                       (4'b0),                       
  .c0_s_axi_arvalid                     (c0_s_axi_arvalid),        
  .c0_s_axi_arready                     (c0_s_axi_arready),        
  .c0_s_axi_rid                         (c0_s_axi_rid),            
  .c0_s_axi_rdata                       (c0_s_axi_rdata),          
  .c0_s_axi_rresp                       (c0_s_axi_rresp),          
  .c0_s_axi_rlast                       (c0