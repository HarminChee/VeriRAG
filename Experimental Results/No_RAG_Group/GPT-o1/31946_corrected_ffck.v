module AUDIO_DAC_corrected_ffc (
    oFLASH_ADDR,
    iFLASH_DATA,
    oSDRAM_ADDR,
    iSDRAM_DATA,
    oSRAM_ADDR,
    iSRAM_DATA,
    oAUD_BCK,
    oAUD_DATA,
    oAUD_LRCK,
    iSrc_Select,
    iCLK_18_4,
    iRST_N
);

parameter REF_CLK          = 18432000;
parameter SAMPLE_RATE      = 48000;
parameter DATA_WIDTH       = 16;
parameter CHANNEL_NUM      = 2;
parameter SIN_SAMPLE_DATA  = 48;
parameter FLASH_DATA_NUM   = 1048576;
parameter SDRAM_DATA_NUM   = 4194304;
parameter SRAM_DATA_NUM    = 262144;
parameter FLASH_ADDR_WIDTH = 20;
parameter SDRAM_ADDR_WIDTH = 22;
parameter SRAM_ADDR_WIDTH  = 18;
parameter FLASH_DATA_WIDTH = 8;
parameter SDRAM_DATA_WIDTH = 16;
parameter SRAM_DATA_WIDTH  = 16;
parameter SIN_SANPLE       = 0;
parameter FLASH_DATA       = 1;
parameter SDRAM_DATA       = 2;
parameter SRAM_DATA        = 3;

output [FLASH_ADDR_WIDTH-1:0] oFLASH_ADDR;
input  [FLASH_DATA_WIDTH-1:0] iFLASH_DATA;
output [SDRAM_ADDR_WIDTH-1:0] oSDRAM_ADDR;
input  [SDRAM_DATA_WIDTH-1:0] iSDRAM_DATA;
output [SRAM_ADDR_WIDTH-1:0]  oSRAM_ADDR;
input  [SRAM_DATA_WIDTH-1:0]  iSRAM_DATA;

output        oAUD_DATA;
output        oAUD_LRCK;
output reg    oAUD_BCK;
input  [1:0]  iSrc_Select;
input         iCLK_18_4;
input         iRST_N;

reg  [3:0] BCK_DIV;
reg  [8:0] LRCK_1X_DIV;
reg  [7:0] LRCK_2X_DIV;
reg  [6:0] LRCK_4X_DIV;

reg  [3:0] SEL_Cont;
reg  [5:0] SIN_Cont;

reg  [FLASH_ADDR_WIDTH-1:0] FLASH_Cont;
reg  [SDRAM_ADDR_WIDTH-1:0] SDRAM_Cont;
reg  [SRAM_ADDR_WIDTH-1:0]  SRAM_Cont;

reg  [DATA_WIDTH-1:0] Sin_Out;
reg  [DATA_WIDTH-1:0] FLASH_Out;
reg  [DATA_WIDTH-1:0] SDRAM_Out;
reg  [DATA_WIDTH-1:0] SRAM_Out;

reg  [DATA_WIDTH-1:0] FLASH_Out_Tmp;
reg  [DATA_WIDTH-1:0] SDRAM_Out_Tmp;
reg  [DATA_WIDTH-1:0] SRAM_Out_Tmp;

reg         LRCK_1X;
reg         LRCK_2X;
reg         LRCK_4X;

// Edge-detection and register signals
reg  LRCK_1X_d, LRCK_2X_d, LRCK_4X_d, oAUD_BCK_d;
wire LRCK_1X_falling, LRCK_1X_rising;
wire LRCK_2X_falling, LRCK_2X_rising;
wire LRCK_4X_falling, LRCK_4X_rising;
wire oAUD_BCK_falling, oAUD_BCK_rising;

// Generate BCK from iCLK_18_4
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        BCK_DIV   <= 0;
        oAUD_BCK  <= 0;
    end
    else
    begin
        if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1)
        begin
            BCK_DIV  <= 0;
            oAUD_BCK <= ~oAUD_BCK;
        end
        else
            BCK_DIV <= BCK_DIV + 1;
    end
