`timescale 1ps / 1ps

module xgbaser_gt_same_quad_wrapper #
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
    input                           areset
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
  // wire    [63:0]  tied_to_ground_vec_i; // Unused
  wire            tied_to_vcc_i;
  // wire    [7:0]   tied_to_vcc_vec_i; // Unused

  assign tied_to_ground_i             = 1'b0;
  // assign tied_to_ground_vec_i         = 64'h0000000000000000; // Unused
  assign tied_to_vcc_i                = 1'b1;
  // assign tied_to_vcc_vec_i            = 8'hff; // Unused

  // Removed redundant _tmp variables

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
    .CLKIN1_PERIOD        (6.4), // Corresponds to 156.25 MHz
    .REF_JITTER1          (0.010))
  clkgen_i
  (
    .CLKFBIN(clkfbout),
    .CLKIN1(clk_156_25_bufh), // Input clock is buffered refclk (156.25MHz)
    .PWRDWN(tied_to_ground_i),
    .RST(!qplllock), // MMCM reset controlled by QPLL lock status
    .CLKFBOUT(clkfbout),
    .CLKOUT0(clk156_buf),      // 156.25 MHz * (6.5 / 6.5) = 156.25 MHz
    .CLKOUT1(dclk_buf),        // 156.25 MHz * (6.5 / 13) = 78.125 MHz
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

  // Core reset logic synchronized to clk156 with asynchronous reset 'areset'
  // Deasserts when all GT TX are done, no areset, and no tx_fault
  // Note: tx_fault is treated as asynchronous condition for deassertion logic path.
  // Consider synchronizing tx_fault to clk156 if it's asynchronous.
  always @(posedge clk156 or posedge areset)
  begin
    if(areset)
    begin
      core_reset <= 1'b1;
    end
    else
    begin
      core_reset <= (!(gt0_tx_resetdone) || !(gt1_tx_resetdone) || !(gt2_tx_resetdone) || !(gt3_tx_resetdone) || tx_fault );
    end
  end

  // Register qplllock status in gt_txusrclk2 domain.
  // Uses negedge qplllock as asynchronous clear. Might be risky if qplllock glitches.
  // Consider a proper 2-flop synchronizer if qplllock is asynchronous to gt_txusrclk2.
  always @(posedge gt_txusrclk2 or negedge qplllock)
  begin
    if(!qplllock)
    begin
      qplllock_txusrclk2 <= 1'b0;
    end
    else
    begin
      qplllock_txusrclk2 <= 1'b1;
    end
  end

  // Register mmcm_locked status in clk156 domain.
  // Uses negedge mmcm_locked as asynchronous clear. Might be risky if mmcm_locked glitches.
  // Consider a proper 2-flop synchronizer if mmcm_locked is asynchronous to clk156.
  always @(posedge clk156 or negedge mmcm_locked)
  begin
    if(!mmcm_locked)
    begin
      mmcm_locked_clk156 <= 1'b0;
    end
    else
    begin
      mmcm_locked_clk156 <= 1'b1;
    end
  end

  // Register gttxreset status in gt_txusrclk2 domain.
  // Uses posedge gttxreset as asynchronous set. Might be risky if gttxreset glitches.
  // Consider a proper 2-flop synchronizer if gttxreset is asynchronous to gt_txusrclk2.
  always @(posedge gt_txusrclk2 or posedge gttxreset)
  begin
    if(gttxreset)
    begin
      gttxreset_txusrclk2 <= 1'b1;
    end
    else
    begin
      gttxreset_txusrclk2 <= 1'b0;
    end
  end

  // Generate txuserrdy based on registered reset and lock status in gt_txusrclk2 domain.
  // Uses gttxreset_txusrclk2 as asynchronous reset.
  always @(posedge gt_txusrclk2 or posedge gttxreset_txusrclk2)
  begin
     if(gttxreset_txusrclk2)
       txuserrdy <= 1'b0;
     else
       txuserrdy <= qplllock_txusrclk2; // Assert when not in reset and QPLL is locked (in gt_txusrclk2 domain)
  end

  // Synchronize areset to clk_156_25_bufh domain (output areset_clk_156_25_bufh)
  always @(posedge clk_156_25_bufh or posedge areset)
  begin
    if(areset)
    begin
      areset_clk_156_25_bufh <= 1'b1;
    end
    else
    begin
      areset_clk_156_25_bufh <= 1'b0;
    end
  end

  // Synchronize areset to clk156 domain (output areset_clk_156_25)
  // Note: Output name areset_clk_156_25 might be confusing as it's synced to clk156.
  always @(posedge clk156 or posedge areset)
  begin
    if(areset)
    begin
      areset_clk_156_25 <= 1'b1;
    end
    else
    begin
      areset_clk_156_25 <= 1'b0;
    end
  end

  // Use BUFHCE for clock buffering - ensures clock enable capability if needed later
  BUFHCE bufhce_156_25_inst(
     .CE  (tied_to_vcc_i), // Clock buffer is always enabled
     .I   (gt_refclk),     // Input is the reference clock (156.25MHz)
     .O   (clk_156_25_bufh) // Output buffered clock
  );

  // Buffer the input gt_txclk322 clock to drive gt_txusrclk
  BUFG tx322clk_bufg_i
  (
      .I (gt_txclk322),
      .O (gt_txusrclk)
  );

  // Assign gt_txusrclk2 directly from gt_txusrclk (assuming they are the same clock)
  assign gt_txusrclk2 = gt_txusrclk;

  // Reset sequence generator clocked by clk_156_25_bufh (buffered refclk)
  // Uses the synchronized reset areset_clk_156_25_bufh
  always @(posedge clk_156_25_bufh or posedge areset_clk_156_25_bufh)
  begin
     if (areset_clk_156_25_bufh == 1'b1)
        reset_counter <= 8'd0;
     else if (!reset_counter[7]) // Count until MSB is high
        reset_counter <= reset_counter + 1'b1;
     // else hold the counter value once done (optional, could keep counting)
     // else reset_counter <= reset_counter; // Redundant line
  end

  // Generate reset pulse based on the counter state
  always @(posedge clk_156_25_bufh)
  begin
     if(!reset_counter[7]) // While counter is running
        reset_pulse <= 4'b1110; // Keep reset asserted (pulse[0]=0 implies reset active high?? Check usage below)
                                // Let's assume reset_pulse[0] = 1 means reset is active.
                                // Original: 4'b1110 -> reset_pulse[0]=0. Let's make it active high: 4'b0001
        reset_pulse <= 4'b0001; // Keep reset asserted (active high)
     else // Once counter is done
        reset_pulse <= {reset_pulse[2:0], 1'b0}; // Deassert reset and shift (creates a pulse?)
                                                 // This creates a shift register after reset. If pulse[0] is the reset signal,
                                                 // this keeps reset low after counter is done. Let's make pulse[0] active high during count.
        // Let's make reset active high during count, low after count.
        // reset_pulse[0] = !reset_counter[7]; // Simpler active high reset during count.
        // The shift register logic might be intentional for sequencing multiple resets.
        // Keeping original shift logic, but assuming reset_pulse[0]=1 means active reset.
        // Original: reset_pulse[0] is low during count, then shifts.
        // Let's stick to original meaning: reset_pulse[0] = 1 means *deasserted*.
        // So, reset is active low.
       if(!reset_counter[7])
          reset_pulse <= 4'b0000; // Keep reset asserted (active low)
       else
          reset_pulse <= {reset_pulse[2:0], 1'b1}; // Deassert reset (high) and shift
  end

  assign reset_counter_done = reset_counter[7];

  // Assign reset signals based on reset_pulse[0]. Assuming active low reset.
  // If reset_pulse[0] is 1, reset is inactive (high). If 0, reset is active (low).
  assign   gttxreset =     !reset_pulse[0]; // Active high output derived from active low pulse
  assign   gtrxreset =     !reset_pulse[0]; // Active high output derived from active low pulse
  assign   qpllreset =     !reset_pulse[0]; // Active high output derived from active low pulse


  // Instantiation of the GT common block wrapper
  // Ensure 'ten_gig_eth_pcs_pma_ip_GT_Common_wrapper' module definition exists elsewhere.
  ten_gig_eth_pcs_pma_ip_GT_Common_wrapper # (
      .WRAPPER_SIM_GTRESET_SPEEDUP("TRUE") ) // Using parameter override from instantiation
  ten_gig_eth_pcs_pma_gt_common_block
    (
     .refclk          (gt_refclk),        // Input reference clock (156.25MHz)
     .qplllockdetclk  (dclk),             // Clock for QPLL lock detection (78.125MHz)
     .qpllreset       (qpllreset),        // QPLL reset input (active high)
     .qplllock        (qplllock),         // QPLL lock status output
     .qpllrefclklost  (qpllrefclklost),   // QPLL reference clock lost output
     .qplloutclk      (qplloutclk),       // QPLL output clock
     .qplloutrefclk   (qplloutrefclk)    // QPLL output reference clock
    );

endmodule