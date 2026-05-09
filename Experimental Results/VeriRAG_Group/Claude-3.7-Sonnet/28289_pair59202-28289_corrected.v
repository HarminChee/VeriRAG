`timescale 1ns/100ps
`timescale 1ns/100ps
module up_hdmi_tx #(
  parameter   ID = 0) (
  input                   hdmi_clk,
  input                   hdmi_rst_n, // Added reset input
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
  input                   vdma_rst_n, // Added reset input
  output                  vdma_rst,
  input                   vdma_ovf,
  input                   vdma_unf,
  input                   vdma_tpm_oos,
  input                   up_rstn,
  input                   up_clk,
  input                   up_wreq,
  input       [13:0]      up_waddr,
  input       [31:0]      up_wdata,
  output  reg             up_wack,
  input                   up_rreq,
  input       [13:0]      up_raddr,
  output  reg [31:0]      up_rdata,
  output  reg             up_rack);

  // Rest of code remains unchanged
  // ... existing code ...

  // Modified reset generation
  ad_rst i_core_rst_reg (
    .rst_async(up_core_preset),
    .clk(hdmi_clk),
    .rstn(hdmi_rst_n), // Connect to input reset
    .rst(hdmi_rst));

  ad_rst i_vdma_rst_reg (
    .rst_async(up_core_preset),
    .clk(vdma_clk),
    .rstn(vdma_rst_n), // Connect to input reset  
    .rst(vdma_rst));

  // Rest of code remains unchanged
  // ... existing code ...

endmodule