module monostable(
    input clk,
    input reset,
    input trigger,
    output reg pulse
);
    parameter PULSE_WIDTH = 0;
    reg [4:0] count;
    wire count_rst = reset | (count == PULSE_WIDTH);

    always @(posedge clk or posedge count_rst) begin
        if (count_rst) begin
            count <= 0;
            pulse <= 1'b0;
        end else if(trigger) begin
            pulse <= 1'b1;
        end else if(pulse) begin
            count <= count + 1'b1;
            if (count == PULSE_WIDTH - 1)
                pulse <= 1'b0;
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

    monostable #(.PULSE_WIDTH(SIGNAL_WIDTH)) signal(
        .clk(clk),
        .reset(reset),
        .trigger(~dly),
        .pulse(pulse)
    );
endmodule