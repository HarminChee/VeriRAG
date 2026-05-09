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
   input   wire                      rst_n                  ,
   output  wire                      pipe_clk               ,
   output  reg                       phy_rdy_n_int          ,
   // ... existing code ...
);

   // ... existing code ...

   wire dft_pipe_clk_int;
   wire dft_rst_n;

   assign dft_pipe_clk_int = test_i ? scan_clk : pipe_clk_int;
   assign dft_rst_n = test_i ? scan_clk : rst_n;

   reg [5:0] pl_ltssm_state_q;
   always @(posedge dft_pipe_clk_int or negedge dft_rst_n) begin
     if (!dft_rst_n)
       pl_ltssm_state_q <= 6'b0;
     else  
       pl_ltssm_state_q <= pl_ltssm_state;
   end

   assign pipe_clk = pipe_clk_int;

   // ... existing code ...

   always @(posedge dft_pipe_clk_int or negedge dft_rst_n) begin
     if (!dft_rst_n)
       phy_rdy_n_int <= 1'b0;
     else
       phy_rdy_n_int <= all_phystatus_rst;
   end

   // ... existing code ...

endmodule