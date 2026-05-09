`timescale 1ns/100ps

module axi_ad9265_pnmon (
  input           adc_clk,
  input   [15:0]  adc_data,
  output          adc_pn_oos,
  output          adc_pn_err,
  input   [ 3:0]  adc_pnseq_sel
);

  reg             adc_valid_in = 1'b0;
  reg     [31:0]  adc_pn_data_in = 32'd0;
  reg     [31:0]  adc_pn_data_pn = 32'd0;
  wire    [31:0]  adc_pn_data_pn_s;

  // PN23 sequence generator function
  function [31:0] pn23 (input [31:0] din);
    begin
      pn23[31] = din[22] ^ din[17];
      pn23[30] = din[21] ^ din[16];
      pn23[29] = din[20] ^ din[15];
      pn23[28] = din[19] ^ din[14];
      pn23[27] = din[18] ^ din[13];
      pn23[26] = din[17] ^ din[12];
      pn23[25] = din[16] ^ din[11];
      pn23[24] = din[15] ^ din[10];
      pn23[23] = din[14] ^ din[ 9];
      pn23[22] = din[13] ^ din[ 8];
      pn23[21] = din[12] ^ din[ 7];
      pn23[20] = din[11] ^ din[ 6];
      pn23[19] = din[10] ^ din[ 5];
      pn23[18] = din[ 9] ^ din[ 4];
      pn23[17] = din[ 8] ^ din[ 3];
      pn23[16] = din[ 7] ^ din[ 2];
      pn23[15] = din[ 6] ^ din[ 1];
      pn23[14] = din[ 5] ^ din[ 0];
      pn23[13] = din[ 4] ^ din[22] ^ din[17];
      pn23[12] = din[ 3] ^ din[21] ^ din[16];
      pn23[11] = din[ 2] ^ din[20] ^ din[15];
      pn23[10] = din[ 1] ^ din[19] ^ din[14];
      pn23[ 9] = din[ 0] ^ din[18] ^ din[13];
      pn23[ 8] = din[22] ^ din[12]; // Feedback taps based on x^23+x^18+1 -> bits 22 and 17 (0-indexed)
      pn23[ 7] = din[21] ^ din[11];
      pn23[ 6] = din[20] ^ din[10];
      pn23[ 5] = din[19] ^ din[ 9];
      pn23[ 4] = din[18] ^ din[ 8];
      pn23[ 3] = din[17] ^ din[ 7];
      pn23[ 2] = din[16] ^ din[ 6];
      pn23[ 1] = din[15] ^ din[ 5];
      pn23[ 0] = din[14] ^ din[ 4];
    end
  endfunction

  // PN9 sequence generator function
  function [31:0] pn9 (input [31:0] din);
    begin
      pn9[31] = din[ 8] ^ din[ 4];
      pn9[30] = din[ 7] ^ din[ 3];
      pn9[29] = din[ 6] ^ din[ 2];
      pn9[28] = din[ 5] ^ din[ 1];
      pn9[27] = din[ 4] ^ din[ 0];
      pn9[26] = din[ 3] ^ din[ 8] ^ din[ 4]; // Feedback taps based on x^9+x^5+1 -> bits 8 and 4 (0-indexed)
      pn9[25] = din[ 2] ^ din[ 7] ^ din[ 3];
      pn9[24] = din[ 1] ^ din[ 6] ^ din[ 2];
      pn9[23] = din[ 0] ^ din[ 5] ^ din[ 1];
      pn9[22] = din[ 8] ^ din[ 0]; // Feedback taps based on x^9+x^5+1 -> bits 8 and 4 (0-indexed)
      pn9[21] = din[ 7] ^ din[ 8] ^ din[ 4];
      pn9[20] = din[ 6] ^ din[ 7] ^ din[ 3];
      pn9[19] = din[ 5] ^ din[ 6] ^ din[ 2];
      pn9[18] = din[ 4] ^ din[ 5] ^ din[ 1];
      pn9[17] = din[ 3] ^ din[ 4] ^ din[ 0];
      pn9[16] = din[ 2] ^ din[ 3] ^ din[ 8] ^ din[ 4];
      pn9[15] = din[ 1] ^ din[ 2] ^ din[ 7] ^ din[ 3];
      pn9[14] = din[ 0] ^ din[ 1] ^ din[ 6] ^ din[ 2];
      pn9[13] = din[ 8] ^ din[ 0] ^ din[ 4] ^ din[ 5] ^ din[ 1];
      pn9[12] = din[ 7] ^ din[ 8] ^ din[ 3] ^ din[ 0];
      pn9[11] = din[ 6] ^ din[ 7] ^ din[ 2] ^ din[ 8] ^ din[ 4];
      pn9[10] = din[ 5] ^ din[ 6] ^ din[ 1] ^ din[ 7] ^ din[ 3];
      pn9[ 9] = din[ 4] ^ din[ 5] ^ din[ 0] ^ din[ 6] ^ din[ 2];
      pn9[ 8] = din[ 3] ^ din[ 8] ^ din[ 5] ^ din[ 1]; // Feedback taps based on x^9+x^5+1 -> bits 8 and 4 (0-indexed)
      pn9[ 7] = din[ 2] ^ din[ 4] ^ din[ 7] ^ din[ 0];
      pn9[ 6] = din[ 1] ^ din[ 3] ^ din[ 6] ^ din[ 8] ^ din[ 4];
      pn9[ 5] = din[ 0] ^ din[ 2] ^ din[ 5] ^ din[ 7] ^ din[ 3];
      pn9[ 4] = din[ 8] ^ din[ 1] ^ din[ 6] ^ din[ 2]; // Feedback taps based on x^9+x^5+1 -> bits 8 and 4 (0-indexed)
      pn9[ 3] = din[ 7] ^ din[ 0] ^ din[ 5] ^ din[ 1];
      pn9[ 2] = din[ 6] ^ din[ 8] ^ din[ 0];
      pn9[ 1] = din[ 5] ^ din[ 7] ^ din[ 8] ^ din[ 4];
      pn9[ 0] = din[ 4] ^ din[ 6] ^ din[ 7] ^ din[ 3];
    end
  endfunction

  // Selects the input for the PN generator:
  // If out of sync (oos), use the incoming data to try and resync.
  // Otherwise, use the output of the PN generator itself.
  assign adc_pn_data_pn_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in : adc_pn_data_pn;

  always @(posedge adc_clk) begin
    // Toggle valid signal every clock cycle - PN check happens on alternate cycles
    adc_valid_in <= ~adc_valid_in;
    // Shift in new ADC data
    adc_pn_data_in <= {adc_pn_data_in[15:0], adc_data};

    // Update the internal PN sequence generator only when valid is high
    if (adc_valid_in == 1'b1) begin
      if (adc_pnseq_sel == 4'd0) begin // Assuming 4'd0 selects PN9
        adc_pn_data_pn <= pn9(adc_pn_data_pn_s);
      end else begin // Assuming any other value selects PN23
        adc_pn_data_pn <= pn23(adc_pn_data_pn_s);
      end
    end
  end

  // Instantiate the generic PN monitor module (assuming it's defined elsewhere)
  // This module compares adc_pn_data_in with adc_pn_data_pn when adc_valid_in is high
  ad_pnmon #(
    .DATA_WIDTH(32)
  ) i_pnmon (
    .adc_clk      (adc_clk),
    .adc_valid_in (adc_valid_in),    // PN check enable
    .adc_data_in  (adc_pn_data_in),  // Data received from ADC (shifted)
    .adc_data_pn  (adc_pn_data_pn),  // Locally generated PN sequence
    .adc_pn_oos   (adc_pn_oos),      // Output: Out Of Sync indicator
    .adc_pn_err   (adc_pn_err)       // Output: Error indicator (latched mismatch)
  );

endmodule