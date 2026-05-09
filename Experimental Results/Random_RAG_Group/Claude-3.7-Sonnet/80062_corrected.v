`timescale 1ns/1ns
`timescale 1ns/1ns
module PCIeGen2x8If128_gt_top #
(
   // ... existing code ...
)
(
   input   wire                      test_i,
   input   wire [5:0]                pl_ltssm_state         ,
   // ... existing code ...
);

// ... existing code ...

wire pipe_clk_int;
reg  phy_rdy_n_int;
reg  reg_clock_locked;
wire all_phystatus_rst;
reg [5:0] pl_ltssm_state_q;
wire pipe_clk_int_dft;

assign pipe_clk_int_dft = test_i ? sys_clk : pipe_clk_int;

always @(posedge pipe_clk_int_dft or negedge sys_rst_n) begin
  if (!sys_rst_n)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

assign pipe_clk = pipe_clk_int_dft;

// ... existing code ...

always @(posedge pipe_clk_int_dft or negedge sys_rst_n) begin
  if (!sys_rst_n)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ 1'b1;
end

always @(posedge pipe_clk_int_dft or negedge sys_rst_n) begin
  if (!sys_rst_n)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

// ... existing code ...

endmodule