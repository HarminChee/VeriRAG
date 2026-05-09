`timescale 1ns/100ps
`timescale 1ns/100ps
module up_dac_common (
  mmcm_rst,
  dac_clk,
  dac_rst,
  dac_sync,
  dac_frame,
  dac_par_type,
  dac_par_enb,
  dac_r1_mode,
  dac_datafmt,
  dac_datarate,
  dac_status,
  dac_status_ovf,
  dac_status_unf,
  dac_clk_ratio,
  up_drp_sel,
  up_drp_wr,
  up_drp_addr,
  up_drp_wdata,
  up_drp_rdata,
  up_drp_ready,
  up_drp_locked,
  up_usr_chanmax,
  dac_usr_chanmax,
  up_dac_gpio_in,
  up_dac_gpio_out,
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

  localparam  PCORE_VERSION = 32'h00080062;
  parameter   ID = 0;

  output          mmcm_rst;
  input           dac_clk;
  output          dac_rst;
  output          dac_sync;
  output          dac_frame;
  output          dac_par_type;
  output          dac_par_enb;
  output          dac_r1_mode;
  output          dac_datafmt;
  output  [ 7:0]  dac_datarate;
  input           dac_status;
  input           dac_status_ovf;
  input           dac_status_unf;
  input   [31:0]  dac_clk_ratio;
  output          up_drp_sel;
  output          up_drp_wr;
  output  [11:0]  up_drp_addr;
  output  [15:0]  up_drp_wdata;
  input   [15:0]  up_drp_rdata;
  input           up_drp_ready;
  input           up_drp_locked;
  output  [ 7:0]  up_usr_chanmax;
  input   [ 7:0]  dac_usr_chanmax;
  input   [31:0]  up_dac_gpio_in;
  output  [31:0]  up_dac_gpio_out;
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

  reg             up_core_preset = 'd0;
  reg             up_mmcm_preset = 'd0;
  reg             up_wack = 'd0;
  reg     [31:0]  up_scratch = 'd0;
  reg             up_mmcm_resetn = 'd0;
  reg             up_resetn = 'd0;
  reg             up_dac_sync = 'd0;
  reg             up_dac_par_type = 'd0;
  reg             up_dac_par_enb = 'd0;
  reg             up_dac_r1_mode = 'd0;
  reg             up_dac_datafmt = 'd0;
  reg     [ 7:0]  up_dac_datarate = 'd0;
  reg             up_dac_frame = 'd0;
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
  reg     [31:0]  up_dac_gpio_out = 'd0;
  reg             up_rack = 'd0;
  reg     [31:0]  up_rdata = 'd0;
  reg             dac_sync_d = 'd0;
  reg             dac_sync_2d = 'd0;
  reg     [ 5:0]  dac_sync_count = 'd0;
  reg             dac_sync = 'd0;
  reg             dac_frame_d = 'd0;
  reg             dac_frame_2d = 'd0;
  reg             dac_frame = 'd0;

  wire            up_wreq_s;
  wire            up_rreq_s;
  wire            up_xfer_done_s;
  wire            up_status_s;
  wire            up_status_ovf_s;
  wire            up_status_unf_s;
  wire            dac_sync_s;
  wire            dac_frame_s;
  wire    [31:0]  up_dac_clk_count_s;

  assign up_wreq_s = (up_waddr[13:8] == 6'h10) ? up_wreq : 1'b0;
  assign up_rreq_s = (up_raddr[13:8] == 6'h10) ? up_rreq : 1'b0;

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_core_preset <= 1'd1;
      up_mmcm_preset <= 1'd1;
      up_wack <= 'd0;
      up_scratch <= 'd0;
      up_mmcm_resetn <= 'd0;
      up_resetn <= 'd0;
      up_dac_sync <= 'd0;
      up_dac_par_type <= 'd0;
      up_dac_par_enb <= 'd0;
      up_dac_r1_mode <= 'd0;
      up_dac_datafmt <= 'd0;
      up_dac_datarate <= 'd0;
      up_dac_frame <= 'd0;
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
      up_dac_gpio_out <= 'd0;
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
      if (up_dac_sync == 1'b1) begin
        if (up_xfer_done_s == 1'b1) begin
          up_dac_sync <= 1'b0;
        end
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h11)) begin
        up_dac_sync <= up_wdata[0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h12)) begin
        up_dac_par_type <= up_wdata[7];
        up_dac_par_enb <= up_wdata[6];
        up_dac_r1_mode <= up_wdata[5];
        up_dac_datafmt <= up_wdata[4];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h13)) begin
        up_dac_datarate <= up_wdata[7:0];
      end
      if (up_dac_frame == 1'b1) begin
        if (up_xfer_done_s == 1'b1) begin
          up_dac_frame <= 1'b0;
        end
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h14)) begin
        up_dac_frame <= up_wdata[0];
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
        up_status_ovf <= up_status_ovf & ~up_wdata[1];
      end
      if (up_status_unf_s == 1'b1) begin
        up_status_unf <= 1'b1;
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h22)) begin
        up_status_unf <= up_status_unf & ~up_wdata[0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h28)) begin
        up_usr_chanmax <= up_wdata[7:0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h2f)) begin
        up_dac_gpio_out <= up_wdata;
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
          8'h11: up_rdata <= {31'd0, up_dac_sync};
          8'h12: up_rdata <= {24'd0, up_dac_par_type, up_dac_par_enb, up_dac_r1_mode,
                              up_dac_datafmt, 4'd0};
          8'h13: up_rdata <= {24'd0, up_dac_datarate};
          8'h14: up_rdata <= {31'd0, up_dac_frame};
          8'h15: up_rdata <= up_dac_clk_count_s;
          8'h16: up_rdata <= dac_clk_ratio;
          8'h17: up_rdata <= {31'd0, up_status_s};
          8'h1c: up_rdata <= {3'd0, up_drp_rwn, up_drp_addr, up_drp_wdata};
          8'h1d: up_rdata <= {14'd0, up_drp_locked, up_drp_status, up_drp_rdata_hold};
          8'h22: up_rdata <= {30'd0, up_status_ovf, up_status_unf};
          8'h28: up_rdata <= {24'd0, dac_usr_chanmax};
          8'h2e: up_rdata <= up_dac_gpio_in;
          8'h2f: up_rdata <= up_dac_gpio_out;
          default: up_rdata <= 0;
        endcase
      end else begin
        up_rdata <= 32'd0;
      end
    end
  end

  ad_rst i_mmcm_rst_reg (
    .preset(up_mmcm_preset),
    .clk(up_clk),
    .rst(mmcm_rst));

  ad_rst i_core_rst_reg (
    .preset(up_core_preset),
    .clk(dac_clk),
    .rst(dac_rst));

  up_xfer_cntrl #(.DATA_WIDTH(14)) i_xfer_cntrl (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_cntrl ({ up_dac_sync,
                      up_dac_frame,
                      up_dac_par_type,
                      up_dac_par_enb,
                      up_dac_r1_mode,
                      up_dac_datafmt,
                      up_dac_datarate}),
    .up_xfer_done (up_xfer_done_s),
    .d_rst (dac_rst),
    .d_clk (dac_clk),
    .d_data_cntrl ({  dac_sync_s,
                      dac_frame_s,
                      dac_par_type,
                      dac_par_enb,
                      dac_r1_mode,
                      dac_datafmt,
                      dac_datarate}));

  up_xfer_status #(.DATA_WIDTH(3)) i_xfer_status (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_status ({up_status_s,
                      up_status_ovf_s,
                      up_status_unf_s}),
    .d_rst (dac_rst),
    .d_clk (dac_clk),
    .d_data_status ({ dac_status,
                      dac_status_ovf,
                      dac_status_unf}));

  always @(posedge dac_clk) begin
    dac_sync_d <= dac_sync_s;
    dac_sync_2d <= dac_sync_d;
    if (dac_sync_count[5] == 1'b1) begin
      dac_sync_count <= dac_sync_count + 1'b1;
    end else if ((dac_sync_d == 1'b1) && (dac_sync_2d == 1'b0)) begin
      dac_sync_count <= 6'h20;
    end
    dac_sync <= dac_sync_count[5];
    dac_frame_d <= dac_frame_s;
    dac_frame_2d <= dac_frame_d;
    dac_frame <= dac_frame_d & ~dac_frame_2d;
  end

  up_clock_mon i_clock_mon (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_d_count (up_dac_clk_count_s),
    .d_rst (dac_rst),
    .d_clk (dac_clk));

endmodule