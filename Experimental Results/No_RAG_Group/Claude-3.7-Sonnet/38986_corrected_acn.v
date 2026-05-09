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
                                    pcie_rstn_in,
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
                                    test_in
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
  input            pcie_rstn_in;
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

  // ... existing code ...

  always @(posedge refclk or negedge pcie_rstn_in)
    begin
      if (pcie_rstn_in == 0)
          reconfig_clk <= 0;
      else 
        reconfig_clk <= ~reconfig_clk;
    end

  // ... existing code ...

  assign clk125_in = ep_clk_in;
  assign ref_clk_sel_code = 0;
  assign phy_sel_code = 6;
  assign powerdown0_ext = powerdown_ext;
  assign txdetectrx0_ext = txdetectrx_ext;
  assign phystatus_ext = phystatus0_ext;
  assign busy_altgxb_reconfig = 0;
  assign fixedclk_serdes = ep_clk_in;
  assign cal_blk_clk = ep_clk_out;
  assign reconfig_togxb = 4'b0010;
  assign gxb_powerdown = ~pcie_rstn_in;
  assign pll_powerdown = ~pcie_rstn_in;
  assign ep_clk250_out = clk250_out;
  assign ep_clk500_out = clk500_out;
  assign ep_core_clk_out = 0;
  assign ep_clk_in = clk125_out;
  assign rp_pclk = (rp_rate == 1) ?  ep_clk500_out : ep_clk250_out;
  assign ep_clk_out = (rate_ext == 1) ?  ep_clk500_out : ep_clk250_out;
  assign rx_in0 = (connected_bits[0] == 1'b1) ?  rp_tx_out0 : 1;
  assign rp_rx_in0 = tx_out0;
  assign local_rstn = 1;
  assign test_in[2 : 1] = 0;
  assign test_in[8 : 4] = 0;
  assign test_in[9] = 1;
  assign test_in[39 : 10] = 0;
  assign test_in[3] = ~pipe_mode;
  assign test_in[0] = FAST_COUNTERS;
  assign connected_lanes = NUM_CONNECTED_LANES;
  assign connected_bits = connected_lanes[3] ? 8'hFF : connected_lanes[2] ? 8'h0F : connected_lanes[1] ? 8'h03 : 8'h01;
  assign rp_test_in[31 : 8] = 0;
  assign rp_test_in[6] = 0;
  assign rp_test_in[4] = 0;
  assign rp_test_in[2 : 1] = 0;
  assign rp_test_in[0] = 1;
  assign rp_test_in[3] = ~pipe_mode;
  assign rp_test_in[5] = 1;
  assign rp_test_in[7] = ~pipe_mode;
  assign pipe_mode_sig2 = PIPE_MODE_SIM;
  assign pipe_mode = ((phy_sel_code == 4'h0) || (phy_sel_code == 4'h2) || (phy_sel_code == 4'h6) || (phy_sel_code == 4'h7)) ? pipe_mode_sig2 : 1'b1;

  // ... rest of existing code ...

  altpcietb_rst_clk rst_clk_gen
    (
      .ep_core_clk_out (ep_core_clk_out),
      .pcie_rstn (pcie_rstn_in),
      .ref_clk_out (refclk),
      .ref_clk_sel_code (ref_clk_sel_code),
      .rp_rstn (rp_rstn)
    );
endmodule