Here's the modified Verilog code addressing the CLKNPI issue:


`timescale 1ns / 1ps
module pcie_7x_v1_3_pipe_clock #
(
    parameter PCIE_USE_MODE      = "1.1",                   
    parameter PCIE_ASYNC_EN      = "FALSE",                 
    parameter PCIE_TXBUF_EN      = "FALSE",                 
    parameter PCIE_LANE          = 1,                       
    parameter PCIE_LINK_SPEED    = 2,                       
    parameter PCIE_REFCLK_FREQ   = 0,                       
    parameter PCIE_USERCLK1_FREQ = 2,                       
    parameter PCIE_USERCLK2_FREQ = 2,                       
    parameter PCIE_DEBUG_MODE    = 0                        
)
(
    input                       CLK_CLK,
    input                       CLK_TXOUTCLK,
    input       [PCIE_LANE-1:0] CLK_RXOUTCLK_IN,
    input                       CLK_RST_N,
    input       [PCIE_LANE-1:0] CLK_PCLK_SEL,
    input                       CLK_GEN3,
    output                      CLK_PCLK,
    output                      CLK_RXUSRCLK,
    output      [PCIE_LANE-1:0] CLK_RXOUTCLK_OUT,
    output                      CLK_DCLK,
    output                      CLK_USERCLK1,
    output                      CLK_USERCLK2,
    output                      CLK_MMCM_LOCK
);
    // ... existing code ...

    wire                        pclk;
    // ... existing code ...

always @(posedge CLK_CLK)
begin
    if (!CLK_RST_N)
        begin
        pclk_sel_reg1 <= {PCIE_LANE{1'd0}};
        gen3_reg1     <= 1'd0;
        pclk_sel_reg2 <= {PCIE_LANE{1'd0}};
        gen3_reg2     <= 1'd0;
        end
    else
        begin
        pclk_sel_reg1 <= CLK_PCLK_SEL;
        gen3_reg1     <= CLK_GEN3;
        pclk_sel_reg2 <= pclk_sel_reg1;
        gen3_reg2     <= gen3_reg1;
        end
end

    // ... existing code ...

always @(posedge CLK_CLK)
begin
    if (!CLK_RST_N)
        pclk_sel <= 1'd0;
    else
        begin
        if (&pclk_sel_reg2)
            pclk_sel <= 1'd1;
        else if (&(~pclk_sel_reg2))
            pclk_sel <= 1'd0;
        else
            pclk_sel <= pclk_sel;
        end
end

    // ... existing code ...

endmodule