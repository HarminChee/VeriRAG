`timescale 1ns/100ps

module axi_ad9434_core (
  input           adc_clk,
  input  [47:0]   adc_data,
  input           adc_or,
  output          dma_dvalid,
  output [63:0]   dma_data,
  input           dma_dovf,
  output          up_drp_sel,
  output          up_drp_wr,
  output  [11:0]  up_drp_addr,
  output  [15:0]  up_drp_wdata,
  input   [15:0]  up_drp_rdata,
  input           up_drp_ready,
  input           up_drp_locked,
  output  [12:0]  up_dld,
  output  [64:0]  up_dwdata,
  input   [64:0]  up_drdata,
  input           delay_clk,
  output          delay_rst,
  input           delay_locked,
  input           up_rstn,
  input           up_clk,
  input           up_wreq,
  input   [13:0]  up_waddr,
  input   [31:0]  up_wdata,
  output          up_wack,
  input           up_rreq,
  input   [13:0]  up_raddr,
  output  [31:0]  up_rdata,
  output          up_rack,
  output          mmcm_rst,
  output          adc_rst,
  input           adc_status
);

  parameter PCORE_ID = 0;

  reg             dma_dvalid_reg;
  reg             up_wack;
  reg     [31:0]  up_rdata;
  reg             up_rack;

  wire            up_status_pn_err_s;
  wire            up_status_pn_oos_s;
  wire            up_status_or_s;
  wire            adc_dfmt_se_s;
  wire            adc_dfmt_type_s;
  wire            adc_dfmt_enable_s;
  wire    [ 3:0]  adc_pnseq_sel_s;
  wire            adc_pn_err_s;
  wire            adc_pn_oos_s;

  // Corrected array declaration syntax
  wire            up_wack_s   [0:2];
  wire    [31:0]  up_rdata_s  [0:2];
  wire            up_rack_s   [0:2];

  // Intermediate signals for data formatting (if needed, e.g., for combining valid signals)
  // wire [3:0] datafmt_valid_out; // Example if combining valid signals was needed

  assign dma_dvalid = dma_dvalid_reg;

  axi_ad9434_pnmon i_pnmon (
    .adc_clk (adc_clk),
    .adc_data (adc_data),
    .adc_pnseq_sel (adc_pnseq_sel_s),
    .adc_pn_err (adc_pn_err_s),
    .adc_pn_oos (adc_pn_oos_s)
  );

  genvar n;
  generate
  for (n = 0; n < 4; n = n + 1) begin: g_ad_dfmt
   ad_datafmt # (
    .DATA_WIDTH(12)
   )
   i_datafmt (
    .clk (adc_clk),
    .valid (1'b1), // Assuming input data is always valid when formatter is enabled
    .data (adc_data[n*12+11:n*12]),
    // .valid_out (datafmt_valid_out[n]), // Connect to intermediate if needed
    .valid_out (), // dma_dvalid is now driven outside the generate loop
    .data_out (dma_data[n*16+15:n*16]),
    .dfmt_enable (adc_dfmt_enable_s),
    .dfmt_type (adc_dfmt_type_s),
    .dfmt_se (adc_dfmt_se_s)
   );
  end
  endgenerate

  // Register dma_dvalid based on adc_dfmt_enable_s, clocked by adc_clk
  // Assumes adc_dfmt_enable_s is synchronous to adc_clk or properly handled
  always @(posedge adc_clk) begin
      dma_dvalid_reg <= adc_dfmt_enable_s; // Simple assignment, adjust if complex logic needed
  end

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 1'b0) begin // Use 1'b0 for active-low reset
      up_rdata <= 32'd0;
      up_rack <= 1'b0;
      up_wack <= 1'b0;
    end else begin
      // ORing assumes only one module drives its bus based on address decode
      up_rdata <= up_rdata_s[0] | up_rdata_s[1] | up_rdata_s[2];
      up_rack <= up_rack_s[0] | up_rack_s[1] | up_rack_s[2];
      up_wack <= up_wack_s[0] | up_wack_s[1] | up_wack_s[2];
    end
  end

  up_adc_common #(
    .PCORE_ID(PCORE_ID)
  )
  i_adc_common(
    .mmcm_rst (mmcm_rst),
    .adc_clk (adc_clk),
    .adc_rst (adc_rst),
    .adc_r1_mode (),
    .adc_ddr_edgesel (),
    .adc_pin_mode (),
    .adc_status (adc_status),
    .adc_sync_status (1'd0),
    .adc_status_ovf (dma_dovf),
    .adc_status_unf (1'b0),
    .adc_clk_ratio (32'd4),
    .adc_start_code (),
    .adc_sync (),
    .up_status_pn_err (up_status_pn_err_s),
    .up_status_pn_oos (up_status_pn_oos_s),
    .up_status_or (up_status_or_s),
    .up_drp_sel (up_drp_sel),
    .up_drp_wr (up_drp_wr),
    .up_drp_addr (up_drp_addr),
    .up_drp_wdata (up_drp_wdata),
    .up_drp_rdata (up_drp_rdata),
    .up_drp_ready (up_drp_ready),
    .up_drp_locked (up_drp_locked),
    .up_usr_chanmax (),
    .adc_usr_chanmax (8'd0), // Assuming 0 channels defined here
    .up_adc_gpio_in (32'd0),
    .up_adc_gpio_out (),
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_wreq (up_wreq),
    .up_waddr (up_waddr),
    .up_wdata (up_wdata),
    .up_wack (up_wack_s[0]),
    .up_rreq (up_rreq),
    .up_raddr (up_raddr),
    .up_rdata (up_rdata_s[0]),
    .up_rack (up_rack_s[0])
  );

  up_adc_channel #(
    .PCORE_ADC_CHID(0)
  )
  i_adc_channel(
    .adc_clk (adc_clk),
    .adc_rst (adc_rst), // Driven by i_adc_common
    .adc_enable (),
    .adc_iqcor_enb (),
    .adc_dcfilt_enb (),
    .adc_dfmt_se (adc_dfmt_se_s),
    .adc_dfmt_type (adc_dfmt_type_s),
    .adc_dfmt_enable (adc_dfmt_enable_s),
    .adc_dcfilt_offset (),
    .adc_dcfilt_coeff (),
    .adc_iqcor_coeff_1 (),
    .adc_iqcor_coeff_2 (),
    .adc_pnseq_sel (adc_pnseq_sel_s),
    .adc_data_sel (),
    .adc_pn_err (adc_pn_err_s), // Driven by i_pnmon
    .adc_pn_oos (adc_pn_oos_s), // Driven by i_pnmon
    .adc_or (adc_or), // Input to top module
    .up_adc_pn_err (up_status_pn_err_s), // Connect to common status wire
    .up_adc_pn_oos (up_status_pn_oos_s), // Connect to common status wire
    .up_adc_or (up_status_or_s), // Connect to common status wire
    .up_usr_datatype_be (),
    .up_usr_datatype_signed (),
    .up_usr_datatype_shift (),
    .up_usr_datatype_total_bits (),
    .up_usr_datatype_bits (),
    .up_usr_decimation_m (),
    .up_usr_decimation_n (),
    .adc_usr_datatype_be (1'b0),
    .adc_usr_datatype_signed (1'b1),
    .adc_usr_datatype_shift (8'd0),
    .adc_usr_datatype_total_bits (8'd16),
    .adc_usr_datatype_bits (8'd16),
    .adc_usr_decimation_m (16'd1),
    .adc_usr_decimation_n (16'd1),
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_wreq (up_wreq),
    .up_waddr (up_waddr),
    .up_wdata (up_wdata),
    .up_wack (up_wack_s[1]),
    .up_rreq (up_rreq),
    .up_raddr (up_raddr),
    .up_rdata (up_rdata_s[1]),
    .up_rack (up_rack_s[1])
  );

  up_delay_cntrl #(
    .IO_WIDTH(13),
    .IO_BASEADDR(6'h02) // Example Base Address
  )
  i_delay_cntrl (
    .delay_clk (delay_clk),
    .delay_rst (delay_rst),
    .delay_locked (delay_locked),
    .up_dld (up_dld),         // Output driven by this instance
    .up_dwdata (up_dwdata),   // Output driven by this instance
    .up_drdata (up_drdata),   // Input from top module port
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_wreq (up_wreq),
    .up_waddr (up_waddr),
    .up_wdata (up_wdata),
    .up_wack (up_wack_s[2]),
    .up_rreq (up_rreq),
    .up_raddr (up_raddr),
    .up_rdata (up_rdata_s[2]),
    .up_rack (up_rack_s[2])
  );

endmodule

// Note: Assumes existence and correct interface definitions for submodules:
// axi_ad9434_pnmon, ad_datafmt, up_adc_common, up_adc_channel, up_delay_cntrl