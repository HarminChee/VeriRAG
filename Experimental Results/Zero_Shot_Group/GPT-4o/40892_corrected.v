module i2c_module(
    input clk, 
    input reset_n,
    output reg sda_oe = 1,
    input wire sda_in,
    output reg sda = 1,
    output reg scl_out,
    input [7:0] writedata,
    input write,
    input [2:0] address,
    output reg ready = 1,
    output reg success_out = 0
);

reg [7:0] state_next = 0;
localparam STATE_IDLE = 0;
localparam STATE_START = 1;
localparam STATE_ADDRESS = 2;
localparam STATE_ADDRESS_ACK = 3;
localparam STATE_REGISTER = 4;
localparam STATE_REGISTER_ACK = 5;
localparam STATE_DATA = 6;
localparam STATE_DATA_ACK = 7;
localparam STATE_STOP = 8;

reg clk_div = 0;
reg [7:0] divider2 = 0;
wire clk_div_2;

always @(posedge clk_div_2) begin
    clk_div <= ~clk_div;
end

always @(posedge clk) begin
    divider2 <= divider2 + 1;
end

assign clk_div_2 = divider2[7];

reg [7:0] control_reg = 0;
reg [7:0] slave_address = 0;
reg [7:0] slave_reg_address = 0;
reg [7:0] slave_data = 0;

always @(posedge clk) begin
    if (!reset_n) begin
        control_reg <= 0;
        slave_address <= 0;
        slave_reg_address <= 0;
        slave_data <= 0;
    end else if (write) begin
        case (address)
            3'b000: control_reg <= writedata;
            3'b001: slave_address <= writedata;
            3'b010: slave_reg_address <= writedata;
            3'b011: slave_data <= writedata;
        endcase
    end
end

reg scl_enable = 0;
reg scl_low = 0;

always @(posedge clk_div_2) begin
    if (scl_enable)
        scl_out <= ~scl_out;
    else
        scl_out <= scl_low ? 1'b0 : 1'b1;
end

reg success = 0;
reg ack_ok = 0;

always @(posedge clk_div_2) begin
    if ((state_next == STATE_ADDRESS_ACK || state_next == STATE_REGISTER_ACK || state_next == STATE_DATA_ACK) && sda_in == 0 && clk_div)
        ack_ok <= 1'b1;
    else
        ack_ok <= 1'b0;
end

always @(negedge clk_div_2) begin
    if (clk_div) begin
        if (state_next == STATE_STOP && success)
            success_out <= 1'b1;
        else if (state_next == STATE_START)
            success_out <= 1'b0;
    end
end

always @(negedge clk_div_2) begin
    if (!reset_n) begin
        state_next <= STATE_IDLE;
    end else begin
        case (state_next)
            STATE_IDLE: 
                if (control_reg[0])
                    state_next <= STATE_START;
            
            STATE_START:
                if (!clk_div)
                    state_next <= STATE_ADDRESS;
            
            STATE_ADDRESS:
                if (!clk_div)
                    state_next <= STATE_ADDRESS_ACK;
            
            STATE_ADDRESS_ACK:
                if (!clk_div) begin
                    if (ack_ok)
                        state_next <= STATE_REGISTER;
                    else
                        state_next <= STATE_STOP;
                end
            
            STATE_REGISTER:
                if (!clk_div)
                    state_next <= STATE_REGISTER_ACK;
            
            STATE_REGISTER_ACK:
                if (!clk_div) begin
                    if (ack_ok)
                        state_next <= STATE_DATA;
                    else
                        state_next <= STATE_STOP;
                end
            
            STATE_DATA:
                if (!clk_div)
                    state_next <= STATE_DATA_ACK;
            
            STATE_DATA_ACK:
                if (!clk_div)
                    state_next <= STATE_STOP;
            
            STATE_STOP:
                if (clk_div)
                    state_next <= STATE_IDLE;
            
            default:
                state_next <= STATE_IDLE;
        endcase
    end
end

always @(negedge clk_div_2) begin
    if (!reset_n) begin
        sda <= 1'b1;
        sda_oe <= 1'b1;
        scl_enable <= 1'b0;
        ready <= 1;
        success <= 0;
    end else begin
        case (state_next)
            STATE_IDLE: begin
                sda <= 1'b1;
                sda_oe <= 1'b1;
                scl_enable <= 1'b0;
                ready <= 1;
                success <= 0;
                scl_low <= 0;
            end
            
            STATE_START: begin
                if (!clk_div) begin
                    scl_low <= 0;
                    scl_enable <= 0;
                    sda_oe <= 1;
                    sda <= 0;
                    ready <= 0;
                    success <= 0;
                end
            end
            
            STATE_ADDRESS: begin
                if (!clk_div) begin
                    scl_enable <= 1;
                    sda_oe <= 1;
                    sda <= slave_address[7];
                end
            end
            
            STATE_ADDRESS_ACK: begin
                if (!clk_div) begin
                    sda_oe <= 0;
                    if (ack_ok)
                        scl_enable <= 0;
                    else
                        scl_enable <= 1;
                end
            end
            
            STATE_REGISTER: begin
                if (!clk_div) begin
                    scl_enable <= 1;
                    sda_oe <= 1;
                    sda <= slave_reg_address[7];
                end
            end
            
            STATE_REGISTER_ACK: begin
                if (!clk_div) begin
                    sda_oe <= 0;
                    if (ack_ok)
                        scl_enable <= 0;
                    else
                        scl_enable <= 1;
                end
            end
            
            STATE_DATA: begin
                if (!clk_div) begin
                    scl_enable <= 1;
                    sda_oe <= 1;
                    sda <= slave_data[7];
                end
            end
            
            STATE_DATA_ACK: begin
                if (!clk_div) begin
                    sda_oe <= 0;
                    if (ack_ok) begin
                        scl_enable <= 1;
                        success <= 1;
                    end else begin
                        scl_enable <= 0;
                    end
                end
            end
            
            STATE_STOP: begin
                if (clk_div) begin
                    sda_oe <= 1;
                    sda <= 1;
                    scl_low <= 0;
                    scl_enable <= 0;
                end
            end
            
            default: begin
                sda <= 1'b1;
                sda_oe <= 1'b1;
                scl_enable <= 1'b0;
                ready <= 1;
                scl_low <= 0;
                success <= 0;
            end
        endcase
    end
end

endmodule