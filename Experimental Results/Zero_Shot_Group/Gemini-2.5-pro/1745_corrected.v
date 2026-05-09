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
   // Reference Clock Interface
   input  clk_ref_p,
   input  clk_ref_n,
   input  clk_ref_i,
   output clk_ref,

   // System Reset Interface
   input  sys_rst,
   output sys_rst_o,

   // IDELAYCTRL Interface
   output iodelay_ctrl_rdy,
   output rst_tmp_idelay,
   output rst_ref,

   // PLL Interface
   input  pll_locked
   );

  localparam RST_SYNC_NUM = 15; // Number of reset synchronization stages

  wire                   clk_ref_bufg;
  wire                   clk_ref_ibufg;
  // wire                   rst_ref; // Redundant declaration, output port implies wire
  (* keep = "true", max_fanout = 10 *) reg [RST_SYNC_NUM-1:0] rst_ref_sync_r ;
  wire                   sys_rst_act_hi;

  // Handle System Reset Input Buffering
  generate
    if (SYS_RST_PORT == "TRUE") begin : gen_sys_rst_ibuf
      IBUF u_sys_rst_ibuf
        (
         .I (sys_rst),
         .O (sys_rst_o)
         );
    end else begin : gen_sys_rst_assign
      assign sys_rst_o = sys_rst;
    end
  endgenerate

  // Determine active-high reset based on parameter
  assign  sys_rst_act_hi = (RST_ACT_LOW == 1) ? ~sys_rst_o: sys_rst_o;

  // Handle Reference Clock Input Buffering
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
      assign clk_ref_ibufg = clk_ref_i; // Assign directly if no IBUF needed
      assign clk_ref_bufg = clk_ref_ibufg; // Assign directly if no BUFG needed
    end else if (REFCLK_TYPE == "USE_SYSTEM_CLOCK" && SYSCLK_TYPE != "NO_BUFFER") begin : clk_ref_noibuf
      assign clk_ref_ibufg = clk_ref_i; // Assign directly if no IBUF needed
      BUFG u_bufg_clk_ref
        (
         .O (clk_ref_bufg),
         .I (clk_ref_ibufg)
         );
    end
  endgenerate

  // Assign buffered clock to output
  assign clk_ref = clk_ref_bufg;

  // Generate temporary reset signal (active high)
  assign rst_tmp_idelay = sys_rst_act_hi | (~pll_locked);

  // Reset Synchronizer for IDELAYCTRL
  // Synchronizes the de-assertion of the reset signal to the reference clock domain
  always @(posedge clk_ref_bufg or posedge rst_tmp_idelay) begin
    if (rst_tmp_idelay) begin
      rst_ref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}}; // Assert reset synchronously
    end else begin
      // Shift in '0's to de-assert reset after RST_SYNC_NUM cycles
      rst_ref_sync_r <= #TCQ {rst_ref_sync_r[RST_SYNC_NUM-2:0], 1'b0};
    end
  end

  // Assign the synchronized reset signal to the output port
  assign rst_ref  = rst_ref_sync_r[RST_SYNC_NUM-1];

  // IDELAYCTRL Instance
  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy), // Output indicating IDELAYCTRL is ready
     .REFCLK (clk_ref_bufg),     // Reference clock input (must be 200MHz or 300MHz)
     .RST    (rst_ref)           // Reset input, synchronized
     );

endmodule