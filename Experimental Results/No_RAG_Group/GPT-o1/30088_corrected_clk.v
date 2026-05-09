`timescale 1ns/100ps
module axi_ad9361_dev_if_corrected_clk (
  rx_clk_in_p,
  rx_clk_in_n,
  rx_frame_in_p,
  rx_frame_in_n,
  rx_data_in_p,
  rx_data_in_n,
  tx_clk_out_p,
  tx_clk_out_n,
  tx_frame_out_p,
  tx_frame_out_n,
  tx_data_out_p,
  tx_data_out_n,
  rst,
  clk,
  l_clk,
  adc_valid,
  adc_data,
  adc_status,
  adc_r1_mode,
  adc_ddr_edgesel,
  dac_valid,
  dac_data,
  dac_r1_mode,
  up_clk,
  up_adc_dld,
  up_adc_dwdata,
  up_adc_drdata,
  up_dac_dld,
  up_dac_dwdata,
  up_dac_drdata,
  delay_clk,
  delay_rst,
  delay_locked);

  parameter   PCORE_DEVICE_TYPE = 0;
  parameter   PCORE_DAC_IODELAY_ENABLE = 0;
  parameter   PCORE_IODELAY_GROUP = "dev_if_delay_group";
  localparam  PCORE_7SERIES = 0;
  localparam  PCORE_VIRTEX6 = 1;

  input           rx_clk_in_p;
  input           rx_clk_in_n;
  input           rx_frame_in_p;
  input           rx_frame_in_n;
  input   [ 5:0]  rx_data_in_p;
  input   [ 5:0]  rx_data_in_n;
  output          tx_clk_out_p;
  output          tx_clk_out_n;
  output          tx_frame_out_p;
  output          tx_frame_out_n;
  output  [ 5:0]  tx_data_out_p;
  output  [ 5:0]  tx_data_out_n;
  input           rst;
  input           clk;
  output          l_clk;
  output          adc_valid;
  output  [47:0]  adc_data;
  output          adc_status;
  input           adc_r1_mode;
  input           adc_ddr_edgesel;
  input           dac_valid;
  input   [47:0]  dac_data;
  input           dac_r1_mode;
  input           up_clk;
  input   [ 6:0]  up_adc_dld;
  input   [34:0]  up_adc_dwdata;
  output  [34:0]  up_adc_drdata;
  input   [ 7:0]  up_dac_dld;
  input   [39:0]  up_dac_dwdata;
  output  [39:0]  up_dac_drdata;
  input           delay_clk;
  input           delay_rst;
  output          delay_locked;

  reg     [ 3:0]  rx_frame = 'd0;
  reg     [ 5:0]  rx_data_3 = 'd0;
  reg     [ 5:0]  rx_data_2 = 'd0;
  reg     [ 5:0]  rx_data_1 = 'd0;
  reg     [ 5:0]  rx_data_0 = 'd0;
  reg             rx_error_r2 = 'd0;
  reg             rx_valid_r2 = 'd0;
  reg     [23:0]  rx_data_r2 = 'd0;
  reg             adc_valid = 'd0;
  reg     [47:0]  adc_data = 'd0;
  reg             adc_status = 'd0;
  reg             tx_data_sel = 'd0;
  reg     [47:0]  tx_data = 'd0;
  reg     [ 3:0]  tx_frame = 'd0;
  reg     [ 5:0]  tx_data_0 = 'd0;
  reg     [ 5:0]  tx_data_1 = 'd0;
  reg     [ 5:0]  tx_data_2 = 'd0;
  reg     [ 5:0]  tx_data_3 = 'd0;

  wire    [ 3:0]  rx_frame_inv_s;
  wire            tx_locked_s;
  wire    [ 3:0]  rx_frame_s;
  wire    [ 5:0]  rx_data_0_s;
  wire    [ 5:0]  rx_data_1_s;
  wire    [ 5:0]  rx_data_2_s;
  wire    [ 5:0]  rx_data_3_s;
  wire            rx_locked_s;

  // Ensure l_clk is derived from a primary input.
  assign l_clk = clk;

  assign delay_locked = 1'd1;
  assign rx_frame_inv_s = ~rx_frame;

  always @(posedge l_clk) begin
    rx_frame <= rx_frame_s;
    rx_data_3 <= rx_data_3_s;
    rx_data_2 <= rx_data_2_s;
    rx_data_1 <= rx_data_1_s;
    rx_data_0 <= rx_data_0_s;
    if (rx_frame_inv_s == rx_frame_s) begin
      rx_error_r2 <= 1'b0;
    end else begin
      rx_error_r2 <= 1'b1;
    end
    case (rx_frame)
      4'b1111: begin
        rx_valid_r2 <= 1'b1;
        rx_data_r2[23:12] <= {rx_data_1,   rx_data_3};
        rx_data_r2[11: 0] <= {rx_data_0,   rx_data_2};
      end
      4'b1110: begin
        rx_valid_r2 <= 1'b1;
        rx_data_r2[23:12] <= {rx_data_2,   rx_data_0_s};
        rx_data_r2[11: 0] <= {rx_data_1,   rx_data_3};
      end
      4'b1100: begin
        rx_valid_r2 <= 1'b1;
        rx_data_r2[23:12] <= {rx_data_3,   rx_data_1_s};
        rx_data_r2[11: 0] <= {rx_data_2,   rx_data_0_s};
      end
      4'b1000: begin
        rx_valid_r2 <= 1'b1;
        rx_data_r2[23:12] <= {rx_data_0_s, rx_data_2_s};
        rx_data_r2[11: 0] <= {rx_data_3,   rx_data_1_s};
      end
      4'b0000: begin
        rx_valid_r2 <= 1'b0;
        rx_data_r2[23:12] <= {rx_data_1,   rx_data_3};
        rx_data_r2[11: 0] <= {rx_data_0,   rx_data_2};
      end
      4'b0001: begin
        rx_valid_r2 <= 1'b0;
        rx_data_r2[23:12] <= {rx_data_2,   rx_data_0_s};
        rx_data_r2[11: 0] <= {rx_data_1,   rx_data_3};
      end
      4'b0011: begin
        rx_valid_r2 <= 1'b0;
        rx_data_r2[23:12] <= {rx_data_3,   rx_data_1_s};
        rx_data_r2[11: 0] <= {rx_data_2,   rx_data_0_s};
      end
      4'b0111: begin
        rx_valid_r2 <= 1'b0;
        rx_data_r2[23:12] <= {rx_data_0_s, rx_data_2_s};
        rx_data_r2[11: 0] <= {rx_data_3,   rx_data_1_s};
      end
      default: begin
        rx_valid_r2 <= 1'b0;
        rx_data_r2[23:12] <= 12'd0;
        rx_data_r2[11: 0] <= 12'd0;
      end
    endcase
    if (rx_valid_r2 == 1'b1) begin
      adc_valid <= 1'b0;
      adc_data <= {24'd0, rx_data_r2};
    end else begin
      adc_valid <= 1'b1;
      adc_data <= {rx_data_r2, adc_data[23:0]};
    end
    adc_status <= ~rx_error_r2 & rx_locked_s & tx_locked_s;
  end

  always @(posedge l_clk) begin
    tx_data_sel <= dac_valid;
    tx_data <= dac_data;
    if (tx_data_sel == 1'b1) begin
      tx_frame <= 4'b1111;
      tx_data_0 <= tx_data[11: 6];
      tx_data_1 <= tx_data[23:18];
      tx_data_2 <= tx_data[ 5: 0];
      tx_data_3 <= tx_data[17:12];
    end else begin
      tx_frame <= 4'b0000;
      tx_data_0 <= tx_data[35:30];
      tx_data_1 <= tx_data[47:42];
      tx_data_2 <= tx_data[29:24];
      tx_data_3 <= tx_data[41:36];
    end
  end

  axi_ad9361_alt_lvds_tx i_tx (
    .tx_clk_out_p (tx_clk_out_p),
    .tx_clk_out_n (tx_clk_out_n),
    .tx_frame_out_p (tx_frame_out_p),
    .tx_frame_out_n (tx_frame_out_n),
    .tx_data_out_p (tx_data_out_p),
    .tx_data_out_n (tx_data_out_n),
    .tx_clk (rx_clk_in_p),
    .clk (l_clk),
    .tx_frame (tx_frame),
    .tx_data_0 (tx_data_0),
    .tx_data_1 (tx_data_1),
    .tx_data_2 (tx_data_2),
    .tx_data_3 (tx_data_3),
    .tx_locked (tx_locked_s));

  axi_ad9361_alt_lvds_rx i_rx (
    .rx_clk_in_p (rx_clk_in_p),
    .rx_clk_in_n (rx_clk_in_n),
    .rx_frame_in_p (rx_frame_in_p),
    .rx_frame_in_n (rx_frame_in_n),
    .rx_data_in_p (rx_data_in_p),
    .rx_data_in_n (rx_data_in_n),
    .clk (l_clk),
    .rx_frame (rx_frame_s),
    .rx_data_0 (rx_data_0_s),
    .rx_data_1 (rx_data_1_s),
    .rx_data_2 (rx_data_2_s),
    .rx_data_3 (rx_data_3_s),
    .rx_locked (rx_locked_s));

endmodule