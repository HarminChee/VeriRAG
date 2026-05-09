`default_nettype none
module pwm_led(
  input wire clk,
  input wire rst_n,
  output wire [7:0] ledb
);

reg [17:0] prescale_1s = 0;
reg [5:0] prescale_1ms = 0;
reg [7:0] cont = 0;
reg [8:0] pulse_width_ud = 0;
reg [7:0] pulse_width = 0;
reg pwm = 0;

// Generate control signals directly from primary clock
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    prescale_1s <= 0;
    prescale_1ms <= 0;
    cont <= 0;
    pulse_width_ud <= 0;
    pulse_width <= 0;
    pwm <= 0;
  end
  else begin
    // 1ms counter
    if (prescale_1ms == 6'd63) begin
      prescale_1ms <= 0;
      cont <= cont + 1;
    end
    else begin
      prescale_1ms <= prescale_1ms + 1;
    end

    // 1s counter
    if (prescale_1s == 18'd262143) begin
      prescale_1s <= 0;
      pulse_width_ud <= pulse_width_ud + 9'b0_0000_1000;
      pulse_width <= pulse_width_ud[8] ? ~pulse_width_ud[7:0] : pulse_width_ud[7:0];
    end
    else begin
      prescale_1s <= prescale_1s + 1;
    end

    // PWM generation
    pwm <= (cont >= pulse_width) ? 1'b0 : 1'b1;
  end
end

assign ledb = {8{pwm}};

endmodule