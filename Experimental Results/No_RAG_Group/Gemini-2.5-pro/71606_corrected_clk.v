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
// File       : 1_corrected_clk.v
// Version    : 3.0
//-- Description: GTX module for 7-series Integrated PCIe Block - DFT Corrected
//--              for CLKNPI violation.
//--
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

//(* DowngradeIPIdentifiedWarnings = "yes" *)
module pcie_7x_0_core_top_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8,          // 1 - x1 , 2 - x2 , 4 - x4 , 8 - x8
   parameter               REF_CLK_FREQ            = 0,          // 0 - 100 MHz , 1 - 125 MHz , 2 - 250 MHz
   parameter               USER_CLK2_DIV2          = "FALSE",    // "FALSE" => user_clk2 = user_clk
                                                                 // "TRUE" => user_clk2 = user_clk/2, where user_clk = 500 or 250 MHz.
   parameter  integer      USER_CLK_FREQ           = 3,          // 0 - 31.25 MHz , 1 - 62.5 MHz , 2 - 125 MHz , 3 - 250 MHz , 4 - 500Mhz
   parameter               PL_FAST_TRAIN           = "FALSE",    // Simulation Speedup
   parameter               PCIE_EXT_CLK            = "FALSE",    // Use External Clocking
   parameter               PCIE_USE_MODE           = "1.0",      // 1.0 = K325T IES, 1.1 = VX485T IES, 3.0 = K325T GES
   parameter               PCIE_GT_DEVICE          = "GTX",      // Select the GT to use (GTP for Artix-7, GTX for K7/V7)
   parameter               PCIE_PLL_SEL            = "CPLL",     // Select the PLL (CPLL or QPLL)
   parameter               PCIE_ASYNC_EN           = "FALSE",    // Asynchronous Clocking Enable
   parameter               PCIE_TXBUF_EN           = "FALSE",    // Use the Tansmit Buffer
   parameter               PCIE_EXT_GT_COMMON      = "FALSE",
   parameter               EXT_CH_GT_DRP           = "FALSE",
   parameter               TX_MARGIN_FULL_0        = 7'b1001111, // 1000 mV
   parameter               TX_MARGIN_FULL_1        = 7'b1001110, // 950 mV
   parameter               TX_MARGIN_FULL_2        = 7'b1001101, // 900 mV
   parameter               TX_MARGIN_FULL_3        = 7'b1001100, // 850 mV
   parameter               TX_MARGIN_FULL_4        = 7'b1000011, // 400 mV
   parameter               TX_MARGIN_LOW_0         = 7'b1000101, // 500 mV
   parameter               TX_MARGIN_LOW_1         = 7'b1000110, // 450 mV
   parameter               TX_MARGIN_LOW_2         = 7'b1000011, // 400 mV
   parameter               TX_MARGIN_LOW_3         = 7'b1000010, // 350 mV
   parameter               TX_MARGIN_LOW_4         = 7'b1000000,

   parameter               PCIE_CHAN_BOND          = 0,
   parameter               TCQ                     = 1           //synthesis warning solved: parameter declaration becomes local
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
   // Pipe Per-Lane Signals                                                                                           //
   //-----------------------------------------------------------------------------------------------------------------//


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
   input   wire                                  sys_clk                , // Primary Clock Input
   input   wire                                  sys_rst_n              , // Primary Reset Input (Active Low)
   input   wire                                  PIPE_MMCM_RST_N        ,
   output  wire                                  pipe_clk               , // This might still be the internal clock, but FFs are clocked by sys_clk
   output  wire                                  user_clk               ,
   output  wire                                  user_clk2              ,

