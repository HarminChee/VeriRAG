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
                        test_i, // Added for DFT consistency
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
input               test_i; // Added for DFT consistency
input				iCLK;
input				iRST_N;
//	Internal Registers
reg			[10:0]	H_Cont;
reg			[10:0]	V_Cont;
////////////////////////////////////////////////////////////
//	Horizontal	Parameter
parameter	H_FRONT	=	16;
parameter	H_SYNC	=	96;
parameter	H_BACK	=	48;
parameter	H_ACT	=	640;
parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK; //160
parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT; //800
////////////////////////////////////////////////////////////
//	Vertical Parameter
parameter	V_FRONT	=	11;
parameter	V_SYNC	=	2;
parameter	V_BACK	=	31;
parameter	V_ACT	=	480;
parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK; //44
parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT; //524
////////////////////////////////////////////////////////////
assign	oVGA_SYNC	=	1'b1;			//	This pin is unused.
assign	oVGA_BLANK	=	~((H_Cont<H_BLANK)||(V_Cont<V_BLANK));
assign	oVGA_CLOCK	=	~iCLK;
assign	oVGA_R		=	iRed;
assign	oVGA_G		=	iGreen;
assign	oVGA_B		=	iBlue;
assign	oAddress	=	oCurrent_Y*H_ACT+oCurrent_X;
assign	oRequest	=	((H_Cont>=H_BLANK && H_Cont<H_TOTAL)	&&
						 (V_Cont>=V_BLANK && V_Cont<V_TOTAL));
assign	oCurrent_X	=	(H_Cont>=H_BLANK)	?	H_Cont-H_BLANK	:	11'h0	;
assign	oCurrent_Y	=	(V_Cont>=V_BLANK)	?	V_Cont-V_BLANK	:	11'h0	;

//	Horizontal Generator: Refer to the pixel clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		oVGA_HS		<=	1'b1; // HS normally high initially
	end
	else
	begin
		if(H_Cont < H_TOTAL - 1) // Check before increment
		    H_Cont	<=	H_Cont + 1'b1;
		else
		    H_Cont	<=	0;

		//	Horizontal Sync based on the value H_Cont will take *after* the clock edge
        //  Corrected timing for HS signal generation relative to H_Cont value
		if(H_Cont == H_FRONT - 2)			// Condition for HS to go low
		    oVGA_HS	<=	1'b0;
		if(H_Cont == H_FRONT + H_SYNC - 2)	// Condition for HS to go high
		    oVGA_HS	<=	1'b1;
	end
end

//	Vertical Generator: Refer to the pixel clock, enabled by H_Cont reaching end of line
wire H_Line_End = (H_Cont == H_TOTAL - 1); // Generate enable signal

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		oVGA_VS		<=	1'b1; // VS normally high initially
	end
	else if (H_Line_End) // Update only at the end of the horizontal line
	begin
		if(V_Cont < V_TOTAL - 1) // Check before increment
		    V_Cont	<=	V_Cont + 1'b1;
		else
		    V_Cont	<=	0;

		//	Vertical Sync logic triggered by V_Cont value *before* update
        //  Corrected timing for VS signal generation relative to V_Cont value
		if(V_Cont == V_FRONT - 1)			// Condition for VS to go low
		    oVGA_VS	<=	1'b0;
		if(V_Cont == V_FRONT + V_SYNC - 1)	// Condition for VS to go high
		    oVGA_VS	<=	1'b1;
        // Ensure VS is high when rolling over to start of frame (V_Cont=0)
        if(V_Cont == V_TOTAL - 1)           // When V_Cont is about to roll over
            oVGA_VS <= 1'b1;                // Set VS high for the next frame start
	end
    // If H_Line_End is false, V_Cont and oVGA_VS retain their values implicitly
end

endmodule