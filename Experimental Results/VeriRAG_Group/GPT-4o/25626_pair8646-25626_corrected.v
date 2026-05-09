`timescale 1ns / 1ps
`timescale 1ns / 1ps
module dram_inf
(
input test_i,
input clk156_25,
input reset156_25_n,
input sys_rst,
input				c0_sys_clk_p,
input				c0_sys_clk_n,
input				c1_sys_clk_p,
input				c1_sys_clk_n,
input				clk_ref_p,
input				clk_ref_n,
inout [71:0]       c0_ddr3_dq,
inout [8:0]        c0_ddr3_dqs_n,
inout [8:0]        c0_ddr3_dqs_p,
output [15:0]     c0_ddr3_addr,
output [2:0]      c0_ddr3_ba,
output            c0_ddr3_ras_n,
output            c0_ddr3_cas_n,
output            c0_ddr3_we_n,
output            c0_ddr3_reset_n,
output[1:0]       c0_ddr3_ck_p,
output[1:0]       c0_ddr3_ck_n,
output[1:0]       c0_ddr3_cke,
output[1:0]       c0_ddr3_cs_n,
output[1:0]       c0_ddr3_odt,
output            c0_ui_clk,
output            c0_init_calib_complete,
inout [71:0]      c1_ddr3_dq,
inout [8:0]       c1_ddr3_dqs_n,
inout [8:0]       c1_ddr3_dqs_p,
output [15:0]    c1_ddr3_addr,
output [2:0]     c1_ddr3_ba,
output           c1_ddr3_ras_n,
output           c1_ddr3_cas_n,
output           c1_ddr3_we_n,
output           c1_ddr3_reset_n,
output[1:0]      c1_ddr3_ck_p,
output[1:0]      c1_ddr3_ck_n,
output[1:0]      c1_ddr3_cke,
output[1:0]      c1_ddr3_cs_n,
output[1:0]      c1_ddr3_odt,
output           c1_ui_clk,
output           c1_init_calib_complete,
input           ht_s_axis_read_cmd_tvalid,
output          ht_s_axis_read_cmd_tready,
input[71:0]     ht_s_axis_read_cmd_tdata,
output          ht_m_axis_read_sts_tvalid,
input           ht_m_axis_read_sts_tready,
output[7:0]     ht_m_axis_read_sts_tdata,
output[511:0]    ht_m_axis_read_tdata,
output[63:0]     ht_m_axis_read_tkeep,
output          ht_m_axis_read_tlast,
output          ht_m_axis_read_tvalid,
input           ht_m_axis_read_tready,
input           ht_s_axis_write_cmd_tvalid,
output          ht_s_axis_write_cmd_tready,
input[71:0]     ht_s_axis_write_cmd_tdata,
output          ht_m_axis_write_sts_tvalid,
input           ht_m_axis_write_sts_tready,
output[7:0]     ht_m_axis_write_sts_tdata,
input[511:0]     ht_s_axis_write_tdata,
input[63:0]      ht_s_axis_write_tkeep,
input           ht_s_axis_write_tlast,
input           ht_s_axis_write_tvalid,
output          ht_s_axis_write_tready,
input           vs_s_axis_read_cmd_tvalid,
output          vs_s_axis_read_cmd_tready,
input[71:0]     vs_s_axis_read_cmd_tdata,
output          vs_m_axis_read_sts_tvalid,
input           vs_m_axis_read_sts_tready,
output[7:0]     vs_m_axis_read_sts_tdata,
output[511:0]    vs_m_axis_read_tdata,
output[63:0]     vs_m_axis_read_tkeep,
output          vs_m_axis_read_tlast,
output          vs_m_axis_read_tvalid,
input           vs_m_axis_read_tready,
input           vs_s_axis_write_cmd_tvalid,
output          vs_s_axis_write_cmd_tready,
input[71:0]     vs_s_axis_write_cmd_tdata,
output          vs_m_axis_write_sts_tvalid,
input           vs_m_axis_write_sts_tready,
output[7:0]     vs_m_axis_write_sts_tdata,
input[511:0]     vs_s_axis_write_tdata,
input[63:0]      vs_s_axis_write_tkeep,
input            vs_s_axis_write_tlast,
input            vs_s_axis_write_tvalid,
output           vs_s_axis_write_tready
);
wire[511:0]    c0_m_axis_read_tdata;
wire[63:0]     c0_m_axis_read_tkeep;
wire          c0_m_axis_read_tlast;
wire          c0_m_axis_read_tvalid;
wire           c0_m_axis_read_tready;
wire[511:0]     c0_s_axis_write_tdata;
wire[63:0]      c0_s_axis_write_tkeep;
wire            c0_s_axis_write_tlast;
wire            c0_s_axis_write_tvalid;
wire           c0_s_axis_write_tready;
wire[511:0]    c1_m_axis_read_tdata;
wire[63:0]     c1_m_axis_read_tkeep;
wire          c1_m_axis_read_tlast;
wire          c1_m_axis_read_tvalid;
wire           c1_m_axis_read_tready;
wire[511:0]     c1_s_axis_write_tdata;
wire[63:0]      c1_s_axis_write_tkeep;
wire            c1_s_axis_write_tlast;
wire            c1_s_axis_write_tvalid;
wire           c1_s_axis_write_tready;
wire                   c0_ui_clk_sync_rst;
wire                   c0_mmcm_locked;
reg                    c0_aresetn_r;
wire  [4:0]            c0_s_axi_awid;
wire  [32:0]           c0_s_axi_awaddr;
wire  [7:0]            c0_s_axi_awlen;
wire  [2:0]            c0_s_axi_awsize;
wire  [1:0]            c0_s_axi_awburst;
wire                   c0_s_axi_awvalid;
wire                   c0_s_axi_awready;
wire  [511:0]          c0_s_axi_wdata;
wire  [63:0]           c0_s_axi_wstrb;
wire                   c0_s_axi_wlast;
wire                   c0_s_axi_wvalid;
wire                   c0_s_axi_wready;
wire [4:0]             c0_s_axi_bid;
wire [1:0]             c0_s_axi_bresp;
wire                   c0_s_axi_bvalid;
wire                   c0_s_axi_bready;
wire  [4:0]           c0_s_axi_arid;
wire  [32:0]          c0_s_axi_araddr;
wire  [7:0]           c0_s_axi_arlen;
wire  [2:0]           c0_s_axi_arsize;
wire  [1:0]           c0_s_axi_arburst;
wire                  c0_s_axi_arvalid;
wire                  c0_s_axi_arready;
wire [4:0]       c0_s_axi_rid;
wire [511:0]     c0_s_axi_rdata;
wire [1:0]       c0_s_axi_rresp;
wire             c0_s_axi_rlast;
wire             c0_s_axi_rvalid;
wire             c0_s_axi_rready;
wire             c1_ui_clk_sync_rst;
wire             c1_mmcm_locked;
reg              c1_aresetn_r;
wire [4:0]      c1_s_axi_awid;
wire [32:0]     c1_s_axi_awaddr;
wire [7:0]      c1_s_axi_awlen;
wire [2:0]      c1_s_axi_awsize;
wire [1:0]      c1_s_axi_awburst;
wire            c1_s_axi_awvalid;
wire            c1_s_axi_awready;
wire [511:0]    c1_s_axi_wdata;
wire [63:0]     c1_s_axi_wstrb;
wire            c1_s_axi_wlast;
wire            c1_s_axi_wvalid;
wire            c1_s_axi_wready;
wire [4:0]      c1_s_axi_bid;
wire [1:0]      c1_s_axi_bresp;
wire            c1_s_axi_bvalid;
wire            c1_s_axi_bready;
wire [4:0]      c1_s_axi_arid;
wire [32:0]     c1_s_axi_araddr;
wire [7:0]      c1_s_axi_arlen;
wire [2:0]      c1_s_axi_arsize;
wire [1:0]      c1_s_axi_arburst;
wire            c1_s_axi_arvalid;
wire            c1_s_axi_arready;
wire [4:0]      c1_s_axi_rid;
wire [511:0]    c1_s_axi_rdata;
wire [1:0]      c1_s_axi_rresp;
wire            c1_s_axi_rlast;
wire            c1_s_axi_rvalid;
wire            c1_s_axi_rready;
wire c0_test_clk, c1_test_clk;
assign c0_test_clk = test_i ? clk156_25 : c0_ui_clk;
assign c1_test_clk = test_i ? clk156_25 : c1_ui_clk;
always @(posedge c0_ui_clk)
    c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;
