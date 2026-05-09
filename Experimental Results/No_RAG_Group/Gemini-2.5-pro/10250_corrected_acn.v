`timescale 1ns/1ps
module ddr2_infrastructure_corrected_acn #
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
  localparam CLK_PERIOD_INT = CLK_PERIOD/1000;
  localparam CLK_GENERATOR = "PLL";

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
  // wire                       rst_tmp; // Removed - internal reset generation violates ACNCPI
  wire                       sys_clk_ibufg;
  wire                       sys_rst; // Primary asynchronous reset signal

  // Primary asynchronous reset derived directly from primary input
  assign sys_rst = RST_ACT_LOW ? ~sys_rst_n: sys_rst_n;

  assign clk0    = clk0_bufg;
  assign clk90   = clk90_bufg;
  assign clk200  = clk200_bufg;
  assign clkdiv0 = clkdiv0_bufg;

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

  generate
    if (CLK_GENERATOR == "PLL") begin : gen_pll_adv
      PLL_ADV #
        (
         .BANDWIDTH          ("OPTIMIZED"),
         .CLKIN1_PERIOD      (CLK_PERIOD_NS),
         .CLKIN2_PERIOD      (10.000),
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
           .RST         (sys_rst), // PLL reset connected to primary reset
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
           .CLKFB     (clk0_bufg),
           .CLKIN     (sys_clk_ibufg),
           .RST       (sys_rst) // DCM reset connected to primary reset
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

  // Synchronous reset conditions based on internal signals (locked, idelay_ctrl_rdy)
  wire sync_rst_condition = ~locked | ~idelay_ctrl_rdy;
  wire sync_rst_condition_200 = ~locked;

  // Reset synchronizer for clk0 domain
  // Asynchronous reset is sys_rst (from primary input)
  // Synchronous reset condition based on internal signals
  always @(posedge clk0_bufg or posedge sys_rst) begin
    if (sys_rst) begin // Asynchronous reset controlled by primary input
      rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    end else begin // Synchronous logic
      if (sync_rst_condition) begin // Synchronous reset condition
        rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
      end else begin
        rst0_sync_r <= rst0_sync_r << 1;
      end
    end
  end

  // Reset synchronizer for clkdiv0 domain
  // Asynchronous reset is sys_rst (from primary input)
  // Synchronous reset condition based on internal signals
  always @(posedge clkdiv0_bufg or posedge sys_rst) begin
    if (sys_rst) begin // Asynchronous reset controlled by primary input
      rstdiv0_sync_r <= {(RST_SYNC_NUM/2){1'b1}};
    end else begin // Synchronous logic
      if (sync_rst_condition) begin // Synchronous reset condition
        rstdiv0_sync_r <= {(RST_SYNC_NUM/2){1'b1}};
      end else begin
        rstdiv0_sync_r <= rstdiv0_sync_r << 1;
      end
    end
  end

  // Reset synchronizer for clk90 domain
  // Asynchronous reset is sys_rst (from primary input)
  // Synchronous reset condition based on internal signals
  always @(posedge clk90_bufg or posedge sys_rst) begin
    if (sys_rst) begin // Asynchronous reset controlled by primary input
      rst90_sync_r <= {RST_SYNC_NUM{1'b1}};
    end else begin // Synchronous logic
      if (sync_rst_condition) begin // Synchronous reset condition
        rst90_sync_r <= {RST_SYNC_NUM{1'b1}};
      end else begin
        rst90_sync_r <= rst90_sync_r << 1;
      end
    end
  end

  // Reset synchronizer for clk200 domain
  // Asynchronous reset is sys_rst (from primary input)
  // Synchronous reset condition based on internal signal 'locked'
  always @(posedge clk200_bufg or posedge sys_rst) begin
    if (sys_rst) begin // Asynchronous reset controlled by primary input
      rst200_sync_r <= {RST_SYNC_NUM{1'b1}};
    end else begin // Synchronous logic
       if (sync_rst_condition_200) begin // Synchronous reset condition
         rst200_sync_r <= {RST_SYNC_NUM{1'b1}};
       end else begin
         rst200_sync_r <= rst200_sync_r << 1;
       end
    end
  end

  // Output assignments
  assign rst0    = rst0_sync_r[RST_SYNC_NUM-1];
  assign rst90   = rst90_sync_r[RST_SYNC_NUM-1];
  assign rst200  = rst200_sync_r[RST_SYNC_NUM-1];
  assign rstdiv0 = rstdiv0_sync_r[(RST_SYNC_NUM/2)-1];

endmodule