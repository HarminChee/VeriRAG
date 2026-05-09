module bcode_encoder(
    input           clk,
    input           pps,
    input           rst_n,
    input           clk_reload_n,
    input           utc_cnv_end,
    input   [5 : 0] sec_bin,
    input   [5 : 0] min_bin,
    input   [4 : 0] hour_bin,
    input   [8 : 0] day_bin,
    input   [15: 0] year_bin,
    input   [63: 0] tai_sec,
    input   [7 : 0] time_zone,
    input   [63: 0] dst_ing,
    input   [63: 0] dst_eng,
    input   [63: 0] leap_occur,
    input           leap_direct,
    input   [3 : 0] time_quality,
    input   [16: 0] sec_of_day,
    output          bcode_trans
);

// 修复点：以下模块实例 bin2bcd 使用了错误的端口名 `end_of_cnv`，应为 `end_of_conv`
// 修复点：信号 l_bcd_rslt 为 20 位，但 year_bcd 是 8 位，需截断赋值

// ... 保持原始代码不变直到以下部分 ...

bin2bcd #(
    .BIN_BITS(9)
) bin2bcd_short (
    .clk(clk),
    .rst(rst_n),
    .start(bcd_start),
    .bin_num_in(bcd_bin_num),
    .bcd_out(bcd_rslt),
    .end_of_conv(bcd_end)
);

bin2bcd #(
    .BIN_BITS(16)
) bin2bcd_long (
    .clk(clk),
    .rst(rst_n),
    .start(l_bcd_start),
    .bin_num_in(l_bcd_bin_num),
    .bcd_out(l_bcd_rslt),
    .end_of_conv(l_bcd_end)
);

// ... 在 BCD_CNV_MIN 状态中赋值时添加截断 ...

BCD_CNV_MIN : begin
    bcd_start <= 0;
    min_bcd <= bcd_rslt;
    year_bcd <= l_bcd_rslt[7:0]; // 添加截断，避免位宽不匹配
end

// ... 其余代码保持不变 ...

endmodule