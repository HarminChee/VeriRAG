module 1_corrected_ffc #(parameter CLOCK_FREQ = 12_000_000, BAUD_RATE = 115_200)
(
    input clock,
    input [7:0] read_data,
    input read_clock_enable,
    input reset,
    output reg ready,
    output reg tx,
    output reg uart_clock
);

localparam CLOCKS_PER_BIT = CLOCK_FREQ / BAUD_RATE / 2;

reg [9:0] data;
reg [24:0] divider;
reg new_data;
reg state;
reg [3:0] bit_pos;
reg uart_clock_reg;

localparam IDLE = 1'h0, DATA = 1'h1;

// Generate uart_clock on primary clock's positive edge
always @(posedge clock or negedge reset) begin
    if (!reset) begin
        uart_clock <= 1'b0;
        divider <= 25'd0;
    end
    else begin
        if (divider >= CLOCKS_PER_BIT) begin
            divider <= 25'd0;
            uart_clock <= ~uart_clock;
        end
        else
            divider <= divider + 1;
    end
end

// Handle data loading and ready flag
always @(posedge clock or negedge reset) begin
    if (!reset) begin
        ready <= 1'b0;
        new_data <= 1'b0;
    end
    else begin
        if (state == IDLE) begin
            if (!new_data) begin
                if (!ready) begin
                    ready <= 1'b1;
                end
                else if (read_clock_enable) begin
                    data[0] <= 1'b0;
                    data[8:1] <= read_data;
                    data[9] <= 1'b1;
                    new_data <= 1'b1;
                    ready <= 1'b0;
                end
            end
        end
        else begin
            new_data <= 1'b0;
        end
    end
end

// Synchronous state machine triggered on the negative edge of uart_clock (detected synchronously)
always @(posedge clock or negedge reset) begin
    if (!reset) begin
        state <= IDLE;
        tx <= 1'b1;
        bit_pos <= 4'd0;
        uart_clock_reg <= 1'b0;
    end
    else begin
        uart_clock_reg <= uart_clock;
        if (uart_clock_reg == 1'b1 && uart_clock == 1'b0) begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (new_data) begin
                        state <= DATA;
                        bit_pos <= 4'd0;
                    end
                end
                DATA: begin
                    tx <= data[bit_pos];
                    if (bit_pos == 4'd9)
                        state <= IDLE;
                    else
                        bit_pos <= bit_pos + 1'b1;
                end
            endcase
        end
    end
end

endmodule