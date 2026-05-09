`timescale 1ns/100ps
module axi_ad9434_core (
  adc_clk,
  adc_data,
  adc_or,
  dma_dvalid,
  dma_data,
  dma_dovf,
  up_drp_sel,
  up_drp_wr,
  up_drp_addr,
  up_drp_wdata,
  up_drp_rdata,
  up_drp_ready,
  up_drp_locked,
  up_dld,
  up_dwdata,
  up_drdata,
  delay_clk,
  delay_rst_in, // Changed to input
  delay_locked,
  up_rstn_in, // Changed to input
  up_clk,
  up_wreq,
  up_waddr,
  up_wdata,
  up_wack,
  up_rreq,
  up_raddr,
  up_rdata,
  up_rack,
  mmcm_rst_in, // Changed to input
  adc_rst_in, // Changed to input
  adc_status);

  parameter PCORE_ID = 0;
  input           adc_clk;
  input  [47:0]   adc_data;
  input           adc_or;
  output          dma_dvalid;
  output [63:0]   dma_data;
  input           dma_dovf;
  output          up_drp_sel;
  output          up_drp_wr;
  output  [11:0]  up_drp_addr;
  output  [15:0]  up_drp_wdata;
  input   [15:0]  up_drp_rdata;
  input           up_drp_ready;
  input           up_drp_locked;
  output  [12:0]  up_dld;
  output  [64:0]  up_dwdata;
  input   [64:0]  up_drdata;
  input           delay_clk;
  input           delay_rst_in;
  input           delay_locked;
  input           up_clk;
  input           up_rstn_in;
  input           up_wreq;
  input   [13:0]  up_waddr;
  input   [31:0]  up_wdata;
  output          up_wack;
  input           up_rreq;
  input   [13:0]  up_raddr;
  output  [31:0]  up_rdata;
  output          up_rack;
  input           mmcm_rst_in;
  input           adc_rst_in;
  input           adc_status;

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
  wire            up_wack_s[0:2];
  wire    [31:0]  up_rdata_s[0:2];
  wire            up_rack_s[0:2];

  // ... existing code ...

  always @(posedge up_clk) begin
    if (up_rstn_in == 0) begin
      up_rdata <= 'd0;
      up_rack <= 'd0;
      up_wack <= 'd0;
    end else begin
      up_rdata <= up_rdata_s[0] | up_rdata_s[1] | up_rdata_s[2];
      up_rack <= up_rack_s[0] | up_rack_s[1] | up_rack_s[2];
      up_wack <= up_wack_s[0] | up_wack_s[1] | up_wack_s[2];
    end
  end

  // ... existing code ...

  up_adc_common #(
    .PCORE_ID(PCORE_ID))
  i_adc_common(
    .mmcm_rst (mmcm_rst_in),
    .adc_clk (adc_clk),
    .adc_rst (adc_rst_in),
    // ... existing code ...
    .up_rstn (up_rstn_in),
    // ... rest of existing code ...
  );

  // ... existing code ...

  up_delay_cntrl #(.IO_WIDTH(13), .IO_BASEADDR(6'h02)) i_delay_cntrl (
    .delay_clk (delay_clk),
    .delay_rst (delay_rst_in),
    .delay_locked (delay_locked),
    // ... existing code ...
    .up_rstn (up_rstn_in),
    // ... rest of existing code ...
  );

endmodule