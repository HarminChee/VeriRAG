module VgaSyncGenerator
(
    input              CLK       ,
    output reg         VGA_HS    ,
    output reg         VGA_VS    ,
    output wire [9 :0] VGA_POS_X ,
    output wire [9 :0] VGA_POS_Y ,
    output wire        VGA_ENABLE
);
parameter HORIZONTAL_RESOLUTION  = 10'd800;
parameter HORIZONTAL_FRONT_PORCH = 10'd40;
parameter HORIZONTAL_SYNC_PULSE  = 10'd128;
parameter HORIZONTAL_BACK_PORCH  = 10'd88;
parameter VERTICAL_RESOLUTION    = 10'd600;
parameter VERTICAL_FRONT_PORCH   = 10'd1;
parameter VERTICAL_SYNC_PULSE    = 10'd4;
parameter VERTICAL_BACK_PORCH    = 10'd23;
localparam SCREEN_LEFT_BORDER  = HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH;
localparam SCREEN_RIGHT_BORDER = HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH + HORIZONTAL_RESOLUTION;
localparam SCREEN_UP_BORDER    = VERTICAL_SYNC_PULSE   + VERTICAL_BACK_PORCH;
localparam SCREEN_DOWN_BORDER  = VERTICAL_SYNC_PULSE   + VERTICAL_BACK_PORCH   + VERTICAL_RESOLUTION;
reg [10:0] PosX = 0;
reg [9 :0] PosY = 0;
wire IsScreenX = (PosX >= SCREEN_LEFT_BORDER) && (PosX < SCREEN_RIGHT_BORDER);
wire IsScreenY = (PosY >= SCREEN_UP_BORDER)   && (PosY < SCREEN_DOWN_BORDER);
assign VGA_POS_X  = IsScreenX ? (PosX - SCREEN_LEFT_BORDER) : 10'd0;
assign VGA_POS_Y  = IsScreenY ? (PosY - SCREEN_UP_BORDER)   : 10'd0;
assign VGA_ENABLE = IsScreenX && IsScreenY;
reg pixel_clk = 1'b0;
always @(posedge CLK)
begin
    pixel_clk <= ~pixel_clk;
end
always @(posedge pixel_clk)
begin
    VGA_HS <= (PosX > HORIZONTAL_SYNC_PULSE);
    if (PosX > (HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH + HORIZONTAL_RESOLUTION + HORIZONTAL_FRONT_PORCH))
        PosX <= 0;
    else
        PosX <= PosX + 1'b1;
end
always @(negedge VGA_HS)
begin
    VGA_VS <= (PosY > VERTICAL_SYNC_PULSE);
    if (PosY > (VERTICAL_SYNC_PULSE + VERTICAL_BACK_PORCH + VERTICAL_RESOLUTION + VERTICAL_FRONT_PORCH))
        PosY <= 0;
    else
        PosY <= PosY + 1'b1; 
end
endmodule