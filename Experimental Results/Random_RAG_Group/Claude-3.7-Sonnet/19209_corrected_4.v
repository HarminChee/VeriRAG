module pcie_7x_v1_11_0_pipe_wrapper #
(
    // ... existing code ...
)
(                                                           
    // ... existing code ...
    input clk_pclk,
    input PIPE_RESET_N,
    input clk_rxusrclk,
    input clk_dclk,
    input drp_done,
    input gt_rxpmaresetdone,
    input gt_cplllock,
    input qrst_idle,
    input rate_idle,
    input user_rxcdrlock,
    input clk_mmcm_lock,
    input user_resetdone,
    input gt_phystatus,
    input sync_txsync_done,
    output rst_cpllreset,
    output rst_cpllpd,
    output rst_rxusrclk_reset,
    output rst_dclk_reset,
    output rst_gtreset,
    output rst_drp_start,
    output rst_drp_x16,
    output rst_userrdy,
    output rst_txsync_start,
    output rst_idle,
    output rst_fsm
);

// ... existing code ...

reg reset_n_reg1;
reg reset_n_reg2;

always @ (posedge clk_pclk or negedge PIPE_RESET_N) 
begin
    if (!PIPE_RESET_N)
        begin
        reset_n_reg1 <= 1'b0;
        reset_n_reg2 <= 1'b0;
        end
    else
        begin
        reset_n_reg1 <= 1'b1;
        reset_n_reg2 <= reset_n_reg1;
        end
end

generate
    if (PCIE_EXT_CLK == "FALSE")
        begin : pipe_clock_int
        pcie_7x_v1_11_0_pipe_clock #
        (
            // ... existing code ...
        )
        pipe_clock_i
        (
            // ... existing code ...
        );
        end
    else
        begin : pipe_clock_int_disable
        // ... existing code ...
        end
endgenerate

generate
    if (PCIE_GT_DEVICE == "GTP")
        begin : gtp_pipe_reset
        pcie_7x_v1_11_0_gtp_pipe_reset #
        (
            // ... existing code ...
        )
        gtp_pipe_reset_i
        (
            // ... existing code ...
        );
        assign gtp_rst_qpllreset   = rst_cpllreset;
        assign gtp_rst_qpllpd      = rst_cpllpd;
        end
    else
        begin : pipe_reset
        pcie_7x_v1_11_0_pipe_reset #
        (
            // ... existing code ...
        )
        pipe_reset_i
        (
            .RST_CLK                        (clk_pclk),
            .RST_RXUSRCLK                   (clk_rxusrclk),
            .RST_DCLK                       (clk_dclk),
            .RST_RST_N                      (reset_n_reg2),
            .RST_DRP_DONE                   (drp_done),
            .RST_RXPMARESETDONE             (gt_rxpmaresetdone),
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
            .RST_DRP_START                  (rst_drp_start),
            .RST_DRP_X16                    (rst_drp_x16),
            .RST_USERRDY                    (rst_userrdy),
            .RST_TXSYNC_START               (rst_txsync_start),
            .RST_IDLE                       (rst_idle),
            .RST_FSM                        (rst_fsm)
        );
        end
endgenerate

endmodule