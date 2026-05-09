module i2c_module(
    input clk, 
    input reset_n,
    output reg sda_oe = 1,
    input wire sda_in,
    output reg sda = 1,
    output reg scl_out = 1,
    input [7:0] writedata,
    input write,
    input [2:0] address,
    output reg ready = 1,
    output reg success_out = 0
);

reg [7:0] state_next = 0;

localparam STATE_IDLE = 0;
localparam STATE_ADDRESS_START = 1;
localparam STATE_ADDRESS_START_2 = 8'd111;
localparam STATE_ADDRESS_START_3 = 8'd112;
localparam STATE_ADDRESS_BIT_1 = 2;
localparam STATE_ADDRESS_BIT_2 = 3;
localparam STATE_ADDRESS_BIT_3 = 4;
localparam STATE_ADDRESS_BIT_4 = 5;
localparam STATE_ADDRESS_BIT_5 = 6;
localparam STATE_ADDRESS_BIT_6 = 7;
localparam STATE_ADDRESS_BIT_7 = 8;
localparam STATE_ADDRESS_BIT_8 = 9;
localparam STATE_ADDRESS_ACK = 10;
localparam STATE_TRANSIT_1 = 8'd102;
localparam STATE_REG_BIT_1 = 11;
localparam STATE_REG_BIT_2 = 12;
localparam STATE_REG_BIT_3 = 13;
localparam STATE_REG_BIT_4 = 14;
localparam STATE_REG_BIT_5 = 15;
localparam STATE_REG_BIT_6 = 16;
localparam STATE_REG_BIT_7 = 17;
localparam STATE_REG_BIT_8 = 18;
localparam STATE_REG_ACK = 19;
localparam STATE_TRANSIT_2 = 8'd192;
localparam STATE_DATA_BIT_1 = 20;
localparam STATE_DATA_BIT_2 = 21;
localparam STATE_DATA_BIT_3 = 22;
localparam STATE_DATA_BIT_4 = 23;
localparam STATE_DATA_BIT_5 = 24;
localparam STATE_DATA_BIT_6 = 25;
localparam STATE_DATA_BIT_7 = 26;
localparam STATE_DATA_BIT_8 = 27;
localparam STATE_DATA_ACK = 28;
localparam STATE_STOP = 29;
localparam STATE_STOP_1 = 30;
localparam STATE_STOP_2 = 31;

reg clk_div = 0;
wire clk_div_2;
reg [7:0] divider2 = 0;

always @(posedge clk_div_2) begin
    clk_div <= ~clk_div;
end

always @(posedge clk) begin
    divider2 <= divider2 + 1'b1;
end

assign clk_div_2 = divider2[7];

reg [7:0] control_reg = 0;
reg [7:0] slave_address = 0;
reg [7:0] slave_reg_address = 0;
reg [7:0] slave_data_1 = 0;
reg [7:0] slave_data_2 = 0;

always @(posedge clk) begin
    if (!reset_n) begin
        control_reg <= 0;
        slave_address <= 0;
        slave_reg_address <= 0;
        slave_data_1 <= 0;
        slave_data_2 <= 0;
    end else begin
        if (write) begin
            case (address)
                3'b000: control_reg <= writedata;
                3'b001: slave_address <= writedata;
                3'b010: slave_reg_address <= writedata;
                3'b011: slave_data_1 <= writedata;
                3'b100: slave_data_2 <= writedata;
            endcase
        end
        if (state_next != STATE_IDLE)
            control_reg <= 0;
    end
end

reg scl_output_enable = 0;
reg scl_output_zero = 0;

always @(posedge clk_div_2) begin
    if (scl_output_enable) begin
        scl_out <= ~scl_out;
    end else begin
        scl_out <= scl_output_zero ? 1'b0 : 1'b1;
    end
end

reg success = 0;
reg ack_ok = 0;

