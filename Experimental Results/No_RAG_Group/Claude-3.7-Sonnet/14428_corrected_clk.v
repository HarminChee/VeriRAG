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
    input           clk_100hz_in,
    input           clk_1khz_in,
    output          bcode_trans
);

// ... existing code ...

// Replace internal clock generators with external clock inputs
wire clk_100hz = clk_100hz_in;
wire clk_1khz = clk_1khz_in;
wire pps_forward = pps;
wire pps_forward_ok = 1'b1;
wire clk_100hz_ok = 1'b1; 
wire clk_1khz_ok = 1'b1;

// ... existing code ...

// Remove clock generator modules
endmodule