module ad_ss_444to422 (
  clk,
  s444_de,
  s444_sync,
  s444_data,
  s422_sync,
  s422_data);
  parameter   Cr_Cb_N = 0;
  parameter   DELAY_DATA_WIDTH = 16;
  localparam  DW = DELAY_DATA_WIDTH - 1;
  input           clk;
  input           s444_de;
  input   [DW:0]  s444_sync;
  input   [23:0]  s444_data;
  output  [DW:0]  s422_sync;
  output  [15:0]  s422_data;
  reg             s444_de_d = 'd0;
  reg     [DW:0]  s444_sync_d = 'd0;
  reg     [23:0]  s444_data_d = 'd0;
  reg             s444_de_2d = 'd0;
  reg     [DW:0]  s444_sync_2d = 'd0;
  reg     [23:0]  s444_data_2d = 'd0;
  reg             s444_de_3d = 'd0;
  reg     [DW:0]  s444_sync_3d = 'd0;
  reg     [23:0]  s444_data_3d = 'd0;
  reg     [ 7:0]  cr = 'd0;
  reg     [ 7:0]  cb = 'd0;
  reg             cr_cb_sel = 'd0;
  reg     [DW:0]  s422_sync = 'd0;
  reg     [15:0]  s422_data = 'd0;
  wire    [ 9:0]  cr_s;
  wire    [ 9:0]  cb_s;
  always @(posedge clk) begin
    s444_de_d <= s444_de;
    s444_sync_d <= s444_sync;
    if (s444_de == 1'b1) begin
      s444_data_d <= s444_data;
    end
    s444_de_2d <= s444_de_d;
    s444_sync_2d <= s444_sync_d;
    if (s444_de_d == 1'b1) begin
      s444_data_2d <= s444_data_d;
    end
    s444_de_3d <= s444_de_2d;
    s444_sync_3d <= s444_sync_2d;
    if (s444_de_2d == 1'b1) begin
      s444_data_3d <= s444_data_2d;
    end
  end
  assign cr_s = {2'd0, s444_data_d[23:16]} +
                {2'd0, s444_data_3d[23:16]} +
                {1'd0, s444_data_2d[23:16], 1'd0};
  assign cb_s = {2'd0, s444_data_d[7:0]} +
                {2'd0, s444_data_3d[7:0]} +
                {1'd0, s444_data_2d[7:0], 1'd0};
  always @(posedge clk) begin
    cr <= cr_s[9:2];
    cb <= cb_s[9:2];
    if (s444_de_3d == 1'b1) begin
      cr_cb_sel <= ~cr_cb_sel;
    end else begin
      cr_cb_sel <= Cr_Cb_N;
    end
  end
  always @(posedge clk) begin
    s422_sync <= s444_sync_3d;
    if (s444_de_3d == 1'b0) begin
      s422_data <= 'd0;
    end else if (cr_cb_sel == 1'b1) begin
      s422_data <= {cr, s444_data_3d[15:8]};
    end else begin
      s422_data <= {cb, s444_data_3d[15:8]};
    end
  end
endmodule
