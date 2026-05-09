Here's the modified Verilog code with the ACNCPI error addressed:


`timescale 1ns/100ps
module up_hdmi_tx #(
  parameter   ID = 0) (
  input                   hdmi_clk,
  input                   hdmi_rst_in,  // Changed from output to input
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
  input                   vdma_rst_in,  // Changed from output to input
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

  // ... existing code ...

  wire hdmi_rst;
  wire vdma_rst;

  assign hdmi_rst = hdmi_rst_in | up_core_preset;
  assign vdma_rst = vdma_rst_in | up_core_preset;

  // ... existing code ...

  ad_rst i_core_rst_reg (.rst_async(up_core_preset), .clk(hdmi_clk), .rstn(), .rst());
  ad_rst i_vdma_rst_reg (.rst_async(up_core_preset), .clk(vdma_clk), .rstn(), .rst());

  // ... existing code ...

  up_xfer_cntrl #(.DATA_WIDTH(236)) i_xfer_cntrl (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_cntrl ({ up_ss_bypass,
                      up_csc_bypass,
                      up_srcsel,
                      up_const_rgb,
                      up_hl_active,
                      up_hl_width,
                      up_hs_width,
                      up_he_max,
                      up_he_min,
                      up_vf_active,
                      up_vf_width,
                      up_vs_width,
                      up_ve_max,
                      up_ve_min,
                      up_clip_max,
                      up_clip_min}),
    .up_xfer_done (),
    .d_rst (hdmi_rst),
    .d_clk (hdmi_clk),
    .d_data_cntrl ({  hdmi_ss_bypass,
                      hdmi_csc_bypass,
                      hdmi_srcsel,
                      hdmi_const_rgb,
                      hdmi_hl_active,
                      hdmi_hl_width,
                      hdmi_hs_width,
                      hdmi_he_max,
                      hdmi_he_min,
                      hdmi_vf_active,
                      hdmi_vf_width,
                      hdmi_vs_width,
                      hdmi_ve_max,
                      hdmi_ve_min,
                      hdmi_clip_max,
                      hdmi_clip_min}));

  // ... existing code ...

endmodule