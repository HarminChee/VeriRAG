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
    parameter MPE = 200 * 32 * 6 / 1600;	
    parameter MXMPE = m * MPE;

    reg [COUNT_BITS - 1:0] encoder_position = 0;
    reg [COUNT_BITS - 1:0] scaled_encoder_position = 0;
    reg [COUNT_BITS - 1:0] scaled_motor_position = 0;
    reg [COUNT_BITS - 1:0] step_freq_m;
    reg [COUNT_BITS - 1:0] step_freq_d;
    wire encoder_step;
    wire encoder_up;
    wire motor_step;

    quad_detector qd(
        .clk(clk),
        .phaseA(phaseA),
        .phaseB(phaseB),
        .encoder_step(encoder_step),
        .encoder_up(encoder_up)
    );

    reciprocal_divider rd(
        .clk(clk),
        .m_in(step_freq_m),
        .d_in(step_freq_d),
        .motor_step(motor_step)
    );

    reg [31:0] step_pulse_timer = 0;
    assign step_pulse = (step_pulse_timer > 0);

    reg [COUNT_BITS - 1:0] prev_encoder_position = 0;
    reg [31:0] reg_tick_counter = 0;

    always @(posedge clk) begin
        if (reg_tick_counter == 0) begin
            step_freq_m = (2 * scaled_encoder_position) - prev_encoder_position - scaled_motor_position;
            step_freq_d = d << REGTICKSX;  
            $display(scaled_encoder_position, scaled_encoder_position - prev_encoder_position, scaled_motor_position, step_freq_m);
            prev_encoder_position = scaled_encoder_position;
            reg_tick_counter = REGTICKS;
        end
        reg_tick_counter = reg_tick_counter - 1;
    end

    always @(posedge clk) begin
        if (motor_step == 1) begin
            scaled_motor_position = scaled_motor_position + d;
            step_pulse_timer = STEP_PULSE_TICKS;
        end
        if (step_pulse_timer > 0) step_pulse_timer = step_pulse_timer - 1;
    end

    reg encoder_step_d = 0;
    reg encoder_step_rise = 0;

    always @(posedge clk) begin
        encoder_step_d <= encoder_step;
        encoder_step_rise <= ~encoder_step_d & encoder_step;
    end

    always @(posedge clk) begin
        if (encoder_step_rise) begin
            if (encoder_up) begin
                encoder_position <= encoder_position + 1;
                scaled_encoder_position <= scaled_encoder_position + MXMPE;
            end else begin
                encoder_position <= encoder_position - 1;
                scaled_encoder_position <= scaled_encoder_position - MXMPE;
            end
        end
    end
endmodule