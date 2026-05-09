`timescale 1ns / 1ps
`timescale 1ns / 1ps
module PCIEBus_pipe_wrapper #
(
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
    parameter PCIE_RXSYNC_MODE              = 0,            
    parameter PCIE_CHAN_BOND                = 1,            
    parameter PCIE_CHAN_BOND_EN             = "TRUE",       
    parameter PCIE_LANE                     = 1,            
    parameter PCIE_LINK_SPEED               = 3,            
    parameter PCIE_REFCLK_FREQ              = 0,            
    parameter PCIE_USERCLK1_FREQ             = 2,            
    parameter PCIE_USERCLK2_FREQ             = 2,            
    parameter PCIE_TX_EIDLE_ASSERT_DELAY    = 3'd4,         
    parameter PCIE_RXEQ_MODE_GEN3           = 1,            
    parameter PCIE_OOBCLK_MODE              = 1,            
    parameter PCIE_JTAG_MODE                = 0,            
    parameter PCIE_DEBUG_MODE               = 0             
)                                                     
(                                                           
    input                           PIPE_CLK,               
    input                           PIPE_RESET_N,           
    output                          PIPE_PCLK,              
    input       [(PCIE_LANE*32)-1:0]PIPE_TXDATA,            
    input       [(PCIE_LANE*4)-1:0] PIPE_TXDATAK,           
    output      [PCIE_LANE-1:0]     PIPE_TXP,               
    output      [PCIE_LANE-1:0]     PIPE_TXN,               
    input       [PCIE_LANE-1:0]     PIPE_RXP,               
    input       [PCIE_LANE-1:0]     PIPE_RXN,               
    output      [(PCIE_LANE*32)-1:0]PIPE_RXDATA,            
    output      [(PCIE_LANE*4)-1:0] PIPE_RXDATAK,           
    input                           PIPE_TXDETECTRX,        
    input       [PCIE_LANE-1:0]     PIPE_TXELECIDLE,        
    input       [PCIE_LANE-1:0]     PIPE_TXCOMPLIANCE,      
    input       [PCIE_LANE-1:0]     PIPE_RXPOLARITY,        
    input       [(PCIE_LANE*2)-1:0] PIPE_POWERDOWN,         
    input       [ 1:0]              PIPE_RATE,              
    input       [ 2:0]              PIPE_TXMARGIN,          
    input                           PIPE_TXSWING,           
    input       [PCIE_LANE-1:0]     PIPE_TXDEEMPH,          
    input       [(PCIE_LANE*2)-1:0] PIPE_TXEQ_CONTROL,      
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET,       
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET_DEFAULT,
    input       [(PCIE_LANE*6)-1:0] PIPE_TXEQ_DEEMPH,       
    input       [(PCIE_LANE*2)-1:0] PIPE_RXEQ_CONTROL,      
    input       [(PCIE_LANE*3)-1:0] PIPE_RXEQ_PRESET,       
    input       [(PCIE_LANE*6)-1:0] PIPE_RXEQ_LFFS,         
    input       [(PCIE_LANE*4)-1:0] PIPE_RXEQ_TXPRESET,     
    input       [PCIE_LANE-1:0]     PIPE_RXEQ_USER_EN,      
    input       [(PCIE_LANE*18)-1:0]PIPE_RXEQ_USER_TXCOEFF, 
    input       [PCIE_LANE-1:0]     PIPE_RXEQ_USER_MODE,    
    output      [ 5:0]              PIPE_TXEQ_FS,           
    output      [ 5:0]              PIPE_TXEQ_LF,           
    output      [(PCIE_LANE*18)-1:0]PIPE_TXEQ_COEFF,        
    output      [PCIE_LANE-1:0]     PIPE_TXEQ_DONE,         
    output      [(PCIE_LANE*18)-1:0]PIPE_RXEQ_NEW_TXCOEFF,  
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_LFFS_SEL,     
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_ADAPT_DONE,   
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_DONE,         
    output      [PCIE_LANE-1:0]     PIPE_RXVALID,           
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS,         
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS_RST,     
    output      [PCIE_LANE-1:0]     PIPE_RXELECIDLE,        
    output      [(PCIE_LANE*3)-1:0] PIPE_RXSTATUS,          
    output      [(PCIE_LANE*3)-1:0] PIPE_RXBUFSTATUS,       
    input                           PIPE_MMCM_RST_N,        
    input       [PCIE_LANE-1:0]     PIPE_RXSLIDE,           
    output      [PCIE_LANE-1:0]     PIPE_CPLL_LOCK,         
    output      [(PCIE_LANE-1)>>2:0]PIPE_QPLL_LOCK,         
    output                          PIPE_PCLK_LOCK,         
    output      [PCIE_LANE-1:0]     PIPE_RXCDRLOCK,         
    output                          PIPE_USERCLK1,          
    output                          PIPE_USERCLK2,          
    output                          PIPE_RXUSRCLK,          
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK,          
    output      [PCIE_LANE-1:0]     PIPE_TXSYNC_DONE,       
    output      [PCIE_LANE-1:0]     PIPE_RXSYNC_DONE,       
    output      [PCIE_LANE-1:0]     PIPE_GEN3_RDY,          
    output      [PCIE_LANE-1:0]     PIPE_RXCHANISALIGNED,
    output      [PCIE_LANE-1:0]     PIPE_ACTIVE_LANE,
    input                           PIPE_PCLK_IN,           
    input                           PIPE_RXUSRCLK_IN,       
    input       [PCIE_LANE-1:0]     PIPE_RXOUTCLK_IN,       
	 input 							PIPE_DCLK_IN,
    input                           PIPE_USERCLK1_IN,       
    input                           PIPE_USERCLK2_IN,       
    input                           PIPE_OOBCLK_IN,         
    input                           PIPE_MMCM_LOCK_IN,      
    output                          PIPE_TXOUTCLK_OUT,      
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK_OUT,      
    output      [PCIE_LANE-1:0]     PIPE_PCLK_SEL_OUT,      
    output                          PIPE_GEN3_OUT,          
    input       [ 2:0]              PIPE_TXPRBSSEL,         
    input       [ 2:0]              PIPE_RXPRBSSEL,         
    input                           PIPE_TXPRBSFORCEERR,    
    input                           PIPE_RXPRBSCNTRESET,    
    input       [ 2:0]              PIPE_LOOPBACK,          
    output      [PCIE_LANE-1:0]     PIPE_RXPRBSERR,         
    output      [10:0]              PIPE_RST_FSM,           
    output      [11:0]              PIPE_QRST_FSM,          
    output      [(PCIE_LANE*31)-1:0]PIPE_RATE_FSM,          
    output      [(PCIE_LANE*6)-1:0] PIPE_SYNC_FSM_TX,       
    output      [(PCIE_LANE*7)-1:0] PIPE_SYNC_FSM_RX,       
    output      [(PCIE_LANE*7)-1:0] PIPE_DRP_FSM,           
    output      [(PCIE_LANE*6)-1:0] PIPE_TXEQ_FSM,          
    output      [(PCIE_LANE*6)-1:0] PIPE_RXEQ_FSM,          
    output      [((((PCIE_LANE-1)>>2)+1)*9)-1:0]PIPE_QDRP_FSM, 
    output                          PIPE_RST_IDLE,          
    output                          PIPE_QRST_IDLE,         
    output                          PIPE_RATE_IDLE,         
    input                           PIPE_JTAG_EN,           
    output      [PCIE_LANE-1:0]     PIPE_JTAG_RDY,          
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_0,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_1,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_2,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_3,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_4,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_5,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_6,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_7,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_8,           
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_9,           
    output      [31:0]              PIPE_DEBUG,             
    output      [(PCIE_LANE*15)-1:0] PIPE_DMONITOROUT       
);
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             reset_n_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             reset_n_reg2;
    wire                            clk_pclk_int;
	 wire                            clk_rxusrclk_int;
    wire        [PCIE_LANE-1:0]     clk_rxoutclk_int;
    wire                            clk_dclk_int;
    wire                            clk_oobclk_int;
    wire                            clk_mmcm_lock_int;
    wire                            rst_cpllreset;
    wire                            rst_cpllpd;
    wire                            rst_rxusrclk_reset;
    wire                            rst_dclk_reset;   
    wire                            rst_gtreset;
    wire                            rst_drp_start;
    wire                            rst_drp_x16x20_mode;
    wire                            rst_drp_x16;
    wire                            rst_userrdy;
    wire                            rst_txsync_start;
    wire                            rst_idle;
    wire        [ 4:0]              rst_fsm;
    wire                            gtp_rst_qpllreset;      
    wire                            gtp_rst_qpllpd;         
    wire        [(PCIE_LANE-1)>>2:0]qpllreset;          
    wire                            qpllpd;
    wire                            qrst_ovrd;
    wire                            qrst_drp_start;
    wire                            qrst_qpllreset;
    wire                            qrst_qpllpd;
    wire                            qrst_idle;
    wire        [ 3:0]              qrst_fsm;
    wire        [(PCIE_LANE*37)-1:0] jtag_sl_iport;
    wire        [(PCIE_LANE*17)-1:0] jtag_sl_oport;
    wire        [PCIE_LANE-1:0]     user_oobclk;
    wire        [PCIE_LANE-1:0]     user_resetovrd;
    wire        [PCIE_LANE-1:0]     user_txpmareset;                 
    wire        [PCIE_LANE-1:0]     user_rxpmareset;                
    wire        [PCIE_LANE-1:0]     user_rxcdrreset;
    wire        [PCIE_LANE-1:0]     user_rxcdrfreqreset;
    wire        [PCIE_LANE-1:0]     user_rxdfelpmreset;
    wire        [PCIE_LANE-1:0]     user_eyescanreset;
    wire        [PCIE_LANE-1:0]     user_txpcsreset;                   
    wire        [PCIE_LANE-1:0]     user_rxpcsreset;                 
    wire        [PCIE_LANE-1:0]     user_rxbufreset;
    wire        [PCIE_LANE-1:0]     user_resetovrd_done;
    wire        [PCIE_LANE-1:0]     user_active_lane;
    wire        [PCIE_LANE-1:0]     user_resetdone ;
    wire        [PCIE_LANE-1:0]     user_rxcdrlock;
    wire        [PCIE_LANE-1:0]     user_rx_converge; 
    wire        [PCIE_LANE-1:0]     rate_cpllpd;
    wire        [PCIE_LANE-1:0]     rate_qpllpd;
    wire        [PCIE_LANE-1:0]     rate_cpllreset;
    wire        [PCIE_LANE-1:0]     rate_qpllreset;
    wire        [PCIE_LANE-1:0]     rate_txpmareset;
    wire        [PCIE_LANE-1:0]     rate_rxpmareset;
    wire        [(PCIE_LANE*2)-1:0] rate_sysclksel;
    wire        [PCIE_LANE-1:0]     rate_pclk_sel;
    wire        [PCIE_LANE-1:0]     rate_drp_start;
    wire        [PCIE_LANE-1:0]     rate_drp_x16x20_mode;
    wire        [PCIE_LANE-1:0]     rate_drp_x16;
    wire        [PCIE_LANE-1:0]     rate_gen3;
    wire        [(PCIE_LANE*3)-1:0] rate_rate;
    wire        [PCIE_LANE-1:0]     rate_resetovrd_start;
    wire        [PCIE_LANE-1:0]     rate_txsync_start;
    wire        [PCIE_LANE-1:0]     rate_done;
    wire        [PCIE_LANE-1:0]     rate_rxsync_start;
    wire        [PCIE_LANE-1:0]     rate_rxsync;
    wire        [PCIE_LANE-1:0]     rate_idle;
    wire        [(PCIE_LANE*5)-1:0]rate_fsm;
    wire        [PCIE_LANE-1:0]     sync_txphdlyreset;
    wire        [PCIE_LANE-1:0]     sync_txphalign;    
    wire        [PCIE_LANE-1:0]     sync_txphalignen; 
    wire        [PCIE_LANE-1:0]     sync_txphinit;   
    wire        [PCIE_LANE-1:0]     sync_txdlybypass; 
    wire        [PCIE_LANE-1:0]     sync_txdlysreset;   
    wire        [PCIE_LANE-1:0]     sync_txdlyen;      
    wire        [PCIE_LANE-1:0]     sync_txsync_done;
    wire        [(PCIE_LANE*6)-1:0] sync_fsm_tx;
    wire        [PCIE_LANE-1:0]     sync_rxphalign;
    wire        [PCIE_LANE-1:0]     sync_rxphalignen;
    wire        [PCIE_LANE-1:0]     sync_rxdlybypass;
    wire        [PCIE_LANE-1:0]     sync_rxdlysreset;
    wire        [PCIE_LANE-1:0]     sync_rxdlyen;
    wire        [PCIE_LANE-1:0]     sync_rxddien;
    wire        [PCIE_LANE-1:0]     sync_rxsync_done; 
    wire        [PCIE_LANE-1:0]     sync_rxsync_donem;      
    wire        [(PCIE_LANE*7)-1:0] sync_fsm_rx;
    wire        [PCIE_LANE-1:0]     txdlysresetdone;
    wire        [PCIE_LANE-1:0]     txphaligndone;
    wire        [PCIE_LANE-1:0]     rxdlysresetdone;
    wire        [PCIE_LANE-1:0]     rxphaligndone_s;    
    wire                            txsyncallin;            
    wire                            rxsyncallin;            
    wire        [(PCIE_LANE*9)-1:0] drp_addr;
    wire        [PCIE_LANE-1:0]     drp_en;
    wire        [(PCIE_LANE*16)-1:0]drp_di;   
    wire        [PCIE_LANE-1:0]     drp_we;
    wire        [PCIE_LANE-1:0]     drp_done;
    wire        [(PCIE_LANE*3)-1:0] drp_fsm;
    wire	      [(PCIE_LANE*17)-1:0]jtag_sl_addr;
    wire        [PCIE_LANE-1:0]     jtag_sl_den;
    wire        [PCIE_LANE-1:0]     jtag_sl_en;
    wire        [(PCIE_LANE*16)-1:0]jtag_sl_di;
    wire        [PCIE_LANE-1:0]     jtag_sl_we;
    wire	      [(PCIE_LANE*9)-1:0] drp_mux_addr;
    wire        [PCIE_LANE-1:0]     drp_mux_en;
    wire        [(PCIE_LANE*16)-1:0]drp_mux_di;
    wire        [PCIE_LANE-1:0]     drp_mux_we;
    wire        [PCIE_LANE-1:0]     eq_txeq_deemph;
    wire        [(PCIE_LANE*5)-1:0] eq_txeq_precursor;
    wire        [(PCIE_LANE*7)-1:0] eq_txeq_maincursor;
    wire        [(PCIE_LANE*5)-1:0] eq_txeq_postcursor;
    wire        [PCIE_LANE-1:0]     eq_rxeq_adapt_done;
    wire        [((((PCIE_LANE-1)>>2)+1)*8)-1:0]  qdrp_addr;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_en;
    wire        [((((PCIE_LANE-1)>>2)+1)*16)-1:0] qdrp_di;   
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_we;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_done;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_qpllreset;
    wire        [((((PCIE_LANE-1)>>2)+1)*6)-1:0]  qdrp_crscode;
    wire        [((((PCIE_LANE-1)>>2)+1)*9)-1:0]  qdrp_fsm;
    wire        [(PCIE_LANE-1)>>2:0]              qpll_qplloutclk;
    wire        [(PCIE_LANE-1)>>2:0]              qpll_qplloutrefclk;
    wire        [(PCIE_LANE-1)>>2:0]              qpll_qplllock;
    wire        [((((PCIE_LANE-1)>>2)+1)*16)-1:0] qpll_do;
    wire        [(PCIE_LANE-1)>>2:0]              qpll_rdy;
    wire        [PCIE_LANE-1:0]     gt_txoutclk;
    wire        [PCIE_LANE-1:0]     gt_rxoutclk;
    wire        [PCIE_LANE-1:0]     gt_cplllock;
    wire        [PCIE_LANE-1:0]     gt_rxcdrlock;
    wire        [PCIE_LANE-1:0]     gt_txresetdone;
    wire        [PCIE_LANE-1:0]     gt_rxresetdone;
    wire        [PCIE_LANE-1:0]     gt_rxpmaresetdone;
    wire        [PCIE_LANE-1:0]     gt_rxvalid;
    wire        [PCIE_LANE-1:0]     gt_phystatus;
    wire        [(PCIE_LANE*3)-1:0] gt_rxstatus;
    wire        [(PCIE_LANE*3)-1:0] gt_rxbufstatus;
    wire        [PCIE_LANE-1:0]     gt_rxelecidle;
    wire        [PCIE_LANE-1:0]     gt_txratedone;
    wire        [PCIE_LANE-1:0]     gt_rxratedone;
    wire        [(PCIE_LANE*16)-1:0]gt_do;
    wire        [PCIE_LANE-1:0]     gt_rdy;
    wire        [PCIE_LANE-1:0]     gt_txphinitdone;  
    wire        [PCIE_LANE-1:0]     gt_txdlysresetdone;
    wire        [PCIE_LANE-1:0]     gt_txphaligndone;
    wire        [PCIE_LANE-1:0]     gt_rxdlysresetdone;
    wire        [PCIE_LANE:0]       gt_rxphaligndone;       
    wire        [PCIE_LANE-1:0]     gt_txsyncout;           
    wire        [PCIE_LANE-1:0]     gt_txsyncdone;          
    wire        [PCIE_LANE-1:0]     gt_rxsyncout;           
    wire        [PCIE_LANE-1:0]     gt_rxsyncdone;          
    wire        [PCIE_LANE-1:0]     gt_rxcommadet;                        
    wire        [(PCIE_LANE*4)-1:0] gt_rxchariscomma;                      
    wire        [PCIE_LANE-1:0]     gt_rxbyteisaligned;                   
    wire        [PCIE_LANE-1:0]     gt_rxbyterealign; 
    wire        [ 4:0]              gt_rxchbondi [PCIE_LANE:0]; 
    wire        [(PCIE_LANE*3)-1:0] gt_rxchbondlevel;
    wire        [ 4:0]              gt_rxchbondo [PCIE_LANE:0];  
    wire        [PCIE_LANE-1:0]     rxchbonden;
    wire        [PCIE_LANE-1:0]     rxchbondmaster;
    wire        [PCIE_LANE-1:0]     rxchbondslave;    
    wire        [PCIE_LANE-1:0]     oobclk; 
    localparam                      TXEQ_FS = 6'd40;        
    localparam                      TXEQ_LF = 6'd15;        
    localparam GC_XSDB_SLAVE_TYPE = (PCIE_GT_DEVICE == "GTP") ? 16'h0400 : (PCIE_GT_DEVICE == "GTH") ? 16'h004A : 16'h0046; 
    genvar                          i;                      
