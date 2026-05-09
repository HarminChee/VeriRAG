module gearbox(
    input  wire clk,
    input  wire phaseA,
    input  wire phaseB,
    output wire step_pulse
);
    parameter COUNT_BITS        = 32;
    parameter CLKF              = 53200000;
    parameter REGTICKSX         = 19;
    parameter REGTICKS          = 1 << REGTICKSX;
    parameter STEP_PULSE_TICKS  = 5;
    parameter m                 = 1;
    parameter d                 = 1;
    parameter MPE               = 200 * 32 * 6 / 1600;
    parameter MXMPE             = m * MPE;

    wire encoder_step;
    wire encoder_up;
    wire motor_step;

    reg [COUNT_BITS-1:0] encoder_position       = 0;
    reg [COUNT_BITS-1:0] scaled_encoder_position= 0;
    reg [COUNT_BITS-1:0] scaled_motor_position  = 0;
    reg [COUNT_BITS-1:0] step_freq_m           = 0;
    reg [COUNT_BITS-1:0] step_freq_d           = 0;

    reg [COUNT_BITS-1:0] prev_encoder_position  = 0;
    reg [31:0] reg_tick_counter                = 0;
    reg [31:0] step_pulse_timer                = 0;

    quad_detector qd(
        .clk(clk),
        .phaseA(phaseA),
        .phaseB(phaseB),
        .step(encoder_step),
        .up(encoder_up)
    );

    reciprocal_divider rd(
        .clk(clk),
        .numerator(step_freq_m),
        .denominator(step_freq_d),
        .pulse(motor_step)
    );

    assign step_pulse = (step_pulse_timer > 0);

    always @(posedge clk) begin
        if (reg_tick_counter == 0) begin
            step_freq_m <= (2 * scaled_encoder_position) - prev_encoder_position - scaled_motor_position;
            step_freq_d <= (d << REGTICKSX);
            $display("%d %d %d %d", scaled_encoder_position, scaled_encoder_position - prev_encoder_position, scaled_motor_position, step_freq_m);
            prev_encoder_position <= scaled_encoder_position;
            reg_tick_counter <= REGTICKS;
        end else begin
            reg_tick_counter <= reg_tick_counter - 1;
        end
    end

    always @(posedge clk) begin
        if (motor_step == 1'b1) begin
            scaled_motor_position <= scaled_motor_position + d;
            step_pulse_timer <= STEP_PULSE_TICKS;
        end
        if (step_pulse_timer > 0) begin
            step_pulse_timer <= step_pulse_timer - 1;
        end
    end

    always @(posedge encoder_step) begin
        if (encoder_up) begin
            encoder_position <= encoder_position + 1;
            scaled_encoder_position <= scaled_encoder_position + MXMPE;
        end else begin
            encoder_position <= encoder_position - 1;
            scaled_encoder_position <= scaled_encoder_position - MXMPE;
        end
    end
endmodule