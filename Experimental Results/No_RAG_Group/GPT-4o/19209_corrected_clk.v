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
    input                           PIPE_MMCM_RST_N,        
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
    output                          PIPE_MMCM_LOCK          
);

    reg reset_n_reg1, reset_n_reg2;
    wire clk_pclk, clk_rxusrclk, clk_dclk, clk_oobclk, clk_mmcm_lock;
    
    always @(posedge PIPE_CLK or negedge PIPE_RESET_N) begin
        if (!PIPE_RESET_N) begin
            reset_n_reg1 <= 1'd0;
            reset_n_reg2 <= 1'd0;
        end else begin
            reset_n_reg1 <= 1'd1;
            reset_n_reg2 <= reset_n_reg1;
        end   
    end  

    generate 
        if (PCIE_EXT_CLK == "FALSE") begin : pipe_clock_int
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
                .CLK_RST_N                      (PIPE_MMCM_RST_N),      
                .CLK_PCLK                       (clk_pclk),
                .CLK_RXUSRCLK                   (clk_rxusrclk),  
                .CLK_DCLK                       (clk_dclk),
                .CLK_OOBCLK                     (clk_oobclk),
                .CLK_MMCM_LOCK                  (clk_mmcm_lock)
            );
        end else begin : pipe_clock_int_disable
            assign clk_pclk      = PIPE_PCLK_IN;
            assign clk_rxusrclk  = PIPE_RXUSRCLK_IN;
            assign clk_dclk      = PIPE_DCLK_IN;
            assign clk_oobclk    = PIPE_OOBCLK_IN;
            assign clk_mmcm_lock = PIPE_MMCM_LOCK_IN;
        end
    endgenerate
    
    assign PIPE_PCLK      = clk_pclk;
    assign PIPE_MMCM_LOCK = clk_mmcm_lock;
    
endmodule