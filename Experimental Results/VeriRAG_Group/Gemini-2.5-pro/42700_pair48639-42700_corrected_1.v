`timescale 1ns/1ns
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
   input   wire                      test_i,               // DFT Test Mode Input
   input   wire [5:0]                pl_ltssm_state         ,
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   input                                      PIPE_PCLK_IN,
   input                                      PIPE_RXUSRCLK_IN,
   input [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,
   input                                      PIPE_DCLK_IN,
   input                                      PIPE_USERCLK1_IN,
   input                                      PIPE_USERCLK2_IN,
   input                                      PIPE_OOBCLK_IN,
   input                                      PIPE_MMCM_LOCK_IN,
   output                                     PIPE_TXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,
   output                                     PIPE_GEN3_OUT,
   output  wire [ 1:0]               pipe_rx0_char_is_k     ,
   output  wire [15:0]               pipe_rx0_data          ,
   output  wire                      pipe_rx0_valid         ,
   output  wire                      pipe_rx0_chanisaligned ,
   output  wire [ 2:0]               pipe_rx0_status        ,
   output  wire                      pipe_rx0_phy_status    ,
   output  wire                      pipe_rx0_elec_idle     ,
   input   wire                      pipe_rx0_polarity      ,
   input   wire                      pipe_tx0_compliance    ,
   input   wire [ 1:0]               pipe_tx0_char_is_k     ,
   input   wire [15:0]               pipe_tx0_data          ,
   input   wire                      pipe_tx0_elec_idle     ,
   input   wire [ 1:0]               pipe_tx0_powerdown     ,
   output  wire [ 1:0]               pipe_rx1_char_is_k     ,
   output  wire [15:0]               pipe_rx1_data          ,
   output  wire                      pipe_rx1_valid         ,
   output  wire                      pipe_rx1_chanisaligned ,
   output  wire [ 2:0]               pipe_rx1_status        ,
   output  wire                      pipe_rx1_phy_status    ,
   output  wire                      pipe_rx1_elec_idle     ,
   input   wire                      pipe_rx1_polarity      ,
   input   wire                      pipe_tx1_compliance    ,
   input   wire [ 1:0]               pipe_tx1_char_is_k     ,
   input   wire [15:0]               pipe_tx1_data          ,
   input   wire                      pipe_tx1_elec_idle     ,
   input   wire [ 1:0]               pipe_tx1_powerdown     ,
   output  wire [ 1:0]               pipe_rx2_char_is_k     ,
   output  wire [15:0]               pipe_rx2_data          ,
   output  wire                      pipe_rx2_valid         ,
   output  wire                      pipe_rx2_chanisaligned ,
   output  wire [ 2:0]               pipe_rx2_status        ,
   output  wire                      pipe_rx2_phy_status    ,
   output  wire                      pipe_rx2_elec_idle     ,
   input   wire                      pipe_rx2_polarity      ,
   input   wire                      pipe_tx2_compliance    ,
   input   wire [ 1:0]               pipe_tx2_char_is_k     ,
   input   wire [15:0]               pipe_tx2_data          ,
   input   wire                      pipe_tx2_elec_idle     ,
   input   wire [ 1:0]               pipe_tx2_powerdown     ,
   output  wire [ 1:0]               pipe_rx3_char_is_k     ,
   output  wire [15:0]               pipe_rx3_data          ,
   output  wire                      pipe_rx3_valid         ,
   output  wire                      pipe_rx3_chanisaligned ,
   output  wire [ 2:0]               pipe_rx3_status        ,
   output  wire                      pipe_rx3_phy_status    ,
   output  wire                      pipe_rx3_elec_idle     ,
   input   wire                      pipe_rx3_polarity      ,
   input   wire                      pipe_tx3_compliance    ,
   input   wire [ 1:0]               pipe_tx3_char_is_k     ,
   input   wire [15:0]               pipe_tx3_data          ,
   input   wire                      pipe_tx3_elec_idle     ,
   input   wire [ 1:0]               pipe_tx3_powerdown     ,
   output  wire [ 1:0]               pipe_rx4_char_is_k     ,
   output  wire [15:0]               pipe_rx4_data          ,
   output  wire                      pipe_rx4_valid         ,
   output  wire                      pipe_rx4_chanisaligned ,
   output  wire [ 2:0]               pipe_rx4_status        ,
   output  wire                      pipe_rx4_phy_status    ,
   output  wire                      pipe_rx4_elec_idle     ,
   input   wire                      pipe_rx4_polarity      ,
   input   wire                      pipe_tx4_compliance    ,
   input   wire [ 1:0]               pipe_tx4_char_is_k     ,
   input   wire [15:0]               pipe_tx4_data          ,
   input   wire                      pipe_tx4_elec_idle     ,
   input   wire [ 1:0]               pipe_tx4_powerdown     ,
   output  wire [ 1:0]               pipe_rx5_char_is_k     ,
   output  wire [15:0]               pipe_rx5_data          ,
   output  wire                      pipe_rx5_valid         ,
   output  wire                      pipe_rx5_chanisaligned ,
   output  wire [ 2:0]               pipe_rx5_status        ,
   output  wire                      pipe_rx5_phy_status    ,
   output  wire                      pipe_rx5_elec_idle     ,
   input   wire                      pipe_rx5_polarity      ,
   input   wire                      pipe_tx5_compliance    ,
   input   wire [ 1:0]               pipe_tx5_char_is_k     ,
   input   wire [15:0]               pipe_tx5_data          ,
   input   wire                      pipe_tx5_elec_idle     ,
   input   wire [ 1:0]               pipe_tx5_powerdown     ,
   output  wire [ 1:0]               pipe_rx6_char_is_k     ,
   output  wire [15:0]               pipe_rx6_data          ,
   output  wire                      pipe_rx6_valid         ,
   output  wire                      pipe_rx6_chanisaligned ,
   output  wire [ 2:0]               pipe_rx6_status        ,
   output  wire                      pipe_rx6_phy_status    ,
   output  wire                      pipe_rx6_elec_idle     ,
   input   wire                      pipe_rx6_polarity      ,
   input   wire                      pipe_tx6_compliance    ,
   input   wire [ 1:0]               pipe_tx6_char_is_k     ,
   input   wire [15:0]               pipe_tx6_data          ,
   input   wire                      pipe_tx6_elec_idle     ,
   input   wire [ 1:0]               pipe_tx6_powerdown     ,
   output  wire [ 1:0]               pipe_rx7_char_is_k     ,
   output  wire [15:0]               pipe_rx7_data          ,
   output  wire                      pipe_rx7_valid         ,
   output  wire                      pipe_rx7_chanisaligned ,
   output  wire [ 2:0]               pipe_rx7_status        ,
   output  wire                      pipe_rx7_phy_status    ,
   output  wire                      pipe_rx7_elec_idle     ,
   input   wire                      pipe_rx7_polarity      ,
   input   wire                      pipe_tx7_compliance    ,
   input   wire [ 1:0]               pipe_tx7_char_is_k     ,
   input   wire [15:0]               pipe_tx7_data          ,
   input   wire                      pipe_tx7_elec_idle     ,
   input   wire [ 1:0]               pipe_tx7_powerdown     ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,
   input   wire                      sys_clk                ,
   input   wire                      sys_rst_n              , // Active Low Reset
   input   wire                      PIPE_MMCM_RST_N        ,
   input        [3:0]                i_tx_diff_ctr          ,
   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,
   output       [15:0]               o_rx_data,
   output       [1:0]                o_rx_data_k,
   output       [1:0]                o_rx_byte_is_comma,
   output                            o_rx_byte_is_aligned,
   output  wire                      phy_rdy_n
);
  parameter                          TCQ  = 1;      
  localparam                         USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                                                        (USER_CLK_FREQ == 4) ? 3 :
                                                        (USER_CLK_FREQ == 3) ? 2 :
                                                         USER_CLK_FREQ;
  localparam                         PCIE_LPM_DFE    = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
  localparam                         PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;
  localparam                         PCIE_OOBCLK_MODE_ENABLE =  1;
  localparam              PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 3'b100 : 3'b010;
  wire [  7:0]                       gt_rx_phy_status_wire        ;
  wire [  7:0]                       gt_rxchanisaligned_wire      ;
  wire [ (4*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_rx_data_k_wire            ; // Adjusted width
  wire [ (32*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_rx_data_wire              ; // Adjusted width
  wire [  7:0]                       gt_rx_elec_idle_wire         ;
  wire [ (3*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_rx_status_wire            ; // Adjusted width
  wire [  7:0]                       gt_rx_valid_wire             ;
  wire [ (LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_rx_polarity               ; // Adjusted width
  wire [ (2*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_power_down                ; // Adjusted width
  wire [ (LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_tx_char_disp_mode         ; // Adjusted width
  wire [ (4*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_tx_data_k                 ; // Adjusted width
  wire [ (32*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_tx_data                   ; // Adjusted width
  wire                               gt_tx_detect_rx_loopback     ;
  wire [ (LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_tx_elec_idle              ; // Adjusted width
  wire [  7:0]                       gt_rx_elec_idle_reset        ;
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] plllkdet                     ;
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] phystatus_rst                ;
  wire                               clock_locked                 ; // Output from pipe_wrapper_i
  wire [  7:0]                       gt_rx_phy_status_wire_filter ;
  wire [ (4*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_rx_data_k_wire_filter     ; // Adjusted width
  wire [ (32*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_rx_data_wire_filter       ; // Adjusted width
  wire [  7:0]                       gt_rx_elec_idle_wire_filter  ;
  wire [ (3*LINK_CAP_MAX_LINK_WIDTH)-1 : 0] gt_rx_status_wire_filter     ; // Adjusted width
  wire [  7:0]                       gt_rx_valid_wire_filter      ;
  wire                               pipe_clk_int; // Internal clock from wrapper
  reg                                phy_rdy_n_int; // Assuming driving logic exists elsewhere or is implicit
  // reg                                reg_clock_locked; // Unused
  // wire                               all_phystatus_rst; // Unused
  wire                               dft_pipe_clk; // DFT Clock Mux Output
  wire                               filter_reset; // DFT Reset for filter (Active High)
  wire                               dft_pl_reset; // DFT Reset for pl_ltssm_state_q (Active High)

reg [5:0] pl_ltssm_state_q;

// DFT Clock Mux: Use sys_clk in test mode, pipe_clk_int in functional mode
assign dft_pipe_clk = test_i ? sys_clk : pipe_clk_int;

// DFT Reset Mux for filter: Use sys_rst_n (active high) in test mode, phy_rdy_n_int (active high) in functional mode
// Assuming phy_rdy_n_int is intended to be an active-high reset signal for the filter
assign filter_reset = test_i ? !sys_rst_n : phy_rdy_n_int; 

// DFT Reset Mux for pl_ltssm_state_q: Use sys_rst_n (active high) in test mode, clock_locked (active low) in functional mode
assign dft_pl_reset = test_i ? !sys_rst_n : !clock_locked;

// Register clocked by DFT clock, with DFT controllable asynchronous reset
// Changed reset edge to posedge and active high signal dft_pl_reset
always @(posedge dft_pipe_clk or posedge dft_pl_reset) begin
  if (dft_pl_reset) // Use DFT controlled reset signal
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

  assign pipe_clk = pipe_clk_int ; // Keep original pipe_clk output if needed externally
  wire                               plm_in_l0 = (pl_ltssm_state_q == 6'h16);
  wire                               plm_in_rl = (pl_ltssm_state_q == 6'h1c);
  wire                               plm_in_dt = (pl_ltssm_state_q == 6'h2d);
  wire                               plm_in_rs = (pl_ltssm_state_q == 6'h1f);

genvar i;
generate for (i=0; i<LINK_CAP_MAX_LINK_WIDTH; i=i+1)
 begin : gt_rx_valid_filter
   pcie_7x_v1_11_0_gt_rx_valid_filter_7x # (
     .CLK_COR_MIN_LAT(28)
   )
   GT_RX_VALID_FILTER_7x_inst (
     // Corrected slicing syntax assuming 2 bits for K, 16 bits for Data per lane
     .USER_RXCHARISK   ( gt_rx_data_k_wire   [(2*i)+1 : (2*i)] ),           
     .USER_RXDATA      ( gt_rx_data_wire     [(16*i)+15: (16*i)] ),      
     .USER_RXVALID     ( gt_rx_valid_wire    [i] ),                                       
     .USER_RXELECIDLE  ( gt_rx_elec_idle_wire[i] ),                                   
     .USER_RX_STATUS   ( gt_rx_status_wire   [(3*i)+2 : (3*i)] ),                          
     .USER_RX_PHY_STATUS ( gt_rx_phy_status_wire [i] ),                                
     .GT_RXCHARISK     ( gt_rx_data_k_wire_filter   [(2*i)+1 : (2*i)] ),       
     .GT_RXDATA        ( gt_rx_data_wire_filter     [(16*i)+15: (16*i)] ), 
     .GT_RXVALID       ( gt_rx_valid_wire_filter    [i] ),                                
     .GT_RXELECIDLE    ( gt_rx_elec_idle_wire_filter[i] ),                            
     .GT_RX_STATUS     ( gt_rx_status_wire_filter   [(3*i)+2 : (3*i)] ),                   
     .GT_RX_PHY_STATUS ( gt_rx_phy_status_wire_filter [i] ),
     .PLM_IN_L0        ( plm_in_l0 ),                                                  
     .PLM_IN_RS        ( plm_in_rs ),                                                  
     .USER_CLK         ( dft_pipe_clk ),     // Use DFT clock                                          
     .RESET            ( filter_reset )      // Use DFT controlled reset (Active High)                                         
   );
 end
endgenerate

  pcie_7x_v1_11_0_pipe_wrapper #
  (
    .PCIE_SIM_MODE                  ( PL_FAST_TRAIN ),
    .PCIE_SIM_SPEEDUP               ( "TRUE" ),
    .PCIE_EXT_CLK                   ( PCIE_EXT_CLK ),
    .PCIE_TXBUF_EN                  ( PCIE_TXBUF_EN ),
    .PCIE_ASYNC_EN                  ( PCIE_ASYNC_EN ),
    .PCIE_CHAN_BOND                 ( PCIE_CHAN_BOND ),
    .PCIE_PLL_SEL                   ( PCIE_PLL_SEL ),
    .PCIE_GT_DEVICE                 ( PCIE_GT_DEVICE ),
    .PCIE_USE_MODE                  ( PCIE_USE_MODE ),
    .PCIE