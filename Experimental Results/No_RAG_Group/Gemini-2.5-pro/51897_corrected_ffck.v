module VgaSyncGenerator_corrected_ffc
(
    input              CLK       , // Primary clock input
    output reg         VGA_HS    ,
    output reg         VGA_VS    ,
    output wire [10:0] VGA_POS_X ,
    output wire [9 :0] VGA_POS_Y ,
    output wire        VGA_ENABLE
);

// Parameters for VGA timing (e.g., 800x600 @ 72Hz)
parameter HORIZONTAL_RESOLUTION  = 10'd800;
parameter HORIZONTAL_FRONT_PORCH = 8'd40;
parameter HORIZONTAL_SYNC_PULSE  = 8'd128;
parameter HORIZONTAL_BACK_PORCH  = 8'd88;

parameter VERTICAL_RESOLUTION    = 10'd600;
parameter VERTICAL_FRONT_PORCH   = 1'd1;
parameter VERTICAL_SYNC_PULSE    = 3'd4;
parameter VERTICAL_BACK_PORCH    = 5'd23;

// Calculate total horizontal and vertical counts
localparam H_TOTAL = HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH + HORIZONTAL_RESOLUTION + HORIZONTAL_FRONT_PORCH; // 128 + 88 + 800 + 40 = 1056
localparam V_TOTAL = VERTICAL_SYNC_PULSE + VERTICAL_BACK_PORCH + VERTICAL_RESOLUTION + VERTICAL_FRONT_PORCH;     // 4 + 23 + 600 + 1 = 628

// Calculate screen borders based on timing parameters
localparam SCREEN_LEFT_BORDER  = HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH; // 128 + 88 = 216
localparam SCREEN_RIGHT_BORDER = HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH + HORIZONTAL_RESOLUTION; // 216 + 800 = 1016
localparam SCREEN_UP_BORDER    = VERTICAL_SYNC_PULSE   + VERTICAL_BACK_PORCH;   // 4 + 23 = 27
localparam SCREEN_DOWN_BORDER  = VERTICAL_SYNC_PULSE   + VERTICAL_BACK_PORCH   + VERTICAL_RESOLUTION; // 27 + 600 = 627

// Internal counters for horizontal and vertical position
// Width must accommodate the TOTAL counts
reg [10:0] PosX = 0; // Needs 11 bits for H_TOTAL (1056)
reg [9 :0] PosY = 0; // Needs 10 bits for V_TOTAL (628)

// Sequential logic clocked by the primary input CLK
always @( posedge CLK )
begin
    // Horizontal Counter Logic
    if ( PosX == H_TOTAL ) begin // End of horizontal line
        PosX <= 0;
        // Vertical Counter Logic (increment/reset at the end of horizontal line)
        if ( PosY == V_TOTAL ) begin // End of vertical frame
            PosY <= 0;
        else begin
            PosY <= PosY + 1'b1;
        end
    end else begin
        PosX <= PosX + 1'b1;
    end

    // Sync Signal Generation (Registered outputs clocked by CLK)
    // VGA_HS is low during the sync pulse (PosX = 0 to HORIZONTAL_SYNC_PULSE - 1)
    // Original logic: VGA_HS <= (PosX > HORIZONTAL_SYNC_PULSE);
    // Let's keep the original logic's effective behavior: HS low for PosX <= HORIZONTAL_SYNC_PULSE
    VGA_HS <= (PosX > HORIZONTAL_SYNC_PULSE);

    // VGA_VS is low during the sync pulse (PosY = 0 to VERTICAL_SYNC_PULSE - 1)
    // Original logic: VGA_VS <= (PosY > VERTICAL_SYNC_PULSE);
    // Let's keep the original logic's effective behavior: VS low for PosY <= VERTICAL_SYNC_PULSE
    VGA_VS <= (PosY > VERTICAL_SYNC_PULSE);
end

// Combinational logic for screen area detection and position calculation
wire IsScreenX = ( PosX >= SCREEN_LEFT_BORDER ) && ( PosX < SCREEN_RIGHT_BORDER );
wire IsScreenY = ( PosY >= SCREEN_UP_BORDER   ) && ( PosY < SCREEN_DOWN_BORDER  );

// Assign outputs based on counters and screen area
// Ensure output widths match definitions
assign VGA_POS_X  = IsScreenX ? ( PosX - SCREEN_LEFT_BORDER ) : 11'd0; // Use 11 bits matching PosX for calculation intermediate
assign VGA_POS_Y  = IsScreenY ? ( PosY - SCREEN_UP_BORDER ) : 10'd0;  // Use 10 bits matching PosY for calculation intermediate
assign VGA_ENABLE = IsScreenX & IsScreenY;

endmodule