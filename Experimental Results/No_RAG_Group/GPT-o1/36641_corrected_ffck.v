`default_nettype none
module pwm_led_corrected_ffc(
  input  wire        clk,
  output wire [7:0]  ledb
);

wire clk_1ms;
wire clk_1s;

prescaler
  #(.N(18))
  T1S (
    .clk_in(clk),
    .ena(1'b1),
    .clk_out(clk_1s)
  );

prescaler
  #(.N(6))
  T1MS (
    .clk_in(clk),
    .ena(1'b1),
    .clk_out(clk_1ms)
  );

reg  [7:0] cont = 0;
reg        clk_1ms_d;
wire       clk_1ms_rise;

assign clk_1ms_rise = ~clk_1ms_d & clk_1ms;

always @(posedge clk) begin
  clk_1ms_d <= clk_1ms;
  if (clk_1ms_rise) begin
    cont <= cont + 1;
  end
end

wire [7:0] pulse_width;
reg  [8:0] pulse_width_ud = 0;
reg        clk_1s_d;
wire       clk_1s_rise;

assign clk_1s_rise = ~clk_1s_d & clk_1s;

always @(posedge clk) begin
  clk_1s_d <= clk_1s;
  if (clk_1s_rise) begin
    pulse_width_ud <= pulse_width_ud + 9'b0_0000_1000;
  end
end

wire a = pulse_width_ud[8];
assign pulse_width = pulse_width_ud[7:0] ^ {a,a,a,a,a,a,a,a};

wire pwm;
assign pwm = (cont >= pulse_width) ? 1'b0 : 1'b1;
assign ledb[7:0] = {8{pwm}};

endmodule