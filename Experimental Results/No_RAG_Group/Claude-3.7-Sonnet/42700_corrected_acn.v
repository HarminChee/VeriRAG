`timescale 1ns/1ns
module pcie_7x_v1_11_0_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8, 
   parameter               REF_CLK_FREQ = 0,            
   parameter               USER_CLK2_DIV2 = "FALSE",    
   parameter  integer      USER_CLK_FREQ = 3,           
   parameter               PL_FAST_TRAIN = "FALSE",     
   parameter               PCIE_EXT_CLK = "FALSE",      
   parameter               PCIE_USE_MODE = "1.0",       
   parameter               PCIE_GT_DEVICE = "GTX",      
   parameter               PCIE_PLL_SEL   = "CPLL",     
   parameter               PCIE_ASYNC_EN  = "FALSE",    
   parameter               PCIE_TXBUF_EN  = "FALSE",    
   parameter               PCIE_CHAN_BOND = 0
)
(
   // ... existing code ...
   input   wire                      sys_clk,
   input   wire                      sys_rst_n,
   input   wire                      rst_n,  // Added primary input reset
   // ... rest of port declarations ...
)

// ... existing code and parameters ...

// Modified reset logic to use primary input reset
always @(posedge pipe_clk_int or negedge rst_n) begin
  if (!rst_n)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

// ... rest of existing code ...

// Modified reset logic for clock_locked register
always @(posedge pipe_clk_int or negedge rst_n) begin
  if (!rst_n)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ 1'b1;
end

// Modified reset logic for phy_rdy_n_int
always @(posedge pipe_clk_int or negedge rst_n) begin
  if (!rst_n)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

// ... rest of existing code ...

endmodule