//-----------------------------------------------------------------------------
//
// (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Series-7 Integrated Block for PCI Express
// File       : pcie_core_gt_top.v
// Version    : 1.10
//-- Description: GTX module for 7-series Integrated PCIe Block
//--
//--
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module pcie_core_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8, // 1 - x1 , 2 - x2 , 4 - x4 , 8 - x8
   parameter               REF_CLK_FREQ = 0,            // 0 - 100 MHz , 1 - 125 MHz , 2 - 250 MHz
   parameter               USER_CLK2_DIV2 = "FALSE",    // "FALSE" => user_clk2 = user_clk
                                                        // "TRUE" => user_clk2 = user_clk/2, where user_clk = 500 or 250 MHz.
   parameter  integer      USER_CLK_FREQ = 3,           // 0 - 31.25 MHz , 1 - 62.5 MHz , 2 - 125 MHz , 3 - 250 MHz , 4 - 500Mhz
   parameter               PL_FAST_TRAIN = "FALSE",     // Simulation Speedup
   parameter               PCIE_EXT_CLK = "FALSE",      // Use External Clocking
   parameter               PCIE_USE_MODE = "1.0",       // 1.0 = K325T IES, 1.1 = VX485T IES, 3.0 = K325T GES
   parameter               PCIE_GT_DEVICE = "GTX",      // Select the GT to use (GTP for Artix-7, GTX for K7/V7)
   parameter               PCIE_PLL_SEL   = "CPLL",     // Select the PLL (CPLL or QPLL)
   parameter               PCIE_ASYNC_EN  = "FALSE",    // Asynchronous Clocking Enable
   parameter               PCIE_TXBUF_EN  = "FALSE",    // Use the Tansmit Buffer
   parameter               PCIE_CHAN_BOND = 0
)
(
   //-----------------------------------------------------------------------------------------------------------------//
   // pl ltssm
   input   wire [5:0]                pl_ltssm_state         ,
   // Pipe Per-Link Signals
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,

   //-----------------------------------------------------------------------------------------------------------------//
   // Clock Inputs                                                                                                    //
   //-----------------------------------------------------------------------------------------------------------------//
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

   // Pipe Per-Lane Signals - Lane 0
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

   // Pipe Per-Lane Signals - Lane 1
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

   // Pipe Per-Lane Signals - Lane 2
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

   // Pipe Per-Lane Signals - Lane 3
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

   // Pipe Per-Lane Signals - Lane 4
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

   // Pipe Per-Lane Signals - Lane 5
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

   // Pipe Per-Lane Signals - Lane 6
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

   // Pipe Per-Lane Signals - Lane 7
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

   // PCI Express signals
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,

   // Non PIPE signals
   input   wire                      sys_clk                ,
   input   wire                      sys_rst_n              ,
   input   wire                      PIPE_MMCM_RST_N        ,
   input   wire                      test_mode              , // DFT Input
   input   wire                      test_rst_n             , // DFT Input


   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,

   output  wire                      phy_rdy_n
);

  parameter                          TCQ  = 1;      // clock to out delay model

  localparam                         USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                                                        (USER_CLK_FREQ == 4) ? 3 :
                                                        (USER_CLK_FREQ == 3) ? 2 :
                                                         USER_CLK_FREQ;

  localparam                         PCIE_LPM_DFE    = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
  localparam                         PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;

// The parameter PCIE_OOBCLK_MODE_ENABLE value should be "0" for simulation and for synthesis it should be 1
  //localparam                         PCIE_OOBCLK_MODE_ENABLE = (PL_FAST_TRAIN == "TRUE") ? 0 : 1;
  localparam                         PCIE_OOBCLK_MODE_ENABLE =  1;

  localparam              PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 4 : 2;

  wire [  7:0]                       gt_rx_phy_status_wire        ;
  wire [  7:0]                       gt_rxchanisaligned_wire      ;
  wire [ (LINK_CAP_MAX_LINK_WIDTH*2)-1 : 0 ] gt_rx_data_k_wire            ; // Size based on LINK_CAP_MAX_LINK_WIDTH
  wire [ (LINK_CAP_MAX_LINK_WIDTH*16)-1 : 0] gt_rx_data_wire              ; // Size based on LINK_CAP_MAX_LINK_WIDTH
  wire [  7:0]                       gt_rx_elec_idle_wire         ;
  wire [ (LINK_CAP_MAX_LINK_WIDTH*3)-1 : 0 ] gt_rx_status_wire            ; // Size based on LINK_CAP_MAX_LINK_WIDTH
  wire [  7:0]                       gt_rx_valid_wire             ;
  wire [  7:0]                       gt_rx_polarity               ;
  wire [ 15:0]                       gt_power_down                ;
  wire [  7:0]                       gt_tx_char_disp_mode         ;
  wire [ (LINK_CAP_MAX_LINK_WIDTH*2)-1 : 0 ] gt_tx_data_k                 ; // Size based on LINK_CAP_MAX_LINK_WIDTH
  wire [ (LINK_CAP_MAX_LINK_WIDTH*16)-1 : 0] gt_tx_data                   ; // Size based on LINK_CAP_MAX_LINK_WIDTH
  wire                               gt_tx_detect_rx_loopback     ;
  wire [  7:0]                       gt_tx_elec_idle              ;
  wire [  7:0]                       gt_rx_elec_idle_reset        ;
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] plllkdet                     ;
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] phystatus_rst                ;
  wire                               clock_locked                 ; // Assuming this signal indicates clock stability

  // Wires for filter inputs (sized appropriately)
  wire [  7:0]                       gt_rx_phy_status_wire_filter ;
  wire [ (LINK_CAP_MAX_LINK_WIDTH*2)-1 : 0 ] gt_rx_data_k_wire_filter     ;
  wire [ (LINK_CAP_MAX_LINK_WIDTH*16)-1 : 0] gt_rx_data_wire_filter       ;
  wire [  7:0]                       gt_rx_elec_idle_wire_filter  ;
  wire [ (LINK_CAP_MAX_LINK_WIDTH*3)-1 : 0 ] gt_rx_status_wire_filter     ;
  wire [  7:0]                       gt_rx_valid_wire_filter      ;

  wire                               pipe_clk_int;
  reg                                phy_rdy_n_int;

  reg                                reg_clock_locked;
  wire                               all_phystatus_rst;

  reg [5:0] pl_ltssm_state_q;

  wire dft_clk; // DFT clock wire
  assign dft_clk = test_mode ? sys_clk : pipe_clk_int; // Mux for test clock


