`timescale 1ns/1ns

module PCIeGen2x8If128_gt_top #(
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
    parameter PCIE_EXT_GT_COMMON = "FALSE",
    parameter EXT_CH_GT_DRP = "FALSE",
    parameter PCIE_CHAN_BOND = 0,
    parameter TCQ = 1
)(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire PIPE_MMCM_RST_N,
    output wire pipe_clk,
    output wire user_clk,
    output wire user_clk2,
    output wire phy_rdy_n
);

    localparam USERCLK2_FREQ = (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                               (USER_CLK_FREQ == 4) ? 3 :
                               (USER_CLK_FREQ == 3) ? 2 :
                               USER_CLK_FREQ;

    localparam PCIE_LPM_DFE = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
    localparam PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;
    localparam PCIE_OOBCLK_MODE_ENABLE = 1;
    localparam PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 3'd4 : 3'd2;

    wire pipe_clk_int;
    reg phy_rdy_n_int;
    reg reg_clock_locked;
    wire clock_locked;

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
            phy_rdy_n_int <= #TCQ 1'b1;
    end

    assign pipe_clk = pipe_clk_int;
    assign phy_rdy_n = phy_rdy_n_int;

    PCIeGen2x8If128_pipe_wrapper #(
        .PCIE_SIM_MODE(PL_FAST_TRAIN),
        .PCIE_EXT_CLK(PCIE_EXT_CLK),
        .PCIE_TXBUF_EN(PCIE_TXBUF_EN),
        .PCIE_EXT_GT_COMMON(PCIE_EXT_GT_COMMON),
        .EXT_CH_GT_DRP(EXT_CH_GT_DRP),
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
        .PIPE_CLK(sys_clk),
        .PIPE_RESET_N(sys_rst_n),
        .PIPE_PCLK(pipe_clk_int),
        .PIPE_MMCM_RST_N(PIPE_MMCM_RST_N),
        .PIPE_PCLK_LOCK(clock_locked),
        .PIPE_USERCLK1(user_clk),
        .