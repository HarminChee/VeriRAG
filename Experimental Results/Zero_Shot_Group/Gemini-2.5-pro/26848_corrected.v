`timescale 1ps/1ps

module clk_wiz_0_clk_wiz
 (
  // Clock in ports
  input         clk_in1_p,
  input         clk_in1_n,
  // Clock out ports
  output        clk_out1,
  // Status and control signals
  input         reset,
  output        locked
 );

// Input buffering
  //------------------------------------
  wire clk_in1_clk_wiz_0;
  IBUFDS clkin1_ibufgds
   (.O  (clk_in1_clk_wiz_0),
    .I  (clk_in1_p),
    .IB (clk_in1_n));


// Clocking PRIMITIVE
  //------------------------------------
  // Instantiation of the PLL PRIMITIVE
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused

  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_wiz_0;
  wire        clkfbout_buf_clk_wiz_0;
  wire        clkfboutb_unused;
  wire        clk_out1_clk_wiz_0;
  wire        clkout1_unused;
  wire        clkout2_unused;
  wire        clkout3_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;
  wire        clk_out1_clk_wiz_0_en_clk; // Declare the missing wire

  reg  [7 :0] seq_reg1 = 8'b0;


  PLLE2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT        (5), // Assuming input is 200MHz, VCO = 1000MHz
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (4), // CLKOUT0 = 1000MHz / 4 = 250MHz
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (5.0), // Period for 200MHz
    .REF_JITTER1          (0.010))
  plle2_adv_inst
   (
    // Output clocks
    .CLKFBOUT            (clkfbout_clk_wiz_0),
    .CLKOUT0             (clk_out1_clk_wiz_0),
    .CLKOUT1             (clkout1_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (clk_in1_clk_wiz_0),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Other control and status signals
    .LOCKED              (locked_int),
    .PWRDWN              (1'b0),
    .RST                 (reset_high) ); // Connect reset properly

  assign reset_high = reset; // Deassert reset when reset input is low

  assign locked = locked_int;

// Output buffering
  //------------------------------------

  BUFG clkf_buf
   (.O (clkfbout_buf_clk_wiz_0),
    .I (clkfbout_clk_wiz_0));

  BUFGCE clkout1_buf
   (.O   (clk_out1),
    .CE  (seq_reg1[7]),
    .I   (clk_out1_clk_wiz_0));

  // Use BUFG for the clock driving the sequential logic for better distribution
  BUFG clkout1_buf_en_driver
   (.O   (clk_out1_clk_wiz_0_en_clk),
    .I   (clk_out1_clk_wiz_0));

  // DFT logic: Enable output clock only after locked has been high for 8 cycles
  always @(posedge clk_out1_clk_wiz_0_en_clk or posedge reset_high)
  begin
    if (reset_high)
        seq_reg1 <= 8'b0;
    else
        seq_reg1 <= {seq_reg1[6:0], locked_int};
  end

endmodule