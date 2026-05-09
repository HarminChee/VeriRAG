module hdmi_encoder_1_corrected_clk (
    // Functional Ports
    input clk,
    input rst, // Consider if this should be synchronous and DFT controllable
    output reg pclk,
    output reg [3:0] tmds,
    output reg [3:0] tmdsb,
    output reg active,
    output reg [10:0] x,
    output reg [9:0] y,
    input [7:0] red,
    input [7:0] green,
    input [7:0] blue,

    // DFT Ports
    input test_mode, // Scan enable / Test mode signal
    input test_clk   // Clock for scan testing
  );

  localparam LATENCY = 2'h2;
  localparam PCLK_DIV = 1'h1;
  localparam Y_RES = 9'h1e0;
  localparam X_RES = 10'h280;
  localparam Y_FRAME = 9'h1f4;
  localparam X_FRAME = 10'h340; // Corrected from 11'h33f (831) to 10'h340 (832) based on X_FRAME parameter name

  reg clkfbin;
  wire M_pll_oserdes_CLKOUT0;
  wire M_pll_oserdes_CLKOUT1;
  wire M_pll_oserdes_CLKOUT2;
  wire M_pll_oserdes_CLKOUT3;
  wire M_pll_oserdes_CLKOUT4;
  wire M_pll_oserdes_CLKOUT5;
  wire M_pll_oserdes_CLKFBOUT;
  wire M_pll_oserdes_LOCKED;

  // PLL instance (unchanged functionally)
  PLL_BASE #(.CLKIN_PERIOD(20), .CLKFBOUT_MULT(20), .CLKOUT0_DIVIDE(2), .CLKOUT1_DIVIDE(20), .CLKOUT2_DIVIDE(10), .COMPENSATION("SOURCE_SYNCHRONOUS")) pll_oserdes (
    .CLKFBIN(clkfbin),
    .CLKIN(clk),
    .RST(1'h0), // Consider if PLL reset needs DFT handling (e.g., tied to test_reset)
    .CLKOUT0(M_pll_oserdes_CLKOUT0),
    .CLKOUT1(M_pll_oserdes_CLKOUT1),
    .CLKOUT2(M_pll_oserdes_CLKOUT2),
    .CLKOUT3(M_pll_oserdes_CLKOUT3),
    .CLKOUT4(M_pll_oserdes_CLKOUT4),
    .CLKOUT5(M_pll_oserdes_CLKOUT5),
    .CLKFBOUT(M_pll_oserdes_CLKFBOUT),
    .LOCKED(M_pll_oserdes_LOCKED)
  );

  wire M_clkfb_buf_O;
  BUFG clkfb_buf (
    .I(M_pll_oserdes_CLKFBOUT),
    .O(M_clkfb_buf_O)
  );

  // Combinational feedback loop - potential issue, but keeping as is per original design
  // This should ideally be avoided or handled carefully in DFT.
  always @* begin
    clkfbin = M_clkfb_buf_O;
  end

  wire M_pclkx2_buf_O_func; // Functional clock
  BUFG pclkx2_buf (
    .I(M_pll_oserdes_CLKOUT2),
    .O(M_pclkx2_buf_O_func)
  );

  wire M_pclk_buf_O_func; // Functional clock
  BUFG pclk_buf (
    .I(M_pll_oserdes_CLKOUT1),
    .O(M_pclk_buf_O_func)
  );

  wire M_ioclk_buf_IOCLK_func; // Functional clock
  wire M_ioclk_buf_SERDESSTROBE;
  wire M_ioclk_buf_LOCK;
  BUFPLL #(.DIVIDE(5)) ioclk_buf (
    .PLLIN(M_pll_oserdes_CLKOUT0),
    .GCLK(M_pclkx2_buf_O_func), // Use functional clock here
    .LOCKED(M_pll_oserdes_LOCKED),
    .IOCLK(M_ioclk_buf_IOCLK_func),
    .SERDESSTROBE(M_ioclk_buf_SERDESSTROBE),
    .LOCK(M_ioclk_buf_LOCK)
  );

  // DFT Clock Muxing
  // Use proper clock mux cells (e.g., CLKMUX from library) instead of assigns for glitch-free switching if needed.
  // Buffering test_clk is recommended.
  wire test_clk_buf;
  BUFG test_clk_bufg (.I(test_clk), .O(test_clk_buf)); // Example buffering

  wire M_pclk_buf_O; // Clock for main FFs
  assign M_pclk_buf_O = test_mode ? test_clk_buf : M_pclk_buf_O_func;

  wire M_pclkx2_buf_O; // Clock for dvi module
  assign M_pclkx2_buf_O = test_mode ? test_clk_buf : M_pclkx2_buf_O_func;

  wire M_ioclk_buf_IOCLK; // Clock for dvi module
  assign M_ioclk_buf_IOCLK = test_mode ? test_clk_buf : M_ioclk_buf_IOCLK_func;

  // Internal registers
  reg [10:0] M_ctrX_d, M_ctrX_q = 11'h0;
  reg [9:0] M_ctrY_d, M_ctrY_q = 10'h0;
  reg [1:0] M_vsync_ff_d, M_vsync_ff_q = 2'b0;
  reg [1:0] M_active_ff_d, M_active_ff_q = 2'b0;
  integer i;
  reg hSync;
  reg vSync;
  reg drawArea;

  wire [3:0] M_dvi_tmds;
  wire [3:0] M_dvi_tmdsb;

  // Instantiate dvi_encoder_8 with potentially muxed clocks
  // Assuming dvi_encoder_8 is also DFT-ready (scan-inserted) and uses these clocks appropriately.
  // The reset for dvi also needs DFT consideration. Using primary rst here.
  dvi_encoder_8 dvi (
    .pclk(M_pclk_buf_O),         // Use muxed clock for FFs inside dvi clocked by pclk
    .pclkx2(M_pclkx2_buf_O),       // Use muxed clock for FFs inside dvi clocked by pclkx2
    .pclkx10(M_ioclk_buf_IOCLK),   // Use muxed clock for FFs inside dvi clocked by pclkx10
    .strobe(M_ioclk_buf_SERDESSTROBE), // Strobe might need special handling (e.g., gated during scan shift)
    .rst(rst || ~M_ioclk_buf_LOCK), // Combine primary reset and functional reset, consider DFT reset strategy
    .blue(blue),
    .green(green),
    .red(red),
    .hsync(hSync),
    .vsync(vSync),
    .de(M_active_ff_q[0]), // Use non-pipelined version for DE signal generation
    .tmds(M_dvi_tmds),
    .tmdsb(M_dvi_tmdsb)
  );

  // Combinational logic block
  always @* begin
    // Default assignments
    M_ctrX_d = M_ctrX_q;
    M_active_ff_d = M_active_ff_q;
    M_vsync_ff_d = M_vsync_ff_q;
    M_ctrY_d = M_ctrY_q;

    // Counter logic - Use parameters
    M_ctrX_d = (M_ctrX_q == X_FRAME - 1) ? 11'h0 : M_ctrX_q + 1'h1;
    if (M_ctrX_q == X_FRAME - 1) begin
      M_ctrY_d = (M_ctrY_q == Y_FRAME - 1) ? 10'h0 : M_ctrY_q + 1'h1;
    end

    // Output assignments
    pclk = M_pclk_buf_O_func; // Output pclk should be the functional clock

    // Sync generation (adjust timings based on actual spec if needed)
    hSync = (M_ctrX_q >= X_RES) && (M_ctrX_q < X_RES + 96); // Example: HSync pulse width 96
    M_vsync_ff_d[0] = (M_ctrY_q >= Y_RES) && (M_ctrY_q < Y_RES + 2); // Example: VSync pulse width 2
    drawArea = (M_ctrX_q < X_RES) && (M_ctrY_q < Y_RES);
    M_active_ff_d[0] = drawArea;

    // Pipeline stages for active and vsync outputs
    M_active_ff_d[1] = M_active_ff_q[0];
    M_vsync_ff_d[1] = M_vsync_ff_q[0]; // Corrected potential typo from original

    // Assign pipelined signals to outputs
    vSync = M_vsync_ff_q[1];
    active = M_active_ff_q[1];

    // Coordinate outputs
    x = M_ctrX_q;
    y = M_ctrY_q;

    // TMDS outputs
    tmds = M_dvi_tmds;
    tmdsb = M_dvi_tmdsb;
  end

  // Sequential logic block
  // Use the muxed clock M_pclk_buf_O
  // Assuming 'rst' is asynchronous active-high reset.
  // For DFT, synchronous reset controlled by test logic is preferred.
  always @(posedge M_pclk_buf_O or posedge rst) begin
    if (rst == 1'b1) begin
      M_ctrX_q <= 11'h0;
      M_ctrY_q <= 10'h0;
      M_vsync_ff_q <= 2'b0;
      M_active_ff_q <= 2'b0;
    end else begin
      M_ctrX_q <= M_ctrX_d;
      M_ctrY_q <= M_ctrY_d;
      M_vsync_ff_q <= M_vsync_ff_d;
      M_active_ff_q <= M_active_ff_d;
    end
  end

endmodule