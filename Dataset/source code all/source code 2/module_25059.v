`timescale 1ns/100ps
`timescale 1ns/100ps
module up_delay_cntrl (
  delay_clk,
  delay_rst,
  delay_locked,
  up_dld,
  up_dwdata,
  up_drdata,
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
  parameter   IO_WIDTH = 8;
  parameter   IO_BASEADDR = 6'h02;
  input                         delay_clk;
  output                        delay_rst;
  input                         delay_locked;
  output  [(IO_WIDTH-1):0]      up_dld;
  output  [((IO_WIDTH*5)-1):0]  up_dwdata;
  input   [((IO_WIDTH*5)-1):0]  up_drdata;
  input                         up_rstn;
  input                         up_clk;
  input                         up_wreq;
  input   [13:0]                up_waddr;
  input   [31:0]                up_wdata;
  output                        up_wack;
  input                         up_rreq;
  input   [13:0]                up_raddr;
  output  [31:0]                up_rdata;
  output                        up_rack;
  reg                           up_preset = 'd0;
  reg                           up_wack = 'd0;
  reg                           up_rack = 'd0;
  reg     [31:0]                up_rdata = 'd0;
  reg                           up_dlocked_m1 = 'd0;
  reg                           up_dlocked = 'd0;
  reg     [(IO_WIDTH-1):0]      up_dld = 'd0;
  reg     [((IO_WIDTH*5)-1):0]  up_dwdata = 'd0;
  wire                          up_wreq_s;
  wire                          up_rreq_s;
  wire    [ 4:0]                up_rdata_s;
  wire    [(IO_WIDTH-1):0]      up_drdata4_s;
  wire    [(IO_WIDTH-1):0]      up_drdata3_s;
  wire    [(IO_WIDTH-1):0]      up_drdata2_s;
  wire    [(IO_WIDTH-1):0]      up_drdata1_s;
  wire    [(IO_WIDTH-1):0]      up_drdata0_s;
  genvar                        n;
  assign up_wreq_s = (up_waddr[13:8] == IO_BASEADDR) ? up_wreq : 1'b0;
  assign up_rreq_s = (up_raddr[13:8] == IO_BASEADDR) ? up_rreq : 1'b0;
  assign up_rdata_s[4] = | up_drdata4_s;
  assign up_rdata_s[3] = | up_drdata3_s;
  assign up_rdata_s[2] = | up_drdata2_s;
  assign up_rdata_s[1] = | up_drdata1_s;
  assign up_rdata_s[0] = | up_drdata0_s;
  generate
  for (n = 0; n < IO_WIDTH; n = n + 1) begin: g_drd
  assign up_drdata4_s[n] = (up_raddr[7:0] == n) ? up_drdata[((n*5)+4)] : 1'd0;
  assign up_drdata3_s[n] = (up_raddr[7:0] == n) ? up_drdata[((n*5)+3)] : 1'd0;
  assign up_drdata2_s[n] = (up_raddr[7:0] == n) ? up_drdata[((n*5)+2)] : 1'd0;
  assign up_drdata1_s[n] = (up_raddr[7:0] == n) ? up_drdata[((n*5)+1)] : 1'd0;
  assign up_drdata0_s[n] = (up_raddr[7:0] == n) ? up_drdata[((n*5)+0)] : 1'd0;
  end
  endgenerate
  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_preset <= 1'd1;
      up_wack <= 'd0;
      up_rack <= 'd0;
      up_rdata <= 'd0;
      up_dlocked_m1 <= 'd0;
      up_dlocked <= 'd0;
    end else begin
      up_preset <= 1'd0;
      up_wack <= up_wreq_s;
      up_rack <= up_rreq_s;
      if (up_rreq_s == 1'b1) begin
        if (up_dlocked == 1'b0) begin
          up_rdata <= 32'hffffffff;
        end else begin
          up_rdata <= {27'd0, up_rdata_s};
        end
      end else begin
        up_rdata <= 32'd0;
      end
      up_dlocked_m1 <= delay_locked;
      up_dlocked <= up_dlocked_m1;
    end
  end
  generate
  for (n = 0; n < IO_WIDTH; n = n + 1) begin: g_dwr
  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_dld[n] <= 'd0;
      up_dwdata[((n*5)+4):(n*5)] <= 'd0;
    end else begin
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == n)) begin
        up_dld[n] <= 1'd1;
        up_dwdata[((n*5)+4):(n*5)] <= up_wdata[4:0];
      end else begin
        up_dld[n] <= 1'd0;
        up_dwdata[((n*5)+4):(n*5)] <= up_dwdata[((n*5)+4):(n*5)];
      end
    end
  end
  end
  endgenerate
  ad_rst i_delay_rst_reg (
    .preset (up_preset),
    .clk (delay_clk),
    .rst (delay_rst));
endmodule
