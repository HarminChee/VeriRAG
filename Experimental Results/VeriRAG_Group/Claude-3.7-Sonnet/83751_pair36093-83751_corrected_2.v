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
   input   wire                                  test_i                 ,
   // ... existing code ...
);

// ... existing code ...

wire dft_pipe_clk_int;
wire dft_clock_locked;
wire dft_sys_clk;
wire dft_sys_rst_n;

assign dft_pipe_clk_int = test_i ? sys_clk : pipe_clk_int;
assign dft_clock_locked = test_i ? sys_rst_n : clock_locked;
assign dft_sys_clk = test_i ? sys_clk : sys_clk;
assign dft_sys_rst_n = test_i ? sys_rst_n : sys_rst_n;

always @(posedge dft_sys_clk or negedge dft_sys_rst_n) begin
  if (!dft_sys_rst_n)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

assign pipe_clk = dft_pipe_clk_int;

// ... existing code ...

always @(posedge dft_sys_clk or negedge dft_sys_rst_n) begin
  if (!dft_sys_rst_n)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ 1'b1;
end

always @(posedge dft_sys_clk or negedge dft_sys_rst_n) begin
  if (!dft_sys_rst_n)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

// ... existing code ...

endmodule