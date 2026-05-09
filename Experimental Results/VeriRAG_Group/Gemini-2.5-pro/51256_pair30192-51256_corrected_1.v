`timescale 1ns/100ps

module axi_ad9643_pnmon (
  adc_clk,
  adc_data,
  adc_pn_oos,
  adc_pn_err,
  adc_pn_type,
  test_mode, // Added test mode input
  test_en_in // Added test enable input
);

  input           adc_clk;
  input   [13:0]  adc_data;
  output          adc_pn_oos;
  output          adc_pn_err;
  input           adc_pn_type;
  input           test_mode; // Added test mode input
  input           test_en_in; // Added test enable input

  reg             adc_pn_en = 'd0;
  reg     [13:0]  adc_data_in = 'd0;
  reg     [13:0]  adc_data_d = 'd0;
  reg     [29:0]  adc_pn_data = 'd0;
  reg             adc_pn_en_d = 'd0;
  reg             adc_pn_match_d_1 = 'd0;
  reg             adc_pn_match_d_0 = 'd0;
  reg             adc_pn_match_z = 'd0;
  reg             adc_pn_err_reg = 'd0; // Renamed from adc_pn_err to avoid conflict with output port
  reg     [ 6:0]  adc_pn_oos_count = 'd0;
  reg             adc_pn_oos_reg = 'd0; // Renamed from adc_pn_oos to avoid conflict with output port

  // Assign outputs from internal registers
  assign adc_pn_oos = adc_pn_oos_reg;
  assign adc_pn_err = adc_pn_err_reg;

  wire            dft_adc_pn_en;   // Muxed enable signal
  wire            dft_adc_pn_en_d; // Muxed delayed enable signal

  wire    [29:0]  adc_pn_data_in_s;
  wire            adc_pn_match_d_1_s;
  wire            adc_pn_match_d_0_s;
  wire            adc_pn_match_z_s;
  wire            adc_pn_match_s;
  wire    [29:0]  adc_pn_data_s;
  wire            adc_pn_update_s;
  wire            adc_pn_err_s;

  // DFT Mux for enable signals - Allows test control over enable logic path
  assign dft_adc_pn_en   = test_mode ? test_en_in : adc_pn_en;
  assign dft_adc_pn_en_d = test_mode ? test_en_in : adc_pn_en_d;


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
      dout[ 6] = din[22] ^ din[12];
      dout[ 5] = din[21] ^ din[11];
      dout[ 4] = din[20] ^ din[10];
      dout[ 3] = din[19] ^ din[ 9];
      dout[ 2] = din[18] ^ din[ 8];
      dout[ 1] = din[17] ^ din[ 7];
      dout[ 0] = din[16] ^ din[ 6];
      pn23 = dout;
    end
  endfunction

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
      dout[20] = din[ 8] ^ din[ 0];
      dout[19] = din[ 7] ^ din[ 8] ^ din[ 4];
      dout[18] = din[ 6] ^ din[ 7] ^ din[ 3];
      dout[17] = din[ 5] ^ din[ 6] ^ din[ 2];
      dout[16] = din[ 4] ^ din[ 5] ^ din[ 1];
      dout[15] = din[ 3] ^ din[ 4] ^ din[ 0];
      dout[14] = din[ 2] ^ din[ 3] ^ din[ 8] ^ din[ 4];
      dout[13] = din[ 1] ^ din[ 2] ^ din[ 7] ^ din[ 3];
      dout[12] = din[ 0] ^ din[ 1] ^ din[ 6] ^ din[ 2];
      dout[11] = din[ 8] ^ din[ 0] ^ din[ 4] ^ din[ 5] ^ din[ 1];
      dout[10] = din[ 7] ^ din[ 8] ^ din[ 3] ^ din[ 0];
      dout[ 9] = din[ 6] ^ din[ 7] ^ din[ 2] ^ din[ 8] ^ din[ 4];
      dout[ 8] = din[ 5] ^ din[ 6] ^ din[ 1] ^ din[ 7] ^ din[ 3];
      dout[ 7] = din[ 4] ^ din[ 5] ^ din[ 0] ^ din[ 6] ^ din[ 2];
      dout[ 6] = din[ 3] ^ din[ 8] ^ din[ 5] ^ din[ 1];
      dout[ 5] = din[ 2] ^ din[ 4] ^ din[ 7] ^ din[ 0];
      dout[ 4] = din[ 1] ^ din[ 3] ^ din[ 6] ^ din[ 8] ^ din[ 4];
      dout[ 3] = din[ 0] ^ din[ 2] ^ din[ 5] ^ din[ 7] ^ din[ 3];
      dout[ 2] = din[ 8] ^ din[ 1] ^ din[ 6] ^ din[ 2];
      dout[ 1] = din[ 7] ^ din[ 0] ^ din[ 5] ^ din[ 1];
      dout[ 0] = din[ 6] ^ din[ 8] ^ din[ 0];
      pn9 = dout;
    end
  endfunction

  // Combinational logic for PN sequence matching and generation
  assign adc_pn_data_in_s[29:15] = {adc_pn_data[29], adc_data_d}; // Form potential next state based on delayed input data
  assign adc_pn_data_in_s[14:0] = {adc_pn_data[14], adc_data_in}; // Form potential next state based on current input data
  assign adc_pn_match_d_1_s = (adc_pn_data_in_s[28:15] == adc_pn_data[28:15]) ? 1'b1 : 1'b0; // Check match for delayed part
  assign adc_pn_match_d_0_s = (adc_pn_data_in_s[13:0] == adc_pn_data[13:0]) ? 1'b1 : 1'b0; // Check match for current part
  assign adc_pn_match_z_s = (adc_pn_data_in_s != 30'd0); // Check if potential next state is non-zero
  assign adc_pn_match_s = adc_pn_match_d_1 & adc_pn_match_d_0 & adc_pn_match_z; // Overall match condition

  // Update and Error signals based on muxed delayed enable and match status
  assign adc_pn_update_s = dft_adc_pn_en_d & adc_pn_match_s;
  assign adc_pn_err_s = dft_adc_pn_en_d & ~adc_pn_match_s;

  // Next state logic for PN data register
  assign adc_pn_data_s = (adc_pn_update_s == 1'b1) ? (adc_pn_type ? pn23(adc_pn_data) : pn9(adc_pn_data)) : adc_pn_data;


  // Synchronous logic block
  always @(posedge adc_clk) begin
    // Input data pipeline
    adc_data_in <= adc_data;
    adc_data_d <= adc_data_in;

    // PN State Machine Registers
    adc_pn_en <= (adc_pn_match_s == 1'b1) ? 1'b1 : ((adc_pn_oos_reg == 1'b1) ? 1'b0 : adc_pn_en); // Enable logic
    adc_pn_en_d <= adc_pn_en; // Pipelined enable (Note: uses original adc_pn_en, not dft_adc_pn_en)

    // PN Data register update
    adc_pn_data <= adc_pn_data_s;

    // Match pipeline registers
    adc_pn_match_d_1 <= adc_pn_match_d_1_s;
    adc_pn_match_d_0 <= adc_pn_match_d_0_s;
    adc_pn_match_z <= adc_pn_match_z_s;

    // Error register update
    adc_pn_err_reg <= adc_pn_err_s;

    // Out-of-Sync (OOS) Logic
    if (adc_pn_err_s == 1'b1) begin // If error detected
      adc_pn_oos_count <= adc_pn_oos_count + 1'b1; // Increment OOS counter
    end else if (adc_pn_match_s == 1'b1) begin // If match occurs
      adc_pn_oos_count <= 7'd0; // Reset OOS counter
    end

    if (adc_pn_oos_count == 7'd127) begin // If OOS count reaches threshold
      adc_pn_oos_reg <= 1'b1; // Set OOS flag
    end else if (adc_pn_match_s == 1'b1) begin // If match occurs
      adc_pn_oos_reg <= 1'b0; // Clear OOS flag
    end
  end

endmodule