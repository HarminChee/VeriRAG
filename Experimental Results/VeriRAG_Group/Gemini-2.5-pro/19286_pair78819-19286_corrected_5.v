module multiSRC_onboard(
	input test_i, // Added test mode input
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
wire dft_clk; // Added DFT clock wire
wire clk_in_buf; // Added wire for buffered input clock
wire dft_dut_rst; // Added DFT reset wire for DUT

// Use IBUFGDS for differential input clock buffering
IBUFGDS clk_diff_buf (
    .I(SYSCLK_P),
    .IB(SYSCLK_N),
    .O(clk_in_buf)
);

// DFT Clock Mux: Selects buffered primary input clock in test mode, generated clock otherwise
assign dft_clk = test_i ? clk_in_buf : clk;

// Primary reset directly from input
assign rst = GPIO_SW_CENTER;

// Corrected sensitivity list for asynchronous reset
always @(posedge dft_clk or posedge rst) begin
	if(rst) begin
		cnt <= 27'd0; // Use explicit width and decimal value for clarity
	end else begin
		cnt <= cnt + 1'b1; // Use explicit width for increment
	end
end

wire ap_start;
wire ap_ready;
wire ap_idle;
wire ap_done;
wire dut_rst; // Functional reset from TB
wire vld_x;
wire vld_y;
wire [15:0] x; // Declare width
wire [2:0]  rat; // Declare width
wire [47:0] y; // Declare width
wire locked;

assign test_start=GPIO_SW_RIGHT;
assign GPIO_LED_CENTER=test_pass;
assign GPIO_LED_RIGHT=cnt[26];
assign GPIO_LED_LEFT=locked;

// DFT Reset Mux for DUT: Selects primary reset in test mode, functional reset otherwise
assign dft_dut_rst = test_i ? rst : dut_rst;

// Instantiation of clk_wiz_0 (Ensure port names match the definition)
clk_wiz_0 CLKPLL
 (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk), // Generated clock output
  .reset(rst),    // Use primary reset for PLL
  .locked(locked)
 );

// Instantiation of test_bench_onboard (Ensure port names match the definition)
// Assuming standard port names if not provided - USER MUST VERIFY
test_bench_onboard TB
(
	.clk(dft_clk), // Use DFT clock
	.rst(rst),     // Use primary reset
	.test_start(test_start),
	.test_done(test_done), // Output from TB
	.test_pass(test_pass), // Output from TB
	.ap_ready(ap_ready),   // Input to TB (from DUT)
	.ap_idle(ap_idle),     // Input to TB (from DUT)
	.ap_done(ap_done),     // Input to TB (from DUT)
	.dut_vld_y(vld_y),     // Input to TB (from DUT)
	.dut_y(y),             // Input to TB (from DUT)
	.dut_rst(dut_rst),     // Output from TB
	.dut_start(ap_start),  // Output from TB
	.dut_vld_x(vld_x),     // Output from TB
	.dut_x(x),             // Output from TB
	.dut_rat(rat)          // Output from TB
);

// Instantiation of multiSRC (Ensure port names match the definition)
// Assuming standard port names if not provided - USER MUST VERIFY
multiSRC DUT(
        .ap_clk(dft_clk),     // Use DFT clock
        .ap_rst(dft_dut_rst), // Use DFT-muxed reset
        .ap_start(ap_start),  // Input to DUT (from TB)
        .ap_done(ap_done),    // Output from DUT
        .ap_idle(ap_idle),    // Output from DUT
        .ap_ready(ap_ready),  // Output from DUT
        .vld_i(vld_x),        // Input to DUT (from TB)
        .x_i_V(x),            // Input to DUT (from TB)
        .rat_i_V(rat),        // Input to DUT (from TB)
        .vld_o(vld_y),        // Output from DUT
        .y_o_V(y)             // Output from DUT
);
endmodule