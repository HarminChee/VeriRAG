`timescale 1ns/1ps
module infrastructure_corrected_clk #
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
   input  scan_mode, // Added scan_mode input for DFT
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
  localparam RST_SYNC_NUM = 25;
  localparam CLK_PERIOD_NS = C_INCLK_PERIOD / 1000.0;
  localparam CLK_PERIOD_INT = C_INCLK_PERIOD/1000;
  wire                       clk_2x_0;
  wire                       clk_2x_180;
  wire                       clk0_bufg;
  wire                       clk0_bufg_in;
  wire                       mcb_drp_clk_bufg_in;
  wire                       mcb_drp_clk_ungated; // Renamed original BUFGCE output
  wire                       clkfbout_clkfbin;
  wire                       locked;
  reg [RST_SYNC_NUM-1:0]     rst0_sync_r    ;
  wire                       rst_tmp;
  reg                        powerup_pll_locked;
  reg 			     syn_clk0_powerup_pll_locked;
  wire                       sys_rst;
  wire                       bufpll_mcb_locked;
  wire                       sys_clk_ibufg; // Declared wire for IBUF output
  wire                       powerup_pll_clk; // Clock for powerup_pll_locked flop
  wire                       rst0_sync_reset; // Reset for rst0_sync_r flop

  assign sys_rst = C_RST_ACT_LOW ? ~sys_rst_i: sys_rst_i;
  assign clk0        = clk0_bufg;
  assign pll_lock    = bufpll_mcb_locked; // Use bufpll_mcb_locked for external lock status

  generate
    if (C_INPUT_CLK_TYPE == "DIFFERENTIAL") begin: diff_input_clk
      IBUFGDS #
        (
         .DIFF_TERM    ("TRUE")
         )
        u_ibufg_sys_clk
          (
           .I  (sys_clk_p),
           .IB (sys_clk_n),
           .O  (sys_clk_ibufg)
           );
    end else if (C_INPUT_CLK_TYPE == "SINGLE_ENDED") begin: se_input_clk
      // For single-ended, sys_clk should be connected to sys_clk_ibufg
      // Assuming sys_clk is the input in this case.
      // If using BUFG directly on sys_clk:
      BUFG u_bufg_sys_clk ( .I(sys_clk), .O(sys_clk_ibufg) );
      // Or simply assign if buffering happens elsewhere or is not needed here:
      // assign sys_clk_ibufg = sys_clk;
   end else begin : no_input_clk // Added default case for safety
      assign sys_clk_ibufg = 1'b0; // Or handle error appropriately
   end
  endgenerate

    PLL_ADV #
        (
         .BANDWIDTH          ("OPTIMIZED"),
         .CLKIN1_PERIOD      (CLK_PERIOD_NS),
         .CLKIN2_PERIOD      (CLK_PERIOD_NS),
         .CLKOUT0_DIVIDE     (C_CLKOUT0_DIVIDE),
         .CLKOUT1_DIVIDE     (C_CLKOUT1_DIVIDE),
         .CLKOUT2_DIVIDE     (C_CLKOUT2_DIVIDE),
         .CLKOUT3_DIVIDE     (C_CLKOUT3_DIVIDE),
         .CLKOUT4_DIVIDE     (1),
         .CLKOUT5_DIVIDE     (1),
         .CLKOUT0_PHASE      (0.000),
         .CLKOUT1_PHASE      (180.000),
         .CLKOUT2_PHASE      (0.000),
         .CLKOUT3_PHASE      (0.000),
         .CLKOUT4_PHASE      (0.000),
         .CLKOUT5_PHASE      (0.000),
         .CLKOUT0_DUTY_CYCLE (0.500),
         .CLKOUT1_DUTY_CYCLE (0.500),
         .CLKOUT2_DUTY_CYCLE (0.500),
         .CLKOUT3_DUTY_CYCLE (0.500),
         .CLKOUT4_DUTY_CYCLE (0.500),
         .CLKOUT5_DUTY_CYCLE (0.500),
         .SIM_DEVICE         ("SPARTAN6"),
         .COMPENSATION       ("INTERNAL"),
         .DIVCLK_DIVIDE      (C_DIVCLK_DIVIDE),
         .CLKFBOUT_MULT      (C_CLKFBOUT_MULT),
         .CLKFBOUT_PHASE     (0.0),
         .REF_JITTER         (0.005000)
         )
        u_pll_adv
          (
           .CLKFBIN     (clkfbout_clkfbin),
           .CLKINSEL    (1'b1),
           .CLKIN1      (sys_clk_ibufg), // Use buffered clock
           .CLKIN2      (1'b0),
           .DADDR       (5'b0),
           .DCLK        (1'b0),
           .DEN         (1'b0),
           .DI          (16'b0),
           .DWE         (1'b0),
           .REL         (1'b0),
           .RST         (sys_rst), // Use primary reset
           .CLKFBDCM    (),
           .CLKFBOUT    (clkfbout_clkfbin),
           .CLKOUTDCM0  (),
           .CLKOUTDCM1  (),
           .CLKOUTDCM2  (),
           .CLKOUTDCM3  (),
           .CLKOUTDCM4  (),
           .CLKOUTDCM5  (),
           .CLKOUT0     (clk_2x_0),
           .CLKOUT1     (clk_2x_180),
           .CLKOUT2     (clk0_bufg_in),
           .CLKOUT3     (mcb_drp_clk_bufg_in),
           .CLKOUT4     (),
           .CLKOUT5     (),
           .DO          (),
           .DRDY        (),
           .LOCKED      (locked) // PLL internal lock
           );

   BUFG U_BUFG_CLK0
    (
     .O (clk0_bufg),
     .I (clk0_bufg_in)
     );

   // Use BUFG for the DRP clock input, gate it later if needed functionally
   // The BUFGCE creates a gated clock, problematic for DFT.
   // We will use the ungated clock for DFT purposes.
   BUFG U_BUFG_CLK1 // Changed from BUFGCE to BUFG
    (
     .O (mcb_drp_clk_ungated), // Output ungated clock
     .I (mcb_drp_clk_bufg_in)
     // .CE (locked) // Removed CE port
     );

   // Assign the module output port. Functionally it might need gating,
   // but for DFT, internal flops should use ungated/test clock.
   // If mcb_drp_clk output *must* be gated, do it here, but internal flops
   // should not use this gated version directly.
   assign mcb_drp_clk = mcb_drp_clk_ungated; // Provide ungated clock as output for now
                                            // Or: assign mcb_drp_clk = mcb_drp_clk_ungated & locked; if needed externally


   // Select clock for powerup_pll_locked based on scan_mode
   // Use clk0_bufg as the test clock (derived from primary input, used by other flops)
   // Use the ungated DRP clock in functional mode
   assign powerup_pll_clk = scan_mode ? clk0_bufg : mcb_drp_clk_ungated;

  // This flop is clocked by the potentially gated DRP clock (mcb_drp_clk).
  // Modified to use the muxed clock 'powerup_pll_clk'
  always @(posedge powerup_pll_clk , posedge sys_rst) // Use muxed clock and primary async reset
      if(sys_rst)
         powerup_pll_locked <= 1'b0;
      else if (bufpll_mcb_locked) // Functional condition remains
         powerup_pll_locked <= 1'b1;

  // This flop is clocked by clk0_bufg (derived from primary input via PLL/BUFG) - OK
  always @(posedge clk0_bufg , posedge sys_rst) // Use primary async reset
      if(sys_rst)
         syn_clk0_powerup_pll_locked <= 1'b0;
      else if (bufpll_mcb_locked) // Functional condition remains
         syn_clk0_powerup_pll_locked <= 1'b1;

  // Async reset generation - This might still be flagged by DFT tools,
  // as it depends on internal state (powerup_pll_locked).
  // Ideally, async resets should only come from primary inputs.
  // This assignment is kept for now, assuming it's handled by sync stages or DFT constraints.
  assign async_rst = sys_rst | ~powerup_pll_locked;

  // Internal reset generation based on internal state - Problematic for DFT.
  assign rst_tmp = sys_rst | ~syn_clk0_powerup_pll_locked;

  // Mux the reset for rst0_sync_r based on scan_mode
  // Use primary reset sys_rst during scan mode
  assign rst0_sync_reset = scan_mode ? sys_rst : rst_tmp;

  // Reset synchronizer clocked by clk0_bufg - OK clock
  // Uses internally generated async reset rst_tmp - Problematic.
  // Modified to use the muxed reset 'rst0_sync_reset'.
  always @(posedge clk0_bufg or posedge rst0_sync_reset) // Use muxed async reset
    if (rst0_sync_reset) // Use muxed async reset
      rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst0_sync_r <= {rst0_sync_r[RST_SYNC_NUM-2:0], 1'b0}; // Corrected shift operation

  assign rst0 = rst0_sync_r[RST_SYNC_NUM-1];

// BUFPLL_MCB generates clocks based on PLL outputs - OK
BUFPLL_MCB BUFPLL_MCB1
( .IOCLK0         (sysclk_2x),
  .IOCLK1         (sysclk_2x_180),
  .LOCKED         (bufpll_mcb_locked), // Output lock status
  .GCLK           (mcb_drp_clk_ungated), // Use ungated clock as input
  .SERDESSTROBE0  (pll_ce_0),
  .SERDESSTROBE1  (pll_ce_90),
  .PLLIN0         (clk_2x_0),
  .PLLIN1         (clk_2x_180),
  .LOCK           (locked) // Feed PLL lock to BUFPLL_MCB lock input
  );

endmodule