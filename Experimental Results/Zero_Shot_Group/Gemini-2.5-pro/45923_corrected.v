`timescale 1ps/1ps

module DemoInterconnect_clk_wiz_0_0_clk_wiz
 (
  // Clock out ports
  output        aclk,
  output        uart,
  // Status and control signals
  input         reset,
  output        locked,
  // Clock in ports
  input         clk_in1
 );

  // Input clock buffering
  wire clk_in1_DemoInterconnect_clk_wiz_0_0;
  IBUF clkin1_ibufg
   (.O (clk_in1_DemoInterconnect_clk_wiz_0_0),
    .I (clk_in1));

  // Clocking primitive
  //------------------------------------
  // Instantiation of the MMCM primitive
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused

  wire        aclk_DemoInterconnect_clk_wiz_0_0;
  wire        uart_DemoInterconnect_clk_wiz_0_0;
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_DemoInterconnect_clk_wiz_0_0;
  wire        clkfbout_buf_DemoInterconnect_clk_wiz_0_0;
  wire        clkfboutb_unused;
  wire        clkout0b_unused;
  wire        clkout1b_unused;
  wire        clkout2_unused;
  wire        clkout2b_unused;
  wire        clkout3_unused;
  wire        clkout3b_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;

  reg  [7:0] seq_reg1 = 8'h0;
  reg  [7:0] seq_reg2 = 8'h0;

  MMCME2_ADV
  #(.BANDWIDTH            ("HIGH"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (63.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (10.500),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (63),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (83.333)) // Input clk frequency is 12 MHz (1/12MHz = 83.333 ns, but timescale is ps, so 83333 ps?) Assuming the value is correct for the tool context.
  mmcm_adv_inst
   ( // Clock Outputs: 1-bit (each)
    .CLKFBOUT            (clkfbout_DemoInterconnect_clk_wiz_0_0),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (aclk_DemoInterconnect_clk_wiz_0_0), // 60 MHz
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (uart_DemoInterconnect_clk_wiz_0_0), // 10 MHz
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_DemoInterconnect_clk_wiz_0_0),
    .CLKIN1              (clk_in1_DemoInterconnect_clk_wiz_0_0),
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
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (reset_high)); // Reset is active high

  assign reset_high = reset; // Assign reset directly
  assign locked = locked_int;

  // Clock Monitor Buffer for feedback
  BUFG clkf_buf
   (.O (clkfbout_buf_DemoInterconnect_clk_wiz_0_0),
    .I (clkfbout_DemoInterconnect_clk_wiz_0_0));

  // Output clock buffers with enable synchronized to lock
  BUFGCE clkout1_buf
   (.O   (aclk),
    .CE  (seq_reg1[7]), // Enable when locked signal has propagated
    .I   (aclk_DemoInterconnect_clk_wiz_0_0));

  // Shift register to delay enable until lock is stable
  always @(posedge aclk_DemoInterconnect_clk_wiz_0_0 or posedge reset_high) begin
    if (reset_high == 1'b1) begin
        seq_reg1 <= 8'h00;
    end
    else begin
        seq_reg1 <= {seq_reg1[6:0], locked_int};
    end
  end

  BUFGCE clkout2_buf
   (.O   (uart),
    .CE  (seq_reg2[7]), // Enable when locked signal has propagated
    .I   (uart_DemoInterconnect_clk_wiz_0_0));

  // Shift register to delay enable until lock is stable
  always @(posedge uart_DemoInterconnect_clk_wiz_0_0 or posedge reset_high) begin
    if (reset_high == 1'b1) begin
      seq_reg2 <= 8'h00;
    end
    else begin
        seq_reg2 <= {seq_reg2[6:0], locked_int};
    end
  end

endmodule