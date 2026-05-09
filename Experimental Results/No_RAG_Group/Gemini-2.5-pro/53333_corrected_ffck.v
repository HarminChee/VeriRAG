module	VGA_Ctrl_corrected_ffc	(
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
output		[10:0]	oCurrent_X;
output		[10:0]	oCurrent_Y;
output				oRequest;
output		[9:0]	oVGA_R;
output		[9:0]	oVGA_G;
output		[9:0]	oVGA_B;
output	reg			oVGA_HS; // Driven by synchronous logic using iCLK
output	reg			oVGA_VS; // Driven by synchronous logic using iCLK
output				oVGA_SYNC;
output				oVGA_BLANK;
output				oVGA_CLOCK;
input				iCLK;       // Primary clock input
input				iRST_N;     // Primary asynchronous reset input

// Internal state registers
reg			[10:0]	H_Cont;
reg			[10:0]	V_Cont;

// Parameters
parameter	H_FRONT	=	16;
parameter	H_SYNC	=	96;
parameter	H_BACK	=	48;
parameter	H_ACT	=	640;
parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK; // 160
parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT; // 800 (0 to 799)

parameter	V_FRONT	=	11;
parameter	V_SYNC	=	2;
parameter	V_BACK	=	31;
parameter	V_ACT	=	480;
parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK; // 44
parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT; // 524 (0 to 523)

// Intermediate signals for next state calculation
reg [10:0] H_Cont_nxt;
reg [10:0] V_Cont_nxt;
reg oVGA_HS_nxt;
reg oVGA_VS_nxt;
reg H_Cont_Rollover; // Signal indicating H_Cont is about to roll over
reg V_Cont_Rollover; // Signal indicating V_Cont is about to roll over

// Continuous assignments for outputs based on current state
assign	oVGA_SYNC	=	1'b1; // Note: Standard VGA SYNC is usually active low (0)
assign	oVGA_CLOCK	=	~iCLK; // Output inverted clock. May cause timing issues/DRCs.

// Active area calculation (combinational)
wire H_Active = (H_Cont >= H_BLANK) && (H_Cont < H_TOTAL);
wire V_Active = (V_Cont >= V_BLANK) && (V_Cont < V_TOTAL);
wire Video_Active = H_Active && V_Active;

assign	oVGA_BLANK	=	~Video_Active; // Active low blanking output

// Output RGB data only during active video period
assign	oVGA_R		=	Video_Active ? iRed   : 10'b0;
assign	oVGA_G		=	Video_Active ? iGreen : 10'b0;
assign	oVGA_B		=	Video_Active ? iBlue  : 10'b0;

// Calculate Current X/Y based on registered counters relative to blanking periods
assign	oCurrent_X	=	H_Active ? (H_Cont - H_BLANK) : 11'h0;
assign	oCurrent_Y	=	V_Active ? (V_Cont - V_BLANK) : 11'h0;

// Address calculation based on Current X/Y within the active frame
assign	oAddress	=	oCurrent_Y * H_ACT + oCurrent_X;

// Request signal active during active video period
assign	oRequest	=	Video_Active;


// Combinational logic for calculating next state values
always @(*) begin
    // Determine rollover conditions
    H_Cont_Rollover = (H_Cont == H_TOTAL - 1);
    V_Cont_Rollover = (V_Cont == V_TOTAL - 1);

    // Calculate next Horizontal Counter value
    if (H_Cont_Rollover) begin
        H_Cont_nxt = 0;
    end else begin
        H_Cont_nxt = H_Cont + 1'b1;
    end

    // Calculate next Vertical Counter value (increments only when H_Cont rolls over)
    if (H_Cont_Rollover) begin
        if (V_Cont_Rollover) begin
            V_Cont_nxt = 0;
        end else begin
            V_Cont_nxt = V_Cont + 1'b1;
        end
    end else begin
        V_Cont_nxt = V_Cont; // Hold V_Cont value otherwise
    end

    // Calculate next Horizontal Sync state (active low)
    // HS should be low during H_SYNC period (H_FRONT to H_FRONT + H_SYNC - 1)
    if (H_Cont_nxt >= H_FRONT && H_Cont_nxt < (H_FRONT + H_SYNC)) begin
        oVGA_HS_nxt = 1'b0; // Active low
    end else begin
        oVGA_HS_nxt = 1'b1; // Inactive high
    end

    // Calculate next Vertical Sync state (active low)
    // VS state depends on the *current* V_Cont, but only updates when H_Cont rolls over.
    // Use V_Cont_nxt for calculation as it reflects the line number for the *next* cycle beginning when H_Cont=0.
    if (V_Cont_nxt >= V_FRONT && V_Cont_nxt < (V_FRONT + V_SYNC)) begin
       oVGA_VS_nxt = 1'b0; // Active low
    end else begin
       oVGA_VS_nxt = 1'b1; // Inactive high
    end
    // Note: The VS logic updates based on the next vertical count value calculated combinatorially.
    // If VS needs to change strictly based on the *registered* V_Cont value *before* it increments,
    // the logic would compare V_Cont instead of V_Cont_nxt inside the H_Cont_Rollover condition.
    // The current implementation aligns VS with the line number that *will be* active.
end


// Sequential logic block: All registers clocked by the primary clock iCLK
always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N) begin
        H_Cont  <= 0;
        V_Cont