assign gt_rxchbondo[0]             = 5'd0;                  
assign gt_rxphaligndone[PCIE_LANE] = 1'd1;                  
assign txsyncallin                 = &(gt_txphaligndone | (~user_active_lane));     
assign rxsyncallin                 = &(gt_rxphaligndone | (~user_active_lane));  
always @ (posedge PIPE_CLK or negedge PIPE_RESET_N)
begin
    if (!PIPE_RESET_N) 
        begin
        reset_n_reg1 <= 1'd0;
        reset_n_reg2 <= 1'd0;
        end
    else
        begin
        reset_n_reg1 <= 1'd1;
        reset_n_reg2 <= reset_n_reg1;
        end   
end  
generate 
    if (PCIE_EXT_CLK == "FALSE")
        begin : pipe_clock_int
		 wire clk_pclk, clk_rxusrclk, clk_dclk, clk_oobclk, clk_mmcm_lock;
		 wire [PCIE_LANE-1:0] clk_rxoutclk;
        PCIEBus_pipe_clock #
        (
            .PCIE_ASYNC_EN                  (PCIE_ASYNC_EN),        
            .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),        
            .PCIE_LANE                      (PCIE_LANE),            
            .PCIE_LINK_SPEED                (PCIE_LINK_SPEED),      
            .PCIE_REFCLK_FREQ               (PCIE_REFCLK_FREQ),     
            .PCIE_USERCLK1_FREQ             (PCIE_USERCLK1_FREQ),   
            .PCIE_USERCLK2_FREQ             (PCIE_USERCLK2_FREQ),   
            .PCIE_OOBCLK_MODE               (PCIE_OOBCLK_MODE),     
            .PCIE_DEBUG_MODE                (PCIE_DEBUG_MODE)       
        )
        pipe_clock_i
        (
            .CLK_CLK                        (PIPE_CLK),
            .CLK_TXOUTCLK                   (gt_txoutclk[0]),       
            .CLK_RXOUTCLK_IN                (gt_rxoutclk),         
            .CLK_RST_N                      (PIPE_MMCM_RST_N),      
            .CLK_PCLK_SEL                   (rate_pclk_sel),     
            .CLK_GEN3                       (rate_gen3[0]),          
            .CLK_PCLK                       (clk_pclk),
            .CLK_RXUSRCLK                   (clk_rxusrclk),  
            .CLK_RXOUTCLK_OUT               (clk_rxoutclk),
            .CLK_DCLK                       (clk_dclk),
            .CLK_USERCLK1                   (PIPE_USERCLK1),
            .CLK_USERCLK2                   (PIPE_USERCLK2),
            .CLK_OOBCLK                     (clk_oobclk),
            .CLK_MMCM_LOCK                  (clk_mmcm_lock)
        );
		 assign clk_pclk_int =  clk_pclk;
		 assign clk_rxusrclk_int =  clk_rxusrclk;
		 assign clk_dclk_int =  clk_dclk;
		 assign clk_oobclk_int =  clk_oobclk;
		 assign clk_mmcm_lock_int =  clk_mmcm_lock;
		 generate
			 for (i = 0; i < PCIE_LANE; i = i + 1) begin : gen_clk_rxoutclk
				assign clk_rxoutclk_int[i] =  clk_rxoutclk[i];
			 end
		 endgenerate
		 assign PIPE_PCLK = clk_pclk;
		 assign PIPE_RXUSRCLK = clk_rxusrclk;
		 generate
			 for (i = 0; i < PCIE_LANE; i = i + 1) begin : gen_pipe_rxoutclk
				assign PIPE_RXOUTCLK[i] =  clk_rxoutclk[i];
			 end
		 endgenerate
        end
    else
        begin : pipe_clock_int_disable
        assign clk_pclk_int      = PIPE_PCLK_IN;
        assign clk_rxusrclk_int  = PIPE_RXUSRCLK_IN;
        assign clk_rxoutclk_int  = PIPE_RXOUTCLK_IN;
        assign clk_dclk_int      = PIPE_DCLK_IN;
        assign PIPE_USERCLK1 = PIPE_USERCLK1_IN;
        assign PIPE_USERCLK2 = PIPE_USERCLK2_IN;
        assign clk_oobclk_int    = PIPE_OOBCLK_IN;
        assign clk_mmcm_lock_int = PIPE_MMCM_LOCK_IN;
		  assign PIPE_PCLK = PIPE_PCLK_IN;
		 assign PIPE_RXUSRCLK = PIPE_RXUSRCLK_IN;
		 generate
			 for (i = 0; i < PCIE_LANE; i = i + 1) begin : gen_pipe_rxoutclk_ext
				assign PIPE_RXOUTCLK[i] =  PIPE_RXOUTCLK_IN[i];
			 end
		 endgenerate
        end
