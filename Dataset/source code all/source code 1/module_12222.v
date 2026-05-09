module ddr3_s4_uniphy_example_sim_ddr3_s4_uniphy_example_sim_e0_if0_p0_memphy(
	global_reset_n,
	soft_reset_n,
	reset_request_n,
	ctl_reset_n,
	pll_locked,
	oct_ctl_rs_value,
	oct_ctl_rt_value,
	afi_addr,
	afi_cke,
	afi_cs_n,
	afi_ba,
	afi_cas_n,
	afi_odt,
	afi_ras_n,
	afi_we_n,
	afi_rst_n,
	afi_mem_clk_disable,
	afi_dqs_burst,
	afi_wlat,
	afi_rlat,
	afi_wdata,
	afi_wdata_valid,
	afi_dm,
	afi_rdata,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata_valid,
	afi_cal_debug_info,
	afi_ctl_refresh_done,
	afi_ctl_long_idle,
	afi_seq_busy,
	afi_cal_success,
	afi_cal_fail,
	mem_a,
	mem_ba,
	mem_ck,
	mem_ck_n,
	mem_cke,
	mem_cs_n,
	mem_dm,
	mem_odt,
	mem_ras_n,
	mem_cas_n,
	mem_we_n,
	mem_reset_n,
	mem_dq,
	mem_dqs,
	mem_dqs_n,
	pll_afi_clk,
	pll_addr_cmd_clk,
	pll_mem_clk,
	pll_write_clk,
	pll_dqs_ena_clk,
	seq_clk,
	pll_avl_clk,
	pll_config_clk,
	dll_phy_delayctrl
);
parameter DEVICE_FAMILY = "";
parameter OCT_SERIES_TERM_CONTROL_WIDTH   = ""; 
parameter OCT_PARALLEL_TERM_CONTROL_WIDTH = ""; 
parameter MEM_ADDRESS_WIDTH     = ""; 
parameter MEM_BANK_WIDTH        = "";
parameter MEM_CLK_EN_WIDTH 	    = ""; 
parameter MEM_CK_WIDTH 	    	= ""; 
parameter MEM_ODT_WIDTH 		= ""; 
parameter MEM_DQS_WIDTH         = "";
parameter MEM_CHIP_SELECT_WIDTH = ""; 
parameter MEM_CONTROL_WIDTH     = ""; 
parameter MEM_DM_WIDTH          = ""; 
parameter MEM_DQ_WIDTH          = ""; 
parameter MEM_READ_DQS_WIDTH    = ""; 
parameter MEM_WRITE_DQS_WIDTH   = "";
parameter AFI_ADDRESS_WIDTH         = ""; 
parameter AFI_DEBUG_INFO_WIDTH = "";
parameter CALIB_VFIFO_OFFSET = "";
parameter CALIB_LFIFO_OFFSET = "";
parameter AFI_BANK_WIDTH            = "";
parameter AFI_CHIP_SELECT_WIDTH     = "";
parameter AFI_CLK_EN_WIDTH     		= "";
parameter AFI_ODT_WIDTH     		= "";
parameter AFI_MAX_WRITE_LATENCY_COUNT_WIDTH = "";
parameter AFI_MAX_READ_LATENCY_COUNT_WIDTH = "";
parameter AFI_DATA_MASK_WIDTH       = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 
parameter AFI_DATA_WIDTH            = ""; 
parameter AFI_DQS_WIDTH				= "";
parameter DLL_DELAY_CTRL_WIDTH  = "";
parameter NUM_SUBGROUP_PER_READ_DQS        = "";
parameter QVLD_EXTRA_FLOP_STAGES		   = "";
parameter QVLD_WR_ADDRESS_OFFSET		   = "";
parameter READ_VALID_TIMEOUT_WIDTH         = "";
parameter READ_VALID_FIFO_SIZE             = "";
parameter READ_FIFO_SIZE                   = "";
parameter MAX_LATENCY_COUNT_WIDTH          = "";
parameter MAX_READ_LATENCY                 = "";
parameter MAX_WRITE_LATENCY_COUNT_WIDTH = 4;
parameter NUM_WRITE_PATH_FLOP_STAGES	= "";
parameter NUM_AC_FR_CYCLE_SHIFTS = "";
parameter INIT_COUNT_WIDTH      = "";
parameter MEM_BURST_LENGTH      = "";
parameter MEM_T_WL              = "";
parameter MEM_T_RL              = "";
parameter MEM_TINIT_CK = "";
parameter MEM_TMRD_CK = "";
parameter RDIMM = "";
parameter MR0_BL                = "";
parameter MR0_BT                = "";
parameter MR0_CAS_LATENCY       = "";
parameter MR0_DLL               = "";
parameter MR0_WR                = "";
parameter MR0_PD                = "";
parameter MR1_DLL               = "";
parameter MR1_ODS               = "";
parameter MR1_RTT               = "";
parameter MR1_AL                = "";
parameter MR1_WL                = "";
parameter MR1_TDQS              = "";
parameter MR1_QOFF              = "";
parameter MR2_CWL               = "";
parameter MR2_ASR               = "";
parameter MR2_SRT               = "";
parameter MR2_RTT_WR            = ""; 
parameter MR3_MPR_RF            = ""; 
parameter MR3_MPR               = ""; 
parameter RDIMM_CONFIG          = 64'h0;
parameter DELAY_PER_OPA_TAP   = "";
parameter DELAY_PER_DCHAIN_TAP   = "";
parameter DLL_DELAY_CHAIN_LENGTH = "";
parameter MEM_NUMBER_OF_RANKS = "";
parameter MEM_MIRROR_ADDRESSING = "";
parameter SEQ_BURST_COUNT_WIDTH = "";
parameter VCALIB_COUNT_WIDTH = "";
parameter ALTDQDQS_INPUT_FREQ = "";
parameter ALTDQDQS_DELAY_CHAIN_BUFFER_MODE = "";
parameter ALTDQDQS_DQS_PHASE_SETTING = "";
parameter ALTDQDQS_DQS_PHASE_SHIFT = "";
parameter ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING = "";
parameter TB_PROTOCOL       = "";
parameter TB_MEM_CLK_FREQ       = "";
parameter TB_RATE       = "";
parameter TB_MEM_DQ_WIDTH       = "";
parameter TB_MEM_DQS_WIDTH       = "";
parameter TB_PLL_DLL_MASTER       = "";
parameter FAST_SIM_MODEL = "";
parameter FAST_SIM_CALIBRATION = "";
localparam DOUBLE_MEM_DQ_WIDTH = MEM_DQ_WIDTH * 2;
localparam HALF_AFI_DATA_WIDTH = AFI_DATA_WIDTH / 2;
parameter CALIB_REG_WIDTH = "";
localparam NUM_AFI_RESET = 4;
localparam READ_VALID_FIFO_WRITE_MEM_DEPTH	= READ_VALID_FIFO_SIZE / 2; 
localparam READ_VALID_FIFO_READ_MEM_DEPTH	= READ_VALID_FIFO_SIZE / 2; 
localparam READ_VALID_FIFO_PER_DQS_WIDTH	= 2; 
localparam READ_VALID_FIFO_WIDTH		= READ_VALID_FIFO_PER_DQS_WIDTH * MEM_READ_DQS_WIDTH;
localparam READ_VALID_FIFO_WRITE_ADDR_WIDTH	= ceil_log2(READ_VALID_FIFO_WRITE_MEM_DEPTH);
localparam READ_VALID_FIFO_READ_ADDR_WIDTH	= ceil_log2(READ_VALID_FIFO_READ_MEM_DEPTH);
localparam READ_FIFO_WRITE_MEM_DEPTH		= READ_FIFO_SIZE / 2; 
localparam READ_FIFO_READ_MEM_DEPTH			= READ_FIFO_SIZE / 2; 
localparam READ_FIFO_WRITE_ADDR_WIDTH		= ceil_log2(READ_FIFO_WRITE_MEM_DEPTH);
localparam READ_FIFO_READ_ADDR_WIDTH		= ceil_log2(READ_FIFO_READ_MEM_DEPTH);
localparam SEQ_ADDRESS_WIDTH		= AFI_ADDRESS_WIDTH;
localparam SEQ_BANK_WIDTH			= AFI_BANK_WIDTH;
localparam SEQ_CHIP_SELECT_WIDTH	= AFI_CHIP_SELECT_WIDTH;
localparam SEQ_CLK_EN_WIDTH			= AFI_CLK_EN_WIDTH;
localparam SEQ_ODT_WIDTH			= AFI_ODT_WIDTH;
localparam SEQ_DATA_MASK_WIDTH		= AFI_DATA_MASK_WIDTH;
localparam SEQ_CONTROL_WIDTH		= AFI_CONTROL_WIDTH;
localparam SEQ_DATA_WIDTH			= AFI_DATA_WIDTH;
localparam SEQ_DQS_WIDTH			= AFI_DQS_WIDTH;
input	global_reset_n;		
input	soft_reset_n;		
input	pll_locked;			
output	reset_request_n;	
output	ctl_reset_n;		
input   [OCT_SERIES_TERM_CONTROL_WIDTH-1:0] oct_ctl_rs_value;
input   [OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] oct_ctl_rt_value;
input   [AFI_ADDRESS_WIDTH-1:0] afi_addr;       
input   [AFI_CLK_EN_WIDTH-1:0] afi_cke;
input   [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n;
input   [AFI_BANK_WIDTH-1:0]    afi_ba;
input   [AFI_CONTROL_WIDTH-1:0] afi_cas_n;
input   [AFI_ODT_WIDTH-1:0] afi_odt;
input   [AFI_CONTROL_WIDTH-1:0] afi_ras_n;
input   [AFI_CONTROL_WIDTH-1:0] afi_we_n;
input   [AFI_CONTROL_WIDTH-1:0] afi_rst_n;
input   afi_mem_clk_disable;	
input   [AFI_DQS_WIDTH-1:0]	afi_dqs_burst;	
output  [AFI_MAX_WRITE_LATENCY_COUNT_WIDTH-1:0] afi_wlat;
output  [AFI_MAX_READ_LATENCY_COUNT_WIDTH-1:0]  afi_rlat;
input   [AFI_DATA_WIDTH-1:0]    afi_wdata;              
input   [AFI_DQS_WIDTH-1:0]		afi_wdata_valid;    	
input   [AFI_DATA_MASK_WIDTH-1:0]   afi_dm;             
output  [AFI_DATA_WIDTH-1:0]    afi_rdata;              
input   afi_rdata_en;       
input   afi_rdata_en_full;  
output  afi_rdata_valid;
output  afi_cal_success;    
output [AFI_DEBUG_INFO_WIDTH - 1:0] afi_cal_debug_info;
input   [MEM_CHIP_SELECT_WIDTH-1:0] afi_ctl_refresh_done;
input   [MEM_CHIP_SELECT_WIDTH-1:0] afi_ctl_long_idle;
output  [MEM_CHIP_SELECT_WIDTH-1:0] afi_seq_busy;
output  afi_cal_fail;       
output  [MEM_ADDRESS_WIDTH-1:0] mem_a;
output  [MEM_BANK_WIDTH-1:0]    mem_ba;
output  [MEM_CK_WIDTH-1:0]	mem_ck;
output  [MEM_CK_WIDTH-1:0]	mem_ck_n;
output  [MEM_CLK_EN_WIDTH-1:0] mem_cke;
output  [MEM_CHIP_SELECT_WIDTH-1:0] mem_cs_n;
output  [MEM_DM_WIDTH-1:0]  mem_dm;
output  [MEM_ODT_WIDTH-1:0] mem_odt;
output  [MEM_CONTROL_WIDTH-1:0] mem_ras_n;
output  [MEM_CONTROL_WIDTH-1:0] mem_cas_n;
output  [MEM_CONTROL_WIDTH-1:0] mem_we_n;
output  mem_reset_n;
inout   [MEM_DQ_WIDTH-1:0]  mem_dq;
inout   [MEM_DQS_WIDTH-1:0] mem_dqs;
inout   [MEM_DQS_WIDTH-1:0] mem_dqs_n;
input	pll_afi_clk;		
input	pll_addr_cmd_clk;	
input	pll_mem_clk;		
input	pll_write_clk;		
input	pll_dqs_ena_clk;
input	seq_clk;
input	pll_avl_clk;
input	pll_config_clk;
input	[DLL_DELAY_CTRL_WIDTH-1:0]  dll_phy_delayctrl;	
wire	[AFI_ADDRESS_WIDTH-1:0]	phy_ddio_address;
wire	[AFI_BANK_WIDTH-1:0]    phy_ddio_bank;
wire	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
wire	[AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;
wire	[AFI_ODT_WIDTH-1:0] phy_ddio_odt;
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ras_n;
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_cas_n;
wire	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_we_n;
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_reset_n;
wire	[AFI_DATA_WIDTH-1:0]  phy_ddio_dq;
wire	[AFI_DQS_WIDTH-1:0]  phy_ddio_dqs_en;
wire	[AFI_DQS_WIDTH-1:0]  phy_ddio_oct_ena;
wire	[AFI_DQS_WIDTH-1:0]  phy_ddio_wrdata_en;
wire	[AFI_DATA_MASK_WIDTH-1:0] phy_ddio_wrdata_mask;
wire	[DOUBLE_MEM_DQ_WIDTH-1:0] ddio_phy_dq;
wire	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk;
wire	[AFI_DATA_WIDTH-1:0]    phy_mux_rdata;
wire	[AFI_DATA_WIDTH-1:0]    phy_mux_read_fifo_q;
wire  	phy_mux_rdata_valid;
wire	[SEQ_ADDRESS_WIDTH-1:0] seq_mux_address;
wire	[SEQ_BANK_WIDTH-1:0]    seq_mux_bank;
wire	[SEQ_CHIP_SELECT_WIDTH-1:0] seq_mux_cs_n;
wire	[SEQ_CLK_EN_WIDTH-1:0] seq_mux_cke;
wire	[SEQ_ODT_WIDTH-1:0] seq_mux_odt;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_ras_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_cas_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_we_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_reset_n;
wire	[SEQ_DQS_WIDTH-1:0]	seq_mux_dqs_en;
wire	[SEQ_DATA_WIDTH-1:0]    seq_mux_wdata;
wire	[SEQ_DQS_WIDTH-1:0]	seq_mux_wdata_valid;
wire	[SEQ_DATA_MASK_WIDTH-1:0]   seq_mux_dm;
wire	seq_mux_rdata_en;
wire	[SEQ_DATA_WIDTH-1:0]    mux_seq_rdata;
wire	[SEQ_DATA_WIDTH-1:0]    mux_seq_read_fifo_q;
wire	mux_seq_rdata_valid;    
wire	mux_sel;
wire  	[AFI_ADDRESS_WIDTH-1:0] mux_phy_address;
wire	[AFI_BANK_WIDTH-1:0]    mux_phy_bank;
wire	[AFI_CHIP_SELECT_WIDTH-1:0] mux_phy_cs_n;
wire	[AFI_CLK_EN_WIDTH-1:0] mux_phy_cke;
wire	[AFI_ODT_WIDTH-1:0] mux_phy_odt;
wire	[AFI_CONTROL_WIDTH-1:0] mux_phy_ras_n;
wire	[AFI_CONTROL_WIDTH-1:0] mux_phy_cas_n;
wire	[AFI_CONTROL_WIDTH-1:0] mux_phy_we_n;
wire	[AFI_CONTROL_WIDTH-1:0] mux_phy_reset_n;
wire	[AFI_DQS_WIDTH-1:0]	mux_phy_dqs_en;
wire	[AFI_DATA_WIDTH-1:0]    mux_phy_wdata;
wire	[AFI_DQS_WIDTH-1:0]		mux_phy_wdata_valid;
wire	[AFI_DATA_MASK_WIDTH-1:0]   mux_phy_dm;
wire	mux_phy_rdata_en;
wire	mux_phy_rdata_en_full;
wire	[MAX_LATENCY_COUNT_WIDTH-1:0] seq_read_latency_counter;
wire	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_fr;
wire	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_hr;
wire	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_qr;
wire	[NUM_AFI_RESET-1:0] reset_n_afi_clk;
wire	reset_n_addr_cmd_clk;
wire	reset_n_seq_clk;
wire	reset_n_resync_clk;
wire	[READ_VALID_FIFO_WIDTH-1:0] dqs_enable_ctrl;
wire	seq_reset_mem_stable;
wire	[MEM_READ_DQS_WIDTH-1:0] seq_read_fifo_reset;
wire	[AFI_DQS_WIDTH-1:0] force_oct_off;
wire	reset_n_scc_clk;
wire	reset_n_avl_clk;
wire csr_soft_reset_req;
wire [MEM_READ_DQS_WIDTH-1:0] dqs_edge_detect;
localparam SKIP_CALIBRATION_STEPS = 7'b1111111;
localparam CALIBRATION_STEPS = SKIP_CALIBRATION_STEPS;
localparam SKIP_MEM_INIT = 1'b1;
localparam SEQ_CALIB_INIT = {CALIBRATION_STEPS, SKIP_MEM_INIT};
reg [CALIB_REG_WIDTH-1:0] seq_calib_init_reg ;
always @(posedge pll_afi_clk)
	`ifndef SYNTH_FOR_SIM
	`endif
	seq_calib_init_reg <= SEQ_CALIB_INIT;
	`ifndef SYNTH_FOR_SIM
	`endif
	`ifndef SYNTH_FOR_SIM
	`endif
	ddr3_s4_uniphy_example_sim_ddr3_s4_uniphy_example_sim_e0_if0_p0_reset	ureset(
		.pll_afi_clk				(pll_afi_clk),
		.pll_addr_cmd_clk			(pll_addr_cmd_clk),
		.pll_dqs_ena_clk			(pll_dqs_ena_clk),
		.seq_clk				(seq_clk),
		.pll_avl_clk				(pll_avl_clk),
		.scc_clk					(pll_config_clk),
		.reset_n_scc_clk			(reset_n_scc_clk),
		.reset_n_avl_clk			(reset_n_avl_clk),
		.read_capture_clk			(read_capture_clk),
		.pll_locked					(pll_locked),
		.global_reset_n				(global_reset_n),
		.soft_reset_n				(soft_reset_n),
		.csr_soft_reset_req         (csr_soft_reset_req),
		.reset_request_n			(reset_request_n),
		.ctl_reset_n				(ctl_reset_n),
		.reset_n_afi_clk			(reset_n_afi_clk),
		.reset_n_addr_cmd_clk		(reset_n_addr_cmd_clk),
		.reset_n_seq_clk			(reset_n_seq_clk),
		.reset_n_resync_clk			(reset_n_resync_clk)
	);
	defparam ureset.MEM_READ_DQS_WIDTH = MEM_READ_DQS_WIDTH;
	defparam ureset.NUM_AFI_RESET = NUM_AFI_RESET;
	wire scc_data;
	wire [MEM_READ_DQS_WIDTH - 1:0] scc_dqs_ena;
	wire [MEM_READ_DQS_WIDTH - 1:0] scc_dqs_io_ena;
	wire [MEM_DQ_WIDTH - 1:0] scc_dq_ena;
	wire [MEM_DM_WIDTH - 1:0] scc_dm_ena;
	wire scc_upd;
	wire [MEM_READ_DQS_WIDTH - 1:0] capture_strobe_tracking;
    ddr3_s4_uniphy_example_sim_ddr3_s4_uniphy_example_sim_e0_if0_p0_nios_sequencer  usequencer(
        .pll_config_clk					(pll_config_clk),
        .pll_avl_clk					(pll_avl_clk),
		.reset_n_avl_clk				(reset_n_avl_clk),
		.reset_n_scc_clk				(reset_n_scc_clk),
		.scc_data						(scc_data),
		.scc_dqs_ena					(scc_dqs_ena),
		.scc_dqs_io_ena					(scc_dqs_io_ena),
		.scc_dq_ena						(scc_dq_ena),
		.scc_dm_ena						(scc_dm_ena),
		.scc_upd						(scc_upd),
		.capture_strobe_tracking		(capture_strobe_tracking),
		.pll_afi_clk					(seq_clk),
		.reset_n						(reset_n_seq_clk),
		.mux_seq_rdata					(mux_seq_rdata),
		.mux_seq_read_fifo_q			(mux_seq_read_fifo_q),
		.mux_seq_rdata_valid			(mux_seq_rdata_valid),
		.seq_mux_address				(seq_mux_address),
        .seq_mux_bank                   (seq_mux_bank),
        .seq_mux_cs_n                   (seq_mux_cs_n),
        .seq_mux_cke                    (seq_mux_cke),
        .seq_mux_odt                    (seq_mux_odt),
        .seq_mux_ras_n                  (seq_mux_ras_n),
        .seq_mux_cas_n                  (seq_mux_cas_n),
        .seq_mux_we_n                   (seq_mux_we_n),
		.seq_mux_reset_n				(seq_mux_reset_n),
        .seq_mux_dqs_en                 (seq_mux_dqs_en),
		.seq_mux_wdata					(seq_mux_wdata),
		.seq_mux_wdata_valid			(seq_mux_wdata_valid),
		.seq_mux_dm						(seq_mux_dm),
		.seq_mux_rdata_en				(seq_mux_rdata_en),
		.mux_sel						(mux_sel),
        .seq_read_latency_counter   	(seq_read_latency_counter),
		.seq_read_increment_vfifo_fr	(seq_read_increment_vfifo_fr),
		.seq_read_increment_vfifo_hr	(seq_read_increment_vfifo_hr),
		.seq_read_increment_vfifo_qr 	(seq_read_increment_vfifo_qr),
		.afi_rlat						(afi_rlat),
		.afi_wlat						(afi_wlat),
		.afi_cal_debug_info(afi_cal_debug_info),
		.afi_ctl_refresh_done			(afi_ctl_refresh_done),
		.afi_ctl_long_idle				(afi_ctl_long_idle),
		.afi_seq_busy					(afi_seq_busy),
		.afi_cal_success				(afi_cal_success),
		.afi_cal_fail					(afi_cal_fail),
        .seq_reset_mem_stable       	(seq_reset_mem_stable),
		.seq_read_fifo_reset			(seq_read_fifo_reset),
		.seq_calib_init					(seq_calib_init_reg)
	);
        defparam usequencer.MEM_ADDRESS_WIDTH                  = MEM_ADDRESS_WIDTH;
        defparam usequencer.MEM_BANK_WIDTH                     = MEM_BANK_WIDTH;
        defparam usequencer.MEM_CLK_EN_WIDTH              	   = MEM_CLK_EN_WIDTH;
        defparam usequencer.MEM_ODT_WIDTH                      = MEM_ODT_WIDTH;
        defparam usequencer.MEM_CHIP_SELECT_WIDTH              = MEM_CHIP_SELECT_WIDTH;
        defparam usequencer.MEM_CONTROL_WIDTH                  = MEM_CONTROL_WIDTH;
        defparam usequencer.MEM_DM_WIDTH                       = MEM_DM_WIDTH;
        defparam usequencer.MEM_DQ_WIDTH                       = MEM_DQ_WIDTH;
        defparam usequencer.MEM_READ_DQS_WIDTH                 = MEM_READ_DQS_WIDTH;
        defparam usequencer.MEM_WRITE_DQS_WIDTH                = MEM_WRITE_DQS_WIDTH;
        defparam usequencer.AFI_ADDRESS_WIDTH                  = SEQ_ADDRESS_WIDTH;
		defparam usequencer.AFI_BANK_WIDTH                     = SEQ_BANK_WIDTH;
        defparam usequencer.AFI_CHIP_SELECT_WIDTH              = SEQ_CHIP_SELECT_WIDTH;
        defparam usequencer.AFI_CLK_EN_WIDTH              	   = SEQ_CLK_EN_WIDTH;
        defparam usequencer.AFI_ODT_WIDTH                      = SEQ_ODT_WIDTH;
        defparam usequencer.AFI_DATA_MASK_WIDTH                = SEQ_DATA_MASK_WIDTH;
        defparam usequencer.AFI_CONTROL_WIDTH                  = SEQ_CONTROL_WIDTH;
        defparam usequencer.AFI_DATA_WIDTH                     = SEQ_DATA_WIDTH;
        defparam usequencer.AFI_DQS_WIDTH                      = SEQ_DQS_WIDTH;
		defparam usequencer.AFI_MAX_WRITE_LATENCY_COUNT_WIDTH  = AFI_MAX_WRITE_LATENCY_COUNT_WIDTH;
		defparam usequencer.AFI_MAX_READ_LATENCY_COUNT_WIDTH   = AFI_MAX_READ_LATENCY_COUNT_WIDTH;
		defparam usequencer.AFI_DEBUG_INFO_WIDTH               = AFI_DEBUG_INFO_WIDTH;
		defparam usequencer.CALIB_VFIFO_OFFSET									= CALIB_VFIFO_OFFSET;
		defparam usequencer.CALIB_LFIFO_OFFSET									= CALIB_LFIFO_OFFSET;
		defparam usequencer.MEM_TINIT_CK                      = MEM_TINIT_CK;
		defparam usequencer.MEM_TMRD_CK                       = MEM_TMRD_CK;
		defparam usequencer.RDIMM                             = RDIMM;
		defparam usequencer.MR0_BL         						= MR0_BL;
		defparam usequencer.MR0_BT         						= MR0_BT;
		defparam usequencer.MR0_CAS_LATENCY						= MR0_CAS_LATENCY;
		defparam usequencer.MR0_DLL        						= MR0_DLL;
		defparam usequencer.MR0_WR         						= MR0_WR;
		defparam usequencer.MR0_PD         						= MR0_PD;
		defparam usequencer.MR1_DLL        						= MR1_DLL;
		defparam usequencer.MR1_ODS        						= MR1_ODS;
		defparam usequencer.MR1_RTT        						= MR1_RTT;
		defparam usequencer.MR1_AL         						= MR1_AL;
		defparam usequencer.MR1_WL         						= MR1_WL;
		defparam usequencer.MR1_TDQS       						= MR1_TDQS;
		defparam usequencer.MR1_QOFF       						= MR1_QOFF;
		defparam usequencer.MR2_CWL        						= MR2_CWL;
		defparam usequencer.MR2_ASR        						= MR2_ASR;
		defparam usequencer.MR2_SRT        						= MR2_SRT;
		defparam usequencer.MR2_RTT_WR     						= MR2_RTT_WR; 
		defparam usequencer.MR3_MPR_RF     						= MR3_MPR_RF; 
		defparam usequencer.MR3_MPR        						= MR3_MPR;
		defparam usequencer.RDIMM_CONFIG							= RDIMM_CONFIG;
		defparam usequencer.MEM_BURST_LENGTH					= MEM_BURST_LENGTH;
		defparam usequencer.MEM_T_WL							= MEM_T_WL;
		defparam usequencer.MEM_T_RL							= MEM_T_RL;
        defparam usequencer.READ_VALID_TIMEOUT_WIDTH           = READ_VALID_TIMEOUT_WIDTH;
        defparam usequencer.MAX_LATENCY_COUNT_WIDTH            = MAX_LATENCY_COUNT_WIDTH;
        defparam usequencer.MAX_READ_LATENCY                   = MAX_READ_LATENCY;
        defparam usequencer.MAX_WRITE_LATENCY_COUNT_WIDTH      = MAX_WRITE_LATENCY_COUNT_WIDTH;
        defparam usequencer.INIT_COUNT_WIDTH                   = INIT_COUNT_WIDTH;
        defparam usequencer.SEQ_BURST_COUNT_WIDTH              = SEQ_BURST_COUNT_WIDTH;
        defparam usequencer.VCALIB_COUNT_WIDTH                 = VCALIB_COUNT_WIDTH;
        defparam usequencer.CALIB_REG_WIDTH                    = CALIB_REG_WIDTH;
		defparam usequencer.READ_VALID_FIFO_SIZE				= READ_VALID_FIFO_SIZE;
		defparam usequencer.DELAY_PER_OPA_TAP 					= DELAY_PER_OPA_TAP;
		defparam usequencer.DELAY_PER_DCHAIN_TAP 				= DELAY_PER_DCHAIN_TAP;
		defparam usequencer.DLL_DELAY_CHAIN_LENGTH 					= DLL_DELAY_CHAIN_LENGTH;
		defparam usequencer.MEM_NUMBER_OF_RANKS = MEM_NUMBER_OF_RANKS;
		defparam usequencer.MEM_MIRROR_ADDRESSING = MEM_MIRROR_ADDRESSING;
		reg	[AFI_ADDRESS_WIDTH-1:0] afi_addr_r;
        reg	[AFI_BANK_WIDTH-1:0] afi_ba_r;
		reg	[AFI_CONTROL_WIDTH-1:0] afi_cas_n_r;
        reg	[AFI_CLK_EN_WIDTH-1:0] afi_cke_r;
        reg	[AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_r;
        reg	[AFI_ODT_WIDTH-1:0] afi_odt_r;
		reg	[AFI_CONTROL_WIDTH-1:0] afi_ras_n_r;
		reg	[AFI_CONTROL_WIDTH-1:0] afi_we_n_r;
		reg	[AFI_CONTROL_WIDTH-1:0] afi_rst_n_r;
        reg	[AFI_ADDRESS_WIDTH-1:0] seq_mux_address_r;
        reg	[AFI_BANK_WIDTH-1:0] seq_mux_bank_r;
        reg	[AFI_CHIP_SELECT_WIDTH-1:0] seq_mux_cs_n_r;
        reg	[AFI_CLK_EN_WIDTH-1:0] seq_mux_cke_r;
        reg	[AFI_ODT_WIDTH-1:0] seq_mux_odt_r;
        reg	[AFI_CONTROL_WIDTH-1:0] seq_mux_ras_n_r;
        reg	[AFI_CONTROL_WIDTH-1:0] seq_mux_cas_n_r;
        reg	[AFI_CONTROL_WIDTH-1:0] seq_mux_we_n_r;
        reg	[AFI_CONTROL_WIDTH-1:0] seq_mux_reset_n_r;
	always @(posedge pll_addr_cmd_clk)
	begin
		afi_addr_r <= afi_addr;
        afi_ba_r <= afi_ba;
        afi_cs_n_r <= afi_cs_n;
        afi_cke_r <= afi_cke;
        afi_odt_r <= afi_odt;
		afi_ras_n_r <= afi_ras_n;
		afi_cas_n_r <= afi_cas_n;
		afi_we_n_r <= afi_we_n;
		afi_rst_n_r <= afi_rst_n;
		seq_mux_address_r <= seq_mux_address;
        seq_mux_bank_r <= seq_mux_bank;
        seq_mux_cs_n_r <= seq_mux_cs_n;
        seq_mux_cke_r <= seq_mux_cke;
        seq_mux_odt_r <= seq_mux_odt;
        seq_mux_ras_n_r <= seq_mux_ras_n;
        seq_mux_cas_n_r <= seq_mux_cas_n;
        seq_mux_we_n_r <= seq_mux_we_n;
        seq_mux_reset_n_r <= seq_mux_reset_n;
	end
	ddr3_s4_uniphy_example_sim_ddr3_s4_uniphy_example_sim_e0_if0_p0_afi_mux		uafi_mux(
		.mux_sel						(mux_sel),
		.afi_address					(afi_addr_r),
		.afi_bank                       (afi_ba_r),
		.afi_cs_n                       (afi_cs_n_r),
		.afi_cke                      	(afi_cke_r),
		.afi_odt                      	(afi_odt_r),
		.afi_ras_n						(afi_ras_n_r),
		.afi_cas_n						(afi_cas_n_r),
		.afi_we_n						(afi_we_n_r),
		.afi_rst_n						(afi_rst_n_r),
		.afi_dqs_burst					(afi_dqs_burst),
		.afi_wdata						(afi_wdata),
		.afi_wdata_valid				(afi_wdata_valid),
		.afi_dm							(afi_dm),
		.afi_rdata_en					(afi_rdata_en),
		.afi_rdata_en_full				(afi_rdata_en_full),
		.afi_rdata                  	(afi_rdata),
		.afi_rdata_valid            	(afi_rdata_valid),
		.seq_mux_address                (seq_mux_address_r),
		.seq_mux_bank                   (seq_mux_bank_r),
		.seq_mux_cs_n                   (seq_mux_cs_n_r),
		.seq_mux_cke                    (seq_mux_cke_r),
		.seq_mux_odt                    (seq_mux_odt_r),
		.seq_mux_ras_n                  (seq_mux_ras_n_r),
		.seq_mux_cas_n                  (seq_mux_cas_n_r),
		.seq_mux_we_n                   (seq_mux_we_n_r),
		.seq_mux_reset_n                (seq_mux_reset_n_r),
		.seq_mux_dqs_en					(seq_mux_dqs_en),
		.seq_mux_wdata                  (seq_mux_wdata),
		.seq_mux_wdata_valid            (seq_mux_wdata_valid),
		.seq_mux_dm                     (seq_mux_dm),
		.seq_mux_rdata_en               (seq_mux_rdata_en),
		.mux_seq_rdata                  (mux_seq_rdata),
		.mux_seq_read_fifo_q            (mux_seq_read_fifo_q),
		.mux_seq_rdata_valid            (mux_seq_rdata_valid),
		.mux_phy_address                (mux_phy_address),
		.mux_phy_bank                   (mux_phy_bank),
		.mux_phy_cs_n                   (mux_phy_cs_n),
		.mux_phy_cke                    (mux_phy_cke),
		.mux_phy_odt                    (mux_phy_odt),
		.mux_phy_ras_n                  (mux_phy_ras_n),
		.mux_phy_cas_n                  (mux_phy_cas_n),
		.mux_phy_we_n                   (mux_phy_we_n),
		.mux_phy_reset_n                (mux_phy_reset_n),
		.mux_phy_dqs_en					(mux_phy_dqs_en),
		.mux_phy_wdata                  (mux_phy_wdata),
		.mux_phy_wdata_valid            (mux_phy_wdata_valid),
		.mux_phy_dm                     (mux_phy_dm),
		.mux_phy_rdata_en               (mux_phy_rdata_en),
		.mux_phy_rdata_en_full          (mux_phy_rdata_en_full),
		.phy_mux_rdata                  (phy_mux_rdata),
		.phy_mux_read_fifo_q            (phy_mux_read_fifo_q),
		.phy_mux_rdata_valid            (phy_mux_rdata_valid)
	);
	defparam uafi_mux.AFI_ADDRESS_WIDTH                  = AFI_ADDRESS_WIDTH;
	defparam uafi_mux.AFI_BANK_WIDTH                     = AFI_BANK_WIDTH;
	defparam uafi_mux.AFI_CHIP_SELECT_WIDTH              = AFI_CHIP_SELECT_WIDTH;
	defparam uafi_mux.AFI_CLK_EN_WIDTH              	 = AFI_CLK_EN_WIDTH;
	defparam uafi_mux.AFI_ODT_WIDTH              		 = AFI_ODT_WIDTH;
	defparam uafi_mux.MEM_READ_DQS_WIDTH				 = MEM_READ_DQS_WIDTH;
	defparam uafi_mux.AFI_DQS_WIDTH              		 = AFI_DQS_WIDTH;
	defparam uafi_mux.AFI_DATA_MASK_WIDTH                = AFI_DATA_MASK_WIDTH;
	defparam uafi_mux.AFI_CONTROL_WIDTH                  = AFI_CONTROL_WIDTH;
	defparam uafi_mux.AFI_DATA_WIDTH                     = AFI_DATA_WIDTH;
    ddr3_s4_uniphy_example_sim_ddr3_s4_uniphy_example_sim_e0_if0_p0_addr_cmd_datapath	uaddr_cmd_datapath(
		.clk		(pll_addr_cmd_clk),
		.reset_n	    		(reset_n_afi_clk[1]), 
		.afi_address	    	(mux_phy_address),
        .afi_bank               (mux_phy_bank),
        .afi_cs_n               (mux_phy_cs_n),
        .afi_cke                (mux_phy_cke),
        .afi_odt                (mux_phy_odt),
        .afi_ras_n              (mux_phy_ras_n),
        .afi_cas_n              (mux_phy_cas_n),
        .afi_we_n               (mux_phy_we_n),
        .afi_rst_n            	(mux_phy_reset_n),
		.phy_ddio_address		(phy_ddio_address),
		.phy_ddio_bank 		   	(phy_ddio_bank),
		.phy_ddio_cs_n    		(phy_ddio_cs_n),
		.phy_ddio_cke    		(phy_ddio_cke),
		.phy_ddio_we_n    		(phy_ddio_we_n),
		.phy_ddio_ras_n   		(phy_ddio_ras_n),
		.phy_ddio_cas_n   		(phy_ddio_cas_n),
		.phy_ddio_reset_n   	(phy_ddio_reset_n),
	.phy_ddio_odt    			(phy_ddio_odt)	
    );
        defparam uaddr_cmd_datapath.MEM_ADDRESS_WIDTH                  = MEM_ADDRESS_WIDTH;
        defparam uaddr_cmd_datapath.MEM_BANK_WIDTH                     = MEM_BANK_WIDTH;
        defparam uaddr_cmd_datapath.MEM_CHIP_SELECT_WIDTH              = MEM_CHIP_SELECT_WIDTH;
        defparam uaddr_cmd_datapath.MEM_CLK_EN_WIDTH              	   = MEM_CLK_EN_WIDTH;
        defparam uaddr_cmd_datapath.MEM_ODT_WIDTH              		   = MEM_ODT_WIDTH;
        defparam uaddr_cmd_datapath.MEM_DM_WIDTH                       = MEM_DM_WIDTH;
        defparam uaddr_cmd_datapath.MEM_CONTROL_WIDTH                  = MEM_CONTROL_WIDTH;
        defparam uaddr_cmd_datapath.MEM_DQ_WIDTH                       = MEM_DQ_WIDTH;
        defparam uaddr_cmd_datapath.MEM_READ_DQS_WIDTH                 = MEM_READ_DQS_WIDTH;
        defparam uaddr_cmd_datapath.MEM_WRITE_DQS_WIDTH                = MEM_WRITE_DQS_WIDTH;
        defparam uaddr_cmd_datapath.AFI_ADDRESS_WIDTH                  = AFI_ADDRESS_WIDTH;
        defparam uaddr_cmd_datapath.AFI_BANK_WIDTH                     = AFI_BANK_WIDTH;
        defparam uaddr_cmd_datapath.AFI_CHIP_SELECT_WIDTH              = AFI_CHIP_SELECT_WIDTH;
        defparam uaddr_cmd_datapath.AFI_CLK_EN_WIDTH              	   = AFI_CLK_EN_WIDTH;
        defparam uaddr_cmd_datapath.AFI_ODT_WIDTH              		   = AFI_ODT_WIDTH;
        defparam uaddr_cmd_datapath.AFI_DATA_MASK_WIDTH                = AFI_DATA_MASK_WIDTH;
        defparam uaddr_cmd_datapath.AFI_CONTROL_WIDTH                  = AFI_CONTROL_WIDTH;
        defparam uaddr_cmd_datapath.AFI_DATA_WIDTH                     = AFI_DATA_WIDTH;
        defparam uaddr_cmd_datapath.NUM_AC_FR_CYCLE_SHIFTS             = NUM_AC_FR_CYCLE_SHIFTS;    
    ddr3_s4_uniphy_example_sim_ddr3_s4_uniphy_example_sim_e0_if0_p0_write_datapath	uwrite_datapath(
		.pll_afi_clk			(pll_afi_clk),
		.reset_n	    		(reset_n_afi_clk[2]),
		.force_oct_off			(force_oct_off),
		.phy_ddio_oct_ena		(phy_ddio_oct_ena),
		.afi_dqs_en				(mux_phy_dqs_en),
		.afi_wdata	    		(mux_phy_wdata),
		.afi_wdata_valid	    (mux_phy_wdata_valid),
		.afi_dm    				(mux_phy_dm),
		.phy_ddio_dq	    	(phy_ddio_dq),
		.phy_ddio_dqs_en		(phy_ddio_dqs_en),
		.phy_ddio_wrdata_en 	(phy_ddio_wrdata_en),
		.phy_ddio_wrdata_mask	(phy_ddio_wrdata_mask)
    );
        defparam uwrite_datapath.MEM_ADDRESS_WIDTH                  = MEM_ADDRESS_WIDTH;
        defparam uwrite_datapath.MEM_DM_WIDTH                       = MEM_DM_WIDTH;
        defparam uwrite_datapath.MEM_CONTROL_WIDTH                  = MEM_CONTROL_WIDTH;
        defparam uwrite_datapath.MEM_DQ_WIDTH                       = MEM_DQ_WIDTH;
        defparam uwrite_datapath.MEM_READ_DQS_WIDTH                 = MEM_READ_DQS_WIDTH;
        defparam uwrite_datapath.MEM_WRITE_DQS_WIDTH                = MEM_WRITE_DQS_WIDTH;
        defparam uwrite_datapath.AFI_ADDRESS_WIDTH                  = AFI_ADDRESS_WIDTH;
        defparam uwrite_datapath.AFI_DATA_MASK_WIDTH                = AFI_DATA_MASK_WIDTH;
        defparam uwrite_datapath.AFI_CONTROL_WIDTH                  = AFI_CONTROL_WIDTH;
        defparam uwrite_datapath.AFI_DATA_WIDTH                     = AFI_DATA_WIDTH;
        defparam uwrite_datapath.AFI_DQS_WIDTH                      = AFI_DQS_WIDTH;
		defparam uwrite_datapath.NUM_WRITE_PATH_FLOP_STAGES         = NUM_WRITE_PATH_FLOP_STAGES;
	ddr3_s4_uniphy_example_sim_ddr3_s4_uniphy_example_sim_e0_if0_p0_read_datapath	uread_datapath(
		.reset_n_afi_clk				(reset_n_afi_clk[3]),
        .reset_n_resync_clk         	(reset_n_resync_clk),
		.seq_read_fifo_reset			(seq_read_fifo_reset),
		.pll_afi_clk					(pll_afi_clk),
		.pll_dqs_ena_clk				(pll_dqs_ena_clk),
		.read_capture_clk				(read_capture_clk),
		.ddio_phy_dq					(ddio_phy_dq),
		.seq_read_latency_counter		(seq_read_latency_counter),
		.seq_read_increment_vfifo_fr	(seq_read_increment_vfifo_fr),
		.seq_read_increment_vfifo_hr	(seq_read_increment_vfifo_hr),
		.seq_read_increment_vfifo_qr	(seq_read_increment_vfifo_qr),
		.force_oct_off					(force_oct_off),
		.dqs_enable_ctrl				(dqs_enable_ctrl),
		.afi_rdata_en					(mux_phy_rdata_en),
		.afi_rdata_en_full				(mux_phy_rdata_en_full),
		.afi_rdata						(phy_mux_rdata),
        .phy_mux_read_fifo_q            (phy_mux_read_fifo_q),
		.afi_rdata_valid				(phy_mux_rdata_valid),
		.seq_calib_init					(seq_calib_init_reg),
		.dqs_edge_detect				(dqs_edge_detect)
	);
	defparam uread_datapath.DEVICE_FAMILY                      	= DEVICE_FAMILY;
	defparam uread_datapath.MEM_ADDRESS_WIDTH                  	= MEM_ADDRESS_WIDTH; 
	defparam uread_datapath.MEM_DM_WIDTH                       	= MEM_DM_WIDTH; 
	defparam uread_datapath.MEM_CONTROL_WIDTH                  	= MEM_CONTROL_WIDTH; 
	defparam uread_datapath.MEM_DQ_WIDTH                       	= MEM_DQ_WIDTH; 
	defparam uread_datapath.MEM_READ_DQS_WIDTH                 	= MEM_READ_DQS_WIDTH; 
	defparam uread_datapath.MEM_WRITE_DQS_WIDTH                	= MEM_WRITE_DQS_WIDTH; 
	defparam uread_datapath.AFI_ADDRESS_WIDTH                  	= AFI_ADDRESS_WIDTH; 
	defparam uread_datapath.AFI_DATA_MASK_WIDTH                	= AFI_DATA_MASK_WIDTH; 
	defparam uread_datapath.AFI_CONTROL_WIDTH                  	= AFI_CONTROL_WIDTH; 
	defparam uread_datapath.AFI_DATA_WIDTH                     	= AFI_DATA_WIDTH; 
	defparam uread_datapath.AFI_DQS_WIDTH                     	= AFI_DQS_WIDTH;
	defparam uread_datapath.MAX_LATENCY_COUNT_WIDTH            	= MAX_LATENCY_COUNT_WIDTH;
	defparam uread_datapath.MAX_READ_LATENCY					= MAX_READ_LATENCY;
	defparam uread_datapath.READ_FIFO_READ_MEM_DEPTH			= READ_FIFO_READ_MEM_DEPTH;
	defparam uread_datapath.READ_FIFO_READ_ADDR_WIDTH			= READ_FIFO_READ_ADDR_WIDTH;
	defparam uread_datapath.READ_FIFO_WRITE_MEM_DEPTH			= READ_FIFO_WRITE_MEM_DEPTH;
	defparam uread_datapath.READ_FIFO_WRITE_ADDR_WIDTH			= READ_FIFO_WRITE_ADDR_WIDTH;
	defparam uread_datapath.READ_VALID_FIFO_SIZE                = READ_VALID_FIFO_SIZE;
	defparam uread_datapath.READ_VALID_FIFO_READ_MEM_DEPTH		= READ_VALID_FIFO_READ_MEM_DEPTH;
	defparam uread_datapath.READ_VALID_FIFO_READ_ADDR_WIDTH		= READ_VALID_FIFO_READ_ADDR_WIDTH;
	defparam uread_datapath.READ_VALID_FIFO_WRITE_MEM_DEPTH		= READ_VALID_FIFO_WRITE_MEM_DEPTH;
	defparam uread_datapath.READ_VALID_FIFO_WRITE_ADDR_WIDTH	= READ_VALID_FIFO_WRITE_ADDR_WIDTH;    	
	defparam uread_datapath.READ_VALID_FIFO_PER_DQS_WIDTH		= READ_VALID_FIFO_PER_DQS_WIDTH;
	defparam uread_datapath.NUM_SUBGROUP_PER_READ_DQS			= NUM_SUBGROUP_PER_READ_DQS;  
	defparam uread_datapath.MEM_T_RL					        = MEM_T_RL;  
	defparam uread_datapath.CALIB_REG_WIDTH				        = CALIB_REG_WIDTH;
	defparam uread_datapath.QVLD_EXTRA_FLOP_STAGES				= QVLD_EXTRA_FLOP_STAGES;
	defparam uread_datapath.QVLD_WR_ADDRESS_OFFSET				= QVLD_WR_ADDRESS_OFFSET;
	defparam uread_datapath.FAST_SIM_MODEL				= FAST_SIM_MODEL;
	ddr3_s4_uniphy_example_sim_ddr3_s4_uniphy_example_sim_e0_if0_p0_new_io_pads uio_pads (
		.reset_n_addr_cmd_clk	(reset_n_addr_cmd_clk),
		.reset_n_afi_clk		(reset_n_afi_clk[1]),
        .oct_ctl_rs_value       (oct_ctl_rs_value),
        .oct_ctl_rt_value       (oct_ctl_rt_value),
		.phy_ddio_addr_cmd_clk	(pll_addr_cmd_clk),
		.phy_ddio_address 		(phy_ddio_address),
		.phy_ddio_bank   	 	(phy_ddio_bank),
		.phy_ddio_cs_n    		(phy_ddio_cs_n),
		.phy_ddio_cke    		(phy_ddio_cke),
		.phy_ddio_odt    		(phy_ddio_odt),
		.phy_ddio_we_n    		(phy_ddio_we_n),
		.phy_ddio_ras_n   		(phy_ddio_ras_n),
		.phy_ddio_cas_n   		(phy_ddio_cas_n),
		.phy_ddio_reset_n   	(phy_ddio_reset_n),
		.phy_mem_address    	(mem_a),
		.phy_mem_bank	    	(mem_ba),
		.phy_mem_cs_n	    	(mem_cs_n),
		.phy_mem_cke	    	(mem_cke),
		.phy_mem_odt	    	(mem_odt),
		.phy_mem_we_n	    	(mem_we_n),
		.phy_mem_ras_n	    	(mem_ras_n),
		.phy_mem_cas_n	    	(mem_cas_n),
		.phy_mem_reset_n	    (mem_reset_n),
		.pll_afi_clk	    	(pll_afi_clk),
		.pll_mem_clk	    	(pll_mem_clk),
		.pll_write_clk	    	(pll_write_clk),
		.pll_dqs_ena_clk		(pll_dqs_ena_clk),
		.phy_ddio_dq	    	(phy_ddio_dq),
		.phy_ddio_dqs_en		(phy_ddio_dqs_en),
		.phy_ddio_oct_ena		(phy_ddio_oct_ena),
		.dqs_enable_ctrl		(dqs_enable_ctrl),
        .phy_ddio_wrdata_en 	(phy_ddio_wrdata_en),
        .phy_ddio_wrdata_mask   (phy_ddio_wrdata_mask),
        .phy_mem_dq             (mem_dq),
        .phy_mem_dm             (mem_dm),
        .phy_mem_ck             (mem_ck),
        .phy_mem_ck_n           (mem_ck_n),
		.mem_dqs				(mem_dqs),
		.mem_dqs_n				(mem_dqs_n),
		.dll_phy_delayctrl		(dll_phy_delayctrl),
		.ddio_phy_dq			(ddio_phy_dq),
        .read_capture_clk       (read_capture_clk)
        ,
		.scc_clk				(pll_config_clk),       
        .scc_data               (scc_data),
        .scc_dqs_ena            (scc_dqs_ena),
        .scc_dqs_io_ena         (scc_dqs_io_ena),
        .scc_dq_ena             (scc_dq_ena),
        .scc_dm_ena             (scc_dm_ena),
        .scc_upd                (scc_upd),
        .capture_strobe_tracking(capture_strobe_tracking)
    );
        defparam uio_pads.DEVICE_FAMILY                      = DEVICE_FAMILY; 		
		defparam uio_pads.OCT_SERIES_TERM_CONTROL_WIDTH		 = OCT_SERIES_TERM_CONTROL_WIDTH;
		defparam uio_pads.OCT_PARALLEL_TERM_CONTROL_WIDTH	 = OCT_PARALLEL_TERM_CONTROL_WIDTH;
        defparam uio_pads.MEM_ADDRESS_WIDTH                  = MEM_ADDRESS_WIDTH; 
        defparam uio_pads.MEM_BANK_WIDTH                     = MEM_BANK_WIDTH; 
        defparam uio_pads.MEM_CHIP_SELECT_WIDTH              = MEM_CHIP_SELECT_WIDTH; 
        defparam uio_pads.MEM_CLK_EN_WIDTH              	 = MEM_CLK_EN_WIDTH; 
        defparam uio_pads.MEM_CK_WIDTH              	 	 = MEM_CK_WIDTH; 
        defparam uio_pads.MEM_ODT_WIDTH              		 = MEM_ODT_WIDTH; 
        defparam uio_pads.MEM_DQS_WIDTH             	 	 = MEM_DQS_WIDTH; 
        defparam uio_pads.MEM_DM_WIDTH                       = MEM_DM_WIDTH; 
        defparam uio_pads.MEM_CONTROL_WIDTH                  = MEM_CONTROL_WIDTH; 
        defparam uio_pads.MEM_DQ_WIDTH                       = MEM_DQ_WIDTH; 
        defparam uio_pads.MEM_READ_DQS_WIDTH                 = MEM_READ_DQS_WIDTH; 
        defparam uio_pads.MEM_WRITE_DQS_WIDTH                = MEM_WRITE_DQS_WIDTH; 
        defparam uio_pads.AFI_ADDRESS_WIDTH                  = AFI_ADDRESS_WIDTH; 
        defparam uio_pads.AFI_BANK_WIDTH                     = AFI_BANK_WIDTH; 
        defparam uio_pads.AFI_CHIP_SELECT_WIDTH              = AFI_CHIP_SELECT_WIDTH; 
        defparam uio_pads.AFI_CLK_EN_WIDTH              	 = AFI_CLK_EN_WIDTH; 
        defparam uio_pads.AFI_ODT_WIDTH              		 = AFI_ODT_WIDTH; 
        defparam uio_pads.AFI_DATA_MASK_WIDTH                = AFI_DATA_MASK_WIDTH; 
        defparam uio_pads.AFI_CONTROL_WIDTH                  = AFI_CONTROL_WIDTH; 
        defparam uio_pads.AFI_DATA_WIDTH                     = AFI_DATA_WIDTH; 
        defparam uio_pads.AFI_DQS_WIDTH                      = AFI_DQS_WIDTH; 
        defparam uio_pads.DLL_DELAY_CTRL_WIDTH               = DLL_DELAY_CTRL_WIDTH; 
		defparam uio_pads.DQS_ENABLE_CTRL_WIDTH = READ_VALID_FIFO_WIDTH;
		defparam uio_pads.ALTDQDQS_INPUT_FREQ = ALTDQDQS_INPUT_FREQ;
		defparam uio_pads.ALTDQDQS_DELAY_CHAIN_BUFFER_MODE = ALTDQDQS_DELAY_CHAIN_BUFFER_MODE;
		defparam uio_pads.ALTDQDQS_DQS_PHASE_SETTING = ALTDQDQS_DQS_PHASE_SETTING;
		defparam uio_pads.ALTDQDQS_DQS_PHASE_SHIFT = ALTDQDQS_DQS_PHASE_SHIFT;
		defparam uio_pads.ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING = ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING;
	defparam uio_pads.FAST_SIM_MODEL		     = FAST_SIM_MODEL;
assign csr_soft_reset_req = 1'b0;
function integer ceil_log2;
	input integer value;
	begin
		value = value - 1;
		for (ceil_log2 = 0; value > 0; ceil_log2 = ceil_log2 + 1)
			value = value >> 1;
	end
endfunction
endmodule
