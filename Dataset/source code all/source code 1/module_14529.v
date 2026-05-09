`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module lpddr2_cntrlr_p0_acv_hard_memphy (
	global_reset_n,
	soft_reset_n,
	ctl_reset_n,
	ctl_reset_export_n,
    afi_reset_n,
	pll_locked,
	oct_ctl_rs_value,
	oct_ctl_rt_value,
	afi_addr,
	afi_ba,
	afi_cke,
	afi_cs_n,
	afi_ras_n,
	afi_we_n,
	afi_cas_n,
	afi_rst_n,
	afi_odt,
	afi_mem_clk_disable,
	afi_dqs_burst,
	afi_wdata_valid,
	afi_wdata,
	afi_dm,
	afi_rdata,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata_valid,
	afi_wlat,
	afi_rlat,
	afi_cal_success,
	afi_cal_fail,
	avl_read,
	avl_write,
	avl_address,
	avl_writedata,
	avl_waitrequest,
	avl_readdata,
	cfg_addlat,               
	cfg_bankaddrwidth,
	cfg_caswrlat,
	cfg_coladdrwidth,
	cfg_csaddrwidth,
	cfg_devicewidth,
	cfg_dramconfig,
	cfg_interfacewidth,
	cfg_rowaddrwidth,
	cfg_tcl,
	cfg_tmrd,
	cfg_trefi,
	cfg_trfc,
	cfg_twr,
	io_intaddrdout,
	io_intbadout,
	io_intcasndout,
	io_intckdout,
	io_intckedout,
	io_intckndout,
	io_intcsndout,
	io_intdmdout,
	io_intdqdin,
	io_intdqdout,
	io_intdqoe,
	io_intdqsbdout,
	io_intdqsboe,
	io_intdqsdout,
	io_intdqslogicdqsena,
	io_intdqslogicfiforeset,
	io_intdqslogicincrdataen,
	io_intdqslogicincwrptr,
	io_intdqslogicoct,
	io_intdqslogicrdatavalid,
	io_intdqslogicreadlatency,
	io_intdqsoe,
	io_intodtdout,
	io_intrasndout,
	io_intresetndout,
	io_intwendout,
	io_intafirlat,
	io_intafiwlat,
	io_intaficalfail,
	io_intaficalsuccess,
	mem_a,
	mem_ba,
	mem_cs_n,
	mem_cke,
	mem_odt,
	mem_we_n,
	mem_ras_n,
	mem_cas_n,
	mem_reset_n,
	mem_dq,
	mem_dm,
	mem_ck,
	mem_ck_n,
	mem_dqs,
	mem_dqs_n,
	reset_n_scc_clk,
	reset_n_avl_clk,
	scc_data,
	scc_dqs_ena,
	scc_dqs_io_ena,
	scc_dq_ena,
	scc_dm_ena,
	scc_upd,
	capture_strobe_tracking,
	phy_clk,
	ctl_clk,
	phy_reset_n,
	pll_afi_clk,
	pll_afi_half_clk,
	pll_addr_cmd_clk,
	pll_mem_clk,
	pll_mem_phy_clk,
	pll_afi_phy_clk,
	pll_avl_phy_clk,
	pll_write_clk,
	pll_write_clk_pre_phy_clk,
	pll_dqs_ena_clk,
	seq_clk,                    
	pll_avl_clk,
	pll_config_clk,
	dll_clk,
	dll_pll_locked,
	dll_phy_delayctrl
);
parameter DEVICE_FAMILY = "";
parameter IS_HHP_HPS = "false";
parameter OCT_SERIES_TERM_CONTROL_WIDTH   = "";
parameter OCT_PARALLEL_TERM_CONTROL_WIDTH = "";
parameter MEM_ADDRESS_WIDTH     = "";
parameter MEM_BANK_WIDTH        = "";
parameter MEM_IF_CS_WIDTH = "";
parameter MEM_CLK_EN_WIDTH      = "";
parameter MEM_CK_WIDTH          = "";
parameter MEM_ODT_WIDTH         = "";
parameter MEM_DQS_WIDTH         = "";
parameter MEM_DM_WIDTH          = "";
parameter MEM_CONTROL_WIDTH     = "";
parameter MEM_DQ_WIDTH          = "";
parameter MEM_READ_DQS_WIDTH    = "";
parameter MEM_WRITE_DQS_WIDTH   = "";
parameter DLL_DELAY_CTRL_WIDTH  = "";
parameter MR3_DS                = "";
parameter TB_PROTOCOL        = "";
parameter TB_MEM_CLK_FREQ    = "";
parameter TB_RATE            = "";
parameter TB_MEM_DQ_WIDTH    = "";
parameter TB_MEM_DQS_WIDTH   = "";
parameter TB_PLL_DLL_MASTER  = "";
parameter FAST_SIM_MODEL = "";
parameter FAST_SIM_CALIBRATION = "";
parameter CALIB_REG_WIDTH = "";
parameter AC_ROM_INIT_FILE_NAME = "";
parameter INST_ROM_INIT_FILE_NAME = "";
localparam NUM_AFI_RESET = 4;
localparam ADC_PHASE_SETTING = 0;
localparam ADC_INVERT_PHASE = "true";
input	global_reset_n;		
input	soft_reset_n;		
input	pll_locked;			
output	ctl_reset_n;		
output	ctl_reset_export_n;		
output	afi_reset_n;		
input   [OCT_SERIES_TERM_CONTROL_WIDTH-1:0]    oct_ctl_rs_value;
input   [OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0]  oct_ctl_rt_value;
input  [19:0]  afi_addr;
input   [2:0]  afi_ba;
input   [1:0]  afi_cke;
input   [1:0]  afi_cs_n;
input   [0:0]  afi_cas_n;
input   [1:0]  afi_odt;
input   [0:0]  afi_ras_n;
input   [0:0]  afi_we_n;
input   [0:0]  afi_rst_n;
input   [0:0]  afi_mem_clk_disable;
input   [4:0]  afi_dqs_burst;
output  [3:0]  afi_wlat;
output  [4:0]  afi_rlat;
input  [79:0]  afi_wdata;              
input   [4:0]  afi_wdata_valid;    	
input   [9:0]  afi_dm;             
output [79:0]  afi_rdata;              
input   [4:0]  afi_rdata_en;       
input   [4:0]  afi_rdata_en_full;  
output  [0:0]  afi_rdata_valid;    
output                                afi_cal_success;    
output                                afi_cal_fail;       
input   [15:0]  avl_address; 
input           avl_read;
output  [31:0]  avl_readdata;
output          avl_waitrequest;
input           avl_write;
input   [31:0]  avl_writedata;
input    [7:0]  cfg_addlat;
input    [7:0]  cfg_bankaddrwidth;
input    [7:0]  cfg_caswrlat;
input    [7:0]  cfg_coladdrwidth;
input    [7:0]  cfg_csaddrwidth;
input    [7:0]  cfg_devicewidth;
input   [23:0]  cfg_dramconfig;
input    [7:0]  cfg_interfacewidth;
input    [7:0]  cfg_rowaddrwidth;
input    [7:0]  cfg_tcl;
input    [7:0]  cfg_tmrd;
input   [15:0]  cfg_trefi;
input    [7:0]  cfg_trfc;
input    [7:0]  cfg_twr;
input   [63:0]  io_intaddrdout;
input   [11:0]  io_intbadout;
input    [3:0]  io_intcasndout;
input    [3:0]  io_intckdout;
input    [7:0]  io_intckedout;
input    [3:0]  io_intckndout;
input    [7:0]  io_intcsndout;
input   [19:0]  io_intdmdout;
output [179:0]  io_intdqdin;
input  [179:0]  io_intdqdout;
input   [89:0]  io_intdqoe;
input   [19:0]  io_intdqsbdout;
input    [9:0]  io_intdqsboe;
input   [19:0]  io_intdqsdout;
input    [9:0]  io_intdqslogicdqsena;
input    [4:0]  io_intdqslogicfiforeset;
input    [9:0]  io_intdqslogicincrdataen;
input    [9:0]  io_intdqslogicincwrptr;
input    [9:0]  io_intdqslogicoct;
output   [4:0]  io_intdqslogicrdatavalid;
input   [24:0]  io_intdqslogicreadlatency;
input    [9:0]  io_intdqsoe;
input    [7:0]  io_intodtdout;
input    [3:0]  io_intrasndout;
input    [3:0]  io_intresetndout;
input    [3:0]  io_intwendout;
output   [4:0]  io_intafirlat;
output   [3:0]  io_intafiwlat;
output          io_intaficalfail;  
output          io_intaficalsuccess;
output  [MEM_ADDRESS_WIDTH-1:0]      mem_a;
output  [MEM_BANK_WIDTH-1:0]         mem_ba;
output  [MEM_IF_CS_WIDTH-1:0]  mem_cs_n;
output  [MEM_CLK_EN_WIDTH-1:0]       mem_cke;
output  [MEM_ODT_WIDTH-1:0]          mem_odt;
output  [MEM_CONTROL_WIDTH-1:0]      mem_we_n;
output  [MEM_CONTROL_WIDTH-1:0]      mem_ras_n;
output  [MEM_CONTROL_WIDTH-1:0]      mem_cas_n;
output                               mem_reset_n;
inout   [MEM_DQ_WIDTH-1:0]           mem_dq;
output  [MEM_DM_WIDTH-1:0]           mem_dm;
output  [MEM_CK_WIDTH-1:0]           mem_ck;
output  [MEM_CK_WIDTH-1:0]           mem_ck_n;
inout   [MEM_DQS_WIDTH-1:0]          mem_dqs;
inout   [MEM_DQS_WIDTH-1:0]          mem_dqs_n;
output  reset_n_scc_clk;
output  reset_n_avl_clk; 
input                              scc_data;
input    [MEM_READ_DQS_WIDTH-1:0]  scc_dqs_ena;
input    [MEM_READ_DQS_WIDTH-1:0]  scc_dqs_io_ena;
input          [MEM_DQ_WIDTH-1:0]  scc_dq_ena;
input          [MEM_DM_WIDTH-1:0]  scc_dm_ena;
input                       [0:0]  scc_upd;
output   [MEM_READ_DQS_WIDTH-1:0]  capture_strobe_tracking;
output  phy_clk;
output	ctl_clk;
output  phy_reset_n;
input  pll_afi_clk;       
input  pll_afi_half_clk;	
input  pll_addr_cmd_clk;  
input  pll_mem_clk;       
input  pll_write_clk;     
input	pll_write_clk_pre_phy_clk;
input  pll_dqs_ena_clk;
input  seq_clk;
input  pll_avl_clk;
input  pll_config_clk;
input pll_mem_phy_clk;
input pll_afi_phy_clk;
input pll_avl_phy_clk;
output  dll_clk;
output	dll_pll_locked;
input   [DLL_DELAY_CTRL_WIDTH-1:0]  dll_phy_delayctrl;   
wire  [179:0]  ddio_phy_dqdin;
wire    [4:0]  ddio_phy_dqslogic_rdatavalid;
wire   [63:0]  phy_ddio_address;
wire   [11:0]  phy_ddio_bank;
wire    [3:0]  phy_ddio_cas_n;
wire    [3:0]  phy_ddio_ck; 
wire    [7:0]  phy_ddio_cke;
wire    [3:0]  phy_ddio_ck_n; 
wire    [7:0]  phy_ddio_cs_n;
wire   [19:0]  phy_ddio_dmdout;  
wire  [179:0]  phy_ddio_dqdout;
wire   [89:0]  phy_ddio_dqoe;
wire    [9:0]  phy_ddio_dqsb_oe;
wire    [9:0]  phy_ddio_dqslogic_dqsena;
wire    [4:0]  phy_ddio_dqslogic_fiforeset;
wire    [4:0]  phy_ddio_dqslogic_aclr_pstamble;
wire    [4:0]  phy_ddio_dqslogic_aclr_fifoctrl;
wire    [9:0]  phy_ddio_dqslogic_incrdataen;
wire    [9:0]  phy_ddio_dqslogic_incwrptr;
wire    [9:0]  phy_ddio_dqslogic_oct;
wire   [24:0]  phy_ddio_dqslogic_readlatency;
wire    [9:0]  phy_ddio_dqs_oe;
wire    [19:0]  phy_ddio_dqs_dout;
wire    [7:0]  phy_ddio_odt;
wire    [3:0]  phy_ddio_ras_n;
wire    [3:0]  phy_ddio_reset_n;
wire    [3:0]  phy_ddio_we_n;
wire	read_capture_clk;
wire	[NUM_AFI_RESET-1:0] reset_n_afi_clk;
wire	reset_n_addr_cmd_clk;
wire	reset_n_seq_clk;
wire	reset_n_scc_clk;
wire	reset_n_avl_clk;
wire	reset_n_resync_clk;
localparam SKIP_CALIBRATION_STEPS = 7'b1111111;
localparam CALIBRATION_STEPS = (FAST_SIM_MODEL && (FAST_SIM_CALIBRATION != "true") ? SKIP_CALIBRATION_STEPS : 7'b1000000);
localparam SKIP_MEM_INIT = 1'b1;
localparam SEQ_CALIB_INIT = {CALIBRATION_STEPS, SKIP_MEM_INIT};
generate
if (IS_HHP_HPS != "true") begin
	reg [CALIB_REG_WIDTH-1:0] seq_calib_init_reg ;
	always @(posedge pll_afi_clk)
		`ifdef SYNTH_FOR_SIM
		`else
		`endif
		seq_calib_init_reg <= SEQ_CALIB_INIT;
		`ifdef SYNTH_FOR_SIM
		`else
		`endif
		`ifdef SYNTH_FOR_SIM
		`else
		`endif
