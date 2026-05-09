`timescale 1ns/1ps

module infrastructure #
  (
   parameter C_INCLK_PERIOD    =  5000,
   parameter C_RST_ACT_LOW      = 1,
   parameter C_INPUT_CLK_TYPE   = "DIFFERENTIAL",
   parameter C_CLKOUT0_DIVIDE   = 1,
   parameter C_CLKOUT1_DIVIDE   = 1,
   parameter C_CLKOUT2_DIVIDE   = 16,
   parameter C_CLKOUT3_DIVIDE   = 8,
   parameter C_CLKFBOUT_MULT    = 2,
   parameter C_DIVCLK_DIVIDE    = 1
   )
  (
   input  sys_clk_p,
   input  sys_clk_n,
   input  sys_clk,
   input  sys_rst_i,
   output clk0,
   output rst0,
   output async_rst,
   output sysclk_2x,
   output sysclk_2x_180,
   output mcb_drp_clk,
   output pll_ce_0,
   output pll_ce_90,
   output pll_lock
   );

  localparam RST_SYNC_NUM = 25; // Number of sync stages
  localparam CLK_PERIOD_NS = C_INCLK_PERIOD / 1000.0;

  wire                       sys_clk_ibufg; // Declare the missing wire
  wire                       clk_2x_0;
  wire                       clk_2x_180;
  wire                       clk0_bufg;
  wire                       clk0_bufg_in;
  wire                       mcb_drp_clk_bufg_in;
  wire                       clkfbout_clkfbin;
  wire                       locked; // PLL Lock signal
  reg [RST_SYNC_NUM-1:0]     rst0_sync_r;
  wire                       rst_tmp;
  reg                        powerup_pll_locked;
  reg                        syn_clk0_powerup_pll_locked;
  wire                       sys_rst;
  wire                       bufpll_mcb_locked; // BUFPLL_MCB Lock signal

  // Determine reset polarity
  assign sys_rst = C_RST_ACT_LOW ? ~sys_rst_i : sys_rst_i;

  // Assign outputs
  assign clk0        = clk0_bufg;
  assign pll_lock    = bufpll_mcb_locked; // Use BUFPLL_MCB lock status

  // Input Clock Buffer Selection
  generate
    if (C_INPUT_CLK_TYPE == "DIFFERENTIAL") begin : diff_input_clk
      IBUFGDS #
        (
         .DIFF_TERM ("TRUE") // Assuming PCB termination
         )
        u_ibufg_sys_clk
          (
           .I  (sys_clk_p),
           .IB (sys_clk_n),
           .O  (sys_clk_ibufg)
           );
    end else if (C_INPUT_CLK_TYPE == "SINGLE_ENDED") begin : se_input_clk
      // For single-ended, assign directly or use IBUFG if needed
      // Assuming direct connection for simplicity based on original code
      assign sys_clk_ibufg = sys_clk;
      // Alternatively, use IBUFG:
      // IBUFG u_ibufg_sys_clk (.I(sys_clk), .O(sys_clk_ibufg));
   end else begin : invalid_clk_type
       // Add synthesis error or default behavior if type is invalid
       // synthesis translate_off
       initial $display("Error: Invalid C_INPUT_CLK_TYPE specified.");
       // synthesis translate_on
       assign sys_clk_ibufg = 1'b0; // Prevent unconnected wire issues
   end
  endgenerate

  // PLL Instantiation
  PLL_ADV #
    (
     .BANDWIDTH          ("OPTIMIZED"),
     .CLKIN1_PERIOD      (CLK_PERIOD_NS),
     .CLKIN2_PERIOD      (0.0), // Set to 0.0 as CLKIN2 is unused
     .CLKOUT0_DIVIDE     (C_CLKOUT0_DIVIDE),
     .CLKOUT1_DIVIDE     (C_CLKOUT1_DIVIDE),
     .CLKOUT2_DIVIDE     (C_CLKOUT2_DIVIDE),
     .CLKOUT3_DIVIDE     (C_CLKOUT3_DIVIDE),
     .CLKOUT4_DIVIDE     (1), // Unused
     .CLKOUT5_DIVIDE     (1), // Unused
     .CLKOUT0_PHASE      (0.000),
     .CLKOUT1_PHASE      (180.000),
     .CLKOUT2_PHASE      (0.000),
     .CLKOUT3_PHASE      (0.000),
     .CLKOUT4_PHASE      (0.000), // Unused
     .CLKOUT5_PHASE      (0.000), // Unused
     .CLKOUT0_DUTY_CYCLE (0.500),
     .CLKOUT1_DUTY_CYCLE (0.500),
     .CLKOUT2_DUTY_CYCLE (0.500),
     .CLKOUT3_DUTY_CYCLE (0.500),
     .CLKOUT4_DUTY_CYCLE (0.500), // Unused
     .CLKOUT5_DUTY_CYCLE (0.500), // Unused
     .SIM_DEVICE         ("SPARTAN6"),
     .COMPENSATION       ("INTERNAL"), // Or SYSTEM_SYNCHRONOUS, etc.
     .DIVCLK_DIVIDE      (C_DIVCLK_DIVIDE),
     .CLKFBOUT_MULT      (C_CLKFBOUT_MULT),
     .CLKFBOUT_PHASE     (0.0),
     .REF_JITTER         (0.01) // Typical value, adjust if needed
     )
    u_pll_adv
      (
       .CLKFBIN     (clkfbout_clkfbin),
       .CLKINSEL    (1'b1), // Use CLKIN1
       .CLKIN1      (sys_clk_ibufg),
       .CLKIN2      (1'b0), // Tie unused input low
       .DADDR       (5'b0), // DRP unused
       .DCLK        (1'b0), // DRP unused
       .DEN         (1'b0), // DRP unused
       .DI          (16'b0),// DRP unused
       .DWE         (1'b0), // DRP unused
       .REL         (1'b0), // DRP unused
       .RST         (sys_rst), // Use processed reset
       // PLL Outputs
       .CLKFBDCM    (), // Unused
       .CLKFBOUT    (clkfbout_clkfbin),
       .CLKOUTDCM0  (), // Unused
       .CLKOUTDCM1  (), // Unused
       .CLKOUTDCM2  (), // Unused
       .CLKOUTDCM3  (), // Unused
       .CLKOUTDCM4  (), // Unused
       .CLKOUTDCM5  (), // Unused
       .CLKOUT0     (clk_2x_0),            // To BUFPLL_MCB
       .CLKOUT1     (clk_2x_180),          // To BUFPLL_MCB
       .CLKOUT2     (clk0_bufg_in),        // To BUFG for clk0
       .CLKOUT3     (mcb_drp_clk_bufg_in), // To BUFGCE for mcb_drp_clk
       .CLKOUT4     (),                    // Unused
       .CLKOUT5     (),                    // Unused
       .DO          (), // DRP unused
       .DRDY        (), // DRP unused
       .LOCKED      (locked) // PLL lock status
       );

  // Clock Buffers
  BUFG U_BUFG_CLK0
    (
     .O (clk0_bufg),
     .I (clk0_bufg_in)
     );

  // Gated clock buffer for DRP clock, enabled by PLL lock
  BUFGCE U_BUFG_DRP_CLK
    (
     .O  (mcb_drp_clk),
     .I  (mcb_drp_clk_bufg_in),
     .CE (locked) // Enable only when PLL is locked
     );

  // Generate sticky lock signals (go high on lock, low on reset)
  // Synchronized to mcb_drp_clk
  always @(posedge mcb_drp_clk or posedge sys_rst) begin
    if (sys_rst) begin
      powerup_pll_locked <= 1'b0;
    end else if (bufpll_mcb_locked) begin // Check BUFPLL_MCB lock
      powerup_pll_locked <= 1'b1;
    end
  end

  // Synchronized to clk0
  always @(posedge clk0_bufg or posedge sys_rst) begin
    if (sys_rst) begin
      syn_clk0_powerup_pll_locked <= 1'b0;
    end else if (bufpll_mcb_locked) begin // Check BUFPLL_MCB lock
      syn_clk0_powerup_pll_locked <= 1'b1;
    end
  end

  // Asynchronous reset generation (active high)
  // Asserted during system reset OR until PLL lock is registered
  assign async_rst = sys_rst | ~powerup_pll_locked;

  // Temporary reset signal for synchronous reset synchronizer (active high)
  // Asserted during system reset OR until PLL lock is registered (sync to clk0)
  assign rst_tmp = sys_rst | ~syn_clk0_powerup_pll_locked;

  // Synchronous Reset Synchronizer (active high reset)
  // Input reset (rst_tmp) is treated asynchronously by the first stage
  always @(posedge clk0_bufg or posedge rst_tmp) begin
    if (rst_tmp) begin
      rst0_sync_r <= {RST_SYNC_NUM{1'b1}}; // Assert reset
    end else begin
      // Shift in '0's during normal operation
      rst0_sync_r <= {rst0_sync_r[RST_SYNC_NUM-2:0], 1'b0};
    end
  end
  // Output of the synchronizer chain is the synchronous reset
  assign rst0 = rst0_sync_r[RST_SYNC_NUM-1];

  // BUFPLL_MCB for Memory Controller Clocking
  BUFPLL_MCB #
    ( .DIVIDE(1) // Or other division factor if needed
      )
    BUFPLL_MCB1
      (
       .IOCLK0         (sysclk_2x),       // Output: MCB IO Clock 0 phase
       .IOCLK1         (sysclk_2x_180),   // Output: MCB IO Clock 180 phase
       .LOCK           (bufpll_mcb_locked),// Output: BUFPLL Lock Status
       .GCLK           (clk0_bufg),       // Input: Global Clock (use clk0)
       .SERDESSTROBE0  (pll_ce_0),        // Output: SerDes Strobe 0 phase
       .SERDESSTROBE1  (pll_ce_90),        // Output: SerDes Strobe 90 phase
       .PLLIN0         (clk_2x_0),        // Input: PLL Clock 0 phase
       .PLLIN1         (clk_2x_180),      // Input: PLL Clock 180 phase
       .LOCKED         (locked)           // Input: PLL Lock Status
       );

endmodule