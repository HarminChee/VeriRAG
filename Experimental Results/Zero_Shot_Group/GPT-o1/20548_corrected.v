module adio_codec (
  output            oAUD_DATA,
  output            oAUD_LRCK,
  output reg        oAUD_BCK,
  input             key1_on,
  input      [1:0]  iSrc_Select,
  input             iCLK_18_4,
  input             iRST_N,
  input      [15:0] sound1
);

  parameter REF_CLK        = 18432000;
  parameter SAMPLE_RATE    = 48000;
  parameter DATA_WIDTH     = 16;
  parameter CHANNEL_NUM    = 2;
  parameter SIN_SAMPLE_DATA= 48;
  parameter SIN_SAMPLE     = 0;

  reg  [3:0] BCK_DIV;
  reg  [8:0] LRCK_1X_DIV;
  reg  [7:0] LRCK_2X_DIV;
  reg  [6:0] LRCK_4X_DIV;
  reg  [3:0] SEL_Cont;
  reg  [5:0] SIN_Cont;
  reg        LRCK_1X;
  reg        LRCK_2X;
  reg        LRCK_4X;

  always @(posedge iCLK_18_4 or negedge iRST_N) begin
    if (!iRST_N) begin
      BCK_DIV   <= 0;
      oAUD_BCK  <= 0;
    end
    else begin
      if (BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1) begin
        BCK_DIV  <= 0;
        oAUD_BCK <= ~oAUD_BCK;
      end
      else
        BCK_DIV <= BCK_DIV + 1;
    end
  end

  always @(posedge iCLK_18_4 or negedge iRST_N) begin
    if(!iRST_N) begin
      LRCK_1X_DIV <= 0;
      LRCK_2X_DIV <= 0;
      LRCK_4X_DIV <= 0;
      LRCK_1X     <= 0;
      LRCK_2X     <= 0;
      LRCK_4X     <= 0;
    end
    else begin
      if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1) begin
        LRCK_1X_DIV <= 0;
        LRCK_1X     <= ~LRCK_1X;
      end
      else
        LRCK_1X_DIV <= LRCK_1X_DIV + 1;

      if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1) begin
        LRCK_2X_DIV <= 0;
        LRCK_2X     <= ~LRCK_2X;
      end
      else
        LRCK_2X_DIV <= LRCK_2X_DIV + 1;

      if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1) begin
        LRCK_4X_DIV <= 0;
        LRCK_4X     <= ~LRCK_4X;
      end
      else
        LRCK_4X_DIV <= LRCK_4X_DIV + 1;
    end
  end

  assign oAUD_LRCK = LRCK_1X;

  always @(negedge LRCK_1X or negedge iRST_N) begin
    if(!iRST_N)
      SIN_Cont <= 0;
    else begin
      if(SIN_Cont < SIN_SAMPLE_DATA - 1)
        SIN_Cont <= SIN_Cont + 1;
      else
        SIN_Cont <= 0;
    end
  end

  wire [15:0] music1_ramp;
  wire [15:0] music1     = music1_ramp;
  wire [15:0] sound_o    = music1;

  always @(negedge oAUD_BCK or negedge iRST_N) begin
    if(!iRST_N)
      SEL_Cont <= 0;
    else
      SEL_Cont <= SEL_Cont + 1;
  end

  assign oAUD_DATA = ((key1_on) && (iSrc_Select == SIN_SAMPLE)) ? sound_o[~SEL_Cont] : 1'b0;

  reg [15:0] ramp1;
  wire [15:0] ramp_max = 16'd60000;

  always @(negedge LRCK_1X or negedge iRST_N) begin
    if(!iRST_N)
      ramp1 <= 0;
    else if(!key1_on)
      ramp1 <= 0;
    else if(ramp1 > ramp_max)
      ramp1 <= 0;
    else
      ramp1 <= ramp1 + sound1;
  end

  wire [5:0] ramp1_ramp = ramp1[15:10];

  wave_gen_string r1(
    .ramp    (ramp1_ramp),
    .music_o (music1_ramp)
  );

endmodule