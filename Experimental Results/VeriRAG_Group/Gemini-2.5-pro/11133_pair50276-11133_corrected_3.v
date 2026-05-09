module AUDIO_DAC #(
    // Define parameters used in port list here
    parameter FLASH_ADDR_WIDTH= 20,
    parameter FLASH_DATA_WIDTH= 8,
    parameter SDRAM_ADDR_WIDTH= 22,
    parameter SDRAM_DATA_WIDTH= 16,
    parameter SRAM_ADDR_WIDTH = 18,
    parameter SRAM_DATA_WIDTH = 16,
    // Other parameters can stay inside or be moved here
    parameter REF_CLK         = 18432000, // 18.432 MHz
    parameter SAMPLE_RATE     = 48000,    // 48 KHz
    parameter DATA_WIDTH      = 16,       // 16 Bits
    parameter CHANNEL_NUM     = 2         // Dual Channel
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
                    input 							test_mode // Added for DFT
                    );

// Remaining parameters that are not used in port list
parameter	SIN_SAMPLE_DATA	=	48;
parameter	FLASH_DATA_NUM	=	1048576;	//	1	MWords
parameter	SDRAM_DATA_NUM	=	4194304;	//	4	MWords
parameter	SRAM_DATA_NUM	=	262144;		//	256	KWords

////////////	Input Source Number	//////////////
parameter	SIN_SANPLE		=	0;
parameter	FLASH_DATA		=	1;
parameter	SDRAM_DATA		=	2;
parameter	SRAM_DATA		=	3;
//////////////////////////////////////////////////

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
reg							oAUD_BCK_reg; // Renamed from oAUD_BCK

// DFT clock muxing
wire dft_LRCK_1X;
wire dft_LRCK_2X;
wire dft_LRCK_4X;
wire dft_oAUD_BCK;

assign dft_LRCK_1X = test_mode ? iCLK_18_4 : LRCK_1X;
assign dft_LRCK_2X = test_mode ? iCLK_18_4 : LRCK_2X;
assign dft_LRCK_4X = test_mode ? iCLK_18_4 : LRCK_4X;
assign dft_oAUD_BCK = test_mode ? iCLK_18_4 : oAUD_BCK_reg; // Use internal reg for muxing
assign oAUD_BCK = oAUD_BCK_reg; // Assign reg to output


