`timescale 1ns/1ns
`timescale 1ns/1ns
module PCIeGen2x8If128_gt_top #
(
   // ... existing code ...
)
(
   input   wire [5:0]                pl_ltssm_state         ,
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   input   wire                      test_i                 ,
   input   wire                      scan_clk               ,
   input   wire                      clock_locked           ,
   input   wire                      pipe_clk_int           ,
   input   wire                      all_phystatus_rst      ,
   output  wire                      pipe_clk               ,
   output  reg                       phy_rdy_n_int          ,
   // ... existing code ...
);

   // ... existing code ...

   wire dft_pipe_clk_int;
   reg  reg_clock_locked;

   assign dft_pipe_clk_int = test_i ? scan_clk : pipe_clk_int;

   reg [5:0] pl_ltssm_state_q;
   always @(posedge dft_pipe_clk_int or negedge clock_locked) begin
     if (!clock_locked)
       pl_ltssm_state_q <= 6'b0;
     else  
       pl_ltssm_state_q <= pl_ltssm_state;
   end

   assign pipe_clk = pipe_clk_int;

   // ... existing code ...

   always @(posedge dft_pipe_clk_int or negedge clock_locked) begin
     if (!clock_locked)
       reg_clock_locked <= 1'b0;
     else
       reg_clock_locked <= 1'b1;
   end

   always @(posedge dft_pipe_clk_int or negedge reg_clock_locked) begin
     if (!reg_clock_locked)
       phy_rdy_n_int <= 1'b0;
     else
       phy_rdy_n_int <= all_phystatus_rst;
   end

   // ... existing code ...

endmodule