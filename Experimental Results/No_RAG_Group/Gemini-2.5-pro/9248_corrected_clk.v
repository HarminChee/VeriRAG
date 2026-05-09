`timescale 1ps/1ps
module iodelay_ctrl_1_corrected_clk #
  (
   parameter TCQ              = 100,
   parameter IODELAY_GRP      = "IODELAY_MIG",
   parameter INPUT_CLK_TYPE   = "DIFFERENTIAL",
   parameter RST_ACT_LOW      = 1,
   parameter DIFF_TERM_REFCLK = "TRUE"
   )
  (
   input  clk_ref_p,
   input  clk_ref_n,
   input  clk_ref_i,
   input  sys_rst,
   // DFT Inputs Added
   input  test_mode,        // DFT test mode enable
   input  test_clk,         // DFT test clock input (Primary Input Clock for DFT)
   // Outputs
   output clk_ref,
   output iodelay_ctrl_rdy
   );

  localparam RST_SYNC_NUM = 15;

  wire                   clk_ref_bufg;
  wire                   clk_ref_ibufg;
  wire                   rst_ref;
  reg [RST_SYNC_NUM-1:0] rst_ref_sync_r ;
  wire                   rst_tmp_idelay;
  wire                   sys_rst_act_hi;

  // DFT Wire Added
  wire                   scan_clk;         // Muxed clock for scan-compatible flops

  assign  sys_rst_act_hi = RST_ACT_LOW ? ~sys_rst: sys_rst;

  generate
    if (INPUT_CLK_TYPE == "DIFFERENTIAL") begin: diff_clk_ref
      IBUFGDS #
        (
         .DIFF_TERM    (DIFF_TERM_REFCLK),
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
           .I (clk_ref_i),
           .O (clk_ref_ibufg)
           );
    end
  endgenerate

  BUFG u_bufg_clk_ref
    (
     .O (clk_ref_bufg),
     .I (clk_ref_ibufg)
     );

  assign clk_ref = clk_ref_bufg;

  // DFT Modification: Select clock based on test_mode
  // In test_mode, use the primary test clock (test_clk).
  // In functional mode, use the buffered functional clock (clk_ref_bufg).
  assign scan_clk = test_mode ? test_clk : clk_ref_bufg;

  assign rst_tmp_idelay = sys_rst_act_hi;

  // DFT Modification: Changed clock source from clk_ref_bufg to scan_clk
  // This ensures the flop can be clocked by a primary input (test_clk) during scan testing.
  always @(posedge scan_clk or posedge rst_tmp_idelay)
    if (rst_tmp_idelay)
      rst_ref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}};
    else
      rst_ref_sync_r <= #TCQ rst_ref_sync_r << 1;

  assign rst_ref  = rst_ref_sync_r[RST_SYNC_NUM-1];

  // The IDELAYCTRL primitive requires a stable reference clock.
  // It continues to use the functional clock clk_ref_bufg.
  // DFT for IDELAYCTRL might involve specific handling/bypassing.
  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy),
     .REFCLK (clk_ref_bufg), // Use functional clock for IDELAYCTRL operation
     .RST    (rst_ref)       // Reset derived from the (now scan-compatible) flop chain
     );

endmodule