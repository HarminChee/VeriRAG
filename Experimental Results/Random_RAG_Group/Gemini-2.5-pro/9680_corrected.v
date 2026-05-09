module PWM_INTERFACE (
  input CLK_IN,
  input RST_N, // Added synchronous reset for DFT
  input test_i, // Added test mode input for DFT
  input [7:0] PWM_DCycle,
  output reg PWM_OUT
  );

  // Use original N parameter default if desired, using smaller value for clarity/simulation
  parameter [4:0] N = 5; // Original: 31. N determines PWM period bit index.
  parameter K = 1;       // Increment step for divider counter

  // Calculate width needed for the divider counter to ensure rollover period related to N
  localparam DIV_WIDTH = N + 1;
  // Calculate the maximum value for the counter based on its width
  localparam DIV_MAX_VAL = (1 << DIV_WIDTH) - 1; // Equivalent to {DIV_WIDTH{1'b1}}

  reg [DIV_WIDTH-1:0] clk_div = 0;
  reg [7:0]  pwm_clk = 0;
  wire pwm_clk_enable;

  // Clock divider counter (synchronous to primary clock CLK_IN)
  // This replaces the internally generated clock source clk_div[N]
  always @ ( posedge CLK_IN or negedge RST_N ) begin
    if (!RST_N) begin
      clk_div <= {DIV_WIDTH{1'b0}};
    end else begin
      // Increment by K, handles rollover implicitly due to fixed width
      clk_div <= clk_div + K;
    end
  end

  // Generate enable pulse for pwm_clk counter (synchronous)
  // Pulses high for one CLK_IN cycle when clk_div reaches its max value.
  // This defines the PWM period based on the rollover of the clk_div counter.
  // The period is 2^(N+1) / K cycles of CLK_IN.
  // Assumes K=1 for simplicity matching original example's likely intent.
  assign pwm_clk_enable = (clk_div == DIV_MAX_VAL);

  // PWM cycle counter (synchronous to primary clock CLK_IN)
  // Enabled by pwm_clk_enable, effectively clocking it at the PWM period rate.
  always @ (posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
      pwm_clk <= 8'b0;
    end else if (pwm_clk_enable) begin
      // Increment once per PWM period when enabled
      pwm_clk <= pwm_clk + 1;
    end
  end

  // PWM Output Logic (Registered and synchronous to primary clock CLK_IN)
  // Replaces the original combinational assignment to PWM_OUT
  always @ (posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
      PWM_OUT <= 1'b0;
    end else begin
      // Determine output based on current pwm_clk counter value vs Duty Cycle input
      // This logic matches the original combinational behavior but is now registered.
      if(pwm_clk <= PWM_DCycle && PWM_DCycle != 8'd0) begin
         PWM_OUT <= 1'b1;
      end else begin
         PWM_OUT <= 1'b0;
      end
    end
  end

endmodule