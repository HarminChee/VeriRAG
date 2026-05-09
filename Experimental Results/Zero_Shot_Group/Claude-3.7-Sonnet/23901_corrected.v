`timescale 1ns/100ps
module up_axis_dma_tx (
  dac_clk,
  dac_rst,
  dma_clk,
  dma_rst,
  dma_frmcnt,
  dma_ovf,
  dma_unf,
  up_rstn,
  up_clk,
  up_wreq,
  up_waddr,
  up_wdata,
  up_wack,
  up_rreq,
  up_raddr,
  up_rdata,
  up_rack);
  localparam  PCORE_VERSION = 32'h00050062;
  parameter   ID = 0;
  input           dac_clk;
  output          dac_rst;
  input           dma_clk;
  output          dma_rst;
  output  [31:0]  dma_frmcnt;
  input           dma_ovf;
  input           dma_unf;
  input           up_rstn;
  input           up_clk;
  input           up_wreq;
  input   [13:0]  up_waddr;
  input   [31:0]  up_wdata;
  output          up_wack;
  input           up_rreq;
  input   [13:0]  up_raddr;
  output  [31:0]  up_rdata;
  output          up_rack;
  reg             up_preset = 1'b0;
  reg             up_wack = 1'b0;
  reg     [31:0]  up_scratch = 32'd0;
  reg             up_resetn = 1'b0;
  reg     [31:0]  up_dma_frmcnt = 32'd0;
  reg             up_dma_ovf = 1'b0;
  reg             up_dma_unf = 1'b0;
  reg             up_rack = 1'b0;
  reg     [31:0]  up_rdata = 32'd0;
  wire            up_wreq_s;
  wire            up_rreq_s;
  reg             up_dma_ovf_s;
  reg             up_dma_unf_s;
  assign up_wreq_s = (up_waddr[13:8] == 6'h10) ? up_wreq : 1'b0;
  assign up_rreq_s = (up_raddr[13:8] == 6'h10) ? up_rreq : 1'b0;
  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_preset <= 1'b1;
      up_wack <= 1'b0;
      up_scratch <= 32'd0;
      up_resetn <= 1'b0;
      up_dma_frmcnt <= 32'd0;
      up_dma_ovf <= 1'b0;
      up_dma_unf <= 1'b0;
    end else begin
      up_preset <= 1'b0;
      up_wack <= up_wreq_s;
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h02)) begin
        up_scratch <= up_wdata;
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h10)) begin
        up_resetn <= up_wdata[0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h21)) begin
        up_dma_frmcnt <= up_wdata;
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h22)) begin
        up_dma_ovf <= up_dma_ovf & ~up_wdata[1];
        up_dma_unf <= up_dma_unf & ~up_wdata[0];
      end
    end
  end
  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_rack <= 1'b0;
      up_rdata <= 32'd0;
    end else begin
      up_rack <= up_rreq_s;
      if (up_rreq_s == 1'b1) begin
        case (up_raddr[7:0])
          8'h00: up_rdata <= PCORE_VERSION;
          8'h01: up_rdata <= ID;
          8'h02: up_rdata <= up_scratch;
          8'h10: up_rdata <= {31'd0, up_resetn};
          8'h21: up_rdata <= up_dma_frmcnt;
          8'h22: up_rdata <= {30'd0, up_dma_ovf, up_dma_unf};
          default: up_rdata <= 0;
        endcase
      end
    end
  end
  always @(posedge dma_clk or negedge up_rstn) begin
    if (!up_rstn) begin
      up_dma_ovf_s <= 1'b0;
      up_dma_unf_s <= 1'b0;
    end else begin
      up_dma_ovf_s <= dma_ovf;
      up_dma_unf_s <= dma_unf;
    end
  end
  ad_rst i_dac_rst_reg (
    .preset(up_preset),
    .clk(dac_clk),
    .rst(dac_rst)
  );
  ad_rst i_dma_rst_reg (
    .preset(up_preset),
    .clk(dma_clk),
    .rst(dma_rst)
  );
  up_xfer_cntrl #(
    .DATA_WIDTH(32)
  ) i_dma_xfer_cntrl (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_cntrl (up_dma_frmcnt),
    .d_rst (dma_rst),
    .d_clk (dma_clk),
    .d_data_cntrl (dma_frmcnt)
  );
endmodule

module ad_rst (
  input   preset,
  input   clk,
  output  rst
);
  reg rst_reg = 0;
  always @(posedge clk or posedge preset) begin
    if (preset)
      rst_reg <= 1'b1;
    else
      rst_reg <= 1'b0;
  end
  assign rst = rst_reg;
endmodule

module up_xfer_cntrl (
  input           up_rstn,
  input           up_clk,
  input   [31:0]  up_data_cntrl,
  input           d_rst,
  input           d_clk,
  output  [31:0]  d_data_cntrl
);
  parameter DATA_WIDTH = 32;
  reg     [31:0]  d_data_cntrl_reg = 0;
  always @(posedge d_clk or negedge up_rstn) begin
    if (!up_rstn)
      d_data_cntrl_reg <= 32'd0;
    else
      d_data_cntrl_reg <= up_data_cntrl;
  end
  assign d_data_cntrl = d_data_cntrl_reg;
endmodule