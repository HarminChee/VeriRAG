<xaiArtifact artifact_id="cd3e70f4-ad1b-4f62-8a80-77158fe4a163" artifact_version_id="122a92f1-e270-4157-9e65-6855d45401cf" title="pcie3_7x_0_pipe_clock.v" contentType="text/verilog">
`timescale 1ns / 1ps
module pcie3_7x_0_pipe_clock #(
    parameter PCIE_ASYNC_EN      = "FALSE",                 
    parameter PCIE_TXBUF_EN      = "FALSE",                 
    parameter PCIE_CLK_SHARING_EN= "FALSE",                 
    parameter PCIE_LANE          = 1,                       
    parameter PCIE_LINK_SPEED    = 3,                       
    parameter PCIE_REFCLK_FREQ   = 0,                       
    parameter PCIE_USERCLK1_FREQ = 2,                       
    parameter PCIE_USERCLK2_FREQ = 2,                       
    parameter PCIE_OOBCLK_MODE   = 1,                       
    parameter PCIE_DEBUG_MODE    = 0                        
)(
    input                       CLK_CLK,
    input                       CLK_TXOUTCLK,
    input       [PCIE_LANE-1:0] CLK_RXOUTCLK_IN,
    input                       CLK_RST_N,
    input       [PCIE_LANE-1:0] CLK_PCLK_SEL,
    input       [PCIE_LANE-1:0] CLK_PCLK_SEL_SLAVE,
    input                       CLK_GEN3,
    output                      CLK_PCLK,
    output                      CLK_PCLK_SLAVE,
    output                      CLK_RXUSRCLK,
    output      [PCIE_LANE-1:0] CLK_RXOUTCLK_OUT,
    output                      CLK_DCLK,
    output                      CLK_OOBCLK,
    output                      CLK_USERCLK1,
    output                      CLK_USERCLK2,
    output                      CLK_MMCM_LOCK
);
    localparam          DIVCLK_DIVIDE    = (PCIE_REFCLK_FREQ == 2) ? 1 :
                                           (PCIE_REFCLK_FREQ == 1) ? 1 : 1;
    localparam          CLKFBOUT_MULT_F  = (PCIE_REFCLK_FREQ == 2) ? 4.0 :
                                           (PCIE_REFCLK_FREQ == 1) ? 8.0 : 10.0;
    localparam          CLKIN1_PERIOD    = (PCIE_REFCLK_FREQ == 2) ? 4.0 :
                                           (PCIE_REFCLK_FREQ == 1) ? 8.0 : 10.0;
    localparam          CLKOUT0_DIVIDE_F = 8.0;
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
    localparam          PCIE_GEN1_MODE   = 1'b0;             
    (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *) reg [PCIE_LANE-1:0] pclk_sel_reg1 = {PCIE_LANE{1'b0}};
    (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *) reg [PCIE_LANE-1:0] pclk_sel_slave_reg1 = {PCIE_LANE{1'b0}};
    (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *) reg gen3_reg1 = 1'b0;
    (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *) reg [PCIE_LANE-1:0] pclk_sel_reg2 = {PCIE_LANE{1'b0}};
    (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *) reg [PCIE_LANE-1:0] pclk_sel_slave_reg2 = {PCIE_LANE{1'b0}};
    (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *) reg gen3_reg2 = 1'b0;   
    wire refclk;
    wire mmcm_fb;
    wire clk_125mhz;
    wire clk_125mhz_buf;
    wire clk_250mhz;
    wire userclk1;
    wire userclk2;
    wire oobclk;
    reg  pclk_sel = 1'b0;
    reg  pclk_sel_slave = 1'b0;
    wire pclk_1;
    wire pclk;
    wire userclk1_1;
    wire userclk2_1;
    wire mmcm_lock;
    genvar i;                                  
    always @(posedge pclk) begin
        if (!CLK_RST_N) begin
            pclk_sel_reg1 <= {PCIE_LANE{1'b0}};
            pclk_sel_slave_reg1 <= {PCIE_LANE{1'b0}};
            gen3_reg1 <= 1'b0;
            pclk_sel_reg2 <= {PCIE_LANE{1'b0}};
            pclk_sel_slave_reg2 <= {PCIE_LANE{1'b0}};
            gen3_reg2 <= 1'b0;
        end else begin  
            pclk_sel_reg1 <= CLK_PCLK_SEL;
            pclk_sel_slave_reg1 <= CLK_PCLK_SEL_SLAVE;
            gen3_reg1 <= CLK_GEN3;
            pclk_sel_reg2 <= pclk_sel_reg1;
            pclk_sel_slave_reg2 <= pclk_sel_slave_reg1;
            gen3_reg2 <= gen3_reg1;
        end
    end
    MMCME2_ADV #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKOUT4_CASCADE("FALSE"),
        .COMPENSATION("ZHOLD"),
        .STARTUP_WAIT("FALSE"),
        .DIVCLK_DIVIDE(DIVCLK_DIVIDE),
        .CLKFBOUT_MULT_F(CLKFBOUT_MULT_F),  
        .CLKFBOUT_PHASE(0.000),
        .CLKFBOUT_USE_FINE_PS("FALSE"),
        .CLKOUT0_DIVIDE_F(CLKOUT0_DIVIDE_F),                    
        .CLKOUT0_PHASE(0.000),
        .CLKOUT0_DUTY_CYCLE(0.500),
        .CLKOUT0_USE_FINE_PS("FALSE"),
        .CLKOUT1_DIVIDE(CLKOUT1_DIVIDE),                    
        .CLKOUT1_PHASE(0.000),
        .CLKOUT1_DUTY_CYCLE(0.500),
        .CLKOUT1_USE_FINE_PS("FALSE"),
        .CLKOUT2_DIVIDE(CLKOUT2_DIVIDE),                  
        .CLKOUT2_PHASE(0.000),
        .CLKOUT2_DUTY_CYCLE(0.500),
        .CLKOUT2_USE_FINE_PS("FALSE"),
        .CLKOUT3_DIVIDE(CLKOUT3_DIVIDE),                  
        .CLKOUT3_PHASE(0.000),
        .CLKOUT3_DUTY_CYCLE(0.500),
        .CLKOUT3_USE_FINE_PS("FALSE"),
        .CLKOUT4_DIVIDE(CLKOUT4_DIVIDE),                  
        .CLKOUT4_PHASE(0.000),
        .CLKOUT4_DUTY_CYCLE(0.500),
        .CLKOUT4_USE_FINE_PS("FALSE"),
        .CLKIN1_PERIOD(CLKIN1_PERIOD),                   
        .REF_JITTER1(0.010)
    ) mmcm_i (
        .CLKIN1(CLK_TXOUTCLK),
        .CLKIN2(1'b0),                     
        .CLKINSEL(1'b1),
        .CLKFBIN(mmcm_fb),
        .RST(!CLK_RST_N),
        .PWRDWN    mmcm_i (
        .CLKFBOUT(mmcm_fb),
        .CLKFBOUTB(),
        .CLKOUT0(clk_125mhz),
        .CLKOUT0B(),
        .CLKOUT1(clk_250mhz),
        .CLKOUT1B(),
        .CLKOUT2(userclk1),
        .CLKOUT2B(),
        .CLKOUT3(userclk2),
        .CLKOUT3B(),
        .CLKOUT4(oobclk),
        .CLKOUT5(),
        .CLKOUT6(),
        .LOCKED(mmcm_lock),
        .DCLK(1'b0),
        .DADDR(7'b0),
        .DEN(1'b0),
        .DWE(1'b0),
        .DI(16'b0),
        .DO(),
        .DRDY(),
        .PSCLK(1'b0),
        .PSEN(1'b0),
        .PSINCDEC(1'b0),
        .PSDONE(),
        .CLKINSTOPPED(),
        .CLKFBSTOPPED()
    ); 
    generate 
        if (PCIE_LINK_SPEED != 1) begin : pclk_i1_bufgctrl
            BUFGCTRL pclk_i1 (
                .CE0(1'b1),         
                .CE1(1'b1),        
                .I0(clk_125mhz),   
                .I1(clk_250mhz),   
                .IGNORE0(1'b0),        
                .IGNORE1(1'b0),        
                .S0(~pclk_sel),    
                .S1(pclk_sel),    
                .O(pclk_1)
            );
        end else begin : pclk_i1_bufg
            BUFG pclk_i1 (
                .I(clk_125mhz), 
                .O(clk_125mhz_buf)
            );
            assign pclk_1 = clk_125mhz_buf;
        end 
    endgenerate
    generate  
        if (PCIE_CLK_SHARING_EN == "FALSE") begin : pclk_slave_disable
            assign CLK_PCLK_SLAVE = 1'b0;
        end else if (PCIE_LINK_SPEED != 1) begin : pclk_slave_bufgctrl
            BUFGCTRL pclk_slave (
                .CE0(1'b1),         
                .CE1(1'b1),        
                .I0(clk_125mhz),   
                .I1(clk_250mhz),   
                .IGNORE0(1'b0),        
                .IGNORE1(1'b0),        
                .S0(~pclk_sel_slave),    
                .S1(pclk_sel_slave),    
                .O(CLK_PCLK_SLAVE)
            );
        end else begin : pclk_slave_bufg
            BUFG pclk_slave (
                .I(clk_125mhz), 
                .O(CLK_PCLK_SLAVE)
            );
        end 
    endgenerate
    generate 
        if ((PCIE_DEBUG_MODE == 1) || (PCIE_ASYNC_EN == "TRUE")) begin : rxoutclk_per_lane
            for (i = 0; i < PCIE_LANE; i = i + 1) begin : rxoutclk_i
                BUFG rxoutclk_i (
                    .I(CLK_RXOUTCLK_IN[i]), 
                    .O(CLK_RXOUTCLK_OUT[i])
                );
            end
        end else begin : rxoutclk_i_disable
            assign CLK_RXOUTCLK_OUT = {PCIE_LANE{1'b0}};
        end       
    endgenerate 
    generate 
        if (PCIE_USERCLK2_FREQ <= 3) begin : dclk_i
            assign CLK_DCLK = userclk2_1;                       
        end else begin : dclk_i_bufg
            BUFG dclk_i (
                .I(clk_125mhz), 
                .O(CLK_DCLK)
            );
        end 
    endgenerate
    generate 
        if (PCIE_GEN1_MODE == 1'b1 && PCIE_USERCLK1_FREQ == 3) begin : userclk1_i1_no_bufg
            assign userclk1_1 = pclk_1;
        end else begin : userclk1_i1
            BUFG usrclk1_i1 (
                .I(userclk1),
                .O(userclk1_1)
            );
        end 
    endgenerate 
    generate 
        if (PCIE_GEN1_MODE == 1'b1 && PCIE_USERCLK2_FREQ == 3) begin : userclk2_i1_no_bufg0
            assign userclk2_1 = pclk_1;
        end else if (PCIE_USERCLK2_FREQ == PCIE_USERCLK1_FREQ) begin : userclk2_i1_no_bufg1
            assign userclk2_1 = userclk1_1;
        end else begin : userclk2_i1
            BUFG usrclk2_i1 (
                .I(userclk2),
                .O(userclk2_1)
            );
        end
    endgenerate 
    generate 
        if (PCIE_OOBCLK_MODE == 2) begin : oobclk_i1
            BUFG oobclk_i1 (
                .I(oobclk),
                .O(CLK_OOBCLK)
            );
        end else begin : oobclk_i1_disable
            assign CLK_OOBCLK = pclk;
        end  
    endgenerate 
    assign pclk = pclk_1;
    assign CLK_RXUSRCLK = pclk_1;
    assign CLK_USERCLK1 = userclk1_1;
    assign CLK_USERCLK2 = userclk2_1;
    always @(posedge pclk) begin
        if (!CLK_RST_N)
            pclk_sel <= 1'b0;
        else begin 
            if (&pclk_sel_reg2)
                pclk_sel <= 1'b1;
            else if (&(~pclk_sel_reg2))
                pclk_sel <= 1'b0;  
            else
                pclk_sel <= pclk_sel;
        end
    end  
    always @(posedge pclk) begin
        if (!CLK_RST_N)
            pclk_sel_slave <= 1'b0;
        else begin 
            if (&pclk_sel_slave_reg2)
                pclk_sel_slave <= 1'b1;
            else if (&(~pclk_sel_slave_reg2))
                pclk_sel_slave <= 1'b0;  
            else
                pclk_sel_slave <= pclk_sel_slave;
        end
    end       
    assign CLK_PCLK = pclk;
    assign CLK_MMCM_LOCK = mmcm_lock;
endmodule
</xaiArtifact>