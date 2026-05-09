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

   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,

   output  wire                      phy_rdy_n,
   input   wire                      test_i // Added for DFT
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
  wire [ 31:0]                       gt_rx_data_k_wire            ;
  wire [255:0]                       gt_rx_data_wire              ;
  wire [  7:0]                       gt_rx_elec_idle_wire         ;
  wire [ 23:0]                       gt_rx_status_wire            ;
  wire [  7:0]                       gt_rx_valid_wire             ;
  wire [  7:0]                       gt_rx_polarity               ;
  wire [ 15:0]                       gt_power_down                ;
  wire [  7:0]                       gt_tx_char_disp_mode         ;
  wire [ 31:0]                       gt_tx_data_k                 ;
  wire [255:0]                       gt_tx_data                   ;
  wire                               gt_tx_detect_rx_loopback     ;
  wire [  7:0]                       gt_tx_elec_idle              ;
  wire [  7:0]                       gt_rx_elec_idle_reset        ;
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] plllkdet                     ;
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] phystatus_rst                ;
  wire                               clock_locked                 ;

  wire [  7:0]                       gt_rx_phy_status_wire_filter ;
  wire [ 31:0]                       gt_rx_data_k_wire_filter     ;
  wire [255:0]                       gt_rx_data_wire_filter       ;
  wire [  7:0]                       gt_rx_elec_idle_wire_filter  ;
  wire [ 23:0]                       gt_rx_status_wire_filter     ;
  wire [  7:0]                       gt_rx_valid_wire_filter      ;

  wire                               pipe_clk_int;
  reg                                phy_rdy_n_int;

  reg                                reg_clock_locked;
  wire                               all_phystatus_rst;

reg [5:0] pl_ltssm_state_q;

wire dft_pipe_clk_int; // Added for DFT
assign dft_pipe_clk_int = test_i ? sys_clk : pipe_clk_int; // Added for DFT

always @(posedge dft_pipe_clk_int or negedge clock_locked) begin // Modified clock for DFT

  if (!clock_locked)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;

