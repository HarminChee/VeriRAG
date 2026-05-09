`timescale 1ps/1ps
module pcie3_7x_0_pcie_3_0_7vx # (
  // ... existing code ...
) (
  // ... existing code ...
  input                                      sys_clk,     // Primary input clock
  input                                      sys_rst_n,   // Primary reset input
  // ... existing code ...
);

  // Internal clock signals
  wire                                      core_clk;
  wire                                      user_clk_int;
  wire                                      pipe_clk;
  wire                                      mmcm_lock;
  wire                                      phy_rdy;
  wire                                      pipe_mmcm_rst_n;
  wire                                      rec_clk;

  // Clock generation
  BUFG user_clk_buf (
    .I(user_clk_int),
    .O(user_clk)
  );

  MMCM_ADV #(
    .CLKFBOUT_MULT_F(8.0),
    .CLKIN1_PERIOD(10.0),
    .CLKOUT0_DIVIDE_F(8.0),
    .CLKOUT1_DIVIDE(8),
    .CLKOUT2_DIVIDE(8)
  ) mmcm_adv_inst (
    .CLKIN1(sys_clk),
    .CLKFBIN(mmcm_fb),
    .RST(~sys_rst_n),
    .CLKOUT0(core_clk),
    .CLKOUT1(pipe_clk),
    .CLKOUT2(user_clk_int),
    .CLKFBOUT(mmcm_fb),
    .LOCKED(mmcm_lock)
  );

  // Rest of original code...
  // ... existing code ...

endmodule