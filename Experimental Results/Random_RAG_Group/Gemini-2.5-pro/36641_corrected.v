`default_nettype none
`default_nettype none
module pwm_led(
    input wire clk,
    input wire rst_n, // Added reset input
    input wire test_i, // Added test mode input
    output wire [7:0] ledb
);

wire clk_1ms_internal;
wire clk_1s_internal;
wire dft_clk_1ms;
wire dft_clk_1s;

prescaler
       #(.N(18))
       T1S (
         .clk_in(clk),
         // .rst_n(rst_n), // Assuming prescaler has reset
         .ena(1'b1), // Enable should ideally be controllable in test mode
         .clk_out(clk_1s_internal)
         );

prescaler
       #(.N(6))
       T1MS (
         .clk_in(clk),
         // .rst_n(rst_n), // Assuming prescaler has reset
         .ena(1'b1), // Enable should ideally be controllable in test mode
         .clk_out(clk_1ms_internal)
         );

// Clock MUX for DFT
assign dft_clk_1ms = test_i ? clk : clk_1ms_internal;
assign dft_clk_1s = test_i ? clk : clk_1s_internal;


reg [7:0] cont = 0;
always @ (posedge dft_clk_1ms or negedge rst_n) begin // Use muxed clock and async reset
  if (!rst_n) begin
    cont <= 8'b0;
  end else begin
    // In test mode, the prescaler generating clk_1ms is bypassed,
    // so incrementing based on the faster 'clk' might not be desired functionally.
    // However, for scan test, we need the FF to be clocked by a controllable clock.
    // Assuming functional behavior during test is not the primary goal here,
    // but rather making the FF scannable.
    // If enable logic is needed during test, it should be added.
    if (!test_i) begin // Functional increment only in normal mode
       cont <= cont + 1;
    end else begin
       cont <= cont; // Or driven by scan input during shift
    end
  end
end

wire [7:0] pulse_width;
reg [8:0] pulse_width_ud = 0;
always @ ( posedge dft_clk_1s or negedge rst_n) begin // Use muxed clock and async reset
  if (!rst_n) begin
    pulse_width_ud <= 9'b0;
  end else begin
    // Similar consideration as above for test mode behavior vs scan capability.
    if (!test_i) begin // Functional increment only in normal mode
      pulse_width_ud <= pulse_width_ud + 9'b0_0000_1000;
    end else begin
       pulse_width_ud <= pulse_width_ud; // Or driven by scan input during shift
    end
  end
end

wire a = pulse_width_ud[8];
assign pulse_width = pulse_width_ud[7:0] ^ {8{a}}; // Corrected replication

wire pwm;
assign pwm = (cont >= pulse_width) ? 1'b0 : 1'b1; // Corrected comparison logic if needed, original seems okay

assign ledb[7:0] =  { 8{pwm} };

endmodule

// Assuming prescaler module definition (remains unchanged unless it has internal DFT issues)
// Example placeholder:
module prescaler #(parameter N=1) (input wire clk_in, /* input wire rst_n, */ input wire ena, output wire clk_out);
  reg [N-1:0] count = 0;
  assign clk_out = (count == {N{1'b1}}); // Example output logic
  always @(posedge clk_in /* or negedge rst_n */) begin
    // if (!rst_n) count <= 0; else
    if (ena) begin
      if (clk_out) // Reset counter when output pulse is generated
        count <= 0;
      else
        count <= count + 1;
    end
    // else count <= count; // Optional: hold count when not enabled
  end
endmodule
`default_nettype wire // Set back to default