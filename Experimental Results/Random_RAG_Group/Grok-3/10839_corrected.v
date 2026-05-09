`timescale 1ns / 1ps
module pcie_7x_v1_11_0_pipe_clock #
(
    parameter PCIE_ASYNC_EN      = "FALSE",                 
    parameter PCIE_TXBUF_EN      = "FALSE",                 
    parameter PCIE_LANE          = 1,                       
    parameter PCIE_LINK_SPEED    = 3,                       
    parameter PCIE_REFCLK_FREQ   = 0,                       
    parameter PCIE_USERCLK1_FREQ = 2,                       
    parameter PCIE_USERCLK2_FREQ = 2,                       
    parameter PCIE_OOBCLK_MODE   = 1,                       
    parameter PCIE_DEBUG_MODE    = 0                        
)
(
    input                       test_i,
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
    output                      CLK_OOBCLK,
    output                      CLK_USERCLK1,
    output                      CLK_USERCLK2,
    output                      CLK_MMCM_LOCK,
    output                      o_clk_in_stopped
);
    localparam          DIVCLK_DIVIDE    = (PCIE_REFCLK_FREQ == 2) ? 1 :
                                           (PCIE_REFCLK_FREQ == 1) ? 1 : 1;
    localparam          CLKFBOUT_MULT_F  = (PCIE_REFCLK_FREQ == 2) ? 4 :
                                           (PCIE_REFCLK_FREQ == 1) ? 8 : 10;
    localparam          CLKIN1_PERIOD    = (PCIE_REFCLK_FREQ == 2) ? 4 :
                                           (PCIE_REFCLK_FREQ == 1) ? 8 : 10;
    localparam          CLKOUT0_DIVIDE_F = 8;
    localparam          CLKOUT1_DIVIDE   = 4;
    localparam          CLKOUT2_DIVIDE   = (PCIE_USERCLK1_FREQ == 5) ?  2 :
                                           (PCIE_USERCLK1_FREQ == 4) ?  4 :
                                           (PCIE_USERCLK1_FREQ == 3) ?  8 :
                                           (PCIE_USERCLK1_FREQ == 1) ? 32 : 16;
    localparam          CLKOUT3_DIVIDE   = (PCIE_USERCLK2_FREQ == 5) ?  2 :
                                           (PCIE_USERCLK2_FREQ == 4) ?  4 :
                                           (PCIE_USERCLK2_FREQ == 3) ?  8 :
                                           (PCIE_USERCLK2_FREQ == 1) ? 32 : 16;
    localparam          CLKOUT4_DIVIDE   = 20;
    localparam          REFCLK_SEL = ((PCIE_TXBUF_EN == "TRUE") && (PCIE_LINK_SPEED != 3)) ? 1'd1 : 1'd0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0] pclk_sel_reg1 = {PCIE_LANE{1'd0}};
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                         gen3_reg1     = 1'd0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg         [PCIE_LANE-1:0] pclk_sel_reg2 = {PCIE_LANE{1'd0}};
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                         gen3_reg2     = 1'd0;
    wire                        refclk;
    wire                        mmcm_fb;
    wire                        clk_125mhz;
    wire                        clk_125mhz_buf;
    wire                        clk_250mhz;
    wire                        userclk1;
    wire                        userclk2;
    wire                        oobclk;
    reg                         pclk_sel = 1'd0;
    wire                        pclk_1;
    wire                        pclk;
    wire                        userclk1_1;
    wire                        userclk2_1;
    wire                        mmcm_lock;
    wire                        dft_pclk;
    genvar              i;                                  
always @ (posedge dft_pclk or posedge CLK_RST_N)
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
generate if ((PCIE_TXBUF_EN == "TRUE") && (PCIE_LINK_SPEED != 3))
    begin : refclk_i
    BUFG refclk_i
    (
        .I                          (CLK_CLK),
        .O                          (refclk)
    );
    end
else
    begin : txoutclk_i
    BUFG txoutclk_i
    (
        .I                          (CLK_TXOUTCLK),
        .O                          (refclk)
    );
    end
endgenerate
MMCME2_ADV #
(
    .BANDWIDTH                  ("OPTIMIZED"),
    .CLKOUT4_CASCADE            ("FALSE"),
    .COMPENSATION               ("ZHOLD"),
    .STARTUP_WAIT               ("FALSE"),
    .DIVCLK_DIVIDE              (DIVCLK_DIVIDE),
    .CLKFBOUT_MULT_F            (CLKFBOUT_MULT_F),
    .CLKFBOUT_PHASE             (0.000),
    .CLKFBOUT_USE_FINE_PS       ("FALSE"),
    .CLKOUT0_DIVIDE_F           (CLKOUT0_DIVIDE_F),
    .CLKOUT0_PHASE              (0.000),
    .CLKOUT0_DUTY_CYCLE         (0.500),
    .CLKOUT0_USE_FINE_PS        ("FALSE"),
    .CLKOUT1_DIVIDE             (CLKOUT1_DIVIDE),
    .CLKOUT1_PHASE              (0.000),
    .CLKOUT1_DUTY_CYCLE         (0.500),
    .CLKOUT1_USE_FINE_PS        ("FALSE"),
    .CLKOUT2_DIVIDE             (CLKOUT2_DIVIDE),
    .CLKOUT2_PHASE              (0.000),
    .CLKOUT2_DUTY_CYCLE         (0.500),
    .CLKOUT2_USE_FINE_PS        ("FALSE"),
    .CLKOUT3_DIVIDE             (CLKOUT3_DIVIDE),
    .CLKOUT3_PHASE              (0.000),
    .CLKOUT3_DUTY_CYCLE         (0.500),
    .CLKOUT3_USE_FINE_PS        ("FALSE"),
    .CLKOUT4_DIVIDE             (CLKOUT4_DIVIDE),
    .CLKOUT4_PHASE              (0.000),
    .CLKOUT4_DUTY_CYCLE         (0.500),
    .CLKOUT4_USE_FINE_PS        ("FALSE"),
    .CLKIN1_PERIOD              (CLKIN1_PERIOD),
    .REF_JITTER1                (0.010)
)
mmcm_i
(
    .CLKIN1                     (refclk),
    .CLKIN2                     (1'd0),                     
    .CLKINSEL                   (1'd1),
    .CLKFBIN                    (mmcm_fb),
    .RST                        (!CLK_RST_N),
    .PWRDWN                     (1'd0),
    .CLKFBOUT                   (mmcm_fb),
    .CLKFBOUTB                  (),
    .CLKOUT0                    (clk_125mhz),
    .CLKOUT0B                   (),
    .CLKOUT1                    (clk_250mhz),
    .CLKOUT1B                   (),
    .CLKOUT2                    (userclk1),
    .CLKOUT2B                   (),
    .CLKOUT3                    (userclk2),
    .CLKOUT3B                   (),
    .CLKOUT4                    (oobclk),
    .CLKOUT5                    (),
    .CLKOUT6                    (),
    .LOCKED                     (mmcm_lock),
    .DCLK                       ( 1'd0),
    .DADDR                      ( 7'd0),
    .DEN                        ( 1'd0),
    .DWE                        ( 1'd0),
    .DI                         (16'd0),
    .DO                         (),
    .DRDY                       (),
    .PSCLK                      (1'd0),
    .PSEN                       (1'd0),
    .PSINCDEC                   (1'd0),
    .PSDONE                     (),
    .CLKINSTOPPED               (o_clk_in_stopped),
    .CLKFBSTOPPED               ()
);
generate if (PCIE_LINK_SPEED != 1)
    begin : pclk_i1_bufgctrl
    BUFGCTRL pclk_i1
    (
        .CE0                        (1'd1),
        .CE1                        (1'd1),
        .I0                         (clk_125mhz),
        .I1                         (clk_250mhz),
        .IGNORE0                    (1'd0),
        .IGNORE1                    (1'd0),
        .S0                         (~pclk_sel),
        .S1                         ( pclk_sel),
        .O                          (pclk_1)
    );
    end
else
    begin : pclk_i1_bufg
    BUFG pclk_i1
    (
        .I                          (clk_125mhz),
        .O                          (clk_125mhz_buf)
    );
    assign pclk_1 = clk_125mhz_buf;
    end
endgenerate
generate if ((PCIE_DEBUG_MODE == 1) || (PCIE_ASYNC_EN == "TRUE"))
    begin : rxoutclk_per_lane
    for (i=0; i<PCIE_LANE; i=i+1)
        begin : rxoutclk_i
        BUFG rxoutclk_i
        (
            .I                          (CLK_RXOUTCLK_IN[i]),
            .O                          (CLK_RXOUTCLK_OUT[i])
        );
        end
    end
else
    begin : rxoutclk_i_disable
    assign CLK_RXOUTCLK_OUT = {PCIE_LANE{1'd0}};
    end
endgenerate
generate if (PCIE_LINK_SPEED != 1)
    begin : dclk_i_bufg
    BUFG dclk_i
    (
        .I                          (clk_125mhz),
        .O                          (CLK_DCLK)
    );
    end
else
    begin : dclk_i
    assign CLK_DCLK = clk_125mhz_buf;                       
    end
endgenerate
generate if (PCIE_USERCLK1_FREQ != 0)
    begin : userclk1_i1
    BUFG usrclk1_i1
    (
        .I                          (userclk1),
        .O                          (userclk1_1)
    );
    end
else
    begin : disable_userclk1_i1
    assign userclk1_1 = 1'd0;
    end
endgenerate
generate if (PCIE_USERCLK2_FREQ != 0)
    begin : userclk2_i1
    BUFG usrclk2_i1
    (
        .I                          (userclk2),
        .O                          (userclk2_1)
    );
    end
else
    begin : userclk2_i1_disable
    assign userclk2_1 = 1'd0;
    end
endgenerate
generate if (PCIE_OOBCLK_MODE == 2)
    begin : oobclk_i1
    BUFG oobclk_i1
    (
        .I                          (oobclk),
        .O                          (CLK_OOBCLK)
    );
    end
else
    begin : oobclk_i1_disable
    assign CLK_OOBCLK = pclk;
    end
endgenerate
generate if ((PCIE_LINK_SPEED == 3) && (PCIE_ASYNC_EN == "TRUE"))
    begin : second_stage_buf
    BUFG pclk_i2
    (
        .I                          (pclk_1),
        .O                          (pclk)
    );
    BUFGCTRL rxusrclk_i2
    (
        .CE0                        (1'b1),
        .CE1                        (1'b1),
        .I0                         (pclk_1),
        .I1                         (CLK_RXOUTCLK_IN[0]),
        .IGNORE0                    (1'b0),
        .IGNORE1                    (1'b0),
        .S0                         (~gen3_reg2),
        .S1                         ( gen3_reg2),
        .O                          (CLK_RXUSRCLK)
    );
    if (PCIE_USERCLK1_FREQ != 0)
        begin : userclk1_i2
        BUFG usrclk1_i2
        (
            .I                          (userclk1_1),
            .O                          (CLK_USERCLK1)
        );
        end
    else
        begin : userclk1_i2_disable
        assign CLK_USERCLK1 = userclk1_1;
        end
    if (PCIE_USERCLK2_FREQ != 0)
        begin : userclk2_i2
        BUFG usrclk2_i2
        (
            .I                          (userclk2_1),
            .O                          (CLK_USERCLK2)
        );
        end
    else
        begin : userclk2_i2_disable
        assign CLK_USERCLK2 = userclk2_1;
        end
    end
else
    begin : second_stage_buf_disable
    assign pclk         = pclk_1;
    assign CLK_RXUSRCLK = pclk_1;
    assign CLK_USERCLK1 = userclk1_1;
    assign CLK_USERCLK2 = userclk2_1;
    end
endgenerate
assign dft_pclk = test_i ? CLK_CLK : pclk;
always @ (posedge dft_pclk or posedge CLK_RST_N)
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
assign CLK_PCLK      = pclk;
assign CLK_MMCM_LOCK = mmcm_lock;
endmodule