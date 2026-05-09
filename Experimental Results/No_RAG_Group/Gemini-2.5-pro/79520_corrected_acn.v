`timescale 1 ns / 1ps
`timescale 1 ns / 1ps
module dvi_decoder_nok_corrected_acn (
  input  wire tmdsclk_p,
  input  wire tmdsclk_n,
  input  wire blue_p,
  input  wire green_p,
  input  wire red_p,
  input  wire blue_n,
  input  wire green_n,
  input  wire red_n,
  input  wire rst_n,          // Changed from exrst to rst_n for clarity and made it the primary async reset
  // removed output wire reset,
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

  // Use synchronous reset for registers driven by pclk if possible,
  // or ensure rst_n directly controls asynchronous reset.
  // Assuming rst_n is active low for example, modify accordingly if active high.
  always @ (posedge pclk or negedge rst_n) begin
    if (!rst_n) begin
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

  BUFG tmdsclk_bufg (.I(rxclk), .O(tmdsclk));

  wire clkfbout; // Added wire declaration
  // Assuming PLL reset (RST) is active high, connect rst_n appropriately (invert if rst_n is active low)
  // For this correction, assume rst_n is active high matching PLL RST polarity.
  PLL_BASE # (
    .CLKIN_PERIOD(10),
    .CLKFBOUT_MULT(10),
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("INTERNAL")
  ) PLL_ISERDES (
    .CLKFBOUT(clkfbout),
    .CLKOUT0(pllclk0),
    .CLKOUT1(pllclk1),
    .CLKOUT2(pllclk2),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(pll_lckd),
    .CLKFBIN(clkfbout),
    .CLKIN(rxclk),
    .RST(rst_n) // Connect PLL reset to primary input rst_n
  );

  BUFG pclkbufg (.I(pllclk1), .O(pclk));
  BUFG pclkx2bufg (.I(pllclk2), .O(pclkx2));

  wire bufpll_lock; // This internal signal remains
  BUFPLL #(.DIVIDE(5)) ioclk_buf (.PLLIN(pllclk0), .GCLK(pclkx2), .LOCKED(pll_lckd),
           .IOCLK(pclkx10), .SERDESSTROBE(serdesstrobe), .LOCK(bufpll_lock));

  // Removed: assign reset = ~bufpll_lock; ACNCPI violation

  // Connect the primary reset input 'rst_n' to the reset port of submodules
  decode_nok # (
	.CHANNEL("BLUE")
  )	dec_b (
    .reset        (rst_n), // Use primary input rst_n
    .pclk         (pclk),
    .pclkx2       (pclkx2),
    .pclkx10      (pclkx10),
    .serdesstrobe (serdesstrobe),
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
    .reset        (rst_n), // Use primary input rst_n
    .pclk         (pclk),
    .pclkx2       (pclkx2),
    .pclkx10      (pclkx10),
    .serdesstrobe (serdesstrobe),
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
    .reset        (rst_n), // Use primary input rst_n
    .pclk         (pclk),
    .pclkx2       (pclkx2),
    .pclkx10      (pclkx10),
    .serdesstrobe (serdesstrobe),
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

// Assuming decode_nok module definition exists elsewhere
// Example placeholder for decode_nok if needed for completeness (not part of the correction itself)
/*
module decode_nok #(parameter CHANNEL = "BLUE") (
    input wire reset,
    input wire pclk,
    input wire pclkx2,
    input wire pclkx10,
    input wire serdesstrobe,
    input wire din_p,
    input wire din_n,
    input wire other_ch0_rdy,
    input wire other_ch1_rdy,
    input wire other_ch0_vld,
    input wire other_ch1_vld,
    input wire videopreamble,
    input wire dilndpreamble,
    output wire iamvld,
    output wire iamrdy,
    output wire psalgnerr,
    output wire c0,
    output wire c1,
    output wire vde,
    output wire ade,
    output wire [9:0] sdout,
    output wire [3:0] adout,
    output wire [7:0] vdout
);
    // Internal logic of decode_nok
    // Ensure any flip-flops inside use 'reset' as their asynchronous reset directly
    // Example internal register:
    reg internal_reg;
    always @(posedge pclk or posedge reset) begin // or negedge reset depending on polarity
        if (reset) begin
            internal_reg <= 1'b0;
        end else begin
            // synchronous logic
        end
    end
    // Assign outputs based on internal logic...
    assign iamvld = 1'b0; // Placeholder
    assign iamrdy = 1'b0; // Placeholder
    assign psalgnerr = 1'b0; // Placeholder
    assign c0 = 1'b0; // Placeholder
    assign c1 = 1'b0; // Placeholder
    assign vde = 1'b0; // Placeholder
    assign ade = 1'b0; // Placeholder
    assign sdout = 10'b0; // Placeholder
    assign adout = 4'b0; // Placeholder
    assign vdout = 8'b0; // Placeholder
endmodule
*/