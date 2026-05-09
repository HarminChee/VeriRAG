`timescale 1ns/1ps
`timescale 1ns/1ps
module system
(
  input wire CLK100MHZ,
  input wire ck_rst,
  inout wire led_0,
  inout wire led_1,
  inout wire led_2,
  inout wire led_3,
  output wire led0_r,
  output wire led0_g,
  output wire led0_b,
  output wire led1_r,
  output wire led1_g,
  output wire led1_b,
  output wire led2_r,
  output wire led2_g,
  output wire led2_b,
  inout wire sw_0,
  inout wire sw_1,
  inout wire sw_2,
  input wire sw_3,
  inout wire btn_0,
  inout wire btn_1,
  inout wire btn_2,
  inout wire btn_3,
  output wire qspi_cs,
  output wire qspi_sck,
  inout wire [3:0] qspi_dq,
  output wire uart_rxd_out,
  input wire uart_txd_in,
  inout wire ja_0,
  inout wire ja_1,
  inout wire [19:0] ck_io,
  inout wire ck_miso,
  inout wire ck_mosi,
  inout wire ck_ss,
  inout wire ck_sck,
  inout wire jd_0, 
  inout wire jd_1, 
  inout wire jd_2, 
  inout wire jd_4, 
  inout wire jd_5, 
  input wire jd_6 
);
  wire clk_out1;
  wire hfclk;
  wire mmcm_locked;
  wire reset_core;
  wire reset_bus;
  wire reset_periph;
  wire reset_intcon_n;
  wire reset_periph_n;
  wire dut_clock;
  wire dut_reset;
  wire dut_io_pads_jtag_TCK_i_ival;
  wire dut_io_pads_jtag_TCK_o_oval;
  wire dut_io_pads_jtag_TCK_o_oe;
  wire dut_io_pads_jtag_TCK_o_ie;
  wire dut_io_pads_jtag_TCK_o_pue;
  wire dut_io_pads_jtag_TCK_o_ds;
  wire dut_io_pads_jtag_TMS_i_ival;
  wire dut_io_pads_jtag_TMS_o_oval;
  wire dut_io_pads_jtag_TMS_o_oe;
  wire dut_io_pads_jtag_TMS_o_ie;
  wire dut_io_pads_jtag_TMS_o_pue;
  wire dut_io_pads_jtag_TMS_o_ds;
  wire dut_io_pads_jtag_TDI_i_ival;
  wire dut_io_pads_jtag_TDI_o_oval;
  wire dut_io_pads_jtag_TDI_o_oe;
  wire dut_io_pads_jtag_TDI_o_ie;
  wire dut_io_pads_jtag_TDI_o_pue;
  wire dut_io_pads_jtag_TDI_o_ds;
  wire dut_io_pads_jtag_TDO_i_ival;
  wire dut_io_pads_jtag_TDO_o_oval;
  wire dut_io_pads_jtag_TDO_o_oe;
  wire dut_io_pads_jtag_TDO_o_ie;
  wire dut_io_pads_jtag_TDO_o_pue;
  wire dut_io_pads_jtag_TDO_o_ds;
  wire dut_io_pads_jtag_TRST_n_i_ival;
  wire dut_io_pads_jtag_TRST_n_o_oval;
  wire dut_io_pads_jtag_TRST_n_o_oe;
  wire dut_io_pads_jtag_TRST_n_o_ie;
  wire dut_io_pads_jtag_TRST_n_o_pue;
  wire dut_io_pads_jtag_TRST_n_o_ds;
  wire dut_io_pads_gpio_0_i_ival;
  wire dut_io_pads_gpio_0_o_oval;
  wire dut_io_pads_gpio_0_o_oe;
  wire dut_io_pads_gpio_0_o_ie;
  wire dut_io_pads_gpio_0_o_pue;
  wire dut_io_pads_gpio_0_o_ds;
  wire dut_io_pads_gpio_1_i_ival;
  wire dut_io_pads_gpio_1_o_oval;
  wire dut_io_pads_gpio_1_o_oe;
  wire dut_io_pads_gpio_1_o_ie;
  wire dut_io_pads_gpio_1_o_pue;
  wire dut_io_pads_gpio_1_o_ds;
  wire dut_io_pads_gpio_2_i_ival;
  wire dut_io_pads_gpio_2_o_oval;
  wire dut_io_pads_gpio_2_o_oe;
  wire dut_io_pads_gpio_2_o_ie;
  wire dut_io_pads_gpio_2_o_pue;
  wire dut_io_pads_gpio_2_o_ds;
  wire dut_io_pads_gpio_3_i_ival;
  wire dut_io_pads_gpio_3_o_oval;
  wire dut_io_pads_gpio_3_o_oe;
  wire dut_io_pads_gpio_3_o_ie;
  wire dut_io_pads_gpio_3_o_pue;
  wire dut_io_pads_gpio_3_o_ds;
  wire dut_io_pads_gpio_4_i_ival;
  wire dut_io_pads_gpio_4_o_oval;
  wire dut_io_pads_gpio_4_o_oe;
  wire dut_io_pads_gpio_4_o_ie;
  wire dut_io_pads_gpio_4_o_pue;
  wire dut_io_pads_gpio_4_o_ds;
  wire dut_io_pads_gpio_5_i_ival;
  wire dut_io_pads_gpio_5_o_oval;
  wire dut_io_pads_gpio_5_o_oe;
  wire dut_io_pads_gpio_5_o_ie;
  wire dut_io_pads_gpio_5_o_pue;
  wire dut_io_pads_gpio_5_o_ds;
  wire dut_io_pads_gpio_6_i_ival;
  wire dut_io_pads_gpio_6_o_oval;
  wire dut_io_pads_gpio_6_o_oe;
  wire dut_io_pads_gpio_6_o_ie;
  wire dut_io_pads_gpio_6_o_pue;
  wire dut_io_pads_gpio_6_o_ds;
  wire dut_io_pads_gpio_7_i_ival;
  wire dut_io_pads_gpio_7_o_oval;
  wire dut_io_pads_gpio_7_o_oe;
  wire dut_io_pads_gpio_7_o_ie;
  wire dut_io_pads_gpio_7_o_pue;
  wire dut_io_pads_gpio_7_o_ds;
  wire dut_io_pads_gpio_8_i_ival;
  wire dut_io_pads_gpio_8_o_oval;
  wire dut_io_pads_gpio_8_o_oe;
  wire dut_io_pads_gpio_8_o_ie;
  wire dut_io_pads_gpio_8_o_pue;
  wire dut_io_pads_gpio_8_o_ds;
  wire dut_io_pads_gpio_9_i_ival;
  wire dut_io_pads_gpio_9_o_oval;
  wire dut_io_pads_gpio_9_o_oe;
  wire dut_io_pads_gpio_9_o_ie;
  wire dut_io_pads_gpio_9_o_pue;
  wire dut_io_pads_gpio_9_o_ds;
  wire dut_io_pads_gpio_10_i_ival;
  wire dut_io_pads_gpio_10_o_oval;
  wire dut_io_pads_gpio_10_o_oe;
  wire dut_io_pads_gpio_10_o_ie;
  wire dut_io_pads_gpio_10_o_pue;
  wire dut_io_pads_gpio_10_o_ds;
  wire dut_io_pads_gpio_11_i_ival;
  wire dut_io_pads_gpio_11_o_oval;
  wire dut_io_pads_gpio_11_o_oe;
  wire dut_io_pads_gpio_11_o_ie;
  wire dut_io_pads_gpio_11_o_pue;
  wire dut_io_pads_gpio_11_o_ds;
  wire dut_io_pads_gpio_12_i_ival;
  wire dut_io_pads_gpio_12_o_oval;
  wire dut_io_pads_gpio_12_o_oe;
  wire dut_io_pads_gpio_12_o_ie;
  wire dut_io_pads_gpio_12_o_pue;
  wire dut_io_pads_gpio_12_o_ds;
  wire dut_io_pads_gpio_13_i_ival;
  wire dut_io_pads_gpio_13_o_oval;
  wire dut_io_pads_gpio_13_o_oe;
  wire dut_io_pads_gpio_13_o_ie;
  wire dut_io_pads_gpio_13_o_pue;
  wire dut_io_pads_gpio_13_o_ds;
  wire dut_io_pads_gpio_14_i_ival;
  wire dut_io_pads_gpio_14_o_oval;
  wire dut_io_pads_gpio_14_o_oe;
  wire dut_io_pads_gpio_14_o_ie;
  wire dut_io_pads_gpio_14_o_pue;
  wire dut_io_pads_gpio_14_o_ds;
  wire dut_io_pads_gpio_15_i_ival;
  wire dut_io_pads_gpio_15_o_oval;
  wire dut_io_pads_gpio_15_o_oe;
  wire dut_io_pads_gpio_15_o_ie;
  wire dut_io_pads_gpio_15_o_pue;
  wire dut_io_pads_gpio_15_o_ds;
  wire dut_io_pads_gpio_16_i_ival;
  wire dut_io_pads_gpio_16_o_oval;
  wire dut_io_pads_gpio_16_o_oe;
  wire dut_io_pads_gpio_16_o_ie;
  wire dut_io_pads_gpio_16_o_pue;
  wire dut_io_pads_gpio_16_o_ds;
  wire dut_io_pads_gpio_17_i_ival;
  wire dut_io_pads_gpio_17_o_oval;
  wire dut_io_pads_gpio_17_o_oe;
  wire dut_io_pads_gpio_17_o_ie;
  wire dut_io_pads_gpio_17_o_pue;
  wire dut_io_pads_gpio_17_o_ds;
  wire dut_io_pads_gpio_18_i_ival;
  wire dut_io_pads_gpio_18_o_oval;
  wire dut_io_pads_gpio_18_o_oe;
  wire dut_io_pads_gpio_18_o_ie;
  wire dut_io_pads_gpio_18_o_pue;
  wire dut_io_pads_gpio_18_o_ds;
  wire dut_io_pads_gpio_19_i_ival;
  wire dut_io_pads_gpio_19_o_oval;
  wire dut_io_pads_gpio_19_o_oe;
  wire dut_io_pads_gpio_19_o_ie;
  wire dut_io_pads_gpio_19_o_pue;
  wire dut_io_pads_gpio_19_o_ds;
  wire dut_io_pads_gpio_20_i_ival;
  wire dut_io_pads_gpio_20_o_oval;
  wire dut_io_pads_gpio_20_o_oe;
  wire dut_io_pads_gpio_20_o_ie;
  wire dut_io_pads_gpio_20_o_pue;
  wire dut_io_pads_gpio_20_o_ds;
  wire dut_io_pads_gpio_21_i_ival;
  wire dut_io_pads_gpio_21_o_oval;
  wire dut_io_pads_gpio_21_o_oe;
  wire dut_io_pads_gpio_21_o_ie;
  wire dut_io_pads_gpio_21_o_pue;
  wire dut_io_pads_gpio_21_o_ds;
  wire dut_io_pads_gpio_22_i_ival;
  wire dut_io_pads_gpio_22_o_oval;
  wire dut_io_pads_gpio_22_o_oe;
  wire dut_io_pads_gpio_22_o_ie;
  wire dut_io_pads_gpio_22_o_pue;
  wire dut_io_pads_gpio_22_o_ds;
  wire dut_io_pads_gpio_23_i_ival;
  wire dut_io_pads_gpio_23_o_oval;
  wire dut_io_pads_gpio_23_o_oe;
  wire dut_io_pads_gpio_23_o_ie;
  wire dut_io_pads_gpio_23_o_pue;
  wire dut_io_pads_gpio_23_o_ds;
  wire dut_io_pads_gpio_24_i_ival;
  wire dut_io_pads_gpio_24_o_oval;
  wire dut_io_pads_gpio_24_o_oe;
  wire dut_io_pads_gpio_24_o_ie;
  wire dut_io_pads_gpio_24_o_pue;
  wire dut_io_pads_gpio_24_o_ds;
  wire dut_io_pads_gpio_25_i_ival;
  wire dut_io_pads_gpio_25_o_oval;
  wire dut_io_pads_gpio_25_o_oe;
  wire dut_io_pads_gpio_25_o_ie;
  wire dut_io_pads_gpio_25_o_pue;
  wire dut_io_pads_gpio_25_o_ds;
  wire dut_io_pads_gpio_26_i_ival;
  wire dut_io_pads_gpio_26_o_oval;
  wire dut_io_pads_gpio_26_o_oe;
  wire dut_io_pads_gpio_26_o_ie;
  wire dut_io_pads_gpio_26_o_pue;
  wire dut_io_pads_gpio_26_o_ds;
  wire dut_io_pads_gpio_27_i_ival;
  wire dut_io_pads_gpio_27_o_oval;
  wire dut_io_pads_gpio_27_o_oe;
  wire dut_io_pads_gpio_27_o_ie;
  wire dut_io_pads_gpio_27_o_pue;
  wire dut_io_pads_gpio_27_o_ds;
  wire dut_io_pads_gpio_28_i_ival;
  wire dut_io_pads_gpio_28_o_oval;
  wire dut_io_pads_gpio_28_o_oe;
  wire dut_io_pads_gpio_28_o_ie;
  wire dut_io_pads_gpio_28_o_pue;
  wire dut_io_pads_gpio_28_o_ds;
  wire dut_io_pads_gpio_29_i_ival;
  wire dut_io_pads_gpio_29_o_oval;
  wire dut_io_pads_gpio_29_o_oe;
  wire dut_io_pads_gpio_29_o_ie;
  wire dut_io_pads_gpio_29_o_pue;
  wire dut_io_pads_gpio_29_o_ds;
  wire dut_io_pads_gpio_30_i_ival;
  wire dut_io_pads_gpio_30_o_oval;
  wire dut_io_pads_gpio_30_o_oe;
  wire dut_io_pads_gpio_30_o_ie;
  wire dut_io_pads_gpio_30_o_pue;
  wire dut_io_pads_gpio_30_o_ds;
  wire dut_io_pads_gpio_31_i_ival;
  wire dut_io_pads_gpio_31_o_oval;
  wire dut_io_pads_gpio_31_o_oe;
  wire dut_io_pads_gpio_31_o_ie;
  wire dut_io_pads_gpio_31_o_pue;
  wire dut_io_pads_gpio_31_o_ds;
  wire dut_io_pads_qspi_sck_i_ival;
  wire dut_io_pads_qspi_sck_o_oval;
  wire dut_io_pads_qspi_sck_o_oe;
  wire dut_io_pads_qspi_sck_o_ie;
  wire dut_io_pads_qspi_sck_o_pue;
  wire dut_io_pads_qspi_sck_o_ds;
  wire dut_io_pads_qspi_dq_0_i_ival;
  wire dut_io_pads_qspi_dq_0_o_oval;
  wire dut_io_pads_qspi_dq_0_o_oe;
  wire dut_io_pads_qspi_dq_0_o_ie;
  wire dut_io_pads_qspi_dq_0_o_pue;
  wire dut_io_pads_qspi_dq_0_o_ds;
  wire dut_io_pads_qspi_dq_1_i_ival;
  wire dut_io_pads_qspi_dq_1_o_oval;
  wire dut_io_pads_qspi_dq_1_o_oe;
  wire dut_io_pads_qspi_dq_1_o_ie;
  wire dut_io_pads_qspi_dq_1_o_pue;
  wire dut_io_pads_qspi_dq_1_o_ds;
  wire dut_io_pads_qspi_dq_2_i_ival;
  wire dut_io_pads_qspi_dq_2_o_oval;
  wire dut_io_pads_qspi_dq_2_o_oe;
  wire dut_io_pads_qspi_dq_2_o_ie;
  wire dut_io_pads_qspi_dq_2_o_pue;
  wire dut_io_pads_qspi_dq_2_o_ds;
  wire dut_io_pads_qspi_dq_3_i_ival;
  wire dut_io_pads_qspi_dq_3_o_oval;
  wire dut_io_pads_qspi_dq_3_o_oe;
  wire dut_io_pads_qspi_dq_3_o_ie;
  wire dut_io_pads_qspi_dq_3_o_pue;
  wire dut_io_pads_qspi_dq_3_o_ds;
  wire dut_io_pads_qspi_cs_0_i_ival;
  wire dut_io_pads_qspi_cs_0_o_oval;
  wire dut_io_pads_qspi_cs_0_o_oe;
  wire dut_io_pads_qspi_cs_0_o_ie;
  wire dut_io_pads_qspi_cs_0_o_pue;
  wire dut_io_pads_qspi_cs_0_o_ds;
  wire dut_io_pads_aon_erst_n_i_ival;
  wire dut_io_pads_aon_erst_n_o_oval;
  wire dut_io_pads_aon_erst_n_o_oe;
  wire dut_io_pads_aon_erst_n_o_ie;
  wire dut_io_pads_aon_erst_n_o_pue;
  wire dut_io_pads_aon_erst_n_o_ds;
  wire dut_io_pads_aon_lfextclk_i_ival;
  wire dut_io_pads_aon_lfextclk_o_oval;
  wire dut_io_pads_aon_lfextclk_o_oe;
  wire dut_io_pads_aon_lfextclk_o_ie;
  wire dut_io_pads_aon_lfextclk_o_pue;
  wire dut_io_pads_aon_lfextclk_o_ds;
  wire dut_io_pads_aon_pmu_dwakeup_n_i_ival;
  wire dut_io_pads_aon_pmu_dwakeup_n_o_oval;
  wire dut_io_pads_aon_pmu_dwakeup_n_o_oe;
  wire dut_io_pads_aon_pmu_dwakeup_n_o_ie;
  wire dut_io_pads_aon_pmu_dwakeup_n_o_pue;
  wire dut_io_pads_aon_pmu_dwakeup_n_o_ds;
  wire dut_io_pads_aon_pmu_vddpaden_i_ival;
  wire dut_io_pads_aon_pmu_vddpaden_o_oval;
  wire dut_io_pads_aon_pmu_vddpaden_o_oe;
  wire dut_io_pads_aon_pmu_vddpaden_o_ie;
  wire dut_io_pads_aon_pmu_vddpaden_o_pue;
  wire dut_io_pads_aon_pmu_vddpaden_o_ds;
  wire SRST_n; 
  mmcm ip_mmcm
  (
    .clk_in1(CLK100MHZ),
    .clk_out1(clk_out1), 
    .clk_out2(hfclk), 
    .resetn(ck_rst),
    .locked(mmcm_locked)
  );
  wire slowclk;
  clkdivider slowclkgen
  (
    .clk(clk_out1),
    .reset(~mmcm_locked),
    .clk_out(slowclk)
  );
  reset_sys ip_reset_sys
  (
    .slowest_sync_clk(clk_out1),
    .ext_reset_in(ck_rst & SRST_n), 
    .aux_reset_in(1'b1),
    .mb_debug_sys_rst(1'b0),
    .dcm_locked(mmcm_locked),
    .mb_reset(reset_core),
    .bus_struct_reset(reset_bus),
    .peripheral_reset(reset_periph),
    .interconnect_aresetn(reset_intcon_n),
    .peripheral_aresetn(reset_periph_n)
  );
  wire [3:0] qspi_ui_dq_o, qspi_ui_dq_oe;
  wire [3:0] qspi_ui_dq_i;
  PULLUP qspi_pullup[3:0]
  (
    .O(qspi_dq)
  );
  IOBUF qspi_iobuf[3:0]
  (
    .IO(qspi_dq),
    .O(qspi_ui_dq_i),
    .I(qspi_ui_dq_o),
    .T(~qspi_ui_dq_oe)
  );
  wire gpio_0;
  wire gpio_1;
  wire gpio_2;
  wire gpio_3;
  wire gpio_4;
  wire gpio_5;
  wire gpio_6;
  wire gpio_7;
  wire gpio_8;
  wire gpio_9;
  wire gpio_10;
  wire gpio_11;
  wire gpio_12;
  wire gpio_13;
  wire gpio_14;
  wire gpio_15;
  wire gpio_16;
  wire gpio_17;
  wire gpio_18;
  wire gpio_19;
  wire gpio_20;
  wire gpio_21;
  wire gpio_22;
  wire gpio_23;
  wire gpio_24;
  wire gpio_25;
  wire gpio_26;
  wire gpio_27;
  wire gpio_28;
  wire gpio_29;
  wire gpio_30;
  wire gpio_31;
  wire iobuf_gpio_0_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_0
  (
    .O(iobuf_gpio_0_o),
    .IO(gpio_0),
    .I(dut_io_pads_gpio_0_o_oval),
    .T(~dut_io_pads_gpio_0_o_oe)
  );
  assign dut_io_pads_gpio_0_i_ival = iobuf_gpio_0_o & dut_io_pads_gpio_0_o_ie;
  wire iobuf_gpio_1_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_1
  (
    .O(iobuf_gpio_1_o),
    .IO(gpio_1),
    .I(dut_io_pads_gpio_1_o_oval),
    .T(~dut_io_pads_gpio_1_o_oe)
  );
  assign dut_io_pads_gpio_1_i_ival = iobuf_gpio_1_o & dut_io_pads_gpio_1_o_ie;
  wire iobuf_gpio_2_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_2
  (
    .O(iobuf_gpio_2_o),
    .IO(gpio_2),
    .I(dut_io_pads_gpio_2_o_oval),
    .T(~dut_io_pads_gpio_2_o_oe)
  );
  assign dut_io_pads_gpio_2_i_ival = iobuf_gpio_2_o & dut_io_pads_gpio_2_o_ie;
  wire iobuf_gpio_3_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_3
  (
    .O(iobuf_gpio_3_o),
    .IO(gpio_3),
    .I(dut_io_pads_gpio_3_o_oval),
    .T(~dut_io_pads_gpio_3_o_oe)
  );
  assign dut_io_pads_gpio_3_i_ival = iobuf_gpio_3_o & dut_io_pads_gpio_3_o_ie;
  wire iobuf_gpio_4_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_4
  (
    .O(iobuf_gpio_4_o),
    .IO(gpio_4),
    .I(dut_io_pads_gpio_4_o_oval),
    .T(~dut_io_pads_gpio_4_o_oe)
  );
  assign dut_io_pads_gpio_4_i_ival = iobuf_gpio_4_o & dut_io_pads_gpio_4_o_ie;
  wire iobuf_gpio_5_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_5
  (
    .O(iobuf_gpio_5_o),
    .IO(gpio_5),
    .I(dut_io_pads_gpio_5_o_oval),
    .T(~dut_io_pads_gpio_5_o_oe)
  );
  assign dut_io_pads_gpio_5_i_ival = iobuf_gpio_5_o & dut_io_pads_gpio_5_o_ie;
  assign dut_io_pads_gpio_6_i_ival = 1'b0;
  assign dut_io_pads_gpio_7_i_ival = 1'b0;
  assign dut_io_pads_gpio_8_i_ival = 1'b0;
  wire iobuf_gpio_9_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_9
  (
    .O(iobuf_gpio_9_o),
    .IO(gpio_9),
    .I(dut_io_pads_gpio_9_o_oval),
    .T(~dut_io_pads_gpio_9_o_oe)
  );
  assign dut_io_pads_gpio_9_i_ival = iobuf_gpio_9_o & dut_io_pads_gpio_9_o_ie;
  wire iobuf_gpio_10_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_10
  (
    .O(iobuf_gpio_10_o),
    .IO(gpio_10),
    .I(dut_io_pads_gpio_10_o_oval),
    .T(~dut_io_pads_gpio_10_o_oe)
  );
  assign dut_io_pads_gpio_10_i_ival = iobuf_gpio_10_o & dut_io_pads_gpio_10_o_ie;
  wire iobuf_gpio_11_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_11
  (
    .O(iobuf_gpio_11_o),
    .IO(gpio_11),
    .I(dut_io_pads_gpio_11_o_oval),
    .T(~dut_io_pads_gpio_11_o_oe)
  );
  assign dut_io_pads_gpio_11_i_ival = iobuf_gpio_11_o & dut_io_pads_gpio_11_o_ie;
  wire iobuf_gpio_12_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_12
  (
    .O(iobuf_gpio_12_o),
    .IO(gpio_12),
    .I(dut_io_pads_gpio_12_o_oval),
    .T(~dut_io_pads_gpio_12_o_oe)
  );
  assign dut_io_pads_gpio_12_i_ival = iobuf_gpio_12_o & dut_io_pads_gpio_12_o_ie;
  wire iobuf_gpio_13_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_13
  (
    .O(iobuf_gpio_13_o),
    .IO(gpio_13),
    .I(dut_io_pads_gpio_13_o_oval),
    .T(~dut_io_pads_gpio_13_o_oe)
  );
  assign dut_io_pads_gpio_13_i_ival = iobuf_gpio_13_o & dut_io_pads_gpio_13_o_ie;
  wire iobuf_gpio_14_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_14
  (
    .O(iobuf_gpio_14_o),
    .IO(gpio_14),
    .I(dut_io_pads_gpio_14_o_oval),
    .T(~dut_io_pads_gpio_14_o_oe)
  );
  assign dut_io_pads_gpio_14_i_ival = iobuf_gpio_14_o & dut_io_pads_gpio_14_o_ie;
  wire iobuf_gpio_15_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_15
  (
    .O(iobuf_gpio_15_o),
    .IO(gpio_15),
    .I(dut_io_pads_gpio_15_o_oval),
    .T(~dut_io_pads_gpio_15_o_oe)
  );
  assign dut_io_pads_gpio_15_i_ival = iobuf_gpio_15_o & dut_io_pads_gpio_15_o_ie;
  wire iobuf_gpio_16_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_16
  (
    .O(iobuf_gpio_16_o),
    .IO(gpio_16),
    .I(dut_io_pads_gpio_16_o_oval),
    .T(~dut_io_pads_gpio_16_o_oe)
  );
  assign dut_io_pads_gpio_16_i_ival = sw_3 ? (iobuf_gpio_16_o & dut_io_pads_gpio_16_o_ie) : (uart_txd_in & dut_io_pads_gpio_16_o_ie);
  wire iobuf_gpio_17_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_17
  (
    .O(iobuf_gpio_17_o),
    .IO(gpio_17),
    .I(dut_io_pads_gpio_17_o_oval),
    .T(~dut_io_pads_gpio_17_o_oe)
  );
  assign dut_io_pads_gpio_17_i_ival = iobuf_gpio_17_o & dut_io_pads_gpio_17_o_ie;
  assign uart_rxd_out = (dut_io_pads_gpio_17_o_oval & dut_io_pads_gpio_17_o_oe);
  wire iobuf_gpio_18_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_18
  (
    .O(iobuf_gpio_18_o),
    .IO(gpio_18),
    .I(dut_io_pads_gpio_18_o_oval),
    .T(~dut_io_pads_gpio_18_o_oe)
  );
  assign dut_io_pads_gpio_18_i_ival = iobuf_gpio_18_o & dut_io_pads_gpio_18_o_ie;
  wire iobuf_gpio_19_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_19
  (
    .O(iobuf_gpio_19_o),
    .IO(gpio_19),
    .I(dut_io_pads_gpio_19_o_oval),
    .T(~dut_io_pads_gpio_19_o_oe)
  );
  assign dut_io_pads_gpio_19_i_ival = iobuf_gpio_19_o & dut_io_pads_gpio_19_o_ie;
  wire iobuf_gpio_20_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_20
  (
    .O(iobuf_gpio_20_o),
    .IO(gpio_20),
    .I(dut_io_pads_gpio_20_o_oval),
    .T(~dut_io_pads_gpio_20_o_oe)
  );
  assign dut_io_pads_gpio_20_i_ival = iobuf_gpio_20_o & dut_io_pads_gpio_20_o_ie;
  wire iobuf_gpio_21_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_21
  (
    .O(iobuf_gpio_21_o),
    .IO(gpio_21),
    .I(dut_io_pads_gpio_21_o_oval),
    .T(~dut_io_pads_gpio_21_o_oe)
  );
  assign dut_io_pads_gpio_21_i_ival = iobuf_gpio_21_o & dut_io_pads_gpio_21_o_ie;
  wire iobuf_gpio_22_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_22
  (
    .O(iobuf_gpio_22_o),
    .IO(gpio_22),
    .I(dut_io_pads_gpio_22_o_oval),
    .T(~dut_io_pads_gpio_22_o_oe)
  );
  assign dut_io_pads_gpio_22_i_ival = iobuf_gpio_22_o & dut_io_pads_gpio_22_o_ie;
  wire iobuf_gpio_23_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_23
  (
    .O(iobuf_gpio_23_o),
    .IO(gpio_23),
    .I(dut_io_pads_gpio_23_o_oval),
    .T(~dut_io_pads_gpio_23_o_oe)
  );
  assign dut_io_pads_gpio_23_i_ival = iobuf_gpio_23_o & dut_io_pads_gpio_23_o_ie;
  wire iobuf_gpio_24_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_24
  (
    .O(iobuf_gpio_24_o),
    .IO(gpio_24),
    .I(dut_io_pads_gpio_24_o_oval),
    .T(~dut_io_pads_gpio_24_o_oe)
  );
  assign dut_io_pads_gpio_24_i_ival = iobuf_gpio_24_o & dut_io_pads_gpio_24_o_ie;
  wire iobuf_gpio_25_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_25
  (
    .O(iobuf_gpio_25_o),
    .IO(gpio_25),
    .I(dut_io_pads_gpio_25_o_oval),
    .T(~dut_io_pads_gpio_25_o_oe)
  );
  assign dut_io_pads_gpio_25_i_ival = iobuf_gpio_25_o & dut_io_pads_gpio_25_o_ie;
  wire iobuf_gpio_26_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_26
  (
    .O(iobuf_gpio_26_o),
    .IO(gpio_26),
    .I(dut_io_pads_gpio_26_o_oval),
    .T(~dut_io_pads_gpio_26_o_oe)
  );
  assign dut_io_pads_gpio_26_i_ival = iobuf_gpio_26_o & dut_io_pads_gpio_26_o_ie;
  wire iobuf_gpio_27_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_27
  (
    .O(iobuf_gpio_27_o),
    .IO(gpio_27),
    .I(dut_io_pads_gpio_27_o_oval),
    .T(~dut_io_pads_gpio_27_o_oe)
  );
  assign dut_io_pads_gpio_27_i_ival = iobuf_gpio_27_o & dut_io_pads_gpio_27_o_ie;
  wire iobuf_gpio_28_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_28
  (
    .O(iobuf_gpio_28_o),
    .IO(gpio_28),
    .I(dut_io_pads_gpio_28_o_oval),
    .T(~dut_io_pads_gpio_28_o_oe)
  );
  assign dut_io_pads_gpio_28_i_ival = iobuf_gpio_28_o & dut_io_pads_gpio_28_o_ie;
  wire iobuf_gpio_29_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_29
  (
    .O(iobuf_gpio_29_o),
    .IO(gpio_29),
    .I(dut_io_pads_gpio_29_o_oval),
    .T(~dut_io_pads_gpio_29_o_oe)
  );
  assign dut_io_pads_gpio_29_i_ival = iobuf_gpio_29_o & dut_io_pads_gpio_29_o_ie;
  wire iobuf_gpio_30_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_30
  (
    .O(iobuf_gpio_30_o),
    .IO(gpio_30),
    .I(dut_io_pads_gpio_30_o_oval),
    .T(~dut_io_pads_gpio_30_o_oe)
  );
  assign dut_io_pads_gpio_30_i_ival = iobuf_gpio_30_o & dut_io_pads_gpio_30_o_ie;
  wire iobuf_gpio_31_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_gpio_31
  (
    .O(iobuf_gpio_31_o),
    .IO(gpio_31),
    .I(dut_io_pads_gpio_31_o_oval),
    .T(~dut_io_pads_gpio_31_o_oe)
  );
  assign dut_io_pads_gpio_31_i_ival = iobuf_gpio_31_o & dut_io_pads_gpio_31_o_ie;
  wire iobuf_jtag_TCK_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TCK
  (
    .O(iobuf_jtag_TCK_o),
    .IO(jd_2),
    .I(dut_io_pads_jtag_TCK_o_oval),
    .T(~dut_io_pads_jtag_TCK_o_oe)
  );
  assign dut_io_pads_jtag_TCK_i_ival = iobuf_jtag_TCK_o & dut_io_pads_jtag_TCK_o_ie;
  PULLUP pullup_TCK (.O(jd_2));
  wire iobuf_jtag_TMS_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TMS
  (
    .O(iobuf_jtag_TMS_o),
    .IO(jd_5),
    .I(dut_io_pads_jtag_TMS_o_oval),
    .T(~dut_io_pads_jtag_TMS_o_oe)
  );
  assign dut_io_pads_jtag_TMS_i_ival = iobuf_jtag_TMS_o & dut_io_pads_jtag_TMS_o_ie;
  PULLUP pullup_TMS (.O(jd_5));
  wire iobuf_jtag_TDI_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TDI
  (
    .O(iobuf_jtag_TDI_o),
    .IO(jd_4),
    .I(dut_io_pads_jtag_TDI_o_oval),
    .T(~dut_io_pads_jtag_TDI_o_oe)
  );
  assign dut_io_pads_jtag_TDI_i_ival = iobuf_jtag_TDI_o & dut_io_pads_jtag_TDI_o_ie;
  PULLUP pullup_TDI (.O(jd_4));
  wire iobuf_jtag_TDO_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TDO
  (
    .O(iobuf_jtag_TDO_o),
    .IO(jd_0),
    .I(dut_io_pads_jtag_TDO_o_oval),
    .T(~dut_io_pads_jtag_TDO_o_oe)
  );
  assign dut_io_pads_jtag_TDO_i_ival = iobuf_jtag_TDO_o & dut_io_pads_jtag_TDO_o_ie;
  wire iobuf_jtag_TRST_n_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TRST_n
  (
    .O(iobuf_jtag_TRST_n_o),
    .IO(jd_1),
    .I(dut_io_pads_jtag_TRST_n_o_oval),
    .T(~dut_io_pads_jtag_TRST_n_o_oe)
  );
  assign dut_io_pads_jtag_TRST_n_i_ival = iobuf_jtag_TRST_n_o & dut_io_pads_jtag_TRST_n_o_ie;
  PULLUP pullup_TRST_n(.O(jd_1));
  assign SRST_n = jd_6;
  PULLUP pullup_SRST_n(.O(SRST_n));
  assign ck_io[0] = gpio_16; 
  assign ck_io[1] = gpio_17; 
  assign ck_io[2] = gpio_18;
  assign ck_io[3] = gpio_19; 
  assign ck_io[4] = gpio_20; 
  assign ck_io[5] = gpio_21; 
  assign ck_io[6] = gpio_22; 
  assign ck_io[7] = gpio_23;
  assign ck_io[8] = gpio_0; 
  assign ck_io[9] = gpio_1; 
  assign ck_io[10] = gpio_2; 
  assign ck_io[11] = gpio_3; 
  assign ck_io[12] = gpio_4; 
  assign ck_io[13] = gpio_5; 
  assign ck_io[14] = uart_txd_in; 
  assign ck_io[15] = gpio_9; 
  assign ck_io[16] = gpio_10; 
  assign ck_io[17] = gpio_11; 
  assign ck_io[18] = gpio_12; 
  assign ck_io[19] = gpio_13; 
  assign led0_r = dut_io_pads_gpio_1_o_oval & dut_io_pads_gpio_1_o_oe;
  assign led0_g = dut_io_pads_gpio_2_o_oval & dut_io_pads_gpio_2_o_oe;
  assign led0_b = dut_io_pads_gpio_3_o_oval & dut_io_pads_gpio_2_o_oe;
  assign led1_r = dut_io_pads_gpio_19_o_oval & dut_io_pads_gpio_19_o_oe;
  assign led1_g = dut_io_pads_gpio_21_o_oval & dut_io_pads_gpio_21_o_oe;
  assign led1_b = dut_io_pads_gpio_22_o_oval & dut_io_pads_gpio_22_o_oe;
  assign led2_r = dut_io_pads_gpio_11_o_oval & dut_io_pads_gpio_11_o_oe;
  assign led2_g = dut_io_pads_gpio_12_o_oval & dut_io_pads_gpio_12_o_oe;
  assign led2_b = dut_io_pads_gpio_13_o_oval & dut_io_pads_gpio_13_o_oe;
  assign btn_0 = gpio_15;
  assign btn_1 = gpio_30;
  assign btn_2 = gpio_31;
  assign ja_0 = gpio_25; 
  assign ja_1 = gpio_24; 
  assign ck_ss = gpio_26;
  assign ck_mosi = gpio_27;
  assign ck_miso = gpio_28;
  assign ck_sck = gpio_29;
  assign led_0 = ck_rst;
  assign led_1 = SRST_n;
  assign led_2 = dut_io_pads_aon_pmu_dwakeup_n_i_ival;
  assign led_3 = gpio_14;
  E300ArtyDevKitTop dut
  (
    .clock(hfclk),
    .reset(1'b1),
    .io_pads_jtag_TCK_i_ival(dut_io_pads_jtag_TCK_i_ival),
    .io_pads_jtag_TCK_o_oval(dut_io_pads_jtag_TCK_o_oval),
    .io_pads_jtag_TCK_o_oe(dut_io_pads_jtag_TCK_o_oe),
    .io_pads_jtag_TCK_o_ie(dut_io_pads_jtag_TCK_o_ie),
    .io_pads_jtag_TCK_o_pue(dut_io_pads_jtag_TCK_o_pue),
    .io_pads_jtag_TCK_o_ds(dut_io_pads_jtag_TCK_o_ds),
    .io_pads_jtag_TMS_i_ival(dut_io_pads_jtag_TMS_i_ival),
    .io_pads_jtag_TMS_o_oval(dut_io_pads_jtag_TMS_o_oval),
    .io_pads_jtag_TMS_o_oe(dut_io_pads_jtag_TMS_o_oe),
    .io_pads_jtag_TMS_o_ie(dut_io_pads_jtag_TMS_o_ie),
    .io_pads_jtag_TMS_o_pue(dut_io_pads_jtag_TMS_o_pue),
    .io_pads_jtag_TMS_o_ds(dut_io_pads_jtag_TMS_o_ds),
    .io_pads_jtag_TDI_i_ival(dut_io_pads_jtag_TDI_i_ival),
    .io_pads_jtag_TDI_o_oval(dut_io_pads_jtag_TDI_o_oval),
    .io_pads_jtag_TDI_o_oe(dut_io_pads_jtag_TDI_o_oe),
    .io_pads_jtag_TDI_o_ie(dut_io_pads_jtag_TDI_o_ie),
    .io_pads_jtag_TDI_o_pue(dut_io_pads_jtag_TDI_o_pue),
    .io_pads_jtag_TDI_o_ds(dut_io_pads_jtag_TDI_o_ds),
    .io_pads_jtag_TDO_i_ival(dut_io_pads_jtag_TDO_i_ival),
    .io_pads_jtag_TDO_o_oval(dut_io_pads_jtag_TDO_o_oval),
    .io_pads_jtag_TDO_o_oe(dut_io_pads_jtag_TDO_o_oe),
    .io_pads_jtag_TDO_o_ie(dut_io_pads_jtag_TDO_o_ie),
    .io_pads_jtag_TDO_o_pue(dut_io_pads_jtag_TDO_o_pue),
    .io_pads_jtag_TDO_o_ds(dut_io_pads_jtag_TDO_o_ds),
    .io_pads_jtag_TRST_n_i_ival(dut_io_pads_jtag_TRST_n_i_ival),
    .io_pads_jtag_TRST_n_o_oval(dut_io_pads_jtag_TRST_n_o_oval),
    .io_pads_jtag_TRST_n_o_oe(dut_io_pads_jtag_TRST_n_o_oe),
    .io_pads_jtag_TRST_n_o_ie(dut_io_pads_jtag_TRST_n_o_ie),
    .io_pads_jtag_TRST_n_o_pue(dut_io_pads_jtag_TRST_n_o_pue),
    .io_pads_jtag_TRST_n_o_ds(dut_io_pads_jtag_TRST_n_o_ds),
    .io_pads_gpio_0_i_ival(dut_io_pads_gpio_0_i_ival),
    .io_pads_gpio_0_o_oval(dut_io_pads_gpio_0_o_oval),
    .io_pads_gpio_0_o_oe(dut_io_pads_gpio_0_o_oe),
    .io_pads_gpio_0_o_ie(dut_io_pads_gpio_0_o_ie),
    .io_pads_gpio_0_o_pue(dut_io_pads_gpio_0_o_pue),
    .io_pads_gpio_0_o_ds(dut_io_pads_gpio_0_o_ds),
    .io_pads_gpio_1_i_ival(dut_io_pads_gpio_1_i_ival),
    .io_pads_gpio_1_o_oval(dut_io_pads_gpio_1_o_oval),
    .io_pads_gpio_1_o_oe(dut_io_pads_gpio_1_o_oe),
    .io_pads_gpio_1_o_ie(dut_io_pads_gpio_1_o_ie),
    .io_pads_gpio_1_o_pue(dut_io_pads_gpio_1_o_pue),
    .io_pads_gpio_1_o_ds(dut_io_pads_gpio_1_o_ds),
    .io_pads_gpio_2_i_ival(dut_io_pads_gpio_2_i_ival),
    .io_pads_gpio_2_o_oval(dut_io_pads_gpio_2_o_oval),
    .io_pads_gpio_2_o_oe(dut_io_pads_gpio_2_o_oe),
    .io_pads_gpio_2_o_ie(dut_io_pads_gpio_2_o_ie),
    .io_pads_gpio_2_o_pue(dut_io_pads_gpio_2_o_pue),
    .io_pads_gpio_2_o_ds(dut_io_pads_gpio_2_o_ds),
    .io_pads_gpio_3_i_ival(dut_io_pads_gpio_3_i_ival),
    .io_pads_gpio_3_o_oval(dut_io_pads_gpio_3_o_oval),
    .io_pads_gpio_3_o_oe(dut_io_pads_gpio_3_o_oe),
    .io_pads_gpio_3_o_ie(dut_io_pads_gpio_3_o_ie),
    .io_pads_gpio_3_o_pue(dut_io_pads_gpio_3_o_pue),
    .io_pads_gpio_3_o_ds(dut_io_pads_gpio_3_o_ds),
    .io_pads_gpio_4_i_ival(dut_io_pads_gpio_4_i_ival),
    .io_pads_gpio_4_o_oval(dut_io_pads_gpio_4_o_oval),
    .io_pads_gpio_4_o_oe(dut_io_pads_gpio_4_o_oe),
    .io_pads_gpio_4_o_ie(dut_io_pads_gpio_4_o_ie),
    .io_pads_gpio_4_o_pue(dut_io_pads_gpio_4_o_pue),
    .io_pads_gpio_4_o_ds(dut_io_pads_gpio_4_o_ds),
    .io_pads_gpio_5_i_ival(dut_io_pads_gpio_5_i_ival),
    .io_pads_gpio_5_o_oval(dut_io_pads_gpio_5_o_oval),
    .io_pads_gpio_5_o_oe(dut_io_pads_gpio_5_o_oe),
    .io_pads_gpio_5_o_ie(dut_io_pads_gpio_5_o_ie),
    .io_pads_gpio_5_o_pue(dut_io_pads_gpio_5_o_pue),
    .io_pads_gpio_5_o_ds(dut_io_pads_gpio_5_o_ds),
    .io_pads_gpio_6_i_ival(dut_io_pads_gpio_6_i_ival),
    .io_pads_gpio_6_o_oval(dut_io_pads_gpio_6_o_oval),
    .io_pads_gpio_6_o_oe(dut_io_pads_gpio_6_o_oe),
    .io_pads_gpio_6_o_ie(dut_io_pads_gpio_6_o_ie),
    .io_pads_gpio_6_o_pue(dut_io_pads_gpio_6_o_pue),
    .io_pads_gpio_6_o_ds(dut_io_pads_gpio_6_o_ds),
    .io_pads_gpio_7_i_ival(dut_io_pads_gpio_7_i_ival),
    .io_pads_gpio_7_o_oval(dut_io_pads_gpio_7_o_oval),
    .io_pads_gpio_7_o_oe(dut_io_pads_gpio_7_o_oe),
    .io_pads_gpio_7_o_ie(dut_io_pads_gpio_7_o_ie),
    .io_pads_gpio_7_o_pue(dut_io_pads_gpio_7_o_pue),
    .io_pads_gpio_7_o_ds(dut_io_pads_gpio_7_o_ds),
    .io_pads_gpio_8_i_ival(dut_io_pads_gpio_8_i_ival),
    .io_pads_gpio_8_o_oval(dut_io_pads_gpio_8_o_oval),
    .io_pads_gpio_8_o_oe(dut_io_pads_gpio_8_o_oe),
    .io_pads_gpio_8_o_ie(dut_io_pads_gpio_8_o_ie),
    .io_pads_gpio_8_o_pue(dut_io_pads_gpio_8_o_pue),
    .io_pads_gpio_8_o_ds(dut_io_pads_gpio_8_o_ds),
    .io_pads_gpio_9_i_ival(dut_io_pads_gpio_9_i_ival),
    .io_pads_gpio_9_o_oval(dut_io_pads_gpio_9_o_oval),
    .io_pads_gpio_9_o_oe(dut_io_pads_gpio_9_o_oe),
    .io_pads_gpio_9_o_ie(dut_io_pads_gpio_9_o_ie),
    .io_pads_gpio_9_o_pue(dut_io_pads_gpio_9_o_pue),
    .io_pads_gpio_9_o_ds(dut_io_pads_gpio_9_o_ds),
    .io_pads_gpio_10_i_ival(dut_io_pads_gpio_10_i_ival),
    .io_pads_gpio_10_o_oval(dut_io_pads_gpio_10_o_oval),
    .io_pads_gpio_10_o_oe(dut_io_pads_gpio_10_o_oe),
    .io_pads_gpio_10_o_ie(dut_io_pads_gpio_10_o_ie),
    .io_pads_gpio_10_o_pue(dut_io_pads_gpio_10_o_pue),
    .io_pads_gpio_10_o_ds(dut_io_pads_gpio_10_o_ds),
    .io_pads_gpio_11_i_ival(dut_io_pads_gpio_11_i_ival),
    .io_pads_gpio_11_o_oval(dut_io_pads_gpio_11_o_oval),
    .io_pads_gpio_11_o_oe(dut_io_pads_gpio_11_o_oe),
    .io_pads_gpio_11_o_ie(dut_io_pads_gpio_11_o_ie),
    .io_pads_gpio_11_o_pue(dut_io_pads_gpio_11_o_pue),
    .io_pads_gpio_11_o_ds(dut_io_pads_gpio_11_o_ds),
    .io_pads_gpio_12_i_ival(dut_io_pads_gpio_12_i_ival),
    .io_pads_gpio_12_o_oval(dut_io_pads_gpio_12_o_oval),
    .io_pads_gpio_12_o_oe(dut_io_pads_gpio_12_o_oe),
    .io_pads_gpio_12_o_ie(dut_io_pads_gpio_12_o_ie),
    .io_pads_gpio_12_o_pue(dut_io_pads_gpio_12_o_pue),
    .io_pads_gpio_12_o_ds(dut_io_pads_gpio_12_o_ds),
    .io_pads_gpio_13_i_ival(dut_io_pads_gpio_13_i_ival),
    .io_pads_gpio_13_o_oval(dut_io_pads_gpio_13_o_oval),
    .io_pads_gpio_13_o_oe(dut_io_pads_gpio_13_o_oe),
    .io_pads_gpio_13_o_ie(dut_io_pads_gpio_13_o_ie),
    .io_pads_gpio_13_o_pue(dut_io_pads_gpio_13_o_pue),
    .io_pads_gpio_13_o_ds(dut_io_pads_gpio_13_o_ds),
    .io_pads_gpio_14_i_ival(dut_io_pads_gpio_14_i_ival),
    .io_pads_gpio_14_o_oval(dut_io_pads_gpio_14_o_oval),
    .io_pads_gpio_14_o_oe(dut_io_pads_gpio_14_o_oe),
    .io_pads_gpio_14_o_ie(dut_io_pads_gpio_14_o_ie),
    .io_pads_gpio_14_o_pue(dut_io_pads_gpio_14_o_pue),
    .io_pads_gpio_14_o_ds(dut_io_pads_gpio_14_o_ds),
    .io_pads_gpio_15_i_ival(dut_io_pads_gpio_15_i_ival),
    .io_pads_gpio_15_o_oval(dut_io_pads_gpio_15_o_oval),
    .io_pads_gpio_15_o_oe(dut_io_pads_gpio_15_o_oe),
    .io_pads_gpio_15_o_ie(dut_io_pads_gpio_15_o_ie),
    .io_pads_gpio_15_o_pue(dut_io_pads_gpio_15_o_pue),
    .io_pads_gpio_15_o_ds(dut_io_pads_gpio_15_o_ds),
    .io_pads_gpio_16_i_ival(dut_io_pads_gpio_16_i_ival),
    .io_pads_gpio_16_o_oval(dut_io_pads_gpio_16_o_oval),
    .io_pads_gpio_16_o_oe(dut_io_pads_gpio_16_o_oe),
    .io_pads_gpio_16_o_ie(dut_io_pads_gpio_16_o_ie),
    .io_pads_gpio_16_o_pue(dut_io_pads_gpio_16_o_pue),
    .io_pads_gpio_16_o_ds(dut_io_pads_gpio_16_o_ds),
    .io_pads_gpio_17_i_ival(dut_io_pads_gpio_17_i_ival),
    .io_pads_gpio_17_o_oval(dut_io_pads_gpio_17_o_oval),
    .io_pads_gpio_17_o_oe(dut_io_pads_gpio_17_o_oe),
    .io_pads_gpio_17_o_ie(dut_io_pads_gpio_17_o_ie),
    .io_pads_gpio_17_o_pue(dut_io_pads_gpio_17_o_pue),
    .io_pads_gpio_17_o_ds(dut_io_pads_gpio_17_o_ds),
    .io_pads_gpio_18_i_ival(dut_io_pads_gpio_18_i_ival),
    .io_pads_gpio_18_o_oval(dut_io_pads_gpio_18_o_oval),
    .io_pads_gpio_18_o_oe(dut_io_pads_gpio_18_o_oe),
    .io_pads_gpio_18_o_ie(dut_io_pads_gpio_18_o_ie),
    .io_pads_gpio_18_o_pue(dut_io_pads_gpio_18_o_pue),
    .io_pads_gpio_18_o_ds(dut_io_pads_gpio_18_o_ds),
    .io_pads_gpio_19_i_ival(dut_io_pads_gpio_19_i_ival),
    .io_pads_gpio_19_o_oval(dut_io_pads_gpio_19_o_oval),
    .io_pads_gpio_19_o_oe(dut_io_pads_gpio_19_o_oe),
    .io_pads_gpio_19_o_ie(dut_io_pads_gpio_19_o_ie),
    .io_pads_gpio_19_o_pue(dut_io_pads_gpio_19_o_pue),
    .io_pads_gpio_19_o_ds(dut_io_pads_gpio_19_o_ds),
    .io_pads_gpio_20_i_ival(dut_io_pads_gpio_20_i_ival),
    .io_pads_gpio_20_o_oval(dut_io_pads_gpio_20_o_oval),
    .io_pads_gpio_20_o_oe(dut_io_pads_gpio_20_o_oe),
    .io_pads_gpio_20_o_ie(dut_io_pads_gpio_20_o_ie),
    .io_pads_gpio_20_o_pue(dut_io_pads_gpio_20_o_pue),
    .io_pads_gpio_20_o_ds(dut_io_pads_gpio_20_o_ds),
    .io_pads_gpio_21_i_ival(dut_io_pads_gpio_21_i_ival),
    .io_pads_gpio_21_o_oval(dut_io_pads_gpio_21_o_oval),
    .io_pads_gpio_21_o_oe(dut_io_pads_gpio_21_o_oe),
    .io_pads_gpio_21_o_ie(dut_io_pads_gpio_21_o_ie),
    .io_pads_gpio_21_o_pue(dut_io_pads_gpio_21_o_pue),
    .io_pads_gpio_21_o_ds(dut_io_pads_gpio_21_o_ds),
    .io_pads_gpio_22_i_ival(dut_io_pads_gpio_22_i_ival),
    .io_pads_gpio_22_o_oval(dut_io_pads_gpio_22_o_oval),
    .io_pads_gpio_22_o_oe(dut_io_pads_gpio_22_o_oe),
    .io_pads_gpio_22_o_ie(dut_io_pads_gpio_22_o_ie),
    .io_pads_gpio_22_o_pue(dut_io_pads_gpio_22_o_pue),
    .io_pads_gpio_22_o_ds(dut_io_pads_gpio_22_o_ds),
    .io_pads_gpio_23_i_ival(dut_io_pads_gpio_23_i_ival),
    .io_pads_gpio_23_o_oval(dut_io_pads_gpio_23_o_oval),
    .io_pads_gpio_23_o_oe(dut_io_pads_gpio_23_o_oe),
    .io_pads_gpio_23_o_ie(dut_io_pads_gpio_23_o_ie),
    .io_pads_gpio_23_o_pue(dut_io_pads_gpio_23_o_pue),
    .io_pads_gpio_23_o_ds(dut_io_pads_gpio_23_o_ds),
    .io_pads_gpio_24_i_ival(dut_io_pads_gpio_24_i_ival),
    .io_pads_gpio_24_o_oval(dut_io_pads_gpio_24_o_oval),
    .io_pads_gpio_24_o_oe(dut_io_pads_gpio_24_o_oe),
    .io_pads_gpio_24_o_ie(dut_io_pads_gpio_24_o_ie),
    .io_pads_gpio_24_o_pue(dut_io_pads_gpio_24_o_pue),
    .io_pads_gpio_24_o_ds(dut_io_pads_gpio_24_o_ds),
    .io_pads_gpio_25_i_ival(dut_io_pads_gpio_25_i_ival),
    .io_pads_gpio_25_o_oval(dut_io_pads_gpio_25_o_oval),
    .io_pads_gpio_25_o_oe(dut_io_pads_gpio_25_o_oe),
    .io_pads_gpio_25_o_ie(dut_io_pads_gpio_25_o_ie),
    .io_pads_gpio_25_o_pue(dut_io_pads_gpio_25_o_pue),
    .io_pads_gpio_25_o_ds(dut_io_pads_gpio_25_o_ds),
    .io_pads_gpio_26_i_ival(dut_io_pads_gpio_26_i_ival),
    .io_pads_gpio_26_o_oval(dut_io_pads_gpio_26_o_oval),
    .io_pads_gpio_26_o_oe(dut_io_pads_gpio_26_o_oe),
    .io_pads_gpio_26_o_ie(dut_io_pads_gpio_26_o_ie),
    .io_pads_gpio_26_o_pue(dut_io_pads_gpio_26_o_pue),
    .io_pads_gpio_26_o_ds(dut_io_pads_gpio_26_o_ds),
    .io_pads_gpio_27_i_ival(dut_io_pads_gpio_27_i_ival),
    .io_pads_gpio_27_o_oval(dut_io_pads_gpio_27_o_oval),
    .io_pads_gpio_27_o_oe(dut_io_pads_gpio_27_o_oe),
    .io_pads_gpio_27_o_ie(dut_io_pads_gpio_27_o_ie),
    .io_pads_gpio_27_o_pue(dut_io_pads_gpio_27_o_pue),
    .io_pads_gpio_27_o_ds(dut_io_pads_gpio_27_o_ds),
    .io_pads_gpio_28_i_ival(dut_io_pads_gpio_28_i_ival),
    .io_pads_gpio_28_o_oval(dut_io_pads_gpio_28_o_oval),
    .io_pads_gpio_28_o_oe(dut_io_pads_gpio_28_o_oe),
    .io_pads_gpio_28_o_ie(dut_io_pads_gpio_28_o_ie),
    .io_pads_gpio_28_o_pue(dut_io_pads_gpio_28_o_pue),
    .io_pads_gpio_28_o_ds(dut_io_pads_gpio_28_o_ds),
    .io_pads_gpio_29_i_ival(dut_io_pads_gpio_29_i_ival),
    .io_pads_gpio_29_o_oval(dut_io_pads_gpio_29_o_oval),
    .io_pads_gpio_29_o_oe(dut_io_pads_gpio_29_o_oe),
    .io_pads_gpio_29_o_ie(dut_io_pads_gpio_29_o_ie),
    .io_pads_gpio_29_o_pue(dut_io_pads_gpio_29_o_pue),
    .io_pads_gpio_29_o_ds(dut_io_pads_gpio_29_o_ds),
    .io_pads_gpio_30_i_ival(dut_io_pads_gpio_30_i_ival),
    .io_pads_gpio_30_o_oval(dut_io_pads_gpio_30_o_oval),
    .io_pads_gpio_30_o_oe(dut_io_pads_gpio_30_o_oe),
    .io_pads_gpio_30_o_ie(dut_io_pads_gpio_30_o_ie),
    .io_pads_gpio_30_o_pue(dut_io_pads_gpio_30_o_pue),
    .io_pads_gpio_30_o_ds(dut_io_pads_gpio_30_o_ds),
    .io_pads_gpio_31_i_ival(dut_io_pads_gpio_31_i_ival),
    .io_pads_gpio_31_o_oval(dut_io_pads_gpio_31_o_oval),
    .io_pads_gpio_31_o_oe(dut_io_pads_gpio_31_o_oe),
    .io_pads_gpio_31_o_ie(dut_io_pads_gpio_31_o_ie),
    .io_pads_gpio_31_o_pue(dut_io_pads_gpio_31_o_pue),
    .io_pads_gpio_31_o_ds(dut_io_pads_gpio_31_o_ds),
    .io_pads_qspi_sck_i_ival(dut_io_pads_qspi_sck_i_ival),
    .io_pads_qspi_sck_o_oval(dut_io_pads_qspi_sck_o_oval),
    .io_pads_qspi_sck_o_oe(dut_io_pads_qspi_sck_o_oe),
    .io_pads_qspi_sck_o_ie(dut_io_pads_qspi_sck_o_ie),
    .io_pads_qspi_sck_o_pue(dut_io_pads_qspi_sck_o_pue),
    .io_pads_qspi_sck_o_ds(dut_io_pads_qspi_sck_o_ds),
    .io_pads_qspi_dq_0_i_ival(dut_io_pads_qspi_dq_0_i_ival),
    .io_pads_qspi_dq_0_o_oval(dut_io_pads_qspi_dq_0_o_oval),
    .io_pads_qspi_dq_0_o_oe(dut_io_pads_qspi_dq_0_o_oe),
    .io_pads_qspi_dq_0_o_ie(dut_io_pads_qspi_dq_0_o_ie),
    .io_pads_qspi_dq_0_o_pue(dut_io_pads_qspi_dq_0_o_pue),
    .io_pads_qspi_dq_0_o_ds(dut_io_pads_qspi_dq_0_o_ds),
    .io_pads_qspi_dq_1_i_ival(dut_io_pads_qspi_dq_1_i_ival),
    .io_pads_qspi_dq_1_o_oval(dut_io_pads_qspi_dq_1_o_oval),
    .io_pads_qspi_dq_1_o_oe(dut_io_pads_qspi_dq_1_o_oe),
    .io_pads_qspi_dq_1_o_ie(dut_io_pads_qspi_dq_1_o_ie),
    .io_pads_qspi_dq_1_o_pue(dut_io_pads_qspi_dq_1_o_pue),
    .io_pads_qspi_dq_1_o_ds(dut_io_pads_qspi_dq_1_o_ds),
    .io_pads_qspi_dq_2_i_ival(dut_io_pads_qspi_dq_2_i_ival),
    .io_pads_qspi_dq_2_o_oval(dut_io_pads_qspi_dq_2_o_oval),
    .io_pads_qspi_dq_2_o_oe(dut_io_pads_qspi_dq_2_o_oe),
    .io_pads_qspi_dq_2_o_ie(dut_io_pads_qspi_dq_2_o_ie),
    .io_pads_qspi_dq_2_o_pue(dut_io_pads_qspi_dq_2_o_pue),
    .io_pads_qspi_dq_2_o_ds(dut_io_pads_qspi_dq_2_o_ds),
    .io_pads_qspi_dq_3_i_ival(dut_io_pads_qspi_dq_3_i_ival),
    .io_pads_qspi_dq_3_o_oval(dut_io_pads_qspi_dq_3_o_oval),
    .io_pads_qspi_dq_3_o_oe(dut_io_pads_qspi_dq_3_o_oe),
    .io_pads_qspi_dq_3_o_ie(dut_io_pads_qspi_dq_3_o_ie),
    .io_pads_qspi_dq_3_o_pue(dut_io_pads_qspi_dq_3_o_pue),
    .io_pads_qspi_dq_3_o_ds(dut_io_pads_qspi_dq_3_o_ds),
    .io_pads_qspi_cs_0_i_ival(dut_io_pads_qspi_cs_0_i_ival),
    .io_pads_qspi_cs_0_o_oval(dut_io_pads_qspi_cs_0_o_oval),
    .io_pads_qspi_cs_0_o_oe(dut_io_pads_qspi_cs_0_o_oe),
    .io_pads_qspi_cs_0_o_ie(dut_io_pads_qspi_cs_0_o_ie),
    .io_pads_qspi_cs_0_o_pue(dut_io_pads_qspi_cs_0_o_pue),
    .io_pads_qspi_cs_0_o_ds(dut_io_pads_qspi_cs_0_o_ds),
    .io_pads_aon_erst_n_i_ival(dut_io_pads_aon_erst_n_i_ival),
    .io_pads_aon_erst_n_o_oval(dut_io_pads_aon_erst_n_o_oval),
    .io_pads_aon_erst_n_o_oe(dut_io_pads_aon_erst_n_o_oe),
    .io_pads_aon_erst_n_o_ie(dut_io_pads_aon_erst_n_o_ie),
    .io_pads_aon_erst_n_o_pue(dut_io_pads_aon_erst_n_o_pue),
    .io_pads_aon_erst_n_o_ds(dut_io_pads_aon_erst_n_o_ds),
    .io_pads_aon_lfextclk_i_ival(dut_io_pads_aon_lfextclk_i_ival),
    .io_pads_aon_lfextclk_o_oval(dut_io_pads_aon_lfextclk_o_oval),
    .io_pads_aon_lfextclk_o_oe(dut_io_pads_aon_lfextclk_o_oe),
    .io_pads_aon_lfextclk_o_ie(dut_io_pads_aon_lfextclk_o_ie),
    .io_pads_aon_lfextclk_o_pue(dut_io_pads_aon_lfextclk_o_pue),
    .io_pads_aon_lfextclk_o_ds(dut_io_pads_aon_lfextclk_o_ds),
    .io_pads_aon_pmu_dwakeup_n_i_ival(dut_io_pads_aon_pmu_dwakeup_n_i_ival),
    .io_pads_aon_pmu_dwakeup_n_o_oval(dut_io_pads_aon_pmu_dwakeup_n_o_oval),
    .io_pads_aon_pmu_dwakeup_n_o_oe(dut_io_pads_aon_pmu_dwakeup_n_o_oe),
    .io_pads_aon_pmu_dwakeup_n_o_ie(dut_io_pads_aon_pmu_dwakeup_n_o_ie),
    .io_pads_aon_pmu_dwakeup_n_o_pue(dut_io_pads_aon_pmu_dwakeup_n_o_pue),
    .io_pads_aon_pmu_dwakeup_n_o_ds(dut_io_pads_aon_pmu_dwakeup_n_o_ds),
    .io_pads_aon_pmu_vddpaden_i_ival(dut_io_pads_aon_pmu_vddpaden_i_ival),
    .io_pads_aon_pmu_vddpaden_o_oval(dut_io_pads_aon_pmu_vddpaden_o_oval),
    .io_pads_aon_pmu_vddpaden_o_oe(dut_io_pads_aon_pmu_vddpaden_o_oe),
    .io_pads_aon_pmu_vddpaden_o_ie(dut_io_pads_aon_pmu_vddpaden_o_ie),
    .io_pads_aon_pmu_vddpaden_o_pue(dut_io_pads_aon_pmu_vddpaden_o_pue),
    .io_pads_aon_pmu_vddpaden_o_ds(dut_io_pads_aon_pmu_vddpaden_o_ds)
  );
  wire iobuf_dwakeup_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_dwakeup_n
  (
    .O(iobuf_dwakeup_o),
    .IO(btn_3),
    .I(~dut_io_pads_aon_pmu_dwakeup_n_o_oval),
    .T(~dut_io_pads_aon_pmu_dwakeup_n_o_oe)
  );
  assign dut_io_pads_aon_pmu_dwakeup_n_i_ival = (~iobuf_dwakeup_o) & dut_io_pads_aon_pmu_dwakeup_n_o_ie;
  assign dut_io_pads_aon_erst_n_i_ival = ~reset_periph;
  assign dut_io_pads_aon_lfextclk_i_ival = slowclk;
  assign dut_io_pads_aon_pmu_vddpaden_i_ival = 1'b1;
  assign qspi_cs = dut_io_pads_qspi_cs_0_o_oval;
  assign qspi_ui_dq_o = {
    dut_io_pads_qspi_dq_3_o_oval,
    dut_io_pads_qspi_dq_2_o_oval,
    dut_io_pads_qspi_dq_1_o_oval,
    dut_io_pads_qspi_dq_0_o_oval
  };
  assign qspi_ui_dq_oe = {
    dut_io_pads_qspi_dq_3_o_oe,
    dut_io_pads_qspi_dq_2_o_oe,
    dut_io_pads_qspi_dq_1_o_oe,
    dut_io_pads_qspi_dq_0_o_oe
  };
  assign dut_io_pads_qspi_dq_0_i_ival = qspi_ui_dq_i[0];
  assign dut_io_pads_qspi_dq_1_i_ival = qspi_ui_dq_i[1];
  assign dut_io_pads_qspi_dq_2_i_ival = qspi_ui_dq_i[2];
  assign dut_io_pads_qspi_dq_3_i_ival = qspi_ui_dq_i[3];
  assign qspi_sck = dut_io_pads_qspi_sck_o_oval;
endmodule
module clkdivider
(
  input wire clk,
  input wire reset,
  output reg clk_out
);
  reg [7:0] counter;
  always @(posedge clk)
  begin
    if (reset)
    begin
      counter <= 8'd0;
      clk_out <= 1'b0;
    end
    else if (counter == 8'hff)
    begin
      counter <= 8'd0;
      clk_out <= ~clk_out;
    end
    else
    begin
      counter <= counter+1;
    end
  end
endmodule
