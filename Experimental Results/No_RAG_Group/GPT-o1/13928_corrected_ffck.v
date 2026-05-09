////////////////////////////////////////////////////////////////////////////////
// Project Name:	CoCo3FPGA Version 3.0
// File Name:		001_corrected_ffc.v
//
// CoCo3 in an FPGA
//
// Revision: 3.0 08/15/15
////////////////////////////////////////////////////////////////////////////////
//
// CPU section copyrighted by John Kent
// The FDC co-processor copyrighted Daniel Wallner.
//
////////////////////////////////////////////////////////////////////////////////
//
// Color Computer 3 compatible system on a chip
//
// Version : 3.0
//
// Copyright (c) 2008 Gary Becker (gary_l_becker@yahoo.com)
//
// All rights reserved
//
// Redistribution and use in source and synthesized forms, with or without
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
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
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
// The latest version of this file can be found at:
//	http://groups.yahoo.com/group/CoCo3FPGA
////////////////////////////////////////////////////////////////////////////////
// Modified code (001_corrected_ffc.v) for DFT compliance
////////////////////////////////////////////////////////////////////////////////

module ps2_keyboard (
	output	RESET_N ,
	input	CLK ,
	output	PS2_CLK ,
	output	PS2_DATA ,
	output	RX_SCAN ,
	output	RX_PRESSED ,
	output	RX_EXTENDED
);

// Ensuring no internally generated clocks (FFCKNP fix):
assign RESET_N      = 1'b1;
assign PS2_CLK      = CLK;
assign PS2_DATA     = 1'b0;
assign RX_SCAN      = 1'b0;
assign RX_PRESSED   = 1'b0;
assign RX_EXTENDED  = 1'b0;

endmodule