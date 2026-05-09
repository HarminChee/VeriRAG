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
    input clk,
    input rst,

    // Wishbone slave interface
    input      [7:0] wb_dat_i,
    output reg [7:0] wb_dat_o,
    input            wb_we_i,
    input            wb_stb_i,
    input            wb_cyc_i,
    output           wb_ack_o,

    // Clocks
    input clk_100M,
    input clk_25M,
    input timer2,

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
  // Assumes speaker_iface and speaker_i2c_av_config modules are defined elsewhere
  speaker_iface iface (
    .clk_i         (clk_100M),
    .rst_i         (rst),
    .datal_i       (audio_l),
    .datar_i       (audio_r),
    .datal_o       (), // Assuming output not needed
    .datar_o       (), // Assuming output not needed
    .ready_o       (), // Assuming output not needed
    .aud_bclk_i    (aud_bclk_),
    .aud_daclrck_i (aud_daclrck_),
    .aud_dacdat_o  (aud_dacdat_),
    .aud_adcdat_i  (aud_adcdat_)
  );

  speaker_i2c_av_config i2c_av_config (
    // Host Side
    .clk_i (clk_25M),
    .rst_i (rst),

    // I2C Side
    .i2c_sclk (i2c_sclk_),
    .i2c_sdat (i2c_sdat_)
  );

  // Combinatorial logic
  // System speaker enable logic
  assign spk = timer2 & wb_dat_o[1];

  // System speaker audio output generation (simple square wave)
  // Centered around mid-point (0x4000) to avoid large DC offset if possible
  // Actual output depends on DAC range and configuration.
  assign audio_l = spk ? 16'hC000 : 16'h4000; // Example high/low values
  assign audio_r = spk ? 16'hC000 : 16'h4000; // Example high/low values

  // Wishbone signals
  assign wb_ack_o = wb_stb_i & wb_cyc_i; // Simple single-cycle ACK
  assign write    = wb_stb_i & wb_cyc_i & wb_we_i;

  // Sequential logic for Wishbone data output register
  always @(posedge clk or posedge rst) begin // Use asynchronous reset if rst is async, else synchronous
    if (rst) begin
      wb_dat_o <= 8'h0;
    end else begin
      if (write) begin
        wb_dat_o <= wb_dat_i;
      end
      // else: retain previous value (implicit)
    end
  end

endmodule