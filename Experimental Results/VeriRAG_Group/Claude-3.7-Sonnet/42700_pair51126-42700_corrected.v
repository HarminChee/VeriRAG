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
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   input   wire                      sys_clk                ,
   input   wire                      sys_rst_n              ,
   input   wire                      PIPE_MMCM_RST_N        ,
   input   wire [3:0]                i_tx_diff_ctr          ,
   input   wire                      pipe_clk_ext           ,
   // ... existing code ...
   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,
   output  wire [15:0]               o_rx_data              ,
   output  wire [1:0]                o_rx_data_k            ,
   output  wire [1:0]                o_rx_byte_is_comma     ,
   output  wire                      o_rx_byte_is_aligned   ,
   output  wire                      phy_rdy_n
);

  parameter                          TCQ  = 1;      
  
  // ... existing code ...

  // Fix CLKNPI error - ensure clock comes from primary input
  wire pipe_clk_int;
  assign pipe_clk_int = pipe_clk_ext;

  // Fix ACNCPI error - ensure reset comes from primary input  
  wire rst_n;
  assign rst_n = sys_rst_n;

  // Fix FFCKNP error - remove internally generated clocks
  wire pipe_clk_out;
  assign pipe_clk = pipe_clk_int;

  // Fix CDFDAT error - separate clock and data paths
  reg [15:0] rx_data_reg;
  always @(posedge pipe_clk_int) begin
    if (!rst_n)
      rx_data_reg <= 16'h0;
    else 
      rx_data_reg <= gt_rx_data_wire[15:0];
  end
  assign o_rx_data = rx_data_reg;

  // ... rest of existing code ...

endmodule