module PWM_INTERFACE (
  input CLK_IN,
  input [7:0] PWM_DCycle,     // Duty cycle (0 to 255)
  output reg PWM_OUT = 1'b0 // Registered PWM output, initialized to 0
);

  // Parameter: Set the ratio for slowing down the PWM counter relative to CLK_IN
  // Determines the PWM period length in CLK_IN cycles.
  // PWM Frequency = CLK_IN / (DIVIDER_RATIO * 256)
  // Example: If CLK_IN = 100MHz, DIVIDER_RATIO = 100,
  // PWM Freq = 100MHz / (100 * 256) = 100MHz / 25600 = 3.90625 kHz
  parameter DIVIDER_RATIO = 100;

  // Ensure DIVIDER_RATIO is at least 1 for calculations
  localparam EFF_DIVIDER_RATIO = (DIVIDER_RATIO < 1) ? 1 : DIVIDER_RATIO;

  // Calculate width needed for the clock divider counter based on effective ratio
  localparam DIV_CNT_WIDTH = $clog2(EFF_DIVIDER_RATIO);

  // Internal registers
  // Use DIV_CNT_WIDTH for the counter. If DIVIDER_RATIO is 1, width is 0, which is handled.
  reg [DIV_CNT_WIDTH > 0 ? DIV_CNT_WIDTH-1 : 0 : 0] clk_div_cnt = 0; // Counter for clock division
  reg [7:0] pwm_cnt = 0;                   // PWM phase counter (0-255)

  // Internal signal for PWM tick enable
  // Tick occurs when clk_div_cnt reaches its maximum value (DIVIDER_RATIO - 1)
  // If DIVIDER_RATIO is 1, tick is always asserted.
  wire pwm_tick;
  assign pwm_tick = (EFF_DIVIDER_RATIO == 1) ? 1'b1 : (clk_div_cnt == EFF_DIVIDER_RATIO - 1);

  // Main synchronous block clocked by CLK_IN
  always @(posedge CLK_IN) begin

    // Clock Divider Logic
    // Increments clk_div_cnt unless DIVIDER_RATIO is 1 or it's time to tick
    if (EFF_DIVIDER_RATIO > 1) begin // Only count if division is needed
        if (pwm_tick) begin
          clk_div_cnt <= 0; // Reset counter on tick
        end else begin
          clk_div_cnt <= clk_div_cnt + 1; // Increment counter
        end
    end
    // If EFF_DIVIDER_RATIO is 1, clk_div_cnt stays 0, pwm_tick is always 1.

    // PWM Counter Logic
    // Increments the 8-bit PWM counter on each pwm_tick
    if (pwm_tick) begin
      pwm_cnt <= pwm_cnt + 1; // Increments from 0 to 255, then wraps to 0
    end

    // PWM Output Logic
    // Updates the PWM output register on every CLK_IN edge.
    // Output is high if the current PWM counter value is less than the Duty Cycle value.
    // Handles the case where Duty Cycle is 0 (output always low).
    if (PWM_DCycle == 8'd0) begin
      PWM_OUT <= 1'b0; // Duty Cycle 0% -> output always low
    end else if (pwm_cnt < PWM_DCycle) begin
      PWM_OUT <= 1'b1; // Output high during the active phase
    end else begin
      // pwm_cnt >= PWM_DCycle
      PWM_OUT <= 1'b0; // Output low after the active phase
    end
  end

endmodule