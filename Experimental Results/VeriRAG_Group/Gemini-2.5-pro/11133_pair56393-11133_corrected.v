module AUDIO_DAC (	//	Memory Side
					test_mode,
					oFLASH_ADDR,iFLASH_DATA,
					oSDRAM_ADDR,iSDRAM_DATA,
					oSRAM_ADDR,iSRAM_DATA,
					//	Audio Side
					oAUD_BCK,
					oAUD_DATA,
					oAUD_LRCK,
					//	Control Signals
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
output	[SDRAM_ADDR_WIDTH:0]	oSDRAM_ADDR;
input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA;
output	[SRAM_ADDR_WIDTH:0]		oSRAM_ADDR;
input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA;
//	Audio Side
output			oAUD_DATA;
output			oAUD_LRCK;
output	reg		oAUD_BCK;
//	Control Signals
input	[1:0]	iSrc_Select;
input			iCLK_18_4;
input			iRST_N;
input           test_mode; // DFT test mode input
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

// DFT Clock Wires
wire    LRCK_1X_dft;
wire    LRCK_2X_dft;
wire    LRCK_4X_dft;
wire    oAUD_BCK_dft;

// DFT Clock Muxing
assign LRCK_1X_dft = test_mode ? iCLK_18_4 : LRCK_1X;
assign LRCK_2X_dft = test_mode ? iCLK_18_4 : LRCK_2X;
assign LRCK_4X_dft = test_mode ? iCLK_18_4 : LRCK_4X;
assign oAUD_BCK_dft = test_mode ? iCLK_18_4 : oAUD_BCK;

////////////	AUD_BCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	0;
		oAUD_BCK	<=	0;
	end
	else
	begin
		if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 )
		begin
			BCK_DIV		<=	0;
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
		LRCK_1X_DIV	<=	0;
		LRCK_2X_DIV	<=	0;
		LRCK_4X_DIV	<=	0;
		LRCK_1X		<=	0;
		LRCK_2X		<=	0;
		LRCK_4X		<=	0;
	end
	else
	begin
		//	LRCK 1X
		if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1 )
		begin
			LRCK_1X_DIV	<=	0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;
		//	LRCK 2X
		if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1 )
		begin
			LRCK_2X_DIV	<=	0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV+1;
		//	LRCK 4X
		if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1 )
		begin
			LRCK_4X_DIV	<=	0;
			LRCK_4X	<=	~LRCK_4X;
		end
		else
		LRCK_4X_DIV		<=	LRCK_4X_DIV+1;
	end
end
assign	oAUD_LRCK	=	LRCK_1X;
//////////////////////////////////////////////////
//////////	Sin LUT ADDR Generator	//////////////
always@(negedge LRCK_1X_dft or negedge iRST_N)
begin
	if(!iRST_N)
	SIN_Cont	<=	0;
	else
	begin
		if(SIN_Cont < SIN_SAMPLE_DATA-1 )
		SIN_Cont	<=	SIN_Cont+1;
		else
		SIN_Cont	<=	0;
	end
end
//////////////////////////////////////////////////
//////////	FLASH ADDR Generator	//////////////
always@(negedge LRCK_4X_dft or negedge iRST_N)
begin
	if(!iRST_N)
	FLASH_Cont	<=	0;
	else
	begin
		if(FLASH_Cont < FLASH_DATA_NUM-1 )
		FLASH_Cont	<=	FLASH_Cont+1;
		else
		FLASH_Cont	<=	0;
	end
end
assign	oFLASH_ADDR	=	FLASH_Cont;
//////////////////////////////////////////////////
//////////	  FLASH DATA Reorder	//////////////
always@(posedge LRCK_4X_dft or negedge iRST_N)
begin
	if(!iRST_N)
	FLASH_Out_Tmp	<=	0;
	else
	begin
		if(FLASH_Cont[0])
		FLASH_Out_Tmp[15:8]	<=	iFLASH_DATA;
		else
		FLASH_Out_Tmp[7:0]	<=	iFLASH_DATA;
	end
end
always@(negedge LRCK_2X_dft	or negedge iRST_N)
begin
	if(!iRST_N)
	FLASH_Out	<=	0;
	else
	FLASH_Out	<=	FLASH_Out_Tmp;
end
//////////////////////////////////////////////////
//////////	SDRAM ADDR Generator	//////////////
always@(negedge LRCK_2X_dft or negedge iRST_N)
begin
	if(!iRST_N)
	SDRAM_Cont	<=	0;
	else
	begin
		if(SDRAM_Cont < SDRAM_DATA_NUM-1 )
		SDRAM_Cont	<=	SDRAM_Cont+1;
		else
		SDRAM_Cont	<=	0;
	end
end
assign	oSDRAM_ADDR	=	SDRAM_Cont;
//////////////////////////////////////////////////
//////////	  SDRAM DATA Latch		//////////////
always@(posedge LRCK_2X_dft or negedge iRST_N)
begin
	if(!iRST_N)
	SDRAM_Out_Tmp	<=	0;
	else
	SDRAM_Out_Tmp	<=	iSDRAM_DATA;
end
always@(negedge LRCK_2X_dft	or negedge iRST_N)
begin
	if(!iRST_N)
	SDRAM_Out	<=	0;
	else
	SDRAM_Out	<=	SDRAM_Out_Tmp;
end
//////////////////////////////////////////////////
////////////	SRAM ADDR Generator	  ////////////
always@(negedge LRCK_2X_dft or negedge iRST_N)
begin
	if(!iRST_N)
	SRAM_Cont	<=	0;
	else
	begin
		if(SRAM_Cont < SRAM_DATA_NUM-1 )
		SRAM_Cont	<=	SRAM_Cont+1;
		else
		SRAM_Cont	<=	0;
	end
