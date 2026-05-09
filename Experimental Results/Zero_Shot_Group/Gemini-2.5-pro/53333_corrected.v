module	VGA_Ctrl	(
						iRed,
						iGreen,
						iBlue,
						oCurrent_X,
						oCurrent_Y,
						oAddress,
						oRequest,
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_HS,
						oVGA_VS,
						oVGA_SYNC,
						oVGA_BLANK,
						oVGA_CLOCK,
						iCLK,
						iRST_N	);
input		[9:0]	iRed;
input		[9:0]	iGreen;
input		[9:0]	iBlue;
output		[21:0]	oAddress;
output	reg	[10:0]	oCurrent_X; // Make reg if needed for timing, but assign driven is ok
output	reg	[10:0]	oCurrent_Y; // Make reg if needed for timing, but assign driven is ok
output				oRequest;
output		[9:0]	oVGA_R;
output		[9:0]	oVGA_G;
output		[9:0]	oVGA_B;
output	reg			oVGA_HS;
output	reg			oVGA_VS;
output				oVGA_SYNC;
output				oVGA_BLANK;
output				oVGA_CLOCK;
input				iCLK;
input				iRST_N;

reg			[10:0]	H_Cont;
reg			[10:0]	V_Cont;

// Horizontal Timing Parameters (640x480 @ 60Hz)
parameter	H_FRONT	=	16;         // Horizontal Front Porch
parameter	H_SYNC	=	96;         // Horizontal Sync Pulse Width
parameter	H_BACK	=	48;         // Horizontal Back Porch
parameter	H_ACT	=	640;        // Horizontal Active Video Pixels
parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK; // Total Horizontal Blanking Time
parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT; // Total Horizontal Time (800 pixels)

// Vertical Timing Parameters (640x480 @ 60Hz)
parameter	V_FRONT	=	10;         // Vertical Front Porch (Often 10 or 11)
parameter	V_SYNC	=	2;          // Vertical Sync Pulse Width
parameter	V_BACK	=	33;         // Vertical Back Porch (Often 31 or 33)
parameter	V_ACT	=	480;        // Vertical Active Video Lines
parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK;   // Total Vertical Blanking Time
parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;   // Total Vertical Time (525 lines)

// Combinational assignments for outputs
assign	oVGA_SYNC	=	1'b1;			// Often unused or tied low (active low sync) - kept as original
assign	oVGA_BLANK	=	!((H_Cont >= H_ACT) || (V_Cont >= V_ACT)); // Active Low Blanking during non-active periods
assign	oVGA_CLOCK	=	iCLK; // Typically use the input clock directly, inversion might depend on monitor spec
assign	oVGA_R		=	(oVGA_BLANK) ? iRed   : 10'b0; // Output color data only during active video
assign	oVGA_G		=	(oVGA_BLANK) ? iGreen : 10'b0;
assign	oVGA_B		=	(oVGA_BLANK) ? iBlue  : 10'b0;

// Address generation logic (combinational based on current counters)
// Note: oCurrent_X/Y represent coordinates within the *active* display area (0 to H_ACT-1, 0 to V_ACT-1)
assign	oCurrent_X	=	(H_Cont >= H_BLANK && H_Cont < H_TOTAL) ? (H_Cont - H_BLANK) : 11'h0;
assign	oCurrent_Y	=	(V_Cont >= V_BLANK && V_Cont < V_TOTAL) ? (V_Cont - V_BLANK) : 11'h0;
assign	oAddress	=	oCurrent_Y * H_ACT + oCurrent_X; // Linear address for framebuffer access

// Request signal - active during the active display period
assign	oRequest	=	(H_Cont >= H_BLANK && H_Cont < H_TOTAL) &&
						(V_Cont >= V_BLANK && V_Cont < V_TOTAL);


// Horizontal Counter and Sync Generation
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		oVGA_HS		<=	1'b1; // HS inactive (high) during reset
	end
	else
	begin
        // Increment horizontal counter or reset at end of line
		if(H_Cont < H_TOTAL - 1) // Count up to H_TOTAL-1
		    H_Cont	<=	H_Cont + 1'b1;
		else
		    H_Cont	<=	0;

        // Generate Horizontal Sync (Active Low)
        // HS should be low from H_ACT+H_FRONT to H_ACT+H_FRONT+H_SYNC - 1
		if (H_Cont == (H_ACT + H_FRONT - 1)) // Start of HS pulse (end of front porch)
            oVGA_HS <= 1'b0;
        else if (H_Cont == (H_ACT + H_FRONT + H_SYNC - 1)) // End of HS pulse (start of back porch)
            oVGA_HS <= 1'b1;
	end
end

// Vertical Counter and Sync Generation
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		oVGA_VS		<=	1'b1; // VS inactive (high) during reset
	end
	else
	begin
        // Check if horizontal counter is at the end of the line
		if (H_Cont == H_TOTAL - 1)
		begin
            // Increment vertical counter or reset at end of frame
			if(V_Cont < V_TOTAL - 1) // Count up to V_TOTAL-1
			    V_Cont	<=	V_Cont + 1'b1;
			else
			    V_Cont	<=	0;

            // Generate Vertical Sync (Active Low) based on the *next* line number
            // VS should be low during lines V_ACT+V_FRONT to V_ACT+V_FRONT+V_SYNC - 1
            // Use V_Cont value *before* it increments for timing checks
            if (V_Cont == (V_ACT + V_FRONT - 1)) // Start of VS pulse (end of front porch)
                oVGA_VS <= 1'b0;
            else if (V_Cont == (V_ACT + V_FRONT + V_SYNC - 1)) // End of VS pulse (start of back porch)
                oVGA_VS <= 1'b1;
		end
	end
end

endmodule