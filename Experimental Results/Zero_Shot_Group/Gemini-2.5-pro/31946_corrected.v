module AUDIO_DAC (
					oFLASH_ADDR,iFLASH_DATA,
					oSDRAM_ADDR,iSDRAM_DATA,
					oSRAM_ADDR,iSRAM_DATA,
					oAUD_BCK,
					oAUD_DATA,
					oAUD_LRCK,
					iSrc_Select,
				    iCLK_18_4,
					iRST_N	);
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
parameter	SRAM_ADDR_WIDTH=	18;
parameter	FLASH_DATA_WIDTH=	8;
parameter	SDRAM_DATA_WIDTH=	16;
parameter	SRAM_DATA_WIDTH=	16;
parameter	SIN_SAMPLE		=	0; // Corrected typo from SIN_SANPLE
parameter	FLASH_DATA		=	1;
parameter	SDRAM_DATA		=	2;
parameter	SRAM_DATA		=	3;

output	[FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR;
input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA;
output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR; // Corrected width
input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA;
output	[SRAM_ADDR_WIDTH-1:0]		oSRAM_ADDR; // Corrected width
input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA;
output			oAUD_DATA;
output			oAUD_LRCK;
output	reg		oAUD_BCK;
input	[1:0]	iSrc_Select;
input			iCLK_18_4;
input			iRST_N;

reg		[3:0]	BCK_DIV;
reg		[8:0]	LRCK_1X_DIV;
reg		[7:0]	LRCK_2X_DIV;
reg		[6:0]	LRCK_4X_DIV;
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
reg							LRCK_1X;
reg							LRCK_2X;
reg							LRCK_4X;

// BCK Generation
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	4'd0;
		oAUD_BCK	<=	1'b0;
	end
	else
	begin
		if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 ) // Note: Integer division
		begin
			BCK_DIV		<=	4'd0;
			oAUD_BCK	<=	~oAUD_BCK;
		end
		else
			BCK_DIV		<=	BCK_DIV + 1'b1;
	end
end

// LRCK Generation (1x, 2x, 4x Sample Rate)
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
		// LRCK 1x
		if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1 ) // Note: Integer division
		begin
			LRCK_1X_DIV	<=	9'd0;
			LRCK_1X		<=	~LRCK_1X;
		end
		else
			LRCK_1X_DIV	<=	LRCK_1X_DIV + 1'b1;

		// LRCK 2x
		if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1 ) // Note: Integer division
		begin
			LRCK_2X_DIV	<=	8'd0;
			LRCK_2X		<=	~LRCK_2X;
		end
		else
			LRCK_2X_DIV	<=	LRCK_2X_DIV + 1'b1;

		// LRCK 4x
		if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1 ) // Note: Integer division
		begin
			LRCK_4X_DIV	<=	7'd0;
			LRCK_4X		<=	~LRCK_4X;
		end
		else
			LRCK_4X_DIV	<=	LRCK_4X_DIV + 1'b1;
	end
end

assign	oAUD_LRCK	=	LRCK_1X;

// Sin Wave Counter
always@(negedge LRCK_1X or negedge iRST_N)
begin
	if(!iRST_N)
		SIN_Cont	<=	6'd0;
	else
	begin
		if(SIN_Cont < SIN_SAMPLE_DATA-1 )
			SIN_Cont	<=	SIN_Cont + 1'b1;
		else
			SIN_Cont	<=	6'd0;
	end
end

