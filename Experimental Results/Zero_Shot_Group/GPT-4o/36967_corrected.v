module sht1x_sensor(
    input rsi_MRST_reset,
    input csi_MCLK_clk,
    input [31:0] avs_ctrl_writedata,
    output reg [31:0] avs_ctrl_readdata,
    input [3:0] avs_ctrl_byteenable,
    input [2:0] avs_ctrl_address,
    input avs_ctrl_write,
    input avs_ctrl_read,
    output avs_ctrl_waitrequest,
    output sck,
    output dir,
    inout sda
);

reg [31:0] write_data;
reg [15:0] temperature;
reg [15:0] moisture;
wire data_ready;
assign avs_ctrl_waitrequest = 0;

always @(posedge csi_MCLK_clk or posedge rsi_MRST_reset) begin
    if (rsi_MRST_reset) begin
        avs_ctrl_readdata <= 0;
    end else if (avs_ctrl_write) begin
        if (avs_ctrl_address == 0)
            write_data <= avs_ctrl_writedata;
    end else begin
        case (avs_ctrl_address)
            0: avs_ctrl_readdata <= 32;
            1: avs_ctrl_readdata <= 32'hEA680003;
            2: avs_ctrl_readdata <= {16'd0, temperature};
            3: avs_ctrl_readdata <= {16'd0, moisture};
            4: avs_ctrl_readdata <= {31'd0, data_ready};
            default: avs_ctrl_readdata <= 0;
        endcase
    end
end

reg [31:0] temp;
always @(posedge csi_MCLK_clk) begin
    temp <= temp + 32'd64585974 / 4 / 4 / 2;
end

assign sck = temp[31];

parameter dir_out = 1'b1;
parameter dir_in = 1'b0;

reg dir_r;
reg sda_r;
reg sck_r;
wire sda_in;

assign sda_in = sda;
assign sda = dir_r ? sda_r : 1'bz;
assign dir = dir_r;

reg [14:0] state, next_state;
reg [15:0] measure_date;
reg [7:0] crc;
reg temp_moist;

always @(posedge sck) begin
    if (rsi_MRST_reset) begin
        state <= 0;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        0: begin
            next_state = 1;
            sck_r = 1'b1;
            sda_r = 1'b1;
            dir_r = dir_out;
        end
        1: begin
            next_state = 2;
            sck_r = 1'b1;
            sda_r = 1'b0;
            dir_r = dir_out;
        end
        2: begin
            next_state = 3;
            sck_r = 1'b0;
            sda_r = 1'b0;
            dir_r = dir_out;
        end
        3: begin
            next_state = 4;
            sck_r = 1'b1;
            sda_r = 1'b0;
            dir_r = dir_out;
        end
        4: begin
            next_state = 5;
            sck_r = 1'b1;
            sda_r = 1'b1;
            dir_r = dir_out;
        end
        5: begin
            next_state = 6;
            sck_r = 1'b0;
            sda_r = 1'b1;
            dir_r = dir_out;
        end
        6: begin
            next_state = 7;
            sck_r = 1'b0;
            sda_r = 1'b1;
            dir_r = dir_out;
        end
        7: begin
            next_state = 8;
            sck_r = 1'b0;
            sda_r = 1'b0;
            dir_r = dir_out;
        end
        8: begin
            next_state = 9;
            sck_r = !sck;
            sda_r = temp_moist ? 5'b00101 : 5'b00011;
            dir_r = dir_out;
        end
        9: begin
            next_state = 10;
            sck_r = !sck;
            sda_r = 1'b0;
            dir_r = dir_out;
        end
        10: begin
            next_state = 11;
            sck_r = !sck;
            sda_r = 1'b1;
            dir_r = dir_out;
        end
        11: begin
            next_state = 12;
            sck_r = !sck;
            sda_r = 1'b1;
            dir_r = dir_out;
        end
        12: begin
            next_state = 13;
            sck_r = !sck;
            sda_r = 1'b0;
            dir_r = dir_out;
        end
        13: begin
            next_state = 14;
            sck_r = !sck;
            sda_r = 1'b1;
            dir_r = dir_out;
        end
        14: begin
            next_state = 15;
            sck_r = !sck;
            sda_r = 1'b0;
            dir_r = dir_out;
        end
        15: begin
            next_state = 16;
            sck_r = !sck;
            sda_r = 1'b1;
            dir_r = dir_out;
        end
        16: begin
            next_state = 17;
            sck_r = !sck;
            dir_r = dir_in;
        end
        17: begin
            next_state = 18;
            sck_r = !sck;
            if (sda_in) next_state = 0;
        end
        18: begin
            next_state = 19;
            sck_r = !sck;
        end
        19: begin
            next_state = 20;
            sck_r = !sck;
        end
        20: begin
            next_state = 21;
            sck_r = !sck;
        end
        21: begin
            next_state = 22;
            sck_r = !sck;
        end
        22: begin
            next_state = 23;
            sck_r = !sck;
        end
        23: begin
            next_state = 24;
            sck_r = !sck;
        end
        24: begin
            next_state = 25;
            sck_r = !sck;
        end
        25: begin
            next_state = 26;
            sck_r = !sck;
        end
        26: begin
            next_state = 27;
            sck_r = !sck;
        end
        27: begin
            next_state = 28;
            sck_r = !sck;
        end
        28: begin
            next_state = 29;
            sck_r = !sck;
        end
        29: begin
            next_state = 30;
            sck_r = !sck;
        end
        30: begin
            next_state = 31;
            sck_r = !sck;
        end
        31: begin
            next_state = 32;
            sck_r = !sck;
        end
        32: begin
            next_state = 33;
            sck_r = !sck;
        end
        33: begin
            next_state = 34;
            sck_r = !sck;
        end
        34: begin
            next_state = 0;
            if (temp_moist == 0)
                temperature <= measure_date;
            else
                moisture <= measure_date;
            temp_moist <= ~temp_moist;
        end
        default: begin
            next_state = 0;
        end
    endcase
end

endmodule