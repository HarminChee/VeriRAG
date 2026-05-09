`timescale 1ns/1ps

module ddr2_infrastructure #
  (
   parameter CLK_PERIOD    = 3000,
   parameter CLK_TYPE      = "DIFFERENTIAL",
   parameter DLL_FREQ_MODE = "HIGH",
   parameter NOCLK200      = 0,
   parameter RST_ACT_LOW  = 1
   )
  (
   input  sys_clk_p,
   input  sys_clk_n,
   input  sys_clk,
   input  clk200_p,
   input  clk200_n,
   input  idly_clk_200,
   output clk0,
   output clk90,
   output clk200,
   output clkdiv0,
   input  sys_rst_n,
   input  idelay_ctrl_rdy,
   output rst0,
   output rst90,
   output rst200,
   output rstdiv0
   );

  localparam RST_SYNC_NUM = 25;
  localparam CLK_PERIOD_NS = CLK_PERIOD / 1000.0;
  // Use integer division for PLL/DCM divide parameters
  localparam CLK_PERIOD_INT = CLK_PERIOD / 1000;
  localparam CLK_GENERATOR = "PLL"; // Can be "PLL" or "DCM"

  wire                       clk0_bufg;
  wire                       clk0_bufg_in;
  wire                       clk90_bufg;
  wire                       clk90_bufg_in;
  wire                       clk200_bufg;
  wire                       clk200_ibufg;
  wire                       clkdiv0_bufg;
  wire                       clkdiv0_bufg_in;
  wire                       clkfbout_clkfbin;
  wire                       locked;
  reg [RST_SYNC_NUM-1:0]     rst0_sync_r    ;
  reg [RST_SYNC_NUM-1:0]     rst200_sync_r  ;
  reg [RST_SYNC_NUM-1:0]     rst90_sync_r   ;
  reg [(RST_SYNC_NUM/2)-1:0] rstdiv0_sync_r ;
  wire                       rst_tmp;
  wire                       sys_clk_ibufg;
  wire                       sys_rst;

  assign sys_rst = RST_ACT_LOW ? ~sys_rst_n: sys_rst_n;

  assign clk0    = clk0_bufg;
  assign clk90   = clk90_bufg;
  assign clk200  = clk200_bufg;
  assign clkdiv0 = clkdiv0_bufg;

  generate
  if(CLK_TYPE == "DIFFERENTIAL") begin : DIFF_ENDED_CLKS_INST
    // Assuming IBUFGDS_LVPECL_25 is the correct primitive for the target device
    // For newer devices (7-series+), use IBUFDS with appropriate IOSTANDARD
    IBUFGDS #(
      .IOSTANDARD("DEFAULT") // Specify appropriate IO standard if needed
    ) SYS_CLK_INST (
       .I  (sys_clk_p),
       .IB (sys_clk_n),
       .O  (sys_clk_ibufg)
    );
    // Assuming IBUFGDS_LVPECL_25 is the correct primitive for the target device
    // For newer devices (7-series+), use IBUFDS with appropriate IOSTANDARD
    if (NOCLK200 == 0) begin : IBUFDS_200_INST
        IBUFGDS #(
          .IOSTANDARD("DEFAULT") // Specify appropriate IO standard if needed
        ) IDLY_CLK_INST (
           .I  (clk200_p),
           .IB (clk200_n),
           .O  (clk200_ibufg)
        );
    end else begin : NO_IBUFDS_200_INST
        assign clk200_ibufg = 1'b0; // Tie off if not used
    end

  end else if(CLK_TYPE == "SINGLE_ENDED") begin : SINGLE_ENDED_CLKS_INST
    IBUF #(
      .IOSTANDARD("DEFAULT") // Specify appropriate IO standard if needed
    ) SYS_CLK_INST (
       .I  (sys_clk),
       .O  (sys_clk_ibufg)
    );
    if ( NOCLK200 == 0 ) begin : IBUFG_INST
        IBUF #(
          .IOSTANDARD("DEFAULT") // Specify appropriate IO standard if needed
        ) IDLY_CLK_INST (
           .I  (idly_clk_200),
           .O  (clk200_ibufg)
        );
    end else begin : NO_IBUFG_INST
        assign clk200_ibufg = 1'b0; // Tie off if not used
    end
  end
  endgenerate

  generate
    // Instantiate BUFG for clk200 only if clk200 input is used
    if ( NOCLK200 == 0 ) begin : BUFG_INST
      BUFG CLK_200_BUFG
        (
         .O (clk200_bufg),
         .I (clk200_ibufg)
         );
    end else begin : NO_BUFG
      assign clk200_bufg = 1'b0; // Tie off BUFG output if not used
    end
  endgenerate

  generate
    if (CLK_GENERATOR == "PLL") begin : gen_pll_adv
      // Assuming PLL_ADV is the correct primitive for the target device
      // For newer devices (7-series+), use PLLE2_ADV or similar
      PLL_ADV #
        (
         .BANDWIDTH          ("OPTIMIZED"),
         .CLKIN1_PERIOD      (CLK_PERIOD_NS),
         .CLKIN2_PERIOD      (10.000), // Example: Not used as CLKINSEL=1
         .CLKOUT0_DIVIDE     (CLK_PERIOD_INT), // Use integer divide
         .CLKOUT1_DIVIDE     (CLK_PERIOD_INT), // Use integer divide
         .CLKOUT2_DIVIDE     (CLK_PERIOD_INT*2), // Use integer divide
         .CLKOUT3_DIVIDE     (1), // Not used
         .CLKOUT4_DIVIDE     (1), // Not used
         .CLKOUT5_DIVIDE     (1), // Not used
         .CLKOUT0_PHASE      (0.000),
         .CLKOUT1_PHASE      (90.000),
         .CLKOUT2_PHASE      (0.000),
         .CLKOUT3_PHASE      (0.000), // Not used
         .CLKOUT4_PHASE      (0.000), // Not used
         .CLKOUT5_PHASE      (0.000), // Not used
         .CLKOUT0_DUTY_CYCLE (0.500),
         .CLKOUT1_DUTY_CYCLE (0.500),
         .CLKOUT2_DUTY_CYCLE (0.500),
         .CLKOUT3_DUTY_CYCLE (0.500), // Not used
         .CLKOUT4_DUTY_CYCLE (0.500), // Not used
         .CLKOUT5_DUTY_CYCLE (0.500), // Not used
         .COMPENSATION       ("SYSTEM_SYNCHRONOUS"), // Adjust if needed
         .DIVCLK_DIVIDE      (1),
         .CLKFBOUT_MULT      (CLK_PERIOD_INT), // Use integer multiply
         .CLKFBOUT_PHASE     (0.0),
         .REF_JITTER         (0.005000) // Example Jitter
         )
        u_pll_adv
          (
           .CLKFBIN     (clkfbout_clkfbin),
           .CLKINSEL    (1'b1), // Select CLKIN1
           .CLKIN1      (sys_clk_ibufg),
           .CLKIN2      (1'b0), // Tie off unused clock input
           .DADDR       (5'b0), // Dynamic reconfig tied off
           .DCLK        (1'b0), // Dynamic reconfig tied off
           .DEN         (1'b0), // Dynamic reconfig tied off
           .DI          (16'b0),// Dynamic reconfig tied off
           .DWE         (1'b0), // Dynamic reconfig tied off
           .REL         (1'b0), // Dynamic reconfig tied off
           .RST         (sys_rst), // Use combined reset
           // Outputs
           .CLKFBDCM    (), // Unused
           .CLKFBOUT    (clkfbout_clkfbin),
           .CLKOUTDCM0  (), // Unused
           .CLKOUTDCM1  (), // Unused
           .CLKOUTDCM2  (), // Unused
           .CLKOUTDCM3  (), // Unused
           .CLKOUTDCM4  (), // Unused
           .CLKOUTDCM5  (), // Unused
           .CLKOUT0     (clk0_bufg_in),
           .CLKOUT1     (clk90_bufg_in),
           .CLKOUT2     (clkdiv0_bufg_in),
           .CLKOUT3     (), // Unused
           .CLKOUT4     (), // Unused
           .CLKOUT5     (), // Unused
           .DO          (), // Dynamic reconfig tied off
           .DRDY        (), // Dynamic reconfig tied off
           .LOCKED      (locked)
           );
    end else if (CLK_GENERATOR == "DCM") begin: gen_dcm_base
      // Assuming DCM_BASE is the correct primitive for the target device
      // For newer devices (7-series+), use MMCM or PLL
      DCM_BASE #
        (
         .CLKIN_PERIOD          (CLK_PERIOD_NS),
         .CLKDV_DIVIDE          (2.0), // Example divide value
         .DLL_FREQUENCY_MODE    (DLL_FREQ_MODE),
         .DUTY_CYCLE_CORRECTION ("TRUE"),
         .FACTORY_JF            (16'hF0F0) // Example value
         )
        u_dcm_base
          (
           // Outputs
           .CLK0      (clk0_bufg_in),
           .CLK180    (), // Unused
           .CLK270    (), // Unused
           .CLK2X     (), // Unused
           .CLK2X180  (), // Unused
           .CLK90     (clk90_bufg_in),
           .CLKDV     (clkdiv0_bufg_in),
           .CLKFX     (), // Unused
           .CLKFX180  (), // Unused
           .LOCKED    (locked),
           // Inputs
           .CLKFB     (clk0_bufg), // Feedback from CLK0 output buffer
           .CLKIN     (sys_clk_ibufg),
           .RST       (sys_rst) // Use combined reset
           );
    end
  endgenerate

  BUFG U_BUFG_CLK0
    (
     .O (clk0_bufg),
     .I (clk0_bufg_in)
     );

  BUFG U_BUFG_CLK90
    (
     .O (clk90_bufg),
     .I (clk90_bufg_in)
     );

   BUFG U_BUFG_CLKDIV0
    (
     .O (clkdiv0_bufg),
     .I (clkdiv0_bufg_in)
     );

  // Combined reset logic: system reset OR PLL/DCM not locked OR IDELAYCTRL not ready
  assign rst_tmp = sys_rst | ~locked | ~idelay_ctrl_rdy;

  // Asynchronous reset synchronizer for clk0 domain
  always @(posedge clk0_bufg or posedge rst_tmp) begin
    if (rst_tmp)
      rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      // Shift in '0' to deassert reset after RST_SYNC_NUM cycles
      rst0_sync_r <= {rst0_sync_r[RST_SYNC_NUM-2:0], 1'b0};
  end
  assign rst0 = rst0_sync_r[RST_SYNC_NUM-1];

  // Asynchronous reset synchronizer for clk90 domain
  always @(posedge clk90_bufg or posedge rst_tmp) begin
    if (rst_tmp)
      rst90_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      // Shift in '0' to deassert reset after RST_SYNC_NUM cycles
      rst90_sync_r <= {rst90_sync_r[RST_SYNC_NUM-2:0], 1'b0};
  end
  assign rst90 = rst90_sync_r[RST_SYNC_NUM-1];

  // Asynchronous reset synchronizer for clkdiv0 domain
  always @(posedge clkdiv0_bufg or posedge rst_tmp) begin
    if (rst_tmp)
      rstdiv0_sync_r <= {(RST_SYNC_NUM/2){1'b1}};
    else
      // Shift in '0' to deassert reset after (RST_SYNC_NUM/2) cycles
      rstdiv0_sync_r <= {rstdiv0_sync_r[(RST_SYNC_NUM/2)-2:0], 1'b0};
  end
  assign rstdiv0 = rstdiv0_sync_r[(RST_SYNC_NUM/2)-1];

  // Asynchronous reset synchronizer for clk200 domain
  // Use rst_tmp for consistency and robustness
  always @(posedge clk200_bufg or posedge rst_tmp) begin
    // Reset is only active if clk200 is actually generated
    if (rst_tmp && (NOCLK200 == 0))
      rst200_sync_r <= {RST_SYNC_NUM{1'b1}};
    else if (NOCLK200 == 0)
      // Shift in '0' to deassert reset after RST_SYNC_NUM cycles
      rst200_sync_r <= {rst200_sync_r[RST_SYNC_NUM-2:0], 1'b0};
    else // If clk200 is not used, keep reset deasserted (or asserted based on need)
      rst200_sync_r <= {RST_SYNC_NUM{1'b0}}; // Default to deasserted
  end
  assign rst200 = (NOCLK200 == 0) ? rst200_sync_r[RST_SYNC_NUM-1] : 1'b0; // Output 0 if clk200 not used

endmodule