module multiSRC_onboard(
	input SYSCLK_N,
	input SYSCLK_P,
	input GPIO_SW_RIGHT,
	input GPIO_SW_CENTER,
	output GPIO_LED_CENTER,
	output GPIO_LED_LEFT,
	output GPIO_LED_RIGHT,
    // DFT inputs
    input scan_en,       // Scan enable signal
    input test_clk_i,    // Test clock input
    input test_rst_i     // Test reset input (asynchronous)
);

// Internal functional signals
wire clk;             // Functional clock from PLL
wire rst;             // Functional reset (derived from primary input)
wire locked;          // PLL lock status

// DFT signals
wire dft_clk;         // Multiplexed clock for scan/functional mode
wire dft_rst;         // Multiplexed reset for scan/functional mode

// Wires for TB/DUT communication
wire test_start;
wire test_done;
wire test_pass;
wire ap_start;
wire ap_ready;
wire ap_idle;
wire ap_done;
wire vld_x;
wire vld_y;
wire [15:0] x;
wire [2:0]  rat;
wire [47:0] y;

// Counter register
reg [26:0] cnt;

// Functional reset derived directly from primary input (GPIO_SW_CENTER)
assign rst = GPIO_SW_CENTER;

// DFT clock selection: Use test clock in scan mode, functional clock otherwise
// This allows bypassing the PLL during scan testing.
assign dft_clk = scan_en ? test_clk_i : clk;

// DFT reset selection: Use asynchronous test reset in scan mode, functional reset otherwise.
// The functional reset 'rst' is derived from a primary input.
// The test reset 'test_rst_i' is a primary input.
// Therefore, 'dft_rst' is controllable from primary inputs in both modes.
assign dft_rst = scan_en ? test_rst_i : rst;

// Counter logic using DFT clock and unified asynchronous reset
// Sensitivity list includes posedge of reset, making it asynchronous.
always @(posedge dft_clk or posedge dft_rst) begin
	if(dft_rst) begin // Reset condition uses the unified DFT reset
		cnt <= 27'b0;
	end else begin
		cnt <= cnt + 1'b1;
	end
end

// Test signals and LED assignments
assign test_start = GPIO_SW_RIGHT; // Test start controlled by primary input
assign GPIO_LED_CENTER = test_pass; // Indicates test completion status
assign GPIO_LED_RIGHT = cnt[26];    // Example output driven by counter MSB
assign GPIO_LED_LEFT = locked;      // PLL lock status driven by PLL output

// PLL instantiation
// Uses unified DFT reset (dft_rst) to ensure PLL is reset during test mode.
// Output clock (clk) is bypassed by dft_clk mux during scan mode.
clk_wiz_0 CLKPLL (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk),    // Functional clock output (used when scan_en=0)
  .reset(dft_rst),   // Use unified DFT reset for PLL
  .locked(locked)
);

// Test Bench instantiation
// Uses DFT clock (dft_clk) and unified DFT reset (dft_rst).
// Ensure 'test_bench_onboard' module definition ports match instantiation.
test_bench_onboard TB (
	.clk(dft_clk),        // Connect to DFT clock mux output
	.rst(dft_rst),        // Connect to DFT reset mux output
	.test_start(test_start),
	.test_done(test_done),
	.test_pass(test_pass),
	.ap_ready(ap_ready),
	.ap_idle(ap_idle),
	.ap_done(ap_done),
	.dut_vld_y(vld_y),
	.dut_y(y),
	// Assuming dut_rst port might not exist or should use dft_rst in test_bench_onboard module definition
	.dut_start(ap_start),
	.dut_vld_x(vld_x),
	.dut_x(x),
	.dut_rat(rat)
);

// DUT instantiation
// Uses DFT clock (dft_clk) and unified DFT reset (dft_rst).
// Ensure 'multiSRC' module definition ports match instantiation.
multiSRC DUT (
    .ap_clk(dft_clk),      // Connect to DFT clock mux output
    .ap_rst(dft_rst),      // Connect to DFT reset mux output
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
    .vld_i(vld_x),
    .x_i_V(x),
    .rat_i_V(rat),
    .vld_o(vld_y),
    .y_o_V(y)
);

endmodule