module	VGA_Ctrl	(	//	Host Side
						iRed,
						iGreen,
						iBlue,
						oCurrent_X,
						oCurrent_Y,
						oAddress,
						oRequest,
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_HS,
						oVGA_VS,
						oVGA_SYNC,
						oVGA_BLANK,
						oVGA_CLOCK,
						//	Control Signal
						iCLK,
						iRST_N	);
//	Host Side
input		[9:0]	iRed;
input		[9:0]	iGreen;
input		[9:0]	iBlue;
output		[21:0]	oAddress;
output		[10:0]	oCurrent_X;
output		[10:0]	oCurrent_Y;
output				oRequest;
//	VGA Side
output		[9:0]	oVGA_R;
output		[9:0]	oVGA_G;
output		[9:0]	oVGA_B;
output	reg			oVGA_HS;
output	reg			oVGA_VS;
output				oVGA_SYNC;
output				oVGA_BLANK;
output				oVGA_CLOCK;
//	Control Signal
input				iCLK;
input				iRST_N;
//	Internal Registers
reg			[10:0]	H_Cont_reg;
reg			[10:0]	V_Cont_reg;

////////////////////////////////////////////////////////////
//	Horizontal	Parameter (Example for 640x480 @ 60Hz, 25.175MHz pixel clock)
parameter	H_FRONT	=	16;
parameter	H_SYNC	=	96;
parameter	H_BACK	=	48;
parameter	H_ACT	=	640;
parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK; //160
parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT; //800
////////////////////////////////////////////////////////////
//	Vertical Parameter (Example for 640x480 @ 60Hz)
parameter	V_FRONT	=	10; // Note: Often specified as 10 or 11 lines
parameter	V_SYNC	=	2;
parameter	V_BACK	=	33; // Note: Often specified as 33 or 31 lines
parameter	V_ACT	=	480;
parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK; //45
parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT; //525
////////////////////////////////////////////////////////////

// Internal signal indicating end of horizontal line
wire	h_end_tick = (H_Cont_reg == H_TOTAL - 1);

// Combinational Assignments
assign	oVGA_SYNC	=	1'b0; // Typically tied low (Composite Sync not used)
assign	oVGA_BLANK	=	~((H_Cont_reg >= H_ACT) || (V_Cont_reg >= V_ACT)); // Active Low Blank during non-active regions
assign	oVGA_CLOCK	=	iCLK; // VGA clock is typically the pixel clock itself

// Video data output - delayed by one cycle if needed, here direct passthrough
assign	oVGA_R		= (oVGA_BLANK) ? 10'b0 : iRed; // Blank data during non-active periods
assign	oVGA_G		= (oVGA_BLANK) ? 10'b0 : iGreen;
assign	oVGA_B		= (oVGA_BLANK) ? 10'b0 : iBlue;

// Active pixel coordinates and memory request signal
assign	oCurrent_X	=	(H_Cont_reg >= H_BLANK) ? (H_Cont_reg - H_BLANK) : 11'h0; // X within active region
assign	oCurrent_Y	=	(V_Cont_reg >= V_BLANK) ? (V_Cont_reg - V_BLANK) : 11'h0; // Y within active region

// Memory Address calculation (linear frame buffer)
assign	oAddress	=	oCurrent_Y * H_ACT + oCurrent_X;

// Request signal asserted during active display area
assign	oRequest	=	((H_Cont_reg >= H_BLANK) && (H_Cont_reg < H_TOTAL) &&
						 (V_Cont_reg >= V_BLANK) && (V_Cont_reg < V_TOTAL));

//	Horizontal Generator: Refer to the pixel clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont_reg	<=	0;
		oVGA_HS		<=	1'b1; // HS Active Low, starts High
	end
	else
	begin
		// Horizontal Counter
		if(H_Cont_reg == H_TOTAL - 1)
			H_Cont_reg <= 0;
		else
			H_Cont_reg <= H_Cont_reg + 1'b1;

		// Horizontal Sync Signal (Active Low)
		if(H_Cont_reg == (H_ACT + H_FRONT - 1)) // End of Front Porch
			oVGA_HS <= 1'b0; // Start Sync Pulse
		else if(H_Cont_reg == (H_TOTAL - H_BACK - 1)) // End of Sync Pulse
			oVGA_HS <= 1'b1; // End Sync Pulse
	end
end

//	Vertical Generator: Refer to the pixel clock and horizontal line end
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont_reg	<=	0;
		oVGA_VS		<=	1'b1; // VS Active Low, starts High
	end
	else
	begin
		// Vertical Counter increments at the end of each horizontal line
		if(h_end_tick) // Check if H_Cont is at its max value
		begin
			if(V_Cont_reg == V_TOTAL - 1)
				V_Cont_reg <= 0;
			else
				V_Cont_reg <= V_Cont_reg + 1'b1;
		end

		// Vertical Sync Signal (Active Low) - Updated based on line count
        // Use V_Cont_reg directly to determine VS state for the current line
		if(V_Cont_reg == (V_ACT + V_FRONT -1)) // End of Front Porch
			oVGA_VS <= 1'b0; // Start Sync Pulse
		else if(V_Cont_reg == (V_TOTAL - V_BACK - 1)) // End of Sync Pulse
			oVGA_VS <= 1'b1; // End Sync Pulse
	end
end

endmodule