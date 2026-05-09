module uart_tx #(parameter CLOCK_FREQ = 12_000_000, BAUD_RATE = 115_200)
(
    input clock,
    input [7:0] read_data,
    input read_clock_enable,
    input reset,
    output reg ready,
    output reg tx,
    output reg uart_clock
);
    reg [9:0] data;
    localparam integer CLOCKS_PER_BIT = CLOCK_FREQ/(BAUD_RATE*2);
    reg [24:0] divider;
    reg new_data;
    reg state;
    reg [3:0] bit_pos;
    localparam IDLE = 1'h0, DATA = 1'h1;

    always @(negedge reset or posedge clock) begin
        if (~reset) begin
            uart_clock <= 0;
            divider <= 0;
        end
        else if (divider >= CLOCKS_PER_BIT) begin
            divider <= 0;
            uart_clock <= ~uart_clock;
        end
        else begin
            divider <= divider + 1;
        end
    end

    always @(negedge clock or negedge reset) begin
        if (~reset) begin
            ready <= 0;
            new_data <= 0;
        end
        else begin
            if (state == IDLE) begin
                if (~new_data) begin
                    if (~ready) begin
                        ready <= 1;
                    end
                    else if (read_clock_enable) begin
                        data[0] <= 0;
                        data[8:1] <= read_data;
                        data[9] <= 1;
                        new_data <= 1;
                        ready <= 0;
                    end
                end
            end
            else begin
                new_data <= 0;
            end
        end
    end

    always @(negedge uart_clock or negedge reset) begin
        if (~reset) begin
            state <= IDLE;
            tx <= 1;
            bit_pos <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    tx <= 1;
                    if (new_data) begin
                        state <= DATA;
                        bit_pos <= 0;
                    end
                end
                DATA: begin
                    tx <= data[bit_pos];
                    if (bit_pos == 9) begin
                        state <= IDLE;
                    end
                    else begin
                        bit_pos <= bit_pos + 1;
                    end
                end
            endcase
        end
    end
endmodule