end

// Generate LRCK_1X, LRCK_2X, LRCK_4X from iCLK_18_4
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
            LRCK_1X_DIV <= LRCK_1X_DIV + 1;

        if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1)
        begin
            LRCK_2X_DIV <= 0;
            LRCK_2X     <= ~LRCK_2X;
        end
        else
            LRCK_2X_DIV <= LRCK_2X_DIV + 1;

        if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1)
        begin
            LRCK_4X_DIV <= 0;
            LRCK_4X     <= ~LRCK_4X;
        end
        else
            LRCK_4X_DIV <= LRCK_4X_DIV + 1;
    end
end

assign oAUD_LRCK = LRCK_1X;

// Capture edges of internally generated clocks on primary clock
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        LRCK_1X_d   <= 1'b0;
        LRCK_2X_d   <= 1'b0;
        LRCK_4X_d   <= 1'b0;
        oAUD_BCK_d  <= 1'b0;
    end
    else
    begin
        LRCK_1X_d   <= LRCK_1X;
        LRCK_2X_d   <= LRCK_2X;
        LRCK_4X_d   <= LRCK_4X;
        oAUD_BCK_d  <= oAUD_BCK;
    end
end

assign LRCK_1X_falling  =  LRCK_1X_d & ~LRCK_1X;
assign LRCK_1X_rising   = ~LRCK_1X_d &  LRCK_1X;
assign LRCK_2X_falling  =  LRCK_2X_d & ~LRCK_2X;
assign LRCK_2X_rising   = ~LRCK_2X_d &  LRCK_2X;
assign LRCK_4X_falling  =  LRCK_4X_d & ~LRCK_4X;
assign LRCK_4X_rising   = ~LRCK_4X_d &  LRCK_4X;
assign oAUD_BCK_falling =  oAUD_BCK_d & ~oAUD_BCK;
assign oAUD_BCK_rising  = ~oAUD_BCK_d &  oAUD_BCK;

// SIN_Cont on negedge LRCK_1X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        SIN_Cont <= 0;
    else if(LRCK_1X_falling)
    begin
        if(SIN_Cont < SIN_SAMPLE_DATA-1)
            SIN_Cont <= SIN_Cont + 1;
        else
            SIN_Cont <= 0;
    end
end

// FLASH_Cont on negedge LRCK_4X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        FLASH_Cont <= 0;
    else if(LRCK_4X_falling)
    begin
        if(FLASH_Cont < FLASH_DATA_NUM-1)
            FLASH_Cont <= FLASH_Cont + 1;
        else
            FLASH_Cont <= 0;
    end
end

assign oFLASH_ADDR = FLASH_Cont;

// FLASH_Out_Tmp on posedge LRCK_4X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        FLASH_Out_Tmp <= 0;
    else if(LRCK_4X_rising)
    begin
        if(FLASH_Cont[0])
            FLASH_Out_Tmp[15:8] <= iFLASH_DATA;
        else
            FLASH_Out_Tmp[7:0]  <= iFLASH_DATA;
    end
end

// FLASH_Out on negedge LRCK_2X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        FLASH_Out <= 0;
    else if(LRCK_2X_falling)
        FLASH_Out <= FLASH_Out_Tmp;
end

// SDRAM_Cont on negedge LRCK_2X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        SDRAM_Cont <= 0;
    else if(LRCK_2X_falling)
    begin
        if(SDRAM_Cont < SDRAM_DATA_NUM-1)
            SDRAM_Cont <= SDRAM_Cont + 1;
        else
            SDRAM_Cont <= 0;
    end
end

assign oSDRAM_ADDR = SDRAM_Cont;

// SDRAM_Out_Tmp on posedge LRCK_2X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        SDRAM_Out_Tmp <= 0;
    else if(LRCK_2X_rising)
        SDRAM_Out_Tmp <= iSDRAM_DATA;
