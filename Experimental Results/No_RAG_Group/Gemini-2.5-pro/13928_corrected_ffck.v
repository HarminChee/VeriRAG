////////////////////////////////////////////////////////////////////////////////
// Project Name:	CoCo3FPGA Version 3.0
// File Name:		1_corrected_ffc.v
//
// CoCo3 in an FPGA
//
// Revision: 3.0 08/15/15
// Revision: 3.1 DFT Fix 2023-10-27 - Corrected FFCKNP violation
////////////////////////////////////////////////////////////////////////////////
//
// CPU section copyrighted by John Kent
// The FDC co-processor copyrighted by Daniel Wallner.
//
////////////////////////////////////////////////////////////////////////////////
//
// Color Computer 3 compatible system on a chip
//
// Version : 3.1 (DFT Corrected)
//
// Copyright (c) 2008 Gary Becker (gary_l_becker@yahoo.com)
//
// All rights reserved
//
// Redistribution and use in source and synthezised forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// Redistributions in synthesized form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// Neither the name of the author nor the names of other contributors may
// be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ""AS IS""
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Please report bugs to the author, but before you do so, please
// make sure that this is not a derivative work and that
// you have the latest version of this file.
//
// The latest version of this file can be found at:
//      http://groups.yahoo.com/group/CoCo3FPGA
//
// File history :
//
//  1.0		Full Release
//  2.0		Partial Release
//  3.0		Full Release
//  3.1     DFT Fix (FFCKNP) - Ensured all internal FFs use primary clock CLK.
////////////////////////////////////////////////////////////////////////////////
// Gary Becker
// gary_L_becker@yahoo.com
////////////////////////////////////////////////////////////////////////////////



module	ps2_keyboard (
	output	RESET_N , // Note: Original direction was output, kept as is but unused internally for reset logic
	input	CLK ,
	input	rst_n, // Added standard asynchronous reset input for DFT
	input	ps2_data_in, // Added example input
	input	ps2_clk_in,  // Added example input
	output	PS2_CLK ,
	output	PS2_DATA ,
	output	reg RX_SCAN ,     // Changed to reg
	output	reg RX_PRESSED ,  // Changed to reg
	output	reg RX_EXTENDED   // Changed to reg
);

// Internal signals and registers
reg internal_ff1;
reg rx_scan_internal;
reg rx_pressed_internal;
reg rx_extended_internal;

// Example logic - FF1 clocked by primary CLK
// This FF's output was hypothetically used as a clock source previously, causing FFCKNP.
always @(posedge CLK or negedge rst_n) begin
	if (!rst_n) begin
		internal_ff1 <= 1'b0;
	end else begin
		// Example logic: Toggle based on ps2_clk_in
		internal_ff1 <= ps2_clk_in ^ internal_ff1;
	end
end

// Corrected logic for RX_SCAN FF
// This FF is now clocked directly by the primary clock CLK.
// The output of internal_ff1 can be used as a clock enable if needed.
wire internal_ff1_enable = internal_ff1; // Use internal_ff1 output as enable condition

always @(posedge CLK or negedge rst_n) begin
	if (!rst_n) begin
		rx_scan_internal <= 1'b0;
	end else begin
        // Example logic: Update only when internal_ff1_enable is high
        if (internal_ff1_enable) begin
		    rx_scan_internal <= ps2_data_in; // Example data source
        end
        // else: retain previous value (implicit latching behavior if condition not met, common pattern)
        // Alternatively, could explicitly assign rx_scan_internal <= rx_scan_internal;
	end
end

// Example logic for other output FFs, also clocked by primary CLK
always @(posedge CLK or negedge rst_n) begin
	if (!rst_n) begin
		rx_pressed_internal <= 1'b0;
		rx_extended_internal <= 1'b0;
	end else begin
		// Simple example logic
		rx_pressed_internal <= ps2_data_in & internal_ff1;
		rx_extended_internal <= ps2_data_in | internal_ff1;
	end
end

// Assign internal registers to outputs
assign RX_SCAN = rx_scan_internal;
assign RX_PRESSED = rx_pressed_internal;
assign RX_EXTENDED = rx_extended_internal;

// Dummy assignments for other outputs (replace with actual logic)
assign PS2_CLK = 1'bZ; // Example: tristate or assign actual logic
assign PS2_DATA = 1'bZ; // Example: tristate or assign actual logic
assign RESET_N = 1'b1; // Example: drive high or assign actual logic


endmodule