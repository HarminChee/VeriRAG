// `default_nettype none // Removed temporarily

module plle2_test
(
input  wire         CLK,
input  wire         RST, // Primary Reset Input
input  wire         I_CLKINSEL,
output wire         O_LOCKED,
output wire [5:0]   O_CNT,
input  wire         scan_clk, // Added for DFT Scan Clock
input  wire         test_i    // Added for DFT Test Mode Enable
);

wire clk100;
reg  clk50; // Register to generate 50MHz clock

// Assign primary clock directly
assign clk100 = CLK;

// FF to generate clk50 - Added asynchronous reset
// Clocked by signal derived from PI CLK (clk100)
// Reset by Primary Input RST
always @(posedge clk100 or posedge RST) begin // Added posedge RST
    if (RST) begin
        clk50 <= 1'b0; // Reset state for clk50
    end else begin
        clk50 <= !clk50;
    end
end

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk; // PLL generated clocks

// Instantiate PLL - Note: CLKIN1 uses internally generated clk50
PLLE2_ADV #
(
.BANDWIDTH          ("HIGH"),
.COMPENSATION       ("BUF_IN"),
.CLKIN1_PERIOD      (20.0), // Corresponds to clk50 (50MHz)
.CLKIN2_PERIOD      (10.0), // Corresponds to clk100 (100MHz)
.CLKFBOUT_MULT      (16),
.CLKFBOUT_PHASE     (0.0),
.CLKOUT0_DIVIDE     (16),
.CLKOUT0_DUTY_CYCLE (0.53125), // Restored original value
.CLKOUT0_PHASE      (45.0),   // Restored original value
.CLKOUT1_DIVIDE     (32),
.CLKOUT1_DUTY_CYCLE (0.5),
.CLKOUT1_PHASE      (90.0),   // Restored original value
.CLKOUT2_DIVIDE     (48),
.CLKOUT2_DUTY_CYCLE (0.5),
.CLKOUT2_PHASE      (135.0),  // Restored original value
.CLKOUT3_DIVIDE     (64),
.CLKOUT3_DUTY_CYCLE (0.5),
.CLKOUT3_PHASE      (-45.0),  // Restored original value
.CLKOUT4_DIVIDE     (80),
.CLKOUT4_DUTY_CYCLE (0.5),
.CLKOUT4_PHASE      (-90.0),  // Restored original value
.CLKOUT5_DIVIDE     (96),
.CLKOUT5_DUTY_CYCLE (0.5),
.CLKOUT5_PHASE      (-135.0), // Restored original value
.STARTUP_WAIT       ("FALSE")
)
pll
(
.CLKIN1     (clk50),        // Input from internal FF (Potential DFT issue if selected)
.CLKIN2     (clk100),       // Input from PI CLK (Good for DFT if selected)
.CLKINSEL   (I_CLKINSEL),   // Selects between clk50 and clk100
.RST        (RST),          // PLL reset uses PI RST (Good)
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

// Feedback buffer
BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));

// Functional reset potentially using non-PI signal O_LOCKED
// This creates an ACNCPI violation if used directly on FFs
wire rst_func = RST || !O_LOCKED;

// DFT-friendly reset mux (Selects PI RST during test mode)
// This ensures FFs downstream are resettable by PI during test
wire dft_rst = test_i ? RST : rst_func;

wire [5:0] dft_clk; // DFT-friendly clock mux outputs
reg [23:0] counter [0:5]; // Counter array [0:5] matches clk[0:5] and O_CNT[5:0]

genvar i;
generate for (i=0; i<6; i=i+1) begin : counter_gen
  // DFT-friendly clock mux (Selects scan_clk during test mode)
  // This ensures FFs downstream are clocked by scan_clk during test
  assign dft_clk[i] = test_i ? scan_clk : clk[i];

  // Counter logic using DFT-friendly clock and reset
  always @(posedge dft_clk[i] or posedge dft_rst) begin // Use dft_clk and dft_rst
      if (dft_rst) begin
          counter[i] <= 24'b0;
      end else begin
          counter[i] <= counter[i] + 1;
      end
  end

  // Assign output bit from the counter array element
  assign O_CNT[i] = counter[i][21]; // Assign corresponding counter output bit
end endgenerate

endmodule

// `default_nettype wire // Restore if desired