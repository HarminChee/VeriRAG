module AUDIO_DAC (
    // Memory Side
    oFLASH_ADDR,
    iFLASH_DATA,
    oSDRAM_ADDR,
    iSDRAM_DATA,
    oSRAM_ADDR,
    iSRAM_DATA,
    // Audio Side
    oAUD_BCK,
    oAUD_DATA,
    oAUD_LRCK,
    // Control Signals
    iSrc_Select,
    iCLK_18_4,
    iRST_N,
    // DFT Ports
    test_i,         // Test mode enable (scan enable)
    scan_data,      // Scan data input
    scan_out        // Scan data output (placeholder)
);

// Parameter definitions (unchanged)
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

// Port Declarations
// Memory Side
output	[FLASH_ADDR_WIDTH-1:0]	oFLASH_ADDR;
input	[FLASH_DATA_WIDTH-1:0]	iFLASH_DATA;
output	[SDRAM_ADDR_WIDTH-1:0]	oSDRAM_ADDR; // Corrected: SDRAM_ADDR_WIDTH-1:0
input	[SDRAM_DATA_WIDTH-1:0]	iSDRAM_DATA;
output	[SRAM_ADDR_WIDTH-1:0]	oSRAM_ADDR;  // Corrected: SRAM_ADDR_WIDTH-1:0
input	[SRAM_DATA_WIDTH-1:0]	iSRAM_DATA;
// Audio Side
output							oAUD_DATA;
output							oAUD_LRCK;
output	reg						oAUD_BCK;
// Control Signals
input	[1:0]					iSrc_Select;
input							iCLK_18_4;
input							iRST_N;
// DFT Ports
input                           test_i;
input                           scan_data;
output                          scan_out; // Added scan_out port

// Internal Registers and Wires
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

// Derived clock edge detection logic
reg     oAUD_BCK_prev;
reg     LRCK_1X_prev;
reg     LRCK_2X_prev;
reg     LRCK_4X_prev;

wire    negedge_oAUD_BCK;
wire    negedge_LRCK_1X;
wire    posedge_LRCK_2X;
wire    negedge_LRCK_2X;
wire    posedge_LRCK_4X;
wire    negedge_LRCK_4X;

// Update previous state registers on main clock edge
always @(posedge iCLK_18_4 or negedge iRST_N) begin
    if (!iRST_N) begin
        oAUD_BCK_prev <= 1'b0;
        LRCK_1X_prev  <= 1'b0;
        LRCK_2X_prev  <= 1'b0;
        LRCK_4X_prev  <= 1'b0;
    end else begin
        oAUD_BCK_prev <= oAUD_BCK;
        LRCK_1X_prev  <= LRCK_1X;
        LRCK_2X_prev  <= LRCK_2X;
        LRCK_4X_prev  <= LRCK_4X;
    end
end

// Generate edge detection signals combinatorially
assign negedge_oAUD_BCK = oAUD_BCK_prev & ~oAUD_BCK;
assign negedge_LRCK_1X  = LRCK_1X_prev  & ~LRCK_1X;
assign posedge_LRCK_2X  = ~LRCK_2X_prev & LRCK_2X;
assign negedge_LRCK_2X  = LRCK_2X_prev  & ~LRCK_2X;
assign posedge_LRCK_4X  = ~LRCK_4X_prev & LRCK_4X;
assign negedge_LRCK_4X  = LRCK_4X_prev  & ~LRCK_4X;

