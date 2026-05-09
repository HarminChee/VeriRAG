`timescale 1ns / 1ps

module pcie_compiler_0_testbench (
    input  wire           clk125_out,
    input  wire           clk250_out,
    input  wire           clk500_out,
    input  wire  [1:0]    powerdown_ext,
    input  wire           rate_ext,
    input  wire  [16:0]   reconfig_fromgxb,
    input  wire           rxpolarity0_ext,
    input  wire  [8:0]    test_out,
    input  wire           tx_out0,
    input  wire           txcompl0_ext,
    input  wire  [7:0]    txdata0_ext,
    input  wire           txdatak0_ext,
    input  wire           txdetectrx_ext,
    input  wire           txelecidle0_ext,
    
    output wire           busy_altgxb_reconfig,
    output wire           cal_blk_clk,
    output wire           clk125_in,
    output wire           fixedclk_serdes,
    output wire           gxb_powerdown,
    output wire           pcie_rstn,
    output wire           phystatus_ext,
    output wire           pipe_mode,
    output wire           pll_powerdown,
    output wire           reconfig_clk,
    output wire  [3:0]    reconfig_togxb,
    output wire           refclk,
    output wire           rx_in0,
    output wire  [7:0]    rxdata0_ext,
    output wire           rxdatak0_ext,
    output wire           rxelecidle0_ext,
    output wire  [2:0]    rxstatus0_ext,
    output wire           rxvalid0_ext,
    output wire  [39:0]   test_in
);

    assign busy_altgxb_reconfig = 0;
    assign fixedclk_serdes = clk125_out;
    assign cal_blk_clk = clk125_out;
    assign reconfig_togxb = 4'b0010;
    assign gxb_powerdown = ~pcie_rstn;
    assign pll_powerdown = ~pcie_rstn;
    assign clk125_in = clk125_out;
    assign phystatus_ext = 0;
    assign refclk = clk125_out;
    assign rx_in0 = tx_out0;
    assign rxdata0_ext = txdata0_ext;
    assign rxdatak0_ext = txdatak0_ext;
    assign rxelecidle0_ext = txelecidle0_ext;
    assign rxstatus0_ext = 3'b000;
    assign rxvalid0_ext = 1'b1;
    assign test_in = 40'b0;
    assign pipe_mode = 1'b1;

    always @(posedge refclk or negedge pcie_rstn) begin
        if (!pcie_rstn)
            reconfig_clk <= 0;
        else 
            reconfig_clk <= ~reconfig_clk;
    end

endmodule