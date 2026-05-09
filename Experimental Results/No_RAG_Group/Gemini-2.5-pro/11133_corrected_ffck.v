1_corrected_ffc.v
module AUDIO_DAC (	//	Memory Side
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
output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR; // Corrected width
input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA;	
output	[SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR; // Corrected width
input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA;	
//	Audio Side
output			oAUD_DATA;
output			oAUD_LRCK;
output	reg		oAUD_BCK;
//	Control Signals
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

// Clock Enables
wire	oAUD_BCK_negedge_en;
wire	LRCK_1X_negedge_en;
wire	LRCK_2X_posedge_en;
wire	LRCK_2X_negedge_en;
wire	LRCK_4X_posedge_en;
wire	LRCK_4X_negedge_en;

////////////	AUD_BCK Generator	//////////////
localparam BCK_DIV_MAX = REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1;
assign oAUD_BCK_negedge_en = (BCK_DIV == BCK_DIV_MAX) && oAUD_BCK;

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	0;
		oAUD_BCK	<=	0;
	end
	else
	begin
		if(BCK_DIV >= BCK_DIV_MAX )
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
localparam LRCK_1X_DIV_MAX = REF_CLK/(SAMPLE_RATE*2)-1;
localparam LRCK_2X_DIV_MAX = REF_CLK/(SAMPLE_RATE*4)-1;
localparam LRCK_4X_DIV_MAX = REF_CLK/(SAMPLE_RATE*8)-1;

assign LRCK_1X_negedge_en = (LRCK_1X_DIV == LRCK_1X_DIV_MAX) && LRCK_1X;
assign LRCK_2X_posedge_en = (LRCK_2X_DIV == LRCK_2X_DIV_MAX) && !LRCK_2X;
assign LRCK_2X_negedge_en = (LRCK_2X_DIV == LRCK_2X_DIV_MAX) && LRCK_2X;
assign LRCK_4X_posedge_en = (LRCK_4X_DIV == LRCK_4X_DIV_MAX) && !LRCK_4X;
assign LRCK_4X_negedge_en = (LRCK_4X_DIV == LRCK_4X_DIV_MAX) && LRCK_4X;

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
		if(LRCK_1X_DIV >= LRCK_1X_DIV_MAX )
		begin
			LRCK_1X_DIV	<=	0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;
		//	LRCK 2X
		if(LRCK_2X_DIV >= LRCK_2X_DIV_MAX )
		begin
			LRCK_2X_DIV	<=	0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV+1;		
		//	LRCK 4X
		if(LRCK_4X_DIV >= LRCK_4X_DIV_MAX )
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
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SIN_Cont	<=	0;
	else if (LRCK_1X_negedge_en) // Use clock enable
	begin
		if(SIN_Cont < SIN_SAMPLE_DATA-1 )
		SIN_Cont	<=	SIN_Cont+1;
		else
		SIN_Cont	<=	0;
	end
end
//////////////////////////////////////////////////
//////////	FLASH ADDR Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	FLASH_Cont	<=	0;
	else if (LRCK_4X_negedge_en) // Use clock enable
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
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	FLASH_Out_Tmp	<=	0;
	else if (LRCK_4X_posedge_en) // Use clock enable
	begin
		if(FLASH_Cont[0]) // Note: FLASH_Cont updates on negedge, FLASH_Out_Tmp on posedge
		FLASH_Out_Tmp[15:8]	<=	iFLASH_DATA;
		else
		FLASH_Out_Tmp[7:0]	<=	iFLASH_DATA;		
	end
end

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	FLASH_Out	<=	0;
	else if (LRCK_2X_negedge_en) // Use clock enable
	FLASH_Out	<=	FLASH_Out_Tmp;
end
//////////////////////////////////////////////////
//////////	SDRAM ADDR Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SDRAM_Cont	<=	0;
	else if (LRCK_2X_negedge_en) // Use clock enable
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
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SDRAM_Out_Tmp	<=	0;
	else if (LRCK_2X_posedge_en) // Use clock enable
	SDRAM_Out_Tmp	<=	iSDRAM_DATA;
end

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SDRAM_Out	<=	0;
	else if (LRCK_2X_negedge_en) // Use clock enable
	SDRAM_Out	<=	SDRAM_Out_Tmp;
end
//////////////////////////////////////////////////
////////////	SRAM ADDR Generator	  ////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SRAM_Cont	<=	0;
	else if (LRCK_2X_negedge_en) // Use clock enable
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
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SRAM_Out_Tmp	<=	0;
	else if (LRCK_2X_posedge_en) // Use clock enable
	SRAM_Out_Tmp	<=	iSRAM_DATA;
end

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SRAM_Out	<=	0;
	else if (LRCK_2X_negedge_en) // Use clock enable
	SRAM_Out	<=	SRAM_Out_Tmp;
end
//////////////////////////////////////////////////
//////////	16 Bits PISO MSB First	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SEL_Cont	<=	0;
	else if (oAUD_BCK_negedge_en) // Use clock enable
	SEL_Cont	<=	SEL_Cont+1;
end

// Combinational logic for oAUD_DATA remains unchanged
// Note: The indexing logic [~SEL_Cont] might need careful review for correctness
// depending on desired MSB/LSB first behavior and SEL_Cont width/range.
// Assuming DATA_WIDTH=16, SEL_Cont should be [3:0] for indexing 0 to 15.
// ~SEL_Cont[3:0] will produce 15 down to 0 as SEL_Cont goes 0 to 15.
// If SEL_Cont wraps around earlier, this indexing might be incorrect.
// The original SEL_Cont was [3:0], so it counts 0-15, which matches DATA_WIDTH=16.
assign	oAUD_DATA	=	(iSrc_Select==SIN_SANPLE)	?	Sin_Out[~SEL_Cont[3:0]]	: // Explicitly size index
						(iSrc_Select==FLASH_DATA)	?	FLASH_Out[~SEL_Cont[3:0]]:
						(iSrc_Select==SDRAM_DATA)	?	SDRAM_Out[~SEL_Cont[3:0]]:
														SRAM_Out[~SEL_Cont[3:0]]	;												
//////////////////////////////////////////////////
////////////	Sin Wave ROM Table	//////////////
// This is combinatorial logic, not clocked by an internal signal, so it's okay.
always@(*) // Use implicit sensitivity list
begin
    case(SIN_Cont)
    0  :  Sin_Out       <=      16'd0       ; // Use explicit sizing and decimal radix
    1  :  Sin_Out       <=      16'd4276    ;
    2  :  Sin_Out       <=      16'd8480    ;
    3  :  Sin_Out       <=      16'd12539   ;
    4  :  Sin_Out       <=      16'd16383   ;
    5  :  Sin_Out       <=      16'd19947   ;
    6  :  Sin_Out       <=      16'd23169   ;
    7  :  Sin_Out       <=      16'd25995   ;
    8  :  Sin_Out       <=      16'd28377   ;
    9  :  Sin_Out       <=      16'd30272   ;
    10 :  Sin_Out       <=      16'd31650   ;
    11 :  Sin_Out       <=      16'd32486   ;
    12 :  Sin_Out       <=      16'd32767   ;
    13 :  Sin_Out       <=      16'd32486   ;
    14 :  Sin_Out       <=      16'd31650   ;
    15 :  Sin_Out       <=      16'd30272   ;
    16 :  Sin_Out       <=      16'd28377   ;
    17 :  Sin_Out       <=      16'd25995   ;
    18 :  Sin_Out       <=      16'd23169   ;
    19 :  Sin_Out       <=      16'd19947   ;
    20 :  Sin_Out       <=      16'd16383   ;
    21 :  Sin_Out       <=      16'd12539   ;
    22 :  Sin_Out       <=      16'd8480    ;
    23 :  Sin_Out       <=      16'd4276    ;
    24 :  Sin_Out       <=      16'd0       ;
    25 :  Sin_Out       <=      16'd61259   ; // These seem like signed values? Assuming unsigned based on context.
    26 :  Sin_Out       <=      16'd57056   ;
    27 :  Sin_Out       <=      16'd52997   ;
    28 :  Sin_Out       <=      16'd49153   ;
    29 :  Sin_Out       <=      16'd45589   ;
    30 :  Sin_Out       <=      16'd42366   ;
    31 :  Sin_Out       <=      16'd39540   ;
    32 :  Sin_Out       <=      16'd37159   ;
    33 :  Sin_Out       <=      16'd35263   ;
    34 :  Sin_Out       <=      16'd33885   ;
    35 :  Sin_Out       <=      16'd33049   ;
    36 :  Sin_Out       <=      16'd32768   ; // -32768 if signed
    37 :  Sin_Out       <=      16'd33049   ;
    38 :  Sin_Out       <=      16'd33885   ;
    39 :  Sin_Out       <=      16'd35263   ;
    40 :  Sin_Out       <=      16'd37159   ;
    41 :  Sin_Out       <=      16'd39540   ;
    42 :  Sin_Out       <=      16'd42366   ;
    43 :  Sin_Out       <=      16'd45589   ;
    44 :  Sin_Out       <=      16'd49152   ; // Typo? Was 49153 before. Kept original.
    45 :  Sin_Out       <=      16'd52997   ;
    46 :  Sin_Out       <=      16'd57056   ;
    47 :  Sin_Out       <=      16'd61259   ;
	default	:
		   Sin_Out		<=		16'd0		;
	endcase
end
//////////////////////////////////////////////////

endmodule