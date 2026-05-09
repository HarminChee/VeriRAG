module multiSRC_onboard(
	input SYSCLK_N,
	input SYSCLK_P,
	input GPIO_SW_RIGHT,
	input GPIO_SW_CENTER,
	output GPIO_LED_CENTER,
	output GPIO_LED_LEFT,
	output GPIO_LED_RIGHT,
    // DFT inputs
    input scan_en,
    input test_clk_i,
    input test_rst_i
);
wire test_start;
wire test_done;
wire test_pass;
wire clk;
wire rst;
wire dft_clk; // DFT clock signal
wire dft_rst; // DFT reset signal for cnt and TB
wire dft_dut_rst; // DFT reset signal for DUT

reg [26:0] cnt;

// DFT clock selection
assign dft_clk = scan_en ? test_clk_i : clk;
// DFT reset selection (using primary input GPIO_SW_CENTER for functional reset)
assign dft_rst = scan_en ? test_rst_i : rst;


always @(posedge dft_clk, posedge dft_rst) begin // Use DFT clock and reset
	if(dft_rst) begin // Use DFT reset
		cnt <= 0;
	end else begin
		cnt <= cnt+1;
	end
end

wire ap_start;
wire ap_ready;
wire ap_idle;
wire ap_done;
wire dut_rst; // Functional reset from TB to DUT
wire vld_x;
wire vld_y;
wire [15:0] x;
wire [2:0]  rat;
wire [47:0] y;
wire locked;

// DFT reset selection for DUT (bypassing TB generated reset in scan mode)
assign dft_dut_rst = scan_en ? test_rst_i : dut_rst;


assign rst=GPIO_SW_CENTER;
assign test_start=GPIO_SW_RIGHT;
assign GPIO_LED_CENTER=test_pass;
assign GPIO_LED_RIGHT=cnt[26];
assign GPIO_LED_LEFT=locked;

// PLL instantiation - remains functionally driven, but its output is bypassed by dft_clk for downstream logic in scan mode
clk_wiz_0 CLKPLL
 (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk), // Functional clock output
  .reset(rst),    // Functional reset input
  .locked(locked)
 );

test_bench_onboard TB
(
	.clk(dft_clk),      // Use DFT clock
	.rst(dft_rst),      // Use DFT reset
	.test_start(test_start),
	.test_done(test_done),
	.test_pass(test_pass),
	.ap_ready(ap_ready),
	.ap_idle(ap_idle),
	.ap_done(ap_done),
	.dut_vld_y(vld_y),
	.dut_y(y),
	.dut_rst(dut_rst),    // Output functional reset for DUT
	.dut_start(ap_start),
	.dut_vld_x(vld_x),
	.dut_x(x),
	.dut_rat(rat)
);

multiSRC DUT(
        .ap_clk(dft_clk),      // Use DFT clock
        .ap_rst(dft_dut_rst),  // Use DFT reset for DUT
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