`timescale 1ps/1ps
`timescale 1ps/1ps
module clk_wiz_0_clk_wiz
 (
  input         clk_in1_p,
  input         clk_in1_n,
  output        clk_out1,
  input         reset,
  output        locked,
  // DFT Ports Added
  input         test_i,
  input         scan_clk
 );

  // Original Wires
  wire        clk_in1_clk_wiz_0;
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_wiz_0;
  wire        clkfbout_buf_clk_wiz_0;
  wire        clkfboutb_unused;
  wire        clk_out1_clk_wiz_0; // Output from PLL
  wire        clkout1_unused;
  wire        clkout2_unused;
  wire        clkout3_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;
  wire        clk_out1_clk_wiz_0_en_clk; // Clock for seq_reg1 (from BUFH)

  // DFT Wires Added
  wire        dft_clk_out1_clk_wiz_0_en_clk;

  reg  [7 :0] seq_reg1 = 0;

  IBUFDS clkin1_ibufgds
   (.O  (clk_in1_clk_wiz_0),
    .I  (clk_in1_p),
    .IB (clk_in1_n));

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
    .CLKOUT0             (clk_out1_clk_wiz_0), // Internally generated clock
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
    .RST                 (reset_high));

  assign reset_high = reset;
  assign locked = locked_int;

  BUFG clkf_buf
   (.O (clkfbout_buf_clk_wiz_0),
    .I (clkfbout_clk_wiz_0));

  // Note: The BUFGCE drives the final output clk_out1.
  // Its enable comes from seq_reg1[7], which is clocked by the internal clock.
  // This might still be a DFT issue depending on how clk_out1 is used downstream.
  // However, the direct violation is the clocking of seq_reg1 itself.
  BUFGCE clkout1_buf
   (.O   (clk_out1),
    .CE  (seq_reg1[7]),
    .I   (clk_out1_clk_wiz_0));

  // This BUFH generates the clock for seq_reg1
  BUFH clkout1_buf_en
   (.O   (clk_out1_clk_wiz_0_en_clk),
    .I   (clk_out1_clk_wiz_0));

  // DFT MUX for the clock driving seq_reg1
  assign dft_clk_out1_clk_wiz_0_en_clk = test_i ? scan_clk : clk_out1_clk_wiz_0_en_clk;

  // Modified always block using the DFT-muxed clock
  always @(posedge dft_clk_out1_clk_wiz_0_en_clk)
        seq_reg1 <= {seq_reg1[6:0],locked_int};

endmodule