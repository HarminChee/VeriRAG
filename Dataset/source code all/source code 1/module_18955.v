module demo2_text (
    input wire clk, 
    input wire [10:0] PIXEL_H, PIXEL_V,
    output reg [2:0] PIXEL
);
    wire [10:0] rom_addr;
    reg [6:0] char_addr;
    reg [3:0] row_addr;
    reg [2:0] bit_addr;
    wire [7:0] font_word;
    wire font_bit;
    wire text_on;
    font_rom font_unit
    (.clk(clk), .addr(rom_addr), .data(font_word));
    reg [10:0] tile_v_start = 8'd10;
    reg [10:0] tile_h_start = 8'd200;
    wire [10:0] tile_v_end;
    wire [10:0] tile_h_end;
    assign tile_v_end = tile_v_start + (8'd15 << 2);
    assign tile_h_end = tile_h_start + (8'd7 << 2);
    assign text_on = (PIXEL_H >= tile_h_start && PIXEL_H <= tile_h_end && PIXEL_V >= tile_v_start && PIXEL_V <= tile_v_end);
    always @* begin
        PIXEL = 3'b000;
        if (text_on) begin
            char_addr = 7'h30; 
            row_addr = (PIXEL_V - tile_v_start) >> 2;
            bit_addr = (PIXEL_H - tile_h_start) >> 2;
            if (font_bit)
               PIXEL = 3'b111;
        end else begin
            char_addr = 0;
            row_addr = 0;
            bit_addr = 0;
        end
    end
    assign rom_addr = {char_addr, row_addr};
    assign font_bit = font_word[~bit_addr];
endmodule
