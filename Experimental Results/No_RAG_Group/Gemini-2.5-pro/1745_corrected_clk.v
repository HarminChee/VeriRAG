`timescale 1ps/1ps
module mig_7series_v1_9_iodelay_ctrl_corrected #(
  parameter TCQ              = 100,
  parameter IODELAY_GRP      = "IODELAY_MIG",
  parameter REFCLK_TYPE      = "DIFFERENTIAL",
  parameter SYSCLK_TYPE      = "DIFFERENTIAL",
  parameter SYS_RST_PORT     = "FALSE",
  parameter RST_ACT_LOW      = 1,
  parameter DIFF_TERM_REFCLK = "TRUE"
)
(
  input  clk_ref_p,
  input  clk_ref_n,
  input  clk_ref_i,
  input  sys_rst,
  output clk_ref,
  output sys_rst_o,
  output iodelay_ctrl_rdy,
  output rst_tmp_idelay,
  output rst_ref,
  input  pll_locked,

  // DFT Inputs
  input  scan_mode,      // DFT Scan Mode enable
  input  scan_clk,       // DFT Scan Clock
  input  scan_reset      // DFT Scan Reset (synchronous)
);

  localparam RST_SYNC_NUM = 15;

  wire                   clk_ref_bufg;
  wire                   clk_ref_ibufg;
  (* keep = "true", max_fanout = 10 *) reg [RST_SYNC_NUM-1:0] rst_ref_sync_r ;
  wire                   sys_rst_act_hi;
  wire                   clk_ff;         // Muxed clock for FF
  wire                   reset_ff;       // Muxed reset for FF

  generate
    if (SYS_RST_PORT == "TRUE")
      IBUF u_sys_rst_ibuf
        (
         .I (sys_rst),
         .O (sys_rst_o)
         );
    else
      assign sys_rst_o = sys_rst;
  endgenerate

  assign sys_rst_act_hi = RST_ACT_LOW ? ~sys_rst_o: sys_rst_o;

  generate
    if (REFCLK_TYPE == "DIFFERENTIAL") begin: diff_clk_ref
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
      BUFG u_bufg_clk_ref
        (
         .O (clk_ref_bufg),
         .I (clk_ref_ibufg)
         );
    end else if (REFCLK_TYPE == "SINGLE_ENDED") begin : se_clk_ref
      IBUFG #
        (
         .IBUF_LOW_PWR ("FALSE")
         )
        u_ibufg_clk_ref
          (
           .I (clk_ref_i),
           .O (clk_ref_ibufg)
           );
      BUFG u_bufg_clk_ref
        (
         .O (clk_ref_bufg),
         .I (clk_ref_ibufg)
         );
    end else if ((REFCLK_TYPE == "NO_BUFFER") ||
                 (REFCLK_TYPE == "USE_SYSTEM_CLOCK" && SYSCLK_TYPE == "NO_BUFFER")) begin : clk_ref_noibuf_nobuf
      assign clk_ref_bufg = clk_ref_i;
    end else if (REFCLK_TYPE == "USE_SYSTEM_CLOCK" && SYSCLK_TYPE != "NO_BUFFER") begin : clk_ref_noibuf
      BUFG u_bufg_clk_ref
        (
         .O (clk_ref_bufg),
         .I (clk_ref_i)
         );
    end
  endgenerate

  assign clk_ref = clk_ref_bufg;

  // Functional reset condition
  assign rst_tmp_idelay = sys_rst_act_hi | (~pll_locked);

  // DFT Clock Mux: Select scan_clk in scan_mode, otherwise functional clock
  assign clk_ff = scan_mode ? scan_clk : clk_ref_bufg;

  // DFT Reset Mux: Select scan_reset in scan_mode, otherwise functional reset condition
  // Making the reset synchronous for DFT
  assign reset_ff = scan_mode ? scan_reset : rst_tmp_idelay;

  // Synchronous Reset Flip-Flop with DFT Muxing
  always @(posedge clk_ff) begin
    if (reset_ff) // Synchronous reset active (functional or scan)
      rst_ref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}};
    else // Normal clocked operation (functional data or scan shift)
      rst_ref_sync_r <= #TCQ rst_ref_sync_r << 1;
  end

  assign rst_ref  = rst_ref_sync_r[RST_SYNC_NUM-1];

  // IDELAYCTRL instantiation - Note: Its clock/reset might also need DFT handling
  // depending on test strategy, but this fix focuses on the FF clock per CLKNPI.
  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy),
     .REFCLK (clk_ref_bufg), // Using functional clock - might need mux if IDELAYCTRL tested via scan
     .RST    (rst_ref)      // Reset comes from the DFT-modified FF
     );

endmodule