`timescale 1ps / 1ps
module pcie3_7x_0_gt_top #
(
  // ... existing code ...
) (
  // ... existing code ...
  input   wire                                       pipe_clk,               
  input   wire                                       sys_rst_n,              
  output  wire                                       rec_clk,                
  output  wire                                       pipe_pclk,              
  output  wire                                       core_clk,
  output  wire                                       user_clk,
  output  wire                                       phy_rdy,
  output  wire                                       mmcm_lock,
  input                                              pipe_mmcm_rst_n,
  // ... existing code ...
);

// ... existing code ...

// Clock generation from primary input
wire pipe_clk_int;
BUFG pipe_clk_bufg (
  .I(pipe_clk),
  .O(pipe_clk_int)
);

// Use pipe_clk_int for all internal clocking
wire user_clk_int;
BUFG user_clk_bufg (
  .I(pipe_clk_int), 
  .O(user_clk_int)
);

// Replace internally generated clocks with primary input derived clocks
assign pipe_pclk = pipe_clk_int;
assign core_clk = pipe_clk_int;
assign user_clk = user_clk_int;
assign rec_clk = pipe_clk_int;

// ... rest of existing code ...

endmodule