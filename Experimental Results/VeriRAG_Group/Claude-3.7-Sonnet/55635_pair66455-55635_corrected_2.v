`timescale 1ns / 1ps
module pcie_7x_v1_3_pipe_wrapper #
(
    // ... existing code ...
)
(
    input                           test_i,
    input                           scan_done,
    input                           PIPE_CLK,               
    input                           PIPE_RESET_N,           
    output                          PIPE_PCLK,              
    // ... existing code ...
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
    wire                            dft_rst_idle;
    wire                            dft_pipe_reset_n;

    assign dft_rst_idle = test_i ? scan_done : rst_idle;
    assign dft_pipe_reset_n = test_i ? scan_done : PIPE_RESET_N;

    // ... existing code ...

    always @ (posedge clk_pclk or negedge dft_pipe_reset_n)
    begin
        if (!dft_pipe_reset_n)
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

    // ... existing code ...

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
        .RST_IDLE                       (dft_rst_idle),
        .RST_FSM                        (rst_fsm)
    );

    // ... existing code ...

endmodule