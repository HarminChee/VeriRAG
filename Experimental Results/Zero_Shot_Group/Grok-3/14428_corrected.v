module bcode_encoder(
    input           clk,
    input           pps,
    input           rst_n,
    input           clk_reload_n,
    input           utc_cnv_end,
    input   [5:0]   sec_bin,
    input   [5:0]   min_bin,
    input   [4:0]   hour_bin,
    input   [8:0]   day_bin,
    input   [15:0]  year_bin,
    input   [63:0]  tai_sec,
    input   [7:0]   time_zone,
    input   [63:0]  dst_ing,
    input   [63:0]  dst_eng,
    input   [63:0]  leap_occur,
    input           leap_direct,
    input   [3:0]   time_quality,
    input   [16:0]  sec_of_day,
    output          bcode_trans
);

localparam CODE_P            = 4'd7;
localparam CODE_1            = 4'd4;
localparam CODE_0            = 4'd1;
localparam BCD_WAIT_PPS      = 11'b00000000001;
localparam BCD_WAIT_UTC_CNV  = 11'b00000000010;
localparam BCD_CNV_SEC_START = 11'b00000000100;
localparam BCD_CNV_SEC       = 11'b00000001000;
localparam BCD_CNV_MIN_START = 11'b00000010000;
localparam BCD_CNV_MIN       = 11'b00000100000;
localparam BCD_CNV_HOUR_START= 11'b00001000000;
localparam BCD_CNV_HOUR      = 11'b00010000000;
localparam BCD_CNV_DAY_START = 11'b00100000000;
localparam BCD_CNV_DAY       = 11'b01000000000;
localparam BCD_ECC           = 11'b10000000000;
localparam ITR_WAIT_PPS      = 11'b00000000001;
localparam ITR_SEND_SEC      = 11'b00000000010;
localparam ITR_SEND_MIN      = 11'b00000000100;
localparam ITR_SEND_HOUR     = 11'b00000001000;
localparam ITR_SEND_DAY_LOW  = 11'b00000010000;
localparam ITR_SEND_DAY_HIGH = 11'b00000100000;
localparam ITR_SEND_YEAR     = 11'b00001000000;
localparam ITR_SEND_CTRL_FLAG= 11'b00010000000;
localparam ITR_SEND_ECC      = 11'b00100000000;
localparam ITR_SEND_SBS_LOW  = 11'b01000000000;
localparam ITR_SEND_SBS_HIGH = 11'b10000000000;

wire                pps_forward;
wire                clk_100hz;
wire                clk_1khz;
wire                pps_forward_ok;
wire                clk_100hz_ok;
wire                clk_1khz_ok;
reg     [1:0]       pps_catch;
reg     [1:0]       pps_catch_100hz;
reg     [1:0]       pps_catch_1khz;
wire                pps_redge_catch;
wire                pps_redge_catch_100hz;
wire                pps_redge_catch_1khz;
reg     [10:0]      bcd_cnv_state;
reg     [10:0]      bcd_next_state;
reg     [10:0]      itr_cnv_state;
reg     [10:0]      itr_next_state;
reg                 cnv_ok;
reg     [3:0]       bit_count;
wire                bit_count_less_than_9;
reg     [7:0]       sec_bcd;
reg     [7:0]       min_bcd;
reg     [7:0]       hour_bcd;
reg     [11:0]      day_bcd;
reg     [15:0]      year_bcd;
reg     [63:0]      tai_plus_59;
reg signed [7:0]    time_offset;
reg                 dst_flag;
reg                 leap_precast;
reg                 dst_precast;
reg                 time_offset_sign;
reg     [3:0]       time_offset_hour;
reg                 time_offset_half_hour;
reg                 ecc_bit;
wire                is_not_dst_period;
wire    [4:0]       time_offset_complete;
reg     [8:0]       shifter;
reg     [3:0]       rz_code;
reg     [8:0]       bcd_bin_num;
reg                 bcd_start;
reg     [15:0]      l_bcd_bin_num;
reg                 l_bcd_start;
wire                bcd_end;
wire    [11:0]      bcd_rslt;
wire                l_bcd_end;
wire    [19:0]      l_bcd_rslt;
reg     [3:0]       rz_encode_timer;
reg                 bcode_gen;