end
endgenerate
generate
if (IS_HHP_HPS != "true") begin
	lpddr2_cntrlr_p0_reset	ureset(
		.pll_afi_clk				(pll_afi_clk),
		.pll_addr_cmd_clk			(pll_addr_cmd_clk),
		.pll_dqs_ena_clk			(pll_dqs_ena_clk),
		.seq_clk					(seq_clk), 
		.pll_avl_clk				(pll_avl_clk),
		.scc_clk					(pll_config_clk),
		.reset_n_scc_clk			(reset_n_scc_clk),
		.reset_n_avl_clk			(reset_n_avl_clk),
		.read_capture_clk			(read_capture_clk),
		.pll_locked					(pll_locked),
		.global_reset_n				(global_reset_n),
		.soft_reset_n				(soft_reset_n),
		.ctl_reset_export_n         (ctl_reset_export_n),
		.reset_n_afi_clk			(reset_n_afi_clk),
		.reset_n_addr_cmd_clk		(reset_n_addr_cmd_clk),
		.reset_n_seq_clk			(reset_n_seq_clk),
		.reset_n_resync_clk			(reset_n_resync_clk) 
	);
	defparam ureset.MEM_READ_DQS_WIDTH = MEM_READ_DQS_WIDTH;
	defparam ureset.NUM_AFI_RESET = NUM_AFI_RESET;
