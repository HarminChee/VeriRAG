`timescale 1ns / 1ps
module clkgen(
    input sys_clk_i,
    input sys_rst_i,
    input test_i,
    output wb_clk_o,
    output wb_clk2x_o,
    output wb_rst_o
);
wire dft_sys_clk, dft_sys_rst;
IBUFG sys_clk_in_ibufg(
    .I(sys_clk_i),
    .O(sys_clk_ibufg)
);
wire [15:0] do_unused;
wire drdy_unused;
wire psdone_unused;
wire clkfbout;
wire clkfbout_buf;
wire clkfboutb_unused;
wire clkout0b_unused;
wire clkout1b_unused;
wire clkout2_unused;
wire clkout2b_unused;
wire clkout3_unused;
wire clkout3b_unused;
wire clkout4_unused;
wire clkout5_unused;
wire clkout6_unused;
wire clkfbstopped_unused;
wire clkinstopped_unused;
assign dft_sys_clk = test_i ? sys_clk_i : sys_clk_ibufg;
assign dft_sys_rst = test_i ? sys_rst_i : sys_rst_i;
MMCME2_ADV #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT4_CASCADE("FALSE"),
    .COMPENSATION("ZHOLD"),
    .STARTUP_WAIT("FALSE"),
    .DIVCLK_DIVIDE(1),
    .CLKFBOUT_MULT_F(10.000),
    .CLKFBOUT_PHASE(0.000),
    .CLKFBOUT_USE_FINE_PS("FALSE"),
    .CLKOUT0_DIVIDE_F(20.000),
    .CLKOUT0_PHASE(0.000),
    .CLKOUT0_DUTY_CYCLE(0.500),
    .CLKOUT0_USE_FINE_PS("FALSE"),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT1_PHASE(0.000),
    .CLKOUT1_DUTY_CYCLE(0.500),
    .CLKOUT1_USE_FINE_PS("FALSE"),
    .CLKIN1_PERIOD(10.000),
    .REF_JITTER1(0.010)
) mmcm_adv_inst(
    .CLKFBOUT(clkfbout),
    .CLKFBOUTB(clkfboutb_unused),
    .CLKOUT0(clkout0),
    .CLKOUT0B(clkout0b_unused),
    .CLKOUT1(clkout1),
    .CLKOUT1B(clkout1b_unused),
    .CLKOUT2(clkout2_unused),
    .CLKOUT2B(clkout2b_unused),
    .CLKOUT3(clkout3_unused),
    .CLKOUT3B(clkout3b_unused),
    .CLKOUT4(clkout4_unused),
    .CLKOUT5(clkout5_unused),
    .CLKOUT6(clkout6_unused),
    .CLKFBIN(clkfbout_buf),
    .CLKIN1(dft_sys_clk),
    .CLKIN2(1'b0),
    .CLKINSEL(1'b1),
    .DADDR(7'h0),
    .DCLK(1'b0),
    .DEN(1'b0),
    .DI(16'h0),
    .DO(do_unused),
    .DRDY(drdy_unused),
    .DWE(1'b0),
    .PSCLK(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .PSDONE(psdone_unused),
    .LOCKED(LOCKED),
    .CLKINSTOPPED(clkinstopped_unused),
    .CLKFBSTOPPED(clkfbstopped_unused),
    .PWRDWN(1'b0),
    .RST(dft_sys_rst)
);
BUFG clkf_buf(
    .O(clkfbout_buf),
    .I(clkfbout)
);
BUFG wb_clk_buf(
    .O(wb_clk_o),
    .I(clkout0)
);
BUFG wb_clk2x_buf(
    .O(wb_clk2x_o),
    .I(clkout1)
);
reg [15:0] wb_rst_shr;
always @(posedge wb_clk_o or posedge dft_sys_rst)
begin
    if(dft_sys_rst)
        wb_rst_shr <= 16'hffff;
    else
        wb_rst_shr <= {wb_rst_shr[14:0], ~(LOCKED)};
end
assign wb_rst_o = wb_rst_shr[15];
endmodule