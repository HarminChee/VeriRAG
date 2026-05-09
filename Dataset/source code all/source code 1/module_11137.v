`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module Player
#( parameter
    SMALL   = 40,
    BIG     = 80
)
(
    input wire [9:0] xpos,
    input wire [8:0] ypos,
    input wire direction,
    input wire size,
    input wire fire,
    input wire [9:0] hcount_in,
    input wire hsync_in,
    input wire [9:0] vcount_in,
    input wire vsync_in,
    input wire blnk_in,
    input wire rst,
    input wire clk,
    input wire [23:0] rgb_in,
    input wire [23:0] rom_data,
    output reg [10:0] rom_addr,
    output reg [9:0] hcount_out,
    output reg hsync_out,
    output reg [9:0] vcount_out,
    output reg vsync_out,
    output reg [23:0] rgb_out,
    output reg blnk_out
    );
    localparam ALFA_COLOR = 24'hA3_49_A4;
    localparam YRES = 480;
    localparam PLAYER_WIDTH = 40;
    reg [5:0] player_height;
    reg [5:0] player_height_nxt;
    reg [23:0] rgb_nxt;
    reg [10:0] rom_addr_nxt;
    always @(posedge clk or posedge rst) begin
        if(rst)
            rom_addr    <= #1 0;
        else
            rom_addr    <= #1 rom_addr_nxt;
    end
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rgb_out     <= #1 0;
            hcount_out  <= #1 0;
            hsync_out   <= #1 0;
            vcount_out  <= #1 0;
            vsync_out   <= #1 0;
            blnk_out    <= #1 0;
        end
        else begin
            rgb_out     <= #1 rgb_nxt;
            hcount_out  <= #1 hcount_in;
            hsync_out   <= #1 hsync_in;         
            vcount_out  <= #1 vcount_in;
            vsync_out   <= #1 vsync_in;
            blnk_out    <= #1 blnk_in;
        end
    end
    always @* begin
        if(size)
            player_height_nxt = BIG;
        else
            player_height_nxt = SMALL;
    end
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            player_height = SMALL;    
        end
        else begin
            player_height = player_height_nxt;
        end
    end
    always @* begin
        if(direction) begin
            rom_addr_nxt = PLAYER_WIDTH*(vcount_in  -(YRES - ypos - player_height)) + (PLAYER_WIDTH - 1 - (hcount_in - xpos + 1)); 
        end
        else begin
            rom_addr_nxt = PLAYER_WIDTH*(vcount_in  -(YRES - ypos - player_height)) + ((hcount_in - xpos + 1)); 
        end
    end
    always @*
      begin
        if(((YRES - 1 - vcount_in) < (ypos + player_height)) && ((YRES - 1 - vcount_in) >= ypos) && (hcount_in < (xpos+PLAYER_WIDTH) ) && ((xpos) <= hcount_in)) begin
            if(rom_data == ALFA_COLOR) 
                rgb_nxt = rgb_in;
            else
                rgb_nxt = rom_data;
        end
        else begin
            rgb_nxt = rgb_in;
        end
    end
endmodule
