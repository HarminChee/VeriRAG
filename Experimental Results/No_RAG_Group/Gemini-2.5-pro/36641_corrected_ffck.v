`default_nettype none
module 1_corrected_ffc (
    input wire clk,
    input wire rst_n, // Added reset for proper initialization and testability
    output wire [7:0] ledb
);

// Parameters for counter limits based on original prescaler N values (2^N)
localparam COUNT_1MS_MAX = (1 << 6) - 1; // N=6 -> 2^6 - 1 = 63
localparam COUNT_1S_MAX  = (1 << 18) - 1; // N=18 -> 2^18 - 1 = 262143

// Counter to generate 1ms enable pulse (based on original N=6)
reg [$clog2(COUNT_1MS_MAX+1)-1:0] count_1ms = 0;
wire ena_1ms;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    count_1ms <= 0;
  end else begin
    if (count_1ms == COUNT_1MS_MAX) begin
      count_1ms <= 0;
    end else begin
      count_1ms <= count_1ms + 1;
    end
  end
end
assign ena_1ms = (count_1ms == COUNT_1MS_MAX);

// Counter to generate 1s enable pulse (based on original N=18)
reg [$clog2(COUNT_1S_MAX+1)-1:0] count_1s = 0;
wire ena_1s;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    count_1s <= 0;
  end else begin
    if (count_1s == COUNT_1S_MAX) begin
      count_1s <= 0;
    end else begin
      count_1s <= count_1s + 1;
    end
  end
end
assign ena_1s = (count_1s == COUNT_1S_MAX);


// PWM counter, clocked by primary clock 'clk', enabled by 'ena_1ms'
reg [7:0] cont = 0;
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cont <= 8'd0;
    end else if (ena_1ms) begin
        cont <= cont + 1;
    end
end

// Pulse width update register, clocked by primary clock 'clk', enabled by 'ena_1s'
reg [8:0] pulse_width_ud = 0;
always @ ( posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
        pulse_width_ud <= 9'd0;
    end else if (ena_1s) begin
        // Increment by 8 as in original logic (9'b0_0000_1000)
        pulse_width_ud <= pulse_width_ud + 9'd8;
    end
end

// Combinational logic for pulse width calculation and PWM generation
wire a = pulse_width_ud[8];
wire [7:0] pulse_width = pulse_width_ud[7:0] ^ {8{a}}; // XOR with replicated MSB
wire pwm;
assign pwm = (cont < pulse_width); // PWM is high when counter is less than pulse width
assign ledb[7:0] = {8{pwm}}; // Drive all LEDs with the same PWM signal

endmodule
`default_nettype wire // Reset default nettype