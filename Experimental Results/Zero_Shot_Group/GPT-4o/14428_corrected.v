module bcode_encoder (
  input         clk,
  input         pps,
  input         rst_n,
  input         clk_reload_n,
  input         utc_cnv_end,
  input  [5:0]  sec_bin,
  input  [5:0]  min_bin,
  input  [4:0]  hour_bin,
  input  [8:0]  day_bin,
  input  [15:0] year_bin,
  input  [63:0] tai_sec,
  input  [7:0]  time_zone,
  input  [63:0] dst_ing,
  input  [63:0] dst_eng,
  input  [63:0] leap_occur,
  input         leap_direct,
  input  [3:0]  time_quality,
  input  [16:0] sec_of_day,
  output        bcode_trans
);

localparam CODE_P               = 4'd7;
localparam CODE_1               = 4'd4;
localparam CODE_0               = 4'd1;

localparam BCD_WAIT_PPS         = 11'b00000000001;
localparam BCD_WAIT_UTC_CNV     = 11'b00000000010;
localparam BCD_CNV_SEC_START    = 11'b00000000100;
localparam BCD_CNV_SEC          = 11'b00000001000;
localparam BCD_CNV_MIN_START    = 11'b00000010000;
localparam BCD_CNV_MIN          = 11'b00000100000;
localparam BCD_CNV_HOUR_START   = 11'b00001000000;
localparam BCD_CNV_HOUR         = 11'b00010000000;
localparam BCD_CNV_DAY_START    = 11'b00100000000;
localparam BCD_CNV_DAY          = 11'b01000000000;
localparam BCD_ECC              = 11'b10000000000;

// 内部信号定义
reg [3:0] rz_encode_timer;
reg bcode_gen;

// 示例编码逻辑
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rz_encode_timer <= 4'd0;
    bcode_gen <= 1'b0;
  end else begin
    if (rz_encode_timer < 4'd9)
      rz_encode_timer <= rz_encode_timer + 1;
    else
      rz_encode_timer <= 0;
  end
end

assign bcode_trans = bcode_gen;

// 三个时钟同步器实例
clk_synchronizer #(
  .SYSCLK_FREQ_HZ(64'd100_000_000),
  .PPS_HIGH_LEVEL_US(64'd1_000),
  .GENCLK_FREQ_HZ(1),
  .FORWARD_OFFSET_CLK(1)
) pps_forward_generator (
  .clk(clk),
  .rst_n(clk_reload_n),
  .pps_in(pps),
  .sync_clk_out(pps_forward),
  .clk_sync_ok_out(pps_forward_ok)
);

clk_synchronizer #(
  .SYSCLK_FREQ_HZ(64'd100_000_000),
  .PPS_HIGH_LEVEL_US(64'd1_000),
  .GENCLK_FREQ_HZ(100),
  .FORWARD_OFFSET_CLK(0)
) synced_100hz_generator (
  .clk(clk),
  .rst_n(clk_reload_n),
  .pps_in(pps),
  .sync_clk_out(clk_100hz),
  .clk_sync_ok_out(clk_100hz_ok)
);

clk_synchronizer #(
  .SYSCLK_FREQ_HZ(64'd100_000_000),
  .PPS_HIGH_LEVEL_US(64'd100),
  .GENCLK_FREQ_HZ(1000),
  .FORWARD_OFFSET_CLK(0)
) synced_1khz_generator (
  .clk(clk),
  .rst_n(clk_reload_n),
  .pps_in(pps),
  .sync_clk_out(clk_1khz),
  .clk_sync_ok_out(clk_1khz_ok)
);

endmodule
