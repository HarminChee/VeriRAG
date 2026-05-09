`timescale 1ps/1ps
module mig_7series_v1_9_iodelay_ctrl #
  (
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
   input  pll_locked
   );

  localparam RST_SYNC_NUM = 15;
  wire                   clk_ref_bufg;
  wire                   clk_ref_ibufg;
  (* keep = "true", max_fanout = 10 *) reg [RST_SYNC_NUM-1:0] rst_ref_sync_r;
  wire                   sys_rst_act_hi;

  generate
    if (SYS_RST_PORT == "TRUE") begin
      IBUF u_sys_rst_ibuf
        (
         .I (sys_rst),
         .O (sys_rst_o)
        );
    end
    else begin
      assign sys_rst_o = sys_rst;
    end
  endgenerate

  assign sys_rst_act_hi = RST_ACT_LOW ? ~sys_rst_o : sys_rst_o;

  generate
    if (REFCLK_TYPE == "DIFFERENTIAL") begin : diff_clk_ref
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
    end
    else if (REFCLK_TYPE == "SINGLE_ENDED") begin : se_clk_ref
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
    end
    else if ((REFCLK_TYPE == "NO_BUFFER") ||
             (REFCLK_TYPE == "USE_SYSTEM_CLOCK" && SYSCLK_TYPE == "NO_BUFFER")) begin : clk_ref_noibuf_nobuf
      assign clk_ref_bufg = clk_ref_i;
    end
    else if (REFCLK_TYPE == "USE_SYSTEM_CLOCK" && SYSCLK_TYPE != "NO_BUFFER") begin : clk_ref_noibuf
      BUFG u_bufg_clk_ref
        (
         .O (clk_ref_bufg),
         .I (clk_ref_i)
        );
    end
  endgenerate

  assign clk_ref = clk_ref_bufg;
  assign rst_tmp_idelay = sys_rst_act_hi | (~pll_locked);

  always @(posedge clk_ref_bufg or posedge rst_tmp_idelay)
    if (rst_tmp_idelay)
      rst_ref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}};
    else
      rst_ref_sync_r <= #TCQ rst_ref_sync_r << 1;

  assign rst_ref = rst_ref_sync_r[RST_SYNC_NUM-1];

  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy),
     .REFCLK (clk_ref_bufg),
     .RST    (rst_ref)
    );

endmodule