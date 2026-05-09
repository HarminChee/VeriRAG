module multiSRC_onboard(
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
wire rst_in; // Renamed input reset signal
wire rst;    // Internal reset signal, potentially synchronized
wire locked;

reg [26:0] cnt;

// Use the raw input switch for the PLL reset
assign rst_in = GPIO_SW_CENTER;

// Optional: Synchronize the reset to the generated clock 'clk'
// This prevents glitches if the switch is pressed/released near a clock edge.
// If the PLL requires an asynchronous reset or the downstream logic handles
// asynchronous reset properly, you might connect rst_in directly.
// For simplicity and robustness in many FPGA designs, synchronizing is often preferred.
reg rst_s1, rst_s2;
always @(posedge clk) begin
    rst_s1 <= rst_in;
    rst_s2 <= rst_s1;
end
assign rst = rst_s2; // Use the synchronized reset for the logic

// Counter logic with synchronous reset
always @(posedge clk) begin
	if(rst) begin // Check reset synchronously on clock edge
		cnt <= 27'b0;
	end else begin
		cnt <= cnt + 1;
	end
end

wire ap_start;
wire ap_ready;
wire ap_idle;
wire ap_done;
wire dut_rst;
wire vld_x;
wire vld_y;
wire [15:0] x;
wire [2:0]  rat;
wire [47:0] y;

assign test_start = GPIO_SW_RIGHT;
assign GPIO_LED_CENTER = test_pass;
assign GPIO_LED_RIGHT = cnt[26];
assign GPIO_LED_LEFT = locked;

// Use the raw input reset for the PLL as it often requires an async reset
// or handles synchronization internally. Check PLL IP core documentation.
clk_wiz_0 CLKPLL
 (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk),
  .reset(rst_in), // Use direct switch input for PLL reset
  .locked(locked)
 );

// Assign the synchronized reset to the testbench and DUT reset inputs
assign dut_rst = rst;

test_bench_onboard TB
(
	.clk(clk),
	.rst(rst), // Use synchronized reset
	.test_start(test_start),
	.test_done(test_done),
	.test_pass(test_pass),
	.ap_ready(ap_ready),
	.ap_idle(ap_idle),
	.ap_done(ap_done),
	.dut_vld_y(vld_y),
	.dut_y(y),
	.dut_rst(dut_rst), // Pass synchronized reset signal
	.dut_start(ap_start),
	.dut_vld_x(vld_x),
	.dut_x(x),
	.dut_rat(rat)
);

multiSRC DUT(
        .ap_clk(clk),
        .ap_rst(dut_rst), // Use synchronized reset
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