module AUDIO_DAC
#(
    parameter	REF_CLK			=	18432000,	//	18.432	MHz
    parameter	SAMPLE_RATE		=	48000,		//	48		KHz
    parameter	DATA_WIDTH		=	16,			//	16		Bits
    parameter	CHANNEL_NUM		=	2,			//	Dual Channel

    parameter	SIN_SAMPLE_DATA	=	48,
    parameter	FLASH_DATA_NUM	=	1048576,	//	1	MWords
    parameter	SDRAM_DATA_NUM	=	4194304,	//	4	MWords
    parameter	SRAM_DATA_NUM	=	262144,		//	256	KWords

    parameter	FLASH_ADDR_WIDTH=	20,			//	20	Address Line
    parameter	SDRAM_ADDR_WIDTH=	22,			//	22	Address Line
    parameter	SRAM_ADDR_WIDTH=	18,			//	18	Address	Line

    parameter	FLASH_DATA_WIDTH=	8,			//	8	Bits
    parameter	SDRAM_DATA_WIDTH=	16,			//	16	Bits
    parameter	SRAM_DATA_WIDTH=	16,			//	16	Bits

    ////////////	Input Source Number	//////////////
    parameter	SIN_SANPLE		=	0,
    parameter	FLASH_DATA		=	1,
    parameter	SDRAM_DATA		=	2,
    parameter	SRAM_DATA		=	3
)
(	//	Memory Side
    output	[FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR,
    input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA,
    output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR,
    input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA,
    output	[SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR,
    input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA,
    //	Audio Side
    output							oAUD_BCK,
    output							oAUD_DATA,
    output							oAUD_LRCK,
    //	Control Signals
    input	[1:0]					iSrc_Select,
    input							iCLK_18_4,
    input							iRST_N,
    input 							test_i // DFT test mode signal
);

// Local parameters derived from module parameters
localparam BCK_DIV_MAX = (REF_CLK >= (SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)) ? (REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2) - 1) : 0;
localparam LRCK_1X_DIV_MAX = (REF_CLK >= (SAMPLE_RATE*2)) ? (REF_CLK/(SAMPLE_RATE*2) - 1) : 0;
localparam LRCK_2X_DIV_MAX = (REF_CLK >= (SAMPLE_RATE*4)) ? (REF_CLK/(SAMPLE_RATE*4) - 1) : 0;
localparam LRCK_4X_DIV_MAX = (REF_CLK >= (SAMPLE_RATE*8)) ? (REF_CLK/(SAMPLE_RATE*8) - 1) : 0;

//	Internal Registers and Wires
reg		[3:0]	BCK_DIV;
reg		[8:0]	LRCK_1X_DIV;
reg		[7:0]	LRCK_2X_DIV;
reg		[6:0]	LRCK_4X_DIV;
reg		[3:0]	SEL_Cont;
////////	DATA Counter	////////
reg		[5:0]	SIN_Cont;
reg		[FLASH_ADDR_WIDTH-1:0]	FLASH_Cont;
reg		[SDRAM_ADDR_WIDTH-1:0]	SDRAM_Cont;
reg		[SRAM_ADDR_WIDTH-1:0]	SRAM_Cont;
////////////////////////////////////
reg		[DATA_WIDTH-1:0]	Sin_Out;
reg		[DATA_WIDTH-1:0]	FLASH_Out;
reg		[DATA_WIDTH-1:0]	SDRAM_Out;
reg		[DATA_WIDTH-1:0]	SRAM_Out;
reg		[DATA_WIDTH-1:0]	FLASH_Out_Tmp;
reg		[DATA_WIDTH-1:0]	SDRAM_Out_Tmp;
reg		[DATA_WIDTH-1:0]	SRAM_Out_Tmp;
reg							LRCK_1X;
reg							LRCK_2X;
reg							LRCK_4X;
reg                         rAUD_BCK; // Internal reg for AUD_BCK

// DFT Muxed Clocks
wire dft_LRCK_1X;
wire dft_LRCK_