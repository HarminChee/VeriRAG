module monostable_corrected_ffc(
        input clk,
        input reset,
        input trigger,
        output reg pulse = 0
);
        parameter PULSE_WIDTH = 0;
        reg [4:0] count = 0;
        reg count_rst = 0;
        
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                count_rst <= 1'b1;
            end else begin
                count_rst <= (count == PULSE_WIDTH);
            end
        end
        
        always @(posedge clk or posedge reset) begin
                if (reset) begin
                        pulse <= 1'b0;
                end else if (count_rst) begin
                        pulse <= 1'b0;
                end else if (trigger) begin
                        pulse <= 1'b1;
                end
        end
        
        always @(posedge clk or posedge reset) begin
                if (reset) begin
                        count <= 0;
                end else if (count_rst) begin
                        count <= 0;
                end else if (pulse) begin
                        count <= count + 1'b1;
                end
        end
endmodule

module delayed_monostable_corrected_ffc(
        input clk,
        input reset,
        input trigger,
        output pulse
);
        parameter DELAY_WIDTH = 0;
        parameter SIGNAL_WIDTH = 0;
        wire dly;
        
        monostable_corrected_ffc #(.PULSE_WIDTH(DELAY_WIDTH)) delay(
                .clk(clk),
                .reset(reset),
                .trigger(trigger),
                .pulse(dly)
        );
        
        wire trig = ~dly;
        
        monostable_corrected_ffc #(.PULSE_WIDTH(SIGNAL_WIDTH)) signal(
                .clk(clk),
                .reset(reset),
                .trigger(trig),
                .pulse(pulse)
        );
endmodule