end else begin
	lpddr2_cntrlr_p0_reset	ureset(
		.pll_afi_clk				(pll_afi_clk),
		.pll_addr_cmd_clk			(pll_addr_cmd_clk),
		.pll_dqs_ena_clk			(pll_dqs_ena_clk),
		.seq_clk					(seq_clk), 
		.pll_avl_clk				(pll_avl_clk),
		.scc_clk					(pll_config_clk),
		.reset_n_scc_clk			(reset_n_scc_clk),
		.reset_n_avl_clk			(reset_n_avl_clk),
		.read_capture_clk			(read_capture_clk),
		.pll_locked					(pll_locked),
		.global_reset_n				(global_reset_n),
		.soft_reset_n				(soft_reset_n),
		.ctl_reset_export_n         (ctl_reset_export_n),
		.reset_n_afi_clk			(reset_n_afi_clk),
		.reset_n_addr_cmd_clk		(reset_n_addr_cmd_clk),
		.reset_n_seq_clk			(reset_n_seq_clk),
		.reset_n_resync_clk			(reset_n_resync_clk) 
	);
	defparam ureset.MEM_READ_DQS_WIDTH = MEM_READ_DQS_WIDTH;
	defparam ureset.NUM_AFI_RESET = NUM_AFI_RESET;
