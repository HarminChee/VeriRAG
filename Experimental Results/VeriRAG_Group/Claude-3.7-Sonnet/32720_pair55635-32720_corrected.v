module pcie_7x_v1_3_pipe_wrapper #
(
    // ... existing code ...
)
(                                                           
    input                           PIPE_CLK,               
    input                           PIPE_RESET_N,           
    output                          PIPE_PCLK,              
    // ... existing code ...
);

    // ... existing code ...

    // Fix CLKNPI error - ensure clk_pclk is driven from primary input
    assign clk_pclk = PIPE_PCLK_IN;

    // Fix FFCKNP error - ensure flip-flop clocks come from primary inputs
    always @(posedge PIPE_CLK) begin
        if (!PIPE_RESET_N) begin
            reset_n_reg1 <= 1'd0;
            reset_n_reg2 <= 1'd0;
        end
        else begin
            reset_n_reg1 <= 1'd1;
            reset_n_reg2 <= reset_n_reg1;
        end
    end

    // Fix ACNCPI error - ensure reset comes from primary input
    assign rst_cpllreset = !PIPE_RESET_N;
    assign rst_cpllpd = !PIPE_RESET_N;
    assign rst_rxusrclk_reset = !PIPE_RESET_N;
    assign rst_dclk_reset = !PIPE_RESET_N;
    assign rst_gtreset = !PIPE_RESET_N;
    assign rst_userrdy = !PIPE_RESET_N;

    // ... existing code ...

    // Fix CDFDAT error - separate clock and data paths
    generate
        if (PCIE_EXT_CLK == "FALSE") begin : pipe_clock_int
            pcie_7x_v1_3_pipe_clock #
            (
                .PCIE_USE_MODE                  (PCIE_USE_MODE),        
                .PCIE_ASYNC_EN                  (PCIE_ASYNC_EN),        
                .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),        
                .PCIE_LANE                      (PCIE_LANE),            
                .PCIE_LINK_SPEED               (PCIE_LINK_SPEED),      
                .PCIE_REFCLK_FREQ              (PCIE_REFCLK_FREQ),     
                .PCIE_USERCLK1_FREQ            (PCIE_USERCLK1_FREQ),   
                .PCIE_USERCLK2_FREQ            (PCIE_USERCLK2_FREQ),   
                .PCIE_DEBUG_MODE               (PCIE_DEBUG_MODE)       
            )
            pipe_clock_i
            (
                .CLK_CLK                        (PIPE_CLK),
                .CLK_TXOUTCLK                   (gt_txoutclk[0]),       
                .CLK_RXOUTCLK_IN               (gt_rxoutclk),
                .CLK_RST_N                      (PIPE_RESET_N),
                .CLK_PCLK_SEL                  (rate_pclk_sel),
                .CLK_GEN3                      (rate_gen3[0]),
                .CLK_PCLK                      (clk_pclk),
                .CLK_RXUSRCLK                  (clk_rxusrclk),
                .CLK_RXOUTCLK_OUT              (clk_rxoutclk),
                .CLK_DCLK                      (clk_dclk),
                .CLK_USERCLK1                  (PIPE_USERCLK1),
                .CLK_USERCLK2                  (PIPE_USERCLK2),
                .CLK_MMCM_LOCK                 (clk_mmcm_lock)
            );
        end
        else begin : pipe_clock_int_disable
            assign clk_pclk      = PIPE_PCLK_IN;
            assign clk_rxusrclk  = PIPE_RXUSRCLK_IN;
            assign clk_rxoutclk  = PIPE_RXOUTCLK_IN;
            assign clk_dclk      = PIPE_DCLK_IN;
            assign PIPE_USERCLK1 = PIPE_USERCLK1_IN;
            assign PIPE_USERCLK2 = PIPE_USERCLK2_IN;
            assign clk_mmcm_lock = PIPE_MMCM_LOCK_IN;
        end
    endgenerate

    // ... rest of existing code ...

endmodule