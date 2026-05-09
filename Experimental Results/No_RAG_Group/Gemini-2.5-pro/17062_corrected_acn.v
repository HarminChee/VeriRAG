`timescale 1ps / 1ps
`define DLY #1
`timescale 1ps / 1ps
`define DLY #1
module xgbaser_gt_same_quad_wrapper_corrected_acn #
  (
    parameter   WRAPPER_SIM_GTRESET_SPEEDUP = "FALSE"
  )
  (
    input                           gt_txclk322,
    output                          gt_txusrclk,
    output                          gt_txusrclk2,
    output                          qplllock,
    output                          qpllrefclklost,
    output                          qplloutclk,
    output                          qplloutrefclk,
    output  reg                     qplllock_txusrclk2,
    output  reg                     gttxreset_txusrclk2,
    output  reg                     txuserrdy,
    output  reg                     areset_clk_156_25_bufh,
    output  reg                     areset_clk_156_25,
    output  reg                     mmcm_locked_clk156,
    output                          reset_counter_done,
    output reg                      core_reset,
    input                           gt0_tx_resetdone,
    input                           gt1_tx_resetdone,
    input                           gt2_tx_resetdone,
    input                           gt3_tx_resetdone,
    input                           tx_fault,
    output                          gttxreset,
    output                          gtrxreset,
    input                           gt_refclk,
    output                          clk156,
    output                          dclk,
    input                           areset // Primary asynchronous reset input
 );
  wire clk_156_25_bufh;
  wire clk156_buf;
  wire dclk_buf;
  wire clkfbout;
  wire mmcm_locked;
  wire qpllreset;
  reg [7:0] reset_counter = 8'd0;
  reg [3:0] reset_pulse;
  wire            tied_to_ground_i;
  wire    [63:0]  tied_to_ground_vec_i;
  wire            tied_to_vcc_i;
  wire    [7:0]   tied_to_vcc_vec_i;
  assign tied_to_ground_i             = 1'b0;
  assign tied_to_ground_vec_i         = 64'h0000000000000000;
  assign tied_to_vcc_i                = 1'b1;
  assign tied_to_vcc_vec_i            = 8'hff;

  // Temporary registers for two-stage synchronization (often good practice, though not strictly required by ACNCPI fix alone)
  reg core_reset_tmp;
  reg areset_clk_156_25_bufh_tmp;
  reg areset_clk156_25_tmp;
  reg qplllock_txusrclk2_tmp;
  reg mmcm_locked_clk156_tmp;
  reg gttxreset_txusrclk2_tmp;

  MMCME2_BASE
  #(.BANDWIDTH            ("OPTIMIZED"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (6.500),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE_F     (6.500),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT1_DIVIDE       (13),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (6.4),
    .REF_JITTER1          (0.010))
  clkgen_i
  (
    .CLKFBIN(clkfbout),
    .CLKIN1(clk_156_25_bufh),
    .PWRDWN(1'b0),
    // .RST(!qplllock), // Original - ACNCPI violation: Internal signal used as async reset
    .RST(areset),      // Corrected - Use primary input reset 'areset'
    .CLKFBOUT(clkfbout),
    .CLKOUT0(clk156_buf),
    .CLKOUT1(dclk_buf),
    .LOCKED(mmcm_locked)
  );

  BUFG clk156_bufg_inst
  (
      .I                              (clk156_buf),
      .O                              (clk156)
  );

  BUFG dclk_bufg_inst
  (
      .I                              (dclk_buf),
      .O                              (dclk)
  );

  // Core reset logic - Asynchronous reset controlled by primary input 'areset'
  always @(posedge clk156 or posedge areset) // Sensitivity list uses primary reset 'areset'
  begin
    if(areset) // Check primary reset 'areset'
    begin
      core_reset_tmp <= 1'b1;
      core_reset <= 1'b1;
    end
    else
    begin
      core_reset_tmp <= (!(gt0_tx_resetdone) || !(gt1_tx_resetdone) || !(gt2_tx_resetdone) || !(gt3_tx_resetdone) || tx_fault ); // Removed areset check here as it's handled asynchronously
      core_reset <= core_reset_tmp;
    end
  end

  // qplllock synchronization - Asynchronous reset controlled by primary input 'areset'
  // Original used negedge qplllock (internal signal) as async reset - ACNCPI violation
  always @(posedge gt_txusrclk2 or posedge areset) // Sensitivity list uses primary reset 'areset'
  begin
    if (areset) // Check primary reset 'areset'
    begin
      qplllock_txusrclk2_tmp <= 1'b0;
      qplllock_txusrclk2 <= 1'b0;
    end
    else // Synchronous logic based on qplllock
    begin
      qplllock_txusrclk2_tmp <= qplllock; // Sample qplllock state
      qplllock_txusrclk2 <= qplllock_txusrclk2_tmp; // Register sampled state
    end
  end

  // mmcm_locked synchronization - Asynchronous reset controlled by primary input 'areset'
  // Original used negedge mmcm_locked (internal signal) as async reset - ACNCPI violation
  always @(posedge clk156 or posedge areset) // Sensitivity list uses primary reset 'areset'
  begin
    if (areset) // Check primary reset 'areset'
    begin
      mmcm_locked_clk156_tmp <= 1'b0;
      mmcm_locked_clk156 <= 1'b0;
    end
    else // Synchronous logic based on mmcm_locked
    begin
      mmcm_locked_clk156_tmp <= mmcm_locked; // Sample mmcm_locked state
      mmcm_locked_clk156 <= mmcm_locked_clk156_tmp; // Register sampled state
    end
  end

  // gttxreset synchronization - Asynchronous reset controlled by primary input 'areset'
  // Original used posedge gttxreset (internal signal) as async reset - ACNCPI violation
  always @(posedge gt_txusrclk2 or posedge areset) // Sensitivity list uses primary reset 'areset'
  begin
    if (areset) // Check primary reset 'areset'
    begin
      gttxreset_txusrclk2_tmp <= 1'b1; // Assuming reset state is high as per original logic
      gttxreset_txusrclk2 <= 1'b1;
    end
    else // Synchronous logic based on gttxreset
    begin
      gttxreset_txusrclk2_tmp <= gttxreset; // Sample gttxreset state
      gttxreset_txusrclk2 <= gttxreset_txusrclk2_tmp; // Register sampled state
    end
  end

  // txuserrdy logic - Asynchronous reset controlled by primary input 'areset'
  // Original used posedge gttxreset_txusrclk2 (internal signal) as async reset - ACNCPI violation
  always @(posedge gt_txusrclk2 or posedge areset) // Sensitivity list uses primary reset 'areset'
  begin
     if (areset) // Check primary reset 'areset'
       txuserrdy <= 1'b0;
     else if (gttxreset_txusrclk2) // Synchronous check of reset condition
       txuserrdy <= 1'b0;
     else
       txuserrdy <= qplllock_txusrclk2; // Normal operation
  end

  // areset synchronization to clk_156_25_bufh - Asynchronous reset controlled by primary input 'areset'
  always @(posedge clk_156_25_bufh or posedge areset) // Sensitivity list uses primary reset 'areset'
  begin
    if(areset) // Check primary reset 'areset'
    begin
      areset_clk_156_25_bufh_tmp <= 1'b1;
      areset_clk_156_25_bufh <= 1'b1;
    end
    else
    begin
      areset_clk_156_25_bufh_tmp <= 1'b0;
      areset_clk_156_25_bufh <= areset_clk_156_25_bufh_tmp;
    end
  end

  // areset synchronization to clk156 - Asynchronous reset controlled by primary input 'areset'
  always @(posedge clk156 or posedge areset) // Sensitivity list uses primary reset 'areset'
  begin
    if(areset) // Check primary reset 'areset'
    begin
      areset_clk156_25_tmp <= 1'b1;
      areset_clk_156_25 <= 1'b1;
    end
    else
    begin
      areset_clk156_25_tmp <= 1'b0;
      areset_clk_156_25 <= areset_clk156_25_tmp;
    end
  end

  BUFHCE bufhce_156_25_inst(
     .CE  (tied_to_vcc_i),
     .I   (gt_refclk),
     .O   (clk_156_25_bufh)
  );

  BUFG tx322clk_bufg_i
  (
      .I (gt_txclk322),
      .O (gt_txusrclk)
  );

  assign gt_txusrclk2 = gt_txusrclk;

  // Reset counter logic - Asynchronous reset controlled by primary input 'areset'
  // Original used posedge areset_clk_156_25_bufh (internal signal) as async reset - ACNCPI violation
  always @(posedge clk_156_25_bufh or posedge areset) // Sensitivity list uses primary reset 'areset'
  begin