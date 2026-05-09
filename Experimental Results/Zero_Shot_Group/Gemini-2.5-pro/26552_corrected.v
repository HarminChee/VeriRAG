module gearbox(
    input clk,
    input phaseA,
    input phaseB,
    output step_pulse
);
    parameter COUNT_BITS = 32;
    parameter CLKF = 53200000;
    parameter REGTICKSX = 19;
    parameter REGTICKS = 1 << REGTICKSX;
    parameter STEP_PULSE_TICKS = 5;
    parameter m = 1;
    parameter d = 1;
    // Calculate MPE carefully
    parameter MPE = (200 * 32 * 6) / 1600; // Results in 24
    parameter MXMPE = m * MPE;

    // Internal signals
    reg [COUNT_BITS - 1:0] encoder_position = 0;
    reg [COUNT_BITS - 1:0] scaled_encoder_position = 0;
    reg [COUNT_BITS - 1:0] scaled_motor_position = 0;
    reg [COUNT_BITS - 1:0] step_freq_m = 0; // Initialize registers
    reg [COUNT_BITS - 1:0] step_freq_d = 0; // Initialize registers
    reg [31:0] step_pulse_timer = 0;
    reg [COUNT_BITS - 1:0] prev_encoder_position = 0;
    // Ensure reg_tick_counter has enough bits to hold REGTICKS
    reg [REGTICKSX : 0] reg_tick_counter = 0;

    // Wires for submodule connections
    wire encoder_step;
    wire encoder_up;
    wire motor_step;

    // Instantiate submodules (assuming they are defined elsewhere and ports match)
    quad_detector qd (
        .clk(clk),
        .phaseA(phaseA),
        .phaseB(phaseB),
        .encoder_step(encoder_step),
        .encoder_up(encoder_up)
    );

    reciprocal_divider rd (
        .clk(clk),
        .m(step_freq_m),         // Assuming input port name is 'm'
        .d(step_freq_d),         // Assuming input port name is 'd'
        .step_out(motor_step)    // Assuming output port name is 'step_out'
    );

    // Step pulse generation logic
    assign step_pulse = (step_pulse_timer > 0);

    // Main synchronous logic block
    always @(posedge clk) begin

        // --- Encoder position update ---
        // Synchronously update position based on quad_detector outputs
        if (encoder_step) begin // Assuming encoder_step is a 1-clock pulse
            if (encoder_up) begin
                encoder_position <= encoder_position + 1;
                scaled_encoder_position <= scaled_encoder_position + MXMPE;
            end else begin
                encoder_position <= encoder_position - 1;
                scaled_encoder_position <= scaled_encoder_position - MXMPE;
            end
        end

        // --- Step frequency calculation and timer ---
        if (reg_tick_counter == 0) begin
            // Use wider intermediate for multiplication to avoid overflow before subtraction
            // Note: Result assigned to step_freq_m (unsigned) might wrap around if negative.
            step_freq_m <= ( {1'b0, scaled_encoder_position} << 1 )
                           - prev_encoder_position
                           - scaled_motor_position;
            // Ensure shift result fits if d is large relative to COUNT_BITS
            step_freq_d <= d << REGTICKSX;

            // $display is a simulation construct
            $display("T=%t: scaled_enc=%d, delta_enc=%d, scaled_mot=%d, step_freq_m=%d",
                     $time, scaled_encoder_position, scaled_encoder_position - prev_encoder_position,
                     scaled_motor_position, step_freq_m);

            prev_encoder_position <= scaled_encoder_position;
            reg_tick_counter <= REGTICKS; // Reload counter
        end else begin
            reg_tick_counter <= reg_tick_counter - 1; // Decrement counter
        end

        // --- Motor position and step pulse timer update ---
        // Handle motor step pulse generation
        if (motor_step) begin // Check for motor step pulse from divider
            scaled_motor_position <= scaled_motor_position + d;
            step_pulse_timer <= STEP_PULSE_TICKS; // Start step pulse timer
        end else if (step_pulse_timer > 0) begin
             // Decrement timer only if it was already running and no new motor_step occurred
            step_pulse_timer <= step_pulse_timer - 1;
        end
        // Note: If motor_step arrives while timer > 0, timer is reset to STEP_PULSE_TICKS

    end

endmodule

// NOTE: The definitions for `quad_detector` and `reciprocal_divider`
// modules are required for simulation or synthesis but were not provided
// in the original request. The corrected code above assumes they exist
// with the specified port names and synchronous behavior relative to `clk`.