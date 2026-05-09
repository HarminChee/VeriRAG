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

    localparam DIVCLK_DIVIDE    = (PCIE_REFCLK_FREQ == 2) ? 2 : 1;
    localparam CLKFBOUT_MULT_F  = 8;
    localparam CLKOUT0_DIVIDE_F = 8;
    localparam CLKOUT1_DIVIDE   = 4;
    localparam CLKIN1_PERIOD    = (PCIE_REFCLK_FREQ == 2) ? 4 : 8;
    localparam CLKOUT2_DIVIDE   = (PCIE_USERCLK1_FREQ == 5) ? 2 : 
                                  (PCIE_USERCLK1_FREQ == 4) ? 4 : 
                                  (PCIE_USERCLK1_FREQ == 3) ? 8 : 16;
    localparam CLKOUT3_DIVIDE   = (PCIE_USERCLK2_FREQ == 5) ? 2 : 
                                  (PCIE_USERCLK2_FREQ == 4) ? 4 : 
                                  (PCIE_USERCLK2_FREQ == 3) ? 8 : 16;
    
    wire refclk, mmcm_fb, clk_125mhz, clk_250mhz, userclk1, userclk2;
    reg pclk_sel = 1'd0;
    wire pclk_1, pclk, userclk1_1, userclk2_1, mmcm_lock;

    generate
        if ((PCIE_TXBUF_EN == "TRUE") && (PCIE_LINK_SPEED != 3)) begin : refclk_buf
            BUFG refclk_inst (.I(CLK_CLK), .O(refclk));
        end else begin : txoutclk_buf
            BUFG txoutclk_inst (.I(CLK_TXOUTCLK), .O(refclk));
        end
    endgenerate

    MMCME2_ADV #
    (
        .BANDWIDTH("OPTIMIZED"),
        .CLKOUT4_CASCADE("FALSE"),
        .COMPENSATION("ZHOLD"),
        .STARTUP_WAIT("FALSE"),
        .DIVCLK_DIVIDE(DIVCLK_DIVIDE),
        .CLKFBOUT_MULT_F(CLKFBOUT_MULT_F),
        .CLKFBOUT_PHASE(0.000),
        .CLKOUT0_DIVIDE_F(CLKOUT0_DIVIDE_F),
        .CLKOUT1_DIVIDE(CLKOUT1_DIVIDE),
        .CLKOUT2_DIVIDE(CLKOUT2_DIVIDE),
        .CLKOUT3_DIVIDE(CLKOUT3_DIVIDE),
        .CLKIN1_PERIOD(CLKIN1_PERIOD),
        .REF_JITTER1(0.010)
    )
    mmcm_inst
    (
        .CLKIN1(refclk),
        .CLKFBIN(mmcm_fb),
        .RST(!CLK_RST_N),
        .CLKFBOUT(mmcm_fb),
        .CLKOUT0(clk_125mhz),
        .CLKOUT1(clk_250mhz),
        .CLKOUT2(userclk1),
        .CLKOUT3(userclk2),
        .LOCKED(mmcm_lock)
    );

    generate
        if (PCIE_LINK_SPEED != 1) begin : pclk_bufgctrl
            BUFGCTRL pclk_inst (
                .CE0(1'd1), .CE1(1'd1),
                .I0(clk_125mhz), .I1(clk_250mhz),
                .S0(~pclk_sel), .S1(pclk_sel),
                .O(pclk_1)
            );
        end else begin : pclk_bufg
            BUFG pclk_inst (.I(clk_125mhz), .O(pclk_1));
        end
    endgenerate

    generate
        if (PCIE_USERCLK1_FREQ != 0) begin : userclk1_buf
            BUFG usrclk1_inst (.I(userclk1), .O(userclk1_1));
        end else begin
            assign userclk1_1 = 1'd0;
        end
    endgenerate

    generate
        if (PCIE_USERCLK2_FREQ != 0) begin : userclk2_buf
            BUFG usrclk2_inst (.I(userclk2), .O(userclk2_1));
        end else begin
            assign userclk2_1 = 1'd0;
        end
    endgenerate

    always @(posedge pclk_1 or negedge CLK_RST_N) begin
        if (!CLK_RST_N)
            pclk_sel <= 1'd0;
        else begin
            if (&CLK_PCLK_SEL)
                pclk_sel <= 1'd1;
            else if (&(~CLK_PCLK_SEL))
                pclk_sel <= 1'd0;
        end
    end

    assign pclk = pclk_1;
    assign CLK_PCLK = pclk;
    assign CLK_MMCM_LOCK = mmcm_lock;
    assign CLK_RXUSRCLK = pclk;
    assign CLK_USERCLK1 = userclk1_1;
    assign CLK_USERCLK2 = userclk2_1;

    generate
        if (PCIE_DEBUG_MODE == 1) begin : rxoutclk_per_lane
            genvar i;
            for (i = 0; i < PCIE_LANE; i = i + 1) begin : rxoutclk_buf
                BUFG rxoutclk_inst (.I(CLK_RXOUTCLK_IN[i]), .O(CLK_RXOUTCLK_OUT[i]));
            end
        end else begin
            assign CLK_RXOUTCLK_OUT = {PCIE_LANE{1'd0}};
        end
    endgenerate

    generate
        if (PCIE_LINK_SPEED != 1) begin : dclk_buf
            BUFG dclk_inst (.I(clk_125mhz), .O(CLK_DCLK));
        end else begin
            assign CLK_DCLK = pclk_1;
        end
    endgenerate

endmodule