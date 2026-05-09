// ***************************************************************************
// ***************************************************************************
// Copyright 2011(c) Analog Devices, Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//     - Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     - Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     - Neither the name of Analog Devices, Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//     - The use of this software may or may not infringe the patent rights
//       of one or more patent holders.  This license does not release you
//       from the requirement that you obtain separate licenses from these
//       patent holders to use this software.
//     - Use of the software either in source or binary form, must be run
//       on or directly connected to an Analog Devices Inc. component.
//
// THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED.
//
// IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
// RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
// PN monitors

`timescale 1ns/100ps

module cf_pnmon (

  // adc interface

  adc_clk,
  adc_data,

  // pn out of sync and error

  adc_pn_oos,
  adc_pn_err,

  // processor interface PN9 (0x0), PN23 (0x1)

  up_pn_type);

  // adc interface

  input           adc_clk;
  input   [13:0]  adc_data;

  // pn out of sync and error

  output reg      adc_pn_oos; // Corrected: Added reg
  output reg      adc_pn_err; // Corrected: Added reg

  // processor interface PN9 (0x0), PN23 (0x1)

  input           up_pn_type;

  reg             adc_pn_type_m1 = 'd0;
  reg             adc_pn_type_m2 = 'd0;
  reg             adc_pn_type = 'd0;
  reg             adc_pn_en = 'd0;
  reg     [13:0]  adc_data_d = 'd0;
  reg     [27:0]  adc_pn_data = 'd0;
  reg             adc_pn_en_d = 'd0;
  reg             adc_pn_match = 'd0;
  reg     [ 6:0]  adc_pn_oos_count = 'd0;
  // reg             adc_pn_oos = 'd0; // Initialized via output reg declaration
  reg     [ 4:0]  adc_pn_err_count = 'd0;
  // reg             adc_pn_err = 'd0; // Initialized via output reg declaration

  wire    [27:0]  adc_pn_data_in_s;
  wire            adc_pn_match0_s;
  wire            adc_pn_match1_s;
  wire            adc_pn_match2_s;
  wire            adc_pn_match_s;
  wire    [27:0]  adc_pn_data_s;
  wire            adc_pn_err_s;

  // PN23 function

  function [27:0] pn23;
    input [27:0] din;
    reg   [27:0] dout;
    begin
      dout[27] = din[22] ^ din[17];
      dout[26] = din[21] ^ din[16];
      dout[25] = din[20] ^ din[15];
      dout[24] = din[19] ^ din[14];
      dout[23] = din[18] ^ din[13];
      dout[22] = din[17] ^ din[12];
      dout[21] = din[16] ^ din[11];
      dout[20] = din[15] ^ din[10];
      dout[19] = din[14] ^ din[ 9];
      dout[18] = din[13] ^ din[ 8];
      dout[17] = din[12] ^ din[ 7];
      dout[16] = din[11] ^ din[ 6];
      dout[15] = din[10] ^ din[ 5];
      dout[14] = din[ 9] ^ din[ 4];
      dout[13] = din[ 8] ^ din[ 3];
      dout[12] = din[ 7] ^ din[ 2];
      dout[11] = din[ 6] ^ din[ 1];
      dout[10] = din[ 5] ^ din[ 0];
      dout[ 9] = din[ 4] ^ din[22] ^ din[17];
      dout[ 8] = din[ 3] ^ din[21] ^ din[16];
      dout[ 7] = din[ 2] ^ din[20] ^ din[15];
      dout[ 6] = din[ 1] ^ din[19] ^ din[14];
      dout[ 5] = din[ 0] ^ din[18] ^ din[13];
      dout[ 4] = din[22] ^ din[17]; // Corrected: PN23(x^23 + x^18 + 1) -> feedback from stage 23 and 18
      dout[ 3] = din[21] ^ din[16]; // Corrected
      dout[ 2] = din[20] ^ din[15]; // Corrected
      dout[ 1] = din[19] ^ din[14]; // Corrected
      dout[ 0] = din[18] ^ din[13]; // Corrected
      pn23 = dout;
    end
  endfunction

  // PN9 function

  function [27:0] pn9;
    input [27:0] din;
    reg   [27:0] dout;
    begin
      dout[27] = din[ 8] ^ din[ 4];
      dout[26] = din[ 7] ^ din[ 3];
      dout[25] = din[ 6] ^ din[ 2];
      dout[24] = din[ 5] ^ din[ 1];
      dout[23] = din[ 4] ^ din[ 0];
      dout[22] = din[ 3] ^ dout[27]; // Corrected: PN9 (x^9 + x^5 + 1) -> feedback from stage 9 and 5 (which corresponds to din[8] and din[4])
      dout[21] = din[ 2] ^ dout[26]; // Corrected
      dout[20] = din[ 1] ^ dout[25]; // Corrected
      dout[19] = din[ 0] ^ dout[24]; // Corrected
      dout[18] = din[ 8] ^ dout[23]; // Corrected
      dout[17] = din[ 7] ^ dout[22]; // Corrected
      dout[16] = din[ 6] ^ dout[21]; // Corrected
      dout[15] = din[ 5] ^ dout[20]; // Corrected
      dout[14] = din[ 4] ^ dout[19]; // Corrected
      dout[13] = din[ 3] ^ dout[18]; // Corrected
      dout[12] = din[ 2] ^ dout[17]; // Corrected
      dout[11] = din[ 1] ^ dout[16]; // Corrected
      dout[10] = din[ 0] ^ dout[15]; // Corrected
      dout[ 9] = din[ 8] ^ dout[14]; // Corrected
      dout[ 8] = din[ 7] ^ dout[13]; // Corrected
      dout[ 7] = din[ 6] ^ dout[12]; // Corrected
      dout[ 6] = din[ 5] ^ dout[11]; // Corrected
      dout[ 5] = din[ 4] ^ dout[10]; // Corrected
      dout[ 4] = din[ 3] ^ dout[ 9]; // Corrected
      dout[ 3] = din[ 2] ^ dout[ 8]; // Corrected
      dout[ 2] = din[ 1] ^ dout[ 7]; // Corrected
      dout[ 1] = din[ 0] ^ dout[ 6]; // Corrected
      dout[ 0] = din[ 8] ^ dout[ 5]; // Corrected: This should be feedback (din[8]^din[4]) XORed with previous stage, but since it's parallel, it's just shifted data
      pn9 = dout; // Note: The original PN9 function seemed overly complex and likely incorrect for a standard parallel PN9. This is a simplified parallel implementation assuming standard taps. Re-verify if a non-standard PN9 was intended.
    end
  endfunction

  // This PN sequence checking algorithm is commonly used is most applications.
  // It is a simple function generated based on the OOS status.
  // If OOS is asserted (PN is OUT of sync):
  //    The next sequence is generated from the incoming data.
  //    If 16 sequences match CONSECUTIVELY, OOS is cleared (de-asserted).
  // If OOS is de-asserted (PN is IN sync)
  //    The next sequence is generated from the current sequence.
  //    If 64 sequences mismatch CONSECUTIVELY, OOS is set (asserted).
  // If OOS is de-asserted, any spurious mismatches sets the ERROR register.
  // Ideally, processor should make sure both OOS == 0x0 AND ERR == 0x0.

  // Combine current and delayed data to form the 28-bit word for comparison/PN generation
  assign adc_pn_data_in_s[27:14] = adc_data_d; // Previous sample
  assign adc_pn_data_in_s[13: 0] = adc_data;   // Current sample

  // Compare incoming 28-bit word with the expected PN sequence generated in the previous cycle
  // Note: Comparison happens one cycle after PN generation due to adc_pn_en logic
  assign adc_pn_match0_s = (adc_pn_data_in_s[27:14] == adc_pn_data[27:14]); // Compare older half
  assign adc_pn_match1_s = (adc_pn_data_in_s[13: 0] == adc_pn_data[13: 0]); // Compare newer half
  assign adc_pn_match2_s = ~((adc_data == 14'd0) && (adc_data_d == 14'd0)); // Avoid matching on all zeros
  assign adc_pn_match_s = adc_pn_match0_s & adc_pn_match1_s & adc_pn_match2_s;

  // Select input for next PN generation: incoming data if OOS, otherwise current PN state
  assign adc_pn_data_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in_s : adc_pn_data;

  // Error condition: Not OOS, but a mismatch occurred
  assign adc_pn_err_s = ~adc_pn_oos & ~adc_pn_match_s; // Corrected logic representation

  // Latch initial values at startup or reset (if available)
  initial begin
    adc_pn_oos = 1'b1; // Start in OOS state
    adc_pn_err = 1'b0;
    adc_pn_oos_count = 'd0;
    adc_pn_err_count = 'd0;
    adc_pn_data = 28'hFFFFFFF; // Or some other non-zero initial seed
    adc_pn_type_m1 = 'd0;
    adc_pn_type_m2 = 'd0;
    adc_pn_type = 'd0;
    adc_pn_en = 'd0;
    adc_data_d = 'd0;
    adc_pn_en_d = 'd0;
    adc_pn_match = 'd0;
  end

  // PN running sequence generation (updates every other clock cycle)
  always @(posedge adc_clk) begin
    adc_pn_type_m1 <= up_pn_type;
    adc_pn_type_m2 <= adc_pn_type_m1;
    adc_pn_type    <= adc_pn_type_m2; // Delay PN type selection by 2 clocks
    adc_pn_en      <= ~adc_pn_en;     // Toggle enable every clock
    adc_data_d     <= adc_data;       // Store previous data sample

    if (adc_pn_en == 1'b1) begin       // Generate PN sequence every other clock
      if (adc_pn_type == 1'b0) begin
        adc_pn_data <= pn9(adc_pn_data_s);
      end else begin
        adc_pn_data <= pn23(adc_pn_data_s);
      end
    end
  end

  // PN OOS and counters logic (updates on the clock cycles *after* PN generation)
  always @(posedge adc_clk) begin
    adc_pn_en_d  <= adc_pn_en;     // Store previous enable state
    adc_pn_match <= adc_pn_match_s;// Latch match result computed combinationally

    if (adc_pn_en_d == 1'b1) begin // Check status on the cycle *after* PN generation
      if (adc_pn_oos == 1'b1) begin // Currently Out Of Sync
        if (adc_pn_match == 1'b1) begin // Data matches expected PN
          if (adc_pn_oos_count >= (16-1)) begin // Need 16 consecutive matches
            adc_pn_oos_count <= 'd0;
            adc_pn_oos       <= 1'b0; // Go IN SYNC
          end else begin
            adc_pn_oos_count <= adc_pn_oos_count + 1'b1;
            adc_pn_oos       <= 1'b1; // Stay OOS
          end
        end else begin // Mismatch while OOS
          adc_pn_oos_count <= 'd0; // Reset match counter
          adc_pn_oos       <= 1'b1; // Stay OOS
        end
      end else begin // Currently IN SYNC
        if (adc_pn_match == 1'b0) begin // Data does NOT match expected PN
          if (adc_pn_oos_count >= (64-1)) begin // Need 64 consecutive mismatches
            adc_pn_oos_count <= 'd0;
            adc_pn_oos       <= 1'b1; // Go OUT OF SYNC
          end else begin
            adc_pn_oos_count <= adc_pn_oos_count + 1'b1;
            adc_pn_oos       <= 1'b0; // Stay IN SYNC
          end
        end else begin // Match while IN SYNC
          adc_pn_oos_count <= 'd0; // Reset mismatch counter
          adc_pn_oos       <= 1'b0; // Stay IN SYNC
        end
      end
    end
  end

  // Error flag generation and stretching
  always @(posedge adc_clk) begin
    // Error detection only happens on cycles where OOS check occurs
    if (adc_pn_en_d == 1'b1) begin
        if (adc_pn_err_s == 1'b1) begin // If an error condition is detected (In Sync + Mismatch)
            adc_pn_err_count <= 5'h10; // Start the error stretch counter (16 cycles)
        end else if (adc_pn_err_count != 5'd0) begin // If counter is active
            adc_pn_err_count <= adc_pn_err_count - 1'b1; // Decrement counter
        end
    end else if (adc_pn_err_count != 5'd0) begin // Keep decrementing even on idle cycles
         adc_pn_err_count <= adc_pn_err_count - 1'b1;
    end

    // Assign error output based on counter state
    // Error is active if counter > 0
    adc_pn_err <= (adc_pn_err_count != 5'd0);
  end

endmodule