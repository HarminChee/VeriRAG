`timescale 1ps/1ps
`timescale 1ps/1ps
module ad_dcfilter #(
  parameter   DISABLE = 0) (
  input           clk,
  input           valid,
  input   [15:0]  data,
  output          valid_out,
  output  [15:0]  data_out,
  input           dcfilt_enb,
  input   [15:0]  dcfilt_coeff,
  input   [15:0]  dcfilt_offset);
  reg     [15:0]  dcfilt_coeff_d = 'd0;
  reg     [47:0]  dc_offset = 'd0;
  reg     [47:0]  dc_offset_d = 'd0;
  reg             valid_d = 'd0;
  reg     [15:0]  data_d = 'd0;
  reg             valid_2d = 'd0;
  reg     [15:0]  data_2d = 'd0;
  reg     [15:0]  data_dcfilt = 'd0;
  reg             valid_int = 'd0;
  reg     [15:0]  data_int = 'd0;
  wire    [47:0]  dc_offset_s;
  generate
  if (DISABLE == 1) begin
  assign valid_out = valid;
  assign data_out = data;
  end else begin
  assign valid_out = valid_int;
  assign data_out = data_int;
  end
  endgenerate
  always @(posedge clk) begin
    dcfilt_coeff_d <= dcfilt_coeff;
  end
  always @(posedge clk) begin
    dc_offset   <= dc_offset_s;
    dc_offset_d <= dc_offset;
    valid_d <= valid;
    if (valid == 1'b1) begin
      data_d <= data + dcfilt_offset;
    end
    valid_2d <= valid_d;
    data_2d  <= data_d;
    data_dcfilt <= data_d - dc_offset[32:17];
    if (dcfilt_enb == 1'b1) begin
      valid_int <= valid_2d;
      data_int  <= data_dcfilt;
    end else begin
      valid_int <= valid_2d;
      data_int  <= data_2d;
    end
  end
  DSP48E1 #(
    .ACASCREG (1),
    .ADREG (1),
    .ALUMODEREG (0),
    .AREG (1),
    .AUTORESET_PATDET ("NO_RESET"),
    .A_INPUT ("DIRECT"),
    .BCASCREG (1),
    .BREG (1),
    .B_INPUT ("DIRECT"),
    .CARRYINREG (0),
    .CARRYINSELREG (0),
    .CREG (1),
    .DREG (0),
    .INMODEREG (0),
    .MASK (48'h3fffffffffff),
    .MREG (1),
    .OPMODEREG (0),
    .PATTERN (48'h000000000000),
    .PREG (1),
    .SEL_MASK ("MASK"),
    .SEL_PATTERN ("PATTERN"),
    .USE_DPORT ("TRUE"),
    .USE_MULT ("MULTIPLY"),
    .USE_PATTERN_DETECT ("NO_PATDET"),
    .USE_SIMD ("ONE48"))
  i_dsp48e1 (
    .CLK (clk),
    .A ({{14{dc_offset_s[32]}}, dc_offset_s[32:17]}),
    .B ({{2{dcfilt_coeff_d[15]}}, dcfilt_coeff_d}),
    .C (dc_offset_d),
    .D ({{9{data_d[15]}}, data_d}),
    .MULTSIGNIN (1'd0),
    .CARRYIN (1'd0),
    .CARRYCASCIN (1'd0),
    .ACIN (30'd0),
    .BCIN (18'd0),
    .PCIN (48'd0),
    .P (dc_offset_s),
    .MULTSIGNOUT (),
    .CARRYOUT (),
    .CARRYCASCOUT (),
    .ACOUT (),
    .BCOUT (),
    .PCOUT (),
    .ALUMODE (4'd0),
    .CARRYINSEL (3'd0),
    .INMODE (5'b01100),
    .OPMODE (7'b0110101),
    .PATTERNBDETECT (),
    .PATTERNDETECT (),
    .OVERFLOW (),
    .UNDERFLOW (),
    .CEA1 (1'd0),
    .CEA2 (1'd1),
    .CEAD (1'd1),
    .CEALUMODE (1'd0),
    .CEB1 (1'd0),
    .CEB2 (1'd1),
    .CEC (1'd1),
    .CECARRYIN (1'd0),
    .CECTRL (1'd0),
    .CED (1'd1),
    .CEINMODE (1'd0),
    .CEM (1'd1),
    .CEP (1'd0),
    .RSTA (1'd0),
    .RSTALLCARRYIN (1'd0),
    .RSTALUMODE (1'd0),
    .RSTB (1'd0),
    .RSTC (1'd0),
    .RSTCTRL (1'd0),
    .RSTD (1'd0),
    .RSTINMODE (1'd0),
    .RSTM (1'd0),
    .RSTP (1'd0));
endmodule
