`timescale 1ns/100ps
`timescale 1ns/100ps
module util_cpack_dsf (
  adc_clk,
  adc_valid,
  adc_enable,
  adc_data,
  adc_dsf_valid,
  adc_dsf_sync,
  adc_dsf_data);
  parameter   CH_DW   = 32;
  parameter   CH_ICNT =  4;
  parameter   CH_MCNT =  8;
  parameter   P_CNT   =  4;
  localparam  CH_DCNT = P_CNT - CH_ICNT;
  localparam  I_WIDTH = CH_DW*CH_ICNT;
  localparam  P_WIDTH = CH_DW*P_CNT;
  localparam  M_WIDTH = CH_DW*CH_MCNT;
  input                     adc_clk;
  input                     adc_valid;
  input                     adc_enable;
  input   [(I_WIDTH-1):0]   adc_data;
  output                    adc_dsf_valid;
  output                    adc_dsf_sync;
  output  [(P_WIDTH-1):0]   adc_dsf_data;
  reg     [  2:0]           adc_samples_int = 'd0;
  reg     [(M_WIDTH-1):0]   adc_data_int = 'd0;
  reg                       adc_dsf_enable = 'd0;
  reg                       adc_dsf_valid_int = 'd0;
  reg                       adc_dsf_sync_int = 'd0;
  reg     [(P_WIDTH-1):0]   adc_dsf_data_int = 'd0;
  reg                       adc_dsf_valid = 'd0;
  reg                       adc_dsf_sync = 'd0;
  reg     [(P_WIDTH-1):0]   adc_dsf_data = 'd0;
  wire    [(M_WIDTH-1):0]   adc_data_s;
  generate
  if (CH_ICNT == P_CNT) begin
  assign adc_data_s = 'd0;
  always @(posedge adc_clk) begin
    adc_samples_int <= 'd0;
    adc_data_int <= 'd0;
    adc_dsf_enable <= 'd0;
    adc_dsf_valid_int <= 'd0;
    adc_dsf_sync_int <= 'd0;
    adc_dsf_data_int <= 'd0;
    if (adc_enable == 1'b1) begin
      adc_dsf_valid <= adc_valid;
      adc_dsf_sync <= 1'b1;
      adc_dsf_data <= adc_data;
    end else begin
      adc_dsf_valid <= 'b0;
      adc_dsf_sync <= 'b0;
      adc_dsf_data <= 'd0;
    end
  end
  end
  endgenerate
  generate
  if (P_CNT > CH_ICNT) begin
  assign adc_data_s[(M_WIDTH-1):I_WIDTH] = 'd0;
  assign adc_data_s[(I_WIDTH-1):0] = adc_data;
  always @(posedge adc_clk) begin
    if (adc_valid == 1'b1) begin
      if (adc_samples_int >= CH_DCNT) begin
        adc_samples_int <= adc_samples_int - CH_DCNT;
      end else begin
        adc_samples_int <= adc_samples_int + CH_ICNT;
      end
      adc_data_int <= {adc_data_s[(I_WIDTH-1):0],
        adc_data_int[(M_WIDTH-1):I_WIDTH]};
    end
  end
  always @(posedge adc_clk) begin
    adc_dsf_enable <= adc_enable;
    if (adc_samples_int >= CH_DCNT) begin
      adc_dsf_valid_int <= adc_valid;
    end else begin
      adc_dsf_valid_int <= 1'b0;
    end
    if (adc_dsf_sync_int == 1'b1) begin
      if (adc_dsf_valid_int == 1'b1) begin
        adc_dsf_sync_int <= 1'b0;
      end
    end else begin
      if (adc_samples_int == 3'd0) begin
        adc_dsf_sync_int <= 1'b1;
      end
    end
  end
  always @(posedge adc_clk) begin
    if (adc_valid == 1'b1) begin
      case (adc_samples_int)
        3'b111:  adc_dsf_data_int <= {adc_data_s[((CH_DW*1)-1):0],
                    adc_data_int[((CH_DW*8)-1):(CH_DW*1)]};
        3'b110:  adc_dsf_data_int <= {adc_data_s[((CH_DW*2)-1):0],
                    adc_data_int[((CH_DW*8)-1):(CH_DW*2)]};
        3'b101:  adc_dsf_data_int <= {adc_data_s[((CH_DW*3)-1):0],
                    adc_data_int[((CH_DW*8)-1):(CH_DW*3)]};
        3'b100:  adc_dsf_data_int <= {adc_data_s[((CH_DW*4)-1):0],
                    adc_data_int[((CH_DW*8)-1):(CH_DW*4)]};
        3'b011:  adc_dsf_data_int <= {adc_data_s[((CH_DW*5)-1):0],
                    adc_data_int[((CH_DW*8)-1):(CH_DW*5)]};
        3'b010:  adc_dsf_data_int <= {adc_data_s[((CH_DW*6)-1):0],
                    adc_data_int[((CH_DW*8)-1):(CH_DW*6)]};
        3'b001:  adc_dsf_data_int <= {adc_data_s[((CH_DW*7)-1):0],
                    adc_data_int[((CH_DW*8)-1):(CH_DW*7)]};
        3'b000:  adc_dsf_data_int <= adc_data_s;
        default: adc_dsf_data_int <= 'd0;
      endcase
    end
  end
  always @(posedge adc_clk) begin
    if (adc_enable == 1'b1) begin
      adc_dsf_valid <= adc_dsf_valid_int;
      adc_dsf_sync <= adc_dsf_sync_int;
      adc_dsf_data <= adc_dsf_data_int[(P_WIDTH-1):0];
    end else begin
      adc_dsf_valid <= 'b0;
      adc_dsf_sync <= 'b0;
      adc_dsf_data <= 'd0;
    end
  end
  end
  endgenerate
endmodule
