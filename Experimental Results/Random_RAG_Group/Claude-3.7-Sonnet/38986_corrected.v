`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_compiler_0_testbench (
                                    clk125_out,
                                    clk250_out,
                                    clk500_out,
                                    powerdown_ext,
                                    rate_ext,
                                    reconfig_fromgxb,
                                    rxpolarity0_ext,
                                    test_out,
                                    tx_out0,
                                    txcompl0_ext,
                                    txdata0_ext,
                                    txdatak0_ext,
                                    txdetectrx_ext,
                                    txelecidle0_ext,
                                    busy_altgxb_reconfig,
                                    cal_blk_clk,
                                    clk125_in,
                                    fixedclk_serdes,
                                    gxb_powerdown,
                                    pcie_rstn,
                                    phystatus_ext,
                                    pipe_mode,
                                    pll_powerdown,
                                    reconfig_clk,
                                    reconfig_togxb,
                                    refclk,
                                    rx_in0,
                                    rxdata0_ext,
                                    rxdatak0_ext,
                                    rxelecidle0_ext,
                                    rxstatus0_ext,
                                    rxvalid0_ext,
                                    test_in,
                                    test_mode_i
                                 )
;
  parameter PIPE_MODE_SIM = 1'b1;
  parameter TEST_LEVEL = 1;
  parameter NUM_CONNECTED_LANES = 8;
  parameter FAST_COUNTERS = 1'b1;
  output           busy_altgxb_reconfig;
  output           cal_blk_clk;
  output           clk125_in;
  output           fixedclk_serdes;
  output           gxb_powerdown;
  output           pcie_rstn;
  output           phystatus_ext;
  output           pipe_mode;
  output           pll_powerdown;
  output           reconfig_clk;
  output  [  3: 0] reconfig_togxb;
  output           refclk;
  output           rx_in0;
  output  [  7: 0] rxdata0_ext;
  output           rxdatak0_ext;
  output           rxelecidle0_ext;
  output  [  2: 0] rxstatus0_ext;
  output           rxvalid0_ext;
  output  [ 39: 0] test_in;
  input            clk125_out;
  input            clk250_out;
  input            clk500_out;
  input   [  1: 0] powerdown_ext;
  input            rate_ext;
  input   [ 16: 0] reconfig_fromgxb;
  input            rxpolarity0_ext;
  input   [  8: 0] test_out;
  input            tx_out0;
  input            txcompl0_ext;
  input   [  7: 0] txdata0_ext;
  input            txdatak0_ext;
  input            txdetectrx_ext;
  input            txelecidle0_ext;
  input            test_mode_i;

  // ... existing code ...

  reg              reconfig_clk;
  wire             test_clk;
  assign test_clk = test_mode_i ? refclk : reconfig_clk;

  always @(posedge refclk or negedge pcie_rstn)
    begin
      if (!pcie_rstn)
          reconfig_clk <= 0;
      else 
          reconfig_clk <= ~reconfig_clk;
    end

  // ... existing code ...

  altpcietb_rst_clk rst_clk_gen
    (
      .ep_core_clk_out (ep_core_clk_out),
      .pcie_rstn (pcie_rstn),
      .ref_clk_out (refclk),
      .ref_clk_sel_code (ref_clk_sel_code),
      .rp_rstn (rp_rstn),
      .test_clk_in (test_clk)
    );

endmodule