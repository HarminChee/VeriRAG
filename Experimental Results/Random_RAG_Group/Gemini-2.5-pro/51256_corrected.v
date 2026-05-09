`timescale 1ns/100ps
module axi_ad9643_pnmon (
  input  wire        adc_clk,
  input  wire        adc_rst,
  input  wire        test_mode,
  input  wire [13:0] adc_data,
  output wire        adc_pn_oos,
  output wire        adc_pn_err,
  input  wire        adc_pn_type
);
  wire        dft_adc_clk;
  reg         adc_pn_en = 'd0;
  reg  [13:0] adc_data_in = 'd0;
  reg  [13:0] adc_data_d = 'd0;
  reg  [29:0] adc_pn_data = 'd0;
  reg         adc_pn_en_d = 'd0;
  reg         adc_pn_match_d_1 = 'd0;
  reg         adc_pn_match_d_0 = 'd0;
  reg         adc_pn_match_z = 'd0;
  reg         adc_pn_err = 'd0;
  reg  [ 6:0] adc_pn_oos_count = 'd0;
  reg         adc_pn_oos = 'd0;
  wire [29:0] adc_pn_data_in_s;
  wire        adc_pn_match_d_1_s;
  wire        adc_pn_match_d_0_s;
  wire        adc_pn_match_z_s;
  wire        adc_pn_match_s;
  wire [29:0] adc_pn_data_s;
  wire        adc_pn_update_s;
  wire        adc_pn_err_s;

  assign dft_adc_clk = test_mode ? adc_clk : adc_clk;

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

  assign adc_pn_data_in_s[29:15] = {adc_pn_data[29], adc_data_d};
  assign adc_pn_data_in_s[14:0] = {adc_pn_data[14], adc_data_in};
  assign adc_pn_match_d_1_s = (adc_pn_data_in_s[28:15] == adc_pn_data[28:15]) ? 1'b1 : 1'b0;
  assign adc_pn_match_d_0_s = (adc_pn_data_in_s[13:0] == adc_pn_data[13:0]) ? 1'b1 : 1'b0;
  assign adc_pn_match_z_s = (adc_pn_data_in_s == 30'd0) ? 1'b0 : 1'b1;
  assign adc_pn_match_s = adc_pn_match_d_1 & adc_pn_match_d_0 & adc_pn_match_z;
  assign adc_pn_data_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in_s : adc_pn_data;
  assign adc_pn_update_s = ~(adc_pn_oos ^ adc_pn_match_s);
  assign adc_pn_err_s = ~(adc_pn_oos | adc_pn_match_s);

  always @(posedge dft_adc_clk or posedge adc_rst) begin
    if (adc_rst) begin
      adc_pn_en <= 'd0;
      adc_data_in <= 'd0;
      adc_data_d <= 'd0;
      adc_pn_data <= 'd0;
    end else begin
      adc_pn_en <= ~adc_pn_en;
      adc_data_in <= {~adc_data[13], adc_data[12:0]};
      adc_data_d <= adc_data_in;
      if (adc_pn_en == 1'b1) begin
        if (adc_pn_type == 1'b0) begin
          adc_pn_data <= pn9(adc_pn_data_s);
        end else begin
          adc_pn_data <= pn23(adc_pn_data_s);
        end
      end
    end
  end

  always @(posedge dft_adc_clk or posedge adc_rst) begin
    if (adc_rst) begin
      adc_pn_en_d <= 'd0;
      adc_pn_match_d_1 <= 'd0;
      adc_pn_match_d_0 <= 'd0;
      adc_pn_match_z <= 'd0;
      adc_pn_err <= 'd0;
      adc_pn_oos_count <= 'd0;
      adc_pn_oos <= 'd0;
    end else begin
      adc_pn_en_d <= adc_pn_en;
      adc_pn_match_d_1 <= adc_pn_match_d_1_s;
      adc_pn_match_d_0 <= adc_pn_match_d_0_s;
      adc_pn_match_z <= adc_pn_match_z_s;
      adc_pn_err <= adc_pn_en_d & adc_pn_err_s;
      if (adc_pn_en_d == 1'b1) begin
        if (adc_pn_update_s == 1'b1) begin
          if (adc_pn_oos_count >= 16) begin
            adc_pn_oos_count <= 'd0;
            adc_pn_oos <= ~adc_pn_oos;
          end else begin
            adc_pn_oos_count <= adc_pn_oos_count + 1'b1;
            adc_pn_oos <= adc_pn_oos;
          end
        end else begin
          adc_pn_oos_count <= 'd0;
          adc_pn_oos <= adc_pn_oos;
        end
      end
    end
  end
endmodule