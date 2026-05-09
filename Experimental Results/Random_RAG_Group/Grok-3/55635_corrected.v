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
    wire                            clk_pclk;
    wire                            clk_rxusrclk;
    wire        [PCIE_LANE-1:0]     clk_rxoutclk;
    wire                            clk_dclk;
    wire                            clk_mmcm_lock;
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
always @ (posedge clk_pclk)
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
            .CLK_PCLK                       (clk_pclk),
            .CLK_RXUSRCLK                   (clk_rxusrclk),
            .CLK_RXOUTCLK_OUT               (clk_rxoutclk),
            .CLK_DCLK                       (clk_dclk),
            .CLK_USERCLK1                   (PIPE_USERCLK1),
            .CLK_USERCLK2                   (PIPE_USERCLK2),
            .CLK_MMCM_LOCK                  (clk_mmcm_lock)
        );
        end
    else
        begin : pipe_clock_int_disable
        assign clk_pclk      = PIPE_PCLK_IN;
        assign clk_rxusrclk  = PIPE_RXUSRCLK_IN;
        assign clk_rxoutclk  = PIPE_RXOUTCLK_IN;
        assign clk_dclk      = PIPE_DCLK_IN;
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
        .USER_ACTIVE_LANE               (user_active_lane[i]),
        .USER_RXCDRLOCK_OUT             (user_rxcdrlock[i]),
        .USER_RXVALID_OUT               (PIPE_RXVALID[i]),
        .USER_PHYSTATUS_OUT             (PIPE_PHYSTATUS[i]),
        .USER_PHYSTATUS_RST             (PIPE_PHYSTATUS_RST[i]),
        .USER_GEN3_RDY                  (PIPE_GEN3_RDY[i])
    );
    pcie_7x_v1_3_pipe_rate #
    (
        .PCIE_USE_MODE                  (PCIE_USE_MODE),    
        .PCIE_PLL_SEL                   (PCIE_PLL_SEL),     
        .PCIE_POWER_SAVING              (PCIE_POWER_SAVING),
        .PCIE_ASYNC_EN                  (PCIE_ASYNC_EN),    
        .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),    
        .PCIE_RXBUF_EN                  (PCIE_RXBUF_EN)     
    )
    pipe_rate_i
    (
        .RATE_CLK                       (clk_pclk),
        .RATE_RST_N                     (!rst_cpllreset),
        .RATE_RST_IDLE                  (rst_idle),
        .RATE_RATE_IN                   (PIPE_RATE),
        .RATE_CPLLLOCK                  (gt_cplllock[i]),
        .RATE_QPLLLOCK                  (qpll_qplllock[i>>2]),
        .RATE_MMCM_LOCK                 (clk_mmcm_lock),
        .RATE_DRP_DONE                  (drp_done[i]),
        .RATE_TXRESETDONE               (gt_txresetdone[i]),
        .RATE_RXRESETDONE               (gt_rxresetdone[i]),
        .RATE_TXRATEDONE                (gt_txratedone[i]),
        .RATE_RXRATEDONE                (gt_rxratedone[i]),
        .RATE_PHYSTATUS                 (gt_phystatus[i]),
        .RATE_RESETOVRD_DONE            (user_resetovrd_done[i]),
        .RATE_TXSYNC_DONE               (sync_txsync_done[i]),
        .RATE_RXSYNC_DONE               (sync_rxsync_done[i]),
        .RATE_CPLLPD                    (rate_cpllpd[i]),
        .RATE_QPLLPD                    (rate_qpllpd[i]),
        .RATE_CPLLRESET                 (rate_cpllreset[i]),
        .RATE_QPLLRESET                 (rate_qpllreset[i]),
        .RATE_TXPMARESET                (rate_txpmareset[i]),
        .RATE_RXPMARESET                (rate_rxpmareset[i]),
        .RATE_SYSCLKSEL                 (rate_sysclksel[(2*i)+1:(2*i)]),
        .RATE_DRP_START                 (rate_drp_start[i]),
        .RATE_PCLK_SEL                  (rate_pclk_sel[i]),
        .RATE_GEN3                      (rate_gen3[i]),
        .RATE_RATE_OUT                  (rate_rate[(3*i)+2:(3*i)]),
        .RATE_RESETOVRD_START           (rate_resetovrd_start[i]),
        .RATE_TXSYNC_START              (rate_txsync_start[i]),
        .RATE_DONE                      (rate_done[i]),
        .RATE_RXSYNC_START              (rate_rxsync_start[i]),
        .RATE_RXSYNC                    (rate_rxsync[i]),
        .RATE_IDLE                      (rate_idle[i]),
        .RATE_FSM                       (rate_fsm[(24*i)+23:(24*i)])
    );
    pcie_7x_v1_3_pipe_sync #
    (
        .PCIE_GT_DEVICE                 (PCIE_GT_DEVICE),   
        .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),    
        .PCIE_RXBUF_EN                  (PCIE_RXBUF_EN),    
        .PCIE_TXSYNC_MODE               (PCIE_TXSYNC_MODE), 
        .PCIE_RXSYNC_MODE               (PCIE_RXSYNC_MODE), 
        .PCIE_LANE                      (PCIE_LANE),        
        .PCIE_LINK_SPEED                (PCIE_LINK_SPEED)   
    )
    pipe_sync_i
    (
        .SYNC_CLK                       (clk_pclk),
        .SYNC_RST_N                     (!rst_cpllreset),
        .SYNC_SLAVE                     (i > 0),
        .SYNC_GEN3                      (rate_gen3[i]),
        .SYNC_RATE_IDLE                 (rate_idle[i]),
        .SYNC_MMCM_LOCK                 (clk_mmcm_lock),
        .SYNC_RXELECIDLE                (gt_rxelecidle[i]),
        .SYNC_RXCDRLOCK                 (user_rxcdrlock[i]),
        .SYNC_TXSYNC_START              (rate_txsync_start[i] || rst_txsync_start),
        .SYNC_TXPHINITDONE              (&gt_txphinitdone),
        .SYNC_TXDLYSRESETDONE           (txdlysresetdone[i]),
        .SYNC_TXPHALIGNDONE             (txphaligndone[i]),
        .SYNC_TXSYNCDONE                (gt_txsyncdone[i]), 
        .SYNC_RXSYNC_START              (rate_rxsync_start[i]),
        .SYNC_RXDLYSRESETDONE           (rxdlysresetdone[i]),
        .SYNC_RXPHALIGNDONE_M           (gt_rxphaligndone[0]),
        .SYNC_RXPHALIGNDONE_S           (rxphaligndone_s[i]),
        .SYNC_RXSYNC_DONEM_IN           (sync_rxsync_donem[0]),
        .SYNC_RXSYNCDONE                (gt_rxsyncdone[i]), 
        .SYNC_TXPHDLYRESET              (sync_txphdlyreset[i]),
        .SYNC_TXPHALIGN                 (sync_txphalign[i]),
        .SYNC_TXPHALIGNEN               (sync_txphalignen[i]),
        .SYNC_TXPHINIT                  (sync_txphinit[i]),
        .SYNC_TXDLYBYPASS               (sync_txdlybypass[i]),
        .SYNC_TXDLYSRESET               (sync_txdlysreset[i]),
        .SYNC_TXDLYEN                   (sync_txdlyen[i]),
        .SYNC_TXSYNC_DONE               (sync_txsync_done[i]),
        .SYNC_FSM_TX                    (sync_fsm_tx[(6*i)+5:(6*i)]),
        .SYNC_RXPHALIGN                 (sync_rxphalign[i]),
        .SYNC_RXPHALIGNEN               (sync_rxphalignen[i]),
        .SYNC_RXDLYBYPASS               (sync_rxdlybypass[i]),
        .SYNC_RXDLYSRESET               (sync_rxdlysreset[i]),
        .SYNC_RXDLYEN                   (sync_rxdlyen[i]),
        .SYNC_RXDDIEN                   (sync_rxddien[i]),
        .SYNC_RXSYNC_DONEM_OUT          (sync_rxsync_donem[i]),
        .SYNC_RXSYNC_DONE               (sync_rxsync_done[i]),
        .SYNC_FSM_RX                    (sync_fsm_rx[(7*i)+6:(7*i)])
    );
    assign txdlysresetdone[i] = (PCIE_TXSYNC_MODE == 1) ? gt_txdlysresetdone[i] : &gt_txdlysresetdone;
    assign txphaligndone[i]   = (PCIE_TXSYNC_MODE == 1) ? gt_txphaligndone[i]   : &gt_txphaligndone;
    assign rxdlysresetdone[i] = (PCIE_RXSYNC_MODE == 1) ? gt_rxdlysresetdone[i] : &gt_rxdlysresetdone;
    assign rxphaligndone_s[i] = (PCIE_LANE == 1)        ? 1'd0                  : &gt_rxphaligndone[PCIE_LANE:1];
    pcie_7x_v1_3_pipe_drp #
    (
        .PCIE_USE_MODE                  (PCIE_USE_MODE),    
        .PCIE_PLL_SEL                   (PCIE_PLL_SEL),     
        .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),    
        .PCIE_RXBUF_EN                  (PCIE_RXBUF_EN),    
        .PCIE_TXSYNC_MODE               (PCIE_TXSYNC_MODE), 
        .PCIE_RXSYNC_MODE               (PCIE_RXSYNC_MODE)  
    )
    pipe_drp_i
    (
        .DRP_CLK                        (clk_dclk),
        .DRP_RST_N                      (!rst_dclk_reset),
        .DRP_GTXRESET                   (rst_gtreset),
        .DRP_RATE                       (PIPE_RATE),
        .DRP_START                      (rate_drp_start[i]),
        .DRP_DO                         (gt_do[(16*i)+15:(16*i)]),
        .DRP_RDY                        (gt_rdy[i]),
        .DRP_ADDR                       (drp_addr[(9*i)+8:(9*i)]),
        .DRP_EN                         (drp_en[i]),
        .DRP_DI                         (drp_di[(16*i)+15:(16*i)]),
        .DRP_WE                         (drp_we[i]),
        .DRP_DONE                       (drp_done[i]),
        .DRP_FSM                        (drp_fsm[(7*i)+6:(7*i)])
    );
    if (PCIE_LINK_SPEED == 3)
        begin : pipe_eq
        pcie_7x_v1_3_pipe_eq
        pipe_eq_i
        (
            .EQ_CLK                         (clk_pclk),
            .EQ_RST_N                       (!rst_cpllreset),
            .EQ_GEN3                        (rate_gen3[i]),
            .EQ_TXEQ_CONTROL                (PIPE_TXEQ_CONTROL[(2*i)+1:(2*i)]),
            .EQ_TXEQ_PRESET                 (PIPE_TXEQ_PRESET[(4*i)+3:(4*i)]),
            .EQ_TXEQ_PRESET_DEFAULT         (PIPE_TXEQ_PRESET_DEFAULT[(4*i)+3:(4*i)]),
            .EQ_TXEQ_DEEMPH_IN              (PIPE_TXDEEMPH[(6*i)+5:(6*i)]),
            .EQ_RXEQ_CONTROL                (PIPE_RXEQ_CONTROL[(2*i)+1:(2*i)]),
            .EQ_RXEQ_PRESET                 (PIPE_RXEQ_PRESET[(3*i)+2:(3*i)]),
            .EQ_RXEQ_LFFS                   (PIPE_RXEQ_LFFS[(6*i)+5:(6*i)]),
            .EQ_RXEQ_TXPRESET               (PIPE_RXEQ_TXPRESET[(4*i)+3:(4*i)]),
            .EQ_TXEQ_DEEMPH                 (eq_txeq_deemph[i]),
            .EQ_TXEQ_PRECURSOR              (eq_txeq_precursor[(5*i)+4:(5*i)]),
            .EQ_TXEQ_MAINCURSOR             (eq_txeq_maincursor[(7*i)+6:(7*i)]),
            .EQ_TXEQ_POSTCURSOR             (eq_txeq_postcursor[(5*i)+4:(5*i)]),
            .EQ_TXEQ_DEEMPH_OUT             (PIPE_TXEQ_DEEMPH[(18*i)+17:(18*i)]),
            .EQ_TXEQ_DONE                   (PIPE_TXEQ_DONE[i]),
            .EQ_TXEQ_FSM                    (PIPE_TXEQ_FSM[(5*i)+4:(5*i)]),
            .EQ_RXEQ_NEW_TXCOEFF            (PIPE_RXEQ_NEW_TXCOEFF[(18*i)+17:(18*i)]),
            .EQ_RXEQ_LFFS_SEL               (PIPE_RXEQ_LFFS_SEL[i]),
            .EQ_RXEQ_ADAPT_DONE             (PIPE_RXEQ_ADAPT_DONE[i]),
            .EQ_RXEQ_DONE                   (PIPE_RXEQ_DONE[i]),
            .EQ_RXEQ_FSM                    (PIPE_RXEQ_FSM[(6*i)+5:(6*i)])
        );
        end
    else
        begin : pipe_eq_disable
        assign eq_txeq_deemph[i]                       =  1'd0;
        assign eq_txeq_precursor[(5*i)+4:(5*i)]        =  5'h00;
        assign eq_txeq_maincursor[(7*i)+6:(7*i)]       =  7'h00;
        assign eq_txeq_postcursor[(5*i)+4:(5*i)]       =  5'h00;
        assign PIPE_TXEQ_DEEMPH[(18*i)+17:(18*i)]      = 18'd0;
        assign PIPE_TXEQ_DONE[i]                       =  1'd0;
        assign PIPE_TXEQ_FSM[(5*i)+4:(5*i)]            =  5'd0;
        assign PIPE_RXEQ_NEW_TXCOEFF[(18*i)+17:(18*i)] = 18'd0;
        assign PIPE_RXEQ_LFFS_SEL[i]                   =  1'd0;
        assign PIPE_RXEQ_ADAPT_DONE[i]                 =  1'd0;
        assign PIPE_RXEQ_DONE[i]                       =  1'd0;
        assign PIPE_RXEQ_FSM[(6*i)+5:(6*i)]            =  5'd0;
        end
    if ((i%4)==0)
        begin : pipe_quad
        if ((PCIE_LINK_SPEED == 3) || (PCIE_PLL_SEL == "QPLL"))
            begin : pipe_common
            pcie_7x_v1_3_qpll_drp #
            (
                .PCIE_PLL_SEL                   (PCIE_PLL_SEL),                 
                .PCIE_REFCLK_FREQ               (PCIE_REFCLK_FREQ)              
            )
            qpll_drp_i
            (
                .DRP_CLK                        (clk_dclk),
                .DRP_RST_N                      (!rst_dclk_reset),
                .DRP_OVRD                       (qrst_ovrd),
                .DRP_GEN3                       (&rate_gen3),
                .DRP_START                      (qrst_drp_start),
                .DRP_DO                         (qpll_do[(16*(i>>2))+15:(16*(i>>2))]),
                .DRP_RDY                        (qpll_rdy[i>>2]),
                .DRP_ADDR                       (qdrp_addr[(8*(i>>2))+7:(8*(i>>2))]),
                .DRP_EN                         (qdrp_en[i>>2]),
                .DRP_DI                         (qdrp_di[(16*(i>>2))+15:(16*(i>>2))]),
                .DRP_WE                         (qdrp_we[i>>2]),
                .DRP_DONE                       (qdrp_done[i>>2]),
                .DRP_CRSCODE                    (qdrp_crscode[(6*(i>>2))+5:(6*(i>>2))]),
                .DRP_FSM                        (qdrp_fsm[(7*(i>>2))+6:(7*(i>>2))])
            );
            pcie_7x_v1_3_qpll_wrapper #
            (
                .PCIE_SIM_MODE                  (PCIE_SIM_MODE),                
                .PCIE_GT_DEVICE                 (PCIE_GT_DEVICE),               
                .PCIE_USE_MODE                  (PCIE_USE_MODE),                
                .PCIE_PLL_SEL                   (PCIE_PLL_SEL),                 
                .PCIE_REFCLK_FREQ               (PCIE_REFCLK_FREQ)              
            )
            qpll_wrapper_i
            (
                .QPLL_GTGREFCLK                 (PIPE_CLK),
                .QPLL_QPLLLOCKDETCLK            (1'd0),
                .QPLL_QPLLOUTCLK                (qpll_qplloutclk[i>>2]),
                .QPLL_QPLLOUTREFCLK             (qpll_qplloutrefclk[i>>2]),
                .QPLL_QPLLLOCK                  (qpll_qplllock[i>>2]),
                .QPLL_QPLLPD                    (qrst_qpllpd),
                .QPLL_QPLLRESET                 (qrst_qpllreset),
                .QPLL_DRPCLK                    (clk_dclk),
                .QPLL_DRPADDR                   (qdrp_addr[(8*(i>>2))+7:(8*(i>>2))]),
                .QPLL_DRPEN                     (qdrp_en[i>>2]),
                .QPLL_DRPDI                     (qdrp_di[(16*(i>>2))+15:(16*(i>>2))]),
                .QPLL_DRPWE                     (qdrp_we[i>>2]),
                .QPLL_DRPDO                     (qpll_do[(16*(i>>2))+15:(16*(i>>2))]),
                .QPLL_DRPRDY                    (qpll_rdy[i>>2])
            );
            end
        else
            begin : pipe_common_disable
            assign qdrp_addr[(8*(i>>2))+7:(8*(i>>2))]    =  8'd0;
            assign qdrp_en[i>>2]                         =  1'd0;
            assign qdrp_di[(16*(i>>2))+15:(16*(i>>2))]   = 16'd0;
            assign qdrp_we[i>>2]                         =  1'd0;
            assign qdrp_done[i>>2]                       =  1'd0;
            assign qdrp_crscode[(6*(i>>2))+5:(6*(i>>2))] =  6'd0;
            assign qdrp_fsm[(7*(i>>2))+6:(7*(i>>2))]     =  7'd0;
            assign qpll_qplloutclk[i>>2]                 =  1'd0;
            assign qpll_qplloutrefclk[i>>2]              =  1'd0;
            assign qpll_qplllock[i>>2]                   =  1'd0;
            assign qpll_do[(16*(i>>2))+15:(16*(i>>2))]   = 16'd0;
            assign qpll_rdy[i>>2]                        =  1'd0;
            end
        end
    pcie_7x_v1_3_gt_wrapper #
    (
        .PCIE_SIM_MODE                  (PCIE_SIM_MODE),                        
        .PCIE_SIM_TX_EIDLE_DRIVE_LEVEL  (PCIE_SIM_TX_EIDLE_DRIVE_LEVEL),        
        .PCIE_GT_DEVICE                 (PCIE_GT_DEVICE),                       
        .PCIE_USE_MODE                  (PCIE_USE_MODE),                        
        .PCIE_PLL_SEL                   (PCIE_PLL_SEL),                         
        .PCIE_LPM_DFE                   (PCIE_LPM_DFE),                         
        .PCIE_ASYNC_EN                  (PCIE_ASYNC_EN),                        
        .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),                        
        .PCIE_TXSYNC_MODE               (PCIE_TXSYNC_MODE),                     
        .PCIE_RXSYNC_MODE               (PCIE_RXSYNC_MODE),                     
        .PCIE_CHAN_BOND                 (PCIE_CHAN_BOND),                       
        .PCIE_CHAN_BOND_EN              (PCIE_CHAN_BOND_EN),                    
        .PCIE_LANE                      (PCIE_LANE),                            
        .PCIE_REFCLK_FREQ               (PCIE_REFCLK_FREQ),                     
        .PCIE_DEBUG_MODE                (PCIE_DEBUG_MODE)                       
    )
    gt_wrapper_i
    (
        .GT_MASTER                      (i == 0),
        .GT_GEN3                        (rate_gen3[i]),
        .GT_GTREFCLK0                   (PIPE_CLK),
        .GT_QPLLCLK                     (qpll_qplloutclk[i>>2]),
        .GT_QPLLREFCLK                  (qpll_qplloutrefclk[i>>2]),
        .GT_TXUSRCLK                    (clk_pclk),
        .GT_RXUSRCLK                    (clk_rxusrclk),
        .GT_TXUSRCLK2                   (clk_pclk),
        .GT_RXUSRCLK2                   (clk_rxusrclk),
        .GT_TXSYSCLKSEL                 (rate_sysclksel[(2*i)+1:(2*i)]),
        .GT_RXSYSCLKSEL                 (rate_sysclksel[(2*i)+1:(2*i)]),
        .GT_TXOUTCLK                    (gt_txoutclk[i]),
        .GT_RXOUTCLK                    (gt_rxoutclk[i]),
        .GT_CPLLLOCK                    (gt_cplllock[i]),
        .GT_RXCDRLOCK                   (gt_rxcdrlock[i]),
        .GT_CPLLPD                      (rst_cpllpd    || rate_cpllpd[i]),
        .GT_CPLLRESET                   (rst_cpllreset || rate_cpllreset[i]),
        .GT_TXUSERRDY                   (rst_userrdy),
        .GT_RXUSERRDY                   (rst_userrdy),
        .GT_RESETOVRD                   (user_resetovrd[i]),
        .GT_GTTXRESET                   (rst_gtreset),
        .GT_GTRXRESET                   (rst_gtreset),
        .GT_TXPMARESET                  (user_txpmareset[i] || rate_txpmareset[i]),
        .GT_RXPMARESET                  (user_rxpmareset[i] || rate_rxpmareset[i]),
        .GT_RXCDRRESET                  (user_rxcdrreset[i]),
        .GT_RXCDRFREQRESET              (user_rxcdrfreqreset[i]),
        .GT_RXDFELPMRESET               (user_rxdfelpmreset[i]),
        .GT_EYESCANRESET                (user_eyescanreset[i]),
        .GT_TXPCSRESET                  (user_txpcsreset[i]),
        .GT_RXPCSRESET                  (user_rxpcsreset[i]),
        .GT_RXBUFRESET                  (user_rxbufreset[i]),
        .GT_TXRESETDONE                 (gt_txresetdone[i]),
        .GT_RXRESETDONE                 (gt_rxresetdone[i]),
        .GT_TXDATA                      (PIPE_TXDATA[(32*i)+31:(32*i)]),
        .GT_TXDATAK                     (PIPE_TXDATAK[(4*i)+3:(4*i)]),
        .GT_TXP                         (PIPE_TXP[i]),
        .GT_TXN                         (PIPE_TXN[i]),
        .GT_RXP                         (PIPE_RXP[i]),
        .GT_RXN                         (PIPE_RXN[i]),
        .GT_RXDATA                      (PIPE_RXDATA[(32*i)+31:(32*i)]),
        .GT_RXDATAK                     (PIPE_RXDATAK[(4*i)+3:(4*i)]),
        .GT_TXDETECTRX                  (PIPE_TXDETECTRX),
        .GT_TXELECIDLE                  (PIPE_TXELECIDLE[i]),
        .GT_TXCOMPLIANCE                (PIPE_TXCOMPLIANCE[i]),
        .GT_RXPOLARITY                  (PIPE_RXPOLARITY[i]),
        .GT_TXPOWERDOWN                 (PIPE_POWERDOWN[(2*i)+1:(2*i)]),
        .GT_RXPOWERDOWN                 (PIPE_POWERDOWN[(2*i)+1:(2*i)]),
        .GT_TXRATE                      (rate_rate[(3*i)+2:(3*i)]),
        .GT_RXRATE                      (rate_rate[(3*i)+2:(3*i)]),
        .GT_TXMARGIN                    (PIPE_TXMARGIN),
        .GT_TXSWING                     (PIPE_TXSWING),
        .GT_TXDEEMPH                    (PIPE_TXDEEMPH[6*i]),
        .GT_TXPRECURSOR                 (eq_txeq_precursor[(5*i)+4:(5*i)]),
        .GT_TXMAINCURSOR                (eq_txeq_maincursor[(7*i)+6:(7*i)]),
        .GT_TXPOSTCURSOR                (eq_txeq_postcursor[(5*i)+4:(5*i)]),
        .GT_RXVALID                     (gt_rxvalid[i]),
        .GT_PHYSTATUS                   (gt_phystatus[i]),
        .GT_RXELECIDLE                  (gt_rxelecidle[i]),
        .GT_RXSTATUS                    (gt_rxstatus[(3*i)+2:(3*i)]),
        .GT_RXBUFSTATUS                 (gt_rxbufstatus[(3*i)+2:(3*i)]),
        .GT_TXRATEDONE                  (gt_txratedone[i]),
        .GT_RXRATEDONE                  (gt_rxratedone[i]),
        .GT_DRPCLK                      (clk_dclk),
        .GT_DRPADDR                     (drp_addr[(9*i)+8:(9*i)]),
        .GT_DRPEN                       (drp_en[i]),
        .GT_DRPDI                       (drp_di[(16*i)+15:(16*i)]),
        .GT_DRPWE                       (drp_we[i]),
        .GT_DRPDO                       (gt_do[(16*i)+15:(16*i)]),
        .GT_DRPRDY                      (gt_rdy[i]),
        .GT_TXPHALIGN                   (sync_txphalign[i]),
        .GT_TXPHALIGNEN                 (sync_txphalignen[i]),
        .GT_TXPHINIT                    (sync_txphinit[i]),
        .GT_TXDLYBYPASS                 (sync_txdlybypass[i]),
        .GT_TXDLYSRESET                 (sync_txdlysreset[i]),
        .GT_TXDLYEN                     (sync_txdlyen[i]),
        .GT_TXDLYSRESETDONE             (gt_txdlysresetdone[i]),
        .GT_TXPHINITDONE                (gt_txphinitdone[i]),
        .GT_TXPHALIGNDONE               (gt_txphaligndone[i]),
        .GT_TXPHDLYRESET                (sync_txphdlyreset[i]),
        .GT_TXSYNCMODE                  (i == 0),           
        .GT_TXSYNCIN                    (gt_txsyncout[0]),  
        .GT_TXSYNCALLIN                 (txsyncallin),      
        .GT_TXSYNCOUT                   (gt_txsyncout[i]),  
        .GT_TXSYNCDONE                  (gt_txsyncdone[i]), 
        .GT_RXPHALIGN                   (sync_rxphalign[i]),
        .GT_RXPHALIGNEN                 (sync_rxphalignen[i]),
        .GT_RXDLYBYPASS                 (sync_rxdlybypass[i]),
        .GT_RXDLYSRESET                 (sync_rxdlysreset[i]),
        .GT_RXDLYEN                     (sync_rxdlyen[i]),
        .GT_RXDDIEN                     (sync_rxddien[i]),
        .GT_RXDLYSRESETDONE             (gt_rxdlysresetdone[i]),
        .GT_RXPHALIGNDONE               (gt_rxphaligndone[i]),
        .GT_RXSYNCMODE                  (i == 0),           
        .GT_RXSYNCIN                    (gt_rxsyncout[0]),  
        .GT_RXSYNCALLIN                 (rxsyncallin),      
        .GT_RXSYNCOUT                   (gt_rxsyncout[i]),  
        .GT_RXSYNCDONE                  (gt_rxsyncdone[i]), 
        .GT_RXSLIDE                     (PIPE_RXSLIDE[i]),
        .GT_RXCOMMADET                  (gt_rxcommadet[i]),
        .GT_RXCHARISCOMMA               (gt_rxchariscomma[(4*i)+3:(4*i)]),
        .GT_RXBYTEISALIGNED             (gt_rxbyteisaligned[i]),
        .GT_RXBYTEREALIGN               (gt_rxbyterealign[i]),
        .GT_RXCHANISALIGNED             (PIPE_RXCHANISALIGNED[i]),
        .GT_RXCHBONDEN                  (rxchbonden[i]),
        .GT_RXCHBONDI                   (gt_rxchbondi[i]),
        .GT_RXCHBONDLEVEL               (gt_rxchbondlevel[(3*i)+2:(3*i)]),
        .GT_RXCHBONDMASTER              (rxchbondmaster[i]),
        .GT_RXCHBONDSLAVE               (rxchbondslave[i]),
        .GT_RXCHBONDO                   (gt_rxchbondo[i+1]),
        .GT_TXPRBSSEL                   (PIPE_TXPRBSSEL),
        .GT_RXPRBSSEL                   (PIPE_RXPRBSSEL),
        .GT_TXPRBSFORCEERR              (PIPE_TXPRBSFORCEERR),
        .GT_RXPRBSCNTRESET              (PIPE_RXPRBSCNTRESET),
        .GT_LOOPBACK                    (PIPE_LOOPBACK),
        .GT_RXPRBSERR                   (PIPE_RXPRBSERR[i]),
        .GT_DMONITOROUT                 (PIPE_DMONITOROUT[(8*i)+7:(8*i)])
    );
    assign rxchbonden[i]     = (PCIE_LANE > 1) && (PCIE_CHAN_BOND_EN == "TRUE") ? !rate_gen3[i] : 1'd0;
    assign rxchbondmaster[i] =  rate_gen3[i] ? 1'd0 : (i == 0);
    assign rxchbondslave[i]  =  rate_gen3[i] ? 1'd0 : (i  > 0);
    if (PCIE_CHAN_BOND == 2)
        begin : channel_bonding_a
        case (i)
        0 :
            begin
            assign gt_rxchbondi[0]         = gt_rxchbondo[0];
            assign gt_rxchbondlevel[2:0]   = (PCIE_LANE == 4'd8) ? 3'd4 :
                                             (PCIE_LANE >  4'd5) ? 3'd3 :
                                             (PCIE_LANE >  4'd3) ? 3'd2 :
                                             (PCIE_LANE >  4'd1) ? 3'd1 : 3'd0;
            end
        1 :
            begin
            assign gt_rxchbondi[1]         = gt_rxchbondo[1];
            assign gt_rxchbondlevel[5:3]   = (PCIE_LANE == 4'd8) ? 3'd3 :
                                             (PCIE_LANE >  4'd5) ? 3'd2 :
                                             (PCIE_LANE >  4'd3) ? 3'd1 : 3'd0;
            end
        2 :
            begin
            assign gt_rxchbondi[2]         = gt_rxchbondo[1];
            assign gt_rxchbondlevel[8:6]   = (PCIE_LANE == 4'd8) ? 3'd3 :
                                             (PCIE_LANE >  4'd5) ? 3'd2 :
                                             (PCIE_LANE >  4'd3) ? 3'd1 : 3'd0;
            end
        3 :
            begin
            assign gt_rxchbondi[3]         = gt_rxchbondo[3];
            assign gt_rxchbondlevel[11:9]  = (PCIE_LANE == 4'd8) ? 3'd2 :
                                             (PCIE_LANE >  4'd5) ? 3'd1 : 3'd0;
            end
        4 :
            begin
            assign gt_rxchbondi[4]         = gt_rxchbondo[3];
            assign gt_rxchbondlevel[14:12] = (PCIE_LANE == 4'd8) ? 3'd2 :
                                             (PCIE_LANE >  4'd5) ? 3'd1 : 3'd0;
            end
        5 :
            begin
            assign gt_rxchbondi[5]         = gt_rxchbondo[5];
            assign gt_rxchbondlevel[17:15] = (PCIE_LANE == 4'd8) ? 3'd1 : 3'd0;
            end
        6 :
            begin
            assign gt_rxchbondi[6]         = gt_rxchbondo[5];
            assign gt_rxchbondlevel[20:18] = (PCIE_LANE == 4'd8) ? 3'd1 : 3'd0;
            end
        7 :
            begin
            assign gt_rxchbondi[7]         = gt_rxchbondo[7];
            assign gt_rxchbondlevel[23:21] = 3'd0;
            end
        default :
            begin
            assign gt_rxchbondi[i]                 = gt_rxchbondo[7];
            assign gt_rxchbondlevel[(3*i)+2:(3*i)] = 3'd0;
            end
        endcase
        end
    else
        begin : channel_bonding_mode_b
        assign gt_rxchbondi[i]                 = (PCIE_CHAN_BOND == 1) ? gt_rxchbondo[i] : ((i == 0) ? gt_rxchbondo[0] : gt_rxchbondo[1]);
        assign gt_rxchbondlevel[(3*i)+2:(3*i)] = (PCIE_CHAN_BOND == 1) ? (PCIE_LANE-1)-i  : ((PCIE_LANE > 1) && (i == 0));
        end
    end
endgenerate
assign PIPE_TXEQ_FS      = TXEQ_FS;
assign PIPE_TXEQ_LF      = TXEQ_LF;
assign PIPE_RXELECIDLE   = gt_rxelecidle;
assign PIPE_RXSTATUS     = gt_rxstatus;
assign PIPE_RXBUFSTATUS  = gt_rxbufstatus;
assign PIPE_CPLL_LOCK    = gt_cplllock;
assign PIPE_QPLL_LOCK    = qpll_qplllock;
assign PIPE_PCLK         = clk_pclk;
assign PIPE_PCLK_LOCK    = clk_mmcm_lock;
assign PIPE_RXCDRLOCK    = user_rxcdrlock;
assign PIPE_RXUSRCLK     = clk_rxusrclk;
assign PIPE_RXOUTCLK     = clk_rxoutclk;
assign PIPE_TXSYNC_DONE  = sync_txsync_done;
assign PIPE_RXSYNC_DONE  = sync_rxsync_done;
assign PIPE_ACTIVE_LANE  = user_active_lane;
assign PIPE_TXOUTCLK_OUT = gt_txoutclk[0];
assign PIPE_RXOUTCLK_OUT = gt_rxoutclk;
assign PIPE_PCLK_SEL_OUT = rate_pclk_sel;
assign PIPE_GEN3_OUT     = rate_gen3[0];
assign PIPE_RST_FSM      = rst_fsm;
assign PIPE_QRST_FSM     = qrst_fsm;
assign PIPE_RATE_FSM     = rate_fsm;
assign PIPE_SYNC_FSM_TX  = sync_fsm_tx;
assign PIPE_SYNC_FSM_RX  = sync_fsm_rx;
assign PIPE_DRP_FSM      = drp_fsm;
assign PIPE_QDRP_FSM     = qdrp_fsm;
assign PIPE_RST_IDLE     = &rst_idle;
assign PIPE_QRST_IDLE    = &qrst_idle;
assign PIPE_RATE_IDLE    = &rate_idle;
assign PIPE_DEBUG_0      = gt_txresetdone;
assign PIPE_DEBUG_1      = gt_rxresetdone;
assign PIPE_DEBUG_2      = gt_phystatus;
assign PIPE_DEBUG_3      = gt_rxvalid;
assign PIPE_DEBUG_4      = gt_txphaligndone;
assign PIPE_DEBUG_5      = gt_rxphaligndone[PCIE_LANE-1:0];
assign PIPE_DEBUG_6      = gt_rxcommadet;
assign PIPE_DEBUG_7      = gt_rxbyteisaligned;
assign PIPE_DEBUG_8      = gt_rxbyterealign;
assign PIPE_DEBUG_9      = {PCIE_LANE{1'd0}};
assign PIPE_DEBUG[ 5: 0] = qdrp_crscode[ 5:0];
assign PIPE_DEBUG[    6] = qrst_qpllreset;
assign PIPE_DEBUG[    7] = qrst_qpllpd;
assign PIPE_DEBUG[    8] = rst_cpllreset;
assign PIPE_DEBUG[    9] = rst_cpllpd;
assign PIPE_DEBUG[31:10] = 22'd0;
endmodule
