`timescale 1ns/1ns

module pcie_core_gt_top #(
    parameter LINK_CAP_MAX_LINK_WIDTH = 8,
    parameter REF_CLK_FREQ = 0,
    parameter USER_CLK2_DIV2 = "FALSE",
    parameter integer USER_CLK_FREQ = 3,
    parameter PL_FAST_TRAIN = "FALSE",
    parameter PCIE_EXT_CLK = "FALSE",
    parameter PCIE_USE_MODE = "1.0",
    parameter PCIE_GT_DEVICE = "GTX",
    parameter PCIE_PLL_SEL = "CPLL",
    parameter PCIE_ASYNC_EN = "FALSE",
    parameter PCIE_TXBUF_EN = "FALSE",
    parameter PCIE_CHAN_BOND = 0
)(
    input wire [5:0] pl_ltssm_state,
    input wire pipe_tx_rcvr_det,
    input wire pipe_tx_reset,
    input wire pipe_tx_rate,
    input wire pipe_tx_deemph,
    input wire [2:0] pipe_tx_margin,
    input wire pipe_tx_swing,
    input wire PIPE_PCLK_IN,
    input wire PIPE_RXUSRCLK_IN,
    input wire [(LINK_CAP_MAX_LINK_WIDTH - 1):0] PIPE_RXOUTCLK_IN,
    input wire PIPE_DCLK_IN,
    input wire PIPE_USERCLK1_IN,
    input wire PIPE_USERCLK2_IN,
    input wire PIPE_OOBCLK_IN,
    input wire PIPE_MMCM_LOCK_IN,
    output wire PIPE_TXOUTCLK_OUT,
    output wire [(LINK_CAP_MAX_LINK_WIDTH - 1):0] PIPE_RXOUTCLK_OUT,
    output wire [(LINK_CAP_MAX_LINK_WIDTH - 1):0] PIPE_PCLK_SEL_OUT,
    output wire PIPE_GEN3_OUT,
    output wire phy_rdy_n
);

    parameter TCQ = 1;
    
    localparam USERCLK2_FREQ = (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                               (USER_CLK_FREQ == 4) ? 3 :
                               (USER_CLK_FREQ == 3) ? 2 : USER_CLK_FREQ;
    
    localparam PCIE_LPM_DFE = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
    localparam PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;
    localparam PCIE_OOBCLK_MODE_ENABLE = 1;
    localparam PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 4 : 2;

    wire clock_locked;
    wire pipe_clk_int;
    reg phy_rdy_n_int;
    reg reg_clock_locked;
    wire all_phystatus_rst;
    
    always @(posedge pipe_clk_int or negedge clock_locked) begin
        if (!clock_locked)
            reg_clock_locked <= #TCQ 1'b0;
        else
            reg_clock_locked <= #TCQ 1'b1;
    end

    always @(posedge pipe_clk_int) begin
        if (!reg_clock_locked)
            phy_rdy_n_int <= #TCQ 1'b0;
        else
            phy_rdy_n_int <= #TCQ all_phystatus_rst;
    end

    assign all_phystatus_rst = 1'b1;
    assign phy_rdy_n = phy_rdy_n_int;

    pcie_core_pipe_wrapper #(
        .PCIE_SIM_MODE(PL_FAST_TRAIN),
        .PCIE_EXT_CLK(PCIE_EXT_CLK),
        .PCIE_TXBUF_EN(PCIE_TXBUF_EN),
        .PCIE_ASYNC_EN(PCIE_ASYNC_EN),
        .PCIE_CHAN_BOND(PCIE_CHAN_BOND),
        .PCIE_PLL_SEL(PCIE_PLL_SEL),
        .PCIE_GT_DEVICE(PCIE_GT_DEVICE),
        .PCIE_USE_MODE(PCIE_USE_MODE),
        .PCIE_LANE(LINK_CAP_MAX_LINK_WIDTH),
        .PCIE_LPM_DFE(PCIE_LPM_DFE),
        .PCIE_LINK_SPEED(PCIE_LINK_SPEED),
        .PCIE_TX_EIDLE_ASSERT_DELAY(PCIE_TX_EIDLE_ASSERT_DELAY),
        .PCIE_OOBCLK_MODE(PCIE_OOBCLK_MODE_ENABLE),
        .PCIE_REFCLK_FREQ(REF_CLK_FREQ),
        .PCIE_USERCLK1_FREQ(USER_CLK_FREQ + 1),
        .PCIE_USERCLK2_FREQ(USERCLK2_FREQ + 1)
    ) pipe_wrapper_i (
        .PIPE_CLK(PIPE_PCLK_IN),
        .PIPE_RESET_N(pipe_tx_reset),
        .PIPE_PCLK(pipe_clk_int),
        .PIPE_TXDETECTRX(pipe_tx_rcvr_det),
        .PIPE_RATE({1'b0, pipe_tx_rate}),
        .PIPE_TXMARGIN(pipe_tx_margin),
        .PIPE_TXSWING(pipe_tx_swing),
        .PIPE_TXDEEMPH({(LINK_CAP_MAX_LINK_WIDTH){pipe_tx_deemph}}),
        .PIPE_MMCM_RST_N(PIPE_MMCM_LOCK_IN),
        .PIPE_TXOUTCLK_OUT(PIPE_TXOUTCLK_OUT),
        .PIPE_RXOUTCLK_OUT(PIPE_RXOUTCLK_OUT),
        .PIPE_PCLK_SEL_OUT(PIPE_PCLK_SEL_OUT),
        .PIPE_GEN3_OUT(PIPE_GEN3_OUT),
        .PIPE_PCLK_IN(PIPE_PCLK_IN),
        .PIPE_RXUSRCLK_IN(PIPE_RXUSRCLK_IN),
        .PIPE_RXOUTCLK_IN(PIPE_RXOUTCLK_IN),
        .PIPE_DCLK_IN(PIPE_DCLK_IN),
        .PIPE_USERCLK1_IN(PIPE_USERCLK1_IN),
        .PIPE_USERCLK2_IN(PIPE_USERCLK2_IN),
        .PIPE_OOBCLK_IN(PIPE_OOBCLK_IN),
        .PIPE_MMCM_LOCK_IN(PIPE_MMCM_LOCK_IN)
    );

endmodule