////////////	AUD_BCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	4'd0;
		oAUD_BCK_reg	<=	1'b0; // Drive internal reg
	end
	else
	begin
		if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 )
		begin
			BCK_DIV		<=	4'd0;
			oAUD_BCK_reg	<=	~oAUD_BCK_reg; // Drive internal reg
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
always@(negedge dft_LRCK_1X or negedge iRST_N) // Modified for DFT
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
always@(negedge dft_LRCK_4X or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	FLASH_Cont	<=	{FLASH_ADDR_WIDTH{1'b0}};
	else
	begin
		if(FLASH_Cont < FLASH_DATA_NUM-1 )
		FLASH_Cont	<=	FLASH_Cont+1;
		else
		FLASH_Cont	<=	{FLASH_ADDR_WIDTH{1'b0}};
	end
end
assign	oFLASH_ADDR	=	FLASH_Cont;
//////////////////////////////////////////////////
//////////	  FLASH DATA Reorder	//////////////
always@(posedge dft_LRCK_4X or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	FLASH_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
	begin
		if(FLASH_Cont[0])
		FLASH_Out_Tmp[DATA_WIDTH-1 : DATA_WIDTH/2]	<=	iFLASH_DATA; // Use parameters
		else
		FLASH_Out_Tmp[DATA_WIDTH/2-1 : 0]	<=	iFLASH_DATA; // Use parameters
	end
end
always@(negedge dft_LRCK_2X	or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	FLASH_Out	<=	{DATA_WIDTH{1'b0}};
	else
	FLASH_Out	<=	FLASH_Out_Tmp;
end
//////////////////////////////////////////////////
//////////	SDRAM ADDR Generator	//////////////
always@(negedge dft_LRCK_2X or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	SDRAM_Cont	<=	{SDRAM_ADDR_WIDTH{1'b0}};
	else
	begin
		if(SDRAM_Cont < SDRAM_DATA_NUM-1 )
		SDRAM_Cont	<=	SDRAM_Cont+1;
		else
		SDRAM_Cont	<=	{SDRAM_ADDR_WIDTH{1'b0}};
	end
end
assign	oSDRAM_ADDR	=	SDRAM_Cont;
//////////////////////////////////////////////////
//////////	  SDRAM DATA Latch		//////////////
always@(posedge dft_LRCK_2X or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	SDRAM_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
	SDRAM_Out_Tmp	<=	iSDRAM_DATA;
end
always@(negedge dft_LRCK_2X	or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	SDRAM_Out	<=	{DATA_WIDTH{1'b0}};
	else
	SDRAM_Out	<=	SDRAM_Out_Tmp;
end
//////////////////////////////////////////////////
////////////	SRAM ADDR Generator	  ////////////
always@(negedge dft_LRCK_2X or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	SRAM_Cont	<=	{SRAM_ADDR_WIDTH{1'b0}};
	else
	begin
		if(SRAM_Cont < SRAM_DATA_NUM-1 )
		SRAM_Cont	<=	SRAM_Cont+1;
		else
		SRAM_Cont	<=	{SRAM_ADDR_WIDTH{1'b0}};
	end
end
assign	oSRAM_ADDR	=	SRAM_Cont;
//////////////////////////////////////////////////
//////////	  SRAM DATA Latch		//////////////
always@(posedge dft_LRCK_2X or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	SRAM_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
	SRAM_Out_Tmp	<=	iSRAM_DATA;
end
always@(negedge dft_LRCK_2X	or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	SRAM_Out	<=	{DATA_WIDTH{1'b0}};
	else
	SRAM_Out	<=	SRAM_Out_Tmp;
end
//////////////////////////////////////////////////
//////////	16 Bits PISO MSB First	//////////////
always@(negedge dft_oAUD_BCK or negedge iRST_N) // Modified for DFT
begin
	if(!iRST_N)
	SEL_Cont	<=	4'd0;
	else
	SEL_Cont	<=	SEL_Cont+1;
end
assign	oAUD_DATA	=	(iSrc_Select==SIN_SANPLE)	?	Sin_Out[DATA_WIDTH-1-SEL_Cont[3:0]]	: // Corrected indexing for MSB first
						(iSrc_Select==FLASH_DATA)	?	FLASH_Out[DATA_WIDTH-1-SEL_Cont[3:0]]:
						(iSrc_Select==SDRAM_DATA)	?	SDRAM_Out[DATA_WIDTH-1-SEL_Cont[3:0]]:
														SRAM_Out[DATA_WIDTH-1-SEL_Cont[3:0]]	;
//////////////////////////////////////////////////
////////////	Sin Wave ROM Table	//////////////
// Using explicit width constants for better clarity and potential tool compatibility
localparam [DATA_WIDTH-1:0] SIN_0  = 16'd0     ;
localparam [DATA_WIDTH-1:0] SIN_1  = 16'd4276  ;
localparam [DATA_WIDTH-1:0] SIN_2  = 16'd8480  ;
localparam [DATA_WIDTH-1:0] SIN_3  = 16'd12539 ;
localparam [DATA_WIDTH-1:0] SIN_4  = 16'd16383 ;
localparam [DATA_WIDTH-1:0] SIN_5  = 16'd19947 ;
localparam [DATA_WIDTH-1:0] SIN_6  = 16'd23169 ;
localparam [DATA_WIDTH-1:0] SIN_7  = 16'd25995 ;
localparam [DATA_WIDTH-1:0] SIN_8  = 16'd28377 ;
localparam [DATA_WIDTH-1:0] SIN_9  = 16'd30272 ;
localparam [DATA_WIDTH-1:0] SIN_10 = 16'd31650 ;
localparam [DATA_WIDTH-1:0] SIN_11 = 16'd32486 ;
localparam [DATA_WIDTH-1:0] SIN_12 = 16'd32767 ;
localparam [DATA_WIDTH-1:0] SIN_13 = 16'd32486 ;
localparam [DATA_WIDTH-1:0] SIN_14 = 16'd31650 ;
localparam [DATA_WIDTH-1:0] SIN_15 = 16'd30272 ;
localparam [DATA_WIDTH-1:0] SIN_16 = 16'd28377 ;
localparam [DATA_WIDTH-1:0] SIN_17 = 16'd25995 ;
localparam [DATA_WIDTH-1:0] SIN_18 = 16'd23169 ;
localparam [DATA_WIDTH-1:0] SIN_19 = 16'd19947 ;
localparam [DATA_WIDTH-1:0] SIN_20 = 16'd16383 ;
localparam [DATA_WIDTH-1:0] SIN_21 = 16'd12539 ;
localparam [DATA_WIDTH-1:0] SIN_22 = 16'd8480  ;
localparam [DATA_WIDTH-1:0] SIN_23 = 16'd4276  ;
localparam [DATA_WIDTH-1:0] SIN_24 = 16'd0     ;
localparam [DATA_WIDTH-1:0] SIN_25 = 16'sd-4276; // Use signed decimal for clarity
localparam [DATA_WIDTH-1:0] SIN_26 = 16'sd-8480;
localparam [DATA_WIDTH-1:0] SIN_27 = 16'sd-12539;
localparam [DATA_WIDTH-1:0] SIN_28 = 16'sd-16383;
localparam [DATA_WIDTH-1:0] SIN_29 = 16'sd-19947;
localparam [DATA_WIDTH-1:0] SIN_30 = 16'sd-23169;