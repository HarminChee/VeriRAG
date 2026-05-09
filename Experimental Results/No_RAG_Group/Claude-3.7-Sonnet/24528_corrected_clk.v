Here is the modified Verilog code addressing the CLKNPI issue:


`timescale 1ns/1ps
module infrastructure #
  (
   parameter C_INCLK_PERIOD    =  5000,
   parameter C_RST_ACT_LOW      = 1,
   parameter C_INPUT_CLK_TYPE   = "DIFFERENTIAL",
   parameter C_CLKOUT0_DIVIDE   = 1,
   parameter C_CLKOUT1_DIVIDE   = 1,
   parameter C_CLKOUT2_DIVIDE   = 16,
   parameter C_CLKOUT3_DIVIDE   = 8,
   parameter C_CLKFBOUT_MULT    = 2,
   parameter C_DIVCLK_DIVIDE    = 1
   )
  (
   input  sys_clk_p,
   input  sys_clk_n,
   input  sys_clk,
   input  sys_rst_i,
   output clk0,
   output rst0,
   output async_rst,
   output sysclk_2x,
   output sysclk_2x_180,
   output mcb_drp_clk,
   output pll_ce_0,
   output pll_ce_90,
   output pll_lock
   );
  localparam RST_SYNC_NUM = 25;
  localparam CLK_PERIOD_NS = C_INCLK_PERIOD / 1000.0;
  localparam CLK_PERIOD_INT = C_INCLK_PERIOD/1000;
  wire                       clk_2x_0;
  wire                       clk_2x_180;
  wire                       clk0_bufg;
  wire                       clk0_bufg_in;
  wire                       mcb_drp_clk_bufg_in;
  wire                       clkfbout_clkfbin;
  wire                       locked;
  reg [RST_SYNC_NUM-1:0]     rst0_sync_r    ;
  wire                       rst_tmp;
  reg                        powerup_pll_locked;
  reg 			     syn_clk0_powerup_pll_locked;
  wire                       sys_rst;
  wire                       bufpll_mcb_locked;
  wire                       sys_clk_ibufg;
  assign sys_rst = C_RST_ACT_LOW ? ~sys_rst_i: sys_rst_i;
  assign clk0        = clk0_bufg;
  assign pll_lock    = bufpll_mcb_locked;
  generate
    if (C_INPUT_CLK_TYPE == "DIFFERENTIAL") begin: diff_input_clk
      IBUFGDS #
        (
         .DIFF_TERM    ("TRUE")
         )
        u_ibufg_sys_clk
          (
           .I  (sys_clk_p),
           .IB (sys_clk_n),
           .O  (sys_clk_ibufg)
           );
    end else if (C_INPUT_CLK_TYPE == "SINGLE_ENDED") begin: se_input_clk
    assign sys_clk_ibufg = sys_clk;
   end
  endgenerate
    PLL_ADV #
        (
         .BANDWIDTH          ("OPTIMIZED"),
         .CLKIN1_PERIOD      (CLK_PERIOD_NS),
         .CLKIN2_PERIOD      (CLK_PERIOD_NS),
         .CLKOUT0_DIVIDE     (C_CLKOUT0_DIVIDE),
         .CLKOUT1_DIVIDE     (C_CLKOUT1_DIVIDE),
         .CLKOUT2_DIVIDE     (C_CLKOUT2_DIVIDE),
         .CLKOUT3_DIVIDE     (C_CLKOUT3_DIVIDE),
         .CLKOUT4_DIVIDE     (1),
         .CLKOUT5_DIVIDE     (1),
         .CLKOUT0_PHASE      (0.000),
         .CLKOUT1_PHASE      (180.000),
         .CLKOUT2_PHASE      (0.000),
         .CLKOUT3_PHASE      (0.000),
         .CLKOUT4_PHASE      (0.000),
         .CLKOUT5_PHASE      (0.000),
         .CLKOUT0_DUTY_CYCLE (0.500),
         .CLKOUT1_DUTY_CYCLE (0.500),
         .CLKOUT2_DUTY_CYCLE (0.500),
         .CLKOUT3_DUTY_CYCLE (0.500),
         .CLKOUT4_DUTY_CYCLE (0.500),
         .CLKOUT5_DUTY_CYCLE (0.500),
         .SIM_DEVICE         ("SPARTAN6"),
         .COMPENSATION       ("INTERNAL"),
         .DIVCLK_DIVIDE      (C_DIVCLK_DIVIDE),
         .CLKFBOUT_MULT      (C_CLKFBOUT_MULT),
         .CLKFBOUT_PHASE     (0.0),
         .REF_JITTER         (0.005000)
         )
        u_pll_adv
          (
           .CLKFBIN     (clkfbout_clkfbin),
           .CLKINSEL    (1'b1),
           .CLKIN1      (sys_clk_ibufg),
           .CLKIN2      (1'b0),
           .DADDR       (5'b0),
           .DCLK        (1'b0),
           .DEN         (1'b0),
           .DI          (16'b0),
           .DWE         (1'b0),
           .REL         (1'b0),
           .RST         (sys_rst),
           .CLKFBDCM    (),
           .CLKFBOUT    (clkfbout_clkfbin),
           .CLKOUTDCM0  (),
           .CLKOUTDCM1  (),
           .CLKOUTDCM2  (),
           .CLKOUTDCM3  (),
           .CLKOUTDCM4  (),
           .CLKOUTDCM5  (),
           .CLKOUT0     (clk_2x_0),
           .CLKOUT1     (clk_2x_180),
           .CLKOUT2     (clk0_bufg_in),
           .CLKOUT3     (mcb_drp_clk_bufg_in),
           .CLKOUT4     (),
           .CLKOUT5     (),
           .DO          (),
           .DRDY        (),
           .LOCKED      (locked)
           );
   BUFG U_BUFG_CLK0
    (
     .O (clk0_bufg),
     .I (clk0_bufg_in)
     );
   BUFG U_BUFG_CLK1
    (
     .O (mcb_drp_clk),
     .I (mcb_drp_clk_bufg_in)
     );
  always @(posedge sys_clk_ibufg, posedge sys_rst)
      if(sys_rst)
         powerup_pll_locked <= 1'b0;
      else if (bufpll_mcb_locked)
         powerup_pll_locked <= 1'b1;
  always @(posedge sys_clk_ibufg, posedge sys_rst)
      if(sys_rst)
         syn_clk0_powerup_pll_locked <= 1'b0;
      else if (bufpll_mcb_locked)
         syn_clk0_powerup_pll_locked <= 1'b1;
  assign async_rst = sys_rst | ~powerup_pll_locked;
  assign rst_tmp = sys_rst | ~syn_clk0_powerup_pll_locked;
  always @(posedge sys_clk_ibufg or posedge rst_tmp)
    if (rst_tmp)
      rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
      rst0_sync_r <= rst0_sync_r << 1;
  assign rst0    = rst0_sync_r[RST_SYNC_NUM-1];
BUFPLL_MCB BUFPLL_MCB1 
( .IOCLK0         (sysclk_2x),  
  .IOCLK1         (sysclk_2x_180),       
  .LOCKED         (locked),
  .GCLK           (sys_clk_ibufg),
  .SERDESSTROBE0  (pll_ce_0), 
  .SERDESSTROBE1  (pll_ce_90), 
  .PLLIN0         (clk_2x_0),  
  .PLLIN1         (clk_2x_180),
  .LOCK           (bufpll_mcb_locked) 
  );
endmodule