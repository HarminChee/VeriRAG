`timescale 1ns / 1ps

module pcie_hip_s4gx_gen2_x4_128_example_chaining_top (
                                                         free_100MHz,
                                                         local_rstn_ext,
                                                         pcie_rstn,
                                                         refclk,
                                                         req_compliance_push_button_n,
                                                         rx_in0,
                                                         rx_in1,
                                                         rx_in2,
                                                         rx_in3,
                                                         usr_sw,
                                                         L0_led,
                                                         alive_led,
                                                         comp_led,
                                                         gen2_led,
                                                         lane_active_led,
                                                         tx_out0,
                                                         tx_out1,
                                                         tx_out2,
                                                         tx_out3
                                                      )
;
  output           L0_led;
  output           alive_led;
  output           comp_led;
  output           gen2_led;
  output  [  3: 0] lane_active_led;
  output           tx_out0;
  output           tx_out1;
  output           tx_out2;
  output           tx_out3;
  input            free_100MHz;
  input            local_rstn_ext;
  input            pcie_rstn;
  input            refclk;
  input            req_compliance_push_button_n;
  input            rx_in0;
  input            rx_in1;
  input            rx_in2;
  input            rx_in3;
  input   [  7: 0] usr_sw;

  reg              L0_led;
  reg     [ 24: 0] alive_cnt;
  reg              alive_led;
  wire             any_rstn;
  reg              any_rstn_r ;
  reg              any_rstn_rr ;
  wire             clk_out_buf;
  reg              comp_led;
  reg              gen2_led;
  wire             gen2_speed;
  reg     [  3: 0] lane_active_led;
  wire             local_rstn;
  wire    [  3: 0] open_lane_width_code;
  wire    [  3: 0] open_phy_sel_code;
  wire    [  3: 0] open_ref_clk_sel_code;
  wire             phystatus_ext;
  wire    [  1: 0] powerdown_ext;
  wire             req_compliance_soft_ctrl;
  wire    [  7: 0] rxdata0_ext;
  wire    [  7: 0] rxdata1_ext;
  wire    [  7: 0] rxdata2_ext;
  wire    [  7: 0] rxdata3_ext;
  wire             rxdatak0_ext;
  wire             rxdatak1_ext;
  wire             rxdatak2_ext;
  wire             rxdatak3_ext;
  wire             rxelecidle0_ext;
  wire             rxelecidle1_ext;
  wire             rxelecidle2_ext;
  wire             rxelecidle3_ext;
  wire             rxpolarity0_ext;
  wire             rxpolarity1_ext;
  wire             rxpolarity2_ext;
  wire             rxpolarity3_ext;
  wire    [  2: 0] rxstatus0_ext;
  wire    [  2: 0] rxstatus1_ext;
  wire    [  2: 0] rxstatus2_ext;
  wire    [  2: 0] rxstatus3_ext;
  wire             rxvalid0_ext;
  wire             rxvalid1_ext;
  wire             rxvalid2_ext;
  wire             rxvalid3_ext;
  wire             safe_mode;
  wire             set_compliance_mode;
  wire    [ 39: 0] test_in;
  wire             test_in_32_hip;
  wire             test_in_5_hip;
  wire    [  8: 0] test_out_icm;
  wire             tx_out0;
  wire             tx_out1;
  wire             tx_out2;
  wire             tx_out3;
  wire             txcompl0_ext;
  wire             txcompl1_ext;
  wire             txcompl2_ext;
  wire             txcompl3_ext;
  wire    [  7: 0] txdata0_ext;
  wire    [  7: 0] txdata1_ext;
  wire    [  7: 0] txdata2_ext;
  wire    [  7: 0] txdata3_ext;
  wire             txdatak0_ext;
  wire             txdatak1_ext;
  wire             txdatak2_ext;
  wire             txdatak3_ext;
  wire             txdetectrx_ext;
  wire             txelecidle0_ext;
  wire             txelecidle1_ext;
  wire             txelecidle2_ext;
  wire             txelecidle3_ext;

  assign safe_mode = 1'b1; // Use explicit width
  assign local_rstn = safe_mode | local_rstn_ext;
  assign any_rstn = pcie_rstn & local_rstn;
  assign test_in[39 : 33] = 7'b0; // Use explicit width
  assign set_compliance_mode = usr_sw[0];
  assign req_compliance_soft_ctrl = 1'b0; // Use explicit width
  assign test_in[32] = test_in_32_hip;
  assign test_in[31 : 9] = 23'b0; // Use explicit width
  assign test_in[8 : 6] = safe_mode ? 3'b010 : usr_sw[3 : 1]; // Corrected width from 4'b010
  assign test_in[5] = test_in_5_hip;
  assign test_in[4 : 0] = 5'b01000;

  always @(posedge clk_out_buf or negedge any_rstn)
    begin
      if (!any_rstn) // Use ! for checking low active reset
        begin
          any_rstn_r <= 1'b0;
          any_rstn_rr <= 1'b0;
        end
      else
        begin
          any_rstn_r <= 1'b1;
          any_rstn_rr <= any_rstn_r;
        end
    end

  always @(posedge clk_out_buf or negedge any_rstn_rr)
    begin
      if (!any_rstn_rr) // Use ! for checking low active reset
        begin
          alive_cnt <= 25'b0;
          alive_led <= 1'b0;
          comp_led <= 1'b0; // Assume LEDs are active low, initial state OFF (high) or ON (low)? Let's keep initial OFF (0) for now.
          L0_led <= 1'b0;
          lane_active_led <= 4'b0;
        end
      else
        begin
          alive_cnt <= alive_cnt + 1'b1;
          alive_led <= alive_cnt[24];
          // Assuming LEDs are active low (ON when signal is 0)
          comp_led <= ~(test_out_icm[4 : 0] == 5'b00011); // ON if LTSSM is NOT 0x03 (Detect.Quiet)
          L0_led <= ~(test_out_icm[4 : 0] == 5'b01111);   // ON if LTSSM is NOT 0x0F (L0)
          lane_active_led[3 : 0] <= ~(test_out_icm[8 : 5]); // ON if corresponding lane status bit is 0
        end
    end

  always @(posedge clk_out_buf or negedge any_rstn_rr)
    begin
      if (!any_rstn_rr) // Use ! for checking low active reset
          gen2_led <= 1'b0; // Assume LED active low, initial state OFF (0)
      else
        gen2_led <= ~gen2_speed; // ON if gen2_speed is 0 (Gen1 speed)
    end

  altpcierd_compliance_test pcie_compliance_test_enable
    (
      .local_rstn                   (local_rstn_ext),             // input
      .pcie_rstn                    (pcie_rstn),                  // input
      .refclk                       (refclk),                     // input
      .req_compliance_push_button_n (req_compliance_push_button_n),// input
      .req_compliance_soft_ctrl     (req_compliance_soft_ctrl),   // input
      .set_compliance_mode          (set_compliance_mode),        // input
      .test_in_32_hip               (test_in_32_hip),             // output
      .test_in_5_hip                (test_in_5_hip)               // output
    );

  pcie_hip_s4gx_gen2_x4_128_example_chaining_pipen1b core
    (
      .core_clk_out     (clk_out_buf),          // output
      .free_100MHz      (free_100MHz),          // input
      .gen2_speed       (gen2_speed),           // output
      .lane_width_code  (open_lane_width_code), // output [3:0]
      .local_rstn       (local_rstn),           // input
      .pcie_rstn        (pcie_rstn),            // input
      .phy_sel_code     (open_phy_sel_code),    // output [3:0]
      .phystatus_ext    (phystatus_ext),        // input
      .pipe_mode        (1'b0),                 // input
      .pld_clk          (clk_out_buf),          // input
      .powerdown_ext    (powerdown_ext),        // input [1:0]
      .ref_clk_sel_code (open_ref_clk_sel_code),// output [3:0]
      .refclk           (refclk),               // input
      .rx_in0           (rx_in0),               // input
      .rx_in1           (rx_in1),               // input
      .rx_in2           (rx_in2),               // input
      .rx_in3           (rx_in3),               // input
      .rxdata0_ext      (rxdata0_ext),          // output [7:0]
      .rxdata1_ext      (rxdata1_ext),          // output [7:0]
      .rxdata2_ext      (rxdata2_ext),          // output [7:0]
      .rxdata3_ext      (rxdata3_ext),          // output [7:0]
      .rxdatak0_ext     (rxdatak0_ext),         // output
      .rxdatak1_ext     (rxdatak1_ext),         // output
      .rxdatak2_ext     (rxdatak2_ext),         // output
      .rxdatak3_ext     (rxdatak3_ext),         // output
      .rxelecidle0_ext  (rxelecidle0_ext),      // output
      .rxelecidle1_ext  (rxelecidle1_ext),      // output
      .rxelecidle2_ext  (rxelecidle2_ext),      // output
      .rxelecidle3_ext  (rxelecidle3_ext),      // output
      .rxpolarity0_ext  (rxpolarity0_ext),      // input
      .rxpolarity1_ext  (rxpolarity1_ext),      // input
      .rxpolarity2_ext  (rxpolarity2_ext),      // input
      .rxpolarity3_ext  (rxpolarity3_ext),      // input
      .rxstatus0_ext    (rxstatus0_ext),        // output [2:0]
      .rxstatus1_ext    (rxstatus1_ext),        // output [2:0]
      .rxstatus2_ext    (rxstatus2_ext),        // output [2:0]
      .rxstatus3_ext    (rxstatus3_ext),        // output [2:0]
      .rxvalid0_ext     (rxvalid0_ext),         // output
      .rxvalid1_ext     (rxvalid1_ext),         // output
      .rxvalid2_ext     (rxvalid2_ext),         // output
      .rxvalid3_ext     (rxvalid3_ext),         // output
      .test_in          (test_in),              // input [39:0]
      .test_out_icm     (test_out_icm),         // output [8:0]
      .tx_out0          (tx_out0),              // output
      .tx_out1          (tx_out1),              // output
      .tx_out2          (tx_out2),              // output
      .tx_out3          (tx_out3),              // output
      .txcompl0_ext     (txcompl0_ext),         // input
      .txcompl1_ext     (txcompl1_ext),         // input
      .txcompl2_ext     (txcompl2_ext),         // input
      .txcompl3_ext     (txcompl3_ext),         // input
      .txdata0_ext      (txdata0_ext),          // input [7:0]
      .txdata1_ext      (txdata1_ext),          // input [7:0]
      .txdata2_ext      (txdata2_ext),          // input [7:0]
      .txdata3_ext      (txdata3_ext),          // input [7:0]
      .txdatak0_ext     (txdatak0_ext),         // input
      .txdatak1_ext     (txdatak1_ext),         // input
      .txdatak2_ext     (txdatak2_ext),         // input
      .txdatak3_ext     (txdatak3_ext),         // input
      .txdetectrx_ext   (txdetectrx_ext),       // input
      .txelecidle0_ext  (txelecidle0_ext),      // input
      .txelecidle1_ext  (txelecidle1_ext),      // input
      .txelecidle2_ext  (txelecidle2_ext),      // input
      .txelecidle3_ext  (txelecidle3_ext)       // input
    );

endmodule