`timescale 1ps/1ps
`timescale 1ps/1ps
module clk_wiz_0_clk_wiz
 (
  input         clk_in1_p,
  input         clk_in1_n,
  input         test_i, // Added test mode input
  output        clk_out1,
  input         reset,
  output        locked
 );
  wire clk_in1_clk_wiz_0;
  IBUFDS clkin1_ibufgds
   (.O  (clk_in1_clk_wiz_0),
    .I  (clk_in1_p),
    .IB (clk_in1_n));
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_wiz_0;
  wire        clkfbout_buf_clk_wiz_0;
  wire        clkfboutb_unused;
   wire clk_out1_clk_wiz_0;
   wire clkout1_unused;
   wire clkout2_unused;
   wire clkout3_unused;
   wire clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;
  reg  [7 :0] seq_reg1 = 0;
  wire clk_out1_clk_wiz_0_en_clk;
  wire dft_seq_reg1_clk;
  wire dft_clkout1_buf_in;
  wire dft_clkout1_buf_ce;

  PLLE2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT        (5),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (4),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (5.0),
    .REF_JITTER1          (0.010))
  plle2_adv_inst
   (
    .CLKFBOUT            (clkfbout_clk_wiz_0),
    .CLKOUT0             (clk_out1_clk_wiz_0),
    .CLKOUT1             (clkout1_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (clk_in1_clk_wiz_0),
    .CLKIN2              (1'b0),
    .CLKINSEL            (1'b1),
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    .LOCKED              (locked_int),
    .PWRDWN              (1'b0),
    .RST                 (reset_high)); // PLL reset controlled by primary reset
  assign reset_high = reset;
  assign locked = locked_int;
  BUFG clkf_buf
   (.O (clkfbout_buf_clk_wiz_0),
    .I (clkfbout_clk_wiz_0));

  // Mux the input clock for the final output buffer based on test_i
  assign dft_clkout1_buf_in = test_i ? clk_in1_clk_wiz_0 : clk_out1_clk_wiz_0;

  // Mux the enable for the final output buffer based on test_i (force enable in test mode)
  assign dft_clkout1_buf_ce = test_i ? 1'b1 : seq_reg1[7];

  BUFGCE clkout1_buf // Final output clock buffer
   (.O   (clk_out1),
    .CE  (dft_clkout1_buf_ce), // Use muxed enable
    .I   (dft_clkout1_buf_in)); // Use muxed clock input

  // This buffer generates the clock for seq_reg1 in functional mode
  BUFH clkout1_buf_en
   (.O   (clk_out1_clk_wiz_0_en_clk),
    .I   (clk_out1_clk_wiz_0));

  // Mux the clock for the seq_reg1 flop based on test_i
  assign dft_seq_reg1_clk = test_i ? clk_in1_clk_wiz_0 : clk_out1_clk_wiz_0_en_clk;

  // seq_reg1 flop clocked by muxed clock, reset by primary reset
  always @(posedge dft_seq_reg1_clk or posedge reset) begin // Use muxed clock and primary reset
    if (reset) begin
        seq_reg1 <= 8'b0;
    end else begin
        seq_reg1 <= {seq_reg1[6:0], locked_int};
    end
  end
endmodule