module VgaSyncGenerator
(
    input              CLK       ,
    output reg         VGA_HS    , // Horizontal Sync (Active Low)
    output reg         VGA_VS    , // Vertical Sync (Active Low)
    output wire [10:0] VGA_POS_X , // Horizontal pixel coordinate (within active region)
    output wire [9 :0] VGA_POS_Y , // Vertical pixel coordinate (within active region)
    output wire        VGA_ENABLE  // High when within active video region
);

// Default Parameters for 800x600 @ 72Hz (matches VESA 800x600@72Hz CVT)
// Pixel Clock: 50.00 MHz
// Horizontal Timing (clocks):
parameter H_RESOLUTION  = 10'd800;  // Horizontal resolution
parameter H_FRONT_PORCH = 8'd56;    // Horizontal front porch
parameter H_SYNC_PULSE  = 8'd120;   // Horizontal sync pulse width
parameter H_BACK_PORCH  = 8'd64;    // Horizontal back porch
// Vertical Timing (lines):
parameter V_RESOLUTION    = 10'd600;  // Vertical resolution
parameter V_FRONT_PORCH   = 3'd37;    // Vertical front porch
parameter V_SYNC_PULSE    = 3'd6;     // Vertical sync pulse width
parameter V_BACK_PORCH    = 5'd23;    // Vertical back porch

// Calculate total horizontal and vertical periods
localparam H_TOTAL = H_RESOLUTION + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; // 800+56+120+64 = 1040
localparam V_TOTAL = V_RESOLUTION + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;   // 600+37+6+23 = 666

// Calculate active video region boundaries (using 0-based counting)
// Horizontal: Sync(0..119), BP(120..183), Active(184..983), FP(984..1039)
localparam H_SYNC_END  = H_SYNC_PULSE;                                  // 120
localparam H_BP_END    = H_SYNC_PULSE + H_BACK_PORCH;                   // 184 (Start of Active Video)
localparam H_ACTIVE_END= H_SYNC_PULSE + H_BACK_PORCH + H_RESOLUTION;    // 984 (End of Active Video)

// Vertical: Sync(0..5), BP(6..28), Active(29..628), FP(629..665)
localparam V_SYNC_END  = V_SYNC_PULSE;                                  // 6
localparam V_BP_END    = V_SYNC_PULSE + V_BACK_PORCH;                   // 29 (Start of Active Video)
localparam V_ACTIVE_END= V_SYNC_PULSE + V_BACK_PORCH + V_RESOLUTION;    // 629 (End of Active Video)

// Counters for horizontal and vertical position
// Need ceil(log2(H_TOTAL)) bits for PosX -> ceil(log2(1040)) = 11 bits
// Need ceil(log2(V_TOTAL)) bits for PosY -> ceil(log2(666)) = 10 bits
reg [10:0] PosX = 0;
reg [9 :0] PosY = 0;

// Internal signals to determine active video region
wire IsScreenX;
wire IsScreenY;

// Main synchronous logic for counters and sync signals
always @( posedge CLK )
begin
    // Horizontal Counter
    if ( PosX == H_TOTAL - 1 ) begin
        PosX <= 0;
        // Vertical Counter (increments at the end of each horizontal line)
        if ( PosY == V_TOTAL - 1) begin
            PosY <= 0;
        end else begin
            PosY <= PosY + 1'b1;
        end
    end else begin
        PosX <= PosX + 1'b1;
    end

    // Generate Sync Signals (Active Low)
    // HS is low during H_SYNC_PULSE duration (PosX from 0 to H_SYNC_PULSE - 1)
    VGA_HS <= (PosX >= H_SYNC_PULSE);

    // VS is low during V_SYNC_PULSE duration (PosY from 0 to V_SYNC_PULSE - 1)
    VGA_VS <= (PosY >= V_SYNC_PULSE);
end

// Combinational logic for Active Video region and coordinates
assign IsScreenX = ( PosX >= H_BP_END ) && ( PosX < H_ACTIVE_END );
assign IsScreenY = ( PosY >= V_BP_END ) && ( PosY < V_ACTIVE_END );

// Output pixel coordinates relative to the top-left corner (0,0) of the active region
assign VGA_POS_X  = IsScreenX ? ( PosX - H_BP_END ) : 11'd0; // Max value H_RESOLUTION-1
assign VGA_POS_Y  = IsScreenY ? ( PosY - V_BP_END ) : 10'd0; // Max value V_RESOLUTION-1

// VGA_ENABLE is high only when both counters are within the active display area
assign VGA_ENABLE = IsScreenX & IsScreenY;

endmodule