(module 1_corrected_ffc);

module monostable(
    input  clk,
    input  reset,
    input  trigger,
    output reg pulse = 0
);
    parameter PULSE_WIDTH = 0;
    reg [4:0] count = 0;
    reg trigger_latched = 0;

    // Latch trigger to detect rising edge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trigger_latched <= 0;
        end else begin
            trigger_latched <= trigger;
        end
    end

    // Synchronous logic to generate pulse
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pulse <= 0;
            count <= 0;
        end else begin
            if (pulse) begin
                if (count == PULSE_WIDTH) begin
                    pulse <= 0;
                    count <= 0;
                end else begin
                    count <= count + 1'b1;
                end
            end else begin
                if (trigger & ~trigger_latched) begin
                    pulse <= 1;
                    count <= 0;
                end
            end
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
    wire dly;

    monostable #(.PULSE_WIDTH(DELAY_WIDTH)) delay(
        .clk(clk),
        .reset(reset),
        .trigger(trigger),
        .pulse(dly)
    );

    wire trig = ~dly;

    monostable #(.PULSE_WIDTH(SIGNAL_WIDTH)) signal(
        .clk(clk),
        .reset(reset),
        .trigger(trig),
        .pulse(pulse)
    );
endmodule

(endmodule)