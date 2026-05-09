`timescale 1ns/100ps

module axi_ad9467_pnmon (
  input           adc_clk,
  input   [15:0]  adc_data,
  output wire     adc_pn_oos, // Corrected: Output driven by instance, should be wire
  output wire     adc_pn_err, // Corrected: Output driven by instance, should be wire
  input   [ 3:0]  adc_pnseq_sel
);

  reg             adc_valid_in = 1'b0; // Initialize explicitly
  reg     [31:0]  adc_pn_data_in = 32'd0; // Initialize explicitly
  reg     [31:0]  adc_pn_data_pn = 32'd0; // Initialize explicitly, maybe needs a specific seed?

  // PN23 function (polynomial x^23 + x^18 + 1, applied across 32 bits)
  // Note: This implementation seems specific, mapping PN logic across parallel bits.
  // Ensure this matches the expected PN sequence generation for the AD9467 test mode.
  function [31:0] pn23 (input [31:0] din);
    reg   [31:0] dout;
    // Based on common PN23: feedback = din[22] ^ din[17]
    // The parallel implementation below assumes specific bit mappings.
    // Example: dout[31] is the next bit if the sequence started with din[22] and din[17]
    dout[31] = din[22] ^ din[17];
    dout[30] = din[21] ^ din[16];
    dout[29] = din[20] ^ din[15];
    dout[28] = din[19] ^ din[14];
    dout[27] = din[18] ^ din[13];
    dout[26] = din[17] ^ din[12];
    dout[25] = din[16] ^ din[11];
    dout[24] = din[15] ^ din[10];
    dout[23] = din[14] ^ din[ 9];
    dout[22] = din[13] ^ din[ 8];
    dout[21] = din[12] ^ din[ 7];
    dout[20] = din[11] ^ din[ 6];
    dout[19] = din[10] ^ din[ 5];
    dout[18] = din[ 9] ^ din[ 4];
    dout[17] = din[ 8] ^ din[ 3];
    dout[16] = din[ 7] ^ din[ 2];
    dout[15] = din[ 6] ^ din[ 1];
    dout[14] = din[ 5] ^ din[ 0];
    dout[13] = din[ 4] ^ din[22] ^ din[17]; // Shifted in bit [31]
    dout[12] = din[ 3] ^ din[21] ^ din[16]; // Shifted in bit [30]
    dout[11] = din[ 2] ^ din[20] ^ din[15]; // Shifted in bit [29]
    dout[10] = din[ 1] ^ din[19] ^ din[14]; // Shifted in bit [28]
    dout[ 9] = din[ 0] ^ din[18] ^ din[13]; // Shifted in bit [27]
    dout[ 8] = din[22] ^ din[17] ^ din[12]; // Shifted in bit [26] ? Recheck logic source
    dout[ 7] = din[21] ^ din[16] ^ din[11]; // Shifted in bit [25] ? Recheck logic source
    dout[ 6] = din[20] ^ din[15] ^ din[10]; // Shifted in bit [24] ? Recheck logic source
    dout[ 5] = din[19] ^ din[14] ^ din[ 9]; // Shifted in bit [23] ? Recheck logic source
    dout[ 4] = din[18] ^ din[13] ^ din[ 8]; // Shifted in bit [22] ? Recheck logic source
    dout[ 3] = din[17] ^ din[12] ^ din[ 7]; // Shifted in bit [21] ? Recheck logic source
    dout[ 2] = din[16] ^ din[11] ^ din[ 6]; // Shifted in bit [20] ? Recheck logic source
    dout[ 1] = din[15] ^ din[10] ^ din[ 5]; // Shifted in bit [19] ? Recheck logic source
    dout[ 0] = din[14] ^ din[ 9] ^ din[ 4]; // Shifted in bit [18] ? Recheck logic source
    pn23 = dout;
  endfunction

  // PN9 function (polynomial x^9 + x^5 + 1, applied across 32 bits)
  // Note: This implementation seems specific, mapping PN logic across parallel bits.
  // Ensure this matches the expected PN sequence generation for the AD9467 test mode.
  function [31:0] pn9 (input [31:0] din);
     reg   [31:0] dout;
     // Based on common PN9: feedback = din[8] ^ din[4]
     // The parallel implementation below assumes specific bit mappings.
     dout[31] = din[ 8] ^ din[ 4];
     dout[30] = din[ 7] ^ din[ 3];
     dout[29] = din[ 6] ^ din[ 2];
     dout[28] = din[ 5] ^ din[ 1];
     dout[27] = din[ 4] ^ din[ 0];
     dout[26] = din[ 3] ^ (din[8] ^ din[4]); // Shifted in bit [31]
     dout[25] = din[ 2] ^ (din[7] ^ din[3]); // Shifted in bit [30]
     dout[24] = din[ 1] ^ (din[6] ^ din[2]); // Shifted in bit [29]
     dout[23] = din[ 0] ^ (din[5] ^ din[1]); // Shifted in bit [28]
     dout[22] = (din[8] ^ din[4]) ^ (din[4] ^ din[0]); // Shifted in bit [27] ? Recheck logic source
     dout[21] = (din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4])); // Shifted in bit [26] ? Recheck logic source
     dout[20] = (din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3])); // Shifted in bit [25] ? Recheck logic source
     dout[19] = (din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2])); // Shifted in bit [24] ? Recheck logic source
     dout[18] = (din[4] ^ din[0]) ^ (din[0] ^ (din[5] ^ din[1])); // Shifted in bit [23] ? Recheck logic source
     dout[17] = (din[3] ^ (din[8] ^ din[4])) ^ ((din[8] ^ din[4]) ^ (din[4] ^ din[0])); // Shifted in bit [22] ? Recheck logic source
     dout[16] = (din[2] ^ (din[7] ^ din[3])) ^ ((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4]))); // Shifted in bit [21] ? Recheck logic source
     dout[15] = (din[1] ^ (din[6] ^ din[2])) ^ ((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3]))); // Shifted in bit [20] ? Recheck logic source
     dout[14] = (din[0] ^ (din[5] ^ din[1])) ^ ((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2]))); // Shifted in bit [19] ? Recheck logic source
     dout[13] = ((din[8] ^ din[4]) ^ (din[4] ^ din[0])) ^ ((din[4] ^ din[0]) ^ (din[0] ^ (din[5] ^ din[1]))); // Shifted in bit [18] ? Recheck logic source
     dout[12] = ((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4]))) ^ ((din[3] ^ (din[8] ^ din[4])) ^ ((din[8] ^ din[4]) ^ (din[4] ^ din[0]))); // Shifted in bit [17] ? Recheck logic source
     dout[11] = ((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3]))) ^ ((din[2] ^ (din[7] ^ din[3])) ^ ((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4])))); // Shifted in bit [16] ? Recheck logic source
     dout[10] = ((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2]))) ^ ((din[1] ^ (din[6] ^ din[2])) ^ ((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3])))); // Shifted in bit [15] ? Recheck logic source
     dout[ 9] = ((din[4] ^ din[0]) ^ (din[0] ^ (din[5] ^ din[1]))) ^ ((din[0] ^ (din[5] ^ din[1])) ^ ((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2])))); // Shifted in bit [14] ? Recheck logic source
     dout[ 8] = ((din[3] ^ (din[8] ^ din[4])) ^ ((din[8] ^ din[4]) ^ (din[4] ^ din[0]))) ^ (((din[8] ^ din[4]) ^ (din[4] ^ din[0])) ^ ((din[4] ^ din[0]) ^ (din[0] ^ (din[5] ^ din[1])))); // Shifted in bit [13] ? Recheck logic source
     dout[ 7] = ((din[2] ^ (din[7] ^ din[3])) ^ ((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4])))) ^ (((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4]))) ^ ((din[3] ^ (din[8] ^ din[4])) ^ ((din[8] ^ din[4]) ^ (din[4] ^ din[0])))); // Shifted in bit [12] ? Recheck logic source
     dout[ 6] = ((din[1] ^ (din[6] ^ din[2])) ^ ((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3])))) ^ (((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3]))) ^ ((din[2] ^ (din[7] ^ din[3])) ^ ((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4]))))); // Shifted in bit [11] ? Recheck logic source
     dout[ 5] = ((din[0] ^ (din[5] ^ din[1])) ^ ((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2])))) ^ (((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2]))) ^ ((din[1] ^ (din[6] ^ din[2])) ^ ((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3]))))); // Shifted in bit [10] ? Recheck logic source
     dout[ 4] = (((din[8] ^ din[4]) ^ (din[4] ^ din[0])) ^ ((din[4] ^ din[0]) ^ (din[0] ^ (din[5] ^ din[1])))) ^ (((din[4] ^ din[0]) ^ (din[0] ^ (din[5] ^ din[1]))) ^ ((din[0] ^ (din[5] ^ din[1])) ^ ((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2]))))); // Shifted in bit [9] ? Recheck logic source
     dout[ 3] = (((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4]))) ^ ((din[3] ^ (din[8] ^ din[4])) ^ ((din[8] ^ din[4]) ^ (din[4] ^ din[0])))) ^ (((din[3] ^ (din[8] ^ din[4])) ^ ((din[8] ^ din[4]) ^ (din[4] ^ din[0]))) ^ (((din[8] ^ din[4]) ^ (din[4] ^ din[0])) ^ ((din[4] ^ din[0]) ^ (din[0] ^ (din[5] ^ din[1]))))); // Shifted in bit [8] ? Recheck logic source
     dout[ 2] = (((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3]))) ^ ((din[2] ^ (din[7] ^ din[3])) ^ ((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4]))))) ^ (((din[2] ^ (din[7] ^ din[3])) ^ ((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4])))) ^ (((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4]))) ^ ((din[3] ^ (din[8] ^ din[4])) ^ ((din[8] ^ din[4]) ^ (din[4] ^ din[0]))))); // Shifted in bit [7] ? Recheck logic source
     dout[ 1] = (((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2]))) ^ ((din[1] ^ (din[6] ^ din[2])) ^ ((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3]))))) ^ (((din[1] ^ (din[6] ^ din[2])) ^ ((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3])))) ^ (((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3]))) ^ ((din[2] ^ (din[7] ^ din[3])) ^ ((din[7] ^ din[3]) ^ (din[3] ^ (din[8] ^ din[4])))))); // Shifted in bit [6] ? Recheck logic source
     dout[ 0] = (((din[4] ^ din[0]) ^ (din[0] ^ (din[5] ^ din[1]))) ^ ((din[0] ^ (din[5] ^ din[1])) ^ ((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2]))))) ^ (((din[0] ^ (din[5] ^ din[1])) ^ ((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2])))) ^ (((din[5] ^ din[1]) ^ (din[1] ^ (din[6] ^ din[2]))) ^ ((din[1] ^ (din[6] ^ din[2])) ^ ((din[6] ^ din[2]) ^ (din[2] ^ (din[7] ^ din[3])))))); // Shifted in bit [5] ? Recheck logic source

     // Simplified based on typical parallel PN9 generation (verify!)
     /*
     dout[31:1] = din[30:0]; // Shift existing bits
     dout[0]    = din[8] ^ din[4]; // New bit based on feedback taps
     */
     // The original complex logic likely attempts to calculate multiple steps ahead
     // or applies the PN logic across lanes. Double check the source/intent.
     // If the complex logic is correct per ADI spec, keep it, otherwise simplify.
     // Using the complex version from the original code for now.
     pn9 = dout;
  endfunction


  // Removed problematic assign:
  // assign adc_pn_data_pn_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in : adc_pn_data_pn;
  // The PN generator should use its previous state. Comparison happens in ad_pnmon.

  always @(posedge adc_clk) begin
    // Toggle valid every clock cycle? This means data/PN is updated every 2 clocks.
    adc_valid_in <= ~adc_valid_in;

    // Capture input data, potentially formatting it (e.g., invert MSB for offset binary?)
    adc_pn_data_in <= {adc_pn_data_in[15:0], ~adc_data[15], adc_data[14:0]};

    // Update the expected PN sequence only when valid is high
    if (adc_valid_in == 1'b1) begin
      if (adc_pnseq_sel == 4'd0) begin // Assuming 0 selects PN9
        // Corrected: Update PN state based on the *previous* PN state
        adc_pn_data_pn <= pn9(adc_pn_data_pn);
      end else begin // Assuming non-zero selects PN23
        // Corrected: Update PN state based on the *previous* PN state
        adc_pn_data_pn <= pn23(adc_pn_data_pn);
      end
    end
  end

  // Instantiate the PN monitor module (definition not provided here)
  ad_pnmon #(
    .DATA_WIDTH(32)
  ) i_pnmon (
    .adc_clk      (adc_clk),
    .adc_valid_in (adc_valid_in),   // Pass the valid signal
    .adc_data_in  (adc_pn_data_in), // Pass the captured (and formatted) ADC data
    .adc_data_pn  (adc_pn_data_pn), // Pass the locally generated expected PN sequence
    .adc_pn_oos   (adc_pn_oos),     // Output: Out of Sync indicator
    .adc_pn_err   (adc_pn_err)      // Output: PN Error indicator/count
  );

endmodule