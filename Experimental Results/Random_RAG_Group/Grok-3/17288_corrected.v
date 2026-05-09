module monostable(
        input clk,
        input reset,
        input trigger,
        input test_i,
        output reg pulse = 0
);
        parameter PULSE_WIDTH = 0;
        reg [4:0] count = 0;
        wire dft_clk = test_i ? clk : clk;
        wire dft_reset = test_i ? reset : (reset | (count == PULSE_WIDTH));
        always @ (posedge trigger, posedge dft_reset) begin
                if (dft_reset) begin
                        pulse <= 1'b0;
                end else begin
                        pulse <= 1'b1;
                end
        end
        always @ (posedge dft_clk, posedge dft_reset) begin
                if(dft_reset) begin
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
                .pulse(dly)
        );
        wire trig = ~dly;
        monostable #(.PULSE_WIDTH(SIGNAL_WIDTH)) signal(
                .clk(clk),
                .reset(reset),
                .trigger(trig),
                .test_i(test_i),
                .pulse(pulse)
        );
endmodule