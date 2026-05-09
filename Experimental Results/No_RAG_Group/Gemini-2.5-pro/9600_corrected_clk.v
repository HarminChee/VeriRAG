`default_nettype none
module plle2_test_corrected_clk // Module name changed as requested
(
input  wire         CLK,
input  wire         RST,
input  wire         test_clk, // Added test clock input
input  wire         test_mode, // Added test mode input
output wire         CLKFBOUT,
input  wire         CLKFBIN,
input  wire         I_PWRDWN,
input  wire         I_CLKINSEL,
output wire         O_LOCKED,
output wire [5:0]   O_CNT
);
parameter FEEDBACK = "INTERNAL";
wire clk100;
reg  clk50;
assign clk100 = CLK;

// This FF generates clk50, which drives the PLL.
// This FF should be part of a scan chain clocked by a test clock (e.g., test_clk or CLK).
always @(posedge clk100) // Assuming clk100 can be controlled during test or replaced by test_clk
    clk50 <= !clk50;

wire clk50_bufg;
BUFG bufgctrl (.I(clk50), .O(clk50_bufg));

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk; // PLL clock outputs
wire [5:0] gclk; // Buffered functional clocks from PLL

PLLE2_ADV #
(
.BANDWIDTH          ("HIGH"),
.COMPENSATION       ("ZHOLD"),
.CLKIN1_PERIOD      (20.0),
.CLKIN2_PERIOD      (10.0),
.CLKFBOUT_MULT      (16),
.CLKFBOUT_PHASE     (0),
.CLKOUT0_DIVIDE     (16),
.CLKOUT0_DUTY_CYCLE (53125),
.CLKOUT0_PHASE      (45000),
.CLKOUT1_DIVIDE     (32),
.CLKOUT1_DUTY_CYCLE (50000),
.CLKOUT1_PHASE      (90000),
.CLKOUT2_DIVIDE     (48),
.CLKOUT2_DUTY_CYCLE (50000),
.CLKOUT2_PHASE      (135000),
.CLKOUT3_DIVIDE     (64),
.CLKOUT3_DUTY_CYCLE (50000),
.CLKOUT3_PHASE      (-45000),
.CLKOUT4_DIVIDE     (80),
.CLKOUT4_DUTY_CYCLE (50000),
.CLKOUT4_PHASE      (-90000),
.CLKOUT5_DIVIDE     (96),
.CLKOUT5_DUTY_CYCLE (50000),
.CLKOUT5_PHASE      (-135000),
.STARTUP_WAIT       ("FALSE")
)
pll
(
.CLKIN1     (clk50_bufg), // Functional clock input derived internally
.CLKIN2     (clk100),    // Functional clock input derived from primary input
.CLKINSEL   (I_CLKINSEL),
.RST        (RST),
.PWRDWN     (I_PWRDWN),
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

generate if (FEEDBACK == "INTERNAL") begin
    assign clk_fb_i = clk_fb_o;
end else if (FEEDBACK == "BUFG") begin
    BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));
end else if (FEEDBACK == "EXTERNAL") begin
    assign CLKFBOUT = clk_fb_o;
    assign clk_fb_i = CLKFBIN;
end endgenerate

wire rst_internal = RST || !O_LOCKED; // Original functional reset

genvar i;
generate for (i=0; i<6; i=i+1) begin : counter_gen
  BUFG bufg(.I(clk[i]), .O(gclk[i])); // Buffer the functional PLL clock output

  wire counter_clk; // Muxed clock for the counter
  wire counter_rst; // Muxed reset for the counter

  // DFT Clock Mux: Select test_clk when test_mode is active
  // This ensures the counter FFs are clocked by a controllable clock during test.
  assign counter_clk = test_mode ? test_clk : gclk[i];

  // DFT Reset Mux: Select primary reset RST when test_mode is active.
  // This bypasses the dependency on the PLL lock status (O_LOCKED) during test.
  assign counter_rst = test_mode ? RST : rst_internal;

  reg [23:0] counter;

  // Counter logic clocked by the muxed clock and reset by the muxed reset
  always @(posedge counter_clk or posedge counter_rst) begin
      if (counter_rst) begin
          counter <= 24'b0;
      end else begin
          counter <= counter + 1'b1;
      end
  end

  assign O_CNT[i] = counter[21];
end endgenerate

endmodule
`default_nettype wire // Restore default net type