`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Josh Sackos
//
// Create Date:    07/26/2012
// Module Name:    ssdCtrl
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This module interfaces the onboard seven segment display (SSD) on
//					 the Nexys3, and formats the data to be displayed.
//
//					 The DIN input is a binary number that gets formatted to binary
//					 coded decimal, and is displayed as a signed 3 digit number on the
//					 SSD. Bit 9 on the DIN input controls whether or not a minus sign
//					 will be displayed on the SSD or not.  The AN output bus drives the
//					 SSD's anodes controling the illumination of the 4 digits on the SSD.
//					 The SEG output bus drives the cathodes on the SSD to display different
//					 characters.
//
// Revision History:
// 						Revision 0.01 - File Created (Josh Sackos)
//                  Revision 1.00 - DFT FFCKNP Fix
///////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								Define Module, Inputs and Outputs
//  ===================================================================================
module ssdCtrl_corrected_ffc( // Renamed module
		CLK,
		RST,
		DIN,
		AN,
		SEG,
		DOT,
		bcdData
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input            CLK;       // Primary Clock Input
   input            RST;       // Primary Reset Input
   input [9:0]      DIN;
   output [3:0]     AN;
   reg [3:0]        AN;
   output [6:0]     SEG;
   reg [6:0]        SEG;
   output           DOT;
   output wire [15:0] bcdData;

// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================

   // Clock Divider Parameters
   parameter [15:0] cntEndVal = 16'hC350; // Approx 1kHz enable @ 50MHz CLK
   reg [15:0]       clkCount;
   wire             clk_enable; // Clock enable signal derived from CLK

   // 2 Bit Counter
   reg [1:0]        CNT;

   // Binary Data to BCD
   // wire [15:0]      bcdData; // Already declared as output wire

   // Output Data Mux
   reg [3:0]        muxData;

// ====================================================================================
// 										 Implementation
// ====================================================================================

		// Assign DOT based on CNT value (combinational)
		assign DOT = (CNT == 2'b11) ? 1'b0 : 1'b1;

		//------------------------------
		//		 	Format Data
		//------------------------------
		// Assumes Format_Data module is modified to accept CLK and CLK_EN
		Format_Data FDATA(
				.CLK(CLK),           // Use primary clock
				.CLK_EN(clk_enable), // Use clock enable
				.RST(RST),
				.DIN(DIN),
				.BCDOUT(bcdData)
		);

		//-----------------------------------------------
		//					 Output Data Mux (Combinational)
		// 		Select data to display on SSD based on CNT
		//-----------------------------------------------
		// Sensitivity list includes all signals read within the block
		always @(CNT or bcdData or RST) // Changed sensitivity list, removed redundant CNT bits
			if (RST == 1'b1) // Asynchronous reset for muxData (can be synchronous if needed)
				muxData <= 4'b0000; // Consider if muxData needs reset
			else
				case (CNT)
					2'b00 : muxData <= bcdData[3:0];
					2'b01 : muxData <= bcdData[7:4];
					2'b10 : muxData <= bcdData[11:8];
					2'b11 : muxData <= bcdData[15:12];
					default : muxData <= 4'b0000; // Default assignment
				endcase

		//------------------------------
		//		   Segment Decoder
		// Determines cathode pattern
		//   to display digit on SSD
		//------------------------------
		// Changed clock from DCLK to CLK, added clock enable condition
		always @(posedge CLK or posedge RST)
			if (RST == 1'b1)
				SEG <= 7'b1000000; // Reset state for SEG (display '0')
			else if (clk_enable) begin // Update only when enabled
				case (muxData)
					4'h0 : SEG <= 7'b1000000;	   // 0
					4'h1 : SEG <= 7'b1111001;	   // 1
					4'h2 : SEG <= 7'b0100100;	   // 2
					4'h3 : SEG <= 7'b0110000;	   // 3
					4'h4 : SEG <= 7'b0011001;	   // 4
					4'h5 : SEG <= 7'b0010010;	   // 5
					4'h6 : SEG <= 7'b0000010;	   // 6
					4'h7 : SEG <= 7'b1111000;	   // 7
					4'h8 : SEG <= 7'b0000000;	   // 8
					4'h9 : SEG <= 7'b0010000;	   // 9
					4'hA : SEG <= 7'b0111111;	   // Minus
					4'hF : SEG <= 7'b1111111;	   // Off
					default : SEG <= 7'b1111111; // Default: Off
				endcase
			end
			// else SEG retains its previous value

		//---------------------------------
		//	  		  Anode Decoder
		//    Determines digit digit to
		//   illuminate for clock period
		//---------------------------------
		// Changed clock from DCLK to CLK, added clock enable condition
		always @(posedge CLK or posedge RST)
			if (RST == 1'b1)
				AN <= 4'b1111; // Reset state for AN (all off)
			else if (clk_enable) begin // Update only when enabled
				case (CNT)
					2'b00 : AN <= 4'b1110; 	 // Digit 0 active
					2'b01 : AN <= 4'b1101; 	 // Digit 1 active
					2'b10 : AN <= 4'b1011; 	 // Digit 2 active
					2'b11 : AN <= 4'b0111; 	 // Digit 3 active
					default : AN <= 4'b1111; // Default: All off
				endcase
			end
			// else AN retains its previous value

		//------------------------------
		//			2 Bit Counter
		//	 Used to select which digit
		//	  is being illuminated, and
		//	selects data to be displayed
		//------------------------------
		// Changed clock from DCLK to CLK, added clock enable condition, added reset
		always @(posedge CLK or posedge RST) begin
				if (RST == 1'b1) begin
					CNT <= 2'b00;
				end else if (clk_enable) begin // Increment only when enabled
					CNT <= CNT + 1'b1;
				end
				// else CNT retains its previous value
		end

		//------------------------------
		//			Clock Divider & Enable Generator
		//  Generates enable pulse approx every 1ms (based on cntEndVal)
		//------------------------------
		// Generate clock enable signal (combinational)
		assign clk_enable = (clkCount == cntEndVal);

		// Counter logic clocked by primary CLK
		always @(posedge CLK or posedge RST) begin
				if (RST == 1'b1) begin
					clkCount <= 16'h0000;
				end else begin
					if (clkCount == cntEndVal) begin // Check if count reached end value
						clkCount <= 16'h0000;     // Reset counter
					end else begin
						clkCount <= clkCount + 1'b1; // Increment counter
					end
				end
		end
		// Removed DCLK generation logic

endmodule