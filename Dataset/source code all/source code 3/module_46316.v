`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module led_flasher
          (
           clk,
			  LED_flash,
			  LED_out
          );
input clk;
input LED_flash;
output LED_out;
parameter HIGH_PERIOD = 600; 
parameter LOW_PERIOD = 600; 
parameter s_reset = 2'd0;
parameter s_off = 2'd1;
parameter s_on = 2'd2;
reg[15:0] cnt = 0;
reg [1:0] state = 2'd0;
always @(posedge clk) begin
		case(state)
			s_reset:
				begin
					cnt  <= 16'd0;
					state <= (LED_flash) ? s_on : s_reset;
				end
			s_off: 
				begin
					state <= (cnt == LOW_PERIOD && LED_flash) ? s_on : 
								(!LED_flash) ? s_reset : 
								s_off;
					cnt <= (cnt == LOW_PERIOD && LED_flash) ? 16'd0 : cnt + 16'd1;
				end
			s_on: 
				begin
					state <= (cnt == HIGH_PERIOD && LED_flash) ? s_off : 
								(!LED_flash) ? s_reset : 
								s_on;
					cnt <= (cnt == HIGH_PERIOD && LED_flash) ? 16'd0 : cnt + 16'd1;
				end
		endcase
end
assign LED_out = (state == s_on);
endmodule
