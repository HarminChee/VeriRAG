`timescale 1ns/100ps
`timescale 1ns/100ps
module up_hdmi_tx #(
  parameter   ID = 0) (
  input                   test_i,
  input                   hdmi_clk,
  output                  hdmi_rst,
  output                  hdmi_csc_bypass,
  output                  hdmi_ss_bypass,
  output      [ 1:0]      hdmi_srcsel,
  output      [23:0]      hdmi_const_rgb,
  output      [15:0]      hdmi_hl_active,
  output      [15:0]      hdmi_hl_width,
  output      [15:0]      hdmi_hs_width,
  output      [15:0]      hdmi_he_max,
  output      [15:0]      hdmi_he_min,
  output      [15:0]      hdmi_vf_active,
  output      [15:0]      hdmi_vf_width,
  output      [15:0]      hdmi_vs_width,
  output      [15:0]      hdmi_ve_max,
  output      [15:0]      hdmi_ve_min,
  output      [23:0]      hdmi_clip_max,
  output      [23:0]      hdmi_clip_min,
  input                   hdmi_status,
  input                   hdmi_tpm_oos,
  input       [31:0]      hdmi_clk_ratio,
  input                   vdma_clk,
  output                  vdma_rst,
  input                   vdma_ovf,
  input                   vdma_unf,
  input                   vdma_tpm_oos,
  input                   up_rstn_i,
  input                   up_clk,
  input                   up_wreq,
  input       [13:0]      up_waddr,
  input       [31:0]      up_wdata,
  output  reg             up_wack,
  input                   up_rreq,
  input       [13:0]      up_raddr,
  output  reg [31:0]      up_rdata,
  output  reg             up_rack);

  localparam  PCORE_VERSION = 32'h00040063;

  wire up_rstn;
  assign up_rstn = test_i ? up_clk : up_rstn_i;

  reg             up_core_preset = 'd0;
  reg     [31:0]  up_scratch = 'd0;
  reg             up_resetn = 'd0;
  reg             up_csc_bypass = 'd0;
  reg             up_ss_bypass = 'd0;
  reg     [ 1:0]  up_srcsel = 'd1;
  reg     [23:0]  up_const_rgb = 'd0;
  reg             up_vdma_ovf = 'd0;
  reg             up_vdma_unf = 'd0;
  reg             up_hdmi_tpm_oos = 'd0;
  reg             up_vdma_tpm_oos = 'd0;
  reg     [15:0]  up_hl_active = 'd0;
  reg     [15:0]  up_hl_width = 'd0;
  reg     [15:0]  up_hs_width = 'd0;
  reg     [15:0]  up_he_max = 'd0;
  reg     [15:0]  up_he_min = 'd0;
  reg     [15:0]  up_vf_active = 'd0;
  reg     [15:0]  up_vf_width = 'd0;
  reg     [15:0]  up_vs_width = 'd0;
  reg     [15:0]  up_ve_max = 'd0;
  reg     [15:0]  up_ve_min = 'd0;
  reg     [23:0]  up_clip_max = 'd0;
  reg     [23:0]  up_clip_min = 'd0;

  wire            up_wreq_s;
  wire            up_rreq_s;
  wire            up_hdmi_status_s;
  wire            up_hdmi_tpm_oos_s;
  wire    [31:0]  up_hdmi_clk_count_s;
  wire            up_vdma_ovf_s;
  wire            up_vdma_unf_s;
  wire            up_vdma_tpm_oos_s;

  // ... existing code ...

endmodule