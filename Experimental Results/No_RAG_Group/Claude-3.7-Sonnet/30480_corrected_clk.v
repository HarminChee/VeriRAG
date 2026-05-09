Here's the modified Verilog code:


`timescale 1ns/100ps
module system_top (
  sys_rst,
  sys_clk_p,
  sys_clk_n,
  uart_sin,
  uart_sout,
  ddr3_addr,
  ddr3_ba,
  ddr3_cas_n,
  ddr3_ck_n,
  ddr3_ck_p,
  ddr3_cke,
  ddr3_cs_n,
  ddr3_dm,
  ddr3_dq,
  ddr3_dqs_n,
  ddr3_dqs_p,
  ddr3_odt,
  ddr3_ras_n,
  ddr3_reset_n,
  ddr3_we_n,
  sgmii_rxp,
  sgmii_rxn,
  sgmii_txp,
  sgmii_txn,
  phy_rstn,
  mgt_clk_p,
  mgt_clk_n,
  mdio_mdc,
  mdio_mdio,
  fan_pwm,
  linear_flash_addr,
  linear_flash_adv_ldn,
  linear_flash_ce_n,
  linear_flash_oen,
  linear_flash_wen,
  linear_flash_dq_io,
  gpio_lcd,
  gpio_bd,
  iic_rstn,
  iic_scl,
  iic_sda,
  rx_ref_clk_0_p,
  rx_ref_clk_0_n,
  rx_data_0_p,
  rx_data_0_n,
  rx_ref_clk_1_p,
  rx_ref_clk_1_n,
  rx_data_1_p,
  rx_data_1_n,
  rx_sysref_p,
  rx_sysref_n,
  rx_sync_0_p,
  rx_sync_0_n,
  rx_sync_1_p,
  rx_sync_1_n,
  spi_csn_0,
  spi_csn_1,
  spi_clk,
  spi_sdio,
  spi_dirn,
  trig_p,
  trig_n,
  vdither_p,
  vdither_n,
  pwr_good,
  dac_clk,
  dac_data,
  dac_sync_0,
  dac_sync_1,
  fd_1,
  irq_1,
  fd_0,
  irq_0,
  pwdn_1,
  rst_1,
  drst_1,
  arst_1,
  pwdn_0,
  rst_0,
  drst_0,
  arst_0);

  // ... existing code ...

  wire              adc_clk;
  wire              adc_valid_0;
  wire              adc_enable_0;
  wire    [255:0]   adc_data_0;
  wire              adc_valid_1;
  wire              adc_enable_1;
  wire    [255:0]   adc_data_1;

  reg               adc_wr;
  reg     [511:0]   adc_wdata;

  always @(posedge sys_clk_p) begin
    adc_wr <= adc_enable_0 & adc_enable_1;
    adc_wdata[((16*31)+15):(16*31)] <= adc_data_1[((16*15)+15):(16*15)];
    adc_wdata[((16*30)+15):(16*30)] <= adc_data_0[((16*15)+15):(16*15)];
    // ... existing code ...
    adc_wdata[((16* 1)+15):(16* 1)] <= adc_data_1[((16* 0)+15):(16* 0)];
    adc_wdata[((16* 0)+15):(16* 0)] <= adc_data_0[((16* 0)+15):(16* 0)];
  end

  // ... existing code ...

  system_wrapper i_system_wrapper (
    .adc_clk (sys_clk_p),
    .adc_data_0 (adc_data_0),
    .adc_data_1 (adc_data_1),
    .adc_enable_0 (adc_enable_0),
    .adc_enable_1 (adc_enable_1),
    .adc_valid_0 (adc_valid_0),
    .adc_valid_1 (adc_valid_1),
    .adc_wdata (adc_wdata),
    .adc_wr (adc_wr),
    // ... existing code ...
    .uart_sin (uart_sin),
    .uart_sout (uart_sout));

endmodule