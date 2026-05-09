`timescale 1ns/100ps
`timescale 1ns/100ps
module cf_pnmon (
  adc_clk,
  adc_data,
  adc_pn_oos,
  adc_pn_err,
  up_pn_type);
  input           adc_clk;
  input   [13:0]  adc_data;
  output          adc_pn_oos;
  output          adc_pn_err;
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
  reg             adc_pn_oos = 'd0;
  reg     [ 4:0]  adc_pn_err_count = 'd0;
  reg             adc_pn_err = 'd0;
  wire    [27:0]  adc_pn_data_in_s;
  wire            adc_pn_match0_s;
  wire            adc_pn_match1_s;
  wire            adc_pn_match2_s;
  wire            adc_pn_match_s;
  wire    [27:0]  adc_pn_data_s;
  wire            adc_pn_err_s;
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
      dout[ 4] = din[22] ^ din[12];
      dout[ 3] = din[21] ^ din[11];
      dout[ 2] = din[20] ^ din[10];
      dout[ 1] = din[19] ^ din[ 9];
      dout[ 0] = din[18] ^ din[ 8];
      pn23 = dout;
    end
  endfunction
  function [27:0] pn9;
    input [27:0] din;
    reg   [27:0] dout;
    begin
      dout[27] = din[ 8] ^ din[ 4];
      dout[26] = din[ 7] ^ din[ 3];
      dout[25] = din[ 6] ^ din[ 2];
      dout[24] = din[ 5] ^ din[ 1];
      dout[23] = din[ 4] ^ din[ 0];
      dout[22] = din[ 3] ^ din[ 8] ^ din[ 4];
      dout[21] = din[ 2] ^ din[ 7] ^ din[ 3];
      dout[20] = din[ 1] ^ din[ 6] ^ din[ 2];
      dout[19] = din[ 0] ^ din[ 5] ^ din[ 1];
      dout[18] = din[ 8] ^ din[ 0];
      dout[17] = din[ 7] ^ din[ 8] ^ din[ 4];
      dout[16] = din[ 6] ^ din[ 7] ^ din[ 3];
      dout[15] = din[ 5] ^ din[ 6] ^ din[ 2];
      dout[14] = din[ 4] ^ din[ 5] ^ din[ 1];
      dout[13] = din[ 3] ^ din[ 4] ^ din[ 0];
      dout[12] = din[ 2] ^ din[ 3] ^ din[ 8] ^ din[ 4];
      dout[11] = din[ 1] ^ din[ 2] ^ din[ 7] ^ din[ 3];
      dout[10] = din[ 0] ^ din[ 1] ^ din[ 6] ^ din[ 2];
      dout[ 9] = din[ 8] ^ din[ 0] ^ din[ 4] ^ din[ 5] ^ din[ 1];
      dout[ 8] = din[ 7] ^ din[ 8] ^ din[ 3] ^ din[ 0];
      dout[ 7] = din[ 6] ^ din[ 7] ^ din[ 2] ^ din[ 8] ^ din[ 4];
      dout[ 6] = din[ 5] ^ din[ 6] ^ din[ 1] ^ din[ 7] ^ din[ 3];
      dout[ 5] = din[ 4] ^ din[ 5] ^ din[ 0] ^ din[ 6] ^ din[ 2];
      dout[ 4] = din[ 3] ^ din[ 8] ^ din[ 5] ^ din[ 1];
      dout[ 3] = din[ 2] ^ din[ 4] ^ din[ 7] ^ din[ 0];
      dout[ 2] = din[ 1] ^ din[ 3] ^ din[ 6] ^ din[ 8] ^ din[ 4];
      dout[ 1] = din[ 0] ^ din[ 2] ^ din[ 5] ^ din[ 7] ^ din[ 3];
      dout[ 0] = din[ 8] ^ din[ 1] ^ din[ 6] ^ din[ 2];
      pn9 = dout;
    end
  endfunction
  assign adc_pn_data_in_s[27:14] = {adc_data_d[13], adc_data_d[12:0]};
  assign adc_pn_data_in_s[13: 0] = {adc_data[13], adc_data[12:0]};
  assign adc_pn_match0_s = (adc_pn_data_in_s[27:14] == adc_pn_data[27:14]) ? 1'b1 : 1'b0;
  assign adc_pn_match1_s = (adc_pn_data_in_s[13:0] == adc_pn_data[13:0]) ? 1'b1 : 1'b0;
  assign adc_pn_match2_s = ((adc_data == 14'd0) && (adc_data_d == 14'd0)) ? 1'b0 : 1'b1;
  assign adc_pn_match_s = adc_pn_match0_s & adc_pn_match1_s & adc_pn_match2_s;
  assign adc_pn_data_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in_s : adc_pn_data;
  assign adc_pn_err_s = ~(adc_pn_oos | adc_pn_match);
  always @(posedge adc_clk) begin
    adc_pn_type_m1 <= up_pn_type;
    adc_pn_type_m2 <= adc_pn_type_m1;
    adc_pn_type <= adc_pn_type_m2;
    adc_pn_en <= ~adc_pn_en;
    adc_data_d <= adc_data;
    if (adc_pn_en == 1'b1) begin
      if (adc_pn_type == 1'b0) begin
        adc_pn_data <= pn9(adc_pn_data_s);
      end else begin
        adc_pn_data <= pn23(adc_pn_data_s);
      end
    end
  end
  always @(posedge adc_clk) begin
    adc_pn_en_d <= adc_pn_en;
    adc_pn_match <= adc_pn_match_s;
    if (adc_pn_en_d == 1'b1) begin
      if (adc_pn_oos == 1'b1) begin
        if (adc_pn_match == 1'b1) begin
          if (adc_pn_oos_count >= 16) begin
            adc_pn_oos_count <= 'd0;
            adc_pn_oos <= 'd0;
          end else begin
            adc_pn_oos_count <= adc_pn_oos_count + 1'b1;
            adc_pn_oos <= 'd1;
          end
        end else begin
          adc_pn_oos_count <= 'd0;
          adc_pn_oos <= 'd1;
        end
      end else begin
        if (adc_pn_match == 1'b0) begin
          if (adc_pn_oos_count >= 64) begin
            adc_pn_oos_count <= 'd0;
            adc_pn_oos <= 'd1;
          end else begin
            adc_pn_oos_count <= adc_pn_oos_count + 1'b1;
            adc_pn_oos <= 'd0;
          end
        end else begin
          adc_pn_oos_count <= 'd0;
          adc_pn_oos <= 'd0;
        end
      end
    end
  end
  always @(posedge adc_clk) begin
    if (adc_pn_en_d == 1'b1) begin
      if (adc_pn_err_s == 1'b1) begin
        adc_pn_err_count <= 5'h10;
      end else if (adc_pn_err_count[4] == 1'b1) begin
        adc_pn_err_count <= adc_pn_err_count + 1'b1;
      end
    end
    adc_pn_err <= adc_pn_err_count[4];
  end
endmodule