////////////	AUD_BCK Generator	//////////////
// This logic generates oAUD_BCK, which is used elsewhere.
// The flop itself (oAUD_BCK) is clocked by iCLK_18_4, which is DFT-friendly.
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<= 4'd0; // Use decimal for clarity
		oAUD_BCK	<= 1'b0;
	end
	else
	begin
		// Calculation assumes integer division: 18432000 / (48000 * 16 * 2 * 2) = 6
		// So, divide by 6 means count 0 to 5. Limit is 5 (6-1).
		if(BCK_DIV >= 4'd5 ) // Corrected calculation: REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1
		begin
			BCK_DIV		<= 4'd0;
			oAUD_BCK	<=	~oAUD_BCK;
		end
		else
		BCK_DIV		<=	BCK_DIV + 1'b1;
	end
end
//////////////////////////////////////////////////
////////////	AUD_LRCK Generator	//////////////
// These flops (LRCK_1X/2X/4X) are clocked by iCLK_18_4, which is DFT-friendly.
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LRCK_1X_DIV	<= 9'd0;
		LRCK_2X_DIV	<= 8'd0;
		LRCK_4X_DIV	<= 7'd0;
		LRCK_1X		<= 1'b0;
		LRCK_2X		<= 1'b0;
		LRCK_4X		<= 1'b0;
	end
	else
	begin
		// LRCK 1X: 18432000 / (48000 * 2) = 192. Count 0 to 191. Limit is 191.
		if(LRCK_1X_DIV >= 9'd191 ) // Corrected calculation: REF_CLK/(SAMPLE_RATE*2)-1
		begin
			LRCK_1X_DIV	<= 9'd0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV + 1'b1;

		// LRCK 2X: 18432000 / (48000 * 4) = 96. Count 0 to 95. Limit is 95.
		if(LRCK_2X_DIV >= 8'd95 ) // Corrected calculation: REF_CLK/(SAMPLE_RATE*4)-1
		begin
			LRCK_2X_DIV	<= 8'd0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV + 1'b1;

		// LRCK 4X: 18432000 / (48000 * 8) = 48. Count 0 to 47. Limit is 47.
		if(LRCK_4X_DIV >= 7'd47 ) // Corrected calculation: REF_CLK/(SAMPLE_RATE*8)-1
		begin
			LRCK_4X_DIV	<= 7'd0;
			LRCK_4X	<=	~LRCK_4X;
		end
		else
		LRCK_4X_DIV		<=	LRCK_4X_DIV + 1'b1;
	end
end
assign	oAUD_LRCK	=	LRCK_1X; // Output assignment remains
//////////////////////////////////////////////////

// DFT Correction: Make flops synchronous to iCLK_18_4 with enables

//////////	Sin LUT ADDR Generator	//////////////
// Clocked by iCLK_18_4, enabled by negedge_LRCK_1X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    SIN_Cont	<= 6'd0;
	else if (negedge_LRCK_1X) // Enable condition
	begin
		if(SIN_Cont < SIN_SAMPLE_DATA-1 )
		    SIN_Cont	<=	SIN_Cont + 1'b1;
		else
		    SIN_Cont	<= 6'd0;
	end
end
//////////////////////////////////////////////////

//////////	FLASH ADDR Generator	//////////////
// Clocked by iCLK_18_4, enabled by negedge_LRCK_4X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    FLASH_Cont	<= {FLASH_ADDR_WIDTH{1'b0}};
	else if (negedge_LRCK_4X) // Enable condition
	begin
		if(FLASH_Cont < FLASH_DATA_NUM-1 )
		    FLASH_Cont	<=	FLASH_Cont + 1'b1;
		else
		    FLASH_Cont	<= {FLASH_ADDR_WIDTH{1'b0}};
	end
end
assign	oFLASH_ADDR	=	FLASH_Cont;
//////////////////////////////////////////////////

//////////	  FLASH DATA Reorder	//////////////
// Clocked by iCLK_18_4, enabled by posedge_LRCK_4X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    FLASH_Out_Tmp	<= {DATA_WIDTH{1'b0}};
	else if (posedge_LRCK_4X) // Enable condition
	begin
		// This logic depends on FLASH_Cont, which changes on negedge_LRCK_4X.
		// Assuming FLASH_Cont is stable when posedge_LRCK_4X occurs
		if(FLASH_Cont[0])
		    FLASH_Out_Tmp[15:8]	<=	iFLASH_DATA;
		else
		    FLASH_Out_Tmp[7:0]	<=	iFLASH_DATA;
	end
end

// Clocked by iCLK_18_4, enabled by negedge_LRCK_2X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    FLASH_Out	<= {DATA_WIDTH{1'b0}};
	else if (negedge_LRCK_2X) // Enable condition
	    FLASH_Out	<=	FLASH_Out_Tmp;
end
//////////////////////////////////////////////////

//////////	SDRAM ADDR Generator	//////////////
// Clocked by iCLK_18_4, enabled by negedge_LRCK_2X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    SDRAM_Cont	<= {SDRAM_ADDR_WIDTH{1'b0}};
	else if (negedge_LRCK_2X) // Enable condition
	begin
		if(SDRAM_Cont < SDRAM_DATA_NUM-1 )
		    SDRAM_Cont	<=	SDRAM_Cont + 1'b1;
		else
		    SDRAM_Cont	<= {SDRAM_ADDR_WIDTH{1'b0}};
	end
end
assign	oSDRAM_ADDR	=	SDRAM_Cont;
//////////////////////////////////////////////////

//////////	  SDRAM DATA Latch		//////////////
// Clocked by iCLK_18_4, enabled by posedge_LRCK_2X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    SDRAM_Out_Tmp	<= {DATA_WIDTH{1'b0}};
	else if (posedge_LRCK_2X) // Enable condition
	    SDRAM_Out_Tmp	<=	iSDRAM_DATA;
end

// Clocked by iCLK_18_4, enabled by negedge_LRCK_2X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    SDRAM_Out	<= {DATA_WIDTH{1'b0}};
	else if (negedge_LRCK_2X) // Enable condition
	    SDRAM_Out	<=	SDRAM_Out_Tmp;
end
//////////////////////////////////////////////////

////////////	SRAM ADDR Generator	  ////////////
// Clocked by iCLK_18_4, enabled by negedge_LRCK_2X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    SRAM_Cont	<= {SRAM_ADDR_WIDTH{1'b0}};
	else if (negedge_LRCK_2X) // Enable condition
	begin
		if(SRAM_Cont < SRAM_DATA_NUM-1 )
		    SRAM_Cont	<=	SRAM_Cont + 1'b1;
		else
		    SRAM_Cont	<= {SRAM_ADDR_WIDTH{1'b0}};
	end
end
assign	oSRAM_ADDR	=	SRAM_Cont;
//////////////////////////////////////////////////

//////////	  SRAM DATA Latch		//////////////
// Clocked by iCLK_18_4, enabled by posedge_LRCK_2X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    SRAM_Out_Tmp	<= {DATA_WIDTH{1'b0}};
	else if (posedge_LRCK_2X) // Enable condition
	    SRAM_Out_Tmp	<=	iSRAM_DATA;
end

// Clocked by iCLK_18_4, enabled by negedge_LRCK_2X
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    SRAM_Out	<= {DATA_WIDTH{1'b0}};
	else if (negedge_LRCK_2X) // Enable condition
	    SRAM_Out	<=	SRAM_Out_Tmp;
end
//////////////////////////////////////////////////

//////////	16 Bits PISO MSB First	//////////////
// SEL_Cont flop clocked by iCLK_18_4, enabled by negedge_oAUD_BCK
// Corrected the incomplete always block
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	    SEL_Cont <= 4'd0; // Initialize SEL_Cont
	else if (negedge_oAUD_BCK) // Enable condition
	begin
		if(SEL_Cont < 4'd15) // Assuming it counts 0 to 15 for 16 bits
		    SEL_Cont <= SEL_Cont + 1'b1;
		else
		    SEL_Cont <= 4'd0;
	end
end

// Placeholder for Sin_Out generation (if needed)
// Assuming Sin_Out should be driven based on SIN_Cont
// This part was missing in the original snippet, add a placeholder or example
// Example: ROM lookup based on SIN_Cont - needs ROM definition
// For now, assign 0
assign Sin_Out = {DATA_WIDTH{1'b0}};


// Data Selection Logic (Combinational)
// Selects output data based on iSrc_Select
// Drives oAUD_DATA based on SEL_Cont (PISO)
wire [DATA_WIDTH-1:0] DATA_Out;
assign DATA_Out = (iSrc_Select == SIN_SANPLE) ? Sin_Out :
                  (iSrc_Select == FLASH_DATA) ? FLASH_Out :
                  (iSrc_Select == SDRAM_DATA) ? SDRAM_Out :
                  (iSrc_Select == SRAM_DATA)  ? SRAM_Out :
                                                {DATA_WIDTH{1'b0}}; // Default

// PISO Output Stage (Combinational)
// Selects the bit based on SEL_Cont
assign oAUD_DATA = DATA_Out[15-SEL_Cont]; // MSB First

// Assign scan_out to a default value
assign scan_out = 1'b0; // Placeholder assignment

endmodule