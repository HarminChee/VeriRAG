`timescale 1ns/1ns
module pcie_clocking_v6 # (
  parameter IS_ENDPOINT = "TRUE",
  parameter CAP_LINK_WIDTH = 8,
  parameter CAP_LINK_SPEED = 4'h1,
  parameter REF_CLK_FREQ = 0,
  parameter USER_CLK_FREQ = 3
)
(
  input  wire        sys_clk,
  input  wire        gt_pll_lock,
  input  wire        sel_lnk_rate,
  input  wire [1:0]  sel_lnk_width,
  output wire        sys_clk_bufg,
  output wire        pipe_clk,
  output wire        user_clk,
  output wire        block_clk,
  output wire        drp_clk,
  output wire        clock_locked
);
  parameter TCQ = 1;
  wire               mmcm_locked;
  wire               mmcm_clkfbin;
  wire               mmcm_clkfbout;
  wire               mmcm_reset;
  wire               clk_500;
  wire               clk_250;
  wire               clk_125;
  wire               user_clk_prebuf;
  wire               sel_lnk_rate_d;
  reg  [1:0]         reg_clock_locked = 2'b11;
  localparam         mmcm_clockin_period  = (REF_CLK_FREQ == 0) ? 10.0 :
                                            (REF_CLK_FREQ == 1) ? 8.0 :
                                            (REF_CLK_FREQ == 2) ? 4.0 : 0;
  localparam         mmcm_clockfb_mult = (REF_CLK_FREQ == 0) ? 10.0 :
                                         (REF_CLK_FREQ == 1) ? 8.0 :
                                         (REF_CLK_FREQ == 2) ? 8.0 : 0;
  localparam         mmcm_divclk_divide = (REF_CLK_FREQ == 0) ? 1 :
                                          (REF_CLK_FREQ == 1) ? 1 :
                                          (REF_CLK_FREQ == 2) ? 2 : 0;
  localparam         mmcm_clock0_div = 4.0;
  localparam         mmcm_clock1_div = 8.0;
  localparam         mmcm_clock2_div = ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 0)) ?  32.0 :
                                       ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 1)) ?  16.0 :
                                       ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 1)) ?  16.0 :
                                       ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 1)) ?  16.0 : 2.0;
  localparam         mmcm_clock3_div = 2.0;
  assign             mmcm_reset = 1'b0;
  assign             block_clk = clk_500;

  generate
    if (CAP_LINK_SPEED == 4'h1) begin : GEN1_LINK
      BUFG pipe_clk_bufg (.O(pipe_clk), .I(clk_125));
    end else if (CAP_LINK_SPEED == 4'h2) begin : GEN2_LINK
      SRL16E #(.INIT(16'h0)) sel_lnk_rate_delay (.Q(sel_lnk_rate_d),
             .D(sel_lnk_rate), .CLK(pipe_clk), .CE(clock_locked), .A3(1'b1), .A2(1'b1), .A1(1'b1), .A0(1'b1));
      BUFGMUX pipe_clk_bufgmux (.O(pipe_clk), .I0(clk_125), .I1(clk_250), .S(sel_lnk_rate_d));
    end
  endgenerate

  generate
    if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 0)) begin : x1_GEN1_31_25
      BUFG user_clk_bufg (.O(user_clk), .I(user_clk_prebuf));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 1)) begin : x1_GEN1_62_50
      BUFG user_clk_bufg (.O(user_clk), .I(user_clk_prebuf));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 2)) begin : x1_GEN1_125_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 3)) begin : x1_GEN1_250_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 1)) begin : x1_GEN2_62_50
      BUFG user_clk_bufg (.O(user_clk), .I(user_clk_prebuf));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 2)) begin : x1_GEN2_125_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h01) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 3)) begin : x1_GEN2_250_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 1)) begin : x2_GEN1_62_50
      BUFG user_clk_bufg (.O(user_clk), .I(user_clk_prebuf));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 2)) begin : x2_GEN1_125_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 3)) begin : x2_GEN1_250_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 2)) begin : x2_GEN2_125_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h02) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 3)) begin : x2_GEN2_250_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h04) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 2)) begin : x4_GEN1_125_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_125));
    end else if ((CAP_LINK_WIDTH == 6'h04) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 3)) begin : x4_GEN1_250_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h04) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 3)) begin : x4_GEN2_250_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h08) && (CAP_LINK_SPEED == 4'h1) && (USER_CLK_FREQ == 3)) begin : x8_GEN1_250_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_250));
    end else if ((CAP_LINK_WIDTH == 6'h08) && (CAP_LINK_SPEED == 4'h2) && (USER_CLK_FREQ == 4)) begin : x8_GEN2_250_00
      BUFG user_clk_bufg (.O(user_clk), .I(clk_250));
    end
  endgenerate

  BUFG drp_clk_bufg_i  (.O(drp_clk), .I(clk_125));
  BUFG clkfbin_bufg_i  (.O(mmcm_clkfbin), .I(mmcm_clkfbout));
  BUFG sys_clk_bufg_i  (.O(sys_clk_bufg), .I(sys_clk));

  MMCME2_ADV # (
    .CLKFBOUT_MULT_F (mmcm_clockfb_mult),
    .DIVCLK_DIVIDE (mmcm_divclk_divide),
    .CLKFBOUT_PHASE(0.0),
    .CLKIN1_PERIOD (mmcm_clockin_period),
    .CLKOUT0_DIVIDE_F (mmcm_clock0_div),
    .CLKOUT0_PHASE (0.0),
    .CLKOUT1_DIVIDE (mmcm_clock1_div),
    .CLKOUT1_PHASE (0.0),
    .CLKOUT2_DIVIDE (mmcm_clock2_div),
    .CLKOUT2_PHASE (0.0),
    .CLKOUT3_DIVIDE (mmcm_clock3_div),
    .CLKOUT3_PHASE (0.0)
  ) mmcm_adv_i (
    .CLKFBOUT     (mmcm_clkfbout),
    .CLKOUT0      (clk_250),
    .CLKOUT1      (clk_125),
    .CLKOUT2      (user_clk_prebuf),
    .CLKOUT3      (clk_500),
    .CLKOUT4      (),
    .CLKOUT5      (),
    .CLKFBOUTB    (),
    .CLKFBIN      (mmcm_clkfbin),
    .CLKIN1       (sys_clk),
    .CLKIN2       (1'b0),
    .CLKINSEL     (1'b1),
    .DADDR        (7'b0),
    .DCLK         (1'b0),
    .DEN          (1'b0),
    .DI           (16'b0),
    .DWE          (1'b0),
    .PWRDWN       (1'b0),
    .RST          (mmcm_reset),
    .LOCKED       (mmcm_locked)
  );

  always @ (posedge pipe_clk or negedge gt_pll_lock) begin
    if (!gt_pll_lock)
      reg_clock_locked[1:0] <= #TCQ 2'b11;
    else
      reg_clock_locked[1:0] <= #TCQ {reg_clock_locked[0], 1'b0};
  end

  assign  clock_locked = !reg_clock_locked[1] & mmcm_locked;
endmodule