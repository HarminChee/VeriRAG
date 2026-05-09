`timescale 1ps/1ps
module iodelay_ctrl_corrected_clk #
  (
   parameter TCQ         = 100,
   parameter IODELAY_GRP = "IODELAY_MIG",
   parameter INPUT_CLK_TYPE  = "DIFFERENTIAL",
   parameter RST_ACT_LOW  = 1
   )
  (
   input  clk_ref_p,
   input  clk_ref_n,
   input  clk_ref,
   input  sys_rst,
   // DFT specific inputs
   input  scan_mode,      // Added for DFT: Scan mode signal
   input  scan_clk,       // Added for DFT: Scan clock
   input  scan_rst,       // Added for DFT: Scan reset (synchronous)
   output iodelay_ctrl_rdy
   );

  localparam RST_SYNC_NUM = 15;

  // Use dedicated test clock and reset during scan mode
  wire                   clk_muxed;
  wire                   rst_muxed;

  // Internal signals
  wire                   clk_ref_bufg;
  wire                   clk_ref_ibufg;
  wire                   rst_ref;
  reg [RST_SYNC_NUM-1:0] rst_ref_sync_r ;
  wire                   rst_tmp_idelay;
  wire                   sys_rst_act_hi;

  // Determine active high reset
  assign  sys_rst_act_hi = RST_ACT_LOW ? ~sys_rst: sys_rst;

  // Clock Muxing for DFT
  // Select scan_clk during scan_mode, otherwise use functional clock clk_ref_bufg
  assign clk_muxed = scan_mode ? scan_clk : clk_ref_bufg;

  // Reset Muxing for DFT
  // Select scan_rst during scan_mode, otherwise use functional reset rst_tmp_idelay
  assign rst_muxed = scan_mode ? scan_rst : rst_tmp_idelay;

  // Clock Input Buffering
  generate
    if (INPUT_CLK_TYPE == "DIFFERENTIAL") begin: diff_clk_ref
      IBUFGDS #
        (
         .DIFF_TERM ("TRUE"),
         .IBUF_LOW_PWR ("FALSE")
         )
        u_ibufg_clk_ref
          (
           .I  (clk_ref_p),
           .IB (clk_ref_n),
           .O  (clk_ref_ibufg)
           );
    end else if (INPUT_CLK_TYPE == "SINGLE_ENDED") begin : se_clk_ref
      IBUFG #
        (
         .IBUF_LOW_PWR ("FALSE")
         )
        u_ibufg_clk_ref
          (
           .I (clk_ref),
           .O (clk_ref_ibufg)
           );
    end
  endgenerate

  // Clock Buffer
  BUFG u_bufg_clk_ref
    (
     .O (clk_ref_bufg),
     .I (clk_ref_ibufg)
     );

  // Assign functional reset source
  assign rst_tmp_idelay = sys_rst_act_hi;

  // Reset Synchronizer - Modified for DFT compliance (Synchronous Reset)
  // Uses the muxed clock and reset signals
  always @(posedge clk_muxed) begin // Use muxed clock
    if (rst_muxed) begin // Use muxed synchronous reset
      rst_ref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}};
    end else begin
      // Shift register behavior: shift in zeros from LSB when not reset
      rst_ref_sync_r <= #TCQ {rst_ref_sync_r[RST_SYNC_NUM-2:0], 1'b0};
    end
  end

  // Assign the synchronized reset signal
  assign rst_ref  = rst_ref_sync_r[RST_SYNC_NUM-1];

  // IDELAYCTRL Instantiation
  // Note: During scan mode, IDELAYCTRL might need special handling or bypass,
  // depending on the specific test strategy. Here, it uses the functional
  // clock and the synchronized functional reset (derived from rst_muxed logic path).
  // For full DFT compliance, ensure IDELAYCTRL behavior in scan mode is verified.
  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy),
     .REFCLK (clk_ref_bufg), // IDELAYCTRL typically needs the functional reference clock
     .RST    (rst_ref)       // Uses the synchronized reset
     );

endmodule