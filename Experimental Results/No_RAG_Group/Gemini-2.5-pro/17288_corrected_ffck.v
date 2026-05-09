// 1_corrected_ffc.v
module monostable(
    input clk,         // Primary clock
    input reset,       // Primary asynchronous reset
    input trigger,     // Input signal
    output reg pulse = 0 // Output pulse
);
    parameter PULSE_WIDTH = 4; // Example width, ensure > 0

    reg trigger_d = 0; // Register to detect trigger edge
    // Ensure counter width matches PULSE_WIDTH requirement.
    // If PULSE_WIDTH can be large, adjust counter width.
    // Assuming PULSE_WIDTH fits in 5 bits for this example.
    reg [4:0] count = 0;
    reg active = 0;

    // Detect rising edge of trigger synchronously
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trigger_d <= 1'b0;
        end else begin
            trigger_d <= trigger;
        end
    end
    // Generate trigger pulse for one clock cycle
    wire trigger_posedge = trigger & ~trigger_d;

    // State machine and counter logic for pulse generation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pulse <= 1'b0;
            count <= 0;
            active <= 1'b0;
        // Start pulse generation on the detected rising edge of trigger
        // Ensure PULSE_WIDTH > 0 for meaningful operation
        end else if (trigger_posedge && PULSE_WIDTH > 0) begin
            pulse <= 1'b1;
            // If PULSE_WIDTH is 1, it should end in the next cycle.
            // Initialize count to 0. It will increment to 1 next cycle.
            count <= 0;
            active <= 1'b1;
        // If the pulse generation is active
        end else if (active) begin
            // Check if the pulse duration is met.
            // Count reaches PULSE_WIDTH-1 after PULSE_WIDTH cycles.
            if (count == PULSE_WIDTH - 1) begin
                pulse <= 1'b0; // End the pulse
                count <= 0;    // Reset counter
                active <= 1'b0; // Go inactive
            end else begin
                pulse <= 1'b1; // Keep pulse active
                count <= count + 1'b1; // Increment counter
                active <= 1'b1; // Remain active
            end
        // If not triggered and not active, keep pulse low
        end else begin
             pulse <= 1'b0;
             // count and active remain 0 or reset values if needed
             // active <= 1'b0; // Already inactive or reset
             // count <= 0; // Already 0 or reset
        end
    end

endmodule

module delayed_monostable(
    input clk,
    input reset,
    input trigger,
    output pulse
);
    parameter DELAY_WIDTH = 2;  // Example width, ensure > 0
    parameter SIGNAL_WIDTH = 4; // Example width, ensure > 0

    wire dly_pulse; // Pulse indicating delay period is active

    // First monostable generates a delay pulse based on DELAY_WIDTH
    monostable #(
        .PULSE_WIDTH(DELAY_WIDTH)
    ) delay_gen (
        .clk(clk),
        .reset(reset),
        .trigger(trigger), // Triggered by the external trigger
        .pulse(dly_pulse)
    );

    // Register the delay pulse to detect its falling edge
    reg dly_pulse_d = 0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            dly_pulse_d <= 1'b0;
        end else begin
            dly_pulse_d <= dly_pulse;
        end
    end

    // Detect falling edge of dly_pulse (indicates end of delay period)
    // This signal acts as the trigger for the second monostable
    wire delay_end_trigger = ~dly_pulse & dly_pulse_d;


    // Second monostable generates the final signal pulse, triggered by the end of the delay
    monostable #(
        .PULSE_WIDTH(SIGNAL_WIDTH)
    ) signal_gen (
        .clk(clk),
        .reset(reset),
        .trigger(delay_end_trigger), // Triggered by the falling edge of delay pulse
        .pulse(pulse)                // Final delayed output pulse
    );

endmodule