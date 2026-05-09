module AUDIO_DAC (	//	Memory Side
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
		FLASH_Out_Tmp[15:8]	<=	iFLASH_DATA;
		else
		FLASH_Out_Tmp[7:0]	<=	iFLASH_DATA;
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
assign	oAUD_DATA	=	(iSrc_Select==SIN_SANPLE)	?	Sin_Out[~SEL_Cont[3:0]]	:
						(iSrc_Select==FLASH_DATA)	?	FLASH_Out[~SEL_Cont[3:0]]:
						(iSrc_Select==SDRAM_DATA)	?	SDRAM_Out[~SEL_Cont[3:0]]:
														SRAM_Out[~SEL_Cont[3:0]]	;
//////////////////////////////////////////////////
////////////	Sin Wave ROM Table	//////////////
// Using explicit width constants for better clarity and potential tool compatibility
localparam SIN_0  = 16'd0     ;
localparam SIN_1  = 16'd4276  ;
localparam SIN_2  = 16'd8480  ;
localparam SIN_3  = 16'd12539 ;
localparam SIN_4  = 16'd16383 ;
localparam SIN_5  = 16'd19947 ;
localparam SIN_6  = 16'd23169 ;
localparam SIN_7  = 16'd25995 ;
localparam SIN_8  = 16'd28377 ;
localparam SIN_9  = 16'd30272 ;
localparam SIN_10 = 16'd31650 ;
localparam SIN_11 = 16'd32486 ;
localparam SIN_12 = 16'd32767 ;
localparam SIN_13 = 16'd32486 ;
localparam SIN_14 = 16'd31650 ;
localparam SIN_15 = 16'd30272 ;
localparam SIN_16 = 16'd28377 ;
localparam SIN_17 = 16'd25995 ;
localparam SIN_18 = 16'd23169 ;
localparam SIN_19 = 16'd19947 ;
localparam SIN_20 = 16'd16383 ;
localparam SIN_21 = 16'd12539 ;
localparam SIN_22 = 16'd8480  ;
localparam SIN_23 = 16'd4276  ;
localparam SIN_24 = 16'd0     ;
localparam SIN_25 = 16'd61259 ; // Corresponds to -4276
localparam SIN_26 = 16'd57056 ; // Corresponds to -8480
localparam SIN_27 = 16'd52997 ; // Corresponds to -12539
localparam SIN_28 = 16'd49153 ; // Corresponds to -16383
localparam SIN_29 = 16'd45589 ; // Corresponds to -19947
localparam SIN_30 = 16'd42366 ; // Corresponds to -23169
localparam SIN_31 = 16'd39540 ; // Corresponds to -25995
localparam SIN_32 = 16'd37159 ; // Corresponds to -28377
localparam SIN_33 = 16'd35263 ; // Corresponds to -30272
localparam SIN_34 = 16'd33885 ; // Corresponds to -31650
localparam SIN_35 = 16'd33049 ; // Corresponds to -32486
localparam SIN_36 = 16'd32768 ; // Corresponds to -32767 (or -32768)
localparam SIN_37 = 16'd33049 ; // Corresponds to -32486
localparam SIN_38 = 16'd33885 ; // Corresponds to -31650
localparam SIN_39 = 16'd35263 ; // Corresponds to -30272
localparam SIN_40 = 16'd37159 ; // Corresponds to -28377
localparam SIN_41 = 16'd39540 ; // Corresponds to -25995
localparam SIN_42 = 16'd42366 ; // Corresponds to -23169
localparam SIN_43 = 16'd45589 ; // Corresponds to -19947
localparam SIN_44 = 16'd49152 ; // Corresponds to -16384 (close to -16383)
localparam SIN_45 = 16'd52997 ; // Corresponds to -12539
localparam SIN_46 = 16'd57056 ; // Corresponds to -8480
localparam SIN_47 = 16'd61259 ; // Corresponds to -4276

always@(SIN_Cont)
begin
    case(SIN_Cont)
     6'd0 : Sin_Out <= SIN_0 ;
     6'd1 : Sin_Out <= SIN_1 ;
     6'd2 : Sin_Out <= SIN_2 ;
     6'd3 : Sin_Out <= SIN_3 ;
     6'd4 : Sin_Out <= SIN_4 ;
     6'd5 : Sin_Out <= SIN_5 ;
     6'd6 : Sin_Out <= SIN_6 ;
     6'd7 : Sin_Out <= SIN_7 ;
     6'd8 : Sin_Out <= SIN_8 ;
     6'd9 : Sin_Out <= SIN_9 ;
    6'd10 : Sin_Out <= SIN_10;
    6'd11 : Sin_Out <= SIN_11;
    6'd12 : Sin_Out <= SIN_12;
    6'd13 : Sin_Out <= SIN_13;
    6'd14 : Sin_Out <= SIN_14;
    6'd15 : Sin_Out <= SIN_15;
    6'd16 : Sin_Out <= SIN_16;
    6'd17 : Sin_Out <= SIN_17;
    6'd18 : Sin_Out <= SIN_18;
    6'd19 : Sin_Out <= SIN_19;
    6'd20 : Sin_Out <= SIN_20;
    6'd21 : Sin_Out <= SIN_21;
    6'd22 : Sin_Out <= SIN_22;
    6'd23 : Sin_Out <= SIN_23;
    6'd24 : Sin_Out <= SIN_24;
    6'd25 : Sin_Out <= SIN_25;
    6'd26 : Sin_Out <= SIN_26;
    6'd27 : Sin_Out <= SIN_27;
    6'd28 : Sin_Out <= SIN_28;
    6'd29 : Sin_Out <= SIN_29;
    6'd30 : Sin_Out <= SIN_30;
    6'd31 : Sin_Out <= SIN_31;
    6'd32 : Sin_Out <= SIN_32;
    6'd33 : Sin_Out <= SIN_33;
    6'd34 : Sin_Out <= SIN_34;
    6'd35 : Sin_Out <= SIN_35;
    6'd36 : Sin_Out <= SIN_36;
    6'd37 : Sin_Out <= SIN_37;
    6'd38 : Sin_Out <= SIN_38;
    6'd39 : Sin_Out <= SIN_39;
    6'd40 : Sin_Out <= SIN_40;
    6'd41 : Sin_Out <= SIN_41;
    6'd42 : Sin_Out <= SIN_42;
    6'd43 : Sin_Out <= SIN_43;
    6'd44 : Sin_Out <= SIN_44;
    6'd45 : Sin_Out <= SIN_45;
    6'd46 : Sin_Out <= SIN_46;
    6'd47 : Sin_Out <= SIN_47;
    default : Sin_Out <= {DATA_WIDTH{1'b0}}; // Added default case
    endcase
end
//////////////////////////////////////////////////

endmodule