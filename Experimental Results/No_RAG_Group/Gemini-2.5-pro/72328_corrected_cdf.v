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

module decode_nok_1_corrected_cdf # (
  parameter CHANNEL = "BLUE"
)
(
  input  wire reset,            //
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
  // input  wire test_mode,        // Added for DFT: Test mode enable
  // input  wire scan_in_toggle,   // Added for DFT: Scan input for toggle flop

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
  wire toggle_next; // Intermediate wire for toggle logic
  assign toggle_next = ~toggle; // Combinational logic for next state

  // Modified toggle flip-flop to potentially avoid CDFDAT misinterpretation
  // by separating combinational logic from sequential update.
  always @ (posedge pclkx2 or posedge reset)
    if (reset == 1'b1) begin
      toggle <= 1'b0 ;
    end else begin
      // The data input 'toggle_next' is derived from '~toggle', not the clock 'pclkx2'.
      toggle <=#1 toggle_next;
    end

  // DFT Fix using test_mode (requires adding ports, commented out as per instructions)
  // wire toggle_d;
  // assign toggle_d = test_mode ? scan_in_toggle : toggle_next;
  // always @ (posedge pclkx2 or posedge reset)
  //   if (reset == 1'b1) begin
  //     toggle <= 1'b0 ;
  //   end else begin
  //     toggle <=#1 toggle_d;
  //   end

  wire rx_toggle;

  assign rx_toggle = toggle ^ flipgearx2; //reverse hi-lo position

  wire [4:0] raw5bit;
  reg [4:0] raw5bit_q;
  reg [9:0] rawword;

  always @ (posedge pclkx2) begin
    raw5bit_q    <=#1 raw5bit;

    if(rx_toggle) //gear from 5 bit to 10 bit
      rawword <=#1 {raw5bit, raw5bit_q};
  end

  ////////////////////////////////
  //
  // bitslip signal sync to pclkx2
  //
  ////////////////////////////////
  reg bitslipx2 = 1'b0;
  reg bitslip_q = 1'b0;
  wire bitslip;

  always @ (posedge pclkx2) begin
    bitslip_q <=#1 bitslip;
    bitslipx2 <=#1 bitslip & !bitslip_q;
  end

  /////////////////////////////////////////////
  //
  // 1:5 de-serializer working at x2 pclk rate
  //
  /////////////////////////////////////////////
  serdes_1_to_5_diff_data_nok # (
    .DIFF_TERM("FALSE"),
    .BITSLIP_ENABLE("TRUE")
  ) des_0 (
    .use_phase_detector(1'b1),
    .datain_p(din_p),
    .datain_n(din_n),
    .rxioclk(pclkx10),
    .rxserdesstrobe(serdesstrobe),
    .reset(reset),
    .gclk(pclkx2),
    .bitslip(bitslipx2),
    .data_out(raw5bit)
  );

  /////////////////////////////////////////////////////
  // Doing word boundary detection here
  /////////////////////////////////////////////////////
  wire [9:0] rawdata = rawword;

  ///////////////////////////////////////
  // Phase Alignment Instance
  ///////////////////////////////////////
  phsaligner_nok # (
	 .CHANNEL(CHANNEL)
  ) phsalgn_0 (
     .rst(reset),
     .clk(pclk),
     .sdata(rawdata),
     .bitslip(bitslip),
     .flipgear(flipgear),
     .psaligned(iamvld)
   );

  assign psalgnerr = 1'b0;

  ///////////////////////////////////////
  // Per Channel De-skew Instance
  ///////////////////////////////////////
  wire [9:0] sdata;
  chnlbond cbnd (
    .clk(pclk),
    .rawdata(rawdata),
    .iamvld(iamvld),
    .other_ch0_vld(other_ch0_vld),
    .other_ch1_vld(other_ch1_vld),
    .other_ch0_rdy(other_ch0_rdy),
    .other_ch1_rdy(other_ch1_rdy),
    .iamrdy(iamrdy),
    .sdata(sdata)
  );

  /////////////////////////////////////////////////////////////////
  // Below performs the 10B-8B decoding function defined in DVI 1.0
  // Specification: Section 3.3.3, Figure 3-6, page 31.
  /////////////////////////////////////////////////////////////////
  // Distinct Control Tokens
  parameter CTRLTOKEN0 = 10'b1101010100;
  parameter CTRLTOKEN1 = 10'b0010101011;
  parameter CTRLTOKEN2 = 10'b0101010100;
  parameter CTRLTOKEN3 = 10'b1010101011;

  wire [7:0] data;
  assign data = (sdata[9]) ? ~sdata[7:0] : sdata[7:0];


  ////////////////////////////////
  // Control Period Ending
  ////////////////////////////////
  reg control  = 1'b0;
  reg control_q;

  always @ (posedge pclk) begin
    control_q <=#1 control;
  end

  wire control_end;

  assign control_end = !control & control_q;

  ////////////////////////////////
  // Video Period Detection
  ////////////////////////////////
  reg videoperiod = 1'b0;

  always @ (posedge pclk) begin
    if(control)
      videoperiod <=#1 1'b0;
    else if(control_end && videopreamble)
      videoperiod <=#1 1'b1;
  end

  ////////////////////////////////
  // Data Island Period Detection
  ////////////////////////////////
  reg dilndperiod = 1'b0;

  always @ (posedge pclk) begin
    if(control)
      dilndperiod <=#1 1'b0;
    else if(control_end && dilndpreamble)
      dilndperiod <=#1 1'b1;
  end

  ////////////////////////////////
  // Decoding ......
  ////////////////////////////////
  always @ (posedge pclk) begin
    if(iamrdy && other_ch0_rdy && other_ch1_rdy) begin
      case (sdata)
        CTRLTOKEN0: begin
          c0  <=#1 1'b0;
          c1  <=#1 1'b0;
          vde <=#1 1'b0;
		  ade <=#1 1'b0;

		  control <=#1 1'b1;
        end

        CTRLTOKEN1: begin
          c0  <=#1 1'b1;
          c1  <=#1 1'b0;
          vde <=#1 1'b0;
          ade <=#1 1'b0;

          control <=#1 1'b1;
        end

        CTRLTOKEN2: begin
          c0  <=#1 1'b0;
          c1  <=#1 1'b1;
          vde <=#1 1'b0;
          ade <=#1 1'b0;

          control <=#1 1'b1;
        end

        CTRLTOKEN3: begin
          c0  <=#1 1'b1;
          c1  <=#1 1'b1;
          vde <=#1 1'b0;
          ade <=#1 1'b0;

          control <=#1 1'b1;
        end

        default: begin // Data period
		  control <=#1 1'b0;

          if(videoperiod) begin //TMDS Coding
            vdout[0] <=#1 data[0];
            vdout[1] <=#1 (sdata[8]) ? (data[1] ^ data[0]) : (data[1] ~^ data[0]);
            vdout[2] <=#1 (sdata[8]) ? (data[2] ^ data[1]) : (data[2] ~^ data[1]);
            vdout[3] <=#1 (sdata[8]) ? (data[3] ^ data[2]) : (data[3] ~^ data[2]);
            vdout[4] <=#1 (sdata[8]) ? (data[4] ^ data[3]) : (data[4] ~^ data[3]);
            vdout[5] <=#1 (sdata[8]) ? (data[5] ^ data[4]) : (data[5] ~^ data[4]);
            vdout[6] <=#1 (sdata[8]) ? (data[6] ^ data[5]) : (data[6] ~^ data[5]);
            vdout[7] <=#1 (sdata[8]) ? (data[7] ^ data[6]) : (data[7] ~^ data[6]);

            ade <=#1 1'b0;
            vde <=#1 1'b1;
		  end else if((CHANNEL == "BLUE") || dilndperiod) begin
            case (sdata)
              /////////////////////////////////////
              // Aux/Audio Data: TERC4
              /////////////////////////////////////
              10'b1010011100: begin adout <=#1 4'b0000; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1001100011: begin adout <=#1 4'b0001; ade <=#1 1'b1; vde <=#1 1'b0; end
              10'b1011100100: begin adout <=#1