always @(posedge c1_ui_clk)
    c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;
assign c0_s_axi_awaddr[32] = 1'b0;
assign c0_s_axi_araddr[32] = 1'b0;
assign c1_s_axi_awaddr[32] = 1'b0;
assign c1_s_axi_araddr[32] = 1'b0;
axi_datamover_0 ht2dram_data_mover (
  .m_axi_mm2s_aclk(c0_test_clk),                        
  .m_axi_mm2s_aresetn(c0_aresetn_r),                  
  .mm2s_err(),                                      
  .m_axis_mm2s_cmdsts_aclk(clk156_25),        
  .m_axis_mm2s_cmdsts_aresetn(reset156_25_n),  
  .s_axis_mm2s_cmd_tvalid(ht_s_axis_read_cmd_tvalid),          
  .s_axis_mm2s_cmd_tready(ht_s_axis_read_cmd_tready),          
  .s_axis_mm2s_cmd_tdata(ht_s_axis_read_cmd_tdata),            
  .m_axis_mm2s_sts_tvalid(ht_m_axis_read_sts_tvalid),          
  .m_axis_mm2s_sts_tready(ht_m_axis_read_sts_tready),          
  .m_axis_mm2s_sts_tdata(ht_m_axis_read_sts_tdata),            
  .m_axis_mm2s_sts_tkeep(),            
  .m_axis_mm2s_sts_tlast(),            
  .m_axi_mm2s_arid(c0_s_axi_arid),                        
  .m_axi_mm2s_araddr(c0_s_axi_araddr[31:0]),                    
  .m_axi_mm2s_arlen(c0_s_axi_arlen),                      
  .m_axi_mm2s_arsize(c0_s_axi_arsize),                    
  .m_axi_mm2s_arburst(c0_s_axi_arburst),                  
  .m_axi_mm2s_arprot(),                    
  .m_axi_mm2s_arcache(),                  
  .m_axi_mm2s_aruser(),                    
  .m_axi_mm2s_arvalid(c0_s_axi_arvalid),                  
  .m_axi_mm2s_arready(c0_s_axi_arready),                  
  .m_axi_mm2s_rdata(c0_s_axi_rdata),                      
  .m_axi_mm2s_rresp(c0_s_axi_rresp),                      
  .m_axi_mm2s_rlast(c0_s_axi_rlast),                      
  .m_axi_mm2s_rvalid(c0_s_axi_rvalid),                    
  .m_axi_mm2s_rready(c0_s_axi_rready),                    
  .m_axis_mm2s_tdata(c0_m_axis_read_tdata),                    
  .m_axis_mm2s_tkeep(c0_m_axis_read_tkeep),                    
  .m_axis_mm2s_tlast(c0_m_axis_read_tlast),                    
  .m_axis_mm2s_tvalid(c0_m_axis_read_tvalid),                  
  .m_axis_mm2s_tready(c0_m_axis_read_tready),                  
  .m_axi_s2mm_aclk(c0_test_clk),                        
  .m_axi_s2mm_aresetn(c0_aresetn_r),                  
  .s2mm_err(),                                      
  .m_axis_s2mm_cmdsts_awclk(clk156_25),      
  .m_axis_s2mm_cmdsts_aresetn(reset156_25_n),  
  .s_axis_s2mm_cmd_tvalid(ht_s_axis_write_cmd_tvalid),          
  .s_axis_s2mm_cmd_tready(ht_s_axis_write_cmd_tready),          
  .s_axis_s2mm_cmd_tdata(ht_s_axis_write_cmd_tdata),            
  .m_axis_s2mm_sts_tvalid(ht_m_axis_write_sts_tvalid),          
  .m_axis_s2mm_sts_tready(ht_m_axis_write_sts_tready),          
  .m_axis_s2mm_sts_tdata(ht_m_axis_write_sts_tdata),            
  .m_axis_s2mm_sts_tkeep(),            
  .m_axis_s2mm_sts_tlast(),            
  .m_axi_s2mm_awid(c0_s_axi_awid),                        
  .m_axi_s2mm_awaddr(c0_s_axi_awaddr[31:0]),                    
  .m_axi_s2mm_awlen(c0_s_axi_awlen),                      
  .m_axi_s2mm_awsize(c0_s_axi_awsize),                    
  .m_axi_s2mm_awburst(c0_s_axi_awburst),                  
  .m_axi_s2mm_awprot(),                    
  .m_axi_s2mm_awcache(),                  
  .m_axi_s2mm_awuser(),                    
  .m_axi_s2mm_awvalid(c0_s_axi_awvalid),                  
  .m_axi_s2mm_awready(c0_s_axi_awready),                  
  .m_axi_s2mm_wdata(c0_s_axi_wdata),                      
  .m_axi_s2mm_wstrb(c0_s_axi_wstrb),                      
  .m_axi_s2mm_wlast(c0_s_axi_wlast),                      
  .m_axi_s2mm_wvalid(c0_s_axi_wvalid),                    
  .m_axi_s2mm_wready(c0_s_axi_wready),                    
  .m_axi_s2mm_bresp(c0_s_axi_bresp),                      
  .m_axi_s2mm_bvalid(c0_s_axi_bvalid),                    
  .m_axi_s2mm_bready(c0_s_axi_bready),                    
  .s_axis_s2mm_tdata(c0_s_axis_write_tdata),                    
  .s_axis_s2mm_tkeep(c0_s_axis_write_tkeep),                    
  .s_axis_s2mm_tlast(c0_s_axis_write_tlast),                    
  .s_axis_s2mm_tvalid(c0_s_axis_write_tvalid),                  
  .s_axis_s2mm_tready(c0_s_axis_write_tready)                  
);
axis_clock_converter_512 ht_c0_read_data_conv (
  .s_axis_aresetn(c0_aresetn_r),  
  .m_axis_aresetn(reset156_25_n),  
  .s_axis_aclk(c0_test_clk),        
  .s_axis_tvalid(c0_m_axis_read_tvalid),    
  .s_axis_tready(c0_m_axis_read_tready),    
  .s_axis_tdata(c0_m_axis_read_tdata),      
  .s_axis_tkeep(c0_m_axis_read_tkeep),      
  .s_axis_tlast(c0_m_axis_read_tlast),      
  .m_axis_aclk(clk156_25),        
  .m_axis_tvalid(ht_m_axis_read_tvalid),    
  .m_axis_tready(ht_m_axis_read_tready),    
  .m_axis_tdata(ht_m_axis_read_tdata),      
  .m_axis_tkeep(ht_m_axis_read_tkeep),      
  .m_axis_tlast(ht_m_axis_read_tlast)      
);
axis_clock_converter_512 ht_c0_write_data_conv(
  .s_axis_aresetn(reset156_25_n),  
  .m_axis_aresetn(c0_aresetn_r),  
  .s_axis_aclk(clk156_25),        
  .s_axis_tvalid(ht_s_axis_write_tvalid),    
  .s_axis_tready(ht_s_axis_write_tready),    
  .s_axis_tdata(ht_s_axis_write_tdata),      
  .s_axis_tkeep(ht_s_axis_write_tkeep),      
  .s_axis_tlast(ht_s_axis_write_tlast),      
  .m_axis_aclk(c0_test_clk),        
  .m_axis_tvalid(c0_s_axis_write_tvalid),    
  .m_axis_tready(c0_s_axis_write_tready),    
  .m_axis_tdata(c0_s_axis_write_tdata),      
  .m_axis_tkeep(c0_s_axis_write_tkeep),      
  .m_axis_tlast(c0_s_axis_write_tlast)      
);
axi_datamover_0 vs2dram_data_mover (
  .m_axi_mm2s_aclk(c1_test_clk),                        
  .m_axi_mm2s_aresetn(c1_aresetn_r),                  
  .mm2s_err(),                                      
  .m_axis_mm2s_cmdsts_aclk(clk156_25),        
  .m_axis_mm2s_cmdsts_aresetn(reset156_25_n),  
  .s_axis_mm2s_cmd_tvalid(vs_s_axis_read_cmd_tvalid),          
  .s_axis_mm2s_cmd_tready(vs_s_axis_read_cmd_tready),          
  .s_axis_mm2s_cmd_tdata(vs_s_axis_read_cmd_tdata),            
  .m_axis_mm2s_sts_tvalid(vs_m_axis_read_sts_tvalid),          
  .m_axis_mm2s_sts_tready(vs_m_axis_read_sts_tready),          
  .m_axis_mm2s_sts_tdata(vs_m_axis_read_sts_tdata),            
  .m_axis_mm2s_sts_tkeep(),            
  .m_axis_mm2s_sts_tlast(),            
  .m_axi_mm2s_arid(c1_s_axi_arid),                        
  .m_axi_mm2s_araddr(c1_s_axi_araddr[31:0]),                    
  .m_axi_mm2s_arlen(c1_s_axi_arlen),                      
  .m_axi_mm2s_arsize(c1_s_axi_arsize),                    
  .m_axi_mm2s_arburst(c1_s_axi_arburst),                  
  .m_axi_mm2s_arprot(),                    
  .m_axi_mm2s_arcache(),                  
  .m_axi_mm2s_aruser(),                    
  .m_axi_mm2s_arvalid(c1_s_axi_arvalid),                  
  .m_axi_mm2s_arready(c1_s_axi_arready),                  
  .m_axi_mm2s_rdata(c1_s_axi_rdata),                      
  .m_axi_mm2s_rresp(c1_s_axi_rresp),                      
  .m_axi_mm2s_rlast(c1_s_axi_rlast),                      
  .m_axi_mm2s_rvalid(c1_s_axi_rvalid),                    
  .m_axi_mm2s_rready(c1_s_axi_rready),                    
  .m_axis_mm2s_tdata(c1_m_axis_read_tdata),                    
  .m_axis_mm2s_tkeep(c1_m_axis_read_tkeep),                    
  .m_axis_mm2s_tlast(c1_m_axis_read_tlast),                    
  .m_axis_mm2s_tvalid(c1_m_axis_read_tvalid),                  
  .m_axis_mm2s_tready(c1_m_axis_read_tready),                  
  .m_axi_s2mm_aclk(c1_test_clk),                        
  .m_axi_s2mm_aresetn(c1_aresetn_r),                  
  .s2mm_err(),                                      
  .m_axis_s2mm_cmdsts_awclk(clk156_25),      
  .m_axis_s2mm_cmdsts_aresetn(reset156_25_n),  
  .s_axis_s2mm_cmd_tvalid(vs_s_axis_write_cmd_tvalid),          
  .s_axis_s2mm_cmd_tready(vs_s_axis_write_cmd_tready),          
  .s_axis_s2mm_cmd_tdata(vs_s_axis_write_cmd_tdata),            
  .m_axis_s2mm_sts_tvalid(vs_m_axis_write_sts_tvalid),          
  .m_axis_s2mm_sts_tready(vs_m_axis_write_sts_tready),          
  .m_axis_s2mm_sts_tdata(vs_m_axis_write_sts_tdata),            
  .m_axis_s2mm_sts_tkeep(),            
  .m_axis_s2mm_sts_tlast(),            
  .m_axi_s2mm_awid(c1_s_axi_awid),                        
  .m_axi_s2mm_awaddr(c1_s_axi_awaddr[31:0]),                    
  .m_axi_s2mm_awlen(c1_s_axi_awlen),                      
  .m_axi_s2mm_awsize(c1_s_axi_awsize),                    
  .m_axi_s2mm_awburst(c1_s_axi_awburst),                  
  .m_axi_s2mm_awprot(),                    
  .m_axi_s2mm_awcache(),                  
  .m_axi_s2mm_awuser(),                    
  .m_axi_s2mm_awvalid(c1_s_axi_awvalid),                  
  .m_axi_s2mm_awready(c1_s_axi_awready),                  
  .m_axi_s2mm_wdata(c1_s_axi_wdata),                      
  .m_axi_s2mm_wstrb(c1_s_axi_wstrb),                      
  .m_axi_s2mm_wlast(c1_s_axi_wlast),                      
  .m_axi_s2mm_wvalid(c1_s_axi_wvalid),                    
  .m_axi_s2mm_wready(c1_s_axi_wready),                    
  .m_axi_s2mm_bresp(c1_s_axi_bresp),                      
  .m_axi_s2mm_bvalid(c1_s_axi_bvalid),                    
  .m_axi_s2mm_bready(c1_s_axi_bready),                    
  .s_axis_s2mm_tdata(c1_s_axis_write_tdata),                    
  .s_axis_s2mm_tkeep(c1_s_axis_write_tkeep),                    
  .s_axis_s2mm_tlast(c1_s_axis_write_tlast),                    
  .s_axis_s2mm_tvalid(c1_s_axis_write_tvalid),                  
  .s_axis_s2mm_tready(c1_s_axis_write_tready)                  
);
axis_clock_converter_512 vs_c1_read_data_conv (
  .s_axis_aresetn(c1_aresetn_r),  
  .m_axis_aresetn(reset156_25_n),  
  .s_axis_aclk(c1_test_clk),        
  .s_axis_tvalid(c1_m_axis_read_tvalid),    
  .s_axis_tready(c1_m_axis_read_tready),    
  .s_axis_tdata(c1_m_axis_read_tdata),      
  .s_axis_tkeep(c1_m_axis_read_tkeep),      
  .s_axis_tlast(c1_m_axis_read_tlast),      
  .m_axis_aclk(clk156_25),        
  .m_axis_tvalid(vs_m_axis_read_tvalid),    
  .m_axis_tready(vs_m_axis_read_tready),    
  .m_axis_tdata(vs_m_axis_read_tdata),      
  .m_axis_tkeep(vs_m_axis_read_tkeep),      
  .m_axis_tlast(vs_m_axis_read_tlast)      
);
axis_clock_converter_512 vs_c1_write_data_conv(
  .s_axis_aresetn(reset156_25_n),  
  .m_axis_aresetn(c1_aresetn_r),  
  .s_axis_aclk(clk156_25),        
  .s_axis_tvalid(vs_s_axis_write_tvalid),    
  .s_axis_tready(vs_s_axis_write_tready),    
  .s_axis_tdata(vs_s_axis_write_tdata),      
  .s_axis_tkeep(vs_s_axis_write_tkeep),      
  .s_axis_tlast(vs_s_axis_write_tlast),      
  .m_axis_aclk(c1_test_clk),        
  .m_axis_tvalid(c1_s_axis_write_tvalid),    
  .m_axis_tready(c1_s_axis_write_tready),    
  .m_axis_tdata(c1_s_axis_write_tdata),      
  .m_axis_tkeep(c1_s_axis_write_tkeep),      
  .m_axis_tlast(c1_s_axis_write_tlast)      
);
mig_7series_0 mig_dual_inst(
    .c0_ddr3_addr                      (c0_ddr3_addr),  
    .c0_ddr3_ba                        (c0_ddr3_ba),  
    .c0_ddr3_cas_n                     (c0_ddr3_cas_n),  
    .c0_ddr3_ck_n                      (c0_ddr3_ck_n),  
    .c0_ddr3_ck_p                      (c0_ddr3_ck_p),  
    .c0_ddr3_cke                       (c0_ddr3_cke),  
    .c0_ddr3_ras_n                     (c0_ddr3_ras_n),  
    .c0_ddr3_reset_n                   (c0_ddr3_reset_n),  
    .c0_ddr3_we_n                      (c0_ddr3_we_n),  
    .c0_ddr3_dq                        (c0_ddr3_dq),  
    .c0_ddr3_dqs_n                     (c0_ddr3_dqs_n),  
    .c0_ddr3_dqs_p                     (c0_ddr3_dqs_p),  
    .c0_init_calib_complete            (c0_init_calib_complete),  
	.c0_ddr3_cs_n                      (c0_ddr3_cs_n),  
    .c0_ddr3_odt                       (c0_ddr3_odt),  
    .c0_ui_clk                         (c0_ui_clk),  
    .c0_ui_clk_sync_rst                (c0_ui_clk_sync_rst),  
    .c0_mmcm_locked                    (c0_mmcm_locked),  
    .c0_aresetn                        (c0_aresetn_r),  
    .c0_app_sr_req                     (1'b0),  
    .c0_app_ref_req                    (1'b0),  
    .c0_app_zq_req                     (1'b0),  
    .c0_app_sr_active                  (),  
    .c0_app_ref_ack                    (),  
    .c0_app_zq_ack                     (),  
    .c0_s_axi_awid                     (c0_s_axi_awid),  
    .c0_s_axi_awaddr                   (c0_s_axi_awaddr),  
    .c0_s_axi_awlen                    (c0_s_axi_awlen),  
    .c0_s_axi_awsize                   (c0_s_axi_awsize),  
    .c0_s_axi_awburst                  (c0_s_axi_awburst),  
    .c0_s_axi_awlock                   (1'b0),  
    .c0_s_axi_awcache                  (4'b0),  
    .c0_s_axi_awprot                   (3'b0),  
    .c0_s_axi_awqos                    (4'b0),  
    .c0_s_axi_awvalid                  (c0_s_axi_awvalid),  
    .c0_s_axi_awready                  (c0_s_axi_awready),  
    .c0_s_axi_wdata                    (c0_s_axi_wdata),  
    .c0_s_axi_wstrb                    (c0_s_axi_wstrb),  
    .c0_s_axi_wlast                    (c0_s_axi_wlast),  
    .c0_s_axi_wvalid                   (c0_s_axi_wvalid),  
    .c0_s_axi_wready                   (c0_s_axi_wready),  
    .c0_s_axi_bid                      (c0_s_axi_bid),  
    .c0_s_axi_bresp                    (c0_s_axi_bresp),  
    .c0_s_axi_bvalid                   (c0_s_axi_bvalid),  
    .c0_s_axi_bready                   (c0_s_axi_bready),  
    .c0_s_axi_arid                     (c0_s_axi_arid),  
    .c0_s_axi_araddr                   (c0_s_axi_araddr),  
    .c0_s_axi_arlen                    (c0_s_axi_arlen),  
    .c0_s_axi_arsize                   (c0_s_axi_arsize),  
    .c0_s_axi_arburst                  (c0_s_axi_arburst),  
    .c0_s_axi_arlock                   (1'b0),  
    .c0_s_axi_arcache                  (4'b0),  
    .c0_s_axi_arprot                   (3'b0),  
    .c0_s_axi_arqos                    (4'b0),  
    .c0_s_axi_arvalid                  (c0_s_axi_arvalid),  
    .c0_s_axi_arready                  (c0_s_axi_arready),  
    .c0_s_axi_rid                      (c0_s_axi_rid),  
    .c0_s_axi_rdata                    (c0_s_axi_rdata),  
    .c0_s_axi_rresp                    (c0_s_axi_rresp),  
    .c0_s_axi_rlast                    (c0_s_axi_rlast),  
    .c0_s_axi_rvalid                   (c0_s_axi_rvalid),  
    .c0_s_axi_rready                   (c0_s_axi_rready),  
    .c0_s_axi_ctrl_awvalid             (1'b0),  
    .c0_s_axi_ctrl_awready             (),  
    .c0_s_axi_ctrl_awaddr              (32'b0),  
    .c0_s_axi_ctrl_wvalid              (1'b0),  
    .c0_s_axi_ctrl_wready              (),  
    .c0_s_axi_ctrl_wdata               (32'b0),  
    .c0_s_axi_ctrl_bvalid              (),  
    .c0_s_axi_ctrl_bready              (1'b1),  
    .c0_s_axi_ctrl_bresp               (),  
    .c0_s_axi_ctrl_arvalid             (1'b0),  
    .c0_s_axi_ctrl_arready             (),  
    .c0_s_axi_ctrl_araddr              (32'b0),  
    .c0_s_axi_ctrl_rvalid              (),  
    .c0_s_axi_ctrl_rready              (1'b1),  
    .c0_s_axi_ctrl_rdata               (),  
    .c0_s_axi_ctrl_rresp               (),  
    .c0_interrupt                      (),  
	.c0_app_ecc_multiple_err           (),  
    .c0_sys_clk_p                       (c0_sys_clk_p),  
    .c0_sys_clk_n                       (c0_sys_clk_n),  
    .clk_ref_p                      (clk_ref_p),  
    .clk_ref_n                      (clk_ref_n),  
    .c1_ddr3_addr                      (c1_ddr3_addr),  
    .c1_ddr3_ba                        (c1_ddr3_ba),  
    .c1_ddr3_cas_n                     (c1_ddr3_cas_n),  
    .c1_ddr3_ck_n                      (c1_ddr3_ck_n),  
    .c1_ddr3_ck_p                      (c1_ddr3_ck_p),  
    .c1_ddr3_cke                       (c1_ddr3_cke),  
    .c1_ddr3_ras_n                     (c1_ddr3_ras_n),  
    .c1_ddr3_reset_n                   (c1_ddr3_reset_n),  
    .c1_ddr3_we_n                      (c1_ddr3_we_n),  
    .c1_ddr3_dq                        (c1_ddr3_dq),  
    .c1_ddr3_dqs_n                     (c1_ddr3_dqs_n),  
    .c1_ddr3_dqs_p                     (c1_ddr3_dqs_p),  
    .c1_init_calib_complete            (c1_init_calib_complete),  
	.c1_ddr3_cs_n                      (c1_ddr3_cs_n),  
    .c1_ddr3_odt                       (c1_ddr3_odt),  
    .c1_ui_clk                         (c1_ui_clk),  
    .c1_ui_clk_sync_rst                (c1_ui_clk_sync_rst),  
    .c1_mmcm_locked                    (c1_mmcm_locked),  
    .c1_aresetn                        (c1_aresetn_r),  
    .c1_app_sr_req                     (1'b0),  
    .c1_app_ref_req                    (1'b0),  
    .c1_app_zq_req                     (1'b0),  
    .c1_app_sr_active                  (),  
    .c1_app_ref_ack                    (),  
    .c1_app_zq_ack                     (),  
    .c1_s_axi_awid                     (c1_s_axi_awid),  
    .c1_s_axi_awaddr                   (c1_s_axi_awaddr),  
    .c1_s_axi_awlen                    (c1_s_axi_awlen),  
    .c1_s_axi_awsize                   (c1_s_axi_awsize),  
    .c1_s_axi_awburst                  (c1_s_axi_awburst),  
    .c1_s_axi_awlock                   (1'b0),  
    .c1_s_axi_awcache                  (4'b0),  
    .c1_s_axi_awprot                   (3'b0),  
    .c1_s_axi_awqos                    (4'b0),  
    .c1_s_axi_awvalid                  (c1_s_axi_awvalid),  
    .c1_s_axi_awready                  (c1_s_axi_awready),  
    .c1_s_axi_wdata                    (c1_s_axi_wdata),  
    .c1_s_axi_wstrb                    (c1_s_axi_wstrb),  
    .c1_s_axi_wlast                    (c1_s_axi_wlast),  
    .c1_s_axi_wvalid                   (c1_s_axi_wvalid),  
    .c1_s_axi_wready                   (c1_s_axi_wready),  
    .c1_s_axi_bid                      (c1_s_axi_bid),  
    .c1_s_axi_bresp                    (c1_s_axi_bresp),  
    .c1_s_axi_bvalid                   (c1_s_axi_bvalid),  
    .c1_s_axi_bready                   (c1_s_axi_bready),  
    .c1_s_axi_arid                     (c1_s_axi_arid),  
    .c1_s_axi_araddr                   (c1_s_axi_araddr),  
    .c1_s_axi_arlen                    (c1_s_axi_arlen),  
    .c1_s_axi_arsize                   (c1_s_axi_arsize),  
    .c1_s_axi_arburst                  (c1_s_axi_arburst),  
    .c1_s_axi_arlock                   (1'b0),  
    .c1_s_axi_arcache                  (4'b0),  
    .c1_s_axi_arprot                   (3'b0),  
    .c1_s_axi_arqos                    (4'b0),  
    .c1_s_axi_arvalid                  (c1_s_axi_arvalid),  
    .c1_s_axi_arready                  (c1_s_axi_arready),  
    .c1_s_axi_rid                      (c1_s_axi_rid),  
    .c1_s_axi_rdata                    (c1_s_axi_rdata),  
    .c1_s_axi_rresp                    (c1_s_axi_rresp),  
    .c1_s_axi_rlast                    (c1_s_axi_rlast),  
    .c1_s_axi_rvalid                   (c1_s_axi_rvalid),  
    .c1_s_axi_rready                   (c1_s_axi_rready),  
    .c1_s_axi_ctrl_awvalid             (1'b0),  
    .c1_s_axi_ctrl_awready             (),  
    .c1_s_axi_ctrl_awaddr              (32'b0),  
    .c1_s_axi_ctrl_wvalid              (1'b0),  
    .c1_s_axi_ctrl_wready              (),  
    .c1_s_axi_ctrl_wdata               (32'b0),  
    .c1_s_axi_ctrl_bvalid              (),  
    .c1_s_axi_ctrl_bready              (1'b1),  
    .c1_s_axi_ctrl_bresp               (),  
    .c1_s_axi_ctrl_arvalid             (1'b0),  
    .c1_s_axi_ctrl_arready             (),  
    .c1_s_axi_ctrl_araddr              (32'b0),  
    .c1_s_axi_ctrl_rvalid              (),  
    .c1_s_axi_ctrl_rready              (1'b1),  
    .c1_s_axi_ctrl_rdata               (),  
    .c1_s_axi_ctrl_rresp               (),  
    .c1_interrupt                      (),  
	.c1_app_ecc_multiple_err           (),  
    .c1_sys_clk_p                       (c1_sys_clk_p),  
    .c1_sys_clk_n                       (c1_sys_clk_n),  
    .sys_rst                        (sys_rst) 
);
endmodule