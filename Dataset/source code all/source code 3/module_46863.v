`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module light_up
          (
           clk,
			  header,
			  counter,
			  tachy_pin,
			  brady_pin,
			  normal_pin
          );
input clk;
input[7:0] header;
input[31:0] counter;
output tachy_pin;
output brady_pin;
output normal_pin;
parameter FAST_BEAT = 32'd750; 
parameter SLOW_BEAT = 32'd1800; 
parameter CORRECT_HEAD1 = 8'd4; 
parameter CORRECT_HEAD2 = 8'd6; 
reg brady_flash;
reg tachy_flash;
reg[31:0] counter_previous;
wire[31:0] difference; 
wire correct_header;
wire too_fast;
wire too_slow;
assign correct_header = (header == CORRECT_HEAD1 || header == CORRECT_HEAD2);
assign difference = counter - counter_previous;
assign too_fast = difference <= FAST_BEAT;
assign too_slow = difference >= SLOW_BEAT;
always @(posedge clk) begin
	if (correct_header) begin
		tachy_flash <= too_fast;
		brady_flash <= too_slow;
		counter_previous <= counter;
	end
end
led_flasher tachy_flasher
          (
           .clk(clk),
			  .LED_flash(tachy_flash),
			  .LED_out(tachy_pin)
          );
led_flasher brady_flasher
          (
           .clk(clk),
			  .LED_flash(brady_flash),
			  .LED_out(brady_pin)
          );
assign normal_pin = !tachy_flash && !brady_flash;
endmodule
