`timescale 1ns/100ps
`timescale 1ns/100ps
module axi_axis_xx (
  adc_clk,
  adc_valid,
  adc_data,
  s_axis_s2mm_clk,
  s_axis_s2mm_tvalid,
  s_axis_s2mm_tdata,
  s_axis_s2mm_tkeep,
  s_axis_s2mm_tlast,
  s_axis_s2mm_tready,
  dac_clk,
  dac_rd,
  dac_valid,
  dac_data,
  m_axis_mm2s_clk,
  m_axis_mm2s_fsync,
  m_axis_mm2s_tvalid,
  m_axis_mm2s_tdata,
  m_axis_mm2s_tkeep,
  m_axis_mm2s_tlast,
  m_axis_mm2s_tready,
  s_axi_aclk,
  s_axi_aresetn,
  s_axi_awvalid,
  s_axi_awaddr,
  s_axi_awready,
  s_axi_wvalid,
  s_axi_wdata,
  s_axi_wstrb,
  s_axi_wready,
  s_axi_bvalid,
  s_axi_bresp,
  s_axi_bready,
  s_axi_arvalid,
  s_axi_araddr,
  s_axi_arready,
  s_axi_rvalid,
  s_axi_rdata,
  s_axi_rresp,
  s_axi_rready);
  parameter   PCORE_ID = 0;
  parameter   PCORE_ADC_DATA_WIDTH = 64;
  parameter   PCORE_DAC_DATA_WIDTH = 64;
  parameter   C_S_AXI_MIN_SIZE = 32'hffff;
  parameter   C_BASEADDR = 32'hffffffff;
  parameter   C_HIGHADDR = 32'h00000000;
  input                                     adc_clk;
  input                                     adc_valid;
  input  [(PCORE_ADC_DATA_WIDTH-1):0]       adc_data;
  input                                     s_axis_s2mm_clk;
  output                                    s_axis_s2mm_tvalid;
  output [(PCORE_ADC_DATA_WIDTH-1):0]       s_axis_s2mm_tdata;
  output [((PCORE_ADC_DATA_WIDTH/8)-1):0]   s_axis_s2mm_tkeep;
  output                                    s_axis_s2mm_tlast;
  input                                     s_axis_s2mm_tready;
  input                                     dac_clk;
  input                                     dac_rd;
  output                                    dac_valid;
  output [(PCORE_DAC_DATA_WIDTH-1):0]       dac_data;
  input                                     m_axis_mm2s_clk;
  output                                    m_axis_mm2s_fsync;
  input                                     m_axis_mm2s_tvalid;
  input  [(PCORE_DAC_DATA_WIDTH-1):0]       m_axis_mm2s_tdata;
  input  [((PCORE_DAC_DATA_WIDTH/8)-1):0]   m_axis_mm2s_tkeep;
  input                                     m_axis_mm2s_tlast;
  output                                    m_axis_mm2s_tready;
  input           s_axi_aclk;
  input           s_axi_aresetn;
  input           s_axi_awvalid;
  input   [31:0]  s_axi_awaddr;
  output          s_axi_awready;
  input           s_axi_wvalid;
  input   [31:0]  s_axi_wdata;
  input   [ 3:0]  s_axi_wstrb;
  output          s_axi_wready;
  output          s_axi_bvalid;
  output  [ 1:0]  s_axi_bresp;
  input           s_axi_bready;
  input           s_axi_arvalid;
  input   [31:0]  s_axi_araddr;
  output          s_axi_arready;
  output          s_axi_rvalid;
  output  [31:0]  s_axi_rdata;
  output  [ 1:0]  s_axi_rresp;
  input           s_axi_rready;
  reg     [31:0]  up_rdata = 'd0;
  reg             up_ack = 'd0;
  wire            up_clk;
  wire            up_rstn;
  wire            up_sel_s;
  wire            up_wr_s;
  wire    [13:0]  up_addr_s;
  wire    [31:0]  up_wdata_s;
  wire    [31:0]  up_rdata_rx_s;
  wire            up_ack_rx_s;
  wire    [31:0]  up_rdata_tx_s;
  wire            up_ack_tx_s;
  assign up_clk = s_axi_aclk;
  assign up_rstn = s_axi_aresetn;
  assign s_axis_s2mm_tkeep = {(PCORE_ADC_DATA_WIDTH/8){1'b1}};
  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_rdata <= 'd0;
      up_ack <= 'd0;
    end else begin
      up_rdata <= up_rdata_rx_s | up_rdata_tx_s;
      up_ack <= up_ack_rx_s | up_ack_tx_s;
    end
  end
  axi_axis_rx_core #(.DATA_WIDTH(PCORE_ADC_DATA_WIDTH)) i_axis_rx_core (
    .adc_clk (adc_clk),
    .adc_valid (adc_valid),
    .adc_data (adc_data),
    .dma_clk (s_axis_s2mm_clk),
    .dma_valid (s_axis_s2mm_tvalid),
    .dma_last (s_axis_s2mm_tlast),
    .dma_data (s_axis_s2mm_tdata),
    .dma_ready (s_axis_s2mm_tready),
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_sel (up_sel_s),
    .up_wr (up_wr_s),
    .up_addr (up_addr_s),
    .up_wdata (up_wdata_s),
    .up_rdata (up_rdata_rx_s),
    .up_ack (up_ack_rx_s));
  axi_axis_tx_core #(.DATA_WIDTH(PCORE_DAC_DATA_WIDTH)) i_axis_tx_core (
    .dac_clk (dac_clk),
    .dac_rd (dac_rd),
    .dac_valid (dac_valid),
    .dac_data (dac_data),
    .dma_clk (m_axis_mm2s_clk),
    .dma_fs (m_axis_mm2s_fsync),
    .dma_valid (m_axis_mm2s_tvalid),
    .dma_data (m_axis_mm2s_tdata),
    .dma_ready (m_axis_mm2s_tready),
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_sel (up_sel_s),
    .up_wr (up_wr_s),
    .up_addr (up_addr_s),
    .up_wdata (up_wdata_s),
    .up_rdata (up_rdata_tx_s),
    .up_ack (up_ack_tx_s));
  up_axi #(
    .PCORE_BASEADDR (C_BASEADDR),
    .PCORE_HIGHADDR (C_HIGHADDR))
  i_up_axi (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_axi_awvalid (s_axi_awvalid),
    .up_axi_awaddr (s_axi_awaddr),
    .up_axi_awready (s_axi_awready),
    .up_axi_wvalid (s_axi_wvalid),
    .up_axi_wdata (s_axi_wdata),
    .up_axi_wstrb (s_axi_wstrb),
    .up_axi_wready (s_axi_wready),
    .up_axi_bvalid (s_axi_bvalid),
    .up_axi_bresp (s_axi_bresp),
    .up_axi_bready (s_axi_bready),
    .up_axi_arvalid (s_axi_arvalid),
    .up_axi_araddr (s_axi_araddr),
    .up_axi_arready (s_axi_arready),
    .up_axi_rvalid (s_axi_rvalid),
    .up_axi_rresp (s_axi_rresp),
    .up_axi_rdata (s_axi_rdata),
    .up_axi_rready (s_axi_rready),
    .up_sel (up_sel_s),
    .up_wr (up_wr_s),
    .up_addr (up_addr_s),
    .up_wdata (up_wdata_s),
    .up_rdata (up_rdata),
    .up_ack (up_ack));
endmodule
