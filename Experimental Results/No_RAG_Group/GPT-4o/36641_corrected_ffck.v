`default_nettype none
module pwm_led(input wire clk, output wire [7:0] ledb);
reg [7:0] cont = 0;
reg [8:0] pulse_width_ud = 0;
wire [7:0] pulse_width;
wire a = pulse_width_ud[8];
wire pwm;

always @ (posedge clk) begin
  cont <= cont + 1;
  pulse_width_ud <= pulse_width_ud + 9'b0_0000_1000;
end

assign pulse_width = pulse_width_ud[7:0] ^ {a,a,a,a,a,a,a,a};
assign pwm = (cont >= pulse_width) ? 0 : 1;
assign ledb[7:0] = { 8{pwm} };

endmodule