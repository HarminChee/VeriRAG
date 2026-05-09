`timescale 1ns/1ps
module ddr2_infrastructure_corrected_clk #
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
   output rstdiv0,

   // DFT Signals
   input  test_mode,    // Scan enable / Test mode select
   input  test_clk,     // Scan clock / Test clock
   input  test_rst_n    // Asynchronous test reset (active low if RST_ACT_LOW=1)
   );

  localparam RST_SYNC_NUM = 25;
  localparam CLK_PERIOD_NS = CLK_PERIOD / 1000.0;
  localparam CLK_PERIOD_INT = CLK_PERIOD/1000;
  localparam CLK_GENERATOR = "PLL";

  // Internal wires
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
  wire                       sys_clk_ibufg;
  wire                       sys_rst;
  wire                       rst_tmp;
  wire                       test_rst;

  // Muxed clocks for DFT
  wire                       clk0_muxed;
  wire                       clk90_muxed;
  wire                       clk200_muxed;
  wire                       clkdiv0_muxed;

  // Muxed resets for DFT
  wire                       rst_async_0_90_div0;
  wire                       rst_async_200;


  // Registers for reset synchronization
  reg [RST_SYNC_NUM-1:0]     rst0_sync_r    ;
  reg [RST_SYNC_NUM-1:0]     rst200_sync_r  ;
  reg [RST_SYNC_NUM-1:0]     rst90_sync_r   ;
  reg [(RST_SYNC_NUM/2)-1:0] rstdiv0_sync_r ;


  // Logic assignments
  assign sys_rst = RST_ACT_LOW ? ~sys_rst_n: sys_rst_n;
  assign test_rst = RST_ACT_LOW ? ~test_rst_n : test_rst_n;

  // Clock outputs assignments (remain driven by functional clocks for external use)
  assign clk0    = clk0_bufg;
  assign clk90   = clk90_bufg;
  assign clk200  = clk200_bufg;
  assign clkdiv0 = clkdiv0_bufg;

  // Input clock buffering
  generate
  if(CLK_TYPE == "DIFFERENTIAL") begin : DIFF_ENDED_CLKS_INST
    IBUFGDS_LVPECL_25 SYS_CLK_INST
      (
       .I  (sys_clk_p),
       .IB (sys_clk_n),
       .O  (sys_clk_ibufg)
       );
    IBUFGDS_LVPECL_25 IDLY_CLK_INST
      (
       .I  (clk200_p),
       .IB (clk200_n),
       .O  (clk200_ibufg)
       );
  end else if(CLK_TYPE == "SINGLE_ENDED") begin : SINGLE_ENDED_CLKS_INST
    IBUFG SYS_CLK_INST
      (
       .I  (sys_clk),
       .O  (sys_clk_ibufg)
       );
    if ( NOCLK200 == 0 ) begin : IBUFG_INST
        IBUFG IDLY_CLK_INST
          (
           .I  (idly_clk_200),
           .O  (clk200_ibufg)
           );
    end
  end
  endgenerate

  // clk200 buffering
  generate
    if ( ((NOCLK200 == 0) && (CLK_TYPE == "SINGLE_ENDED")) || (CLK_TYPE == "DIFFERENTIAL") ) begin : BUFG_INST
      BUFG CLK_200_BUFG
        (
         .O (clk200_bufg),
         .I (clk200_ibufg)
         );
    end else begin : NO_BUFG
      assign clk200_bufg = 1'b0;
    end
  endgenerate

  // Clock generator (PLL or DCM)
  generate
    if (CLK_GENERATOR == "PLL") begin : gen_pll_adv
      PLL_ADV #
        (
         .BANDWIDTH          ("OPTIMIZED"),
         .CLKIN1_PERIOD      (CLK_PERIOD_NS),
         .CLKIN2_PERIOD      (10.000), // Example, adjust if needed
         .CLKOUT0_DIVIDE     (CLK_PERIOD_INT),
         .CLKOUT1_DIVIDE     (CLK_PERIOD_INT),
         .CLKOUT2_DIVIDE     (CLK_PERIOD_INT*2),
         .CLKOUT3_DIVIDE     (1),
         .CLKOUT4_DIVIDE     (1),
         .CLKOUT5_DIVIDE     (1),
         .CLKOUT0_PHASE      (0.000),
         .CLKOUT1_PHASE      (90.000),
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
         .COMPENSATION       ("SYSTEM_SYNCHRONOUS"),
         .DIVCLK_DIVIDE      (1),
         .CLKFBOUT_MULT      (CLK_PERIOD_INT),
         .CLKFBOUT_PHASE     (0.0),
         .REF_JITTER         (0.005000)
         )
        u_pll_adv
          (
           .CLKFBIN     (clkfbout_clkfbin),
           .CLKINSEL    (1'b1),
           .CLKIN1      (sys_clk_ibufg),
           .CLKIN2      (1'b0),
           .DADDR       (5'b0),
           .DCLK        (1'b0),
           .DEN         (1'b0),
           .DI          (16'b0),
           .DWE         (1'b0),
           .REL         (1'b0),
           // PLL Reset is controlled by functional reset sys_rst during normal operation
           // In test mode, PLL is typically bypassed or held static, reset control might vary based on DFT strategy
           .RST         (sys_rst),
           .CLKFBDCM    (),
           .CLKFBOUT    (clkfbout_clkfbin),
           .CLKOUTDCM0  (),
           .CLKOUTDCM1  (),
           .CLKOUTDCM2  (),
           .CLKOUTDCM3  (),
           .CLKOUTDCM4  (),
           .CLKOUTDCM5  (),
           .CLKOUT0     (clk0_bufg_in),
           .CLKOUT1     (clk90_bufg_in),
           .CLKOUT2     (clkdiv0_bufg_in),
           .CLKOUT3     (),
           .CLKOUT4     (),
           .CLKOUT5     (),
           .DO          (),
           .DRDY        (),
           .LOCKED      (locked)
           );
    end else if (CLK_GENERATOR == "DCM") begin: gen_dcm_base
      DCM_BASE #
        (
         .CLKIN_PERIOD          (CLK_PERIOD_NS),
         .CLKDV_DIVIDE          (2.0),
         .DLL_FREQUENCY_MODE    (DLL_FREQ_MODE),
         .DUTY_CYCLE_CORRECTION ("TRUE"),
         .FACTORY_JF            (16'hF0F0)
         )
        u_dcm_base
          (
           .CLK0      (clk0_bufg_in),
           .CLK180    (),
           .CLK270    (),
           .CLK2X     (),
           .CLK2X180  (),
           .CLK90     (clk90_bufg_in),
           .CLKDV     (clkdiv0_bufg_in),
           .CLKFX     (),
           .CLKFX180  (),
           .LOCKED    (locked),
           .CLKFB     (clk0_bufg), // Feedback from BUFG output
           .CLKIN     (sys_clk_ibufg),
           // DCM Reset controlled by functional reset
           .RST       (sys_rst)
           );
    end
  endgenerate

  // Output clock buffering
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

  // --- DFT Modifications Start ---

  // Clock Multiplexing for DFT
  // Select test_clk in test_mode, otherwise use functional clock
  assign clk0_muxed    = test_mode ? test_clk : clk0_bufg;
  assign clk90_muxed   = test_mode ? test_clk : clk90_bufg;
  assign clkdiv0_muxed = test_mode ? test_clk : clkdiv0_bufg;
  // clk200 is derived from primary inputs, but muxing provides consistent DFT clocking
  assign clk200_muxed  = test_mode ? test_clk : clk200_bufg;

  // Functional asynchronous reset condition
  assign rst_tmp = sys_rst | ~locked | ~idelay_ctrl_rdy;

  // Reset Multiplexing for DFT
  // Select test_rst in test_mode, otherwise use functional asynchronous reset sources
  assign rst_async_0_90_div0 = test_mode ? test_rst : rst_tmp;
  // For rst200, the original async reset was !locked. Use test_rst in test mode.
  assign rst_async_200       = test_mode ? test_rst : (!locked | sys_rst); // Include sys_rst for robustness if needed

  // --- DFT Modifications End ---


  // Reset synchronization logic using DFT-friendly clocks and resets
  always @(posedge clk0_muxed or posedge rst_async_0_90_div0)
    if (rst_async_0_90_div0)
      rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst0_sync_r <= {rst0_sync_r[RST_SYNC_NUM-2:0], 1'b0}; // Corrected shift direction

  always @(posedge clkdiv0_muxed or posedge rst_async_0_90_div0)
    if (rst_async_0_90_div0)
      rstdiv0_sync_r <= {(RST_SYNC_NUM/2){1'b1}};
    else
      rstdiv0_sync_r <= {rstdiv0_sync_r[(RST_SYNC_NUM/2)-2:0], 1'b0}; // Corrected shift direction

  always @(posedge clk90_muxed or posedge rst_async_0_90_div0)
    if (rst_async_0_90_div0)
      rst90_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst90_sync_r <= {rst90_sync_r[RST_SYNC_NUM-2:0], 1'b0}; // Corrected shift direction

  // Note: The original reset for rst200 was posedge clk200 or negedge locked.
  // Using posedge rst_async_200 maintains positive edge reset convention.
  always @(posedge clk200_muxed or posedge rst_async_200)
    if (rst_async_200)
      rst200_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst200_sync_r <= {rst200_sync_r[RST_SYNC_NUM-2:0], 1'b0}; // Corrected shift direction

  // Assign final synchronized reset outputs
  assign rst0    = rst0_sync_r[RST_SYNC_NUM-1];
  assign rst90   = rst90_sync_r[RST_SYNC_NUM-1];
  assign rst200  = rst200_sync_r[RST_SYNC_NUM-1];
  assign rstdiv0 = rstdiv0_sync_r[(RST_SYNC_NUM/2)-1];

endmodule