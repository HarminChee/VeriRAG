module multiSRC_onboard(
	input test_i,
	input scan_clk,
	input SYSCLK_N,
	input SYSCLK_P,
	input GPIO_SW_RIGHT,
	input GPIO_SW_CENTER,
	output GPIO_LED_CENTER,
	output GPIO_LED_LEFT,
	output GPIO_LED_RIGHT
);
wire test_start;
wire test_done;
wire test_pass;
wire clk;
wire rst;
reg [26:0] cnt;
wire dft_clk;
wire dut_rst; // Driven by TB output
wire dft_dut_rst;
wire locked; // Driven by clk_wiz_0 output

wire ap_start; // Driven by TB output
wire ap_ready; // Driven by DUT output
wire ap_idle;  // Driven by DUT output
wire ap_done;  // Driven by DUT output
wire vld_x;    // Driven by TB output
wire vld_y;    // Driven by DUT output
wire [15:0] x; // Driven by TB output
wire [2:0]  rat; // Driven by TB output
wire [47:0] y; // Driven by DUT output


assign dft_clk = test_i ? scan_clk : clk ;
assign rst = GPIO_SW_CENTER; // Primary reset
assign dft_dut_rst = test_i ? rst : dut_rst; // Muxed reset for DUT

// Counter with primary asynchronous reset and muxed clock
// Changed sensitivity list from comma to 'or' for standard practice
always @(posedge dft_clk or posedge rst) begin
	if(rst) begin
		cnt <= 27'b0;
	end else begin
		cnt <= cnt + 1'b1;
	end
end

assign test_start = GPIO_SW_RIGHT;
assign GPIO_LED_CENTER = test_pass; // test_pass comes from TB output
assign GPIO_LED_RIGHT = cnt[26];
assign GPIO_LED_LEFT = locked; // locked comes from clk_wiz_0 output

// Clock Wizard Instance
clk_wiz_0 CLKPLL
 (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk),     // Output wire
  .reset(rst),        // Input uses primary reset
  .locked(locked)     // Output wire
 );

// Test Bench Instance
test_bench_onboard TB
(
	.clk(dft_clk),         // Input uses muxed clock
	.rst(rst),             // Input uses primary reset
	.test_start(test_start), // Input uses primary input derived signal
	.test_done(test_done),   // Output wire
	.test_pass(test_pass),   // Output wire
	.ap_ready(ap_ready),     // Input connected to DUT output wire
	.ap_idle(ap_idle),       // Input connected to DUT output wire
	.ap_done(ap_done),       // Input connected to DUT output wire
	.dut_vld_y(vld_y),       // Input connected to DUT output wire
	.dut_y(y),             // Input connected to DUT output wire
	.dut_rst(dut_rst),       // Output wire (functional reset for DUT)
	.dut_start(ap_start),    // Output wire
	.dut_vld_x(vld_x),       // Output wire
	.dut_x(x),             // Output wire
	.dut_rat(rat)          // Output wire
);

// DUT Instance
multiSRC DUT(
        .ap_clk(dft_clk),      // Input uses muxed clock
        .ap_rst(dft_dut_rst),  // Input uses muxed reset (primary in test mode)
        .ap_start(ap_start),   // Input connected to TB output wire
        .ap_done(ap_done),     // Output wire
        .ap_idle(ap_idle),     // Output wire
        .ap_ready(ap_ready),   // Output wire
        .vld_i(vld_x),         // Input connected to TB output wire
        .x_i_V(x),             // Input connected to TB output wire
        .rat_i_V(rat),         // Input connected to TB output wire
        .vld_o(vld_y),         // Output wire
        .y_o_V(y)              // Output wire
);
endmodule