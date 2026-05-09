module PWM_INTERFACE_corrected_ffc (
  input CLK_IN,                                       
  input [7:0] PWM_DCycle,                             
  output reg PWM_OUT                                  
  );
  parameter [4:0] N = 31, K=1;                        
  reg [31:0] clk_div =0;                              
  reg [7:0] pwm_clk =0;                               
  reg clk_div_toggle = 0;

  always @ (posedge CLK_IN) begin
    if (clk_div == (1 << N) - 1) begin
      clk_div <= 0;
      clk_div_toggle <= ~clk_div_toggle;
    end else begin
      clk_div <= clk_div + K;
    end
  end

  always @ (posedge CLK_IN) begin
    if (clk_div_toggle) begin
      pwm_clk <= pwm_clk + 1;
    end
  end

  always @ (*) begin
    if(pwm_clk <= PWM_DCycle & PWM_DCycle != 0)
      PWM_OUT <= 1;
    else
      PWM_OUT <= 0;
  end
endmodule