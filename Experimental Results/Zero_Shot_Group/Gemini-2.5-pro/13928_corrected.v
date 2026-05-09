////////////////////////////////////////////////////////////////////////////////
// Project Name:	CoCo3FPGA Version 3.0
// File Name:		cocokey.v (Corrected ps2_keyboard module)
//
// CoCo3 in an FPGA
//
// Revision: 3.0 08/15/15 - Corrected and implemented ps2_keyboard module
////////////////////////////////////////////////////////////////////////////////
//
// CPU section copyrighted by John Kent
// The FDC co-processor copyrighted by Daniel Wallner.
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
////////////////////////////////////////////////////////////////////////////////
// Gary Becker
// gary_L_becker@yahoo.com
////////////////////////////////////////////////////////////////////////////////


module	ps2_keyboard (
	input           reset_n,    // System Reset, active low
	input           clk,        // System clock
	inout           ps2_clk,    // PS/2 Clock (bi-directional, requires external pull-up)
	inout           ps2_data,   // PS/2 Data (bi-directional, requires external pull-up)
	output reg [7:0] rx_scan,   // Received scan code (make or break code)
	output reg      rx_pressed, // Key pressed ('1') or released ('0')
	output reg      rx_extended // Extended scan code flag ('1' if preceded by E0)
);

    // Internal signals for PS/2 lines (read values)
    wire ps2_clk_in;
    wire ps2_data_in;

    // PS/2 lines are open-drain, usually pulled high externally.
    // We only drive them low or let them float (high-impedance).
    // For a simple receiver, we mostly listen. Set to high-impedance ('z').
    // If sending commands (e.g., set LEDs) is needed, add tristate logic.
    assign ps2_clk = 1'bz;
    assign ps2_data = 1'bz;

    // Synchronize and filter PS/2 inputs to system clock domain
    // Simple 3-stage synchronizer for metastability hardening and basic filtering
    reg [2:0] ps2_clk_sync;
    reg [2:0] ps2_data_sync;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ps2_clk_sync <= 3'b111;
            ps2_data_sync <= 3'b111;
        end else begin
            ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
            ps2_data_sync <= {ps2_data_sync[1:0], ps2_data};
        end
    end

    // Use the synchronized/filtered versions (middle flop output)
    assign ps2_clk_in = ps2_clk_sync[1];
    assign ps2_data_in = ps2_data_sync[1];

    // Edge detection for PS/2 clock (falling edge)
    reg ps2_clk_prev;
    wire ps2_clk_falling_edge;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ps2_clk_prev <= 1'b1;
        end else begin
            ps2_clk_prev <= ps2_clk_in;
        end
    end
    assign ps2_clk_falling_edge = ps2_clk_prev & ~ps2_clk_in;

    // PS/2 Receiver State Machine
    typedef enum logic [2:0] {
        IDLE,       // Waiting for start bit
        START,      // Start bit detected (though we transition directly to DATA)
        DATA,       // Receiving data bits (0-7)
        PARITY,     // Receiving parity bit
        STOP        // Receiving stop bit
    } ps2_state_t;

    reg ps2_state;
    reg [3:0] bit_count;      // Counts received bits (0-7 data, 8 parity, 9 stop)
    reg [9:0] rx_shift_reg;   // Shift register for incoming bits: [9]=Stop, [8]=Parity, [7:0]=Data
    reg rx_parity_error;
    reg rx_stop_error;
    reg [7:0] received_byte;      // Latched received data byte
    reg received_byte_valid;  // Flag indicating a valid byte was received in the last cycle

    // Internal flags for scan code processing state
    reg internal_extended; // Set when 0xE0 is received
    reg internal_release;  // Set when 0xF0 is received

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ps2_state <= IDLE;
            bit_count <= 4'd0;
            rx_shift_reg <= 10'd0;
            received_byte_valid <= 1'b0;
            rx_parity_error <= 1'b0;
            rx_stop_error <= 1'b0;
            received_byte <= 8'd0;
            // Initialize processing flags and outputs
            internal_extended <= 1'b0;
            internal_release <= 1'b0;
            rx_scan <= 8'd0;
            rx_pressed <= 1'b0;
            rx_extended <= 1'b0;
        end else begin
            // Default: clear valid flag after one cycle
            received_byte_valid <= 1'b0;

            if (ps2_clk_falling_edge) begin // Sample data on falling edge of PS/2 clock
                case (ps2_state)
                    IDLE: begin
                        if (~ps2_data_in) begin // Start bit detected (is low)
                            ps2_state <= DATA;
                            bit_count <= 4'd0;
                            rx_shift_reg <= 10'd0; // Clear shift register
                            rx_parity_error <= 1'b0;
                            rx_stop_error <= 1'b0;
                        end
                        // else: Stay in IDLE if start bit is not low
                    end
                    DATA: begin
                        rx_shift_reg[bit_count] <= ps2_data_in; // Shift in data bit (LSB first)
                        if (bit_count == 7) begin
                            ps2_state <= PARITY;
                            bit_count <= bit_count + 1; // Advance counter to 8 for parity bit
                        end else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                    PARITY: begin
                         rx_shift_reg[8] <= ps2_data_in; // Store parity bit
                         // Check parity (odd parity: data bits + parity bit should have odd number of 1s)
                         if (^({rx_shift_reg[7:0], ps2_data_in}) == 1'b1) begin // Check if XOR sum is 1 (odd number of 1s)
                             rx_parity_error <= 1'b0; // Parity OK
                         end else begin
                             rx_parity_error <= 1'b1; // Parity Error
                         end
                         ps2_state <= STOP;
                         bit_count <= bit_count + 1; // Advance counter to 9 for stop bit
                    end
                    STOP: begin
                        rx_shift_reg[9] <= ps2_data_in; // Store stop bit
                        if (ps2_data_in) begin // Stop bit should be high
                            rx_stop_error <= 1'b0; // Stop bit OK
                            // If no errors, process the byte
                            if (!rx_parity_error) begin
                                received_byte <= rx_shift_reg[7:0]; // Data bits are [7:0]
                                received_byte_valid <= 1'b1;        // Signal valid byte received
                            end
                            // else: Parity error occurred, ignore byte
                        end else begin // Stop bit error (low instead of high)
                            rx_stop_error <= 1'b1;
                            // Ignore byte due to stop bit error
                        end
                        ps2_state <= IDLE; // Return to idle regardless of stop bit status
                        bit_count <= 4'd0;
                    end
                    default: ps2_state <= IDLE; // Should not happen
                endcase
            end // if ps2_clk_falling_edge
        end // else: !if(!reset_n)
    end // always @ receiver state machine

    // Scan Code Processing Logic
    // Processes the received byte to determine scan code, press/release, and extended status
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rx_scan <= 8'd0;
            rx_pressed <= 1'b0;
            rx_extended <= 1'b0;
            internal_extended <= 1'b0;
            internal_release <= 1'b0;
        end else begin
            if (received_byte_valid) begin
                // Process the newly received valid byte
                if (received_byte == 8'hE0) begin
                    // Extended code prefix detected
                    internal_extended <= 1'b1;
                    internal_release <= 1'b0; // Reset release flag if E0 sequence starts
                    // Do not output scan code for the prefix itself
                end else if (received_byte == 8'hF0) begin
                    // Release code prefix detected
                    internal_release <= 1'b1;
                    // Keep internal_extended if it was set (for E0 F0 sequences)
                    // Do not output scan code for the prefix itself
                end else begin
                    // This is an actual scan code (make or break)
                    rx_scan <= received_byte;         // Output the scan code
                    rx_extended <= internal_extended; // Output extended status
                    rx_pressed <= ~internal_release;  // Output pressed status (pressed if NOT preceded by F0)

                    // Reset flags for the next scan code sequence
                    internal_extended <= 1'b0;
                    internal_release <= 1'b0;
                end
            end
            // else: No new valid byte received, hold the previous output values.
            // Consider adding an explicit rx_valid output signal if needed by downstream logic.
        end
    end // always @ scan code processing

endmodule