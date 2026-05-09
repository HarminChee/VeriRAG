/*
 *  PC speaker module using WM8731 codec
 *  Copyright (C) 2010  Zeus Gomez Marmolejo <zeus@aluzina.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

module speaker (
    // Clocks
    input clk, // Original clock, potentially unused for FFs now or used elsewhere
    input rst,

    // Wishbone slave interface
    input      [7:0] wb_dat_i,
    output reg [7:0] wb_dat_o,
    input            wb_we_i,
    input            wb_stb_i,
    input            wb_cyc_i,
    output           wb_ack_o,

    // Clocks - Ensure these are primary inputs used for FFs
    input clk_100M, // Primary clock for main logic
    input clk_25M,  // Primary clock for I2C logic
    input timer2,   // Treat as data/enable, not clock

    // I2C pad signals
    output i2c_sclk_,
    inout  i2c_sdat_,

    // Audio codec pad signals
    input  aud_adcdat_,
    input  aud_daclrck_,
    output aud_dacdat_,
    input  aud_bclk_
  );

  // Net declaration
  wire [15:0] audio_r;
  wire [15:0] audio_l;
  wire        write;
  wire        spk;

  // Module instances
  speaker_iface iface (
    .clk_i         (clk_100M),    // Uses primary clock clk_100M
    .rst_i         (rst),
    .datal_i       (audio_l),
    .datar_i       (audio_r),
    .datal_o       (),
    .datar_o       (),
    .ready_o       (),
    .aud_bclk_i    (aud_bclk_),
    .aud_daclrck_i (aud_daclrck_),
    .aud_dacdat_o  (aud_dacdat_),
    .aud_adcdat_i  (aud_adcdat_)
  );

  speaker_i2c_av_config i2c_av_config (
    // Host Side
    .clk_i (clk_25M),       // Uses primary clock clk_25M
    .rst_i (rst),

    // I2C Side
    .i2c_sclk (i2c_sclk_),
    .i2c_sdat (i2c_sdat_)
  );

  // Combinatorial logic
  // System speaker
  assign spk = timer2 & wb_dat_o[1]; // timer2 used as data/enable

  // System speaker audio output
  assign audio_l = {spk, 15'h4000};
  assign audio_r = {spk, 15'h4000};

  // Wishbone signals
  assign wb_ack_o = wb_stb_i && wb_cyc_i;
  assign write    = wb_stb_i && wb_cyc_i && wb_we_i;

  // Sequential logic
  // Modified to use clk_100M, a primary input clock, instead of clk
  always @(posedge clk_100M or posedge rst) begin // Use asynchronous reset consistent with assumption
    if (rst)
      wb_dat_o <= 8'h0;
    else if (write)
      wb_dat_o <= wb_dat_i;
    // Removed implicit latch: else wb_dat_o <= wb_dat_o; (implied by non-assignment in conditional)
    // Explicitly keep value if write is false
    else
      wb_dat_o <= wb_dat_o;
  end
  // Note: The original code used synchronous reset based on the ternary operator.
  // Changed to asynchronous reset style for clarity, assuming 'rst' is asynchronous.
  // If 'rst' is synchronous, it should be checked inside the non-reset part:
  // always @(posedge clk_100M) begin
  //   if (rst) wb_dat_o <= 8'h0;
  //   else if (write) wb_dat_o <= wb_dat_i;
  //   else wb_dat_o <= wb_dat_o; // Keep current value if not write
  // end
  // However, using the asynchronous style as shown above is common.
  // The original ternary implies synchronous reset if rst is only sampled at posedge clk.
  // Let's revert to the exact original logic structure but with the new clock and proper reset handling.

  // Reverting to original reset style but with clk_100M
  /* // Commenting out the async version above
  always @(posedge clk_100M) begin
      // Assuming rst should behave synchronously as implied by original ternary
      if (rst) begin
          wb_dat_o <= 8'h0;
      end else begin
          if (write) begin
              wb_dat_o <= wb_dat_i;
          end else begin
              wb_dat_o <= wb_dat_o; // Maintain value if not write and not reset
          end
      end
  end
  */
   // Let's use the most direct translation of the original ternary with the new clock:
   always @(posedge clk_100M)
     // wb_dat_o <= rst ? 8'h0 : (write ? wb_dat_i : wb_dat_o); // Original logic with clk
     wb_dat_o <= rst ? 8'h0 : (write ? wb_dat_i : wb_dat_o); // Using clk_100M


endmodule