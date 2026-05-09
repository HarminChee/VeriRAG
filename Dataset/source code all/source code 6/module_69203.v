`resetall
`timescale 1ns / 1ps
`default_nettype none
`resetall
`resetall
`timescale 1ns / 1ps
`default_nettype none
module i2c_master (
    input  wire        clk,
    input  wire        rst,
    input  wire [6:0]  cmd_address,
    input  wire        cmd_start,
    input  wire        cmd_read,
    input  wire        cmd_write,
    input  wire        cmd_write_multiple,
    input  wire        cmd_stop,
    input  wire        cmd_valid,
    output wire        cmd_ready,
    input  wire [7:0]  data_in,
    input  wire        data_in_valid,
    output wire        data_in_ready,
    input  wire        data_in_last,
    output wire [7:0]  data_out,
    output wire        data_out_valid,
    input  wire        data_out_ready,
    output wire        data_out_last,
    input  wire        scl_i,
    output wire        scl_o,
    output wire        scl_t,
    input  wire        sda_i,
    output wire        sda_o,
    output wire        sda_t,
    output wire        busy,
    output wire        bus_control,
    output wire        bus_active,
    output wire        missed_ack,
    input  wire [15:0] prescale,
    input  wire        stop_on_idle
);
localparam [4:0]
    STATE_IDLE = 4'd0,
    STATE_ACTIVE_WRITE = 4'd1,
    STATE_ACTIVE_READ = 4'd2,
    STATE_START_WAIT = 4'd3,
    STATE_START = 4'd4,
    STATE_ADDRESS_1 = 4'd5,
    STATE_ADDRESS_2 = 4'd6,
    STATE_WRITE_1 = 4'd7,
    STATE_WRITE_2 = 4'd8,
    STATE_WRITE_3 = 4'd9,
    STATE_READ = 4'd10,
    STATE_STOP = 4'd11;
reg [4:0] state_reg = STATE_IDLE, state_next;
localparam [4:0]
    PHY_STATE_IDLE = 5'd0,
    PHY_STATE_ACTIVE = 5'd1,
    PHY_STATE_REPEATED_START_1 = 5'd2,
    PHY_STATE_REPEATED_START_2 = 5'd3,
    PHY_STATE_START_1 = 5'd4,
    PHY_STATE_START_2 = 5'd5,
    PHY_STATE_WRITE_BIT_1 = 5'd6,
    PHY_STATE_WRITE_BIT_2 = 5'd7,
    PHY_STATE_WRITE_BIT_3 = 5'd8,
    PHY_STATE_READ_BIT_1 = 5'd9,
    PHY_STATE_READ_BIT_2 = 5'd10,
    PHY_STATE_READ_BIT_3 = 5'd11,
    PHY_STATE_READ_BIT_4 = 5'd12,
    PHY_STATE_STOP_1 = 5'd13,
    PHY_STATE_STOP_2 = 5'd14,
    PHY_STATE_STOP_3 = 5'd15;
reg [4:0] phy_state_reg = STATE_IDLE, phy_state_next;
reg phy_start_bit;
reg phy_stop_bit;
reg phy_write_bit;
reg phy_read_bit;
reg phy_release_bus;
reg phy_tx_data;
reg phy_rx_data_reg = 1'b0, phy_rx_data_next;
reg [6:0] addr_reg = 7'd0, addr_next;
reg [7:0] data_reg = 8'd0, data_next;
reg last_reg = 1'b0, last_next;
reg mode_read_reg = 1'b0, mode_read_next;
reg mode_write_multiple_reg = 1'b0, mode_write_multiple_next;
reg mode_stop_reg = 1'b0, mode_stop_next;
reg [16:0] delay_reg = 16'd0, delay_next;
reg delay_scl_reg = 1'b0, delay_scl_next;
reg delay_sda_reg = 1'b0, delay_sda_next;
reg [3:0] bit_count_reg = 4'd0, bit_count_next;
reg cmd_ready_reg = 1'b0, cmd_ready_next;
reg data_in_ready_reg = 1'b0, data_in_ready_next;
reg [7:0] data_out_reg = 8'd0, data_out_next;
reg data_out_valid_reg = 1'b0, data_out_valid_next;
reg data_out_last_reg = 1'b0, data_out_last_next;
reg scl_i_reg = 1'b1;
reg sda_i_reg = 1'b1;
reg scl_o_reg = 1'b1, scl_o_next;
reg sda_o_reg = 1'b1, sda_o_next;
reg last_scl_i_reg = 1'b1;
reg last_sda_i_reg = 1'b1;
reg busy_reg = 1'b0;
reg bus_active_reg = 1'b0;
reg bus_control_reg = 1'b0, bus_control_next;
reg missed_ack_reg = 1'b0, missed_ack_next;
assign cmd_ready = cmd_ready_reg;
assign data_in_ready = data_in_ready_reg;
assign data_out = data_out_reg;
assign data_out_valid = data_out_valid_reg;
assign data_out_last = data_out_last_reg;
assign scl_o = scl_o_reg;
assign scl_t = scl_o_reg;
assign sda_o = sda_o_reg;
assign sda_t = sda_o_reg;
assign busy = busy_reg;
assign bus_active = bus_active_reg;
assign bus_control = bus_control_reg;
assign missed_ack = missed_ack_reg;
wire scl_posedge = scl_i_reg & ~last_scl_i_reg;
wire scl_negedge = ~scl_i_reg & last_scl_i_reg;
wire sda_posedge = sda_i_reg & ~last_sda_i_reg;
wire sda_negedge = ~sda_i_reg & last_sda_i_reg;
wire start_bit = sda_negedge & scl_i_reg;
wire stop_bit = sda_posedge & scl_i_reg;
always @* begin
    state_next = STATE_IDLE;
    phy_start_bit = 1'b0;
    phy_stop_bit = 1'b0;
    phy_write_bit = 1'b0;
    phy_read_bit = 1'b0;
    phy_tx_data = 1'b0;
    phy_release_bus = 1'b0;
    addr_next = addr_reg;
    data_next = data_reg;
    last_next = last_reg;
    mode_read_next = mode_read_reg;
    mode_write_multiple_next = mode_write_multiple_reg;
    mode_stop_next = mode_stop_reg;
    bit_count_next = bit_count_reg;
    cmd_ready_next = 1'b0;
    data_in_ready_next = 1'b0;
    data_out_next = data_out_reg;
    data_out_valid_next = data_out_valid_reg & ~data_out_ready;
    data_out_last_next = data_out_last_reg;
    missed_ack_next = 1'b0;
    if (phy_state_reg != PHY_STATE_IDLE && phy_state_reg != PHY_STATE_ACTIVE) begin
        state_next = state_reg;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                cmd_ready_next = 1'b1;
                if (cmd_ready & cmd_valid) begin
                    if (cmd_read ^ (cmd_write | cmd_write_multiple)) begin
                        addr_next = cmd_address;
                        mode_read_next = cmd_read;
                        mode_write_multiple_next = cmd_write_multiple;
                        mode_stop_next = cmd_stop;
                        cmd_ready_next = 1'b0;
                        if (bus_active) begin
                            state_next = STATE_START_WAIT;
                        end else begin
                            phy_start_bit = 1'b1;
                            bit_count_next = 4'd8;
                            state_next = STATE_ADDRESS_1;
                        end
                    end else begin
                        state_next = STATE_IDLE;
                    end
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_ACTIVE_WRITE: begin
                cmd_ready_next = 1'b1;
                if (cmd_ready & cmd_valid) begin
                    if (cmd_read ^ (cmd_write | cmd_write_multiple)) begin
                        addr_next = cmd_address;
                        mode_read_next = cmd_read;
                        mode_write_multiple_next = cmd_write_multiple;
                        mode_stop_next = cmd_stop;
                        cmd_ready_next = 1'b0;
                        if (cmd_start || cmd_address != addr_reg || cmd_read) begin
                            phy_start_bit = 1'b1;
                            bit_count_next = 4'd8;
                            state_next = STATE_ADDRESS_1;
                        end else begin
                            data_in_ready_next = 1'b1;
                            state_next = STATE_WRITE_1;
                        end
                    end else if (cmd_stop && !(cmd_read || cmd_write || cmd_write_multiple)) begin
                        phy_stop_bit = 1'b1;
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_ACTIVE_WRITE;
                    end
                end else begin
                    if (stop_on_idle & cmd_ready & ~cmd_valid) begin
                        phy_stop_bit = 1'b1;
                        state_next = STATE_IDLE;
                    end else begin
                        state_next = STATE_ACTIVE_WRITE;
                    end
                end
            end
            STATE_ACTIVE_READ: begin
                cmd_ready_next = ~data_out_valid;
                if (cmd_ready & cmd_valid) begin
                    if (cmd_read ^ (cmd_write | cmd_write_multiple)) begin
                        addr_next = cmd_address;
                        mode_read_next = cmd_read;
                        mode_write_multiple_next = cmd_write_multiple;
                        mode_stop_next = cmd_stop;
                        cmd_ready_next = 1'b0;
                        if (cmd_start || cmd_address != addr_reg || cmd_write) begin
                            phy_write_bit = 1'b1;
                            phy_tx_data = 1'b1;
                            state_next = STATE_START;
                        end else begin
                            phy_write_bit = 1'b1;
                            phy_tx_data = 1'b0;
                            bit_count_next = 4'd8;
                            data_next = 8'd0;
                            state_next = STATE_READ;
                        end
                    end else if (cmd_stop && !(cmd_read || cmd_write || cmd_write_multiple)) begin
                        phy_write_bit = 1'b1;
                        phy_tx_data = 1'b1;
                        state_next = STATE_STOP;
                    end else begin
                        state_next = STATE_ACTIVE_READ;
                    end
                end else begin
                    if (stop_on_idle & cmd_ready & ~cmd_valid) begin
                        phy_write_bit = 1'b1;
                        phy_tx_data = 1'b1;
                        state_next = STATE_STOP;
                    end else begin
                        state_next = STATE_ACTIVE_READ;
                    end
                end
            end
            STATE_START_WAIT: begin
                if (bus_active) begin
                    state_next = STATE_START_WAIT;
                end else begin
                    phy_start_bit = 1'b1;
                    bit_count_next = 4'd8;
                    state_next = STATE_ADDRESS_1;
                end
            end
            STATE_START: begin
                phy_start_bit = 1'b1;
                bit_count_next = 4'd8;
                state_next = STATE_ADDRESS_1;
            end
            STATE_ADDRESS_1: begin
                bit_count_next = bit_count_reg - 1;
                if (bit_count_reg > 1) begin
                    phy_write_bit = 1'b1;
                    phy_tx_data = addr_reg[bit_count_reg-2];
                    state_next = STATE_ADDRESS_1;
                end else if (bit_count_reg > 0) begin
                    phy_write_bit = 1'b1;
                    phy_tx_data = mode_read_reg;
                    state_next = STATE_ADDRESS_1;
                end else begin
                    phy_read_bit = 1'b1;
                    state_next = STATE_ADDRESS_2;
                end
            end
            STATE_ADDRESS_2: begin
                missed_ack_next = phy_rx_data_reg;
                if (mode_read_reg) begin
                    bit_count_next = 4'd8;
                    data_next = 1'b0;
                    state_next = STATE_READ;
                end else begin
                    data_in_ready_next = 1'b1;
                    state_next = STATE_WRITE_1;
                end
            end
            STATE_WRITE_1: begin
                data_in_ready_next = 1'b1;
                if (data_in_ready & data_in_valid) begin
                    data_next = data_in;
                    last_next = data_in_last;
                    bit_count_next = 4'd8;
                    data_in_ready_next = 1'b0;
                    state_next = STATE_WRITE_2;
                end else begin
                    state_next = STATE_WRITE_1;
                end
            end
            STATE_WRITE_2: begin
                bit_count_next = bit_count_reg - 1;
                if (bit_count_reg > 0) begin
                    phy_write_bit = 1'b1;
                    phy_tx_data = data_reg[bit_count_reg-1];
                    state_next = STATE_WRITE_2;
                end else begin
                    phy_read_bit = 1'b1;
                    state_next = STATE_WRITE_3;
                end
            end
            STATE_WRITE_3: begin
                missed_ack_next = phy_rx_data_reg;
                if (mode_write_multiple_reg && !last_reg) begin
                    state_next = STATE_WRITE_1;
                end else if (mode_stop_reg) begin
                    phy_stop_bit = 1'b1;
                    state_next = STATE_IDLE;
                end else begin
                    state_next = STATE_ACTIVE_WRITE;
                end
            end
            STATE_READ: begin
                bit_count_next = bit_count_reg - 1;
                data_next = {data_reg[6:0], phy_rx_data_reg};
                if (bit_count_reg > 0) begin
                    phy_read_bit = 1'b1;
                    state_next = STATE_READ;
                end else begin
                    data_out_next = data_next;
                    data_out_valid_next = 1'b1;
                    data_out_last_next = 1'b0;
                    if (mode_stop_reg) begin
                        data_out_last_next = 1'b1;
                        phy_write_bit = 1'b1;
                        phy_tx_data = 1'b1;
                        state_next = STATE_STOP;
                    end else begin
                        state_next = STATE_ACTIVE_READ;
                    end
                end
            end
            STATE_STOP: begin
                phy_stop_bit = 1'b1;
                state_next = STATE_IDLE;
            end
        endcase
    end
end
always @* begin
    phy_state_next = PHY_STATE_IDLE;
    phy_rx_data_next = phy_rx_data_reg;
    delay_next = delay_reg;
    delay_scl_next = delay_scl_reg;
    delay_sda_next = delay_sda_reg;
    scl_o_next = scl_o_reg;
    sda_o_next = sda_o_reg;
    bus_control_next = bus_control_reg;
    if (phy_release_bus) begin
        sda_o_next = 1'b1;
        scl_o_next = 1'b1;
        delay_scl_next = 1'b0;
        delay_sda_next = 1'b0;
        delay_next = 1'b0;
        phy_state_next = PHY_STATE_IDLE;
    end else if (delay_scl_reg) begin
        delay_scl_next = scl_o_reg & ~scl_i_reg;
        phy_state_next = phy_state_reg;
    end else if (delay_sda_reg) begin
        delay_sda_next = sda_o_reg & ~sda_i_reg;
        phy_state_next = phy_state_reg;
    end else if (delay_reg > 0) begin
        delay_next = delay_reg - 1;
        phy_state_next = phy_state_reg;
    end else begin
        case (phy_state_reg)
            PHY_STATE_IDLE: begin
                sda_o_next = 1'b1;
                scl_o_next = 1'b1;
                if (phy_start_bit) begin
                    sda_o_next = 1'b0;
                    delay_next = prescale;
                    phy_state_next = PHY_STATE_START_1;
                end else begin
                    phy_state_next = PHY_STATE_IDLE;
                end
            end
            PHY_STATE_ACTIVE: begin
                if (phy_start_bit) begin
                    sda_o_next = 1'b1;
                    delay_next = prescale;
                    phy_state_next = PHY_STATE_REPEATED_START_1;
                end else if (phy_write_bit) begin
                    sda_o_next = phy_tx_data;
                    delay_next = prescale;
                    phy_state_next = PHY_STATE_WRITE_BIT_1;
                end else if (phy_read_bit) begin
                    sda_o_next = 1'b1;
                    delay_next = prescale;
                    phy_state_next = PHY_STATE_READ_BIT_1;
                end else if (phy_stop_bit) begin
                    sda_o_next = 1'b0;
                    delay_next = prescale;
                    phy_state_next = PHY_STATE_STOP_1;
                end else begin
                    phy_state_next = PHY_STATE_ACTIVE;
                end
            end
            PHY_STATE_REPEATED_START_1: begin
                scl_o_next = 1'b1;
                delay_scl_next = 1'b1;
                delay_next = prescale;
                phy_state_next = PHY_STATE_REPEATED_START_2;
            end
            PHY_STATE_REPEATED_START_2: begin
                sda_o_next = 1'b0;
                delay_next = prescale;
                phy_state_next = PHY_STATE_START_1;
            end
            PHY_STATE_START_1: begin
                scl_o_next = 1'b0;
                delay_next = prescale;
                phy_state_next = PHY_STATE_START_2;
            end
            PHY_STATE_START_2: begin
                bus_control_next = 1'b1;
                phy_state_next = PHY_STATE_ACTIVE;
            end
            PHY_STATE_WRITE_BIT_1: begin
                scl_o_next = 1'b1;
                delay_scl_next = 1'b1;
                delay_next = prescale << 1;
                phy_state_next = PHY_STATE_WRITE_BIT_2;
            end
            PHY_STATE_WRITE_BIT_2: begin
                scl_o_next = 1'b0;
                delay_next = prescale;
                phy_state_next = PHY_STATE_WRITE_BIT_3;
            end
            PHY_STATE_WRITE_BIT_3: begin
                phy_state_next = PHY_STATE_ACTIVE;
            end
            PHY_STATE_READ_BIT_1: begin
                scl_o_next = 1'b1;
                delay_scl_next = 1'b1;
                delay_next = prescale;
                phy_state_next = PHY_STATE_READ_BIT_2;
            end
            PHY_STATE_READ_BIT_2: begin
                phy_rx_data_next = sda_i_reg;
                delay_next = prescale;
                phy_state_next = PHY_STATE_READ_BIT_3;
            end
            PHY_STATE_READ_BIT_3: begin
                scl_o_next = 1'b0;
                delay_next = prescale;
                phy_state_next = PHY_STATE_READ_BIT_4;
            end
            PHY_STATE_READ_BIT_4: begin
                phy_state_next = PHY_STATE_ACTIVE;
            end
            PHY_STATE_STOP_1: begin
                scl_o_next = 1'b1;
                delay_scl_next = 1'b1;
                delay_next = prescale;
                phy_state_next = PHY_STATE_STOP_2;
            end
            PHY_STATE_STOP_2: begin
                sda_o_next = 1'b1;
                delay_next = prescale;
                phy_state_next = PHY_STATE_STOP_3;
            end
            PHY_STATE_STOP_3: begin
                bus_control_next = 1'b0;
                phy_state_next = PHY_STATE_IDLE;
            end
        endcase
    end
end
always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;
        phy_state_reg <= PHY_STATE_IDLE;
        delay_reg <= 16'd0;
        delay_scl_reg <= 1'b0;
        delay_sda_reg <= 1'b0;
        cmd_ready_reg <= 1'b0;
        data_in_ready_reg <= 1'b0;
        data_out_valid_reg <= 1'b0;
        scl_o_reg <= 1'b1;
        sda_o_reg <= 1'b1;
        busy_reg <= 1'b0;
        bus_active_reg <= 1'b0;
        bus_control_reg <= 1'b0;
        missed_ack_reg <= 1'b0;
    end else begin
        state_reg <= state_next;
        phy_state_reg <= phy_state_next;
        delay_reg <= delay_next;
        delay_scl_reg <= delay_scl_next;
        delay_sda_reg <= delay_sda_next;
        cmd_ready_reg <= cmd_ready_next;
        data_in_ready_reg <= data_in_ready_next;
        data_out_valid_reg <= data_out_valid_next;
        scl_o_reg <= scl_o_next;
        sda_o_reg <= sda_o_next;
        busy_reg <= !(state_reg == STATE_IDLE || state_reg == STATE_ACTIVE_WRITE || state_reg == STATE_ACTIVE_READ);
        if (start_bit) begin
            bus_active_reg <= 1'b1;
        end else if (stop_bit) begin
            bus_active_reg <= 1'b0;
        end else begin
            bus_active_reg <= bus_active_reg;
        end
        bus_control_reg <= bus_control_next;
        missed_ack_reg <= missed_ack_next;
    end
    phy_rx_data_reg <= phy_rx_data_next;
    addr_reg <= addr_next;
    data_reg <= data_next;
    last_reg <= last_next;
    mode_read_reg <= mode_read_next;
    mode_write_multiple_reg <= mode_write_multiple_next;
    mode_stop_reg <= mode_stop_next;
    bit_count_reg <= bit_count_next;
    data_out_reg <= data_out_next;
    data_out_last_reg <= data_out_last_next;
    scl_i_reg <= scl_i;
    sda_i_reg <= sda_i;
    last_scl_i_reg <= scl_i_reg;
    last_sda_i_reg <= sda_i_reg;
end
endmodule
`resetall