//----------- Shared Logic Internal--------------------------------------

  output                                        INT_PCLK_OUT_SLAVE,     // PCLK       | PCLK
  output                                        INT_RXUSRCLK_OUT,       // RXUSERCLK
  output  [(LINK_CAP_MAX_LINK_WIDTH-1):0]       INT_RXOUTCLK_OUT,       // RX recovered clock
  output                                        INT_DCLK_OUT,           // DCLK       | DCLK
  output                                        INT_USERCLK1_OUT,       // Optional user clock
  output                                        INT_USERCLK2_OUT,       // Optional user clock
  output                                        INT_OOBCLK_OUT,         // OOB        | OOB
  output                                        INT_MMCM_LOCK_OUT,      // Async      | Async
  output  [1:0]                                 INT_QPLLLOCK_OUT,
  output  [1:0]                                 INT_QPLLOUTCLK_OUT,
  output  [1:0]                                 INT_QPLLOUTREFCLK_OUT,
  input   [(LINK_CAP_MAX_LINK_WIDTH-1):0]       INT_PCLK_SEL_SLAVE,

  // Shared Logic External

 //---------- External GT COMMON Ports ----------------------
  input   [11:0]                                qpll_drp_crscode,
  input   [17:0]                                qpll_drp_fsm,
  input   [1:0]                                 qpll_drp_done,
  input   [1:0]                                 qpll_drp_reset,
  input   [1:0]                                 qpll_qplllock,
  input   [1:0]                                 qpll_qplloutclk,
  input   [1:0]                                 qpll_qplloutrefclk,
  output                                        qpll_qplld,
  output  [1:0]                                 qpll_qpllreset,
  output                                        qpll_drp_clk,
  output                                        qpll_drp_rst_n,
  output                                        qpll_drp_ovrd,
  output                                        qpll_drp_gen3,
  output                                        qpll_drp_start,

  //---------- External Clock Ports ----------------------
  input                                         PIPE_PCLK_IN,           // PCLK       | PCLK
  input                                         PIPE_RXUSRCLK_IN,       // RXUSERCLK
  input  [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_RXOUTCLK_IN,       // RX recovered clock
  input                                         PIPE_DCLK_IN,           // DCLK       | DCLK
  input                                         PIPE_USERCLK1_IN,       // Optional user clock
  input                                         PIPE_USERCLK2_IN,       // Optional user clock
  input                                         PIPE_OOBCLK_IN,         // OOB        | OOB
  input                                         PIPE_MMCM_LOCK_IN,      // Async      | Async
  output                                        PIPE_TXOUTCLK_OUT,      // PCLK       | PCLK
  output [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_RXOUTCLK_OUT,      // RX recovered clock (for debug only)
  output [LINK_CAP_MAX_LINK_WIDTH-1:0]          PIPE_PCLK_SEL_OUT,      // PCLK       | PCLK
  output                                        PIPE_GEN3_OUT ,          // PCLK       | PCLK

//-----------TRANSCEIVER DEBUG--------------------------------

  output      [4:0]                             PIPE_RST_FSM,
  output      [11:0]                            PIPE_QRST_FSM,
  output      [(LINK_CAP_MAX_LINK_WIDTH*5)-1:0] PIPE_RATE_FSM,
  output      [(LINK_CAP_MAX_LINK_WIDTH*6)-1:0] PIPE_SYNC_FSM_TX,
  output      [(LINK_CAP_MAX_LINK_WIDTH*7)-1:0] PIPE_SYNC_FSM_RX,
  output      [(LINK_CAP_MAX_LINK_WIDTH*7)-1:0] PIPE_DRP_FSM,

  output                                        PIPE_RST_IDLE,
  output                                        PIPE_QRST_IDLE,
  output                                        PIPE_RATE_IDLE,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_EYESCANDATAERROR,
  output     [(LINK_CAP_MAX_LINK_WIDTH*3)-1:0]  PIPE_RXSTATUS,
  output     [(LINK_CAP_MAX_LINK_WIDTH*15)-1:0] PIPE_DMONITOROUT,

  //---------- Debug Ports -------------------------------
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_CPLL_LOCK,
  output     [(LINK_CAP_MAX_LINK_WIDTH-1)>>2:0] PIPE_QPLL_LOCK,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXPMARESETDONE,
  output     [(LINK_CAP_MAX_LINK_WIDTH*3)-1:0]  PIPE_RXBUFSTATUS,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXPHALIGNDONE,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXPHINITDONE,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXDLYSRESETDONE,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXPHALIGNDONE,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXDLYSRESETDONE,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXSYNCDONE,
  output     [(LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  PIPE_RXDISPERR,
  output     [(LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  PIPE_RXNOTINTABLE,
  output     [(LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXCOMMADET,

  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_0,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_1,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_2,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_3,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_4,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_5,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_6,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_7,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_8,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_9,
  output      [31:0]                            PIPE_DEBUG,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_JTAG_RDY,

  input       [ 2:0]                            PIPE_TXPRBSSEL,
  input       [ 2:0]                            PIPE_RXPRBSSEL,
  input                                         PIPE_TXPRBSFORCEERR,
  input                                         PIPE_RXPRBSCNTRESET,
  input       [ 2:0]                            PIPE_LOOPBACK,
  output      [LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_RXPRBSERR