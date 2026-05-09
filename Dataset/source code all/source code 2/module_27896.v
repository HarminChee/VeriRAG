module vga_demo
    (
        CLOCK_PIXEL,
        RESET,
        VGA_RED,
        VGA_GREEN,
        VGA_BLUE,
        VGA_HS,
        VGA_VS
    );
    input CLOCK_PIXEL;
    input RESET;
    output VGA_RED;
    output VGA_GREEN;
    output VGA_BLUE;
    output VGA_HS;
    output VGA_VS;
    reg [10:0] hor_reg; 
    reg hor_sync;
    wire hor_max = (hor_reg == 975); 
    reg [9:0] ver_reg; 
    reg ver_sync;
    reg red, green, blue;
    wire ver_max = (ver_reg == 527); 
    always @ (posedge CLOCK_PIXEL or posedge RESET) begin
        if (RESET) begin 
            hor_reg <= 0;
            ver_reg <= 0;
        end
        else if (hor_max) begin
            hor_reg <= 0;
            if (ver_max)
                ver_reg <= 0;
            else
            ver_reg <= ver_reg + 1;
        end else
            hor_reg <= hor_reg + 1;
    end
    always @ (posedge CLOCK_PIXEL or posedge RESET) begin
        if (RESET) begin 
            hor_sync <= 0;
            ver_sync <= 0;
            red <= 0;
            green <= 0;
            blue <= 0;
        end
        else begin
            if (hor_reg == 840)      
                hor_sync <= 1;       
            else if (hor_reg == 928) 
                hor_sync <= 0;       
            if (ver_reg == 493)      
                ver_sync <= 1;       
            else if (ver_reg == 496) 
                ver_sync <= 0;       
            if (ver_reg > 480 || hor_reg > 800) begin
                red <= 0;
                green <= 0;
                blue <= 0;
            end
            else begin
                if (hor_reg >= 100 && hor_reg <= 200 && ver_reg >= 100 && ver_reg <= 200) begin
                    red <= 0;
                    green <= 1;
                    blue <= 0;
                end 
                else if (ver_reg == 0 ) begin
                    red <= 0;
                    green <= 1;
                    blue <= 0;
                end
                else if (ver_reg == 478 ) begin 
                    red <= 0;
                    green <= 1;
                    blue <= 0;
                end
                else if (hor_reg == 0 ) begin
                    red <= 1;
                    green <= 0;
                    blue <= 0;
                end
                else if (hor_reg == 780 ) begin 
                    red <= 1;
                    green <= 0;
                    blue <= 0;
                end
                else begin
                    red <= 1;
                    green <= 1;
                    blue <= 1;
                end
            end
        end
    end
    assign VGA_HS = hor_sync;
    assign VGA_VS = ver_sync;
    assign VGA_RED =  red;
    assign VGA_GREEN = green;
    assign VGA_BLUE = blue;
endmodule
