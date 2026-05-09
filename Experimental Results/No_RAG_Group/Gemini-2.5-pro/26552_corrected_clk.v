module gearbox_corrected_clk (
    clk,
    phaseA,
    phaseB,
    step_pulse
);
    parameter COUNT_BITS = 32;
    parameter CLKF = 53200000;
    parameter REGTICKSX = 19;
    parameter REGTICKS = 1 << REGTICKSX;
    parameter STEP_PULSE_TICKS = 5;
    parameter m = 1;
    parameter d = 1;
    // Note: MPE calculation might result in truncation if integer division is implied.
    // Ensure this calculation matches the intended floating-point value if necessary.
    // Example: 200 * 32 * 6 / 1600 = 38400 / 1600 = 24.
    // If MPE = 7.5 was intended, parameter definition needs care. Assuming 24 here.
    parameter MPE = (200 * 32 * 6) / 1600;
    parameter MXMPE = m * MPE;

    input clk; // Primary clock input
    input phaseA;
    input phaseB;
    output step_pulse;

    // Internal signals from sub-modules
    wire encoder_step_raw; // Raw output from quad_detector
    wire encoder_up_raw;   // Raw output from quad_detector
    wire motor_step;

    // Registers clocked by the primary clock 'clk'
    reg [COUNT_BITS - 1:0] encoder_position = 0;
    reg [COUNT_BITS - 1:0] scaled_encoder_position = 0;
    reg [COUNT_BITS - 1:0] scaled_motor_position = 0;
    reg signed [COUNT_BITS - 1:0] step_freq_m; // Made signed based on calculation
    reg [COUNT_BITS - 1:0] step_freq_d;
    reg [31:0] step_pulse_timer = 0;
    reg [COUNT_BITS - 1:0] prev_encoder_position = 0;
    reg [31:0] reg_tick_counter = 0;

    // Instantiate sub-modules
    // It's assumed quad_detector and reciprocal_divider are DFT-clean internally
    // or their DFT handling is managed separately.
    quad_detector qd (
        .clk(clk), // Assuming quad_detector uses clk internally
        .phaseA(phaseA),
        .phaseB(phaseB),
        .encoder_step(encoder_step_raw),
        .encoder_up(encoder_up_raw)
    );

    reciprocal_divider rd (
        .clk(clk),
        .numer(step_freq_m), // Ensure port names match actual module
        .denom(step_freq_d), // Ensure port names match actual module
        .step_out(motor_step)  // Ensure port names match actual module
    );

    assign step_pulse = (step_pulse_timer > 0);

    // --- CLKNPI Fix: Synchronize and edge-detect encoder signals ---

    // Synchronize raw signals from quad_detector to the main clock domain 'clk'
    // This prevents metastability if quad_detector outputs are asynchronous to clk
    reg encoder_step_ff1, encoder_step_ff2;
    reg encoder_up_ff1, encoder_up_ff2;

    always @(posedge clk) begin
        encoder_step_ff1 <= encoder_step_raw;
        encoder_step_ff2 <= encoder_step_ff1; // Synchronized encoder_step
        encoder_up_ff1 <= encoder_up_raw;
        encoder_up_ff2 <= encoder_up_ff1;   // Synchronized encoder_up
    end

    wire encoder_step_sync = encoder_step_ff2;
    wire encoder_up_sync = encoder_up_ff2;

    // Detect the rising edge of the synchronized encoder_step signal
    reg encoder_step_sync_prev;
    wire encoder_step_posedge;

    always @(posedge clk) begin
        encoder_step_sync_prev <= encoder_step_sync;
    end

    // Detect rising edge: current is high, previous was low
    assign encoder_step_posedge = encoder_step_sync & ~encoder_step_sync_prev;

    // --- End CLKNPI Fix ---


    // Main logic blocks, all clocked by the primary clock 'clk'

    // Frequency calculation logic
    always @(posedge clk) begin
        if (reg_tick_counter == 0) begin
            // Use synchronized signals if needed, assuming calculation happens less frequently
            // Calculation uses potentially wide signals, ensure correct signedness and width
            step_freq_m <= $signed(2 * scaled_encoder_position) - $signed(prev_encoder_position) - $signed(scaled_motor_position);
            step_freq_d <= d << REGTICKSX;
            //$display($time, " Scaled Enc Pos: %d, Delta: %d, Scaled Motor Pos: %d, Freq_m: %d",
            //         scaled_encoder_position, $signed(scaled_encoder_position) - $signed(prev_encoder_position), scaled_motor_position, step_freq_m);
            prev_encoder_position <= scaled_encoder_position;
            reg_tick_counter <= REGTICKS - 1; // Reset counter correctly
        end else begin
            reg_tick_counter <= reg_tick_counter - 1;
        end
    end

    // Motor step and step pulse timer logic
    always @(posedge clk) begin
        if (motor_step == 1'b1) begin // Check for active motor step signal
            scaled_motor_position <= scaled_motor_position + d;
            step_pulse_timer <= STEP_PULSE_TICKS; // Start pulse timer
        end else if (step_pulse_timer > 0) begin // If no new step, decrement timer
            step_pulse_timer <= step_pulse_timer - 1;
        end
        // else: step_pulse_timer remains 0 if it was 0 and motor_step is not 1.
    end

    // Encoder position update logic (previously clocked by encoder_step)
    // Now clocked by clk and enabled by the detected edge 'encoder_step_posedge'
    always @(posedge clk) begin
        if (encoder_step_posedge) begin // Update only on the detected rising edge
            if (encoder_up_sync) begin // Use the synchronized direction signal
                encoder_position <= encoder_position + 1;
                scaled_encoder_position <= scaled_encoder_position + MXMPE;
            end else begin
                encoder_position <= encoder_position - 1;
                scaled_encoder_position <= scaled_encoder_position - MXMPE;
            end
        end
    end

endmodule

// Dummy definition for quad_detector (replace with actual or ensure it's DFT clean)
module quad_detector(
    input clk,
    input phaseA,
    input phaseB,
    output reg encoder_step,
    output reg encoder_up
);
    // Example: Simplified logic, may not reflect actual quadrature decoding
    reg phaseA_d, phaseB_d;
    reg state, last_state;

    always @(posedge clk) begin
        phaseA_d <= phaseA;
        phaseB_d <= phaseB;
        last_state <= state;
        state <= {phaseA, phaseB};

        encoder_step <= 1'b0; // Default
        // Basic edge detection and direction logic (example only)
        if (state != last_state) begin
             encoder_step <= 1'b1;
             // Simplified direction check
             case ({last_state, state})
                4'b0001, 4'b0111, 4'b1110, 4'b1000: encoder_up <= 1'b1; // Clockwise
                4'b0010, 4'b1011, 4'b1101, 4'b0100: encoder_up <= 1'b0; // Counter-clockwise
                default: encoder_up <= encoder_up; // No change on error/bounce
             endcase
        end
    end
endmodule

// Dummy definition for reciprocal_divider (replace with actual or ensure it's DFT clean)
module reciprocal_divider(
    input clk,
    input signed [31:0] numer, // Assuming signed input based on calculation
    input [31:0] denom,
    output reg step_out
);
    // Example: Simplified accumulator logic, not a real reciprocal divider
    reg signed [63:0] accumulator = 0; // Wider accumulator, signed

    always @(posedge clk) begin
        step_out <= 1'b0; // Default to no step

        if (denom != 0) begin
            // This logic represents rate accumulation, not true division
            accumulator <= accumulator + numer; // Add signed numerator
            // Check if magnitude crosses threshold (represented by denom)
            // This comparison logic needs careful design for signed numbers
            if ((numer >= 0 && accumulator >= $signed({1'b0, denom})) || (numer < 0 && accumulator <= -$signed({1'b0, denom})) ) begin
                 step_out <= 1'b1;
                 // Adjust accumulator based on sign
                 accumulator <= (numer >= 0) ? accumulator - $signed({1'b0, denom}) : accumulator + $signed({1'b0, denom});
            end
        end else begin
            // Handle denom = 0 case, e.g., reset accumulator
            accumulator <= 0;
        end
    end
endmodule