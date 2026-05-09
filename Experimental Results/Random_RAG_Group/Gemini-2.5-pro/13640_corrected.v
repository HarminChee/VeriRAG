`timescale 1ps/1ps
`timescale 1ps/1ps
module iodelay_ctrl #
  (
   parameter TCQ         = 100,
   parameter IODELAY_GRP = "IODELAY_MIG",
   parameter INPUT_CLK_TYPE  = "DIFFERENTIAL",
   parameter RST_ACT_LOW  = 1
   )
  (
   input  test_i, // Added test mode input
   input  clk_ref_p,
   input  clk_ref_n,
   input  clk_ref,
   input  sys_rst,
   output iodelay_ctrl_rdy
   );
  localparam RST_SYNC_NUM = 15;
  wire                   clk_ref_bufg;
  wire                   clk_ref_ibufg;
  wire                   rst_ref;
  reg [RST_SYNC_NUM-1:0] rst_ref_sync_r ;
  wire                   rst_tmp_idelay; // Keep this name for FF reset clarity
  wire                   sys_rst_act_hi;
  wire                   idelayctrl_rst; // New wire for IDELAYCTRL reset

  assign  sys_rst_act_hi = RST_ACT_LOW ? ~sys_rst: sys_rst;
  assign  rst_tmp_idelay = sys_rst_act_hi; // Use this for the FF reset

  // Generate clock buffer
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

  BUFG u_bufg_clk_ref
    (
     .O (clk_ref_bufg),
     .I (clk_ref_ibufg)
     );

  // Synchronizer FF with standard level-sensitive async reset
  // Reset signal rst_tmp_idelay is derived from PI sys_rst
  always @(posedge clk_ref_bufg or posedge rst_tmp_idelay) // Use active-high level-sensitive reset
    if (rst_tmp_idelay)
      rst_ref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}};
    else
      rst_ref_sync_r <= #TCQ rst_ref_sync_r << 1;

  assign rst_ref  = rst_ref_sync_r[RST_SYNC_NUM-1]; // Functional synchronized reset

  // Select IDELAYCTRL reset based on test mode
  // During test (test_i=1), use the direct async reset from PI.
  // During functional mode (test_i=0), use the synchronized reset.
  assign idelayctrl_rst = test_i ? rst_tmp_idelay : rst_ref;

  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy),
     .REFCLK (clk_ref_bufg),
     .RST    (idelayctrl_rst) // Use the muxed reset
     );
endmodule