end
endgenerate
assign phy_clk = seq_clk;
assign phy_reset_n = reset_n_seq_clk;  
assign dll_clk = pll_write_clk_pre_phy_clk;
assign dll_pll_locked = pll_locked;
wire afi_clk;
wire avl_clk;
wire adc_clk;
wire adc_clk_cps;
lpddr2_cntrlr_p0_acv_ldc # (
	.DLL_DELAY_CTRL_WIDTH (DLL_DELAY_CTRL_WIDTH),
	.ADC_PHASE_SETTING (ADC_PHASE_SETTING),
	.ADC_INVERT_PHASE (ADC_INVERT_PHASE),
	.IS_HHP_HPS (IS_HHP_HPS)
) memphy_ldc (
	.pll_hr_clk (pll_avl_phy_clk),
	.pll_dq_clk (pll_write_clk),
	.pll_dqs_clk (pll_mem_phy_clk),
	.dll_phy_delayctrl (dll_phy_delayctrl),
	.afi_clk (afi_clk),
	.avl_clk (avl_clk),
	.adc_clk (adc_clk),
	.adc_clk_cps (adc_clk_cps)
);
assign ctl_clk = afi_clk;
assign afi_reset_n = reset_n_afi_clk;
	cyclonev_mem_phy hphy_inst (
		.pllaficlk                   (afi_clk),
		.pllavlclk                   (avl_clk),
		.plllocked                   (pll_locked),
		.plladdrcmdclk               (adc_clk),
		.globalresetn                (global_reset_n),
		.softresetn                  (soft_reset_n),
		.phyresetn                   (phy_reset_n), 
		.ctlresetn                   (ctl_reset_n),
		.iointaddrdout               (io_intaddrdout),
		.iointbadout                 (io_intbadout),
		.iointcasndout               (io_intcasndout),
		.iointckdout                 (io_intckdout),
		.iointckedout                (io_intckedout),
		.iointckndout                (io_intckndout),
		.iointcsndout                (io_intcsndout),
		.iointdmdout                 (io_intdmdout),
		.iointdqdin                  (io_intdqdin),
		.iointdqdout                 (io_intdqdout),
		.iointdqoe                   (io_intdqoe),
		.iointdqsbdout               (io_intdqsbdout),
		.iointdqsboe                 (io_intdqsboe),
		.iointdqsdout                (io_intdqsdout),
		.iointdqslogicdqsena         (io_intdqslogicdqsena),
		.iointdqslogicfiforeset      (io_intdqslogicfiforeset),
		.iointdqslogicincrdataen     (io_intdqslogicincrdataen),
		.iointdqslogicincwrptr       (io_intdqslogicincwrptr),
		.iointdqslogicoct            (io_intdqslogicoct),
		.iointdqslogicrdatavalid     (io_intdqslogicrdatavalid),
		.iointdqslogicreadlatency    (io_intdqslogicreadlatency),
		.iointdqsoe                  (io_intdqsoe),
		.iointodtdout                (io_intodtdout),
		.iointrasndout               (io_intrasndout),
		.iointresetndout             (io_intresetndout),
		.iointwendout                (io_intwendout),
		.iointafirlat                (io_intafirlat),
		.iointafiwlat                (io_intafiwlat),
		.iointaficalfail             (io_intaficalfail),
		.iointaficalsuccess          (io_intaficalsuccess),
		.ddiophydqdin                (ddio_phy_dqdin),
		.ddiophydqslogicrdatavalid   (ddio_phy_dqslogic_rdatavalid),
		.phyddioaddrdout             (phy_ddio_address),
		.phyddiobadout               (phy_ddio_bank),
		.phyddiocasndout             (phy_ddio_cas_n),
		.phyddiockdout               (phy_ddio_ck),
		.phyddiockedout              (phy_ddio_cke),
		.phyddiockndout              (),    
		.phyddiocsndout              (phy_ddio_cs_n),
		.phyddiodmdout               (phy_ddio_dmdout),
		.phyddiodqdout               (phy_ddio_dqdout),
		.phyddiodqoe                 (phy_ddio_dqoe),
		.phyddiodqsbdout             (),    
		.phyddiodqsboe               (phy_ddio_dqsb_oe),
		.phyddiodqslogicdqsena       (phy_ddio_dqslogic_dqsena),
		.phyddiodqslogicfiforeset    (phy_ddio_dqslogic_fiforeset),
		.phyddiodqslogicaclrpstamble (phy_ddio_dqslogic_aclr_pstamble),
		.phyddiodqslogicaclrfifoctrl (phy_ddio_dqslogic_aclr_fifoctrl),
		.phyddiodqslogicincrdataen   (phy_ddio_dqslogic_incrdataen),
		.phyddiodqslogicincwrptr     (phy_ddio_dqslogic_incwrptr),
		.phyddiodqslogicoct          (phy_ddio_dqslogic_oct),
		.phyddiodqslogicreadlatency  (phy_ddio_dqslogic_readlatency),
		.phyddiodqsoe                (phy_ddio_dqs_oe),
		.phyddiodqsdout              (phy_ddio_dqs_dout),
		.phyddioodtdout              (phy_ddio_odt),
		.phyddiorasndout             (phy_ddio_ras_n),
		.phyddioresetndout           (phy_ddio_reset_n),
		.phyddiowendout              (phy_ddio_we_n),
		.afiaddr                     (afi_addr),
		.afiba                       (afi_ba),
		.aficalfail                  (afi_cal_fail),
		.aficalsuccess               (afi_cal_success),
		.aficasn                     (afi_cas_n),
		.aficke                      (afi_cke),
		.aficsn                      (afi_cs_n),
		.afidm                       (afi_dm),
		.afidqsburst                 (afi_dqs_burst),
		.afimemclkdisable            (afi_mem_clk_disable),
		.afiodt                      (afi_odt),
		.afirasn                     (afi_ras_n),
		.afirdata                    (afi_rdata),
		.afirdataen                  (afi_rdata_en),
		.afirdataenfull              (afi_rdata_en_full),
		.afirdatavalid               (afi_rdata_valid),
		.afirlat                     (afi_rlat),
		.afirstn                     (afi_rst_n),
		.afiwdata                    (afi_wdata),
		.afiwdatavalid               (afi_wdata_valid),
		.afiwen                      (afi_we_n),
		.afiwlat                     (afi_wlat),
		.avladdress                  (avl_address),
		.avlread                     (avl_read),
		.avlreaddata                 (avl_readdata),
		.avlresetn                   (reset_n_avl_clk),
		.avlwaitrequest              (avl_waitrequest),
		.avlwrite                    (avl_write),
		.avlwritedata                (avl_writedata),
		.cfgaddlat                   (cfg_addlat),
		.cfgbankaddrwidth            (cfg_bankaddrwidth),
		.cfgcaswrlat                 (cfg_caswrlat),
		.cfgcoladdrwidth             (cfg_coladdrwidth),
		.cfgcsaddrwidth              (cfg_csaddrwidth),
		.cfgdevicewidth              (cfg_devicewidth),
		.cfgdramconfig               (cfg_dramconfig),
		.cfginterfacewidth           (cfg_interfacewidth),
		.cfgrowaddrwidth             (cfg_rowaddrwidth),
		.cfgtcl                      (cfg_tcl),
		.cfgtmrd                     (cfg_tmrd),
		.cfgtrefi                    (cfg_trefi),
		.cfgtrfc                     (cfg_trfc),
		.cfgtwr                      (cfg_twr),
		.scanen                      ()  
	);
	defparam hphy_inst.hphy_ac_ddr_disable = "false";
	defparam hphy_inst.hphy_datapath_delay = "one_cycle";
	defparam hphy_inst.hphy_datapath_ac_delay = "one_cycle";
	defparam hphy_inst.hphy_reset_delay_en = "false";  
	defparam hphy_inst.m_hphy_ac_rom_init_file = AC_ROM_INIT_FILE_NAME;
	defparam hphy_inst.m_hphy_inst_rom_init_file = INST_ROM_INIT_FILE_NAME;
	defparam hphy_inst.hphy_wrap_back_en = "false";  
	defparam hphy_inst.hphy_atpg_en = "false";  
	defparam hphy_inst.hphy_use_hphy = "true";  
	defparam hphy_inst.hphy_csr_pipelineglobalenable = "true";  
	defparam hphy_inst.hphy_hhp_hps = IS_HHP_HPS;
	lpddr2_cntrlr_p0_acv_hard_io_pads #(
		.DEVICE_FAMILY(DEVICE_FAMILY),
		.FAST_SIM_MODEL(FAST_SIM_MODEL),
		.OCT_SERIES_TERM_CONTROL_WIDTH(OCT_SERIES_TERM_CONTROL_WIDTH),
		.OCT_PARALLEL_TERM_CONTROL_WIDTH(OCT_PARALLEL_TERM_CONTROL_WIDTH),
		.MEM_ADDRESS_WIDTH(MEM_ADDRESS_WIDTH),
		.MEM_BANK_WIDTH(MEM_BANK_WIDTH),
		.MEM_CHIP_SELECT_WIDTH(MEM_IF_CS_WIDTH),
		.MEM_CLK_EN_WIDTH(MEM_CLK_EN_WIDTH),
		.MEM_CK_WIDTH(MEM_CK_WIDTH),
		.MEM_ODT_WIDTH(MEM_ODT_WIDTH),
		.MEM_DQS_WIDTH(MEM_DQS_WIDTH),
		.MEM_DM_WIDTH(MEM_DM_WIDTH),
		.MEM_CONTROL_WIDTH(MEM_CONTROL_WIDTH),
		.MEM_DQ_WIDTH(MEM_DQ_WIDTH),
		.MEM_READ_DQS_WIDTH(MEM_READ_DQS_WIDTH),
		.MEM_WRITE_DQS_WIDTH(MEM_WRITE_DQS_WIDTH),
		.DLL_DELAY_CTRL_WIDTH(DLL_DELAY_CTRL_WIDTH),
		.ADC_PHASE_SETTING(ADC_PHASE_SETTING),
		.ADC_INVERT_PHASE(ADC_INVERT_PHASE),
		.IS_HHP_HPS(IS_HHP_HPS)
	) uio_pads (
		.reset_n_addr_cmd_clk              (reset_n_addr_cmd_clk),
		.reset_n_afi_clk                   (reset_n_afi_clk[1]),  
		.oct_ctl_rs_value                  (oct_ctl_rs_value),
		.oct_ctl_rt_value                  (oct_ctl_rt_value),
		.phy_ddio_address                  (phy_ddio_address),
		.phy_ddio_bank                     (phy_ddio_bank),
		.phy_ddio_cs_n                     (phy_ddio_cs_n),
		.phy_ddio_cke                      (phy_ddio_cke),
		.phy_ddio_odt                      (phy_ddio_odt),
		.phy_ddio_we_n                     (phy_ddio_we_n),
		.phy_ddio_ras_n                    (phy_ddio_ras_n),
		.phy_ddio_cas_n                    (phy_ddio_cas_n),
		.phy_ddio_ck                       (phy_ddio_ck),
		.phy_ddio_reset_n                  (phy_ddio_reset_n),
		.phy_mem_address                   (mem_a),
		.phy_mem_bank                      (mem_ba),
		.phy_mem_cs_n                      (mem_cs_n),
		.phy_mem_cke                       (mem_cke),
		.phy_mem_odt                       (mem_odt),
		.phy_mem_we_n                      (mem_we_n),
		.phy_mem_ras_n                     (mem_ras_n),
		.phy_mem_cas_n                     (mem_cas_n),
		.phy_mem_reset_n                   (mem_reset_n),
		.pll_afi_clk                       (pll_afi_clk),
		.pll_mem_clk                       (pll_mem_clk),
		.pll_afi_phy_clk                   (pll_afi_phy_clk),
		.pll_avl_phy_clk                   (pll_avl_phy_clk),
		.pll_avl_clk                       (pll_avl_clk),
		.avl_clk                           (avl_clk),
		.pll_mem_phy_clk                   (pll_mem_phy_clk),
		.pll_write_clk                     (pll_write_clk),
		.pll_dqs_ena_clk                   (pll_dqs_ena_clk),
		.pll_addr_cmd_clk                  (adc_clk_cps),
		.phy_mem_dq                        (mem_dq),
		.phy_mem_dm                        (mem_dm),
		.phy_mem_ck                        (mem_ck),
		.phy_mem_ck_n                      (mem_ck_n),
		.mem_dqs                           (mem_dqs),
		.mem_dqs_n                         (mem_dqs_n),
		.dll_phy_delayctrl                 (dll_phy_delayctrl),
		.scc_clk                           (pll_config_clk),
		.scc_data                          (scc_data),
		.scc_dqs_ena                       (scc_dqs_ena),
		.scc_dqs_io_ena                    (scc_dqs_io_ena),
		.scc_dq_ena                        (scc_dq_ena),
		.scc_dm_ena                        (scc_dm_ena),
		.scc_upd                           (scc_upd[0]),
		.phy_ddio_dmdout                   (phy_ddio_dmdout),
		.phy_ddio_dqdout                   (phy_ddio_dqdout),
		.phy_ddio_dqs_oe                   (phy_ddio_dqs_oe),
		.phy_ddio_dqsdout                  (phy_ddio_dqs_dout),
		.phy_ddio_dqsb_oe                  (phy_ddio_dqsb_oe),
		.phy_ddio_dqslogic_oct             (phy_ddio_dqslogic_oct),
		.phy_ddio_dqslogic_fiforeset       (phy_ddio_dqslogic_fiforeset),
		.phy_ddio_dqslogic_aclr_pstamble   (phy_ddio_dqslogic_aclr_pstamble),
		.phy_ddio_dqslogic_aclr_fifoctrl   (phy_ddio_dqslogic_aclr_fifoctrl),
		.phy_ddio_dqslogic_incwrptr        (phy_ddio_dqslogic_incwrptr),
		.phy_ddio_dqslogic_readlatency     (phy_ddio_dqslogic_readlatency),
		.ddio_phy_dqslogic_rdatavalid      (ddio_phy_dqslogic_rdatavalid),
		.ddio_phy_dqdin                    (ddio_phy_dqdin),
		.phy_ddio_dqslogic_incrdataen      (phy_ddio_dqslogic_incrdataen),
		.phy_ddio_dqslogic_dqsena          (phy_ddio_dqslogic_dqsena),
		.phy_ddio_dqoe                     (phy_ddio_dqoe),
		.capture_strobe_tracking           (capture_strobe_tracking)
    );
generate
if (IS_HHP_HPS != "true") begin
	reg afi_clk_reg ;
	always @(posedge pll_afi_clk)
		afi_clk_reg <= ~afi_clk_reg;
	reg afi_half_clk_reg ;
	always @(posedge pll_afi_half_clk)
		afi_half_clk_reg <= ~afi_half_clk_reg;
	reg avl_clk_reg ;
	always @(posedge pll_avl_clk)
		avl_clk_reg <= ~avl_clk_reg;
	reg config_clk_reg ;
	always @(posedge pll_config_clk)
		config_clk_reg <= ~config_clk_reg;
end
endgenerate
function integer ceil_log2;
	input integer value;
	begin
		value = value - 1;
		for (ceil_log2 = 0; value > 0; ceil_log2 = ceil_log2 + 1)
			value = value >> 1;
	end
endfunction
endmodule
