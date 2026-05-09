`timescale 1ns/100ps
module system_top (
  sys_rst,
  sys_clk_p,
  sys_clk_n,
  scan_mode, // Added for DFT
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
  input             sys_rst;
  input             sys_clk_p;
  input             sys_clk_n;
  input             scan_mode; // Added for DFT
  input             uart_sin;
  output            uart_sout;
  output  [ 13:0]   ddr3_addr;
  output  [  2:0]   ddr3_ba;
  output            ddr3_cas_n;
  output  [  0:0]   ddr3_ck_n;
  output  [  0:0]   ddr3_ck_p;
  output  [  0:0]   ddr3_cke;
  output  [  0:0]   ddr3_cs_n;
  output  [  7:0]   ddr3_dm;
  inout   [ 63:0]   ddr3_dq;
  inout   [  7:0]   ddr3_dqs_n;
  inout   [  7:0]   ddr3_dqs_p;
  output  [  0:0]   ddr3_odt;
  output            ddr3_ras_n;
  output            ddr3_reset_n;
  output            ddr3_we_n;
  input             sgmii_rxp;
  input             sgmii_rxn;
  output            sgmii_txp;
  output            sgmii_txn;
  output            phy_rstn;
  input             mgt_clk_p;
  input             mgt_clk_n;
  output            mdio_mdc;
  inout             mdio_mdio;
  output            fan_pwm;
  output  [26:1]    linear_flash_addr;
  output            linear_flash_adv_ldn;
  output            linear_flash_ce_n;
  output            linear_flash_oen;
  output            linear_flash_wen;
  inout   [15:0]    linear_flash_dq_io;
  inout   [  6:0]   gpio_lcd;
  inout   [ 20:0]   gpio_bd;
  output            iic_rstn;
  inout             iic_scl;
  inout             iic_sda;
  input             rx_ref_clk_0_p;
  input             rx_ref_clk_0_n;
  input   [  7:0]   rx_data_0_p;
  input   [  7:0]   rx_data_0_n;
  input             rx_ref_clk_1_p;
  input             rx_ref_clk_1_n;
  input   [  7:0]   rx_data_1_p;
  input   [  7:0]   rx_data_1_n;
  output            rx_sysref_p;
  output            rx_sysref_n;
  output            rx_sync_0_p;
  output            rx_sync_0_n;
  output            rx_sync_1_p;
  output            rx_sync_1_n;
  output            spi_csn_0;
  output            spi_csn_1;
  output            spi_clk;
  inout             spi_sdio;
  output            spi_dirn;
  output            dac_clk;
  output            dac_data;
  output            dac_sync_0;
  output            dac_sync_1;
  input             trig_p;
  input             trig_n;
  output            vdither_p;
  output            vdither_n;
  inout             pwr_good;
  inout             fd_1;
  inout             irq_1;
  inout             fd_0;
  inout             irq_0;
  inout             pwdn_1;
  inout             rst_1;
  inout             drst_1;
  inout             arst_1;
  inout             pwdn_0;
  inout             rst_0;
  inout             drst_0;
  inout             arst_0;

  // Clock generation/buffering from primary inputs
  wire              sys_clk_in;
  wire              sys_clk; // Main system clock derived from primary inputs
  IBUFDS sys_clk_ibuf (.I(sys_clk_p), .IB(sys_clk_n), .O(sys_clk_in));
  BUFG sys_clk_bufg (.I(sys_clk_in), .O(sys_clk));

  // Wires and Regs
  reg               adc_wr = 'd0;
  reg     [511:0]   adc_wdata = 'd0;
  wire    [ 63:0]   gpio_i;
  wire    [ 63:0]   gpio_o;
  wire    [ 63:0]   gpio_t;
  wire    [  7:0]   spi_csn;
  wire              spi_clk_int; // Renamed internal SPI clock wire
  wire              spi_mosi;
  wire              spi_miso;
  wire              rx_ref_clk_0;
  wire              rx_ref_clk_1;
  wire              rx_sysref;
  wire              rx_sync_0;
  wire              rx_sync_1;
  wire              adc_clk; // Internally generated clock from system_wrapper
  wire              adc_valid_0;
  wire              adc_enable_0;
  wire    [255:0]   adc_data_0;
  wire              adc_valid_1;
  wire              adc_enable_1;
  wire    [255:0]   adc_data_1;

  // DFT Clock MUX for adc_wr and adc_wdata registers
  wire              clk_for_adc_regs;
  assign clk_for_adc_regs = scan_mode ? sys_clk : adc_clk; // MUX selects sys_clk in scan_mode

  // Registers clocked by potentially internally generated adc_clk
  // Modified to use clk_for_adc_regs and include asynchronous reset
  always @(posedge clk_for_adc_regs or posedge sys_rst) begin
    if (sys_rst) begin // Use asynchronous reset sys_rst (active high)
       adc_wr <= 1'b0;
       adc_wdata <= 512'b0;
    end else begin
      adc_wr <= adc_enable_0 & adc_enable_1;
      // Assignments remain the same, but clocked by clk_for_adc_regs
      adc_wdata[((16*31)+15):(16*31)] <= adc_data_1[((16*15)+15):(16*15)];
      adc_wdata[((16*30)+15):(16*30)] <= adc_data_0[((16*15)+15):(16*15)];
      adc_wdata[((16*29)+15):(16*29)] <= adc_data_1[((16*14)+15):(16*14)];
      adc_wdata[((16*28)+15):(16*28)] <= adc_data_0[((16*14)+15):(16*14)];
      adc_wdata[((16*27)+15):(16*27)] <= adc_data_1[((16*13)+15):(16*13)];
      adc_wdata[((16*26)+15):(16*26)] <= adc_data_0[((16*13)+15):(16*13)];
      adc_wdata[((16*25)+15):(16*25)] <= adc_data_1[((16*12)+15):(16*12)];
      adc_wdata[((16*24)+15):(16*24)] <= adc_data_0[((16*12)+15):(16*12)];
      adc_wdata[((16*23)+15):(16*23)] <= adc_data_1[((16*11)+15):(16*11)];
      adc_wdata[((16*22)+15):(16*22)] <= adc_data_0[((16*11)+15):(16*11)];
      adc_wdata[((16*21)+15):(16*21)] <= adc_data_1[((16*10)+15):(16*10)];
      adc_wdata[((16*20)+15):(16*20)] <= adc_data_0[((16*10)+15):(16*10)];
      adc_wdata[((16*19)+15):(16*19)] <= adc_data_1[((16* 9)+15):(16* 9)];
      adc_wdata[((16*18)+15):(16*18)] <= adc_data_0[((16* 9)+15):(16* 9)];
      adc_wdata[((16*17)+15):(16*17)] <= adc_data_1[((16* 8)+15):(16* 8)];
      adc_wdata[((16*16)+15):(16*16)] <= adc_data_0[((16* 8)+15):(16* 8)];
      adc_wdata[((16*15)+15):(16*15)] <= adc_data_1[((16* 7)+15):(16* 7)];
      adc_wdata[((16*14)+15):(16*14)] <= adc_data_0[((16* 7)+15):(16* 7)];
      adc_wdata[((16*13)+15):(16*13)] <= adc_data_1[((16* 6)+15):(16* 6)];
      adc_wdata[((16*12)+15):(16*12)] <= adc_data_0[((16* 6)+15):(16* 6)];
      adc_wdata[((16*11)+15):(16*11)] <= adc_data_1[((16* 5)+15):(16* 5)];
      adc_wdata[((16*10)+15):(16*10)] <= adc_data_0[((16* 5)+15):(16* 5)];
      adc_wdata[((16* 9)+15):(16* 9)] <= adc_data_1[((16* 4)+15):(16* 4)];
      adc_wdata[((16* 8)+15):(16* 8)] <= adc_data_0[((16* 4)+15):(16* 4)];
      adc_wdata[((16* 7)+15):(16* 7)] <= adc_data_1[((16* 3)+15):(16* 3)];
      adc_wdata[((16* 6)+15):(16* 6)] <= adc_data_0[((16* 3)+15):(16* 3)];
      adc_wdata[((16* 5)+15):(16* 5)] <= adc_data_1[((16* 2)+15):(16* 2)];
      adc_wdata[((16* 4)+15):(16* 4)] <= adc_data_0[((16* 2)+15):(16* 2)];
      adc_wdata[((16* 3)+15):(16* 3)] <= adc_data_1[((16* 1)+15):(16* 1)];
      adc_wdata[((16* 2)+15):(16* 2)] <= adc_data_0[((16* 1)+15):(16* 1)];
      adc_wdata[((16* 1)+15):(16* 1)] <= adc_data_1[((16* 0)+15):(16* 0)];
      adc_wdata[((16* 0)+15):(16* 0)] <= adc_data_0[((16* 0)+15):(16* 0)];
    end
  end

  // Assignments
  assign iic_rstn = 1'b1;
  assign fan_pwm = 1'b1;
  assign dac_clk = spi_clk; // Assign top-level spi_clk output
  assign dac_data = spi_mosi;
  assign dac_sync_1 = spi_csn[3];
  assign dac_sync_0 = spi_csn[2];
  assign spi_csn_1 = spi_csn[1]; // Assign top-level spi_csn_1 output
  assign spi_csn_0 = spi_csn[0]; // Assign top-level spi_csn_0 output
  assign spi_clk = spi_clk_int;  // Connect internal spi clk to output port

  // Instantiations
  IBUFDS_GTE2 i_ibufds_rx_ref_clk_0 (
    .CEB (1'd0),
    .I (rx_ref