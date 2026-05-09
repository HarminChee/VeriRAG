`default_nettype none
module pwm_led(input wire clk, output wire [7:0] ledb);
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
reg [7:0] cont = 0;
always @ (posedge clk_1ms) begin
  cont <= cont + 1;
end
wire [7:0] pulse_width;
reg [8:0] pulse_width_ud = 0;
always @ ( posedge clk_1s ) begin
  pulse_width_ud <= pulse_width_ud + 9'b0000_1000;
end
wire a = pulse_width_ud[8];
assign pulse_width = pulse_width_ud[7:0] ^ {a,a,a,a,a,a,a,a};
wire pwm;
assign pwm = (cont >= pulse_width) ? 0 : 1;
assign ledb[7:0] =  { 8{pwm} };
endmodule