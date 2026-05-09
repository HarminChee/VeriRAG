module adio_codec (
output			oAUD_DATA,
output			oAUD_LRCK,
output	reg		oAUD_BCK,
input key1_on,
input	[1:0]	iSrc_Select,
input			iCLK_18_4,
input			iRST_N,
input   [15:0]	sound1
						);
// Removed test_mode input as the fix involves redesigning to synchronous logic

parameter	REF_CLK			=	18432000;
parameter	SAMPLE_RATE		=	48000;
parameter	DATA_WIDTH		=	16;
parameter	CHANNEL_NUM		=	2;
parameter	SIN_SAMPLE_DATA	=	48;
parameter	SIN_SANPLE		=	0;

reg		[3:0]	BCK_DIV;
reg		[8:0]	LRCK_1X_DIV;
reg		[7:0]	LRCK_2X_DIV;
reg		[6:0]	LRCK_4X_DIV;
reg		[3:0]	SEL_Cont;
reg		[5:0]	SIN_Cont;
reg							LRCK_1X;
reg							LRCK_2X;
reg							LRCK_4X;

// BCK generation - OK (synchronous to iCLK_18_4, async reset iRST_N)
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

// LRCK generation - OK (synchronous to iCLK_18_4, async reset iRST_N)
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

// Corrected SIN_Cont generation - Synchronous to iCLK_18_4
reg LRCK_1X_d; // Previous value of LRCK_1X
always @(posedge iCLK_18_4 or negedge iRST_N) begin
  if (!iRST_N) begin
    LRCK_1X_d <= 1'b0;
    SIN_Cont <= 0;
  end else begin
    LRCK_1X_d <= LRCK_1X; // Sample LRCK_1X every cycle
    if (LRCK_1X_d && !LRCK_1X) begin // Detect falling edge
      if(SIN_Cont < SIN_SAMPLE_DATA-1 )
        SIN_Cont <= SIN_Cont+1;
      else
        SIN_Cont <= 0;
    end
    // No change if edge not detected
  end
end

wire [15:0]music1_ramp;
wire [15:0]music1=music1_ramp;
wire [15:0]sound_o;
assign sound_o=music1;

// Corrected SEL_Cont generation - Synchronous to iCLK_18_4
reg oAUD_BCK_d; // Previous value of oAUD_BCK
always @(posedge iCLK_18_4 or negedge iRST_N) begin
  if (!iRST_N) begin
    oAUD_BCK_d <= 1'b0; // Assuming oAUD_BCK resets low
    SEL_Cont <= 0;
  end else begin
    oAUD_BCK_d <= oAUD_BCK; // Sample oAUD_BCK every cycle
    if (oAUD_BCK_d && !oAUD_BCK) begin // Detect falling edge
      SEL_Cont <= SEL_Cont + 1;
    end
    // No change if edge not detected
  end
end

assign	oAUD_DATA	=	((key1_on) && (iSrc_Select==SIN_SANPLE))	?	sound_o[~SEL_Cont[3:0]]	:0; // Use SEL_Cont[3:0] as index

reg  [15:0]ramp1;
wire [15:0]ramp_max=60000;

// Corrected ramp1 generation - Synchronous to iCLK_18_4
reg LRCK_1X_d_ramp; // Previous value of LRCK_1X for ramp logic
always @(posedge iCLK_18_4 or negedge iRST_N) begin // Changed clock and reset trigger
  if (!iRST_N) begin // Use standard async reset
    ramp1 <= 0;
    LRCK_1X_d_ramp <= 1'b0;
  end else begin
    LRCK_1X_d_ramp <= LRCK_1X; // Sample LRCK_1X
    // Synchronous check for key1_on and LRCK_1X falling edge
    if (!key1_on) begin // Check key1_on level synchronously
        ramp1 <= 0;
    end else if (LRCK_1X_d_ramp && !LRCK_1X) begin // Update on falling edge of LRCK_1X if key1_on is high
        if (ramp1 > ramp_max)
            ramp1 <= 0;
        else
            ramp1 <= ramp1 + sound1;
    end
  end
end

wire [5:0] ramp1_ramp=ramp1[15:10];
wave_gen_string r1(
	.ramp(ramp1_ramp),
	.music_o(music1_ramp)
);

endmodule

// Assuming wave_gen_string is defined elsewhere and is DFT-friendly
// Example placeholder:
/*
module wave_gen_string (
    input [5:0] ramp,
    output reg [15:0] music_o
);
    // Simplified example logic
    always @(*) begin
        music_o = {ramp, 10'b0}; // Replace with actual logic
    end
endmodule
*/