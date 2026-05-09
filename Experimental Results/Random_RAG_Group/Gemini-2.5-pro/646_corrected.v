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
//                  Revision 0.02 - DFT Fixes Applied
///////////////////////////////////////////////////////////////////////////////////

//  ===================================================================================
//  								Define Module, Inputs and Outputs
//  ===================================================================================
module ssdCtrl(
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
   input            CLK; // Primary Clock Input
   input            RST; // Primary Reset Input (Active High)
   input [9:0]      DIN;
   output reg [3:0] AN; // Anode control FFs output
   output reg [6:0] SEG; // Segment control FFs output
   output           DOT;
   output wire [15:0] bcdData; // Output from Format_Data instance
   
// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
   
   // Counter for 1 kHz Clock Enable generation
   parameter [15:0] cntEndVal = 16'hC350; // Value for ~1kHz enable @ 50MHz CLK (adjust if CLK freq differs)
   reg [15:0]       clkCount;
   reg              CLK_EN; // Clock Enable Signal (replaces DCLK)
   
   // 2 Bit Counter for SSD digit selection
   reg [1:0]        CNT;
   
   // Binary Data to BCD "g" value format x.xx (output from FDATA)
   // wire [15:0]      bcdData; // Declared as output wire
   
   // Output Data Mux (Combinational)
   reg [3:0]        muxData;
   
// ====================================================================================
// 										 Implementation
// ====================================================================================
   
		// Assign DOT based on CNT value (Combinational)
		// DOT is active low for the display segment
		assign DOT = (CNT == 2'b10) ? 1'b0 : 1'b1; // Assuming DOT on 3rd digit (index 2)
		
		//------------------------------
		//		 	Format Data Instance
		//  (Assuming Format_Data uses CLK and RST, and CLK_EN if needed)
		//------------------------------
		Format_Data FDATA(
				.CLK(CLK),       // Pass primary clock
				// .DCLK(DCLK), // Original connection to internal clock removed
				.CLK_EN(CLK_EN), // Pass clock enable instead (if needed by Format_Data)
				.RST(RST),       // Pass primary reset
				.DIN(DIN),
				.BCDOUT(bcdData)
		);
		
		//-----------------------------------------------
		//					 Output Data Mux (Combinational)
		// 		Selects BCD data based on CNT value
		//-----------------------------------------------
		always @* // Use @* for combinational logic sensitivity
		begin
			if (RST) // Allow reset to clear muxData if intended (acts asynchronously here)
				muxData = 4'b0000;
			else
				case (CNT) // Use CNT directly
					2'b00 : muxData = bcdData[3:0];    // Digit 0 (LSB)
					2'b01 : muxData = bcdData[7:4];    // Digit 1
					2'b10 : muxData = bcdData[11:8];   // Digit 2
					2'b11 : muxData = bcdData[15:12];  // Digit 3 (MSB / Sign)
					default : muxData = 4'b0000;       // Default case
				endcase
		end // Use blocking assignments (=) in combinational blocks

		//------------------------------
		//		   Segment Decoder FF
		// Determines cathode pattern based on muxData
		// Clocked by CLK, Enabled by CLK_EN, Asynchronous Reset RST
		//------------------------------
		always @(posedge CLK or posedge RST) // Clocked by primary CLK, async reset RST
		begin
			if (RST) // Asynchronous reset condition
				SEG <= 7'b1000000; // Reset to '0' pattern
			else if (CLK_EN) // Update only when enabled
			begin
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
					4'hA : SEG <= 7'b0111111;	   // Minus sign (for BCD A)
					// 4'hF : SEG <= 7'b1111111;	// Off (or Blank) (for BCD F)
					default : SEG <= 7'b1111111; // Default to blank/off
				endcase
			end
		end // Use non-blocking assignments (<=) in sequential blocks
		
		//---------------------------------
		//	  		  Anode Decoder FF
		//    Selects active digit based on CNT
		// Clocked by CLK, Enabled by CLK_EN, Asynchronous Reset RST
		//---------------------------------
		always @(posedge CLK or posedge RST) // Clocked by primary CLK, async reset RST
		begin
			if (RST) // Asynchronous reset condition
				AN <= 4'b1111; // All anodes off
			else if (CLK_EN) // Update only when enabled
			begin
				case (CNT)
					2'b00 : AN <= 4'b1110; 	 // Activate Digit 0 (AN0 low)
					2'b01 : AN <= 4'b1101; 	 // Activate Digit 1 (AN1 low)
					2'b10 : AN <= 4'b1011; 	 // Activate Digit 2 (AN2 low)
					2'b11 : AN <= 4'b0111; 	 // Activate Digit 3 (AN3 low)
					default : AN <= 4'b1111; // Default: All off
				endcase
			end
		end // Use non-blocking assignments (<=) in sequential blocks
		
		//------------------------------
		//			2 Bit Counter FF
		//	 Cycles through 00, 01, 10, 11
		// Clocked by CLK, Enabled by CLK_EN, Asynchronous Reset RST
		//------------------------------
		always @(posedge CLK or posedge RST) // Clocked by primary CLK, async reset RST
		begin
		    if (RST) // Asynchronous reset condition
		        CNT <= 2'b00;
			else if (CLK_EN) // Increment only when enabled
				CNT <= CNT + 1'b1;
		end // Use non-blocking assignments (<=) in sequential blocks
		
		//------------------------------
		//			Clock Enable Generator (~1kHz)
		//  Generates CLK_EN pulse for one CLK cycle
		// Clocked by CLK, Synchronous Reset (using RST signal logic)
		//------------------------------
		always @(posedge CLK or posedge RST) // Use primary clock and reset
		begin
		    if (RST) begin // Reset condition
		        clkCount <= 16'h0000;
		        CLK_EN <= 1'b0; // Ensure enable is low on reset
		    end else begin
				if (clkCount == cntEndVal) begin
					CLK_EN <= 1'b1; // Assert enable for one clock cycle
					clkCount <= 16'h0000; // Reset counter
				end
				else begin
					CLK_EN <= 1'b0; // Deassert enable
					clkCount <= clkCount + 1'b1; // Increment counter
				end
			end
		end // Use non-blocking assignments (<=) in sequential blocks
   
endmodule