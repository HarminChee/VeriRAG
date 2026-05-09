`timescale 1ns/100ps

module axi_ad9643_pnmon (
  input           rst_n, // Added reset input
  input           adc_clk,
  input   [13:0]  adc_data,
  output          adc_pn_oos,
  output          adc_pn_err,
  input           adc_pn_type);

  reg             adc_pn_en;
  reg     [13:0]  adc_data_in;
  reg     [13:0]  adc_data_d;
  reg     [29:0]  adc_pn_data;
  reg             adc_pn_en_d;
  reg             adc_pn_match_d_1;
  reg             adc_pn_match_d_0;
  reg             adc_pn_match_z;
  reg             adc_pn_err;
  reg     [ 6:0]  adc_pn_oos_count;
  reg             adc_pn_oos;

  wire    [29:0]  adc_pn_data_in_s;
  wire            adc_pn_match_d_1_s;
  wire            adc_pn_match_d_0_s;
  wire            adc_pn_match_z_s;
  wire            adc_pn_match_s;
  wire    [29:0]  adc_pn_data_s;
  wire            adc_pn_update_s;
  wire            adc_pn_err_s;

  // PN23 generator function
  function [29:0] pn23;
    input [29:0] din;
    reg   [29:0] dout;
    begin
      dout[29] = din[22] ^ din[17];
      dout[28] = din[21] ^ din[16];
      dout[27] = din[20] ^ din[15];
      dout[26] = din[19] ^ din[14];
      dout[25] = din[18] ^ din[13];
      dout[24] = din[17] ^ din[12];
      dout[23] = din[16] ^ din[11];
      dout[22] = din[15] ^ din[10];
      dout[21] = din[14] ^ din[ 9];
      dout[20] = din[13] ^ din[ 8];
      dout[19] = din[12] ^ din[ 7];
      dout[18] = din[11] ^ din[ 6];
      dout[17] = din[10] ^ din[ 5];
      dout[16] = din[ 9] ^ din[ 4];
      dout[15] = din[ 8] ^ din[ 3];
      dout[14] = din[ 7] ^ din[ 2];
      dout[13] = din[ 6] ^ din[ 1];
      dout[12] = din[ 5] ^ din[ 0];
      dout[11] = din[ 4] ^ din[22] ^ din[17];
      dout[10] = din[ 3] ^ din[21] ^ din[16];
      dout[ 9] = din[ 2] ^ din[20] ^ din[15];
      dout[ 8] = din[ 1] ^ din[19] ^ din[14];
      dout[ 7] = din[ 0] ^ din[18] ^ din[13];
      dout[ 6] = din[22] ^ din[12]; // Corrected index: din[22] not din[29]
      dout[ 5] = din[21] ^ din[11]; // Corrected index: din[21] not din[28]
      dout[ 4] = din[20] ^ din[10]; // Corrected index: din[20] not din[27]
      dout[ 3] = din[19] ^ din[ 9]; // Corrected index: din[19] not din[26]
      dout[ 2] = din[18] ^ din[ 8]; // Corrected index: din[18] not din[25]
      dout[ 1] = din[17] ^ din[ 7]; // Corrected index: din[17] not din[24]
      dout[ 0] = din[16] ^ din[ 6]; // Corrected index: din[16] not din[23]
      pn23 = dout;
    end
  endfunction

  // PN9 generator function
  function [29:0] pn9;
    input [29:0] din;
    reg   [29:0] dout;
    begin
      dout[29] = din[ 8] ^ din[ 4];
      dout[28] = din[ 7] ^ din[ 3];
      dout[27] = din[ 6] ^ din[ 2];
      dout[26] = din[ 5] ^ din[ 1];
      dout[25] = din[ 4] ^ din[ 0];
      dout[24] = din[ 3] ^ din[ 8] ^ din[ 4];
      dout[23] = din[ 2] ^ din[ 7] ^ din[ 3];
      dout[22] = din[ 1] ^ din[ 6] ^ din[ 2];
      dout[21] = din[ 0] ^ din[ 5] ^ din[ 1];
      dout[20] = din[ 8] ^ din[ 0]; // Corrected index: din[8] not din[15]
      dout[19] = din[ 7] ^ din[ 8] ^ din[ 4]; // Corrected index: din[7], din[8], din[4]
      dout[18] = din[ 6] ^ din[ 7] ^ din[ 3]; // Corrected index: din[6], din[7], din[3]
      dout[17] = din[ 5] ^ din[ 6] ^ din[ 2]; // Corrected index: din[5], din[6], din[2]
      dout[16] = din[ 4] ^ din[ 5] ^ din[ 1]; // Corrected index: din[4], din[5], din[1]
      dout[15] = din[ 3] ^ din[ 4] ^ din[ 0]; // Corrected index: din[3], din[4], din[0]
      dout[14] = din[ 2] ^ din[ 3] ^ din[ 8] ^ din[ 4]; // Corrected index: din[2], din[3], din[8], din[4]
      dout[13] = din[ 1] ^ din[ 2] ^ din[ 7] ^ din[ 3]; // Corrected index: din[1], din[2], din[7], din[3]
      dout[12] = din[ 0] ^ din[ 1] ^ din[ 6] ^ din[ 2]; // Corrected index: din[0], din[1], din[6], din[2]
      dout[11] = din[ 8] ^ din[ 4] ^ din[ 5] ^ din[ 1] ^ din[ 0]; // Corrected index: din[8], din[4], din[5], din[1], din[0]
      dout[10] = din[ 7] ^ din[ 3] ^ din[ 8] ^ din[ 0]; // Corrected index: din[7], din[3], din[8], din[0]
      dout[ 9] = din[ 6] ^ din[ 2] ^ din[ 7] ^ din[ 8] ^ din[ 4]; // Corrected index: din[6], din[2], din[7], din[8], din[4]
      dout[ 8] = din[ 5] ^ din[ 1] ^ din[ 6] ^ din[ 7] ^ din[ 3]; // Corrected index: din[5], din[1], din[6], din[7], din[3]
      dout[ 7] = din[ 4] ^ din[ 0] ^ din[ 5] ^ din[ 6] ^ din[ 2]; // Corrected index: din[4], din[0], din[5], din[6], din[2]
      dout[ 6] = din[ 8] ^ din[ 4] ^ din[ 3] ^ din[ 5] ^ din[ 1]; // Corrected index: din[8], din[4], din[3], din[5], din[1]
      dout[ 5] = din[ 7] ^ din[ 3] ^ din[ 2] ^ din[ 4] ^ din[ 0]; // Corrected index: din[7], din[3], din[2], din[4], din[0]
      dout[ 4] = din[ 6] ^ din[ 2] ^ din[ 1] ^ din[ 3] ^ din[ 8] ^ din[ 4]; // Corrected index: din[6], din[2], din[1], din[3], din[8], din[4]
      dout[ 3] = din[ 5] ^ din[ 1] ^ din[ 0] ^ din[ 2] ^ din[ 7] ^ din[ 3]; // Corrected index: din[5], din[1], din[0], din[2], din[7], din[3]
      dout[ 2] = din[ 4] ^ din[ 0] ^ din[ 8] ^ din[ 1] ^ din[ 6] ^ din[ 2]; // Corrected index: din[4], din[0], din[8], din[1], din[6], din[2]
      dout[ 1] = din[ 8] ^ din[ 4] ^ din[ 7] ^ din[ 0] ^ din[ 5] ^ din[ 1]; // Corrected index: din[8], din[4], din[7], din[0], din[5], din[1]
      dout[ 0] = din[ 7] ^ din[ 3] ^ din[ 6] ^ din[ 8] ^ din[ 0]; // Corrected index: din[7], din[3], din[6], din[8], din[0]
      pn9 = dout;
    end
  endfunction

  // Combine delayed and current data with PN bits for input check
  assign adc_pn_data_in_s[29:15] = {adc_pn_data[29], adc_data_d};
  assign adc_pn_data_in_s[14:0]  = {adc_pn_data[14], adc_data_in};

  // Check if parts of the incoming data match the expected PN sequence
  assign adc_pn_match_d_1_s = (adc_pn_data_in_s[28:15] == adc_pn_data[28:15]);
  assign adc_pn_match_d_0_s = (adc_pn_data_in_s[13:0]  == adc_pn_data[13:0]);
  // Check if the expected PN sequence is non-zero (avoids locking on all zeros)
  assign adc_pn_match_z_s   = (|adc_pn_data); // More robust check for non-zero

  // Combined match signal (requires both halves to match and PN not be zero)
  assign adc_pn_match_s = adc_pn_match_d_1 & adc_pn_match_d_0 & adc_pn_match_z;

  // Data input to the PN generator: Use incoming data if OOS, else use current PN state
  assign adc_pn_data_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in_s : adc_pn_data;

  // Update condition for OOS counter
  assign adc_pn_update_s = (adc_pn_oos == adc_pn_match_s); // Update if state matches expectation

  // Error condition: OOS is low (expect match) but no match occurred
  assign adc_pn_err_s = (adc_pn_oos == 1'b0) & (adc_pn_match_s == 1'b0);

  // PN generator update logic
  always @(posedge adc_clk or negedge rst_n) begin
    if (!rst_n) begin
      adc_pn_en     <= 1'b0; // Start disabled
      adc_data_in   <= 14'd0;
      adc_data_d    <= 14'd0;
      adc_pn_data   <= 30'd1; // Initialize PN sequence to non-zero state
    end else begin
      adc_pn_en <= ~adc_pn_en; // Toggle enable every cycle
      // Invert MSB as per original logic, capture data
      adc_data_in <= {~adc_data[13], adc_data[12:0]};
      // Delay captured data by one cycle
      adc_data_d <= adc_data_in;
      // Update PN sequence only when enabled
      if (adc_pn_en == 1'b1) begin
        if (adc_pn_type == 1'b0) begin // Select PN9
          adc_pn_data <= pn9(adc_pn_data_s);
        end else begin // Select PN23
          adc_pn_data <= pn23(adc_pn_data_s);
        end
      end
    end
  end

  // Match detection, OOS logic, and error flag generation
  always @(posedge adc_clk or negedge rst_n) begin
    if (!rst_n) begin
      adc_pn_en_d       <= 1'b0;
      adc_pn_match_d_1  <= 1'b0;
      adc_pn_match_d_0  <= 1'b0;
      adc_pn_match_z    <= 1'b0;
      adc_pn_err        <= 1'b0;
      adc_pn_oos_count  <= 7'd0;
      adc_pn_oos        <= 1'b1; // Start in Out-Of-Sync state
    end else begin
      adc_pn_en_d <= adc_pn_en; // Delay enable signal

      // Register match signals calculated combinatorially
      adc_pn_match_d_1 <= adc_pn_match_d_1_s;
      adc_pn_match_d_0 <= adc_pn_match_d_0_s;
      adc_pn_match_z   <= adc_pn_match_z_s;

      // Generate error flag: only assert if enabled and error condition met
      adc_pn_err <= adc_pn_en_d & adc_pn_err_s;

      // OOS state machine: only update when enabled
      if (adc_pn_en_d == 1'b1) begin
        if (adc_pn_update_s == 1'b1) begin // Condition met (either OOS and no match, or In-Sync and match)
          if (adc_pn_oos_count >= 7'd16) begin // Threshold reached
            adc_pn_oos_count <= 7'd0;
            adc_pn_oos <= ~adc_pn_oos; // Toggle OOS state
          end else begin
            adc_pn_oos_count <= adc_pn_oos_count + 1'b1; // Increment counter
            // adc_pn_oos <= adc_pn_oos; // Keep current OOS state (redundant line)
          end
        end else begin // Condition not met (OOS and match, or In-Sync and no match)
          adc_pn_oos_count <= 7'd0; // Reset counter
          // adc_pn_oos <= adc_pn_oos; // Keep current OOS state (redundant line)
        end
      end else begin
         // If not enabled, hold the OOS state and reset the counter
         adc_pn_oos_count <= 7'd0;
         // adc_pn_oos <= adc_pn_oos; // Keep current OOS state (redundant line)
      end
    end
  end

  // Assign registered outputs directly
  // assign adc_pn_oos = adc_pn_oos; // Not needed, driven by reg
  // assign adc_pn_err = adc_pn_err; // Not needed, driven by reg

endmodule