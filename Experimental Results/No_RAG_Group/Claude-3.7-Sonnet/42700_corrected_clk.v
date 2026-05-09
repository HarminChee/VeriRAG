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
   input   wire                      sys_clk,               // Primary clock input
   input   wire                      sys_rst_n,             // Primary reset input
   // ... existing code ...
   output  wire                      pipe_clk,              // Clock output
   output  wire                      user_clk,              // User clock output
   output  wire                      user_clk2,             // User clock 2 output
   // ... existing code ...
);

// ... existing code ...

// Remove internally generated clock
wire pipe_clk_int;
assign pipe_clk_int = sys_clk; // Use primary input clock directly

// ... existing code ...

// Clock domain crossing synchronizer for ltssm state
reg [5:0] pl_ltssm_state_q;
always @(posedge sys_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else 
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

// ... existing code ...

// Clock domain crossing synchronizer for clock_locked
reg reg_clock_locked;
always @(posedge sys_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ clock_locked;
end

// Clock domain crossing synchronizer for phy_rdy_n
reg phy_rdy_n_int;
always @(posedge sys_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
    phy_rdy_n_int <= #TCQ 1'b1;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

// ... rest of existing code ...

endmodule