`timescale 1ns/1ns
module pcie_clocking_v6_corrected_clk # (
  parameter IS_ENDPOINT = "TRUE",
  parameter CAP_LINK_WIDTH = 8,
  parameter CAP_LINK_SPEED = 4'h1,
  parameter REF_CLK_FREQ = 0,
  parameter USER_CLK_FREQ = 3
)
(
  input  wire        sys_clk,
  input  wire        gt_pll_lock,
  input  wire        sel_lnk_rate,
  input  wire [1:0]  sel_lnk_width,
  // Add a primary reset for DFT friendliness if possible, or ensure reset logic is synchronous
  // input  wire        sys_rst_n, // Example: Add a primary reset if feasible
  output wire        sys_clk_bufg,
  output wire        pipe_clk,
  output wire        user_clk,
  output wire        block_clk,
  output wire        drp_clk,
  output wire        clock_locked
);
  parameter TCQ = 1;
  wire               mmcm_locked;
  wire               mmcm_clkfbin;
  wire               mmcm_clkfbout;
  wire               mmcm_reset;
  wire               clk_500;
  wire               clk_250;
  wire               clk_125;
  wire               user_clk_prebuf;
  wire               sel_lnk_rate_d;
  reg  [1:0]         reg_clock_locked = 2'b11;
  localparam         mmcm_clockin_period  = (REF_CLK_FREQ == 0) ? 10 :
                                            (REF_CLK_FREQ == 1) ? 8 :
                                            (REF_CLK_FREQ == 2) ? 4 : 0;
  localparam         mmcm_clockfb_mult = (REF_CLK_FREQ == 0) ? 10 :
                                         (REF_CLK_FREQ == 1) ? 8 :
                                         (REF_CLK_FREQ == 2) ? 8 : 0;
  localparam         mmcm_divclk_divide = (REF_CLK_FREQ == 0) ? 1 :
                                          (REF_CLK_FREQ == 1) ? 1 :
                                          (REF_CLK_FREQ == 2) ? 2 : 0;
  localparam         mmcm_clock0_div = 4;
  localparam         mmcm_clock1_div = 8;
  localparam         mmcm_clock2_div = ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 0)) ?  32 :
                                       ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 1)) ?  16 :
                                       ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 1)) ?  16 :
                                       ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 1)) ?  16 : 2;
  localparam         mmcm_clock3_div = 2;
  assign             mmcm_reset = 1'b0; // In real design, connect to appropriate reset source

  // Instantiate BUFG for sys_clk first to derive sys_clk_bufg
  BUFG sys_clk_bufg_i  (.O(sys_clk_bufg), .I(sys_clk));

  generate
    if (CAP_LINK_SPEED == 4'h1) begin : GEN1_LINK
      BUFG pipe_clk_bufg (.O(pipe_clk),.I(clk_125));
    end else if (CAP_LINK_SPEED == 4'h2) begin : GEN2_LINK
      // Note: Clocking SRL16E with pipe_clk might still be a DFT concern if pipe_clk is considered internal.
      // Consider clocking with sys_clk_bufg if DFT tools flag this.
      SRL16E #(.INIT(0)) sel_lnk_rate_delay (.Q(sel_lnk_rate_d),
             .D(sel_lnk_rate), .CLK(sys_clk_bufg),.CE(clock_locked), .A3(1'b1),.A2(1'b1),.A1(1'b1),.A0(1'b1));
      BUFGMUX pipe_clk_bufgmux (.O(pipe_clk), .I0(clk_125),.I1(clk_250),.S(sel_lnk_rate_d));
    end else begin : ILLEGAL_LINK_SPEED
       // Add default assignments or error handling if necessary
       assign pipe_clk = 1'b0; // Example default assignment
    end

    // User clock generation logic (remains largely the same, BUFGs driven by MMCM outputs)
    if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 0)) begin : x1_GEN1_31_25
      BUFG user_clk_bufg (.O(user_clk),.I(user_clk_prebuf));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 1)) begin : x1_GEN1_62_50
      BUFG user_clk_bufg (.O(user_clk),.I(user_clk_prebuf));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 2)) begin : x1_GEN1_125_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 3)) begin : x1_GEN1_250_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 1)) begin : x1_GEN2_62_50
      BUFG user_clk_bufg (.O(user_clk),.I(user_clk_prebuf));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 2)) begin : x1_GEN2_125_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 3)) begin : x1_GEN2_250_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 1)) begin : x2_GEN1_62_50
      BUFG user_clk_bufg (.O(user_clk),.I(user_clk_prebuf));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 2)) begin : x2_GEN1_125_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 3)) begin : x2_GEN1_250_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 2)) begin : x2_GEN2_125_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 3)) begin : x2_GEN2_250_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h04) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 2)) begin : x4_GEN1_125_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h04) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 3)) begin : x4_GEN1_250_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h04) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 3)) begin : x4_GEN2_250_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h08) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 3)) begin : x8_GEN1_250_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h08) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 4)) begin : x8_GEN2_250_00
      BUFG user_clk_bufg (.O(user_clk),.I(clk_250));
      BUFG block_clk_bufg (.O(block_clk),.I(clk_500));
    end else begin : ILLEGAL_CONFIGURATION
       // Add default assignments or error handling if necessary
       assign user_clk = 1'b0; // Example default assignment
       assign block_clk = 1'b0; // Example default assignment
    end
  endgenerate

  BUFG drp_clk_bufg_i  (.O(drp_clk), .I(clk_125));
  BUFG clkfbin_bufg_i  (.O(mmcm_clkfbin), .I(mmcm_clkfbout));

  MMCM_ADV # (
    .CLKFBOUT_MULT_F (mmcm_clockfb_mult),
    .DIVCLK_DIVIDE (mmcm_divclk_divide),
    .CLKFBOUT_PHASE(0),
    .CLKIN1_PERIOD (mmcm_clockin_period),
    .CLKIN2_PERIOD (mmcm_clockin_period), // Use CLKIN1 period for CLKIN2 if unused
    .CLKOUT0_DIVIDE_F (mmcm_clock0_div),
    .CLKOUT0_PHASE (0),
    .CLKOUT1_DIVIDE (mmcm_clock1_div),
    .CLKOUT1_PHASE (0),
    .CLKOUT2_DIVIDE (mmcm_clock2_div),
    .CLKOUT2_PHASE (0),
    .CLKOUT3_DIVIDE (mmcm_clock3_div),
    .CLKOUT3_PHASE (0)
    // Add other necessary parameters if defaults are not suitable
  ) mmcm_adv_i (
    .CLKFBOUT     (mmcm_clkfbout),
    .CLKOUT0      (clk_250),
    .CLKOUT1      (clk_125),
    .CLKOUT2      (user_clk_prebuf),
    .CLKOUT3      (clk_500),
    .CLKOUT4      (), // Tied off
    .CLKOUT5      (), // Tied off
    .CLKOUT6      (), // Tied off
    .DO           (), // Tied off
    .DRDY         (), // Tied off
    .CLKFBOUTB    (), // Tied off
    .CLKFBSTOPPED (), // Tied off
    .CLKINSTOPPED (), // Tied off
    .CLKOUT0B     (), // Tied off
    .CLKOUT1B     (), // Tied off
    .CLKOUT2B     (), // Tied off
    .CLKOUT3B     (), // Tied off
    .PSDONE       (), // Tied off
    .LOCKED       (mmcm_locked),
    .CLKFBIN      (mmcm_clkfbin),
    .CLKIN1       (sys_clk_bufg), // Use buffered clock for MMCM input
    .CLKIN2       (1'b0),         // Tied off
    .CLKINSEL     (1'b1),         // Select CLKIN1
    .DADDR        (7'b0),         // Tied off
    .DCLK         (1'b0),         // Tied off
    .DEN          (1'b0),         // Tied off
    .DI           (16'b0),        // Tied off
    .DWE          (1'b0),         // Tied off
    .PSEN         (1'b0),         // Tied off
    .PSINCDEC     (1'b0),         // Tied off
    .PWRDWN       (1'b0),         // Tie high or low as needed
    .PSCLK        (1'b0),         // Tied off
    .RST          (mmcm_reset)    // Connect to appropriate reset
  );

  // Corrected: Use sys_clk_bufg (derived from primary input sys_clk)
  // and make reset synchronous to sys_clk_bufg.
  always @ (posedge sys_clk_bufg) begin
    // Use gt_pll_lock as a synchronous reset condition relative to sys_clk_bufg
    // If a dedicated primary asynchronous reset (e.g., sys_rst_n) is available and preferred for DFT,
    // it should be used instead or in combination, ensuring proper synchronization.
    if (!gt_pll_lock) // Check gt_pll_lock synchronously
      reg_clock_locked[1:0] <= #TCQ 2'b11;
    else
      reg_clock_locked[1:0] <= #TCQ {reg_clock_locked[0], 1'b0};
  end

  // clock_locked depends on the synchronously updated reg_clock_locked and mmcm_locked
  assign  clock_locked = !reg_clock_locked[1] & mmcm_locked;

endmodule