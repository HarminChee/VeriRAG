module AUDIO_DAC (	//	Memory Side
					output	[FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR,
					input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA,
					output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR, // Corrected width
					input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA,
					output	[SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR, // Corrected width
					input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA,
					//	Audio Side
					output	reg						oAUD_BCK,
					output							oAUD_DATA,
					output							oAUD_LRCK,
					//	Control Signals
					input	[1:0]					iSrc_Select,
				    input							iCLK_18_4,
					input							iRST_N	);

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
parameter	SIN_SANPLE		=	2'b00; // Use explicit size and base
parameter	FLASH_DATA		=	2'b01; // Use explicit size and base
parameter	SDRAM_DATA		=	2'b10; // Use explicit size and base
parameter	SRAM_DATA		=	2'b11; // Use explicit size and base
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

// Intermediate signal for PISO data selection
wire	[DATA_WIDTH-1:0]	Selected_Data;
wire    [3:0]               PISO_Index;

////////////	AUD_BCK Generator	//////////////
// Use integer for calculation clarity if needed, or ensure parameter calculation is precise
localparam BCK_DIV_LIMIT = REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2) - 1;
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	4'd0;
		oAUD_BCK	<=	1'b0;
	end
	else
	begin
		if(BCK_DIV >= BCK_DIV_LIMIT ) // Use calculated limit
		begin
			BCK_DIV		<=	4'd0;
			oAUD_BCK	<=	~oAUD_BCK;
		end
		else
			BCK_DIV		<=	BCK_DIV + 1'b1;
	end
end
//////////////////////////////////////////////////

////////////	AUD_LRCK Generator	//////////////
localparam LRCK_1X_DIV_LIMIT = REF_CLK/(SAMPLE_RATE*2) - 1;
localparam LRCK_2X_DIV_LIMIT = REF_CLK/(SAMPLE_RATE*4) - 1;
localparam LRCK_4X_DIV_LIMIT = REF_CLK/(SAMPLE_RATE*8) - 1;

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
		if(LRCK_1X_DIV >= LRCK_1X_DIV_LIMIT )
		begin
			LRCK_1X_DIV	<=	9'd0;
			LRCK_1X		<=	~LRCK_1X;
		end
		else
			LRCK_1X_DIV	<=	LRCK_1X_DIV + 1'b1;

		//	LRCK 2X
		if(LRCK_2X_DIV >= LRCK_2X_DIV_LIMIT )
		begin
			LRCK_2X_DIV	<=	8'd0;
			LRCK_2X		<=	~LRCK_2X;
		end
		else
			LRCK_2X_DIV	<=	LRCK_2X_DIV + 1'b1;

		//	LRCK 4X
		if(LRCK_4X_DIV >= LRCK_4X_DIV_LIMIT )
		begin
			LRCK_4X_DIV	<=	7'd0;
			LRCK_4X		<=	~LRCK_4X;
		end
		else
			LRCK_4X_DIV	<=	LRCK_4X_DIV + 1'b1;
	end
end
assign	oAUD_LRCK	=	LRCK_1X;
//////////////////////////////////////////////////

//////////	Sin LUT ADDR Generator	//////////////
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
//////////////////////////////////////////////////

//////////	FLASH ADDR Generator	//////////////
assign	oFLASH_ADDR	=	FLASH_Cont;
always@(negedge LRCK_4X or negedge iRST_N) // Address should typically change *before* data is needed
begin
	if(!iRST_N)
		FLASH_Cont	<=	{FLASH_ADDR_WIDTH{1'b0}}; // Use sized literal for reset
	else
	begin
		if(FLASH_Cont < FLASH_DATA_NUM-1 ) // Assumes FLASH_DATA_NUM fits in FLASH_ADDR_WIDTH
			FLASH_Cont	<=	FLASH_Cont + 1'b1;
		else
			FLASH_Cont	<=	{FLASH_ADDR_WIDTH{1'b0}};
	end
end
//////////////////////////////////////////////////

//////////	  FLASH DATA Reorder	//////////////
// Consider potential timing issues: Address changes on negedge LRCK_4X,
// data might need setup time before posedge LRCK_4X.
// This implementation assumes data is valid at posedge LRCK_4X.
always@(posedge LRCK_4X or negedge iRST_N)
begin
	if(!iRST_N)
		FLASH_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
	begin
		// Check LSB of the *next* address to decide where current data goes
        // This requires looking ahead or adjusting timing/logic.
        // Assuming FLASH_Cont represents the *current* address being read:
		if(FLASH_Cont[0]) // If current address is odd, data is MSB
			FLASH_Out_Tmp[15:8]	<=	iFLASH_DATA;
		else // If current address is even, data is LSB
			FLASH_Out_Tmp[7:0]	<=	iFLASH_DATA;
        // Note: This implies the other byte comes from the *previous* cycle.
        // If FLASH_Cont[0] is 1 (odd address, MSB), FLASH_Out_Tmp[7:0] retains old value.
        // If FLASH_Cont[0] is 0 (even address, LSB), FLASH_Out_Tmp[15:8] retains old value.
	end
end

// Latch the assembled 16-bit word
always@(negedge LRCK_2X	or negedge iRST_N)
begin
	if(!iRST_N)
		FLASH_Out	<=	{DATA_WIDTH{1'b0}};
	else
		FLASH_Out	<=	FLASH_Out_Tmp; // Latch the potentially partially updated word
end
//////////////////////////////////////////////////

//////////	SDRAM ADDR Generator	//////////////
assign	oSDRAM_ADDR	=	SDRAM_Cont;
always@(negedge LRCK_2X or negedge iRST_N) // Address change timing
begin
	if(!iRST_N)
		SDRAM_Cont	<=	{SDRAM_ADDR_WIDTH{1'b0}};
	else
	begin
		if(SDRAM_Cont < SDRAM_DATA_NUM-1 ) // Assumes SDRAM_DATA_NUM fits
			SDRAM_Cont	<=	SDRAM_Cont + 1'b1;
		else
			SDRAM_Cont	<=	{SDRAM_ADDR_WIDTH{1'b0}};
	end
end
//////////////////////////////////////////////////

//////////	  SDRAM DATA Latch		//////////////
// Assumes iSDRAM_DATA is valid at posedge LRCK_2X for address generated at previous negedge LRCK_2X
always@(posedge LRCK_2X or negedge iRST_N)
begin
	if(!iRST_N)
		SDRAM_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
		SDRAM_Out_Tmp	<=	iSDRAM_DATA;
end

always@(negedge LRCK_2X	or negedge iRST_N)
begin
	if(!iRST_N)
		SDRAM_Out	<=	{DATA_WIDTH{1'b0}};
	else
		SDRAM_Out	<=	SDRAM_Out_Tmp;
end
//////////////////////////////////////////////////

////////////	SRAM ADDR Generator	  ////////////
assign	oSRAM_ADDR	=	SRAM_Cont;
always@(negedge LRCK_2X or negedge iRST_N) // Address change timing
begin
	if(!iRST_N)
		SRAM_Cont	<=	{SRAM_ADDR_WIDTH{1'b0}};
	else
	begin
		if(SRAM_Cont < SRAM_DATA_NUM-1 ) // Assumes SRAM_DATA_NUM fits
			SRAM_Cont	<=	SRAM_Cont + 1'b1;
		else
			SRAM_Cont	<=	{SRAM_ADDR_WIDTH{1'b0}};
	end
end
//////////////////////////////////////////////////

//////////	  SRAM DATA Latch		//////////////
// Assumes iSRAM_DATA is valid at posedge LRCK_2X for address generated at previous negedge LRCK_2X
always@(posedge LRCK_2X or negedge iRST_N)
begin
	if(!iRST_N)
		SRAM_Out_Tmp	<=	{DATA_WIDTH{1'b0}};
	else
		SRAM_Out_Tmp	<=	iSRAM_DATA;
end

always@(negedge LRCK_2X	or negedge iRST_N)
begin
	if(!iRST_N)
		SRAM_Out	<=	{DATA_WIDTH{1'b0}};
	else
		SRAM_Out	<=	SRAM_Out_Tmp;
end
//////////////////////////////////////////////////

//////////	16 Bits PISO MSB First	//////////////
always@(negedge oAUD_BCK or negedge iRST_N)
begin
	if(!iRST_N)
		SEL_Cont	<=	4'd0;
	else
	begin
        // Counter should cycle through 0 to 15 for 16 bits
		if (SEL_Cont == 4'd15)
            SEL_Cont <= 4'd0;
        else
            SEL_Cont <= SEL_Cont + 1'b1;
    end
end

// Select data source based on iSrc_Select
assign Selected_Data = (iSrc_Select == SIN_SANPLE) ? Sin_Out   :
                       (iSrc_Select == FLASH_DATA)? FLASH_Out :
                       (iSrc_Select == SDRAM_DATA)? SDRAM_Out :
                                                    SRAM_Out; // Default to SRAM_Out if select is invalid

// PISO index calculation: MSB first means index 15, 14, ..., 1, 0
// When SEL_Cont = 0, index = 15 (1111)
// When SEL_Cont = 1, index = 14 (1110)
// ...
// When SEL_Cont = 15, index = 0 (0000)
// ~SEL_Cont calculates this correctly for 4 bits (0->15, 1->14, ..., 15->0)
assign PISO_Index = ~SEL_Cont;

// Assign output data bit based on calculated index
assign oAUD_DATA = Selected_Data[PISO_Index];

//////////////////////////////////////////////////

////////////	Sin Wave ROM Table	//////////////
// Use blocking assignments for combinational logic
// Sensitivity list should ideally include all inputs read (just SIN_Cont here)
always@(*) // Use @(*) for combinational logic sensitivity list
begin
    case(SIN_Cont)
     0 :  Sin_Out = 16'd0     ;
     1 :  Sin_Out = 16'd4276  ;
     2 :  Sin_Out = 16'd8480  ;
     3 :  Sin_Out = 16'd12539 ;
     4 :  Sin_Out = 16'd16383 ;
     5 :  Sin_Out = 16'd19947 ;
     6 :  Sin_Out = 16'd23169 ;
     7 :  Sin_Out = 16'd25995 ;
     8 :  Sin_Out = 16'd28377 ;
     9 :  Sin_Out = 16'd30272 ;
    10 :  Sin_Out = 16'd31650 ;
    11 :  Sin_Out = 16'd32486 ;
    12 :  Sin_Out = 16'd32767 ;
    13 :  Sin_Out = 16'd32486 ;
    14 :  Sin_Out = 16'd31650 ;
    15 :  Sin_Out = 16'd30272 ;
    16 :  Sin_Out = 16'd28377 ;
    17 :  Sin_Out = 16'd25995 ;
    18 :  Sin_Out = 16'd23169 ;
    19 :  Sin_Out = 16'd19947 ;
    20 :  Sin_Out = 16'd16383 ;
    21 :  Sin_Out = 16'd12539 ;
    22 :  Sin_Out = 16'd8480  ;
    23 :  Sin_Out = 16'd4276  ;
    24 :  Sin_Out = 16'd0     ;
    25 :  Sin_Out = 16'd61259 ; // Equivalent to -4277 (assuming 2's complement)
    26 :  Sin_Out = 16'd57056 ; // Equivalent to -8480
    27 :  Sin_Out = 16'd52997 ; // ... and so on
    28 :  Sin_Out = 16'd49153 ;
    29 :  Sin_Out = 16'd45589 ;
    30 :  Sin_Out = 16'd42366 ;
    31 :  Sin_Out = 16'd39540 ;
    32 :  Sin_Out = 16'd37159 ;
    33 :  Sin_Out = 16'd35263 ;
    34 :  Sin_Out = 16'd33885 ;
    35 :  Sin_Out = 16'd33049 ;
    36 :  Sin_Out = 16'd32768 ; // Equivalent to -32768 (min value)
    37 :  Sin_Out = 16'd33049 ;
    38 :  Sin_Out = 16'd33885 ;
    39 :  Sin_Out = 16'd35263 ;
    40 :  Sin_Out = 16'd37159 ;
    41 :  Sin_Out = 16'd39540 ;
    42 :  Sin_Out = 16'd42366 ;
    43 :  Sin_Out = 16'd45589 ;
    44 :  Sin_Out = 16'd49152 ; // Note: 49153 in original code
    45 :  Sin_Out = 16'd52997 ;
    46 :  Sin_Out = 16'd57056 ;
    47 :  Sin_Out = 16'd61259 ;
	default: Sin_Out = 16'd0     ;
	endcase
end
//////////////////////////////////////////////////

endmodule