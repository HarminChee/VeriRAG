module multiSRC_onboard(
	input SYSCLK_N,
	input SYSCLK_P,
	input GPIO_SW_RIGHT,
	input GPIO_SW_CENTER,
    input test_i,
    input scan_clk,
    input scan_rst_n, // Added dedicated test reset input
	output GPIO_LED_CENTER,
	output GPIO_LED_LEFT,
	output GPIO_LED_RIGHT
);
wire test_start;
wire test_done; // Wire to connect TB output
wire test_pass;
wire clk;
wire dft_clk;
wire rst; // Functional reset
wire dft_rst; // Combined reset for DFT (active high)
wire dft_pll_reset; // Muxed reset for PLL (active high)
reg [26:0] cnt;
wire locked;

// DFT Clock Mux
assign dft_clk = test_i ? scan_clk : clk;

// Functional Reset Assignment (Assuming active-high reset internally)
assign rst = GPIO_SW_CENTER;

// DFT Reset Mux (Active high)
// Use dedicated scan reset (active high derived from active-low scan_rst_n) in test mode,
// Use functional reset (rst) in functional mode.
assign dft_rst = test_i ? ~scan_rst_n : rst;

// DFT PLL Reset Mux (Active high) - Assuming PLL reset is also active high
assign dft_pll_reset = test_i ? ~scan_rst_n : rst;

// Counter with DFT clock and DFT reset (asynchronous active high)
always @(posedge dft_clk, posedge dft_rst) begin
	if(dft_rst) begin
		cnt <= 27'b0;
	end else begin
		cnt <= cnt + 1'b1;
	end
end

wire ap_start;
wire ap_ready;
wire ap_idle;
wire ap_done;
wire dut_rst; // Reset signal going into DUT from TB (controlled by TB)
wire vld_x;
wire vld_y;
wire [15:0] x;
wire [2:0]  rat;
wire [47:0] y;


assign test_start=GPIO_SW_RIGHT;
assign GPIO_LED_CENTER=test_pass;
assign GPIO_LED_RIGHT=cnt[26];
assign GPIO_LED_LEFT=locked;

// PLL Instance - Using muxed DFT reset
clk_wiz_0 CLKPLL
 (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk),
  .reset(dft_pll_reset), // Use muxed DFT reset for PLL
  .locked(locked)
 );

// Test Bench Instance with DFT clock and DFT reset
// Ensure these port names/directions match the test_bench_onboard module definition
test_bench_onboard TB
(
	.clk(dft_clk),
	.rst(dft_rst), // Use combined DFT reset
	.test_start(test_start), // Input from GPIO
	.test_done(test_done), // Output, connected but maybe unused locally
	.test_pass(test_pass), // Output to LED
	.ap_ready(ap_ready), // Input from DUT
	.ap_idle(ap_idle),   // Input from DUT
	.ap_done(ap_done),   // Input from DUT
	.dut_vld_y(vld_y), // Input from DUT
	.dut_y(y),       // Input from DUT
	.dut_rst(dut_rst),   // Output to DUT
	.dut_start(ap_start), // Output to DUT
	.dut_vld_x(vld_x), // Output to DUT
	.dut_x(x),       // Output to DUT
	.dut_rat(rat)    // Output to DUT
);

// DUT Instance with DFT clock. Reset comes from TB's dut_rst output.
// Ensure these port names/directions match the multiSRC module definition
multiSRC DUT(
        .ap_clk(dft_clk),    // Input DFT clock
        .ap_rst(dut_rst),    // Input reset from TB
        .ap_start(ap_start), // Input start from TB
        .ap_done(ap_done),   // Output to TB
        .ap_idle(ap_idle),   // Output to TB
        .ap_ready(ap_ready), // Output to TB
        .vld_i(vld_x),     // Input data valid from TB
        .x_i_V(x),       // Input data from TB
        .rat_i_V(rat),     // Input data from TB
        .vld_o(vld_y),     // Output data valid to TB
        .y_o_V(y)        // Output data to TB
);
endmodule