end

  assign pipe_clk = pipe_clk_int ;

  wire                               plm_in_l0 = (pl_ltssm_state_q == 6'h16);
  wire                               plm_in_rl = (pl_ltssm_state_q == 6'h1c);
  wire                               plm_in_dt = (pl_ltssm_state_q == 6'h2d);
  wire                               plm_in_rs = (pl_ltssm_state_q == 6'h1f);

//-------------RX FILTER Instantiation----------------------------------------------------------//
genvar i;
generate for (i=0; i<LINK_CAP_MAX_LINK_WIDTH; i=i+1)
 begin : gt_rx_valid_filter

   pcie_core_gt_rx_valid_filter_7x # (
     .CLK_COR_MIN_LAT(28)
   )
   GT_RX_VALID_FILTER_7x_inst (

     .USER_RXCHARISK   ( gt_rx_data_k_wire [(2*i)+1 : (2*i)] ),           //O - Corrected Indexing
     .USER_RXDATA      ( gt_rx_data_wire [(16*i)+15 : (16*i)] ),      //O - Corrected Indexing
     .USER_RXVALID     ( gt_rx_valid_wire [i] ),                                       //O
     .USER_RXELECIDLE  ( gt_rx_elec_idle_wire [i] ),                                   //O
     .USER_RX_STATUS   ( gt_rx_status_wire [(3*i)+2:(3*i)] ),                          //O
     .USER_RX_PHY_STATUS ( gt_rx_phy_status_wire [i] ),                                //O

     .GT_RXCHARISK     ( gt_rx_data_k_wire_filter [(2*i)+1 : (2*i)] ),       //I - Corrected Indexing
     .GT_RXDATA        ( gt_rx_data_wire_filter [(16*i)+15 : (16*i)] ), //I - Corrected Indexing
     .GT_RXVALID       ( gt_rx_valid_wire_filter [i] ),                                //I
     .GT_RXELECIDLE    ( gt_rx_elec_idle_wire_filter [i] ),                            //I
     .GT_RX_STATUS     ( gt_rx_status_wire_filter [(3*i)+2:(3*i)] ),                   //I
     .GT_RX_PHY_STATUS ( gt_rx_phy_status_wire_filter [i] ),

     .PLM_IN_L0        ( plm_in_l0 ),                                                  //I
     .PLM_IN_RS        ( plm_in_rs ),                                                  //I
     .USER_CLK         ( dft_pipe_clk_int ),                                           // Modified clock for DFT
     .RESET            ( phy_rdy_n_int )                                               //I
   );


 end
endgenerate

  //---------- GT Instantiation ---------------------------------------------------------------
  pcie_core_pipe_wrapper #
  (
    .PCIE_SIM_MODE                  ( PL_FAST_TRAIN ),

    // synthesis translate_off
    .PCIE_SIM_SPEEDUP               ( "TRUE" ),
    // synthesis translate_on

    .PCIE_EXT_CLK                   ( PCIE_EXT_CLK ),
    .PCIE_TXBUF_EN                  ( PCIE_TXBUF_EN ),
    .PCIE_ASYNC_EN                  ( PCIE_ASYNC_EN ),
    .PCIE_CHAN_BOND                 ( PCIE_CHAN_BOND ),
    .PCIE_PLL_SEL                   ( PCIE_PLL_SEL ),
    .PCIE_GT_DEVICE                 ( PCIE_GT_DEVICE ),
    .PCIE_USE_MODE                  ( PCIE_USE_MODE ),
    .PCIE_LANE                      ( LINK_CAP_MAX_LINK_WIDTH ),
    .PCIE_LPM_DFE                   ( PCIE_LPM_DFE ),
    .PCIE_LINK_SPEED                ( PCIE_LINK_SPEED ),
    .PCIE_TX_EIDLE_ASSERT_DELAY     ( PCIE_TX_EIDLE_ASSERT_DELAY ),
    .PCIE_OOBCLK_MODE               ( PCIE_OOBCLK_MODE_ENABLE ),

    .PCIE_REFCLK_FREQ               ( REF_CLK_FREQ ),
    .PCIE_USERCLK1_FREQ             ( USER_CLK_FREQ +1 ),
    .PCIE_USERCLK2_FREQ             ( USERCLK2_FREQ +1 )

  ) pipe_wrapper_i (

    //---------- PIPE Clock & Reset Ports ------------------
    .PIPE_PCLK_IN                   ( PIPE_PCLK_IN ),
    .PIPE_RXUSRCLK_IN               ( PIPE_RXUSRCLK_IN ),
    .PIPE_RXOUTCLK_IN               ( PIPE_RXOUTCLK_IN ),
    .PIPE_DCLK_IN                   ( PIPE_DCLK_IN ),
    .PIPE_USERCLK1_IN               ( PIPE_USERCLK1_IN ),
    .PIPE_USERCLK2_IN               ( PIPE_USERCLK2_IN ),
    .PIPE_OOBCLK_IN                 ( PIPE_OOBCLK_IN ),
    .PIPE_MMCM_LOCK_IN              ( PIPE_MMCM_LOCK_IN ),
    .PIPE_TXOUTCLK_OUT              ( PIPE_TXOUTCLK_OUT ),
    .PIPE_RXOUTCLK_OUT              ( PIPE_RXOUTCLK_OUT ),
    .PIPE_PCLK_SEL_OUT              ( PIPE_PCLK_SEL_OUT ),
    .PIPE_GEN3_OUT                  ( PIPE_GEN3_OUT ),

    //---------- PIPE RX Data Ports ------------------------
    .PIPE_RXDATA_OUT                ( gt_rx_data_wire_filter ),
    .PIPE_RXCHARISK_OUT             ( gt_rx_data_k_wire_filter ),
    .PIPE_RXVALID_OUT               ( gt_rx_valid_wire_filter ),
    .PIPE_RXELECIDLE_OUT            ( gt_rx_elec_idle_wire_filter ),
    .PIPE_RXSTATUS_OUT              ( gt_rx_status_wire_filter ),
    .PIPE_PHYSTATUS_OUT             ( gt_rx_phy_status_wire_filter ),
    .PIPE_RXCHANISALIGNED_OUT       ( gt_rxchanisaligned_wire ),

    //---------- PIPE TX Data Ports ------------------------
    .PIPE_TXDATA_IN                 ( gt_tx_data ),
    .PIPE_TXCHARISK_IN              ( gt_tx_data_k ),
    .PIPE_TXELECIDLE_IN             ( gt_tx_elec_idle ),
    .PIPE_TXCOMPLIANCE_IN           ( gt_tx_char_disp_mode ),

    //---------- PIPE Configuration Ports ------------------
    .PIPE_POWERDOWN_IN              ( gt_power_down ),
    .PIPE_RXPOLARITY_IN             ( gt_rx_polarity ),
    .PIPE_TXDETECTRX_IN             ( gt_tx_detect_rx_loopback ),
    .PIPE_TXDEEMPH_IN               ( pipe_tx_deemph ),
    .PIPE_TXMARGIN_IN               ( pipe_tx_margin ),
    .PIPE_TXSWING_IN                ( pipe_tx_swing ),
    .PIPE_RESET_IN                  ( pipe_tx_reset ),
    .PIPE_RATE_IN                   ( pipe_tx_rate ),

    //---------- PCIe Physical Layer Interface -------------
    .PCIE_RXN_IN                    ( pci_exp_rxn ),
    .PCIE_RXP_IN                    ( pci_exp_rxp ),
    .PCIE_TXN_OUT                   ( pci_exp_txn ),
    .PCIE_TXP_OUT                   ( pci_exp_txp ),

    //---------- System Interface --------------------------
    .SYS_CLK_IN                     ( sys_clk ),
    .SYS_RST_N_IN                   ( sys_rst_n ),
    .PIPE_MMCM_RST_N                ( PIPE_MMCM_RST_N ),

    //---------- Physical Layer Interface ------------------
    .PHY_CLK_OUT                    ( pipe_clk_int ),
    .PHY_USER_CLK_OUT               ( user_clk ),
    .PHY_USER_CLK2_OUT              ( user_clk2 ),
    .PHY_RDY_N_OUT                  ( phy_rdy_n_int ),
    .PHY_PLLLKDET_OUT               ( plllkdet ),
    .PHY_CLOCK_LOCKED_OUT           ( clock_locked )

    );

  assign phy_rdy_n = phy_rdy_n_int;

  //---------- PIPE Output Assignments -------------------
  assign pipe_rx0_char_is_k     = gt_rx_data_k_wire[1:0]             ;
  assign pipe_rx0_data          = gt_rx_data_wire[15:0]              ;
  assign pipe_rx0_valid         = gt_rx_valid_wire[0]                ;
  assign pipe_rx0_chanisaligned = gt_rxchanisaligned_wire[0]         ;
  assign pipe_rx0_status        = gt_rx_status_wire[2:0]             ;
  assign pipe_rx0_phy_status    = gt_rx_phy_status_wire[0]           ;
  assign pipe_rx0_elec_idle     = gt_rx_elec_idle_wire[0]            ;
  assign gt_rx_polarity[0]      = pipe_rx0_polarity                  ;
  assign gt_tx_char_disp_mode[0]= pipe_tx0_compliance                ;
  assign gt_tx_data_k[1:0]      = pipe_tx0_char_is_k                 ;
  assign gt_tx_data[15:0]       = pipe_tx0_data                      ;
  assign gt_tx_elec_idle[0]     = pipe_tx0_elec_idle                 ;
  assign gt_power_down[1:0]     = pipe_tx0_powerdown                 ;

  assign pipe_rx1_char_is_