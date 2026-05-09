module monostable(
        input clk,
        input reset,
        input trigger,
        input test_i,
        input scan_trigger,
        output reg pulse = 0
);
        parameter PULSE_WIDTH = 0;
        reg [4:0] count = 0;
        wire count_rst = reset | (count == PULSE_WIDTH);
        wire dft_trigger = test_i ? scan_trigger : trigger;
        always @ (posedge dft_trigger, posedge count_rst) begin
                if (count_rst) begin
                        pulse <= 1'b0;
                end else begin
                        pulse <= 1'b1;
                end
        end
        always @ (posedge clk, posedge count_rst) begin
                if(count_rst) begin
                        count <= 0;
                end else begin
                        if(pulse) begin
                                count <= count + 1'b1;
                        end
                end
        end
endmodule
module delayed_monostable(
        input clk,
        input reset,
        input trigger,
        input test_i,
        input scan_trigger,
        output pulse
);
        parameter DELAY_WIDTH = 0;
        parameter SIGNAL_WIDTH = 0;
        wire dly;
        monostable #(.PULSE_WIDTH(DELAY_WIDTH)) delay(
                .clk(clk),
                .reset(reset),
                .trigger(trigger),
                .test_i(test_i),
                .scan_trigger(scan_trigger),
                .pulse(dly)
        );
        wire trig = ~dly;
        monostable #(.PULSE_WIDTH(SIGNAL_WIDTH)) signal(
                .clk(clk),
                .reset(reset),
                .trigger(trig),
                .test_i(test_i),
                .scan_trigger(scan_trigger),
                .pulse(pulse)
        );
endmodule