// DFT Change: Use dft_clk and synchronous test reset test_rst_n
always @(posedge dft_clk) begin
  if (test_mode && !test_rst_n) begin // Test mode synchronous reset
     pl_ltssm_state_q <= #TCQ 6'b0;
  end else if (!test_mode) begin // Functional mode
     // In functional mode, use the functional reset condition derived from clock_locked,
     // but make it synchronous to the functional clock (pipe_clk_int).
     // We assume clock_locked is asserted high when the clock is stable and reset should be deasserted.
     if (!clock_locked) begin // Functional mode reset condition (synchronous to pipe_clk_int via dft_clk mux)
        pl_ltssm_state_q <= #TCQ 6'b0;
     end else begin // Functional operation
        pl_ltssm_state_q <= #TCQ pl_ltssm_state;
     end
  end
  // Note: Scan enable logic would typically be added here by DFT tools.
end


  assign pipe_clk = pipe_clk_int ; // Keep original assignment for internal use if needed

  // Assign clock_locked based on PIPE_MMCM_LOCK_IN (assuming this is the indicator)
  // This should ideally be registered synchronously to the relevant clock domain if needed elsewhere,
  // but for the reset logic above, using it directly (combinatorially) is okay if it's stable.
  assign clock_locked = PIPE_MMCM_LOCK_IN;


  wire                               plm_in_l0 = (pl_ltssm_state_q == 6'h16);
  wire                               plm_in_rl = (pl_ltssm_state_q == 6'h1c);
  wire                               plm_in_dt = (pl_ltssm_state_q == 6'h2d);
  wire                               plm_in_rs = (pl_ltssm_state_q == 6'h1f);

//-------------RX FILTER Instantiation----------------------------------------------------------//
// Assuming pcie_core_gt_rx_valid_filter_7x has CLK and RESET_N ports
// Assuming it uses pipe_clk_int and the functional reset derived from clock_locked

genvar i;
generate for (i=0; i<LINK_CAP_MAX_LINK_WIDTH; i=i+1)
 begin : gt_rx_valid_filter

   // Placeholder for the actual filter module instantiation
   // Assuming the filter module name is 'pcie_core_gt_rx_valid_filter_7x'
   // and it has the ports listed below.
   // The exact ports and behavior depend on the filter's definition.
   /*
   pcie_core_gt_rx_valid_filter_7x # (
     .CLK_COR_MIN_LAT(28) // Example parameter
   )
   GT_RX_VALID_FILTER_7x_inst (
     // Clock and Reset (Assumed Ports)
     .CLK              ( pipe_clk_int ), // Use the internal pipe clock
     .RESET_N          ( clock_locked ), // Use clock_locked as active-low reset

     // Filter Outputs (Connect to internal wires)
     .USER_RXCHARISK   ( gt_rx_data_k_wire [(2*i)+1 : (2*i)] ),           // Corrected Indexing
     .USER_RXDATA      ( gt_rx_data_wire [(16*i)+15 : (16*i)] ),          // Corrected Indexing
     .USER_RXVALID     ( gt_rx_valid_wire [i] ),
     .USER_RXELECIDLE  ( gt_rx_elec_idle_wire [i] ),
     .USER_RX_STATUS   ( gt_rx_status_wire [(3*i)+2 : (3*i)] ),
     .USER_RX_PHY_STATUS( gt_rx_phy_status_wire