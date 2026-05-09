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
   output  wire                                  pipe_clk               ,
   output  wire                                  user_clk               ,
   output  wire                                  user_clk2              ,
   // ... existing code ...
);

// ... existing code ...

// Remove internally generated clock
assign pipe_clk = sys_clk;

// ... existing code ...

// Modify clock domain logic to use primary input clock
always @(posedge sys_clk or negedge clock_locked) begin
  if (!clock_locked)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ 1'b1;
end

always @(posedge sys_clk) begin
  if (!reg_clock_locked)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

// ... existing code ...

// Modify LTSSM state register to use primary input clock
always @(posedge sys_clk or negedge clock_locked) begin
  if (!clock_locked)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

// ... existing code ...

endmodule