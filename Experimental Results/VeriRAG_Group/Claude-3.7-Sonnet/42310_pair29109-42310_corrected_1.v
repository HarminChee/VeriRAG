module cf_pnmon (
  input wire test_i,
  input wire scan_clk,
  input wire adc_clk,
  input wire reset_n,
  input [13:0] adc_data,
  output reg adc_pn_oos,
  output reg adc_pn_err,
  input wire up_pn_type
);

  reg adc_pn_type_m1 = 'd0;
  reg adc_pn_type_m2 = 'd0;
  reg adc_pn_type = 'd0;
  reg adc_pn_en = 'd0;
  reg [13:0] adc_data_d = 'd0;
  reg [27:0] adc_pn_data = 'd0;
  reg adc_pn_en_d = 'd0;
  reg adc_pn_match = 'd0;
  reg [6:0] adc_pn_oos_count = 'd0;
  reg [4:0] adc_pn_err_count = 'd0;

  wire [27:0] adc_pn_data_in_s;
  wire adc_pn_match0_s;
  wire adc_pn_match1_s;
  wire adc_pn_match2_s;
  wire adc_pn_match_s;
  wire [27:0] adc_pn_data_s;
  wire adc_pn_err_s;
  wire dft_clk;

  assign dft_clk = test_i ? scan_clk : adc_clk;

  function [27:0] pn23;
    input [27:0] din;
    reg [27:0] dout;
    begin
      dout = {din[26:0], din[27] ^ din[26] ^ din[25] ^ din[22]};
      pn23 = dout;
    end
  endfunction

  function [27:0] pn9;
    input [27:0] din;
    reg [27:0] dout;
    begin
      dout = {din[26:0], din[27] ^ din[26]};
      pn9 = dout;
    end
  endfunction

  assign adc_pn_data_in_s[27:14] = {adc_data_d[13], adc_data_d[12:0]};
  assign adc_pn_data_in_s[13:0] = {adc_data[13], adc_data[12:0]};
  assign adc_pn_match0_s = (adc_pn_data_in_s[27:14] == adc_pn_data[27:14]) ? 1'b1 : 1'b0;
  assign adc_pn_match1_s = (adc_pn_data_in_s[13:0] == adc_pn_data[13:0]) ? 1'b1 : 1'b0;
  assign adc_pn_match2_s = ((adc_data == 14'd0) && (adc_data_d == 14'd0)) ? 1'b0 : 1'b1;
  assign adc_pn_match_s = adc_pn_match0_s & adc_pn_match1_s & adc_pn_match2_s;
  assign adc_pn_data_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in_s : adc_pn_data;
  assign adc_pn_err_s = ~(adc_pn_oos | adc_pn_match);

  always @(posedge dft_clk or negedge reset_n) begin
    if (!reset_n) begin
      adc_pn_type_m1 <= 'd0;
      adc_pn_type_m2 <= 'd0;
      adc_pn_type <= 'd0;
      adc_pn_en <= 'd0;
      adc_data_d <= 'd0;
      adc_pn_data <= 'd0;
    end else begin
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
  end

  always @(posedge dft_clk or negedge reset_n) begin
    if (!reset_n) begin
      adc_pn_en_d <= 'd0;
      adc_pn_match <= 'd0;
      adc_pn_oos_count <= 'd0;
      adc_pn_oos <= 'd0;
    end else begin
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
  end

  always @(posedge dft_clk or negedge reset_n) begin
    if (!reset_n) begin
      adc_pn_err_count <= 'd0;
      adc_pn_err <= 'd0;
    end else begin
      if (adc_pn_en_d == 1'b1) begin
        if (adc_pn_err_s == 1'b1) begin
          adc_pn_err_count <= 5'h10;
        end else if (adc_pn_err_count[4] == 1'b1) begin
          adc_pn_err_count <= adc_pn_err_count + 1'b1;
        end
      end
      adc_pn_err <= adc_pn_err_count[4];
    end
  end

endmodule