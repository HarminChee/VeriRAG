`timescale 1ns/100ps
module up_adc_common (
  input  wire        test_i,
  output wire        mmcm_rst,
  input  wire        adc_clk,
  output wire        adc_rst,
  output wire        adc_r1_mode,
  output wire        adc_ddr_edgesel,
  output wire        adc_pin_mode,
  input  wire        adc_status,
  input  wire        adc_sync_status,
  input  wire        adc_status_ovf,
  input  wire        adc_status_unf,
  input  wire [31:0] adc_clk_ratio,
  output wire [31:0] adc_start_code,
  output wire        adc_sync,
  input  wire        up_status_pn_err,
  input  wire        up_status_pn_oos,
  input  wire        up_status_or,
  output wire        up_drp_sel,
  output wire        up_drp_wr,
  output wire [11:0] up_drp_addr,
  output wire [15:0] up_drp_wdata,
  input  wire [15:0] up_drp_rdata,
  input  wire        up_drp_ready,
  input  wire        up_drp_locked,
  output wire [ 7:0] up_usr_chanmax,
  input  wire [ 7:0] adc_usr_chanmax,
  input  wire [31:0] up_adc_gpio_in,
  output wire [31:0] up_adc_gpio_out,
  input  wire        up_rstn,
  input  wire        up_clk,
  input  wire        up_wreq,
  input  wire [13:0] up_waddr,
  input  wire [31:0] up_wdata,
  output wire        up_wack,
  input  wire        up_rreq,
  input  wire [13:0] up_raddr,
  output wire [31:0] up_rdata,
  output wire        up_rack
);
  localparam  PCORE_VERSION = 32'h00090062;
  parameter   ID = 0;

  reg             up_core_preset = 'd0;
  reg             up_mmcm_preset = 'd0;
  reg             up_wack = 'd0;
  reg     [31:0]  up_scratch = 'd0;
  reg             up_mmcm_resetn = 'd0;
  reg             up_resetn = 'd0;
  reg             up_adc_r1_mode = 'd0;
  reg             up_adc_ddr_edgesel = 'd0;
  reg             up_adc_pin_mode = 'd0;
  reg             up_drp_sel = 'd0;
  reg             up_drp_wr = 'd0;
  reg             up_drp_status = 'd0;
  reg             up_drp_rwn = 'd0;
  reg     [11:0]  up_drp_addr = 'd0;
  reg     [15:0]  up_drp_wdata = 'd0;
  reg     [15:0]  up_drp_rdata_hold = 'd0;
  reg             up_status_ovf = 'd0;
  reg             up_status_unf = 'd0;
  reg     [ 7:0]  up_usr_chanmax = 'd0;
  reg     [31:0]  up_adc_gpio_out = 'd0;
  reg     [31:0]  up_adc_start_code = 'd0;
  reg             up_adc_sync = 'd0;
  reg             up_rack = 'd0;
  reg     [31:0]  up_rdata = 'd0;

  wire            up_wreq_s;
  wire            up_rreq_s;
  wire            up_status_s;
  wire            up_sync_status_s;
  wire            up_status_ovf_s;
  wire            up_status_unf_s;
  wire            up_cntrl_xfer_done;
  wire    [31:0]  up_adc_clk_count_s;
  wire            dft_adc_rst;
  wire            dft_adc_clk;

  assign up_wreq_s = (up_waddr[13:8] == 6'h00) ? up_wreq : 1'b0;
  assign up_rreq_s = (up_raddr[13:8] == 6'h00) ? up_rreq : 1'b0;
  assign dft_adc_rst = test_i ? ~up_rstn : adc_rst;
  assign dft_adc_clk = test_i ? up_clk : adc_clk;

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_core_preset <= 1'd1;
      up_mmcm_preset <= 1'd1;
      up_wack <= 'd0;
      up_scratch <= 'd0;
      up_mmcm_resetn <= 'd0;
      up_resetn <= 'd0;
      up_adc_r1_mode <= 'd0;
      up_adc_ddr_edgesel <= 'd0;
      up_adc_pin_mode <= 'd0;
      up_drp_sel <= 'd0;
      up_drp_wr <= 'd0;
      up_drp_status <= 'd0;
      up_drp_rwn <= 'd0;
      up_drp_addr <= 'd0;
      up_drp_wdata <= 'd0;
      up_drp_rdata_hold <= 'd0;
      up_status_ovf <= 'd0;
      up_status_unf <= 'd0;
      up_usr_chanmax <= 'd0;
      up_adc_gpio_out <= 'd0;
      up_adc_start_code <= 'd0;
      up_adc_sync <= 'd0;
    end else begin
      up_core_preset <= ~up_resetn;
      up_mmcm_preset <= ~up_mmcm_resetn;
      up_wack <= up_wreq_s;
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h02)) begin
        up_scratch <= up_wdata;
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h10)) begin
        up_mmcm_resetn <= up_wdata[1];
        up_resetn <= up_wdata[0];
      end
      if (up_adc_sync == 1'b1) begin
        if (up_cntrl_xfer_done == 1'b1) begin
          up_adc_sync <= 1'b0;
        end
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h11)) begin
        up_adc_sync <= up_wdata[3];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h11)) begin
        up_adc_r1_mode <= up_wdata[2];
        up_adc_ddr_edgesel <= up_wdata[1];
        up_adc_pin_mode <= up_wdata[0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h1c)) begin
        up_drp_sel <= 1'b1;
        up_drp_wr <= ~up_wdata[28];
      end else begin
        up_drp_sel <= 1'b0;
        up_drp_wr <= 1'b0;
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h1c)) begin
        up_drp_status <= 1'b1;
      end else if (up_drp_ready == 1'b1) begin
        up_drp_status <= 1'b0;
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h1c)) begin
        up_drp_rwn <= up_wdata[28];
        up_drp_addr <= up_wdata[27:16];
        up_drp_wdata <= up_wdata[15:0];
      end
      if (up_drp_ready == 1'b1) begin
        up_drp_rdata_hold <= up_drp_rdata;
      end
      if (up_status_ovf_s == 1'b1) begin
        up_status_ovf <= 1'b1;
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h22)) begin
        up_status_ovf <= up_status_ovf & ~up_wdata[2];
      end
      if (up_status_unf_s == 1'b1) begin
        up_status_unf <= 1'b1;
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h22)) begin
        up_status_unf <= up_status_unf & ~up_wdata[1];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h28)) begin
        up_usr_chanmax <= up_wdata[7:0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h29)) begin
        up_adc_start_code <= up_wdata[31:0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h2f)) begin
        up_adc_gpio_out <= up_wdata;
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
          8'h00: up_rdata <= PCORE_VERSION;
          8'h01: up_rdata <= ID;
          8'h02: up_rdata <= up_scratch;
          8'h10: up_rdata <= {30'd0, up_mmcm_resetn, up_resetn};
          8'h11: up_rdata <= {28'd0, up_adc_sync, up_adc_r1_mode, up_adc_ddr_edgesel, up_adc_pin_mode};
          8'h15: up_rdata <= up_adc_clk_count_s;
          8'h16: up_rdata <= adc_clk_ratio;
          8'h17: up_rdata <= {28'd0, up_status_pn_err, up_status_pn_oos, up_status_or, up_status_s};
          8'h1a: up_rdata <= {31'd0, up_sync_status_s};
          8'h1c: up_rdata <= {3'd0, up_drp_rwn, up_drp_addr, up_drp_wdata};
          8'h1d: up_rdata <= {14'd0, up_drp_locked, up_drp_status, up_drp_rdata_hold};
          8'h22: up_rdata <= {29'd0, up_status_ovf, up_status_unf, 1'b0};
          8'h23: up_rdata <= 32'd8;
          8'h28: up_rdata <= {24'd0, adc_usr_chanmax};
          8'h29: up_rdata <= up_adc_start_code;
          8'h2e: up_rdata <= up_adc_gpio_in;
          8'h2f: up_rdata <= up_adc_gpio_out;
          default: up_rdata <= 0;
        endcase
      end else begin
        up_rdata <= 32'd0;
      end
    end
  end

  ad_rst i_mmcm_rst_reg (.preset(up_mmcm_preset), .clk(up_clk),  .rst(mmcm_rst));
  ad_rst i_core_rst_reg (.preset(up_core_preset), .clk(dft_adc_clk), .rst(adc_rst));

  up_xfer_cntrl #(.DATA_WIDTH(36)) i_xfer_cntrl (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_cntrl ({ up_adc_sync,
                      up_adc_start_code,
                      up_adc_r1_mode,
                      up_adc_ddr_edgesel,
                      up_adc_pin_mode}),
    .up_xfer_done (up_cntrl_xfer_done),
    .d_rst (dft_adc_rst),
    .d_clk (dft_adc_clk),
    .d_data_cntrl ({  adc_sync,
                      adc_start_code,
                      adc_r1_mode,
                      adc_ddr_edgesel,
                      adc_pin_mode}));

  up_xfer_status #(.DATA_WIDTH(4)) i_xfer_status (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_status ({up_sync_status_s,
                      up_status_s,
                      up_status_ovf_s,
                      up_status_unf_s}),
    .d_rst (dft_adc_rst),
    .d_clk (dft_adc_clk),
    .d_data_status ({ adc_sync_status,
                      adc_status,
                      adc_status_ovf,
                      adc_status_unf}));

  up_clock_mon i_clock_mon (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_d_count (up_adc_clk_count_s),
    .d_rst (dft_adc_rst),
    .d_clk (dft_adc_clk));
endmodule