always @(posedge clk_div_2) begin
    if ((state_next == STATE_ADDRESS_ACK || state_next == STATE_REG_ACK || state_next == STATE_DATA_ACK)
        && sda_in == 1'b0 && clk_div == 1) begin
        ack_ok <= 1'b1;
    end else begin
        ack_ok <= 1'b0;
    end
end

always @(negedge clk_div_2) begin
    if (clk_div == 1) begin
        if (state_next == STATE_STOP && success == 1'b1)
            success_out <= 1'b1;
        else if (state_next == STATE_ADDRESS_START)
            success_out <= 1'b0;
    end
end

always @(negedge clk_div_2) begin
    if (!reset_n) begin
        state_next <= STATE_IDLE;
    end else begin
        case (state_next)
            STATE_IDLE:
                if (control_reg[0]) state_next <= STATE_ADDRESS_START;
            STATE_ADDRESS_START:
                if (clk_div == 0) state_next <= STATE_ADDRESS_START_2;
            STATE_ADDRESS_START_2:
                if (clk_div == 1) state_next <= STATE_ADDRESS_START_3;
            STATE_ADDRESS_START_3:
                if (clk_div == 0) state_next <= STATE_ADDRESS_BIT_1;
            STATE_ADDRESS_BIT_1:
                if (clk_div == 0) state_next <= STATE_ADDRESS_BIT_2;
            STATE_ADDRESS_BIT_2:
                if (clk_div == 0) state_next <= STATE_ADDRESS_BIT_3;
            STATE_ADDRESS_BIT_3:
                if (clk_div == 0) state_next <= STATE_ADDRESS_BIT_4;
            STATE_ADDRESS_BIT_4:
                if (clk_div == 0) state_next <= STATE_ADDRESS_BIT_5;
            STATE_ADDRESS_BIT_5:
                if (clk_div == 0) state_next <= STATE_ADDRESS_BIT_6;
            STATE_ADDRESS_BIT_6:
                if (clk_div == 0) state_next <= STATE_ADDRESS_BIT_7;
            STATE_ADDRESS_BIT_7:
                if (clk_div == 0) state_next <= STATE_ADDRESS_BIT_8;
            STATE_ADDRESS_BIT_8:
                if (clk_div == 0) state_next <= STATE_ADDRESS_ACK;
            STATE_ADDRESS_ACK:
                if (clk_div == 0)
                    state_next <= ack_ok ? STATE_TRANSIT_1 : STATE_STOP;
            STATE_TRANSIT_1:
                if (clk_div == 0) state_next <= STATE_REG_BIT_1;
            STATE_REG_BIT_1:
                if (clk_div == 0) state_next <= STATE_REG_BIT_2;
            STATE_REG_BIT_2:
                if (clk_div == 0) state_next <= STATE_REG_BIT_3;
            STATE_REG_BIT_3:
                if (clk_div == 0) state_next <= STATE_REG_BIT_4;
            STATE_REG_BIT_4:
                if (clk_div == 0) state_next <= STATE_REG_BIT_5;
            STATE_REG_BIT_5:
                if (clk_div == 0) state_next <= STATE_REG_BIT_6;
            STATE_REG_BIT_6:
                if (clk_div == 0) state_next <= STATE_REG_BIT_7;
            STATE_REG_BIT_7:
                if (clk_div == 0) state_next <= STATE_REG_BIT_8;
            STATE_REG_BIT_8:
                if (clk_div == 0) state_next <= STATE_REG_ACK;
            STATE_REG_ACK:
                if (clk_div == 0)
                    state_next <= ack_ok ? STATE_TRANSIT_2 : STATE_STOP;
            STATE_TRANSIT_2:
                if (clk_div == 0) state_next <= STATE_DATA_BIT_1;
            STATE_DATA_BIT_1:
                if (clk_div == 0) state_next <= STATE_DATA_BIT_2;
            STATE_DATA_BIT_2:
                if (clk_div == 0) state_next <= STATE_DATA_BIT_3;
            STATE_DATA_BIT_3:
                if (clk_div == 0) state_next <= STATE_DATA_BIT_4;
            STATE_DATA_BIT_4:
                if (clk_div == 0) state_next <= STATE_DATA_BIT_5;
            STATE_DATA_BIT_5:
                if (clk_div == 0) state_next <= STATE_DATA_BIT_6;
            STATE_DATA_BIT_6:
                if (clk_div == 0) state_next <= STATE_DATA_BIT_7;
            STATE_DATA_BIT_7:
                if (clk_div == 0) state_next <= STATE_DATA_BIT_8;
            STATE_DATA_BIT_8:
                if (clk_div == 0) state_next <= STATE_DATA_ACK;
            STATE_DATA_ACK:
                if (clk_div == 0) state_next <= STATE_STOP;
            STATE_STOP:
                if (clk_div == 1) state_next <= STATE_STOP_1;
            STATE_STOP_1:
                if (clk_div == 0) state_next <= STATE_IDLE;
            default:
                state_next <= STATE_IDLE;
        endcase
    end
end

endmodule