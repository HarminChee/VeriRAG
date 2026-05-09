module monostable(
    input clk,
    input reset,
    input trigger,
    output reg pulse
);
    parameter PULSE_WIDTH = 1;
    reg [31:0] count = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pulse <= 1'b0;
            count <= 0;
        end else begin
            if (trigger) begin
                pulse <= 1'b1;
                count <= 0;
            end else if (pulse && (count < PULSE_WIDTH)) begin
                count <= count + 1;
            end else begin
                pulse <= 1'b0;
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
    parameter DELAY_WIDTH = 1;
    parameter SIGNAL_WIDTH = 1;

    wire dly;
    wire trig;

    monostable #(DELAY_WIDTH) delay_inst (
        .clk(clk),
        .reset(reset),
        .trigger(trigger),
        .pulse(dly)
    );

    assign trig = ~dly;

    monostable #(SIGNAL_WIDTH) signal_inst (
        .clk(clk),
        .reset(reset),
        .trigger(trig),
        .pulse(pulse)
    );

endmodule