`timescale 1ps/1ps

module iodelay_ctrl #
  (
   parameter TCQ             = 100,
   parameter IODELAY_GRP     = "IODELAY_MIG",
   parameter INPUT_CLK_TYPE  = "DIFFERENTIAL",
   parameter RST_ACT_LOW     = 1
   )
  (
   input  clk_ref_p,
   input  clk_ref_n,
   input  clk_ref,
   input  sys_rst,
   output iodelay_ctrl_rdy
   );

  // Local parameters (RST_SYNC_NUM removed as it's no longer used with standard synchronizer)

  wire   clk_ref_bufg;
  wire   clk_ref_ibufg;
  wire   rst_ref;
  wire   sys_rst_act_hi;

  // Determine active-high reset based on parameter
  assign sys_rst_act_hi = (RST_ACT_LOW == 1) ? ~sys_rst : sys_rst;

  // Input Clock Buffer Selection
  generate
    if (INPUT_CLK_TYPE == "DIFFERENTIAL") begin: diff_clk_ref
      IBUFGDS #
        (
         .DIFF_TERM ("TRUE"),       // Assuming termination is desired
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
    // Optional: Add an 'else' block here to generate an error or default
    // if INPUT_CLK_TYPE is neither "DIFFERENTIAL" nor "SINGLE_ENDED"
    end
  endgenerate

  // Clock Buffer for internal logic and IDELAYCTRL REFCLK
  BUFG u_bufg_clk_ref
    (
     .O (clk_ref_bufg),
     .I (clk_ref_ibufg)
     );

  // Reset Synchronizer (Standard 2-flop synchronizer)
  reg rst_sync_0;
  reg rst_sync_1;

  always @(posedge clk_ref_bufg) begin
    rst_sync_0 <= #TCQ sys_rst_act_hi;
    rst_sync_1 <= #TCQ rst_sync_0;
  end

  assign rst_ref = rst_sync_1; // Use the synchronized reset

  // IDELAYCTRL Primitive Instantiation
  (* IODELAY_GROUP = IODELAY_GRP *) // Synthesis attribute for grouping
  IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy), // Output Ready signal
     .REFCLK (clk_ref_bufg),     // Reference clock (must be stable)
     .RST    (rst_ref)           // Reset, synchronous to REFCLK
     );

endmodule