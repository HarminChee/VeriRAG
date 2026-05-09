module AUDIO_DAC_FIFO (	
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
input	[DATA_WIDTH-1:0]	iDATA;
input						iWR;
input						iWR_CLK;
output	[DATA_WIDTH-1:0]	oDATA;
wire	[DATA_WIDTH-1:0]	mDATA;
reg							mDATA_RD;
output	oAUD_DATA;
output	oAUD_LRCK;
output	oAUD_BCK;
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
wire    aud_bck;

FIFO_16_256 	u0	(	.data(iDATA),.wrreq(iWR),
						.rdreq(mDATA_RD),.rdclk(iCLK_18_4),
						.wrclk(iWR_CLK),.aclr(~iRST_N),
						.q(mDATA),.wrfull(oDATA[0]));
assign	oAUD_XCK	=	~iCLK_18_4;

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	0;
		aud_bck	<=	0;
	end
	else
	begin
		if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 )
		begin
			BCK_DIV		<=	0;
			aud_bck	<=	~aud_bck;
		end
		else
		BCK_DIV		<=	BCK_DIV+1;
	end
end

assign oAUD_BCK = aud_bck;

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
		if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1 )
		begin
			LRCK_1X_DIV	<=	0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;
		if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1 )
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
		if(LRCK_1X_DIV == REF_CLK/(SAMPLE_RATE*2)-1 )
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
		if(LRCK_2X_DIV == REF_CLK/(SAMPLE_RATE*4)-1 )
		DATA_Out_Tmp	<=	mDATA;
	end
end

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	DATA_Out	<=	0;
	else
	begin
		if(LRCK_2X_DIV == REF_CLK/(SAMPLE_RATE*4)-3 )
		DATA_Out	<=	DATA_Out_Tmp;
	end
end

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	SEL_Cont	<=	0;
	else
	SEL_Cont	<=	SEL_Cont+1;
end

assign	oAUD_DATA	=	DATA_Out[~SEL_Cont];											
endmodule