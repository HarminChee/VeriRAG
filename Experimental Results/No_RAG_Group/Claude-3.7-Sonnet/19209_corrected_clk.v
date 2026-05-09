Here is the corrected Verilog code:


`timescale 1ns / 1ps

module pcie_7x_v1_11_0_pipe_wrapper #
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
    parameter PCIE_USERCLK1_FREQ            = 2,            
    parameter PCIE_USERCLK2_FREQ            = 2,            
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
    input                           PIPE_DCLK_IN,           
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
    input       [3:0]               i_tx_diff_ctr,
    output      [1:0]               o_rx_byte_is_comma,
    output                          o_rx_byte_is_aligned,
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

// ... existing code ...

wire clk_pclk;
wire clk_rxusrclk;
wire [PCIE_LANE-1:0] clk_rxoutclk;
wire clk_dclk;
wire clk_oobclk;
wire clk_mmcm_lock;

// ... existing code ...

generate
    if (PCIE_EXT_CLK == "FALSE")
        begin : pipe_clock_int
        pcie_7x_v1_11_0_pipe_clock #
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
        end
    else
        begin : pipe_clock_ext
        assign clk_pclk      = PIPE_PCLK_IN;
        assign clk_rxusrclk  = PIPE_RXUSRCLK_IN;
        assign clk_rxoutclk  = PIPE_RXOUTCLK_IN;
        assign clk_dclk      = PIPE_DCLK_IN;
        assign PIPE_USERCLK1 = PIPE_USERCLK1_IN;
        assign PIPE_USERCLK2 = PIPE_USERCLK2_IN;
        assign clk_oobclk    = PIPE_OOBCLK_IN;
        assign clk_mmcm_lock = PIPE_MMCM_LOCK_IN;
        end
endgenerate

// ... existing code ...

endmodule