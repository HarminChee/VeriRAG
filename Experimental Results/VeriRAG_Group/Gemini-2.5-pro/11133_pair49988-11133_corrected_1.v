module AUDIO_DAC (	//	Memory Side
					output	[FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR,
					input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA,
					output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR, // Corrected: Parameter width used
					input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA,
					output	[SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR,  // Corrected: Parameter width used
					input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA,
					//	Audio Side
					output							oAUD_BCK, // Made output wire, driven by reg
					output							oAUD_DATA,
					output							oAUD_LRCK,
					//	Control Signals
					input	[1:0]					iSrc_Select,
				    input							iCLK_18_4,
					input							iRST_N,
                    input 							test_i // DFT test mode signal - Corrected position
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
reg		[SDRAM_ADDR_WIDTH-1:0]	SDRAM_Cont; // Corrected width
reg		[SRAM_ADDR_WIDTH-1:0]	SRAM_Cont;  // Corrected width
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
wire dft_LRCK_2X;
wire dft_LRCK_4X;
wire dft_rAUD_BCK; // Mux for internal BCK FF clock

assign dft_LRCK_1X = test_i ? iCLK_18_4 : LRCK_1X;
assign dft_LRCK_2X = test_i ? iCLK_18_4 : LRCK_2X;
assign dft_LRCK_4X = test_i ? iCLK_18_4 : LRCK_4X;
assign dft_rAUD_BCK = test_i ? iCLK_18_4 : rAUD_BCK; // Mux for BCK FF clock input

assign oAUD_BCK = rAUD_BCK; // Assign internal reg to output port

////////////	AUD_BCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	4'd0;
		rAUD_BCK	<=	1'b0;
	end
	else
	begin
		// Calculate division factor safely, ensuring it's at least 1
		localparam BCK_DIV_MAX = (REF_CLK >= (SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)) ? (REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2) - 1) : 0;
		if(BCK_DIV >= BCK_DIV_MAX )
		begin
			BCK_DIV		<=	4'd0;
			rAUD_BCK	<=	~rAUD_BCK;
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
	    localparam LRCK_1X_DIV_MAX = (REF_CLK >= (SAMPLE_RATE*2)) ? (REF_CLK/(SAMPLE_RATE*2) - 1) : 0;
	    localparam LRCK_2X_DIV_MAX = (REF_CLK >= (SAMPLE_RATE*4)) ? (REF_CLK/(SAMPLE_RATE*4) - 1) : 0;
	    localparam LRCK_4X_DIV_MAX = (REF_CLK >= (SAMPLE_RATE*8)) ? (REF_CLK/(SAMPLE_RATE*8) - 1) : 0;

		//	LRCK 1X
		if(LRCK_1X_DIV >= LRCK_1X_DIV_MAX )
		begin
			LRCK_1X_DIV	<=	9'd0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;
		//	LRCK 2X
		if(LRCK_2X_DIV >= LRCK_2X_DIV_MAX )
		begin
			LRCK_2X_DIV	<=	8'd0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV+1;
		//	LRCK 4X
		if(LRCK_4X_DIV >= LRCK_4X_DIV_MAX )
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
always@(negedge dft_LRCK_1X or negedge iRST_N) // Use Muxed Clock
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
always@(negedge dft_LRCK_4X or negedge iRST_N) // Use Muxed Clock
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
always@(posedge dft_LRCK_4X or negedge iRST_N) // Use Muxed Clock
begin
	if(!iRST_N)
	FLASH_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
	begin
		if(FLASH_Cont[0]) // Assuming LSB indicates high byte
		FLASH_Out_Tmp[15:8]	<=	iFLASH_DATA;
		else              // Assuming LSB indicates low byte
		FLASH_Out_Tmp[7:0]	<=	iFLASH_DATA;
	end
end
always@(negedge dft_LRCK_2X	or negedge iRST_N) // Use Muxed Clock
begin
	if(!iRST_N)
	FLASH_Out	<=	{DATA_WIDTH{1'b0}};
	else
	FLASH_Out	<=	FLASH_Out_Tmp;
end
//////////////////////////////////////////////////
//////////	SDRAM ADDR Generator	//////////////
always@(negedge dft_LRCK_2X or negedge iRST_N) // Use Muxed Clock
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
always@(posedge dft_LRCK_2X or negedge iRST_N) // Use Muxed Clock
begin
	if(!iRST_N)
	SDRAM_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
	SDRAM_Out_Tmp	<=	iSDRAM_DATA;
end
always@(negedge dft_LRCK_2X	or negedge iRST_N) // Use Muxed Clock
begin
	if(!iRST_N)
	SDRAM_Out	<=	{DATA_WIDTH{1'b0}};
	else
	SDRAM_Out	<=	SDRAM_Out_Tmp;
end
//////////////////////////////////////////////////
////////////	SRAM ADDR Generator	  ////////////
always@(negedge dft_LRCK_2X or negedge iRST_N) // Use Muxed Clock
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
always@(posedge dft_LRCK_2X or negedge iRST_N) // Use Muxed Clock
begin
	if(!iRST_N)
	SRAM_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
	SRAM_Out_Tmp	<=	iSRAM_DATA;
end
always@(negedge dft_LRCK_2X	or negedge iRST_N) // Use Muxed Clock
begin
	if(!iRST_N)
	SRAM_Out	<=	{DATA_WIDTH{1'b0}};
	else
	SRAM_Out	<=	SRAM_Out_Tmp;
end
//////////////////////////////////////////////////
//////////	16 Bits PISO MSB First	//////////////
always@(negedge dft_rAUD_BCK or negedge iRST_N) // Use Muxed Clock
begin
	if(!iRST_N)
	SEL_Cont	<=	4'd0;
	else if (SEL_Cont == 4'd15) // Corrected counter wrap-around
	SEL_Cont	<=	4'd0;
	else
	SEL_Cont	<=	SEL_Cont+1;
end

// Indexing from MSB (15) down to LSB (0)
wire [3:0] piso_index = 4'd15 - SEL_Cont;

assign	oAUD_DATA	=	(iSrc_Select==SIN_SANPLE)	?	Sin_Out[piso_index]	:
						(iSrc_Select==FLASH_DATA)	?	FLASH_Out[piso_index]:
						(iSrc_Select==SDRAM_DATA)	?	SDRAM_Out[piso_index]:
														SRAM_Out[piso_index]	;
//////////////////////////////////////////////////
////////////	Sin Wave ROM Table	//////////////
// Changed to combinational always block
always@(*) // Use @(*) for combinational logic
begin
    case(SIN_Cont)
     0 : Sin_Out = 16'd0     ;
     1 : Sin_Out = 16'd4276  ;
     2 : Sin_Out = 16'd8480  ;
     3 : Sin_Out = 16'd12539 ;
     4 : Sin_Out = 16'd16383 ;
     5 : Sin_Out = 16'd19947 ;
     6 : Sin_Out = 16'd23169 ;
     7 : Sin_Out = 16'd25995 ;
     8 : Sin_Out = 16'd28377 ;
     9 : Sin_Out = 16'd30272 ;
    10 : Sin_Out = 16'd31650 ;
    11 : Sin_Out = 16'd32486 ;
    12 : Sin_Out = 16'd32767 ;
    13 : Sin_Out = 16'd32486 ;
    14 : Sin_Out = 16'd31650 ;
    15 : Sin_Out = 16'd30272 ;
    16 : Sin_Out = 16'd28377 ;
    17 : Sin_Out = 16'd25995 ;
    18 : Sin_Out = 16'd23169 ;
    19 : Sin_Out = 16'd19947 ;
    20 : Sin_Out = 16'd16383 ;
    21 : Sin_Out = 16'd12539 ;
    22 : Sin_Out = 16'd8480  ;
    23 : Sin_Out = 16'd4276  ;
    24 : Sin_Out = 16'd0     ;
    25 : Sin_Out = 16'd61259 ; // Equivalent to -4277 (signed 16-bit)
    26 : Sin_Out = 16'd57056 ; // Equivalent to -8480
    27 : Sin_Out = 16'd52997 ; // Equivalent to -12539
    28 : Sin_Out = 16'd49153 ; // Equivalent to -16383
    29 : Sin_Out = 16'd45589 ; // Equivalent to -19947
    30 : Sin_Out = 16'd42366 ; // Equivalent to -23170
    31 : Sin_Out = 16'd39540 ; // Equivalent to -25996
    32 : Sin_Out = 16'd37159 ; // Equivalent to -28377
    33 : Sin_Out = 16'd35263 ; // Equivalent to -30273
    34 : Sin_Out = 16'd33885 ; // Equivalent to -31651
    35 : Sin_Out = 16'd33049 ; // Equivalent to -32487
    36 : Sin_Out = 16'd32768 ; // Equivalent to -32768
    37 : Sin_Out = 16'd33049 ; // Equivalent to -32487
    38 : Sin_Out = 16'd33885 ; // Equivalent to -31651
    39 : Sin_Out = 16'd35263 ; // Equivalent to -30273
    40 : Sin_Out = 16'd37159 ; // Equivalent to -28377
    41 : Sin_Out = 16'd39540 ; // Equivalent to -25996
    42 : Sin_Out = 16'd42366 ; // Equivalent to -23170
    43 : Sin_Out = 16'd45589 ; // Equivalent to -19947
    44 : Sin_Out = 16'd49153 ; // Equivalent to -16383
    45 : Sin_Out = 16'd52997 ; // Equivalent to -12539
    46 : Sin_Out = 16'd57056 ; // Equivalent to -8480
    47 : Sin_Out = 16'd61259 ; // Equivalent to -4277
    default : Sin_Out = 16'd0; // Default case
    endcase
end

endmodule