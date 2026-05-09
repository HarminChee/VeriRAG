//////////////////////////////////////////////////////////////////////////////
//
//  Xilinx, Inc. 2010                 www.xilinx.com
//
//  XAPP xxx
//
//////////////////////////////////////////////////////////////////////////////
//
//  File name :       decoder.v
//
//  Description :     Spartan-6 dvi decoder
//
//
//  Author :          Bob Feng
//
//  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are
//              provided to you "as is". Xilinx and its licensors makeand you
//              receive no warranties or conditions, express, implied,
//              statutory or otherwise, and Xilinx specificallydisclaims any
//              implied warranties of merchantability, non-infringement,or
//              fitness for a particular purpose. Xilinx does notwarrant that
//              the functions contained in these designs will meet your
//              requirements, or that the operation of these designswill be
//              uninterrupted or error free, or that defects in theDesigns
//              will be corrected. Furthermore, Xilinx does not warrantor
//              make any representations regarding use or the results ofthe
//              use of the designs in terms of correctness, accuracy,
//              reliability, or otherwise.
//
//              LIMITATION OF LIABILITY. In no event will Xilinx or its
//              licensors be liable for any loss of data, lost profits,cost
//              or procurement of substitute goods or services, or forany
//              special, incidental, consequential, or indirect damages
//              arising from the use or operation of the designs or
//              accompanying documentation, however caused and on anytheory
//              of liability. This limitation will apply even if Xilinx
//              has been advised of the possibility of such damage. This
//              limitation shall apply not-withstanding the failure ofthe
//              essential purpose of any limited remedies herein.
//
//  Copyright  2004 Xilinx, Inc.
//  All rights reserved
//
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1ps

module decode_nok # (
  parameter CHANNEL = "BLUE"
)
(
  input  wire test_mode,        // DFT test mode enable
  input  wire test_reset,       // DFT test reset input
  input  wire reset,            // Functional reset
  input  wire pclk,             //  pixel clock
  input  wire pclkx2,           //  double pixel rate for gear box
  input  wire pclkx10,          //  IOCLK
  input  wire serdesstrobe,     //  serdesstrobe for iserdes2
  input  wire din_p,            //  data from dvi cable
  input  wire din_n,            //  data from dvi cable
  input  wire other_ch0_vld,    //  other channel0 has valid data now
  input  wire other_ch1_vld,    //  other channel1 has valid data now
  input  wire other_ch0_rdy,    //  other channel0 has detected a valid starting pixel
  input  wire other_ch1_rdy,    //  other channel1 has detected a valid starting pixel
  input  wire videopreamble,    //video preambles
  input  wire dilndpreamble,    //data island preambles

  output wire iamvld,           //  I have valid data now
  output wire iamrdy,           //  I have detected a valid new pixel
  output wire psalgnerr,        //  Phase alignment error
  output reg  c0,
  output reg  c1,
  output reg  vde,
  output reg  ade,
  output reg [9:0] sdout,       //10 bit raw data out
  output reg [3:0] adout,       //4 bit audio/aux data out
  output reg [7:0] vdout);      //8 bit video data out

  ////////////////////////////////
  // DFT Reset Mux
  ////////////////////////////////
  wire dft_reset_mux;
  assign dft_reset_mux = test_mode ? test_reset : reset;

  ////////////////////////////////
  //
  // 5-bit to 10-bit gear box
  //
  ////////////////////////////////
  wire flipgear;
  reg flipgearx2;

  always @ (posedge pclkx2) begin
    flipgearx2 <=#1 flipgear;
  end

  reg toggle = 1'b0;

  // Modified to use muxed reset for DFT controllability
  always @ (posedge pclkx2 or posedge dft_reset_mux)
    if (dft_reset_mux == 1'b1) begin // Use muxed reset
      toggle <= 1'b0 ;
    end else begin
      toggle <=#1 ~toggle;
    end

  wire rx_toggle;

  assign rx_toggle = toggle ^ flipgearx2; //reverse hi-lo position

  wire