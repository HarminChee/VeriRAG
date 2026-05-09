`timescale 1ns / 1ps

module pcie_7x_v1_8_pipe_wrapper #(
    parameter PCIE_LANE = 1
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
    output      [PCIE_LANE-1:0]     PIPE_RXVALID,
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS,
    output      [PCIE_LANE-1:0]     PIPE_RXELECIDLE,
    output      [(PCIE_LANE*3)-1:0] PIPE_RXSTATUS,
    output      [PCIE_LANE-1:0]     PIPE_CPLL_LOCK,
    output                          PIPE_PCLK_LOCK,
    output      [PCIE_LANE-1:0]     PIPE_RXCDRLOCK,
    output                          PIPE_USERCLK1,
    output                          PIPE_USERCLK2,
    output                          PIPE_RXUSRCLK,
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK,
    output      [PCIE_LANE-1:0]     PIPE_GEN3_RDY
);

    reg reset_n_reg1;
    reg reset_n_reg2;
    wire clk_pclk;
    wire clk_rxusrclk;
    wire [PCIE_LANE-1:0] clk_rxoutclk;
    wire clk_mmcm_lock;
    wire reset_cpll;
    wire reset_gt;

    always @(posedge PIPE_CLK) begin
        if (!PIPE_RESET_N) begin
            reset_n_reg1 <= 1'b0;
            reset_n_reg2 <= 1'b0;
        end else begin
            reset_n_reg1 <= 1'b1;
            reset_n_reg2 <= reset_n_reg1;
        end
    end

    assign PIPE_PCLK = clk_pclk;
    assign PIPE_PCLK_LOCK = clk_mmcm_lock;
    assign PIPE_RXUSRCLK = clk_rxusrclk;
    assign PIPE_RXOUTCLK = clk_rxoutclk;
    assign PIPE_CPLL_LOCK = reset_cpll;
    assign PIPE_RXCDRLOCK = 1'b0;
    assign PIPE_USERCLK1 = clk_pclk;
    assign PIPE_USERCLK2 = clk_pclk;
    assign PIPE_GEN3_RDY = 1'b0;

endmodule