end

// SDRAM_Out on negedge LRCK_2X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        SDRAM_Out <= 0;
    else if(LRCK_2X_falling)
        SDRAM_Out <= SDRAM_Out_Tmp;
end

// SRAM_Cont on negedge LRCK_2X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        SRAM_Cont <= 0;
    else if(LRCK_2X_falling)
    begin
        if(SRAM_Cont < SRAM_DATA_NUM-1)
            SRAM_Cont <= SRAM_Cont + 1;
        else
            SRAM_Cont <= 0;
    end
end

assign oSRAM_ADDR = SRAM_Cont;

// SRAM_Out_Tmp on posedge LRCK_2X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        SRAM_Out_Tmp <= 0;
    else if(LRCK_2X_rising)
        SRAM_Out_Tmp <= iSRAM_DATA;
end

// SRAM_Out on negedge LRCK_2X
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        SRAM_Out <= 0;
    else if(LRCK_2X_falling)
        SRAM_Out <= SRAM_Out_Tmp;
end

// SEL_Cont on negedge oAUD_BCK
always @(posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
        SEL_Cont <= 0;
    else if(oAUD_BCK_falling)
        SEL_Cont <= SEL_Cont + 1;
end

assign oAUD_DATA =
    (iSrc_Select == SIN_SANPLE)  ? Sin_Out[~SEL_Cont]   :
    (iSrc_Select == FLASH_DATA)  ? FLASH_Out[~SEL_Cont] :
    (iSrc_Select == SDRAM_DATA)  ? SDRAM_Out[~SEL_Cont] :
                                   SRAM_Out[~SEL_Cont];

// Update Sin_Out
always @(SIN_Cont)
begin
    case(SIN_Cont)
        0  :  Sin_Out <= 0;
        1  :  Sin_Out <= 4276;
        2  :  Sin_Out <= 8480;
        3  :  Sin_Out <= 12539;
        4  :  Sin_Out <= 16383;
        5  :  Sin_Out <= 19947;
        6  :  Sin_Out <= 23169;
        7  :  Sin_Out <= 25995;
        8  :  Sin_Out <= 28377;
        9  :  Sin_Out <= 30272;
        10 :  Sin_Out <= 31650;
        11 :  Sin_Out <= 32486;
        12 :  Sin_Out <= 32767;
        13 :  Sin_Out <= 32486;
        14 :  Sin_Out <= 31650;
        15 :  Sin_Out <= 30272;
        16 :  Sin_Out <= 28377;
        17 :  Sin_Out <= 25995;
        18 :  Sin_Out <= 23169;
        19 :  Sin_Out <= 19947;
        20 :  Sin_Out <= 16383;
        21 :  Sin_Out <= 12539;
        22 :  Sin_Out <= 8480;
        23 :  Sin_Out <= 4276;
        24 :  Sin_Out <= 0;
        25 :  Sin_Out <= 61259;
        26 :  Sin_Out <= 57056;
        27 :  Sin_Out <= 52997;
        28 :  Sin_Out <= 49153;
        29 :  Sin_Out <= 45589;
        30 :  Sin_Out <= 42366;
        31 :  Sin_Out <= 39540;
        32 :  Sin_Out <= 37159;
        33 :  Sin_Out <= 35263;
        34 :  Sin_Out <= 33885;
        35 :  Sin_Out <= 33049;
        36 :  Sin_Out <= 32768;
        37 :  Sin_Out <= 33049;
        38 :  Sin_Out <= 33885;
        39 :  Sin_Out <= 35263;
        40 :  Sin_Out <= 37159;
        41 :  Sin_Out <= 39540;
        42 :  Sin_Out <= 42366;
        43 :  Sin_Out <= 45589;
        44 :  Sin_Out <= 49152;
        45 :  Sin_Out <= 52997;
        46 :  Sin_Out <= 57056;
        47 :  Sin_Out <= 61259;
        default: Sin_Out <= 0;
    endcase
end

endmodule