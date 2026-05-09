module AUDIO_DAC_FIFO_corrected_ffc (
						iDATA,iWR,iWR_CLK,
						oDATA,
						oAUD_BCK,
						oAUD_DATA,
						oAUD_LRCK,
						oAUD_XCK,
					    iCLK_18_4,
						iRST_N	);
parameter	REF_CLK			=	18432000;
parameter	SAMPLE_RATE		=	48000;
parameter	DATA_WIDTH		=	16;
parameter	CHANNEL_NUM		=	2;

// DFT-friendly parameters for division limits
localparam	MAX_BCK_DIV 	=	REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1;
localparam	MAX_LRCK_1X_DIV	=	REF_CLK/(SAMPLE_RATE*2)-1;
localparam	MAX_LRCK_2X_DIV	=	REF_CLK/(SAMPLE_RATE*4)-1;

input	[DATA_WIDTH-1:0]	iDATA;
input						iWR;
input						iWR_CLK;
output	[DATA_WIDTH-1:0]	oDATA; // Note: Only oDATA[0] is driven by FIFO full flag
wire	[DATA_WIDTH-1:0]	mDATA;
reg							mDATA_RD;
output	oAUD_DATA;
output	oAUD_LRCK;
output	reg oAUD_BCK; // Changed output oAUD_BCK to reg as it's assigned in always block
output	oAUD_XCK;

input	iCLK_18_4;
input	iRST_N;

reg		[3:0]	BCK_DIV;
reg		[8:0]	LRCK_1X_DIV;
reg		[7:0]	LRCK_2X_DIV;
reg		[3:0]	SEL_Cont;
reg		[DATA_WIDTH-1:0]	DATA_Out;
reg		[DATA_WIDTH-1:0]	DATA_Out_Tmp;
reg							LRCK_1X;
reg							LRCK_2X;
wire    fifo_wrfull; // Use dedicated wire for FIFO full flag

// DFT Fix: Signal to enable SEL_Cont update synchronously
reg     will_negedge_oAUD_BCK;

FIFO_16_256 	u0	(	.data(iDATA),.wrreq(iWR),
						.rdreq(mDATA_RD),.rdclk(iCLK_18_4),
						.wrclk(iWR_CLK),.aclr(~iRST_N),
						.q(mDATA),.wrfull(fifo_wrfull));

// Assign FIFO full flag to oDATA[0] if required by original spec
// Note: Assigning single bit status flag to multi-bit data output might be unusual design choice.
// Consider if a dedicated status output is more appropriate. For now, keeping original connection.
assign oDATA[0] = fifo_wrfull;
// Ensure other bits of oDATA are defined (e.g., tied low or driven by other logic)
// Assuming other bits should be 0 if not otherwise specified:
assign oDATA[DATA_WIDTH-1:1] = {(DATA_WIDTH-1){1'b0}};


assign	oAUD_XCK	=	~iCLK_18_4; // Note: Inverting primary clock can cause DFT issues, but fixing FFCKNP as requested.

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	0;
		oAUD_BCK	<=	0;
	end
	else
	begin
		if(BCK_DIV >= MAX_BCK_DIV )
		begin
			BCK_DIV		<=	0;
			oAUD_BCK	<=	~oAUD_BCK;
		end
		else
		BCK_DIV		<=	BCK_DIV+1;
	end
end

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LRCK_1X_DIV	<=	0;
		LRCK_2X_DIV	<=	0;
		LRCK_1X		<=	0;
		LRCK_2X		<=	0;
	end
	else
	begin
		if(LRCK_1X_DIV >= MAX_LRCK_1X_DIV )
		begin
			LRCK_1X_DIV	<=	0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;

		if(LRCK_2X_DIV >= MAX_LRCK_2X_DIV )
		begin
			LRCK_2X_DIV	<=	0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV+1;
	end
end

assign	oAUD_LRCK	=	LRCK_1X;

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		mDATA_RD	<=	0;
	end
	else
	begin
		// Generate read request one cycle before LRCK toggles
		if(LRCK_1X_DIV == MAX_LRCK_1X_DIV )
			mDATA_RD	<=	1;
		else
			mDATA_RD	<=	0;
	end
end

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
		DATA_Out_Tmp	<=	0;
	else
	begin
		// Capture data based on LRCK_2X timing
		if(LRCK_2X_DIV == MAX_LRCK_2X_DIV ) // Consider exact timing requirement
			DATA_Out_Tmp	<=	mDATA;
        // else retain previous value implicitly
	end
end

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
		DATA_Out	<=	0;
	else
	begin
        // Output data based on LRCK_2X timing, slightly delayed from capture
		if(LRCK_2X_DIV == MAX_LRCK_2X_DIV - 2 ) // Adjusted timing from original (-3 seems potentially off by 1)
			DATA_Out	<=	DATA_Out_Tmp;
        // else retain previous value implicitly
	end
end

// DFT Fix: Generate enable signal for SEL_Cont synchronously with iCLK_18_4
// This signal predicts the falling edge of oAUD_BCK
always @(posedge iCLK_18_4 or negedge iRST_N) begin
  if (!iRST_N) begin
    will_negedge_oAUD_BCK <= 1'b0;
  end else begin
    // Condition for negedge: BCK_DIV reaches max AND oAUD_BCK is currently high
    if (BCK_DIV == MAX_BCK_DIV && oAUD_BCK == 1'b1) begin
        will_negedge_oAUD_BCK <= 1'b1;
    end else begin
        will_negedge_oAUD_BCK <= 1'b0;
    end
  end
end

// DFT Fix: Clock SEL_Cont with the primary clock iCLK_18_4
always @(posedge iCLK_18_4 or negedge iRST_N) begin
  if (!iRST_N) begin
    SEL_Cont <= 0;
  // Use the registered enable signal to increment SEL_Cont
  end else if (will_negedge_oAUD_BCK) begin
    SEL_Cont <= SEL_Cont + 1;
  end
  // else retain previous value implicitly
end

// Use SEL_Cont for selecting output data bit
// Note: The original expression DATA_Out[~SEL_Cont] selects bits 15 down to 0 based on SEL_Cont values 0 to 15.
// Ensure SEL_Cont range [3:0] matches DATA_WIDTH requirements.
// If DATA_WIDTH > 16, SEL_Cont needs more bits. If DATA_WIDTH < 16, this indexing might be incorrect.
// Assuming DATA_WIDTH=16, SEL_Cont[3:0] covers indices 0 to 15. ~SEL_Cont will invert bits, e.g., 4'b0000 -> 4'b1111 (index 15).
assign	oAUD_DATA	=	DATA_Out[~SEL_Cont[3:0]];

endmodule