module monostable(
    input clk,
    input reset, // Asynchronous reset from primary input
    input trigger,
    output reg pulse = 0
);
    parameter PULSE_WIDTH = 0;
    // Use $clog2 to determine the minimum bits needed for the counter, handle PULSE_WIDTH=0 case
    localparam COUNT_WIDTH = (PULSE_WIDTH == 0) ? 1 : $clog2(PULSE_WIDTH + 1);
    reg [COUNT_WIDTH-1:0] count = 0;
    reg state = 0; // 0: idle, 1: pulsing

    // Synchronous logic for state, count, and pulse output
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            count <= 0;
            pulse <= 0;
        end else begin
            case (state)
                0: begin // Idle state
                    if (trigger) begin
                        // Start pulse on the clock edge after trigger is detected
                        state <= 1;
                        pulse <= 1;
                        // Reset count only if PULSE_WIDTH is non-zero, otherwise it stays 0
                        if (PULSE_WIDTH > 0) begin
                            count <= 0;
                        end
                    end else begin
                        // Remain idle
                        // state <= 0; // No need to reassign
                        pulse <= 0;
                        count <= 0;
                    end
                end
                1: begin // Pulsing state
                    // Check if pulse duration is met
                    if (count == PULSE_WIDTH) begin
                        // End pulse
                        state <= 0;
                        pulse <= 0;
                        count <= 0;
                    end else begin
                        // Continue pulsing and increment count
                        // state <= 1; // No need to reassign
                        pulse <= 1;
                        count <= count + 1'b1;
                    end
                end
                default: begin // Should not happen in 1-bit state FSM
                     state <= 0;
                     pulse <= 0;
                     count <= 0;
                end
            endcase
        end
    end
endmodule

module delayed_monostable(
        input clk,
        input reset,
        input trigger,
        output pulse
);
        parameter DELAY_WIDTH = 0;
        parameter SIGNAL_WIDTH = 0;

        wire dly_pulse; // Output pulse from the delay monostable

        // Instantiate the first monostable for the delay
        monostable #(
                .PULSE_WIDTH(DELAY_WIDTH)
        ) delay_mono (
                .clk(clk),
                .reset(reset),
                .trigger(trigger),
                .pulse(dly_pulse) // This pulse indicates the delay period is active
        );

        // The trigger for the second monostable should occur when the delay pulse ends.
        // Detect the falling edge of dly_pulse synchronously.
        reg dly_pulse_d1 = 0;
        wire trig_for_signal;

        always @(posedge clk or posedge reset) begin
            if (reset) begin
                dly_pulse_d1 <= 0;
            end else begin
                dly_pulse_d1 <= dly_pulse;
            end
        end

        // Trigger happens when delay pulse was high (dly_pulse_d1) and is now low (~dly_pulse)
        assign trig_for_signal = dly_pulse_d1 & (~dly_pulse);

        // Instantiate the second monostable for the actual signal pulse
        monostable #(
                .PULSE_WIDTH(SIGNAL_WIDTH)
        ) signal_mono (
                .clk(clk),
                .reset(reset),
                .trigger(trig_for_signal), // Triggered by the end of the delay pulse
                .pulse(pulse)
        );

endmodule