always @(posedge clk or negedge clk_reload_n) begin
    if (!clk_reload_n) begin
        pps_catch <= 2'b00;
    end else begin
        pps_catch[0] <= pps_forward;
        pps_catch[1] <= pps_catch[0];
    end
end

assign pps_redge_catch = (pps_catch == 2'b01);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bcd_cnv_state <= BCD_WAIT_PPS;
    end else begin
        bcd_cnv_state <= bcd_next_state;
    end
end

always @(*) begin
    case (bcd_cnv_state)
        BCD_WAIT_PPS: begin
            if (pps_redge_catch)
                bcd_next_state = BCD_WAIT_UTC_CNV;
            else
                bcd_next_state = BCD_WAIT_PPS;
        end
        BCD_WAIT_UTC_CNV: begin
            if (utc_cnv_end)
                bcd_next_state = BCD_CNV_SEC_START;
            else
                bcd_next_state = BCD_WAIT_UTC_CNV;
        end
        BCD_CNV_SEC_START:
            bcd_next_state = BCD_CNV_SEC;
        BCD_CNV_SEC: begin
            if (bcd_end)
                bcd_next_state = BCD_CNV_MIN_START;
            else
                bcd_next_state = BCD_CNV_SEC;
        end
        BCD_CNV_MIN_START:
            bcd_next_state = BCD_CNV_MIN;
        BCD_CNV_MIN: begin
            if (bcd_end)
                bcd_next_state = BCD_CNV_HOUR_START;
            else
                bcd_next_state = BCD_CNV_MIN;
        end
        BCD_CNV_HOUR_START:
            bcd_next_state = BCD_CNV_HOUR;
        BCD_CNV_HOUR: begin
            if (bcd_end)
                bcd_next_state = BCD_CNV_DAY_START;
            else
                bcd_next_state = BCD_CNV_HOUR;
        end
        BCD_CNV_DAY_START:
            bcd_next_state = BCD_CNV_DAY;
        BCD_CNV_DAY: begin
            if (bcd_end)
                bcd_next_state = BCD_ECC;
            else
                bcd_next_state = BCD_CNV_DAY;
        end
        BCD_ECC:
            bcd_next_state = BCD_WAIT_PPS;
        default:
            bcd_next_state = BCD_WAIT_PPS;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnv_ok <= 0;
        sec_bcd <= 0;
        min_bcd <= 0;
        hour_bcd <= 0;
        day_bcd <= 0;
        year_bcd <= 0;
        tai_plus_59 <= 0;
        time_offset <= 0;
        dst_flag <= 0;
        leap_precast <= 0;
        dst_precast <= 0;
        time_offset_sign <= 0;
        time_offset_hour <= 0;
        time_offset_half_hour <= 0;
        ecc_bit <= 0;
        bcd_bin_num <= 0;
        bcd_start <= 0;
        l_bcd_bin_num <= 0;
        l_bcd_start <= 0;
    end else begin
        case (bcd_cnv_state)
            BCD_WAIT_PPS: begin
                if (pps_redge_catch)
                    cnv_ok <= 0;
            end
            BCD_WAIT_UTC_CNV: begin
                bcd_bin_num <= {3'b0, sec_bin};
                bcd_start <= 0;
                l_bcd_bin_num <= year_bin;
                l_bcd_start <= 0;
            end
            BCD_CNV_SEC_START: begin
                bcd_start <= 1;
                l_bcd_start <= 1;
                tai_plus_59 <= tai_sec + 64'd59;
                time_offset <= $signed(time_zone) + (is_not_dst_period ? 8'd0 : 8'd2);
                dst_flag <= !is_not_dst_period;
            end
            BCD_CNV_SEC: begin
                bcd_start <= 0;
                l_bcd_start <= 0;
                if (bcd_end)
                    sec_bcd <= bcd_rslt[7:0];
            end
            BCD_CNV_MIN_START: begin
                bcd_bin_num <= {3'b0, min_bin};
                bcd_start <= 1;
                leap_precast <= (tai_plus_59 >= leap_occur && tai_sec <= leap_occur);
                dst_precast <= (tai_plus_59 >= dst_ing && tai_sec <= dst_ing);
                if (time_offset < 0) begin
                    time_offset_sign <= 1;
                    time_offset_hour <= time_offset_complete[4:1];
                    time_offset_half_hour <= time_offset_complete[0];
                end else begin
                    time_offset_sign <= 0;
                    time_offset_hour <= time_offset[4:1];
                    time_offset_half_hour <= time_offset[0];
                end
            end
            BCD_CNV_MIN: begin
                bcd_start <= 0;
                if (bcd_end)
                    min_bcd <= bcd_rslt[7:0];
                if (l_bcd_end)
                    year_bcd <= l_bcd_rslt[15:0];
            end
            BCD_CNV_HOUR_START: begin
                bcd_bin_num <= {4'b0, hour_bin};
                bcd_start <= 1;
            end
            BCD_CNV_HOUR: begin
                bcd_start <= 0;
                if (bcd_end)
                    hour_bcd <= bcd_rslt[7:0];
            end
            BCD_CNV_DAY_START: begin
                bcd_bin_num <= day_bin;
                bcd_start <= 1;
            end
            BCD_CNV_DAY: begin
                bcd_start <= 0;
                if (bcd_end)
                    day_bcd <= bcd_rslt[11:0];
            end
            BCD_ECC: begin
                ecc_bit <= ^{
                    sec_bcd,
                    min_bcd,
                    hour_bcd,
                    day_bcd,
                    year_bcd[7:0],
                    leap_precast,
                    leap_direct,
                    dst_precast,
                    dst_flag,
                    time_offset_sign,
                    time_offset_hour,
                    time_offset_half_hour,
                    time_quality
                };
                cnv_ok <= 1;
            end
        endcase
    end
end

assign is_not_dst_period = (tai_sec < dst_ing || tai_sec > dst_eng);
assign time_offset_complete = (~time_offset[4:0]) + 1;

bin2bcd #(
    .BIN_BITS(9)
) bin2bcd_short (
    .clk(clk),
    .rst(rst_n),
    .start(bcd_start),
    .bin_num_in(bcd_bin_num),
    .bcd_out(bcd_rslt),
    .end_of_cnv(bcd_end)
);

bin2bcd #(
    .BIN_BITS(16)
) bin2bcd_long (
    .clk(clk),
    .rst(rst_n),
    .start(l_bcd_start),
    .bin_num_in(l_bcd_bin_num),
    .bcd_out(l_bcd_rslt),
    .end_of_cnv(l_bcd_end)
);

always @(posedge clk_100hz or negedge clk_reload_n) begin
    if (!clk_reload_n) begin
        pps_catch_100hz <= 2'b00;
    end else begin
        pps_catch_100hz[0] <= pps_forward;
        pps_catch_100hz[1] <= pps_catch_100hz[0];
    end
end

assign pps_redge_catch_100hz = (pps_catch_100hz == 2'b01);

always @(posedge clk_100hz or negedge rst_n) begin
    if (!rst_n) begin
        itr_cnv_state <= ITR_WAIT_PPS;
    end else begin
        itr_cnv_state <= itr_next_state;
    end
end

always @(*) begin
    case (itr_cnv_state)
        ITR_WAIT_PPS: begin
            if (pps_redge_catch_100hz && cnv_ok)
                itr_next_state = ITR_SEND_SEC;
            else
                itr_next_state = ITR_WAIT_PPS;
        end
        ITR_SEND_SEC: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_SEC;
            else
                itr_next_state = ITR_SEND_MIN;
        end
        ITR_SEND_MIN: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_MIN;
            else
                itr_next_state = ITR_SEND_HOUR;
        end
        ITR_SEND_HOUR: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_HOUR;
            else
                itr_next_state = ITR_SEND_DAY_LOW;
        end
        ITR_SEND_DAY_LOW: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_DAY_LOW;
            else
                itr_next_state = ITR_SEND_DAY_HIGH;
        end
        ITR_SEND_DAY_HIGH: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_DAY_HIGH;
            else
                itr_next_state = ITR_SEND_YEAR;
        end
        ITR_SEND_YEAR: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_YEAR;
            else
                itr_next_state = ITR_SEND_CTRL_FLAG;
        end
        ITR_SEND_CTRL_FLAG: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_CTRL_FLAG;
            else
                itr_next_state = ITR_SEND_ECC;
        end
        ITR_SEND_ECC: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_ECC;
            else
                itr_next_state = ITR_SEND_SBS_LOW;
        end
        ITR_SEND_SBS_LOW: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_SBS_LOW;
            else
                itr_next_state = ITR_SEND_SBS_HIGH;
        end
        ITR_SEND_SBS_HIGH: begin
            if (bit_count_less_than_9)
                itr_next_state = ITR_SEND_SBS_HIGH;
            else
                itr_next_state = ITR_WAIT_PPS;
        end
        default:
            itr_next_state = ITR_WAIT_PPS;
    endcase
end

always @(posedge clk_100hz or negedge rst_n) begin
    if (!rst_n) begin
        shifter <= 9'b0;
        bit_count <= 4'd0;
        rz_code <= CODE_P;
    end else begin
        case (itr_cnv_state)
            ITR_WAIT_PPS: begin
                if (pps_redge_catch_100hz && cnv_ok) begin
                    shifter <= {sec_bcd[7:4], 1'b0, sec_bcd[3:0]};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end else begin
                    shifter <= 9'b0;
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_SEC: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= {min_bcd[7:4], 1'b0, min_bcd[3:0]};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_MIN: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= {hour_bcd[7:4], 1'b0, hour_bcd[3:0]};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_HOUR: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= {day_bcd[7:4], 1'b0, day_bcd[3:0]};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_DAY_LOW: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= {5'b0, day_bcd[11:8]};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_DAY_HIGH: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= {year_bcd[7:4], 1'b0, year_bcd[3:0]};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_YEAR: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= {time_offset_hour, time_offset_sign, dst_flag, dst_precast, leap_direct, leap_precast};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_CTRL_FLAG: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= {3'b0, ecc_bit, time_quality, time_offset_half_hour};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_ECC: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= sec_of_day[8:0];
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_SBS_LOW: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= {1'b0, sec_of_day[16:9]};
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
            ITR_SEND_SBS_HIGH: begin
                if (bit_count_less_than_9) begin
                    shifter <= shifter >> 1;
                    bit_count <= bit_count + 1;
                    rz_code <= shifter[0] ? CODE_1 : CODE_0;
                end else begin
                    shifter <= 9'b0;
                    bit_count <= 4'd0;
                    rz_code <= CODE_P;
                end
            end
        endcase
    end
end

assign bit_count_less_than_9 = (bit_count < 9);

always @(posedge clk_1khz or negedge clk_reload_n) begin
    if (!clk_reload_n) begin
        pps_catch_1khz <= 2'b00;
    end else begin
        pps_catch_1khz[0] <= pps_forward;
        pps_catch_1khz[1] <= pps_catch_1khz[0];
    end
end

assign pps_redge_catch_1khz = (pps_catch_1khz == 2'b01);

always @(posedge clk_1khz or negedge rst_n) begin
    if (!rst_n) begin
        rz_encode_timer <= 4'd0;
        bcode_gen <= 0;
    end else begin
        if (pps_redge_catch_1khz) begin
            rz_encode_timer <= 4'd0;
            bcode_gen <= 0;
        end else if (rz_encode_timer < 9) begin
            rz_encode_timer <= rz_encode_timer + 1;
            bcode_gen <= (rz_encode_timer < rz_code);
        end else begin
            rz_encode_timer <= 4'd0;
            bcode_gen <= 0;
        end
    end
end

assign bcode_trans = bcode_gen;

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