`timescale 1ns / 1ps
module pcie_compiler_0_testbench (
                                    // Original Outputs
                                    busy_altgxb_reconfig,
                                    cal_blk_clk,
                                    clk125_in,
                                    fixedclk_serdes,
                                    gxb_powerdown,
                                    pcie_rstn,
                                    phystatus_ext,
                                    pipe_mode,
                                    pll_powerdown,
                                    reconfig_clk, // Keep as output if needed by external, but driven by internal logic
                                    reconfig_togxb,
                                    refclk,
                                    rx_in0,
                                    rxdata0_ext,
                                    rxdatak0_ext,
                                    rxelecidle0_ext,
                                    rxstatus0_ext,
                                    rxvalid0_ext,
                                    test_in,
                                    // Original Inputs
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
                                    // Added DFT Input
                                    dft_reset_n // Primary input for asynchronous reset control
                                 )
;
  parameter PIPE_MODE_SIM = 1'b1;
  parameter TEST_LEVEL = 1;
  parameter NUM_CONNECTED_LANES = 8;
  parameter FAST_COUNTERS = 1'b1;

  // Output Port Declarations
  output           busy_altgxb_reconfig;
  output           cal_blk_clk;
  output           clk125_in;
  output           fixedclk_serdes;
  output           gxb_powerdown;
  output           pcie_rstn;
  output           phystatus_ext;
  output           pipe_mode;
  output           pll_powerdown;
  output           reconfig_clk; // This is driven by the internal reg
  output  [  3: 0] reconfig_togxb;
  output           refclk;
  output           rx_in0;
  output  [  7: 0] rxdata0_ext;
  output           rxdatak0_ext;
  output           rxelecidle0_ext;
  output  [  2: 0] rxstatus0_ext;
  output           rxvalid0_ext;
  output  [ 39: 0] test_in;

  // Input Port Declarations
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
  input            dft_reset_n; // Primary input for asynchronous reset

  // Internal Wires and Regs
  wire             bfm_log_common_dummy_out;
  wire             bfm_req_intf_common_dummy_out;
  wire             bfm_shmem_common_dummy_out;
  wire             busy_altgxb_reconfig;
  wire             cal_blk_clk;
  wire             clk125_in;
  wire    [  7: 0] connected_bits;
  wire    [  3: 0] connected_lanes;
  wire             dummy_out;
  wire             ep_clk250_out;
  wire             ep_clk500_out;
  wire             ep_clk_in;
  wire             ep_clk_out;
  wire             ep_core_clk_out;
  wire    [  4: 0] ep_ltssm;
  wire             fixedclk_serdes;
  wire    [  1: 0] gnd_powerdown1_ext;
  wire    [  1: 0] gnd_powerdown2_ext;
  wire    [  1: 0] gnd_powerdown3_ext;
  wire    [  1: 0] gnd_powerdown4_ext;
  wire    [  1: 0] gnd_powerdown5_ext;
  wire    [  1: 0] gnd_powerdown6_ext;
  wire    [  1: 0] gnd_powerdown7_ext;
  wire             gnd_rp_rx_in1;
  wire             gnd_rp_rx_in2;
  wire             gnd_rp_rx_in3;
  wire             gnd_rp_rx_in4;
  wire             gnd_rp_rx_in5;
  wire             gnd_rp_rx_in6;
  wire             gnd_rp_rx_in7;
  wire             gnd_rxpolarity1_ext;
  wire             gnd_rxpolarity2_ext;
  wire             gnd_rxpolarity3_ext;
  wire             gnd_rxpolarity4_ext;
  wire             gnd_rxpolarity5_ext;
  wire             gnd_rxpolarity6_ext;
  wire             gnd_rxpolarity7_ext;
  wire             gnd_txcompl1_ext;
  wire             gnd_txcompl2_ext;
  wire             gnd_txcompl3_ext;
  wire             gnd_txcompl4_ext;
  wire             gnd_txcompl5_ext;
  wire             gnd_txcompl6_ext;
  wire             gnd_txcompl7_ext;
  wire    [  7: 0] gnd_txdata1_ext;
  wire    [  7: 0] gnd_txdata2_ext;
  wire    [  7: 0] gnd_txdata3_ext;
  wire    [  7: 0] gnd_txdata4_ext;
  wire    [  7: 0] gnd_txdata5_ext;
  wire    [  7: 0] gnd_txdata6_ext;
  wire    [  7: 0] gnd_txdata7_ext;
  wire             gnd_txdatak1_ext;
  wire             gnd_txdatak2_ext;
  wire             gnd_txdatak3_ext;
  wire             gnd_txdatak4_ext;
  wire             gnd_txdatak5_ext;
  wire             gnd_txdatak6_ext;
  wire             gnd_txdatak7_ext;
  wire             gnd_txdetectrx1_ext;
  wire             gnd_txdetectrx2_ext;
  wire             gnd_txdetectrx3_ext;
  wire             gnd_txdetectrx4_ext;
  wire             gnd_txdetectrx5_ext;
  wire             gnd_txdetectrx6_ext;
  wire             gnd_txdetectrx7_ext;
  wire             gnd_txelecidle1_ext;
  wire             gnd_txelecidle2_ext;
  wire             gnd_txelecidle3_ext;
  wire             gnd_txelecidle4_ext;
  wire             gnd_txelecidle5_ext;
  wire             gnd_txelecidle6_ext;
  wire             gnd_txelecidle7_ext;
  wire             gxb_powerdown;
  wire             local_rstn;
  wire             ltssm_dummy_out;
  wire             open_phystatus1_ext;
  wire             open_phystatus2_ext;
  wire             open_phystatus3_ext;
  wire             open_phystatus4_ext;
  wire             open_phystatus5_ext;
  wire             open_phystatus6_ext;
  wire             open_phystatus7_ext;
  wire             open_rp_tx_out1;
  wire             open_rp_tx_out2;
  wire             open_rp_tx_out3;
  wire             open_rp_tx_out4;
  wire             open_rp_tx_out5;
  wire             open_rp_tx_out6;
  wire             open_rp_tx_out7;
  wire    [  7: 0] open_rxdata1_ext;
  wire    [  7: 0] open_rxdata2_ext;
  wire    [  7: 0] open_rxdata3_ext;
  wire    [  7: 0] open_rxdata4_ext;
  wire    [  7: 0] open_rxdata5_ext;
  wire    [  7: 0] open_rxdata6_ext;
  wire    [  7: 0] open_rxdata7_ext;
  wire             open_rxdatak1_ext;
  wire             open_rxdatak2_ext;
  wire             open_rxdatak3_ext;
  wire             open_rxdatak4_ext;
  wire             open_rxdatak5_ext;
  wire             open_rxdatak6_ext;
  wire             open_rxdatak7_ext;
  wire             open_rxelecidle1_ext;
  wire             open_rxelecidle2_ext;
  wire             open_rxelecidle3_ext;
  wire             open_rxelecidle4_ext;
  wire             open_rxelecidle5_ext;
  wire             open_rxelecidle6_ext;
  wire             open_rxelecidle7_ext;
  wire    [  2: 0] open_rxstatus1_ext;
  wire    [  2: 0] open_rxstatus2_ext;
  wire    [  2: 0] open_rxstatus3_ext;
  wire    [  2: 0] open_rxstatus4_ext;
  wire    [  2: 0] open_rxstatus5_ext;
  wire    [  2: 0] open_rxstatus6_ext;
  wire    [  2: 0] open_rxstatus7_ext;
  wire             open_rxvalid1_ext;
  wire             open_rxvalid2_ext;
  wire             open_rxvalid3_ext;
  wire             open_rxvalid4_ext;
  wire             open_rxvalid5_ext;
  wire             open_rxvalid6_ext;
  wire             open_rxvalid7_ext;
  wire             pcie_rstn; // Internal wire driven by rst_clk_gen, also connected to output port
  wire    [  3: 0] phy_sel_code;
  wire             phystatus0_ext;
  wire             phystatus_ext;
  wire             pipe_mode;
  wire             pipe_mode_sig2;
  wire             pll_powerdown;
  wire    [  1: 0] powerdown0_ext;
  reg              reconfig_clk_reg ; // Internal register for the clock generation
  wire    [  3: 0] reconfig_togxb;
  wire    [  3: 0] ref_clk_sel_code;
  wire             refclk; // Internal wire driven by rst_clk_gen, also connected to output port
  wire    [  4: 0] rp_ltssm;
  wire             rp_pclk;
  wire             rp_phystatus0_ext;
  wire             rp_phystatus1_ext;
  wire             rp_phystatus2_ext;
  wire             rp_phystatus3_ext;
  wire             rp_phystatus4_ext;
  wire             rp_phystatus5_ext;
  wire             rp_phystatus6_ext;
  wire             rp_phystatus7_ext;
  wire    [  1: 0] rp_powerdown0_ext;
  wire    [  1: 0] rp_powerdown1_ext;
  wire    [  1: 0] rp_powerdown2_ext;
  wire    [  1: 0] rp_powerdown3_ext;
  wire    [  1: 0] rp_powerdown4_ext;
  wire    [  1: 0] rp_powerdown5_ext;
  wire    [  1: 0] rp_powerdown6_ext;
  wire    [  1: 0] rp_powerdown7_ext;
  wire             rp_rate;
  wire             rp_rstn;
  wire             rp_rx_in0;
  wire    [  7: 0] rp_rxdata0_ext;
  wire    [  7: 0] rp_rxdata1_ext;
  wire    [  7: 0] rp_rxdata2_ext;
  wire    [  7: 0] rp_rxdata3_ext;
  wire    [  7: 0] rp_rxdata4_ext;
  wire    [  7: 0] rp_rxdata5_ext;
  wire    [  7: 0] rp_rxdata6_ext;
  wire    [  7: 0] rp_rxdata7_ext;
  wire             rp_rxdatak0_ext;
  wire             rp_rxdatak1_ext;
  wire             rp_rxdatak2_ext;
  wire             rp_rxdatak3_ext;
  wire             rp_rxdatak4_ext;
  wire             rp_rxdatak5_ext;
  wire             rp_rxdatak6_ext;
  wire             rp_rxdatak7_ext;
  wire             rp_rxelecidle0_ext;
  wire             rp_rxelecidle1_ext;
  wire             rp_rxelecidle2_ext;
  wire             rp_rxelecidle3_ext;
  wire             rp_rxelecidle4_ext;
  wire             rp_rxelecidle5_ext;
  wire             rp_rxelecidle6_ext;
  wire             rp_rxelecidle7_ext;
  wire             rp_rxpolarity0_ext;
  wire             rp_rxpolarity1_ext;
  wire             rp_rxpolarity2_ext;
  wire             rp_rxpolarity3_ext;
  wire             rp_rxpolarity4_ext;
  wire             rp_rxpolarity5_ext;
  wire             rp_rxpolarity6_ext;
  wire             rp_rxpolarity7_ext;
  wire    [  2: 0] rp_rxstatus0_ext;
  wire    [  2: 0] rp_rxstatus1_ext;
  wire    [  2: 0] rp_rxstatus2_ext;
  wire    [  2: 0] rp_rxstatus3_ext;
  wire    [  2: 0] rp_rxstatus4_ext;
  wire    [  2: 0] rp_rxstatus5_ext;
  wire    [  2: 0] rp_rxstatus6_ext;
  wire    [  2: 0] rp_rxstatus7_ext;
  wire             rp_rxvalid0_ext;
  wire             rp_rxvalid1_ext;
  wire             rp_rxvalid2_ext;
  wire             rp_rxvalid3_ext;
  wire             rp_rxvalid4_ext;
  wire             rp_rxvalid5_ext;
  wire             rp_rxvalid6_ext;
  wire             rp_rxvalid7_ext;
  wire    [ 31: 0] rp_test_in;
  wire    [511: 0] rp_test_out;
  wire             rp_tx_out0;
  wire             rp_txcompl0_ext;
  wire             rp_txcompl1_ext;
  wire             rp_txcompl2_ext;
  wire             rp_txcompl3_ext;
  wire             rp_txcompl4_ext;
  wire             rp_txcompl5_ext;
  wire             rp_txcompl6_ext;
  wire             rp_txcompl7_ext;
  wire    [  7: 0] rp_txdata0_ext;
  wire    [  7: 0] rp_txdata1_ext;
  wire    [  7: 0] rp_txdata2_ext;
  wire    [  7: 0] rp_txdata3_ext;
  wire    [  7: 0] rp_txdata4_ext;
  wire    [  7: 0] rp_txdata5_ext;
  wire    [  7: 0] rp_txdata6_ext;
  wire    [  7: 0] rp_txdata7_ext;
  wire             rp_txdatak0_ext;
  wire             rp_txdatak1_ext;
  wire             rp_txdatak2_ext;
  wire             rp_txdatak3_ext;
  wire             rp_txdatak4_ext;
  wire             rp_txdatak5_ext;
  wire             rp_txdatak6_ext;
  wire             rp_txdatak7_ext;
  wire             rp_txdetectrx0_ext;
  wire             rp_txdetectrx1_ext;
  wire             rp_txdetectrx2_ext;
  wire             rp_txdetectrx3_ext;
  wire             rp_txdetectrx4_ext;
  wire             rp_txdetectrx5_ext;
  wire             rp_txdetectrx6_ext;
  wire             rp_txdetectrx7_ext;
  wire             rp_txelecidle0_ext;
  wire             rp_txelecidle1_ext;
  wire             rp_txelecidle2_ext;
  wire             rp_txelecidle3_ext;
  wire             rp_txelecidle4_ext;
  wire             rp_txelecidle5_ext;
  wire             rp_txelecidle6_ext;
  wire             rp_txelecidle7_ext;
  wire             rx_in0;
  wire    [  7: 0] rxdata0_ext;
  wire             rxdatak0_ext;
  wire             rxelecidle0_ext;
  wire    [  2: 0] rxstatus0_ext;
  wire             rxvalid0_ext;
  wire    [  5: 0] swdn_out;
  wire    [ 39: 0] test_in;
  wire             txdetectrx0_ext;

  // Assignments
  assign gnd_rp_rx_in1 = 1;
  assign gnd_rp_rx_in2 = 1;
  assign gnd_rp_rx_in3 = 1;
  assign gnd_rp_rx_in4 = 1;
  assign gnd_rp_rx_in5 = 1;
  assign gnd_rp_rx_in6 = 1;
  assign gnd_rp_rx_in7 = 1;
  assign ep_ltssm = test_out[4 : 0];
  assign rp_ltssm = rp_test_out[324 : 320];
  assign gnd_txdata1_ext = 0;
  assign gnd_txdatak1_ext = 0;
  assign gnd_txdetectrx1_ext = 0;
  assign gnd_txelecidle1_ext = 0;
  assign gnd_rxpolarity1_ext = 0;
  assign gnd_txcompl1_ext = 0;
  assign gnd_powerdown1_ext = 0;
  assign gnd_txdata2_ext = 0;
  assign gnd_txdatak2_ext = 0;
  assign gnd_txdetectrx2_ext = 0;
  assign gnd_txelecidle2_ext = 0;
  assign gnd_rxpolarity2_ext = 0;
  assign gnd_txcompl2_ext = 0;
  assign gnd_powerdown2_ext = 0;
  assign gnd_txdata3_ext = 0;
  assign gnd_txdatak3_ext = 0;
  assign gnd_txdetectrx3_ext = 0;
  assign gnd_txelecidle3_ext = 0;
  assign gnd_rxpolarity3_ext = 0;
  assign gnd_txcompl3_ext = 0;
  assign gnd_powerdown3_ext = 0;
  assign gnd_txdata4_ext = 0;
  assign gnd_txdatak4_ext = 0;
  assign gnd_txdetectrx4_ext = 0;
  assign gnd_txelecidle4_ext = 0;
  assign gnd_rxpolarity4_ext = 0;
  assign gnd_txcompl4_ext = 0;
  assign gnd_powerdown4_ext = 0;
  assign gnd_txdata5_ext = 0;
  assign gnd_txdatak5_ext = 0;
  assign gnd_txdetectrx5_ext = 0;
  assign gnd_txelecidle5_ext = 0;
  assign gnd_rxpolarity5_ext = 0;
  assign gnd_txcompl5_ext = 0;
  assign gnd_powerdown5_ext = 0;
  assign gnd_txdata6_ext = 0;
  assign gnd_txdatak6_ext = 0;
  assign gnd_txdetectrx6_ext = 0;
  assign gnd_txelecidle6_ext = 0;
  assign gnd_rxpolarity6_ext = 0;
  assign gnd_txcompl6_ext = 0;
  assign gnd_powerdown6_ext = 0;
  assign gnd_txdata7_ext = 0;
  assign gnd_txdatak7_ext = 0;
  assign gnd_txdetectrx7_ext = 0;
  assign gnd_txelecidle7_ext = 0;
  assign gnd_rxpolarity7_ext = 0;
  assign gnd_txcompl7_ext = 0;
  assign gnd_powerdown7_ext = 0;

  // Corrected ACNCPI: Use primary input dft_reset_n for async reset
  always @(posedge refclk or negedge dft_reset_n)
    begin
      if (dft_reset_n == 1'b0) // Use primary input reset
          reconfig_clk_reg <= 1'b0;
      else
        reconfig_clk_reg <= ~reconfig_clk_reg;
    end
  assign reconfig_clk = reconfig_clk_reg; // Assign internal reg to output port

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
  assign gxb_powerdown = ~pcie_rstn; // pcie_rstn (output from rst_clk_gen) still used here
  assign pll_powerdown = ~pcie_rstn; // pcie_rstn (output from rst_clk_gen) still used here
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
  assign connected_bits = connected