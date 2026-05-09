`timescale 1ns/100ps
`timescale 1ns/100ps
module up_xfer_cntrl (
  up_rstn,
  up_clk,
  up_data_cntrl,
  up_xfer_done,
  d_rst,
  d_clk,
  d_data_cntrl);
  parameter     DATA_WIDTH = 8;
  localparam    DW = DATA_WIDTH - 1;
  input           up_rstn;
  input           up_clk;
  input   [DW:0]  up_data_cntrl;
  output          up_xfer_done;
  input           d_rst;
  input           d_clk;
  output  [DW:0]  d_data_cntrl;
  reg             up_xfer_state_m1 = 'd0;
  reg             up_xfer_state_m2 = 'd0;
  reg             up_xfer_state = 'd0;
  reg     [ 5:0]  up_xfer_count = 'd0;
  reg             up_xfer_done = 'd0;
  reg             up_xfer_toggle = 'd0;
  reg     [DW:0]  up_xfer_data = 'd0;
  reg             d_xfer_toggle_m1 = 'd0;
  reg             d_xfer_toggle_m2 = 'd0;
  reg             d_xfer_toggle_m3 = 'd0;
  reg             d_xfer_toggle = 'd0;
  reg     [DW:0]  d_data_cntrl = 'd0;
  wire            up_xfer_enable_s;
  wire            d_xfer_toggle_s;
  assign up_xfer_enable_s = up_xfer_state ^ up_xfer_toggle;
  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 1'b0) begin
      up_xfer_state_m1 <= 'd0;
      up_xfer_state_m2 <= 'd0;
      up_xfer_state <= 'd0;
      up_xfer_count <= 'd0;
      up_xfer_done <= 'd0;
      up_xfer_toggle <= 'd0;
      up_xfer_data <= 'd0;
    end else begin
      up_xfer_state_m1 <= d_xfer_toggle;
      up_xfer_state_m2 <= up_xfer_state_m1;
      up_xfer_state <= up_xfer_state_m2;
      up_xfer_count <= up_xfer_count + 1'd1;
      up_xfer_done <= (up_xfer_count == 6'd1) ? ~up_xfer_enable_s : 1'b0;
      if ((up_xfer_count == 6'd1) && (up_xfer_enable_s == 1'b0)) begin
        up_xfer_toggle <= ~up_xfer_toggle;
        up_xfer_data <= up_data_cntrl;
      end
    end
  end
  assign d_xfer_toggle_s = d_xfer_toggle_m3 ^ d_xfer_toggle_m2;
  always @(posedge d_clk or posedge d_rst) begin
    if (d_rst == 1'b1) begin
      d_xfer_toggle_m1 <= 'd0;
      d_xfer_toggle_m2 <= 'd0;
      d_xfer_toggle_m3 <= 'd0;
      d_xfer_toggle <= 'd0;
      d_data_cntrl <= 'd0;
    end else begin
      d_xfer_toggle_m1 <= up_xfer_toggle;
      d_xfer_toggle_m2 <= d_xfer_toggle_m1;
      d_xfer_toggle_m3 <= d_xfer_toggle_m2;
      d_xfer_toggle <= d_xfer_toggle_m3;
      if (d_xfer_toggle_s == 1'b1) begin
        d_data_cntrl <= up_xfer_data;
      end
    end
  end
endmodule
