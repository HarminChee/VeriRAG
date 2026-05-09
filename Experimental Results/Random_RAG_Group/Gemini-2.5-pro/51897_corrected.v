module VgaSyncGenerator
(
    input              CLK       ,
    input              RST       ,
    input              TEST_MODE ,
    output reg         VGA_HS    ,
    output reg         VGA_VS    ,
    output wire [10:0] VGA_POS_X ,
    output wire [9 :0] VGA_POS_Y ,
    output wire        VGA_ENABLE
);
parameter HORIZONTAL_RESOLUTION  = 10'd800;
parameter HORIZONTAL_FRONT_PORCH = 8'd40;
parameter HORIZONTAL_SYNC_PULSE  = 8'd128;
parameter HORIZONTAL_BACK_PORCH  = 8'd88;
parameter VERTICAL_RESOLUTION    = 10'd600;
parameter VERTICAL_FRONT_PORCH   = 1'd1;
parameter VERTICAL_SYNC_PULSE    = 3'd4;
parameter VERTICAL_BACK_PORCH    = 5'd23;
localparam SCREEN_LEFT_BORDER  = HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH;
localparam SCREEN_RIGHT_BORDER = HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH + HORIZONTAL_RESOLUTION;
localparam SCREEN_UP_BORDER    = VERTICAL_SYNC_PULSE   + VERTICAL_BACK_PORCH;
localparam SCREEN_DOWN_BORDER  = VERTICAL_SYNC_PULSE   + VERTICAL_BACK_PORCH   + VERTICAL_RESOLUTION;
reg [10:0] PosX = 0;
reg [9 :0] PosY = 0;
wire IsScreenX = ( PosX >= SCREEN_LEFT_BORDER ) && ( PosX < SCREEN_RIGHT_BORDER );
wire IsScreenY = ( PosY >= SCREEN_UP_BORDER   ) && ( PosY < SCREEN_DOWN_BORDER  );
assign VGA_POS_X  = IsScreenX ? ( PosX - SCREEN_LEFT_BORDER ) : 10'd0;
assign VGA_POS_Y  = IsScreenY ? ( PosY - SCREEN_UP_BORDER ) : 9'd0;
assign VGA_ENABLE = IsScreenX & IsScreenY;
wire dft_clk;
assign dft_clk = TEST_MODE ? CLK : Clk;
reg Clk = 1'b0;
always @( posedge CLK or posedge RST )
begin
    if (RST)
        Clk <= 1'b0;
    else
        Clk <= ~Clk;
end
always @( posedge dft_clk or posedge RST )
begin
    if (RST)
    begin
        VGA_HS <= 1'b0;
        PosX <= 0;
    end
    else
    begin
        VGA_HS <= (PosX > HORIZONTAL_SYNC_PULSE);
        if (PosX > (HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH + HORIZONTAL_RESOLUTION + HORIZONTAL_FRONT_PORCH))
            PosX <= 0;
        else
            PosX <= PosX + 1'b1;
    end
end
always @( negedge VGA_HS or posedge RST )
begin
    if (RST)
    begin
        VGA_VS <= 1'b0;
        PosY <= 0;
    end
    else
    begin
        VGA_VS <= (PosY > VERTICAL_SYNC_PULSE);
        if (PosY > (VERTICAL_SYNC_PULSE + VERTICAL_BACK_PORCH + VERTICAL_RESOLUTION + VERTICAL_FRONT_PORCH))
            PosY <= 0;
        else
            PosY <= PosY + 1'b1;
    end
end
endmodule