module monostable(
    input clk,
    input reset,
    input trigger,
    output reg pulse = 0
);
    parameter PULSE_WIDTH = 0;
    reg [4:0] count = 0;
    reg trig_d = 0, trig_q = 0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trig_d <= 0;
            trig_q <= 0;
        end else begin
            trig_d <= trigger;
            trig_q <= trig_d;
        end
    end
    wire rising_edge = ~trig_q & trig_d;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pulse <= 1'b0;
            count <= 0;
        end else begin
            if (rising_edge) begin
                pulse <= 1'b1;
                count <= 0;
            end else if (pulse) begin
                if (count == PULSE_WIDTH) begin
                    pulse <= 1'b0;
                    count <= 0;
                end else begin
                    count <= count + 1'b1;
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