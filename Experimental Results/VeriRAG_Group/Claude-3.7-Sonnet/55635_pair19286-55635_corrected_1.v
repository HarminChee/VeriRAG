`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_3_pipe_wrapper #
(
    parameter PCIE_SIM_MODE                 = "FALSE",      
    parameter PCIE_SIM_TX_EIDLE_DRIVE_LEVEL = "1",          
    parameter PCIE_GT_DEVICE                = "GTX",        
    parameter PCIE_USE_MODE                 = "1.1",        
    parameter PCIE_PLL_SEL                  = "CPLL",       
    parameter PCIE_LPM_DFE                  = "LPM",        
    parameter PCIE_EXT_CLK                  = "FALSE",      
    parameter PCIE_POWER_SAVING             = "TRUE",       
    parameter PCIE_ASYNC_EN                 = "FALSE",      
    parameter PCIE_TXBUF_EN                 = "FALSE",      
    parameter PCIE_RXBUF_EN                 = "TRUE",       
    parameter PCIE_TXSYNC_MODE              = 0,            
    parameter PCIE_RXSYNC_MODE              = 0,            
    parameter PCIE_CHAN_BOND                = 0,            
    parameter PCIE_CHAN_BOND_EN             = "TRUE",       
    parameter PCIE_LANE                     = 1,            
    parameter PCIE_LINK_SPEED               = 2,            
    parameter PCIE_REFCLK_FREQ              = 0,            
    parameter PCIE_USERCLK1_FREQ            = 2,            
    parameter PCIE_USERCLK2_FREQ            = 2,            
    parameter PCIE_DEBUG_MODE               = 0             
)
(                                                           
    input                           PIPE_CLK,               
    input                           PIPE_RESET_N,
	input 							scan_clk,
	input 							test_i,           
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
    input       [(PCIE_LANE*6)-1:0] PIPE_TXDEEMPH,          
    input       [(PCIE_LANE*2)-1:0] PIPE_TXEQ_CONTROL,      
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET,       
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET_DEFAULT,
    input       [(PCIE_LANE*2)-1:0] PIPE_RXEQ_CONTROL,      
    input       [(PCIE_LANE*3)-1:0] PIPE_RXEQ_PRESET,       
    input       [(PCIE_LANE*6)-1:0] PIPE_RXEQ_LFFS,         
    input       [(PCIE_LANE*4)-1:0] PIPE_RXEQ_TXPRESET,     
    output      [ 5:0]              PIPE_TXEQ_FS,           
    output      [ 5:0]              PIPE_TXEQ_LF,           
    output      [(PCIE_LANE*18)-1:0]PIPE_TXEQ_DEEMPH,       
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
    input                           PIPE_DCLK_IN,           
    input                           PIPE_USERCLK1_IN,       
    input                           PIPE_USERCLK2_IN,       
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
    output      [(PCIE_LANE*24)-1:0]PIPE_RATE_FSM,          
    output      [(PCIE_LANE*6)-1:0] PIPE_SYNC_FSM_TX,       
    output      [(PCIE_LANE*7)-1:0] PIPE_SYNC_FSM_RX,       
    output      [(PCIE_LANE*7)-1:0] PIPE_DRP_FSM,           
    output      [(PCIE_LANE*5)-1:0] PIPE_TXEQ_FSM,          
    output      [(PCIE_LANE*6)-1:0] PIPE_RXEQ_FSM,          
    output      [((((PCIE_LANE-1)>>2)+1)*7)-1:0]PIPE_QDRP_FSM, 
    output                          PIPE_RST_IDLE,          
    output                          PIPE_QRST_IDLE,         
    output                          PIPE_RATE_IDLE,         
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
    output      [(PCIE_LANE*8)-1:0] PIPE_DMONITOROUT        
);
    reg                             reset_n_reg1;
    reg                             reset_n_reg2;
    wire                            clk_pclk_unbuf, clk_rxusrclk_unbuf, clk_dclk_unbuf;
    wire        [PCIE_LANE-1:0]     clk_rxoutclk_unbuf;
    wire                            clk_pclk, clk_rxusrclk;
    wire        [PCIE_LANE-1:0]     clk_rxoutclk;
    wire                            clk_dclk;
    wire                            clk_mmcm_lock;
	wire 							dft_clk_pclk, dft_clk_rxusrclk, dft_clk_dclk;
	wire 							dft_clk_rxoutclk [PCIE_LANE-1:0];
    wire                            rst_cpllreset;
    wire                            rst_cpllpd;
    wire                            rst_rxusrclk_reset;
    wire                            rst_dclk_reset;
    wire                            rst_gtreset;
    wire                            rst_userrdy;
    wire                            rst_txsync_start;
    wire                            rst_idle;
    wire        [10:0]              rst_fsm;
    wire                            qrst_ovrd;
    wire                            qrst_drp_start;
    wire                            qrst_qpllreset;
    wire                            qrst_qpllpd;
    wire                            qrst_idle;
    wire        [11:0]              qrst_fsm;
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
    wire        [PCIE_LANE-1:0]     user_resetdone;
    wire        [PCIE_LANE-1:0]     user_rxcdrlock;
    wire        [PCIE_LANE-1:0]     rate_cpllpd;
    wire        [PCIE_LANE-1:0]     rate_qpllpd;
    wire        [PCIE_LANE-1:0]     rate_cpllreset;
    wire        [PCIE_LANE-1:0]     rate_qpllreset;
    wire        [PCIE_LANE-1:0]     rate_txpmareset;
    wire        [PCIE_LANE-1:0]     rate_rxpmareset;
    wire        [(PCIE_LANE*2)-1:0] rate_sysclksel;
    wire        [PCIE_LANE-1:0]     rate_drp_start;
    wire        [PCIE_LANE-1:0]     rate_pclk_sel;
    wire        [PCIE_LANE-1:0]     rate_gen3;
    wire        [(PCIE_LANE*3)-1:0] rate_rate;
    wire        [PCIE_LANE-1:0]     rate_resetovrd_start;
    wire        [PCIE_LANE-1:0]     rate_txsync_start;
    wire        [PCIE_LANE-1:0]     rate_done;
    wire        [PCIE_LANE-1:0]     rate_rxsync_start;
    wire        [PCIE_LANE-1:0]     rate_rxsync;
    wire        [PCIE_LANE-1:0]     rate_idle;
    wire        [(PCIE_LANE*24)-1:0]rate_fsm;
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
    wire        [(PCIE_LANE*7)-1:0] drp_fsm;
    wire        [PCIE_LANE-1:0]     eq_txeq_deemph;
    wire        [(PCIE_LANE*5)-1:0] eq_txeq_precursor;
    wire        [(PCIE_LANE*7)-1:0] eq_txeq_maincursor;
    wire        [(PCIE_LANE*5)-1:0] eq_txeq_postcursor;
    wire        [((((PCIE_LANE-1)>>2)+1)*8)-1:0]  qdrp_addr;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_en;
    wire        [((((PCIE_LANE-1)>>2)+1)*16)-1:0] qdrp_di;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_we;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_done;
    wire        [((((PCIE_LANE-1)>>2)+1)*6)-1:0]  qdrp_crscode;
    wire        [((((PCIE_LANE-1)>>2)+1)*7)-1:0]  qdrp_fsm;
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
    localparam                      TXEQ_FS = 6'd63;        
    localparam                      TXEQ_LF = 6'd1;         
    genvar                          i;                      
assign gt_rxchbondo[0]             = 5'd0;                  
assign gt_rxphaligndone[PCIE_LANE] = 1'd1;                  
assign txsyncallin                 = &gt_txphaligndone;     
assign rxsyncallin                 = &gt_rxphaligndone;     

assign dft_clk_pclk = test_i ? scan_clk : clk_pclk_unbuf;
assign dft_clk_rxusrclk = test_i ? scan_clk : clk_rxusrclk_unbuf;
assign dft_clk_dclk = test_i ? scan_clk : clk_dclk_unbuf;
generate 
	for (i=0; i<PCIE_LANE; i=i+1) begin : gen_dft_rxoutclk
		assign clk_rxoutclk_unbuf[i] = gt_rxoutclk[i];
		assign dft_clk_rxoutclk[i] = test_i ? scan_clk : clk_rxoutclk_unbuf[i];
	end
endgenerate

assign clk_pclk = dft_clk_pclk;
assign clk_rxusrclk = dft_clk_rxusrclk;
assign clk_dclk = dft_clk_dclk;
generate
	for (i=0; i<PCIE_LANE; i=i+1) begin : gen_clk_rxoutclk
		assign clk_rxoutclk[i] = dft_clk_rxoutclk[i];
	end
endgenerate

always @ (posedge PIPE_CLK)
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
        pcie_7x_v1_3_pipe_clock #
        (
            .PCIE_USE_MODE                  (PCIE_USE_MODE),        
            .PCIE_ASYNC_EN                  (PCIE_ASYNC_EN),        
            .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),        
            .PCIE_LANE                      (PCIE_LANE),            
            .PCIE_LINK_SPEED                (PCIE_LINK_SPEED),      
            .PCIE_REFCLK_FREQ               (PCIE_REFCLK_FREQ),     
            .PCIE_USERCLK1_FREQ             (PCIE_USERCLK1_FREQ),   
            .PCIE_USERCLK2_FREQ             (PCIE_USERCLK2_FREQ),   
            .PCIE_DEBUG_MODE                (PCIE_DEBUG_MODE)       
        )
        pipe_clock_i
        (
            .CLK_CLK                        (PIPE_CLK),
            .CLK_TXOUTCLK                   (gt_txoutclk[0]),       
            .CLK_RXOUTCLK_IN                (gt_rxoutclk),
            .CLK_RST_N                      (1'b1),
            .CLK_PCLK_SEL                   (rate_pclk_sel),
            .CLK_GEN3                       (rate_gen3[0]),
            .CLK_PCLK                       (clk_pclk_unbuf),
            .CLK_RXUSRCLK                   (clk_rxusrclk_unbuf),
            .CLK_RXOUTCLK_OUT               (clk_rxoutclk_unbuf),
            .CLK_DCLK                       (clk_dclk_unbuf),
            .CLK_USERCLK1                   (PIPE_USERCLK1),
            .CLK_USERCLK2                   (PIPE_USERCLK2),
            .CLK_MMCM_LOCK                  (clk_mmcm_lock)
        );
        end
    else
        begin : pipe_clock_int_disable
        assign clk_pclk_unbuf      = PIPE_PCLK_IN;
        assign clk_rxusrclk_unbuf  = PIPE_RXUSRCLK_IN;
        assign clk_rxoutclk_unbuf  = PIPE_RXOUTCLK_IN;
        assign clk_dclk_unbuf      = PIPE_DCLK_IN;
        assign PIPE_USERCLK1 = PIPE_USERCLK1_IN;
        assign PIPE_USERCLK2 = PIPE_USERCLK2_IN;
        assign clk_mmcm_lock = PIPE_MMCM_LOCK_IN;
        end
endgenerate
pcie_7x_v1_3_pipe_reset #
(
    .PCIE_PLL_SEL                   (PCIE_PLL_SEL),         
    .PCIE_POWER_SAVING              (PCIE_POWER_SAVING),    
    .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),        
    .PCIE_LANE                      (PCIE_LANE)             
)
pipe_reset_i
(
    .RST_CLK                        (clk_pclk),
    .RST_RXUSRCLK                   (clk_rxusrclk),
    .RST_DCLK                       (clk_dclk),
    .RST_RST_N                      (reset_n_reg2),
    .RST_CPLLLOCK                   (gt_cplllock),
    .RST_QPLL_IDLE                  (qrst_idle),
    .RST_RATE_IDLE                  (rate_idle),
    .RST_RXCDRLOCK                  (user_rxcdrlock),
    .RST_MMCM_LOCK                  (clk_mmcm_lock),
    .RST_RESETDONE                  (user_resetdone),
    .RST_PHYSTATUS                  (gt_phystatus),
    .RST_TXSYNC_DONE                (sync_txsync_done),
    .RST_CPLLRESET                  (rst_cpllreset),
    .RST_CPLLPD                     (rst_cpllpd),
    .RST_RXUSRCLK_RESET             (rst_rxusrclk_reset),
    .RST_DCLK_RESET                 (rst_dclk_reset),
    .RST_GTRESET                    (rst_gtreset),
    .RST_USERRDY                    (rst_userrdy),
    .RST_TXSYNC_START               (rst_txsync_start),
    .RST_IDLE                       (rst_idle),
    .RST_FSM                        (rst_fsm)
);
generate
    if ((PCIE_LINK_SPEED == 3) || (PCIE_PLL_SEL == "QPLL"))
        begin : qpll_reset
        pcie_7x_v1_3_qpll_reset #
        (
            .PCIE_PLL_SEL                   (PCIE_PLL_SEL),     
            .PCIE_POWER_SAVING              (PCIE_POWER_SAVING),
            .PCIE_LANE                      (PCIE_LANE)         
        )
        qpll_reset_i
        (
            .QRST_CLK                       (clk_pclk),
            .QRST_RST_N                     (reset_n_reg2),
            .QRST_MMCM_LOCK                 (clk_mmcm_lock),
            .QRST_CPLLLOCK                  (gt_cplllock),
            .QRST_DRP_DONE                  (qdrp_done),
            .QRST_QPLLLOCK                  (qpll_qplllock),
            .QRST_RATE                      (PIPE_RATE),
            .QRST_QPLLRESET_IN              (rate_qpllreset),
            .QRST_QPLLPD_IN                 (rate_qpllpd),
            .QRST_OVRD                      (qrst_ovrd),
            .QRST_DRP_START                 (qrst_drp_start),
            .QRST_QPLLRESET_OUT             (qrst_qpllreset),
            .QRST_QPLLPD_OUT                (qrst_qpllpd),
            .QRST_IDLE                      (qrst_idle),
            .QRST_FSM                       (qrst_fsm)
        );
        end
    else
        begin : qpll_reset_disable
        assign qrst_ovrd      =  1'd0;
        assign qrst_drp_start =  1'd0;
        assign qrst_qpllreset =  1'd0;
        assign qrst_qpllpd    =  1'd0;
        assign qrst_idle      =  1'd0;
        assign qrst_fsm       = 12'd1;
        end
endgenerate
generate for (i=0; i<PCIE_LANE; i=i+1)
    begin : pipe_lane
    pcie_7x_v1_3_pipe_user #
    (
        .PCIE_USE_MODE                  (PCIE_USE_MODE)
    )
    pipe_user_i
    (
        .USER_TXUSRCLK                  (clk_pclk),
        .USER_RXUSRCLK                  (clk_rxusrclk),
        .USER_RST_N                     (!rst_cpllreset),
        .USER_RXUSRCLK_RST_N            (!rst_rxusrclk_reset),
        .USER_RESETOVRD_START           (rate_resetovrd_start[i]),
        .USER_TXRESETDONE               (gt_txresetdone[i]),
        .USER_RXRESETDONE               (gt_rxresetdone[i]),
        .USER_TXELECIDLE                (PIPE_TXELECIDLE[i]),
        .USER_TXCOMPLIANCE              (PIPE_TXCOMPLIANCE[i]),
        .USER_RXCDRLOCK_IN              (gt_rxcdrlock[i]),
        .USER_RXVALID_IN                (gt_rxvalid[i]),
        .USER_RXSTATUS_IN               (gt_rxstatus[(3*i)+2]),
        .USER_PHYSTATUS_IN              (gt_phystatus[i]),
        .USER_RATE_DONE                 (rate_done[i]),
        .USER_RST_IDLE                  (rst_idle),
        .USER_RATE_RXSYNC               (rate_rxsync[i]),
        .USER_RATE_IDLE                 (rate_idle[i]),
        .USER_RATE_GEN3                 (rate_gen3[i]),
        .USER_RESETOVRD                 (user_resetovrd[i]),
        .USER_TXPMARESET                (user_txpmareset[i]),
        .USER_RXPMARESET                (user_rxpmareset[i]),
        .USER_RXCDRRESET                (user_rxcdrreset[i]),
        .USER_RXCDRFREQRESET            (user_rxcdrfreqreset[i]),
        .USER_RXDFELPMRESET             (user_rxdfelpmreset[i]),
        .USER_EYESCANRESET              (user_eyescanreset[i]),
        .USER_TXPCSRESET                (user_txpcsreset[i]),
        .USER_RXPCSRESET                (user_rxpcsreset[i]),
        .USER_RXBUFRESET                (user_rxbufreset[i]),
        .USER_RESETOVRD_DONE            (user_resetovrd_done[i]),
        .USER_RESETDONE                 (user_resetdone[i]),
        .USER_ACTIVE_LANE