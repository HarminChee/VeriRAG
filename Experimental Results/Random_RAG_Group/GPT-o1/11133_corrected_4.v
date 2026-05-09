`timescale 1ns / 1ps
module AUDIO_DAC (
	// Memory Side
	output	[FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR,
	input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA,
	output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR,
	input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA,
	output	[SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR,
	input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA,
	// Audio Side
	output			oAUD_BCK,
	output			oAUD_DATA,
	output			oAUD_LRCK,
	// Control Signals
	input	[1:0]	iSrc_Select,
	input			iCLK_18_4,
	input			iRST_N
);

parameter	REF_CLK			=	18432000;	
parameter	SAMPLE_RATE		=	48000;		
parameter	DATA_WIDTH		=	16;			
parameter	CHANNEL_NUM		=	2;			

parameter	SIN_SAMPLE_DATA	=	48;
parameter	FLASH_DATA_NUM	=	1048576;	
parameter	SDRAM_DATA_NUM	=	4194304;	
parameter	SRAM_DATA_NUM	=	262144;		

parameter	FLASH_ADDR_WIDTH=	20;			
parameter	SDRAM_ADDR_WIDTH=	22;			
parameter	SRAM_ADDR_WIDTH	=	18;			

parameter	FLASH_DATA_WIDTH=	8;			
parameter	SDRAM_DATA_WIDTH=	16;			
parameter	SRAM_DATA_WIDTH=	16;			

parameter	SIN_SAMPLE		=	0;
parameter	FLASH_DATA		=	1;
parameter	SDRAM_DATA		=	2;
parameter	SRAM_DATA		=	3;

localparam integer BCK_LIMIT     = REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2);
localparam integer LRCK_1X_LIMIT = REF_CLK/(SAMPLE_RATE*2);
localparam integer LRCK_2X_LIMIT = REF_CLK/(SAMPLE_RATE*4);
localparam integer LRCK_4X_LIMIT = REF_CLK/(SAMPLE_RATE*8);

reg		[3:0]	BCK_DIV;
reg				rAUD_BCK;
reg		[8:0]	LRCK_1X_DIV;
reg		[7:0]	LRCK_2X_DIV;
reg		[6:0]	LRCK_4X_DIV;
reg				LRCK_1X;
reg				LRCK_2X;
reg				LRCK_4X;

reg		[3:0]	SEL_Cont;
reg		[5:0]	SIN_Cont;
reg		[FLASH_ADDR_WIDTH-1:0]	FLASH_Cont;
reg		[SDRAM_ADDR_WIDTH-1:0]	SDRAM_Cont;
reg		[SRAM_ADDR_WIDTH-1:0]	SRAM_Cont;

reg		[DATA_WIDTH-1:0]	Sin_Out;
reg		[DATA_WIDTH-1:0]	FLASH_Out;
reg		[DATA_WIDTH-1:0]	SDRAM_Out;
reg		[DATA_WIDTH-1:0]	SRAM_Out;
reg		[DATA_WIDTH-1:0]	FLASH_Out_Tmp;
reg		[DATA_WIDTH-1:0]	SDRAM_Out_Tmp;
reg		[DATA_WIDTH-1:0]	SRAM_Out_Tmp;

reg				old_LRCK_1X;
reg				old_LRCK_2X;
reg				old_LRCK_4X;
reg				old_rAUD_BCK;

wire			lrck_1x_negedge;
wire			lrck_2x_negedge;
wire			lrck_4x_negedge;
wire			lrck_4x_posedge;
wire			lrck_2x_posedge;
wire			rAUD_BCK_negedge;

assign oAUD_BCK   = rAUD_BCK;
assign oAUD_LRCK  = LRCK_1X;
assign oFLASH_ADDR= FLASH_Cont;
assign oSDRAM_ADDR= SDRAM_Cont;
assign oSRAM_ADDR = SRAM_Cont;

assign lrck_1x_negedge   = old_LRCK_1X & (~LRCK_1X);
assign lrck_2x_negedge   = old_LRCK_2X & (~LRCK_2X);
assign lrck_4x_negedge   = old_LRCK_4X & (~LRCK_4X);
assign lrck_4x_posedge   = (~old_LRCK_4X) & LRCK_4X;
assign lrck_2x_posedge   = (~old_LRCK_2X) & LRCK_2X;
assign rAUD_BCK_negedge  = old_rAUD_BCK & (~rAUD_BCK);

always @(posedge iCLK_18_4)
begin
	if(!iRST_N)
	begin
		BCK_DIV       <= 0;
		rAUD_BCK      <= 0;
		LRCK_1X_DIV   <= 0;
		LRCK_2X_DIV   <= 0;
		LRCK_4X_DIV   <= 0;
		LRCK_1X       <= 0;
		LRCK_2X       <= 0;
		LRCK_4X       <= 0;
		SEL_Cont      <= 0;
		SIN_Cont      <= 0;
		FLASH_Cont    <= 0;
		SDRAM_Cont    <= 0;
		SRAM_Cont     <= 0;
		FLASH_Out     <= 0;
		SDRAM_Out     <= 0;
		SRAM_Out      <= 0;
		FLASH_Out_Tmp <= 0;
		SDRAM_Out_Tmp <= 0;
		SRAM_Out_Tmp  <= 0;
		old_LRCK_1X   <= 0;
		old_LRCK_2X   <= 0;
		old_LRCK_4X   <= 0;
		old_rAUD_BCK  <= 0;
	end
	else
	begin
		old_LRCK_1X   <= LRCK_1X;
		old_LRCK_2X   <= LRCK_2X;
		old_LRCK_4X   <= LRCK_4X;
		old_rAUD_BCK  <= rAUD_BCK;

		if(BCK_DIV >= (BCK_LIMIT-1))
		begin
			BCK_DIV  <= 0;
			rAUD_BCK <= ~rAUD_BCK;
		end
		else
			BCK_DIV <= BCK_DIV + 1;

		if(LRCK_1X_DIV >= (LRCK_1X_LIMIT-1))
		begin
			LRCK_1X_DIV <= 0;
			LRCK_1X     <= ~LRCK_1X;
		end
		else
			LRCK_1X_DIV <= LRCK_1X_DIV + 1;

		if(LRCK_2X_DIV >= (LRCK_2X_LIMIT-1))
		begin
			LRCK_2X_DIV <= 0;
			LRCK_2X     <= ~LRCK_2X;
		end
		else
			LRCK_2X_DIV <= LRCK_2X_DIV + 1;

		if(LRCK_4X_DIV >= (LRCK_4X_LIMIT-1))
		begin
			LRCK_4X_DIV <= 0;
			LRCK_4X     <= ~LRCK_4X;
		end
		else
			LRCK_4X_DIV <= LRCK_4X_DIV + 1;

		if(lrck_1x_negedge)
		begin
			if(SIN_Cont < SIN_SAMPLE_DATA-1)
				SIN_Cont <= SIN_Cont + 1;
			else
				SIN_Cont <= 0;
		end

		if(lrck_4x_negedge)
		begin
			if(FLASH_Cont < FLASH_DATA_NUM-1)
				FLASH_Cont <= FLASH_Cont + 1;
			else
				FLASH_Cont <= 0;
		end

		if(lrck_4x_posedge)
		begin
			if(FLASH_Cont[0])
				FLASH_Out_Tmp[15:8] <= iFLASH_DATA;
			else
				FLASH_Out_Tmp[7:0]  <= iFLASH_DATA;
		end
		if(lrck_2x_negedge)
			FLASH_Out <= FLASH_Out_Tmp;

		if(lrck_2x_negedge)
		begin
			if(SDRAM_Cont < SDRAM_DATA_NUM-1)
				SDRAM_Cont <= SDRAM_Cont + 1;
			else
				SDRAM_Cont <= 0;
		end

		if(lrck_2x_posedge)
			SDRAM_Out_Tmp <= iSDRAM_DATA;
		if(lrck_2x_negedge)
			SDRAM_Out <= SDRAM_Out_Tmp;

		if(lrck_2x_negedge)
		begin
			if(SRAM_Cont < SRAM_DATA_NUM-1)
				SRAM_Cont <= SRAM_Cont + 1;
			else
				SRAM_Cont <= 0;
		end

		if(lrck_2x_posedge)
			SRAM_Out_Tmp <= iSRAM_DATA;
		if(lrck_2x_negedge)
			SRAM_Out <= SRAM_Out_Tmp;

		if(rAUD_BCK_negedge)
			SEL_Cont <= SEL_Cont + 1;
	end
end

assign oAUD_DATA = (iSrc_Select == SIN_SAMPLE) ? Sin_Out[~SEL_Cont] :
                   (iSrc_Select == FLASH_DATA)? FLASH_Out[~SEL_Cont]:
                   (iSrc_Select == SDRAM_DATA)? SDRAM_Out[~SEL_Cont] :
                                                SRAM_Out[~SEL_Cont];

always @(*)
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