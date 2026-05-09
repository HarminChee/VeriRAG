`timescale 1ns/100ps
`timescale 1ns/100ps
module fmcadc2_spi (
  spi_clk,
  spi_adc_csn,
  spi_ext_csn_0,
  spi_ext_csn_1,
  spi_mosi,
  spi_miso,
  spi_adc_sdio,
  spi_ext_sdio);
  input           spi_clk;
  input           spi_adc_csn;
  input           spi_ext_csn_0;
  input           spi_ext_csn_1;
  input           spi_mosi;
  output          spi_miso;
  inout           spi_adc_sdio;
  inout           spi_ext_sdio;
  reg     [ 5:0]  spi_count = 'd0;
  reg             spi_rd_wr_n = 'd0;
  reg             spi_enable = 'd0;
  wire            spi_csn_s;
  wire            spi_enable_s;
  wire            spi_adc_miso_s;
  wire            spi_ext_miso_s;
  assign spi_csn_s = spi_adc_csn & spi_ext_csn_0 & spi_ext_csn_1;
  assign spi_enable_s = spi_enable & ~spi_csn_s;
  always @(posedge spi_clk or posedge spi_csn_s) begin
    if (spi_csn_s == 1'b1) begin
      spi_count <= 6'd0;
      spi_rd_wr_n <= 1'd0;
    end else begin
      spi_count <= spi_count + 1'b1;
      if (spi_count == 6'd0) begin
        spi_rd_wr_n <= spi_mosi;
      end
    end
  end
  always @(negedge spi_clk or posedge spi_csn_s) begin
    if (spi_csn_s == 1'b1) begin
      spi_enable <= 1'b0;
    end else begin
      if (spi_count == 6'd16) begin
        spi_enable <= spi_rd_wr_n;
      end
    end
  end
  assign spi_miso = ((spi_adc_miso_s & ~spi_adc_csn) |
                     (spi_ext_miso_s & ~spi_ext_csn_0) |
                     (spi_ext_miso_s & ~spi_ext_csn_1));
  IOBUF i_iobuf_adc_sdio (
    .T (spi_enable_s),
    .I (spi_mosi),
    .O (spi_adc_miso_s),
    .IO (spi_adc_sdio));
  IOBUF i_iobuf_clk_sdio (
    .T (spi_enable_s),
    .I (spi_mosi),
    .O (spi_ext_miso_s),
    .IO (spi_ext_sdio));
endmodule
