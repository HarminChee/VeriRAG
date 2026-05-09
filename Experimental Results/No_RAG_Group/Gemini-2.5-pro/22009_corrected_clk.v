`timescale 1ns/100ps
// 1_corrected_clk.v

module axi_ad9434_if (
  input           adc_clk_in_p,
  input           adc_clk_in_n,
  input   [11:0]  adc_data_in_p,
  input   [11:0]  adc_data_in_n,
  input           adc_or_in_p,
  input           adc_or_in_n,
  output  [47:0]  adc_data,
  output          adc_or,
  output          adc_clk, // Functional clock output
  input           adc_rst, // Reset input
  output          adc_status,
  input           up_clk,
  input   [12:0]  up_adc_dld,
  input   [64:0]  up_adc_dwdata,
  output  [64:0]  up_adc_drdata,
  input           delay_clk,
  input           delay_rst,
  output          delay_locked,
  input           mmcm_rst,
  input           up_rstn,
  input           up_drp_sel,
  input           up_drp_wr,
  input   [11:0]  up_drp_addr,
  input   [15:0]  up_drp_wdata,
  output  [15:0]  up_drp_rdata,
  output          up_drp_ready,
  output          up_drp_locked,

  // DFT Ports
  input           test_clk, // Test clock input derived from primary input
  input           test_mode // Test mode select signal
);
  parameter PCORE_DEVTYPE = 0;
  parameter PCORE_IODELAY_GROUP = "dev_if_delay_group";
  localparam PCORE_BUFTYPE = PCORE_DEVTYPE;
  localparam SDR = 0;

  // Internal signals
  reg             adc_status_reg = 'd0; // Internal register for adc_status output
  reg             adc_status_m1 = 'd0;
  wire    [3:0]   adc_or_s;
  wire            adc_clk_in;      // Clock from IBUFDS
  wire            adc_div_clk;     // Divided functional clock from MMCM/PLL
  wire            clk_muxed;       // Muxed clock for DFT compliance

  genvar          l_inst;

  // Assign functional clock output
  assign  adc_clk = adc_div_clk;

  // DFT Clock Mux: Select test_clk in test_mode, otherwise functional clock
  // Ensures flip-flops can be clocked by a controllable test clock.
  assign clk_muxed = test_mode ? test_clk : adc_div_clk;

  // Instantiate clock generation block (e.g., MMCM/PLL)
  ad_serdes_clk #(
    .MMCM_DEVICE_TYPE (PCORE_DEVTYPE),
    .MMCM_CLKIN_PERIOD (2),
    .MMCM_VCO_DIV (6),
    .MMCM_VCO_MUL (12),
    .MMCM_CLK0_DIV (2),
    .MMCM_CLK1_DIV (8))
  i_serdes_clk (
    .mmcm_rst (mmcm_rst),
    .clk_in_p (adc_clk_in_p),
    .clk_in_n (adc_clk_in_n),
    .clk (adc_clk_in),      // Output: High-speed clock
    .div_clk (adc_div_clk), // Output: Divided functional clock
    .up_clk (up_clk),
    .up_rstn (up_rstn),
    .up_drp_sel (up_drp_sel),
    .up_drp_wr (up_drp_wr),
    .up_drp_addr (up_drp_addr),
    .up_drp_wdata (up_drp_wdata),
    .up_drp_rdata (up_drp_rdata),
    .up_drp_ready (up_drp_ready),
    .up_drp_locked (up_drp_locked));

  // Instantiate SERDES input logic for data channels
  generate
  for (l_inst = 0; l_inst <= 11; l_inst = l_inst + 1) begin : g_adc_if
    ad_serdes_in #(
      .DEVICE_TYPE(PCORE_DEVTYPE),
      .IODELAY_CTRL(0),
      .IODELAY_GROUP(PCORE_IODELAY_GROUP),
      .IF_TYPE(SDR),
      .PARALLEL_WIDTH(4))
    i_adc_data (
      .rst(adc_rst), // Note: Reset handling within ad_serdes_in needs DFT consideration
      .clk(adc_clk_in),
      .div_clk(adc_div_clk),
      .data_s0(adc_data[(3*12)+l_inst]),
      .data_s1(adc_data[(2*12)+l_inst]),
      .data_s2(adc_data[(1*12)+l_inst]),
      .data_s3(adc_data[(0*12)+l_inst]),
      .data_s4(),
      .data_s5(),
      .data_s6(),
      .data_s7(),
      .data_in_p(adc_data_in_p[l_inst]),
      .data_in_n(adc_data_in_n[l_inst]),
      .up_clk (up_clk),
      .up_dld (up_adc_dld[l_inst]),
      .up_dwdata (up_adc_dwdata[((l_inst*5)+4):(l_inst*5)]),
      .up_drdata (up_adc_drdata[((l_inst*5)+4):(l_inst*5)]),
      .delay_clk(delay_clk),
      .delay_rst(delay_rst),
      .delay_locked()); // Instance output not connected at module level
    end
  endgenerate

  // Instantiate SERDES input logic for OR (Out of Range) signal
  ad_serdes_in #(
    .DEVICE_TYPE(PCORE_DEVTYPE),
    .IODELAY_CTRL(1),
    .IODELAY_GROUP(PCORE_IODELAY_GROUP),
    .IF_TYPE(SDR),
    .PARALLEL_WIDTH(4))
  i_adc_or ( // Renamed instance
    .rst(adc_rst), // Note: Reset handling within ad_serdes_in needs DFT consideration
    .clk(adc_clk_in),
    .div_clk(adc_div_clk),
    .data_s0(adc_or_s[0]),
    .data_s1(adc_or_s[1]),
    .data_s2(adc_or_s[2]),
    .data_s3(adc_or_s[3]),
    .data_s4(),
    .data_s5(),
    .data_s6(),
    .data_s7(),
    .data_in_p(adc_or_in_p),
    .data_in_n(adc_or_in_n),
    .up_clk (up_clk),
    .up_dld (up_adc_dld[12]),
    .up_dwdata (up_adc_dwdata[64:60]),
    .up_drdata (up_adc_drdata[64:60]),
    .delay_clk(delay_clk),
    .delay_rst(delay_rst),
    .delay_locked(delay_locked)); // Connected to module output

  // Combine OR signals
  assign adc_or = adc_or_s[0] | adc_or_s[1] | adc_or_s[2] | adc_or_s[3];

  // Status registers clocked by the DFT-muxed clock
  // Using asynchronous reset for adc_rst. If synchronous reset is intended,
  // remove 'posedge adc_rst' and check reset condition inside 'posedge clk_muxed'.
  always @(posedge clk_muxed or posedge adc_rst) begin
    if (adc_rst == 1'b1) begin // Asynchronous reset condition
      adc_status_m1  <= 1'b0;
      adc_status_reg <= 1'b0;
    end else begin // Synchronous logic path
      adc_status_m1  <= up_drp_locked & delay_locked; // Capture status
      adc_status_reg <= adc_status_m1;             // Register the status
    end
  end

  // Assign registered status to the output port
  assign adc_status = adc_status_reg;

endmodule