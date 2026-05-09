module AUDIO_DAC (	//	Memory Side
					oFLASH_ADDR,iFLASH_DATA,
					oSDRAM_ADDR,iSDRAM_DATA,
					oSRAM_ADDR,iSRAM_DATA,
					//	Audio Side
					oAUD_BCK,
					oAUD_DATA,
					oAUD_LRCK,
					//	Control Signals
					test_mode_i, // Added for DFT
					iSrc_Select,
				    iCLK_18_4,
					iRST_N	);

parameter	REF_CLK			=	18432000;	//	18.432	MHz
parameter	SAMPLE_RATE		=	48000;		//	48		KHz
parameter	DATA_WIDTH		=	16;			//	16		Bits
parameter	CHANNEL_NUM		=	2;			//	Dual Channel

parameter	SIN_SAMPLE_DATA	=	48;
parameter	FLASH_DATA_NUM	=	1048576;	//	1	MWords
parameter	SDRAM_DATA_NUM	=	4194304;	//	4	MWords
parameter	SRAM_DATA_NUM	=	262144;		//	256	KWords

parameter	FLASH_ADDR_WIDTH=	20;			//	20	Address Line
parameter	SDRAM_ADDR_WIDTH=	22;			//	22	Address Line
parameter	SRAM_ADDR_WIDTH=	18;			//	18	Address	Line

parameter	FLASH_DATA_WIDTH=	8;			//	8	Bits
parameter	SDRAM_DATA_WIDTH=	16;			//	16	Bits
parameter	SRAM_DATA_WIDTH=	16;			//	16	Bits

////////////	Input Source Number	//////////////
parameter	SIN_SANPLE		=	0;
parameter	FLASH_DATA		=	1;
parameter	SDRAM_DATA		=	2;
parameter	SRAM_DATA		=	3;
//////////////////////////////////////////////////
//	Memory Side
output	[FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR;
input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA;
output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR; // Corrected width
input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA;
output	[SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR; // Corrected width
input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA;
//	Audio Side
output			oAUD_DATA;
output			oAUD_LRCK;
output	reg		oAUD_BCK;
//	Control Signals
input			test_mode_i; // Added for DFT
input	[1:0]	iSrc_Select;
input			iCLK_18_4;
input			iRST_N;
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

// DFT Clock Mux Wires
wire dft_clk_LRCK_1X;
wire dft_clk_LRCK_2X;
wire dft_clk_LRCK_4X;
wire dft_clk_oAUD_BCK;

// DFT Clock Mux Assignments
assign dft_clk_LRCK_1X  = test_mode_i ? iCLK_18_4 : LRCK_1X;
assign dft_clk_LRCK_2X  = test_mode_i ? iCLK_18_4 : LRCK_2X;
assign dft_clk_LRCK_4X  = test_mode_i ? iCLK_18_4 : LRCK_4X;
assign dft_clk_oAUD_BCK = test_mode_i ? iCLK_18_4 : oAUD_BCK;

////////////	AUD_BCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	4'd0;
		oAUD_BCK	<=	1'b0;
	end
	else
	begin
		if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 )
		begin
			BCK_DIV		<=	4'd0;
			oAUD_BCK	<=	~oAUD_BCK;
		end
		else
		BCK_DIV		<=	BCK_DIV+1;
	end
end
//////////////////////////////////////////////////
////////////	AUD_LRCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LRCK_1X_DIV	<=	9'd0;
		LRCK_2X_DIV	<=	8'd0;
		LRCK_4X_DIV	<=	7'd0;
		LRCK_1X		<=	1'b0;
		LRCK_2X		<=	1'b0;
		LRCK_4X		<=	1'b0;
	end
	else
	begin
		//	LRCK 1X
		if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1 )
		begin
			LRCK_1X_DIV	<=	9'd0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;
		//	LRCK 2X
		if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1 )
		begin
			LRCK_2X_DIV	<=	8'd0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV+1;
		//	LRCK 4X
		if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1 )
		begin
			LRCK_4X_DIV	<=	7'd0;
			LRCK_4X	<=	~LRCK_4X;
		end
		else
		LRCK_4X_DIV		<=	LRCK_4X_DIV+1;
	end
end
assign	oAUD_LRCK	=	LRCK_1X;
//////////////////////////////////////////////////
//////////	Sin LUT ADDR Generator	//////////////
always@(negedge dft_clk_LRCK_1X or negedge iRST_N) // Changed clock
begin
	if(!iRST_N)
	SIN_Cont	<=	6'd0;
	else
	begin
		if(SIN_Cont < SIN_SAMPLE_DATA-1 )
		SIN_Cont	<=	SIN_Cont+1;
		else
		SIN_Cont	<=	6'd0;
	end
end
//////////////////////////////////////////////////
//////////	FLASH ADDR Generator	//////////////
always@(negedge dft_clk_LRCK_4X or negedge iRST_N) // Changed clock
begin
	if(!iRST_N)
	FLASH_Cont	<=	{FLASH_ADDR_WIDTH{1'b0}};
	else
	begin
		if(FLASH_Cont < FLASH_DATA_NUM-1 )
		FLASH_Cont	<=	FLASH_Cont+1;
		else
		FLASH_Cont	<=