// FLASH Address Counter
always@(negedge LRCK_4X or negedge iRST_N)
begin
	if(!iRST_N)
		FLASH_Cont	<=	{FLASH_ADDR_WIDTH{1'b0}};
	else
	begin
		if(FLASH_Cont < FLASH_DATA_NUM-1 )
			FLASH_Cont	<=	FLASH_Cont + 1'b1;
		else
			FLASH_Cont	<=	{FLASH_ADDR_WIDTH{1'b0}};
	end
end
assign	oFLASH_ADDR	=	FLASH_Cont;

// FLASH Data Input Stage 1 (Byte Assembly)
always@(posedge LRCK_4X or negedge iRST_N)
begin
	if(!iRST_N)
		FLASH_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
	begin
		// Use value of FLASH_Cont stable at posedge (updated on previous negedge)
		if(FLASH_Cont[0]) // Odd address -> Upper byte
			FLASH_Out_Tmp[DATA_WIDTH-1 : DATA_WIDTH/2]	<=	iFLASH_DATA;
		else // Even address -> Lower byte
			FLASH_Out_Tmp[DATA_WIDTH/2-1 : 0]	<=	iFLASH_DATA;
	end
end

// FLASH Data Input Stage 2 (Final Register)
always@(negedge LRCK_2X	or negedge iRST_N)
begin
	if(!iRST_N)
		FLASH_Out	<=	{DATA_WIDTH{1'b0}};
	else
		FLASH_Out	<=	FLASH_Out_Tmp;
end

// SDRAM Address Counter
always@(negedge LRCK_2X or negedge iRST_N)
begin
	if(!iRST_N)
		SDRAM_Cont	<=	{SDRAM_ADDR_WIDTH{1'b0}};
	else
	begin
		if(SDRAM_Cont < SDRAM_DATA_NUM-1 )
			SDRAM_Cont	<=	SDRAM_Cont + 1'b1;
		else
			SDRAM_Cont	<=	{SDRAM_ADDR_WIDTH{1'b0}};
	end
end
assign	oSDRAM_ADDR	=	SDRAM_Cont;

// SDRAM Data Input Stage 1
// Captures data presumably valid around posedge LRCK_2X
always@(posedge LRCK_2X or negedge iRST_N)
begin
	if(!iRST_N)
		SDRAM_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
		SDRAM_Out_Tmp	<=	iSDRAM_DATA;
end

// SDRAM Data Input Stage 2 (Final Register)
// Uses data captured on previous posedge LRCK_2X
always@(negedge LRCK_2X	or negedge iRST_N)
begin
	if(!iRST_N)
		SDRAM_Out	<=	{DATA_WIDTH{1'b0}};
	else
		SDRAM_Out	<=	SDRAM_Out_Tmp;
end

// SRAM Address Counter
always@(negedge LRCK_2X or negedge iRST_N)
begin
	if(!iRST_N)
		SRAM_Cont	<=	{SRAM_ADDR_WIDTH{1'b0}};
	else
	begin
		if(SRAM_Cont < SRAM_DATA_NUM-1 )
			SRAM_Cont	<=	SRAM_Cont + 1'b1;
		else
			SRAM_Cont	<=	{SRAM_ADDR_WIDTH{1'b0}};
	end
end
assign	oSRAM_ADDR	=	SRAM_Cont;

// SRAM Data Input Stage 1
// Captures data presumably valid around posedge LRCK_2X
always@(posedge LRCK_2X or negedge iRST_N)
begin
	if(!iRST_N)
		SRAM_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
		SRAM_Out_Tmp	<=	iSRAM_DATA;
end

// SRAM Data Input Stage 2 (Final Register)
// Uses data captured on previous posedge LRCK_2X
always@(negedge LRCK_2X	or negedge iRST_N)
begin
	if(!iRST_N)
		SRAM_Out	<=	{DATA_WIDTH{1'b0}};
	else
		SRAM_Out	<=	SRAM_Out_Tmp;
end

// Serial Output Bit Counter
always@(negedge oAUD_BCK or negedge iRST_N)
begin
	if(!iRST_N)
		SEL_Cont	<=	4'd0;
	else
	// Counter wraps automatically due to 4-bit width
		SEL_Cont	<=	SEL_Cont + 1'b1;
end

// Output Data Selection and Serialization (MSB first)
assign	oAUD_DATA	=	(iSrc_Select==SIN_SAMPLE)	?	Sin_Out[DATA_WIDTH-1 - SEL_Cont]	: // Corrected indexing and typo
						(iSrc_Select==FLASH_DATA)	?	FLASH_Out[DATA_WIDTH-1 - SEL_Cont]: // Corrected indexing
						(iSrc_Select==SDRAM_DATA)	?	SDRAM_Out[DATA_WIDTH-1 - SEL_Cont]: // Corrected indexing
														SRAM_Out[DATA_WIDTH-1 - SEL_Cont]	; // Corrected indexing

// Sin Wave ROM (Combinational)
always@(SIN_Cont)
begin
    case(SIN_Cont) // Use blocking assignments in combinational block
    0  :  Sin_Out       =      16'd0       ;
    1  :  Sin_Out       =      16'd4276    ;
    2  :  Sin_Out       =      16'd8480    ;
    3  :  Sin_Out       =      16'd12539   ;
    4  :  Sin_Out       =      16'd16383   ;
    5  :  Sin_Out       =      16'd19947   ;
    6  :  Sin_Out       =      16'd23169   ;
    7  :  Sin_Out       =      16'd25995   ;
    8  :  Sin_Out       =      16'd28377   ;
    9  :  Sin_Out       =      16'd30272   ;
    10 :  Sin_Out       =      16'd31650   ;
    11 :  Sin_Out       =      16'd32486   ;
    12 :  Sin_Out       =      16'd32767   ;
    13 :  Sin_Out       =      16'd32486   ;
    14 :  Sin_Out       =      16'd31650   ;
    15 :  Sin_Out       =      16'd30272   ;
    16 :  Sin_Out       =      16'd28377   ;
    17 :  Sin_Out       =      16'd25995   ;
    18 :  Sin_Out       =      16'd23169   ;
    19 :  Sin_Out       =      16'd19947   ;
    20 :  Sin_Out       =      16'd16383   ;
    21 :  Sin_Out       =      16'd12539   ;
    22 :  Sin_Out       =      16'd8480    ;
    23 :  Sin_Out       =      16'd4276    ;
    24 :  Sin_Out       =      16'd0       ;
    25 :  Sin_Out       =      16'd61259   ; // Assuming 2's complement for negative values
    26 :  Sin_Out       =      16'd57056   ; // -8480
    27 :  Sin_Out       =      16'd52997   ; // -12539
    28 :  Sin_Out       =      16'd49153   ; // -16383
    29 :  Sin_Out       =      16'd45589   ; // -19947
    30 :  Sin_Out       =      16'd42366   ; // -23169
    31 :  Sin_Out       =      16'd39540   ; // -25995
    32 :  Sin_Out       =      16'd37159   ; // -28377
    33 :  Sin_Out       =      16'd35263   ; // -30272
    34 :  Sin_Out       =      16'd33885   ; // -31650
    35 :  Sin_Out       =      16'd33049   ; // -32486
    36 :  Sin_Out       =      16'd32768   ; // -32768 (or min value)
    37 :  Sin_Out       =      16'd33049   ; // -32486
    38 :  Sin_Out       =      16'd33885   ; // -31650
    39 :  Sin_Out       =      16'd35263   ; // -30272
    40 :  Sin_Out       =      16'd37159   ; // -28377
    41 :  Sin_Out       =      16'd39540   ; // -25995
    42 :  Sin_Out       =      16'd42366   ; // -23169
    43 :  Sin_Out       =      16'd45589   ; // -19947
    44 :  Sin_Out       =      16'd49152   ; // -16384 (close to -16383)
    45 :  Sin_Out       =      16'd52997   ; // -12539
    46 :  Sin_Out       =      16'd57056   ; // -8480
    47 :  Sin_Out       =      16'd61259   ; // -4276
	default	:
		   Sin_Out		=		16'd0		;
	endcase
end

endmodule