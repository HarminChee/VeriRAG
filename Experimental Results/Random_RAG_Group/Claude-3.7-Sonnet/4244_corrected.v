`timescale 1ns/100ps
`timescale 1ns/100ps
module system_top (
  test_i,
  sys_clk,
  sys_resetn,
  ddr3_a,
  ddr3_ba,
  ddr3_clk_p,
  ddr3_clk_n,
  ddr3_cke,
  ddr3_cs_n,
  ddr3_dm,
  ddr3_ras_n,
  ddr3_cas_n,
  ddr3_we_n,
  ddr3_reset_n,
  ddr3_dq,
  ddr3_dqs_p,
  ddr3_dqs_n,
  ddr3_odt,
  ddr3_rzq,
  eth_rx_clk,
  eth_rx_data,
  eth_rx_cntrl,
  eth_tx_clk_out,
  eth_tx_data,
  eth_tx_cntrl,
  eth_mdc,
  eth_mdio_i,
  eth_mdio_o,
  eth_mdio_t,
  eth_phy_resetn,
  led_grn,
  led_red,
  push_buttons,
  dip_switches,
  ref_clk,
  rx_data,
  rx_sync,
  rx_sysref,
  spi_csn,
  spi_clk,
  spi_sdio);

  input             test_i;
  input             sys_clk;
  input             sys_resetn;
  output  [ 13:0]   ddr3_a;
  output  [  2:0]   ddr3_ba;
  output            ddr3_clk_p;
  output            ddr3_clk_n;
  output            ddr3_cke;
  output            ddr3_cs_n;
  output  [  7:0]   ddr3_dm;
  output            ddr3_ras_n;
  output            ddr3_cas_n;
  output            ddr3_we_n;
  output            ddr3_reset_n;
  inout   [ 63:0]   ddr3_dq;
  inout   [  7:0]   ddr3_dqs_p;
  inout   [  7:0]   ddr3_dqs_n;
  output            ddr3_odt;
  input             ddr3_rzq;
  input             eth_rx_clk;
  input   [  3:0]   eth_rx_data;
  input             eth_rx_cntrl;
  output            eth_tx_clk_out;
  output  [  3:0]   eth_tx_data;
  output            eth_tx_cntrl;
  output            eth_mdc;
  input             eth_mdio_i;
  output            eth_mdio_o;
  output            eth_mdio_t;
  output            eth_phy_resetn;
  output  [  7:0]   led_grn;
  output  [  7:0]   led_red;
  input   [  2:0]   push_buttons;
  input   [  7:0]   dip_switches;
  input             ref_clk;
  input   [  3:0]   rx_data;
  output            rx_sync;
  output            rx_sysref;
  output            spi_csn;
  output            spi_clk;
  inout             spi_sdio;

  reg               rx_sysref_m1 = 'd0;
  reg               rx_sysref_m2 = 'd0;
  reg               rx_sysref_m3 = 'd0;
  reg               rx_sysref = 'd0;
  reg     [  3:0]   phy_rst_cnt = 0;
  reg               phy_rst_reg = 0;

  wire              sys_125m_clk;
  wire              sys_25m_clk;
  wire              sys_2m5_clk;
  wire              eth_tx_clk;
  wire              rx_clk;
  wire              sys_pll_locked_s;
  wire              eth_tx_reset_s;
  wire              eth_tx_mode_1g_s;
  wire              eth_tx_mode_10m_100m_n_s;
  wire              spi_mosi;
  wire              spi_miso;
  wire    [  3:0]   rx_ip_sof_s;
  wire    [127:0]   rx_ip_data_s;
  wire    [127:0]   rx_data_s;
  wire              rx_sw_rstn_s;
  wire              rx_sysref_s;
  wire              rx_err_s;
  wire              rx_ready_s;
  wire    [  3:0]   rx_rst_state_s;
  wire              rx_lane_aligned_s;
  wire    [  3:0]   rx_analog_reset_s;
  wire    [  3:0]   rx_digital_reset_s;
  wire    [  3:0]   rx_cdr_locked_s;
  wire    [  3:0]   rx_cal_busy_s;
  wire              rx_pll_locked_s;
  wire    [ 15:0]   rx_xcvr_status_s;
  wire              dft_eth_tx_clk;

  assign eth_tx_clk = (eth_tx_mode_1g_s == 1'b1) ? sys_125m_clk :
    (eth_tx_mode_10m_100m_n_s == 1'b0) ? sys_25m_clk : sys_2m5_clk;

  assign dft_eth_tx_clk = test_i ? sys_clk : eth_tx_clk;
  assign eth_phy_resetn = phy_rst_reg;

  always @(posedge sys_clk) begin
    if (!sys_resetn) begin
      phy_rst_cnt <= 0;
      phy_rst_reg <= 0;
    end
    else begin
      phy_rst_cnt <= phy_rst_cnt + 4'd1;
      if (phy_rst_cnt == 4'h0) begin
        phy_rst_reg <= sys_pll_locked_s;
      end
    end
  end

  altddio_out #(.width(1)) i_eth_tx_clk_out (
    .aset (1'b0),
    .sset (1'b0),
    .sclr (1'b0),
    .oe (1'b1),
    .oe_out (),
    .datain_h (1'b1),
    .datain_l (1'b0),
    .outclocken (1'b1),
    .aclr (eth_tx_reset_s),
    .outclock (dft_eth_tx_clk),
    .dataout (eth_tx_clk_out));

  assign eth_tx_reset_s = ~sys_pll_locked_s;

  always @(posedge sys_clk) begin
    if (!sys_resetn) begin
      rx_sysref_m1 <= 0;
      rx_sysref_m2 <= 0;
      rx_sysref_m3 <= 0;
      rx_sysref <= 0;
    end
    else begin
      rx_sysref_m1 <= rx_sysref_s;
      rx_sysref_m2 <= rx_sysref_m1;
      rx_sysref_m3 <= rx_sysref_m2;
      rx_sysref <= rx_sysref_m2 & ~rx_sysref_m3;
    end
  end

  genvar n;
  generate
  for (n = 0; n < 4; n = n + 1) begin: g_align_1
  ad_jesd_align i_jesd_align (
    .rx_clk (rx_clk),
    .rx_ip_sof (rx_ip_sof_s),
    .rx_ip_data (rx_ip_data_s[n*32+31:n*32]),
    .rx_data (rx_data_s[n*32+31:n*32]));
  end
  endgenerate

  // ... existing code ...

endmodule