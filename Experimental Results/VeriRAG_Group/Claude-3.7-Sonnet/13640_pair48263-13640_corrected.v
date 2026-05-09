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
   input  clk_ref_p,
   input  clk_ref_n,
   input  clk_ref,
   input  sys_rst,
   input  scan_clk,
   input  test_i,
   output iodelay_ctrl_rdy
   );
  localparam RST_SYNC_NUM = 15;
  wire                   clk_ref_bufg;  
  wire                   clk_ref_ibufg;
  wire                   rst_ref;
  reg [RST_SYNC_NUM-1:0] rst_ref_sync_r ;  
  wire                   rst_tmp_idelay;
  wire                   sys_rst_act_hi;
  wire                   dft_clk_ref;
  assign  sys_rst_act_hi = RST_ACT_LOW ? ~sys_rst: sys_rst;
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
  assign rst_tmp_idelay = sys_rst_act_hi;
  assign dft_clk_ref = test_i ? scan_clk : clk_ref_bufg;
  always @(posedge dft_clk_ref or posedge rst_tmp_idelay)
    if (rst_tmp_idelay)
      rst_ref_sync_r <= #TCQ {RST_SYNC_NUM{1'b1}};
    else
      rst_ref_sync_r <= #TCQ rst_ref_sync_r << 1;
  assign rst_ref  = rst_ref_sync_r[RST_SYNC_NUM-1];
  (* IODELAY_GROUP = IODELAY_GRP *) IDELAYCTRL u_idelayctrl
    (
     .RDY    (iodelay_ctrl_rdy),
     .REFCLK (clk_ref_bufg),
     .RST    (rst_ref)
     );
endmodule