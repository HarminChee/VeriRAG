`timescale 1ps/1ps
`timescale 1ps/1ps
module clk_wiz_0_clk_wiz 
 (
  input         clk_in1_p,
  input         clk_in1_n,
  output        clk_out1,
  input         reset,
  output        locked,
  input         test_i // Added test mode input
 );
  // Input clock buffering
  wire clk_in1_clk_wiz_0;
  IBUFDS clkin1_ibufgds
   (.O  (clk_in1_clk_wiz_0),
    .I  (clk_in1_p),
    .IB (clk_in1_n));

  // Internal wires
  wire        clk_out1_clk_wiz_0;
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_wiz_0;
  wire        clkfbout_buf_clk_wiz_0;
  wire        clkfboutb_unused;
   wire clkout1_unused;
   wire clkout2_unused;
   wire clkout3_unused;
   wire clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;
  wire        clk_out1_clk_wiz_0_en_clk; // Original clock for seq_reg1
  wire        dft_clk; // Multiplexed DFT clock

  reg  [7 :0] seq_reg1 = 0;

  // PLL instance
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
    .CLKOUT0             (clk_out1_clk_wiz_0), // Generated clock
    .CLKOUT1             (clkout1_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
     // Clock Frequencies:
     // CLKOUT0 = 1 * 5.0 / 4 = 1.250
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (clk_in1_clk_wiz_0), // Primary clock input
    .CLKIN2              (1'b0),
     // Input clock control
    .CLKINSEL            (1'b1),
     // Dynamic reconfiguration ports
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (locked_int),
    .PWRDWN              (1'b0),
    .RST                 (reset_high) // Reset derived from primary input
    );

  // Reset assignment
  assign reset_high = reset;

  // Output assignment
  assign locked = locked_int;

  // Clock buffering for feedback
  BUFG clkf_buf
   (.O (clkfbout_buf_clk_wiz_0),
    .I (clkfbout_clk_wiz_0));

  // Output clock buffering (gated)
  BUFGCE clkout1_buf
   (.O   (clk_out1),
    .CE  (seq_reg1[7]), // Gated by internal register
    .I   (clk_out1_clk_wiz_0)); // Input is the generated clock

  // Internal clock buffering (used to clock seq_reg1 originally)
  BUFH clkout1_buf_en
   (.O   (clk_out1_clk_wiz_0_en_clk),
    .I   (clk_out1_clk_wiz_0));

  // DFT Clock Mux: Select primary clock in test mode, generated clock otherwise
  assign dft_clk = test_i ? clk_in1_clk_wiz_0 : clk_out1_clk_wiz_0_en_clk;

  // Register logic: Use the multiplexed DFT clock
  // This register causes the CLKNPI violation as it's clocked by a generated clock in functional mode.
  always @(posedge dft_clk) // Changed clock source to dft_clk
  begin
        seq_reg1 <= {seq_reg1[6:0], locked_int};
  end

endmodule