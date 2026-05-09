`timescale 1ps/1ps
`timescale 1ps/1ps
// File name: 1_corrected_clk.v
module corrected_clk
 (
  input         clk_in1_p,
  input         clk_in1_n,
  output        clk_out1,
  input         reset, // Assuming active-high reset
  output        locked
 );

  // Internal wires
  wire clk_in1_clk_wiz_0; // Clock derived from primary input
  wire clk_out1_clk_wiz_0; // Internally generated clock from PLL
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_wiz_0;
  wire        clkfbout_buf_clk_wiz_0;
  wire        clkfboutb_unused;
  wire        clkout1_unused;
  wire        clkout2_unused;
  wire        clkout3_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high; // Use this for synchronous reset

  // Register clocked by primary-derived clock
  reg  [7:0] seq_reg1 = 8'b0; // Initialize register

  // Input Buffer for primary clock
  IBUFDS clkin1_ibufgds
   (.O  (clk_in1_clk_wiz_0),
    .I  (clk_in1_p),
    .IB (clk_in1_n));

  // PLL Instance
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
    .CLKOUT0             (clk_out1_clk_wiz_0), // PLL output clock
    .CLKOUT1             (clkout1_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    //.CLKOUT6          (), // Port does not exist in PLLE2_ADV primitive
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (clk_in1_clk_wiz_0), // PLL input clock (primary derived)
    .CLKIN2              (1'b0),
    .CLKINSEL            (1'b1),
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    .LOCKED              (locked_int), // PLL lock status
    .PWRDWN              (1'b0),
    .RST                 (reset_high)); // PLL reset

  // Assign reset signal
  assign reset_high = reset;

  // Assign locked output
  assign locked = locked_int;

  // Feedback Buffer
  BUFG clkf_buf
   (.O (clkfbout_buf_clk_wiz_0),
    .I (clkfbout_clk_wiz_0));

  // Output Clock Buffer with Enable
  // The enable signal seq_reg1[7] is now generated synchronously to clk_in1_clk_wiz_0
  BUFGCE clkout1_buf
   (.O   (clk_out1), // Final clock output
    .CE  (seq_reg1[7]), // Enable controlled by seq_reg1
    .I   (clk_out1_clk_wiz_0)); // Input is the PLL generated clock

  // Removed BUFH clkout1_buf_en as its output is no longer used to clock seq_reg1

  // Sequential logic for generating BUFGCE enable
  // Now clocked by clk_in1_clk_wiz_0 (derived from primary input)
  // Added synchronous reset logic
  always @(posedge clk_in1_clk_wiz_0 or posedge reset_high) begin
    if (reset_high) begin
        seq_reg1 <= 8'b0; // Reset register on active-high reset
    end else begin
        // Shift register capturing locked_int status
        // Note: locked_int originates from the PLL domain. Sampling it here
        // introduces a potential Clock Domain Crossing (CDC) issue.
        // This modification focuses solely on fixing the CLKNPI violation.
        seq_reg1 <= {seq_reg1[6:0], locked_int};
    end
  end

endmodule