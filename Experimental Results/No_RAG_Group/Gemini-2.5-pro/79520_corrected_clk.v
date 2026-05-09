`timescale 1 ns / 1ps
module dvi_decoder_nok_corrected (
  input  wire tmdsclk_p,
  input  wire tmdsclk_n,
  input  wire blue_p,
  input  wire green_p,
  input  wire red_p,
  input  wire blue_n,
  input  wire green_n,
  input  wire red_n,
  input  wire exrst,
  // DFT Inputs
  input  wire scan_en,        // Scan enable signal
  input  wire test_clk,       // Scan clock input
  input  wire test_rst_n,     // Asynchronous scan reset (active low)

  output wire reset,
  output wire pclk,
  output wire pclkx2,
  output wire pclkx10,
  output wire pllclk0,
  output wire pllclk1,
  output wire pllclk2,
  output wire pll_lckd,
  output wire serdesstrobe,
  output wire tmdsclk,
  output wire hsync,
  output wire vsync,
  output wire de,
  output wire blue_vld,
  output wire green_vld,
  output wire red_vld,
  output wire blue_rdy,
  output wire green_rdy,
  output wire red_rdy,
  output wire psalgnerr,
  output wire [29:0] sdout,
  output wire [7:0] red,
  output wire [7:0] green,
  output wire [7:0] blue);

  wire [9:0] sdout_blue, sdout_green, sdout_red;
  assign sdout = {sdout_red[9:5], sdout_green[9:5], sdout_blue[9:5],
                  sdout_red[4:0], sdout_green[4:0], sdout_blue[4:0]};

  wire vde_b, vde_g, vde_r;
  wire ade_b, ade_g, ade_r;
  wire ade;
  assign de = vde_r;
  assign ade = ade_r;

  wire blue_psalgnerr, green_psalgnerr, red_psalgnerr;
  wire blue_c0, blue_c1;
  wire [3:0] aux0;
  wire [3:0] aux1;
  wire [3:0] aux2;
  assign hsync = ade_b ? aux0[0] : blue_c0;
  assign vsync = ade_b ? aux0[1] : blue_c1;

  wire ctl0, ctl1, ctl2, ctl3;
  reg  videopreamble;
  reg  dilndpreamble;

  // Internal clock and reset signals
  wire func_pclk;
  wire func_pclkx2;
  wire func_pclkx10;
  wire func_reset;
  wire func_serdesstrobe;
  wire func_pll_lckd;
  wire func_pllclk0;
  wire func_pllclk1;
  wire func_pllclk2;
  wire func_tmdsclk;

  // DFT Muxed signals
  wire pclk_scan;
  wire pclkx2_scan;
  wire pclkx10_scan;
  wire reset_scan;

  assign pclk_scan    = scan_en ? test_clk : func_pclk;
  assign pclkx2_scan  = scan_en ? test_clk : func_pclkx2;
  assign pclkx10_scan = scan_en ? test_clk : func_pclkx10;
  assign reset_scan   = scan_en ? ~test_rst_n : func_reset; // In scan mode, use test_rst_n (active high reset), otherwise functional reset

  // Assign outputs from functional signals
  assign pclk = func_pclk;
  assign pclkx2 = func_pclkx2;
  assign pclkx10 = func_pclkx10;
  assign reset = func_reset;
  assign serdesstrobe = func_serdesstrobe;
  assign pll_lckd = func_pll_lckd;
  assign pllclk0 = func_pllclk0;
  assign pllclk1 = func_pllclk1;
  assign pllclk2 = func_pllclk2;
  assign tmdsclk = func_tmdsclk;


  // Use muxed clock for registers in this module
  always @ (posedge pclk_scan or posedge reset_scan) begin
    if (reset_scan) begin
        videopreamble <= #1 1'b0;
        dilndpreamble <= #1 1'b0;
    end else begin
        videopreamble <= #1 ({ctl0, ctl1, ctl2, ctl3} === 4'b1000);
        dilndpreamble <= #1 ({ctl0, ctl1, ctl2, ctl3} === 4'b1010);
    end
  end

  wire rxclkint;
  IBUFDS  #(.IOSTANDARD("TMDS_33"), .DIFF_TERM("FALSE")
  ) ibuf_rxclk (.I(tmdsclk_p), .IB(tmdsclk_n), .O(rxclkint));

  wire rxclk;
  BUFIO2 #(.DIVIDE_BYPASS("TRUE"), .DIVIDE(1))
  bufio_tmdsclk (.DIVCLK(rxclk), .IOCLK(), .SERDESSTROBE(), .I(rxclkint));

  BUFG tmdsclk_bufg (.I(rxclk), .O(func_tmdsclk)); // Output functional tmdsclk

  wire clkfbout; // Internal PLL feedback
  PLL_BASE # (
    .CLKIN_PERIOD(10),
    .CLKFBOUT_MULT(10),
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("INTERNAL")
  ) PLL_ISERDES (
    .CLKFBOUT(clkfbout),
    .CLKOUT0(func_pllclk0), // Output functional pllclk0
    .CLKOUT1(func_pllclk1), // Output functional pllclk1
    .CLKOUT2(func_pllclk2), // Output functional pllclk2
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(func_pll_lckd), // Output functional pll_lckd
    .CLKFBIN(clkfbout),
    .CLKIN(rxclk),         // Use rxclk derived from primary inputs
    .RST(exrst)            // Use primary reset for PLL
  );

  BUFG pclkbufg (.I(func_pllclk1), .O(func_pclk));     // Output functional pclk
  BUFG pclkx2bufg (.I(func_pllclk2), .O(func_pclkx2)); // Output functional pclkx2

  wire bufpll_lock;
  BUFPLL #(.DIVIDE(5)) ioclk_buf (.PLLIN(func_pllclk0), .GCLK(func_pclkx2), .LOCKED(func_pll_lckd),
           .IOCLK(func_pclkx10), .SERDESSTROBE(func_serdesstrobe), .LOCK(bufpll_lock)); // Output functional pclkx10 and serdesstrobe

  // Functional reset generation
  assign func_reset = ~bufpll_lock;

  // Instantiate submodules with scan-compatible clocks and reset
  decode_nok # (
	.CHANNEL("BLUE")
  )	dec_b (
    .reset        (reset_scan),        // Use muxed reset
    .pclk         (pclk_scan),         // Use muxed pclk
    .pclkx2       (pclkx2_scan),       // Use muxed pclkx2
    .pclkx10      (pclkx10_scan),      // Use muxed pclkx10
    .serdesstrobe (func_serdesstrobe), // Assuming serdesstrobe is treated as data/enable
    .din_p        (blue_p),
    .din_n        (blue_n),
    .other_ch0_rdy(green_rdy),
    .other_ch1_rdy(red_rdy),
    .other_ch0_vld(green_vld),
    .other_ch1_vld(red_vld),
    .videopreamble(videopreamble),
    .dilndpreamble(dilndpreamble),
    .iamvld       (blue_vld),
    .iamrdy       (blue_rdy),
    .psalgnerr    (blue_psalgnerr),
    .c0           (blue_c0),
    .c1           (blue_c1),
    .vde          (vde_b),
	.ade          (ade_b),
    .sdout        (sdout_blue),
	.adout		  (aux0),
    .vdout        (blue)) ;

  decode_nok # (
	.CHANNEL("GREEN")
  )	dec_g (
    .reset        (reset_scan),        // Use muxed reset
    .pclk         (pclk_scan),         // Use muxed pclk
    .pclkx2       (pclkx2_scan),       // Use muxed pclkx2
    .pclkx10      (pclkx10_scan),      // Use muxed pclkx10
    .serdesstrobe (func_serdesstrobe), // Assuming serdesstrobe is treated as data/enable
    .din_p        (green_p),
    .din_n        (green_n),
    .other_ch0_rdy(blue_rdy),
    .other_ch1_rdy(red_rdy),
    .other_ch0_vld(blue_vld),
    .other_ch1_vld(red_vld),
    .videopreamble(videopreamble),
    .dilndpreamble(dilndpreamble),
    .iamvld       (green_vld),
    .iamrdy       (green_rdy),
    .psalgnerr    (green_psalgnerr),
    .c0           (ctl0),
    .c1           (ctl1),
    .vde          (vde_g),
	.ade          (ade_g),
    .sdout        (sdout_green),
	.adout		  (aux1),
    .vdout        (green)) ;

  decode_nok # (
	.CHANNEL("RED")
  )	dec_r (
    .reset        (reset_scan),        // Use muxed reset
    .pclk         (pclk_scan),         // Use muxed pclk
    .pclkx2       (pclkx2_scan),       // Use muxed pclkx2
    .pclkx10      (pclkx10_scan),      // Use muxed pclkx10
    .serdesstrobe (func_serdesstrobe), // Assuming serdesstrobe is treated as data/enable
    .din_p        (red_p),
    .din_n        (red_n),
    .other_ch0_rdy(blue_rdy),
    .other_ch1_rdy(green_rdy),
    .other_ch0_vld(blue_vld),
    .other_ch1_vld(green_vld),
    .videopreamble(videopreamble),
    .dilndpreamble(dilndpreamble),
    .iamvld       (red_vld),
    .iamrdy       (red_rdy),
    .psalgnerr    (red_psalgnerr),
    .c0           (ctl2),
    .c1           (ctl3),
    .vde          (vde_r),
	.ade          (ade_r),
    .sdout        (sdout_red),
	.adout		  (aux2),
    .vdout        (red)) ;

  assign psalgnerr = red_psalgnerr | blue_psalgnerr | green_psalgnerr;

endmodule

// Note: The 'decode_nok' module itself would also need modification
// to correctly handle the muxed clocks and reset if it contains
// flip-flops clocked by pclk, pclkx2, or pclkx10, or sensitive to reset.
// This solution assumes those clocks/reset are passed through or that
// DFT insertion tools can manage clocking within the sub-module based
// on these top-level muxed inputs. A full DFT implementation would
// typically involve modifying 'decode_nok' as well.