end
assign	oSRAM_ADDR	=	SRAM_Cont;
//////////////////////////////////////////////////
//////////	  SRAM DATA Latch		//////////////
always@(posedge LRCK_2X_dft or negedge iRST_N)
begin
	if(!iRST_N)
	SRAM_Out_Tmp	<=	0;
	else
	SRAM_Out_Tmp	<=	iSRAM_DATA;
end
always@(negedge LRCK_2X_dft	or negedge iRST_N)
begin
	if(!iRST_N)
	SRAM_Out	<=	0;
	else
	SRAM_Out	<=	SRAM_Out_Tmp;
end
//////////////////////////////////////////////////
//////////	16 Bits PISO MSB First	//////////////
always@(negedge oAUD_BCK_dft or negedge iRST_N)
begin
	if(!iRST_N)
	SEL_Cont	<=	0;
	else
	SEL_Cont	<=	SEL_Cont+1;
end
assign	oAUD_DATA	=	(iSrc_Select==SIN_SANPLE)	?	Sin_Out[~SEL_Cont[3:0]]	: // Corrected indexing
						(iSrc_Select==FLASH_DATA)	?	FLASH_Out[~SEL_Cont[3:0]]: // Corrected indexing
						(iSrc_Select==SDRAM_DATA)	?	SDRAM_Out[~SEL_Cont[3:0]]: // Corrected indexing
														SRAM_Out[~SEL_Cont[3:0]]	; // Corrected indexing
//////////////////////////////////////////////////
////////////	Sin Wave ROM Table	//////////////
always@(*) // Changed sensitivity list for combinational logic
begin
    case(SIN_Cont)
    0  :  Sin_Out       =      0       ; // Changed to blocking assignment
    1  :  Sin_Out       =      4276    ; // Changed to blocking assignment
    2  :  Sin_Out       =      8480    ; // Changed to blocking assignment
    3  :  Sin_Out       =      12539   ; // Changed to blocking assignment
    4  :  Sin_Out       =      16383   ; // Changed to blocking assignment
    5  :  Sin_Out       =      19947   ; // Changed to blocking assignment
    6  :  Sin_Out       =      23169   ; // Changed to blocking assignment
    7  :  Sin_Out       =      25995   ; // Changed to blocking assignment
    8  :  Sin_Out       =      28377   ; // Changed to blocking assignment
    9  :  Sin_Out       =      30272   ; // Changed to blocking assignment
    10 :  Sin_Out       =      31650   ; // Changed to blocking assignment
    11 :  Sin_Out       =      32486   ; // Changed to blocking assignment
    12 :  Sin_Out       =      32767   ; // Changed to blocking assignment
    13 :  Sin_Out       =      32486   ; // Changed to blocking assignment
    14 :  Sin_Out       =      31650   ; // Changed to blocking assignment
    15 :  Sin_Out       =      30272   ; // Changed to blocking assignment
    16 :  Sin_Out       =      28377   ; // Changed to blocking assignment
    17 :  Sin_Out       =      25995   ; // Changed to blocking assignment
    18 :  Sin_Out       =      23169   ; // Changed to blocking assignment
    19 :  Sin_Out       =      19947   ; // Changed to blocking assignment
    20 :  Sin_Out       =      16383   ; // Changed to blocking assignment
    21 :  Sin_Out       =      12539   ; // Changed to blocking assignment
    22 :  Sin_Out       =      8480    ; // Changed to blocking assignment
    23 :  Sin_Out       =      4276    ; // Changed to blocking assignment
    24 :  Sin_Out       =      0       ; // Changed to blocking assignment
    25 :  Sin_Out       =      61259   ; // Changed to blocking assignment
    26 :  Sin_Out       =      57056   ; // Changed to blocking assignment
    27 :  Sin_Out       =      52997   ; // Changed to blocking assignment
    28 :  Sin_Out       =      49153   ; // Changed to blocking assignment
    29 :  Sin_Out       =      45589   ; // Changed to blocking assignment
    30 :  Sin_Out       =      42366   ; // Changed to blocking assignment
    31 :  Sin_Out       =      39540   ; // Changed to blocking assignment
    32 :  Sin_Out       =      37159   ; // Changed to blocking assignment
    33 :  Sin_Out       =      35263   ; // Changed to blocking assignment
    34 :  Sin_Out       =      33885   ; // Changed to blocking assignment
    35 :  Sin_Out       =      33049   ; // Changed to blocking assignment
    36 :  Sin_Out       =      32768   ; // Changed to blocking assignment
    37 :  Sin_Out       =      33049   ; // Changed to blocking assignment
    38 :  Sin_Out       =      33885   ; // Changed to blocking assignment
    39 :  Sin_Out       =      35263   ; // Changed to blocking assignment
    40 :  Sin_Out       =      37159   ; // Changed to blocking assignment
    41 :  Sin_Out       =      39540   ; // Changed to blocking assignment
    42 :  Sin_Out       =      42366   ; // Changed to blocking assignment
    43 :  Sin_Out       =      45589   ; // Changed to blocking assignment
    44 :  Sin_Out       =      49152   ; // Changed to blocking assignment
    45 :  Sin_Out       =      52997   ; // Changed to blocking assignment
    46 :  Sin_Out       =      57056   ; // Changed to blocking assignment
    47 :  Sin_Out       =      61259   ; // Changed to blocking assignment
	default	:
		   Sin_Out		=		0		; // Changed to blocking assignment
	endcase
end
//////////////////////////////////////////////////

endmodule