endgenerate
generate 
    if (PCIE_GT_DEVICE == "GTP")
        begin : gtp_pipe_reset
        PCIEBus_gtp_pipe_reset #
        (
            .PCIE_SIM_SPEEDUP               (PCIE_SIM_SPEEDUP),                 
            .PCIE_LANE                      (PCIE_LANE)                         
        )
        gtp_pipe_reset_i
        (
            .RST_CLK                        (clk_pclk_int),                 
            .RST_RXUSRCLK                   (clk_rxusrclk_int),
            .RST_DCLK                       (clk_dclk_int),
            .RST_RST_N                      (reset_n_reg2),
            .RST_DRP_DONE                   (drp_done),
            .RST_RXPMARESETDONE             (gt_rxpmaresetdone),
            .RST_PLLLOCK                    (&qpll_qplllock), 
            .RST_RATE_IDLE                  (rate_idle),
            .RST_RXCDRLOCK                  (user_rxcdrlock),
            .RST_MMCM_LOCK                  (clk_mmcm_lock_int),
            .RST_RESETDONE                  (user_resetdone),
            .RST_PHYSTATUS                  (gt_phystatus),
            .RST_TXSYNC_DONE                (sync_txsync_done),
            .RST_CPLLRESET                  (rst_cpllreset),                   
            .RST_CPLLPD                     (rst_cpllpd),                      
            .RST_RXUSRCLK_RESET             (rst_rxusrclk_reset),
            .RST_DCLK_RESET                 (rst_dclk_reset),
            .RST_GTRESET                    (rst_gtreset),
            .RST_DRP_START                  (rst_drp_start),
            .RST_DRP_X16                    (rst_drp_x16),
            .RST_USERRDY                    (rst_userrdy),
            .RST_TXSYNC_START               (rst_txsync_start),
            .RST_IDLE                       (rst_idle),
            .RST_FSM                        (rst_fsm)
        );
        assign gtp_rst_qpllreset   = rst_cpllreset;
        end
	 else
		begin :