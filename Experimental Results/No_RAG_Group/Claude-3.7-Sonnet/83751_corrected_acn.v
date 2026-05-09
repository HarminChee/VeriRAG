`timescale 1ns/1ns
module PCIeGen2x8If128_gt_top #
(
   // ... existing code ...
)
(
   // ... existing code ...
   input   wire                                  sys_clk                ,
   input   wire                                  sys_rst_n              ,
   input   wire                                  PIPE_MMCM_RST_N        ,
   input   wire                                  pipe_clk               , // Changed from output to input
   input   wire                                  user_clk               , // Changed from output to input  
   input   wire                                  user_clk2              , // Changed from output to input
   // ... existing code ...
);

// ... existing code ...

// Modified reset logic to use primary input
reg [5:0] pl_ltssm_state_q;
always @(posedge pipe_clk or posedge sys_rst_n) begin // Changed to use sys_rst_n
  if (sys_rst_n)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

// Modified clock locked logic to use primary input
reg reg_clock_locked;
always @(posedge pipe_clk or posedge sys_rst_n) begin // Changed to use sys_rst_n
  if (sys_rst_n)
    reg_clock_locked <= #TCQ 1'b0;
  else 
    reg_clock_locked <= #TCQ 1'b1;
end

// Modified phy_rdy logic to use primary input
reg phy_rdy_n_int;
always @(posedge pipe_clk or posedge sys_rst_n) begin // Changed to use sys_rst_n
  if (sys_rst_n)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

// ... existing code ...

endmodule