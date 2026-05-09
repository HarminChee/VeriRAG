module PWM_INTERFACE_corrected_ffc (
  input CLK_IN,
  input RST_N, // Added reset for good practice and DFT
  input [7:0] PWM_DCycle,
  output reg PWM_OUT
);
  parameter [4:0] N = 31; // Bit index for derived clock edge detection
  parameter K = 1;        // Increment value for clk_div

  reg [31:0] clk_div;
  reg [7:0]  pwm_clk;
  reg        clk_div_N_dly; // Delayed version of clk_div[N] for edge detection
  wire       pwm_clk_en;
  wire       pwm_out_comb;

  // Clock divider counter
  always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
      clk_div <= 32'b0;
    end else begin
      clk_div <= clk_div + K;
    end
  end

  // Register to store the previous value of clk_div[N]
  always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
      clk_div_N_dly <= 1'b0;
    end else begin
      clk_div_N_dly <= clk_div[N];
    end
  end

  // Generate enable signal for pwm_clk based on rising edge of clk_div[N]
  // Enable is active for one CLK_IN cycle when clk_div[N] transitions 0 -> 1.
  assign pwm_clk_en = (~clk_div_N_dly && clk_div[N]);

  // PWM cycle counter, clocked by CLK_IN, enabled by pwm_clk_en
  always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
      pwm_clk <= 8'b0;
    end else if (pwm_clk_en) begin
      pwm_clk <= pwm_clk + 1;
    end
  end

  // Combinatorial logic for PWM output based on current pwm_clk count
  // PWM_OUT is high when pwm_clk is less than or equal to PWM_DCycle
  // (and PWM_DCycle is not zero, implying PWM is active).
  assign pwm_out_comb = (pwm_clk <= PWM_DCycle) && (PWM_DCycle != 8'b0);

  // Register the PWM output
  always @(posedge CLK_IN or negedge RST_N) begin
    if (!RST_N) begin
      PWM_OUT <= 1'b0;
    end else begin
      PWM_OUT <= pwm_out_comb;
    end
  end

endmodule