`timescale 1ns/100ps
`timescale 1ns/100ps
module up_pmod (
  pmod_clk,
  pmod_rst,
  pmod_signal_freq,
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
  localparam      PCORE_VERSION = 32'h00010001;
  parameter       PCORE_ID = 0;
  input           pmod_clk;
  output          pmod_rst;
  input   [31:0]  pmod_signal_freq;
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
  reg             up_wack = 'd0;
  reg     [31:0]  up_scratch = 'd0;
  reg             up_resetn = 'd0;
  reg             up_rack = 'd0;
  reg     [31:0]  up_rdata = 'd0;
  wire    [31:0]  up_pmod_signal_freq_s;
  wire            up_wreq_s;
  wire            up_rreq_s;
  assign up_wreq_s   = (up_waddr[13:8] == 6'h00) ? up_wreq : 1'b0;
  assign up_rreq_s   = (up_raddr[13:8] == 6'h00) ? up_rreq : 1'b0;
  assign up_preset_s = ~up_resetn;
  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_wack <= 'd0;
      up_scratch <= 'd0;
      up_resetn <= 'd0;
    end else begin
      up_wack <= up_wreq_s;
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h02)) begin
        up_scratch <= up_wdata;
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h10)) begin
        up_resetn <= up_wdata[0];
      end
    end
  end
  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_rack <= 'd0;
      up_rdata <= 'd0;
    end else begin
      up_rack <= up_rreq_s;
      if (up_rreq_s == 1'b1) begin
        case (up_raddr[7:0])
          8'h00:  up_rdata <= PCORE_VERSION;
          8'h01:  up_rdata <= PCORE_ID;
          8'h02:  up_rdata <= up_scratch;
          8'h03:  up_rdata <= up_pmod_signal_freq_s;
          8'h10:  up_rdata <= up_resetn;
          default: up_rdata <= 0;
        endcase
      end else begin
        up_rdata <= 32'd0;
      end
    end
  end
  ad_rst i_adc_rst_reg    (.preset(up_preset_s),      .clk(pmod_clk),    .rst(pmod_rst));
  up_xfer_status #(.DATA_WIDTH(32)) i_pmod_xfer_status (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_status (up_pmod_signal_freq_s),
    .d_rst (pmod_rst),
    .d_clk (pmod_clk),
    .d_data_status (pmod_signal_freq));
endmodule
