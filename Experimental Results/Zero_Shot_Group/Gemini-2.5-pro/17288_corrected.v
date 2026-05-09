// Corrected monostable module
// Uses a synchronous state machine with asynchronous reset
// Generates a pulse of PULSE_WIDTH clock cycles starting the cycle after trigger is detected
module monostable (
    input clk,
    input reset, // Asynchronous reset
    input trigger,
    output pulse // Registered output pulse
);
    parameter PULSE_WIDTH = 4; // Example non-zero default

    // Calculate counter width needed to count up to PULSE_WIDTH-1
    // Handle PULSE_WIDTH=0 and PULSE_WIDTH=1 cases correctly for $clog2
    localparam COUNT_MAX = (PULSE_WIDTH == 0) ? 0 : PULSE_WIDTH - 1;
    localparam COUNT_WIDTH = (PULSE_WIDTH <= 1) ? 1 : $clog2(COUNT_MAX + 1);

    // Internal state registers
    reg state_reg = 1'b0; // 0: IDLE, 1: ACTIVE
    reg [COUNT_WIDTH-1:0] count_reg = 0;
    reg pulse_reg = 1'b0;

    // Next state logic (combinational)
    reg next_state;
    reg [COUNT_WIDTH-1:0] next_count;
    reg next_pulse;

    always @(*) begin
        // Default assignments: stay in current state unless condition met
        next_state = state_reg;
        next_count = count_reg;
        next_pulse = pulse_reg; // Keep pulse as is unless changed by state transition

        case (state_reg)
            1'b0: begin // IDLE State
                next_pulse = 1'b0; // Ensure pulse is low in IDLE
                next_count = 0;    // Reset counter in IDLE
                if (trigger) begin
                    if (PULSE_WIDTH > 0) begin
                        next_state = 1'b1; // Go to ACTIVE state
                        next_pulse = 1'b1; // Start pulse on next cycle
                        next_count = 0;    // Start count from 0
                    end
                    // If PULSE_WIDTH is 0, stay in IDLE, pulse remains 0
                end
            end
            1'b1: begin // ACTIVE State
                next_pulse = 1'b1; // Keep pulse high during ACTIVE state
                if (PULSE_WIDTH == 1 || count_reg == COUNT_MAX) begin // Pulse duration reached (handle width=1 case)
                    next_state = 1'b0; // Go back to IDLE
                    next_pulse = 1'b0; // Pulse ends on the next cycle
                    next_count = 0;    // Reset counter
                end else begin
                    next_count = count_reg + 1'b1; // Increment counter
                    // Keep state ACTIVE, pulse HIGH
                end
            end
            default: begin // Should not happen
                next_state = 1'b0;
                next_pulse = 1'b0;
                next_count = 0;
            end
        endcase
    end

    // State and output registers (sequential)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= 1'b0;
            count_reg <= 0;
            pulse_reg <= 1'b0;
        end else begin
            state_reg <= next_state;
            count_reg <= next_count;
            pulse_reg <= next_pulse;
        end
    end

    // Assign registered pulse signal to the output port
    assign pulse = pulse_reg;

endmodule

// Corrected delayed_monostable module
module delayed_monostable(
        input clk,
        input reset, // Asynchronous reset
        input trigger,
        output pulse
);
        parameter DELAY_WIDTH = 4;  // Example non-zero default
        parameter SIGNAL_WIDTH = 4; // Example non-zero default

        wire dly_pulse; // Output pulse from the delay monostable
        reg dly_pulse_prev = 1'b0; // Register to detect falling edge
        wire dly_falling_edge;   // One-cycle pulse on falling edge of dly_pulse

        // Instantiate the first monostable for the delay period
        monostable #(
                .PULSE_WIDTH(DELAY_WIDTH)
        ) delay_monostable_inst (
                .clk(clk),
                .reset(reset),
                .trigger(trigger), // Triggered by the external input
                .pulse(dly_pulse)
        );

        // Detect the falling edge of the delay pulse to trigger the signal pulse
        always @(posedge clk or posedge reset) begin
                if (reset) begin
                    dly_pulse_prev <= 1'b0;
                end else begin
                    dly_pulse_prev <= dly_pulse;
                end
        end
        assign dly_falling_edge = dly_pulse_prev & ~dly_pulse; // Assert high for one cycle when dly_pulse falls

        // Instantiate the second monostable for the actual signal pulse
        monostable #(
                .PULSE_WIDTH(SIGNAL_WIDTH)
        ) signal_monostable_inst (
                .clk(clk),
                .reset(reset),
                .trigger(dly_falling_edge), // Triggered by the falling edge of the delay pulse
                .pulse(pulse)               // Final output pulse
        );

endmodule