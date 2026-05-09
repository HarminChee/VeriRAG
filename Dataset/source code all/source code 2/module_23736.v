`timescale 1ns/100ps
`timescale 1ns/100ps
module ad_mmcm_drp (
  clk,
  mmcm_rst,
  mmcm_clk_0,
  mmcm_clk_1,
  drp_clk,
  drp_rst,
  drp_sel,
  drp_wr,
  drp_addr,
  drp_wdata,
  drp_rdata,
  drp_ack_t,
  drp_locked);
  parameter   MMCM_DEVICE_TYPE = 0;
  localparam  MMCM_DEVICE_7SERIES = 0;
  localparam  MMCM_DEVICE_VIRTEX6 = 1;
  parameter   MMCM_CLKIN_PERIOD  = 1.667;
  parameter   MMCM_VCO_DIV  = 6;
  parameter   MMCM_VCO_MUL = 12.000;
  parameter   MMCM_CLK0_DIV = 2.000;
  parameter   MMCM_CLK1_DIV = 6;
  input           clk;
  input           mmcm_rst;
  output          mmcm_clk_0;
  output          mmcm_clk_1;
  input           drp_clk;
  input           drp_rst;
  input           drp_sel;
  input           drp_wr;
  input   [11:0]  drp_addr;
  input   [15:0]  drp_wdata;
  output  [15:0]  drp_rdata;
  output          drp_ack_t;
  output          drp_locked;
  reg             drp_locked_m1 = 'd0;
  reg             drp_locked = 'd0;
  reg             drp_ready = 'd0;
  reg             drp_ack_t = 'd0;
  reg     [15:0]  drp_rdata = 'd0;
  wire            bufg_fb_clk_s;
  wire            mmcm_fb_clk_s;
  wire            mmcm_clk_0_s;
  wire            mmcm_clk_1_s;
  wire            mmcm_locked_s;
  wire    [15:0]  drp_rdata_s;
  wire            drp_ready_s;
  always @(posedge drp_clk) begin
    if (drp_rst == 1'b1) begin
      drp_locked_m1 <= 1'd0;
      drp_locked <= 1'd0;
    end else begin
      drp_locked_m1 <= mmcm_locked_s;
      drp_locked <= drp_locked_m1;
    end
    drp_ready <= drp_ready_s;
    if ((drp_ready_s == 1'b1) && (drp_ready == 1'b0)) begin
      drp_ack_t <= ~drp_ack_t;
      drp_rdata <= drp_rdata_s;
    end
  end
  generate
  if (MMCM_DEVICE_TYPE == MMCM_DEVICE_VIRTEX6) begin
  MMCM_ADV #(
    .BANDWIDTH ("OPTIMIZED"),
    .CLKOUT4_CASCADE ("FALSE"),
    .CLOCK_HOLD ("FALSE"),
    .COMPENSATION ("ZHOLD"),
    .STARTUP_WAIT ("FALSE"),
    .DIVCLK_DIVIDE (MMCM_VCO_DIV),
    .CLKFBOUT_MULT_F (MMCM_VCO_MUL),
    .CLKFBOUT_PHASE (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F (MMCM_CLK0_DIV),
    .CLKOUT0_PHASE (0.000),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKOUT0_USE_FINE_PS ("FALSE"),
    .CLKOUT1_DIVIDE (MMCM_CLK1_DIV),
    .CLKOUT1_PHASE (0.000),
    .CLKOUT1_DUTY_CYCLE (0.500),
    .CLKOUT1_USE_FINE_PS ("FALSE"),
    .CLKIN1_PERIOD (MMCM_CLKIN_PERIOD),
    .REF_JITTER1 (0.010))
  i_mmcm (
    .CLKIN1 (clk),
    .CLKFBIN (bufg_fb_clk_s),
    .CLKFBOUT (mmcm_fb_clk_s),
    .CLKOUT0 (mmcm_clk_0_s),
    .CLKOUT1 (mmcm_clk_1_s),
    .LOCKED (mmcm_locked_s),
    .DCLK (drp_clk),
    .DEN (drp_sel),
    .DADDR (drp_addr[6:0]),
    .DWE (drp_wr),
    .DI (drp_wdata),
    .DO (drp_rdata_s),
    .DRDY (drp_ready_s),
    .CLKFBOUTB (),
    .CLKOUT0B (),
    .CLKOUT1B (),
    .CLKOUT2 (),
    .CLKOUT2B (),
    .CLKOUT3 (),
    .CLKOUT3B (),
    .CLKOUT4 (),
    .CLKOUT5 (),
    .CLKOUT6 (),
    .CLKIN2 (1'b0),
    .CLKINSEL (1'b1),
    .PSCLK (1'b0),
    .PSEN (1'b0),
    .PSINCDEC (1'b0),
    .PSDONE (),
    .CLKINSTOPPED (),
    .CLKFBSTOPPED (),
    .PWRDWN (1'b0),
    .RST (mmcm_rst));
  end
  if (MMCM_DEVICE_TYPE == MMCM_DEVICE_7SERIES) begin
  MMCME2_ADV #(
    .BANDWIDTH ("OPTIMIZED"),
    .CLKOUT4_CASCADE ("FALSE"),
    .COMPENSATION ("ZHOLD"),
    .STARTUP_WAIT ("FALSE"),
    .DIVCLK_DIVIDE (MMCM_VCO_DIV),
    .CLKFBOUT_MULT_F (MMCM_VCO_MUL),
    .CLKFBOUT_PHASE (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F (MMCM_CLK0_DIV),
    .CLKOUT0_PHASE (0.000),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKOUT0_USE_FINE_PS ("FALSE"),
    .CLKOUT1_DIVIDE (MMCM_CLK1_DIV),
    .CLKOUT1_PHASE (0.000),
    .CLKOUT1_DUTY_CYCLE (0.500),
    .CLKOUT1_USE_FINE_PS ("FALSE"),
    .CLKIN1_PERIOD (MMCM_CLKIN_PERIOD),
    .REF_JITTER1 (0.010))
  i_mmcm (
    .CLKIN1 (clk),
    .CLKFBIN (bufg_fb_clk_s),
    .CLKFBOUT (mmcm_fb_clk_s),
    .CLKOUT0 (mmcm_clk_0_s),
    .CLKOUT1 (mmcm_clk_1_s),
    .LOCKED (mmcm_locked_s),
    .DCLK (drp_clk),
    .DEN (drp_sel),
    .DADDR (drp_addr[6:0]),
    .DWE (drp_wr),
    .DI (drp_wdata),
    .DO (drp_rdata_s),
    .DRDY (drp_ready_s),
    .CLKFBOUTB (),
    .CLKOUT0B (),
    .CLKOUT1B (),
    .CLKOUT2 (),
    .CLKOUT2B (),
    .CLKOUT3 (),
    .CLKOUT3B (),
    .CLKOUT4 (),
    .CLKOUT5 (),
    .CLKOUT6 (),
    .CLKIN2 (1'b0),
    .CLKINSEL (1'b1),
    .PSCLK (1'b0),
    .PSEN (1'b0),
    .PSINCDEC (1'b0),
    .PSDONE (),
    .CLKINSTOPPED (),
    .CLKFBSTOPPED (),
    .PWRDWN (1'b0),
    .RST (mmcm_rst));
  end
  endgenerate
  BUFG i_fb_clk_bufg  (.I (mmcm_fb_clk_s),  .O (bufg_fb_clk_s));
  BUFG i_clk_0_bufg   (.I (mmcm_clk_0_s),   .O (mmcm_clk_0)); 
  BUFG i_clk_1_bufg   (.I (mmcm_clk_1_s),   .O (mmcm_clk_1));
endmodule
