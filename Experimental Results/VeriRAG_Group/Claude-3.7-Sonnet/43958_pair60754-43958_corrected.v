`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_hip_s4gx_gen2_x4_128_example_chaining_top (
                                                         input wire test_i,
                                                         input wire free_100MHz,
                                                         input wire local_rstn_ext,
                                                         input wire pcie_rstn,
                                                         input wire refclk,
                                                         input wire req_compliance_push_button_n,
                                                         input wire rx_in0,
                                                         input wire rx_in1,
                                                         input wire rx_in2,
                                                         input wire rx_in3,
                                                         input wire [7:0] usr_sw,
                                                         output wire L0_led,
                                                         output wire alive_led,
                                                         output wire comp_led,
                                                         output wire gen2_led,
                                                         output wire [3:0] lane_active_led,
                                                         output wire tx_out0,
                                                         output wire tx_out1,
                                                         output wire tx_out2,
                                                         output wire tx_out3
                                                      );
  wire          clk_out_buf;
  wire          dft_clk_out_buf;
  wire          any_rstn;
  reg           any_rstn_r;
  reg           any_rstn_rr;
  wire          local_rstn;
  wire          safe_mode;
  wire          set_compliance_mode;
  wire          req_compliance_soft_ctrl;
  wire [39:0]   test_in;
  wire          test_in_32_hip;
  wire          test_in_5_hip;
  wire [8:0]    test_out_icm;
  wire          gen2_speed;
  wire [3:0]    open_lane_width_code;
  wire [3:0]    open_phy_sel_code;
  wire [3:0]    open_ref_clk_sel_code;
  wire          phystatus_ext;
  wire [1:0]    powerdown_ext;
  wire [7:0]    rxdata0_ext;
  wire [7:0]    rxdata1_ext;
  wire [7:0]    rxdata2_ext;
  wire [7:0]    rxdata3_ext;
  wire          rxdatak0_ext;
  wire          rxdatak1_ext;
  wire          rxdatak2_ext;
  wire          rxdatak3_ext;
  wire          rxelecidle0_ext;
  wire          rxelecidle1_ext;
  wire          rxelecidle2_ext;
  wire          rxelecidle3_ext;
  wire          rxpolarity0_ext;
  wire          rxpolarity1_ext;
  wire          rxpolarity2_ext;
  wire          rxpolarity3_ext;
  wire [2:0]    rxstatus0_ext;
  wire [2:0]    rxstatus1_ext;
  wire [2:0]    rxstatus2_ext;
  wire [2:0]    rxstatus3_ext;
  wire          rxvalid0_ext;
  wire          rxvalid1_ext;
  wire          rxvalid2_ext;
  wire          rxvalid3_ext;
  wire          txcompl0_ext;
  wire          txcompl1_ext;
  wire          txcompl2_ext;
  wire          txcompl3_ext;
  wire [7:0]    txdata0_ext;
  wire [7:0]    txdata1_ext;
  wire [7:0]    txdata2_ext;
  wire [7:0]    txdata3_ext;
  wire          txdatak0_ext;
  wire          txdatak1_ext;
  wire          txdatak2_ext;
  wire          txdatak3_ext;
  wire          txdetectrx_ext;
  wire          txelecidle0_ext;
  wire          txelecidle1_ext;
  wire          txelecidle2_ext;
  wire          txelecidle3_ext;

  reg [24:0]    alive_cnt;
  reg           alive_led_r;
  reg           comp_led_r;
  reg           L0_led_r;
  reg [3:0]     lane_active_led_r;
  reg           gen2_led_r;

  assign safe_mode = 1;
  assign local_rstn = safe_mode | local_rstn_ext;
  assign any_rstn = pcie_rstn & local_rstn;
  assign dft_clk_out_buf = test_i ? refclk : clk_out_buf;

  assign test_in[39:33] = 0;
  assign set_compliance_mode = usr_sw[0];
  assign req_compliance_soft_ctrl = 0;
  assign test_in[32] = test_in_32_hip;
  assign test_in[31:9] = 0;
  assign test_in[8:6] = safe_mode ? 4'b010 : usr_sw[3:1];
  assign test_in[5] = test_in_5_hip;
  assign test_in[4:0] = 5'b01000;

  assign alive_led = alive_led_r;
  assign comp_led = comp_led_r;
  assign L0_led = L0_led_r;
  assign lane_active_led = lane_active_led_r;
  assign gen2_led = gen2_led_r;

  always @(posedge dft_clk_out_buf or negedge any_rstn) begin
    if (!any_rstn) begin
      any_rstn_r <= 0;
      any_rstn_rr <= 0;
    end
    else begin
      any_rstn_r <= 1;
      any_rstn_rr <= any_rstn_r;
    end
  end

  always @(posedge dft_clk_out_buf or negedge any_rstn_rr) begin
    if (!any_rstn_rr) begin
      alive_cnt <= 0;
      alive_led_r <= 0;
      comp_led_r <= 0;
      L0_led_r <= 0;
      lane_active_led_r <= 0;
    end
    else begin
      alive_cnt <= alive_cnt + 1;
      alive_led_r <= alive_cnt[24];
      comp_led_r <= ~(test_out_icm[4:0] == 5'b00011);
      L0_led_r <= ~(test_out_icm[4:0] == 5'b01111);
      lane_active_led_r[3:0] <= ~(test_out_icm[8:5]);
    end
  end

  always @(posedge dft_clk_out_buf or negedge any_rstn_rr) begin
    if (!any_rstn_rr)
      gen2_led_r <= 0;
    else
      gen2_led_r <= ~gen2_speed;
  end

  altpcierd_compliance_test pcie_compliance_test_enable (
    .local_rstn(local_rstn_ext),
    .pcie_rstn(pcie_rstn),
    .refclk(refclk),
    .req_compliance_push_button_n(req_compliance_push_button_n),
    .req_compliance_soft_ctrl(req_compliance_soft_ctrl),
    .set_compliance_mode(set_compliance_mode),
    .test_in_32_hip(test_in_32_hip),
    .test_in_5_hip(test_in_5_hip)
  );

  pcie_hip_s4gx_gen2_x4_128_example_chaining_pipen1b core (
    .core_clk_out(clk_out_buf),
    .free_100MHz(free_100MHz),
    .gen2_speed(gen2_speed),
    .lane_width_code(open_lane_width_code),
    .local_rstn(local_rstn),
    .pcie_rstn(pcie_rstn),
    .phy_sel_code(open_phy_sel_code),
    .phystatus_ext(phystatus_ext),
    .pipe_mode(1'b0),
    .pld_clk(clk_out_buf),
    .powerdown_ext(powerdown_ext),
    .ref_clk_sel_code(open_ref_clk_sel_code),
    .refclk(refclk),
    .rx_in0(rx_in0),
    .rx_in1(rx_in1),
    .rx_in2(rx_in2),
    .rx_in3(rx_in3),
    .rxdata0_ext(rxdata0_ext),
    .rxdata1_ext(rxdata1_ext),
    .rxdata2_ext(rxdata2_ext),
    .rxdata3_ext(rxdata3_ext),
    .rxdatak0_ext(rxdatak0_ext),
    .rxdatak1_ext(rxdatak1_ext),
    .rxdatak2_ext(rxdatak2_ext),
    .rxdatak3_ext(rxdatak3_ext),
    .rxelecidle0_ext(rxelecidle0_ext),
    .rxelecidle1_ext(rxelecidle1_ext),
    .rxelecidle2_ext(rxelecidle2_ext),
    .rxelecidle3_ext(rxelecidle3_ext),
    .rxpolarity0_ext(rxpolarity0_ext),
    .rxpolarity1_ext(rxpolarity1_ext),
    .rxpolarity2_ext(rxpolarity2_ext),
    .rxpolarity3_ext(rxpolarity3_ext),
    .rxstatus0_ext(rxstatus0_ext),
    .rxstatus1_ext(rxstatus1_ext),
    .rxstatus2_ext(rxstatus2_ext),
    .rxstatus3_ext(rxstatus3_ext),
    .rxvalid0_ext(rxvalid0_ext),
    .rxvalid1_ext(rxvalid1_ext),
    .rxvalid2_ext(rxvalid2_ext),
    .rxvalid3_ext(rxvalid3_ext),
    .test_in(test_in),
    .test_out_icm(test_out_icm),
    .tx_out0(tx_out0),
    .tx_out1(tx_out1),
    .tx_out2(tx_out2),
    .tx_out3(tx_out3),
    .txcompl0_ext(txcompl0_ext),
    .txcompl1_ext(txcompl1_ext),
    .txcompl2_ext(txcompl2_ext),
    .txcompl3_ext(txcompl3_ext),
    .txdata0_ext(txdata0_ext),
    .txdata1_ext(txdata1_ext),
    .txdata2_ext(txdata2_ext),
    .txdata3_ext(txdata3_ext),
    .txdatak0_ext(txdatak0_ext),
    .txdatak1_ext(txdatak1_ext),
    .txdatak2_ext(txdatak2_ext),
    .txdatak3_ext(txdatak3_ext),
    .txdetectrx_ext(txdetectrx_ext),
    .txelecidle0_ext(txelecidle0_ext),
    .txelecidle1_ext(txelecidle1_ext),
    .txelecidle2_ext(txelecidle2_ext),
    .txelecidle3_ext(txelecidle3_ext)
  );

endmodule