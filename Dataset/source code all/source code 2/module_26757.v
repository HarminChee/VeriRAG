module pwm_generator 
#(parameter PWM_DEPTH=8)							
(
	output reg	pwm,									
	input  wire [PWM_DEPTH-1:0] duty_cycle,	
	input  wire rst_n,								
	input  wire clk									
);
reg [PWM_DEPTH-1:0] count;							
wire pwm_next;											
assign pwm_next = (duty_cycle) ? (count <= duty_cycle) : 1'b0;
always @ (negedge rst_n, posedge clk)
begin
	if (!rst_n)
		pwm <= 1'b0;
	else
		pwm <= pwm_next;			
end
always @ (negedge rst_n, posedge clk)
begin
	if (!rst_n)
		count <= 1'b0;
	else
		count <= count + 1'b1;	
end
endmodule
