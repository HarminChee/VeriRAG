`default_nettype none
module plle2_test
(
input  wire         test_i, // Added for DFT control
input  wire         CLK,
input  wire         RST,
output wire         CLKFBOUT,
input  wire         CLKFBIN,
input  wire         I_PWRDWN,
input  wire         I_CLKINSEL,
output wire         O_LOCKED,
output wire [5:0]   O_CNT
);
parameter FEEDBACK = "INTERNAL";

// Original clock generation logic
wire clk100;
reg  clk50;
assign clk100 = CLK;
// This FF generates an internal clock 'clk50'
// While clocked by PI CLK, clk50 itself is internal
always @(posedge clk100)
    clk50 <= !clk50;

wire clk50_bufg;
BUFG bufgctrl (.I(clk50), .O(clk50_bufg));

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk; // PLL output clocks (derived)
wire [5:0] gclk; // Buffered PLL output clocks (derived)

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
.CLKIN1     (clk50_bufg), // Fed by internally generated clk50
.CLKIN2     (clk100),     // Fed by PI CLK
.CLKINSEL   (I_CLKINSEL),
.RST        (RST),        // Reset from PI
.PWRDWN     (I_PWRDWN),   // Control from PI
.LOCKED     (O_LOCKED),   // Internal status signal
.CLKFBIN    (clk_fb_i),
.CLKFBOUT   (clk_fb_o),
.CLKOUT0    (clk[0]),     // Derived clock outputs
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

// Original reset logic - depends on internal signal O_LOCKED (ACNCPI source)
wire func_rst = RST || !O_LOCKED;
// DFT reset - selects primary input RST during test mode
wire dft_rst;
assign dft_rst = test_i ? RST : func_rst;

genvar i;
generate for (i=0; i<6; i=i+1) begin
  // Buffer the derived PLL clocks
  BUFG bufg(.I(clk[i]), .O(gclk[i]));

  // DFT clock - selects primary input CLK during test mode, bypassing derived clock gclk[i] (CLKNPI fix)
  wire dft_clk;
  assign dft_clk = test_i ? CLK : gclk[i];

  reg [23:0] counter;
  // Counter flip-flop using DFT-controlled clock and reset
  always @(posedge dft_clk or posedge dft_rst) begin // Use DFT clock and reset in sensitivity list
      if (dft_rst) begin // Use DFT reset for logic
          counter <= 24'b0;
      end else begin
          counter <= counter + 1;
      end
  end
  assign O_CNT[i] = counter[21];
end endgenerate

endmodule
`default_nettype wire // Restore default net type