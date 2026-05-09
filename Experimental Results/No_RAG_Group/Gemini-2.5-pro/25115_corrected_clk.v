`default_nettype none
module mmcme2_test_corrected_clk // Renamed module to reflect correction
(
input  wire         CLK,
input  wire         RST,
// Add test mode input for DFT
input  wire         test_mode,
output wire         CLKFBOUT,
input  wire         CLKFBIN,
input  wire         I_PWRDWN,
input  wire         I_CLKINSEL,
output wire         O_LOCKED,
output wire [5:0]   O_CNT
);
parameter FEEDBACK = "INTERNAL";
parameter CLKFBOUT_MULT_F  = 12.000;
parameter CLKOUT0_DIVIDE_F = 12.000;

wire clk100;
BUFG bufg100 (.I(CLK), .O(clk100));

// Define test clock based on buffered primary input clock
wire test_clk = clk100;

// Note: The generation of clk50 using BUFGCE might also be flagged by some DFT tools,
// but the primary CLKNPI violation addressed here is the clocking of downstream FFs (counter).
reg clk50_ce;
always @(posedge clk100)
    clk50_ce <= !clk50_ce;

wire clk50;
BUFGCE bufg50 (.I(CLK), .CE(clk50_ce), .O(clk50));

wire clk_fb_o;
wire clk_fb_i;
wire [5:0] clk;
wire [5:0] gclk; // Buffered MMCM output clocks

generate if (FEEDBACK == "NONE") begin
    MMCME2_ADV #
    (
    .BANDWIDTH          ("HIGH"),
    .CLKIN1_PERIOD      (20.0),
    .CLKIN2_PERIOD      (10.0),
    .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
    .CLKFBOUT_PHASE     (0),
    .CLKOUT0_DIVIDE_F   (CLKOUT0_DIVIDE_F),
    .CLKOUT0_DUTY_CYCLE (0.50),
    .CLKOUT0_PHASE      (45.0),
    .CLKOUT1_DIVIDE     (32),
    .CLKOUT1_DUTY_CYCLE (0.53125),
    .CLKOUT1_PHASE      (90.0),
    .CLKOUT2_DIVIDE     (48),
    .CLKOUT2_DUTY_CYCLE (0.50),
    .CLKOUT2_PHASE      (135.0),
    .CLKOUT3_DIVIDE     (64),
    .CLKOUT3_DUTY_CYCLE (0.50),
    .CLKOUT3_PHASE      (45.0),
    .CLKOUT4_DIVIDE     (80),
    .CLKOUT4_DUTY_CYCLE (0.50),
    .CLKOUT4_PHASE      (90.0),
    .CLKOUT5_DIVIDE     (96),
    .CLKOUT5_DUTY_CYCLE (0.50),
    .CLKOUT5_PHASE      (135.0),
    .CLKOUT6_DIVIDE     (1),
    .CLKOUT6_DUTY_CYCLE (0.50),
    .CLKOUT6_PHASE      (0.0),
    .STARTUP_WAIT       ("FALSE")
    )
    mmcm
    (
    .CLKIN1     (clk50),
    .CLKIN2     (clk100),
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
    .CLKOUT5    (clk[5]),
    .CLKOUT6    ()
    );
end else begin
    MMCME2_ADV #
    (
    .BANDWIDTH          ("HIGH"),
    .COMPENSATION       ((FEEDBACK == "EXTERNAL") ? "EXTERNAL" : "INTERNAL"),
    .CLKIN1_PERIOD      (20.0),
    .CLKIN2_PERIOD      (10.0),
    .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
    .CLKFBOUT_PHASE     (0),
    .CLKOUT0_DIVIDE_F   (CLKOUT0_DIVIDE_F),
    .CLKOUT0_DUTY_CYCLE (0.50),
    .CLKOUT0_PHASE      (45.0),
    .CLKOUT1_DIVIDE     (32),
    .CLKOUT1_DUTY_CYCLE (0.53125),
    .CLKOUT1_PHASE      (90.0),
    .CLKOUT2_DIVIDE     (48),
    .CLKOUT2_DUTY_CYCLE (0.50),
    .CLKOUT2_PHASE      (135.0),
    .CLKOUT3_DIVIDE     (64),
    .CLKOUT3_DUTY_CYCLE (0.50),
    .CLKOUT3_PHASE      (45.0),
    .CLKOUT4_DIVIDE     (80),
    .CLKOUT4_DUTY_CYCLE (0.50),
    .CLKOUT4_PHASE      (90.0),
    .CLKOUT5_DIVIDE     (96),
    .CLKOUT5_DUTY_CYCLE (0.50),
    .CLKOUT5_PHASE      (135.0),
    .CLKOUT6_DIVIDE     (1),
    .CLKOUT6_DUTY_CYCLE (0.50),
    .CLKOUT6_PHASE      (0.0),
    .STARTUP_WAIT       ("FALSE")
    )
    mmcm
    (
    .CLKIN1     (clk50),
    .CLKIN2     (clk100),
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
    .CLKOUT5    (clk[5]),
    .CLKOUT6    ()
    );
end endgenerate

generate if (FEEDBACK == "INTERNAL") begin
    assign clk_fb_i = clk_fb_o;
end else if (FEEDBACK == "BUFG") begin
    BUFG clk_fb_buf (.I(clk_fb_o), .O(clk_fb_i));
end else if (FEEDBACK == "EXTERNAL") begin
    assign CLKFBOUT = clk_fb_o;
    assign clk_fb_i = CLKFBIN;
end endgenerate

// Functional reset depends on primary reset OR MMCM lock status
wire functional_rst = RST || !O_LOCKED;

genvar i;
generate for (i=0; i<6; i=i+1) begin: counter_gen
  // Buffer the generated clock
  BUFG bufg(.I(clk[i]), .O(gclk[i]));

  // DFT Clock MUX: Select between functional clock (gclk[i]) and test clock (test_clk)
  wire counter_clk;
  // In test mode, use the test clock derived from the primary input.
  // Otherwise, use the functionally generated clock.
  assign counter_clk = test_mode ? test_clk : gclk[i];

  // DFT Reset MUX: Select between functional reset and primary reset
  wire counter_rst;
  // In test mode, use the primary asynchronous reset (RST) directly.
  // Otherwise, use the functional reset condition.
  assign counter_rst = test_mode ? RST : functional_rst;

  // Counter Register
  reg [23:0] counter;
  // Use the multiplexed clock and reset signals
  // Assuming RST is an asynchronous positive edge reset
  always @(posedge counter_clk or posedge counter_rst) begin
      if (counter_rst) begin
          counter <= 24'b0;
      end else begin
          // Ensure the counter enable logic (if any) is also DFT friendly
          // Simple increment shown here
          counter <= counter + 1;
      end
  end
  // Assign counter output
  assign O_CNT[i] = counter[21];
end endgenerate

endmodule
`default_nettype wire // Reset default_nettype if needed at the end