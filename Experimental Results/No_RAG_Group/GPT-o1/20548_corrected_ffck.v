module adio_codec (
    output          oAUD_DATA,
    output          oAUD_LRCK,
    output  reg     oAUD_BCK,
    input           key1_on,
    input   [1:0]   iSrc_Select,
    input           iCLK_18_4,
    input           iRST_N,
    input   [15:0]  sound1
);

parameter   REF_CLK         = 18432000;
parameter   SAMPLE_RATE     = 48000;
parameter   DATA_WIDTH      = 16;
parameter   CHANNEL_NUM     = 2;
parameter   SIN_SAMPLE_DATA = 48;
parameter   SIN_SANPLE      = 0;

reg [3:0]   BCK_DIV;
reg [8:0]   LRCK_1X_DIV;
reg [7:0]   LRCK_2X_DIV;
reg [6:0]   LRCK_4X_DIV;
reg [3:0]   SEL_Cont;
reg [5:0]   SIN_Cont;
reg         LRCK_1X;
reg         LRCK_2X;
reg         LRCK_4X;

// Edge-detection registers
reg         LRCK_1X_d;
reg         oAUD_BCK_d;
reg         key1_on_d;
reg         LRCK_1X_d2;

// Negative-edge detection wires
wire        LRCK_1X_negedge     = (LRCK_1X_d   == 1'b1) && (LRCK_1X   == 1'b0);
wire        oAUD_BCK_negedge    = (oAUD_BCK_d == 1'b1) && (oAUD_BCK == 1'b0);
wire        key1_on_negedge     = (key1_on_d  == 1'b1) && (key1_on  == 1'b0);
wire        LRCK_1X_negedge2    = (LRCK_1X_d2 == 1'b1) && (LRCK_1X  == 1'b0);

// BCK generation
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        BCK_DIV     <= 0;
        oAUD_BCK    <= 0;
    end
    else
    begin
        if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1)
        begin
            BCK_DIV  <= 0;
            oAUD_BCK<= ~oAUD_BCK;
        end
        else
            BCK_DIV  <= BCK_DIV+1;
    end
end

// LRCK generation
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        LRCK_1X_DIV <= 0;
        LRCK_2X_DIV <= 0;
        LRCK_4X_DIV <= 0;
        LRCK_1X     <= 0;
        LRCK_2X     <= 0;
        LRCK_4X     <= 0;
    end
    else
    begin
        if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1)
        begin
            LRCK_1X_DIV <= 0;
            LRCK_1X     <= ~LRCK_1X;
        end
        else
            LRCK_1X_DIV <= LRCK_1X_DIV+1;

        if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1)
        begin
            LRCK_2X_DIV <= 0;
            LRCK_2X     <= ~LRCK_2X;
        end
        else
            LRCK_2X_DIV <= LRCK_2X_DIV+1;

        if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1)
        begin
            LRCK_4X_DIV <= 0;
            LRCK_4X     <= ~LRCK_4X;
        end
        else
            LRCK_4X_DIV <= LRCK_4X_DIV+1;
    end
end

assign oAUD_LRCK = LRCK_1X;

// SIN_Cont logic using negedge LRCK_1X detection
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        LRCK_1X_d <= 1'b0;
        SIN_Cont  <= 0;
    end
    else
    begin
        LRCK_1X_d <= LRCK_1X;
        if(LRCK_1X_negedge)
        begin
            if(SIN_Cont < SIN_SAMPLE_DATA-1)
                SIN_Cont <= SIN_Cont + 1;
            else
                SIN_Cont <= 0;
        end
    end
end

// SEL_Cont logic using negedge oAUD_BCK detection
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        oAUD_BCK_d <= 1'b0;
        SEL_Cont   <= 0;
    end
    else
    begin
        oAUD_BCK_d <= oAUD_BCK;
        if(oAUD_BCK_negedge)
            SEL_Cont <= SEL_Cont + 1;
    end
end

wire [15:0] music1_ramp;
wire [15:0] music1 = music1_ramp;
wire [15:0] sound_o;
assign sound_o = music1;

// ramp1 logic using negedge key1_on and negedge LRCK_1X
reg [15:0] ramp1;
wire [15:0] ramp_max = 60000;

always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        key1_on_d  <= 1'b0;
        LRCK_1X_d2 <= 1'b0;
        ramp1      <= 0;
    end
    else
    begin
        key1_on_d  <= key1_on;
        LRCK_1X_d2 <= LRCK_1X;
        if(key1_on_negedge)
            ramp1 <= 0;
        else if(LRCK_1X_negedge2)
        begin
            if(ramp1 > ramp_max)
                ramp1 <= 0;
            else
                ramp1 <= ramp1 + sound1;
        end
    end
end

wire [5:0] ramp1_ramp = ramp1[15:10];

wave_gen_string r1(
    .ramp   (ramp1_ramp),
    .music_o(music1_ramp)
);

assign oAUD_DATA = ((key1_on) && (iSrc_Select == SIN_SANPLE)) ? sound_o[~SEL_Cont] : 0;

endmodule