`default_nettype none
module plle2_test
(
input  wire         CLK,
input  wire         RST,
input  wire         I_CLKINSEL,
output wire         O_LOCKED,
output wire [5:0]   O_CNT,
input  wire         scan_clk, // Added for DFT
input  wire         test_i    // Added for DFT (test mode enable)
);
wire clk100;
reg  clk50;
assign clk100 = CLK;
// Note: clk50 is an internally generated clock driving the PLL.
// This register itself might need DFT handling depending on overall strategy,
// but focusing on the user FFs (counters) clocked by PLL outputs first.
always @(posedge clk100) // Assuming CLK (clk100) can be controlled during test or is the test clock
    clk50 <= !clk50;     // This FF uses clk100 (from PI CLK) and no reset shown, implies asynchronous reset? Assuming RST applies implicitly or not needed based on context. If it needs reset, it should use dft_rst.

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk; // PLL generated clocks
PLLE2_ADV #
(
.BANDWIDTH          ("HIGH"),
.COMPENSATION       ("BUF_IN"),
.CLKIN1_PERIOD      (20.0),
.CLKIN2_PERIOD      (10.0),
.CLKFBOUT_MULT      (16),
.CLKFBOUT_PHASE     (0.0),
.CLKOUT0_DIVIDE     (16),
.CLKOUT0_DUTY_CYCLE (0.53125),
.CLKOUT0_PHASE      (45.0),
.CLKOUT1_DIVIDE     (32),
.CLKOUT1_DUTY_CYCLE (0.5),
.CLKOUT1_PHASE      (90.0),
.CLKOUT2_DIVIDE     (48),
.CLKOUT2_DUTY_CYCLE (0.5),
.CLKOUT2_PHASE      (135.0),
.CLKOUT3_DIVIDE     (64),
.CLKOUT3_DUTY_CYCLE (0.5),
.CLKOUT3_PHASE      (-45.0),
.CLKOUT4_DIVIDE     (80),
.CLKOUT4_DUTY_CYCLE (0.5),
.CLKOUT4_PHASE      (-90.0),
.CLKOUT5_DIVIDE     (96),
.CLKOUT5_DUTY_CYCLE (0.5),
.CLKOUT5_PHASE      (-135.0),
.STARTUP_WAIT       ("FALSE")
)
pll
(
.CLKIN1     (clk50),
.CLKIN2     (clk100),
.CLKINSEL   (I_CLKINSEL),
.RST        (RST), // PLL reset is primary input RST
.LOCKED     (O_LOCKED),
.CLKFBIN    (clk_fb_i),
.CLKFBOUT   (clk_fb_o),
.CLKOUT0    (clk[0]),
.CLKOUT1    (clk[1]),
.CLKOUT2    (clk[2]),
.CLKOUT3    (clk[3]),
.CLKOUT4    (clk[4]),
.CLKOUT5    (clk[5])
);
BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));

// Original reset logic (ACNCPI violation potential due to O_LOCKED)
wire rst_func = RST || !O_LOCKED;

// DFT-friendly reset mux (Selects PI RST during test mode)
wire dft_rst = test_i ? RST : rst_func;

wire [5:0] dft_clk; // DFT-friendly clock mux outputs

genvar i;
generate for (i=0; i<6; i=i+1) begin
  // DFT-friendly clock mux (Selects scan_clk during test mode)
  assign dft_clk[i] = test_i ? scan_clk : clk[i];

  reg [23:0] counter;
  // Use DFT-friendly clock and reset
  always @(posedge dft_clk[i] or posedge dft_rst)
      if (dft_rst) counter <= 24'b0; // Corrected reset value width
      else         counter <= counter + 1;

  assign O_CNT[i] = counter[21];
end endgenerate
endmodule
`default_nettype wire