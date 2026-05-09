`timescale 1ps/1ps

module iodelay_ctrl #
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
   output clk_ref,
   output iodelay_ctrl_rdy
   );

  localparam RST_SYNC_NUM = 15; // Number of reset synchronization stages

  wire                   clk_ref_bufg;
  wire                   clk_ref_ibufg;
  wire                   rst_ref;
  reg [RST_SYNC_NUM-1:0] rst_ref_sync_r ;
  wire                   rst_tmp_idelay;
  wire                   sys_rst_act_hi;

  // Determine active high reset based on parameter
  assign  sys_rst_act_hi = RST_ACT_LOW ? ~sys_rst: sys_rst;

  // Generate block for selecting input clock buffer type
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
    end else begin : invalid_clk_type // Added for robustness
      // Synthesis tools might require a default case or handle this
      // For simulation, let's tie the output low or generate an error
      assign clk_ref_ibufg = 1'b0;
      // Consider adding $error statement for unsupported type in simulation
    end
  endgenerate

  // Clock buffer for driving internal logic and IDELAYCTRL
  BUFG u_bufg_clk_ref
    (
     .O (clk_ref_bufg),
     .I (clk_ref_ibufg)
     );

  // Output the buffered clock
  assign clk_ref = clk_ref_bufg;

  // Intermediate signal for reset (active high)
  assign rst_tmp_idelay = sys_rst_act_hi;

  // Reset Synchronizer (asynchronous reset assertion, synchronous deassertion)
  // This synchronizes the reset signal to the clk_ref_bufg domain.
  // The register itself is reset asynchronously when rst_tmp_idelay goes high.
  // The deassertion (rst_tmp_idelay going low) is synchronized through the shift register.
  always @(posedge clk_ref_bufg or posedge rst_tmp_idelay) begin
    if (rst_tmp_idelay) begin // Asynchronous reset asserted (active high)
      rst_ref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}}; // Set all stages high
    end else begin // Clocked behavior: Synchronize reset deassertion
      // Shift '0' into the synchronizer chain when reset is inactive.
      rst_ref_sync_r <= #TCQ {rst_ref_sync_r[RST_SYNC_NUM-2:0], 1'b0};
    end
  end

  // Synchronized reset signal (output of the last stage)
  assign rst_ref  = rst_ref_sync_r[RST_SYNC_NUM-1];

  // IDELAYCTRL Primitive Instantiation
  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy), // Output: Ready signal
     .REFCLK (clk_ref_bufg),     // Input: Reference clock
     .RST    (rst_ref)           // Input: Reset (synchronized)
     );

endmodule