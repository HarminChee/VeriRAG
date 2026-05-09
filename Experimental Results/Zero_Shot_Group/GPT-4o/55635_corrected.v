`timescale 1ns / 1ps

module pcie_7x_v1_3_pipe_wrapper #(
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
)(
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
    input       [1:0]               PIPE_RATE,
    input       [2:0]               PIPE_TXMARGIN,
    input                           PIPE_TXSWING,
    input       [(PCIE_LANE*6)-1:0] PIPE_TXDEEMPH,
    output      [PCIE_LANE-1:0]     PIPE_RXVALID,
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS,
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS_RST,
    output      [PCIE_LANE-1:0]     PIPE_RXELECIDLE,
    output      [(PCIE_LANE*3)-1:0] PIPE_RXSTATUS,
    output      [PCIE_LANE-1:0]     PIPE_CPLL_LOCK,
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
    output      [PCIE_LANE-1:0]     PIPE_ACTIVE_LANE
);

    reg reset_n_reg1;
    reg reset_n_reg2;
    wire clk_pclk;
    wire clk_rxusrclk;
    wire clk_mmcm_lock;
    wire rst_cpllreset;
    wire rst_gtreset;
    wire rst_idle;
    wire [PCIE_LANE-1:0] user_resetdone;
    wire [PCIE_LANE-1:0] user_rxcdrlock;
    wire [PCIE_LANE-1:0] gt_rxvalid;
    wire [PCIE_LANE-1:0] gt_phystatus;
    wire [PCIE_LANE-1:0] gt_rxstatus;
    wire [PCIE_LANE-1:0] gt_rxelecidle;
    wire [PCIE_LANE-1:0] gt_cplllock;
    wire [PCIE_LANE-1:0] gt_rxoutclk;

    always @(posedge clk_pclk) begin
        if (!PIPE_RESET_N) begin
            reset_n_reg1 <= 1'd0;
            reset_n_reg2 <= 1'd0;
        end else begin
            reset_n_reg1 <= 1'd1;
            reset_n_reg2 <= reset_n_reg1;
        end
    end

    assign PIPE_PCLK         = clk_pclk;
    assign PIPE_PCLK_LOCK    = clk_mmcm_lock;
    assign PIPE_RXCDRLOCK    = user_rxcdrlock;
    assign PIPE_RXUSRCLK     = clk_rxusrclk;
    assign PIPE_RXOUTCLK     = gt_rxoutclk;
    assign PIPE_CPLL_LOCK    = gt_cplllock;
    assign PIPE_RXVALID      = gt_rxvalid;
    assign PIPE_PHYSTATUS    = gt_phystatus;
    assign PIPE_PHYSTATUS_RST= rst_idle;
    assign PIPE_RXELECIDLE   = gt_rxelecidle;
    assign PIPE_RXSTATUS     = gt_rxstatus;
    assign PIPE_USERCLK1     = clk_pclk;
    assign PIPE_USERCLK2     = clk_pclk;
    assign PIPE_TXSYNC_DONE  = gt_rxvalid;
    assign PIPE_RXSYNC_DONE  = gt_rxvalid;
    assign PIPE_GEN3_RDY     = gt_rxvalid;
    assign PIPE_RXCHANISALIGNED = gt_rxvalid;
    assign PIPE_ACTIVE_LANE  = gt_rxvalid;

endmodule