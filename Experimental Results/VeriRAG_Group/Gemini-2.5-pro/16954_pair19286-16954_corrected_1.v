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

// FF to generate clk50
always @(posedge clk100) // Clocked by signal derived from PI CLK
    clk50 <= !clk50;     // No reset used here

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk; // PLL generated clocks

PLLE2_ADV #
(
.BANDWIDTH          ("HIGH"),
.COMPENSATION       ("BUF_IN"),
.CLKIN1_PERIOD      (20.0), // Corresponds to clk50 (50MHz)
.CLKIN2_PERIOD      (10.0), // Corresponds to clk100 (100MHz)
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
.RST        (RST), // PLL reset uses PI RST
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

// Functional reset potentially using non-PI signal O_LOCKED
wire rst_func = RST || !O_LOCKED;

// DFT-friendly reset mux (Selects PI RST during test mode)
wire dft_rst = test_i ? RST : rst_func;

wire [5:0] dft_clk; // DFT-friendly clock mux outputs
reg [23:0] counter [5:0]; // Declare counter as an array outside generate

genvar i;
generate for (i=0; i<6; i=i+1) begin : counter_gen // Added generate block label
  // DFT-friendly clock mux (Selects scan_clk during test mode)
  assign dft_clk[i] = test_i ? scan_clk : clk[i];

  // Use DFT-friendly clock and reset for the counter array element
  always @(posedge dft_clk[i] or posedge dft_rst)
      if (dft_rst) counter[i] <= 24'b0;
      else         counter[i] <= counter[i] + 1;

  // Assign output bit from the counter array element
  assign O_CNT[i] = counter[i][21];
end endgenerate

endmodule
`default_nettype wire