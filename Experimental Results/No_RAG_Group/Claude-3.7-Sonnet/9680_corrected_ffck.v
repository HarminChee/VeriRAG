module PWM_INTERFACE (
  input CLK_IN,                                       
  input [7:0] PWM_DCycle,                             
  output reg PWM_OUT                                  
);

parameter [4:0] N = 31, K=1;                        
reg [31:0] clk_div;                              
reg [7:0] pwm_cnt;                              

always @(posedge CLK_IN) begin
  if (clk_div == N) begin
    clk_div <= 0;
    pwm_cnt <= pwm_cnt + 1;
  end
  else begin
    clk_div <= clk_div + K;
  end
  
  if (pwm_cnt <= PWM_DCycle && PWM_DCycle != 0)
    PWM_OUT <= 1;
  else 
    PWM_OUT <= 0;
end

endmodule