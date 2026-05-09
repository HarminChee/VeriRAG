module VGA1Interface(
    input wire clock,
    input wire reset,
    input wire [63:0] framebuffer,
    output wire vga_hsync,
    output wire vga_vsync,
    output wire vga_r,
    output wire vga_g,
    output wire vga_b
);

    reg [9:0] CounterX;
    reg [8:0] CounterY;
    reg value;
    reg clock2 = 0;
    reg vga_HS;
    reg vga_VS;
    reg [2:0] ix;
    reg [2:0] iy;

    wire inDisplayArea = (CounterX < 640) && (CounterY < 480);
    wire CounterXmaxed = (CounterX == 799); // Corrected value to 799 to match timing
    wire CounterYmaxed = (CounterY == 524); // Added CounterYmaxed signal


    always @(posedge clock) begin
        if (reset) begin
            clock2 <= 0;
        end else begin
            clock2 <= ~clock2;
        end
    end

    always @(posedge clock2) begin
        if (reset) begin
            CounterX <= 0;
        end else if (CounterXmaxed) begin
            CounterX <= 0;
        end else begin
            CounterX <= CounterX + 1;
        end
    end

    always @(posedge clock2) begin
        if (reset) begin
            CounterY <= 0;
        end else if (CounterXmaxed) begin
            if (CounterYmaxed) begin
                CounterY <= 0;
            end else begin
                CounterY <= CounterY + 1;
            end
        end
    end

    always @(posedge clock2) begin
        if (reset) begin
            vga_HS <= 1;
            vga_VS <= 1;
        end else begin
            vga_HS <= (CounterX >= 656 && CounterX <= 751) ? 0 : 1;   //Horizontal Sync Pulse
            vga_VS <= (CounterY >= 490 && CounterY <= 492) ? 0 : 1;  //Vertical Sync Pulse
        end
    end

    assign vga_hsync = vga_HS;
    assign vga_vsync = vga_VS;


    always @(posedge clock2) begin
        if (reset) begin
            ix <= 0;
        end else if (CounterX < 80) begin
            ix <= 0;
        end else if (CounterX < 160) begin
            ix <= 1;
        end else if (CounterX < 240) begin
            ix <= 2;
        end else if (CounterX < 320) begin
            ix <= 3;
        end else if (CounterX < 400) begin
            ix <= 4;
        end else if (CounterX < 480) begin
            ix <= 5;
        end else if (CounterX < 560) begin
            ix <= 6;
        end else if (CounterX < 640) begin
            ix <= 7;
        end else begin
            ix <= 0;
        end
    end

    always @(posedge clock2) begin
        if (reset) begin
            iy <= 0;
        end else if (CounterY < 60) begin
            iy <= 0;
        end else if (CounterY < 120) begin
            iy <= 1;
        end else if (CounterY < 180) begin
            iy <= 2;
        end else if (CounterY < 240) begin
            iy <= 3;
        end else if (CounterY < 300) begin
            iy <= 4;
        end else if (CounterY < 360) begin
            iy <= 5;
        end else if (CounterY < 420) begin
            iy <= 6;
        end else if (CounterY < 480) begin
            iy <= 7;
        end else begin
            iy <= 0;
        end
    end

    always @(posedge clock2) begin
        if (reset) begin
            value <= 0;
        end else if (inDisplayArea) begin
            value <= framebuffer[{iy, ix}];
        end else begin
            value <= 0;
        end
    end

    assign vga_r = value & inDisplayArea;
    assign vga_g = value & inDisplayArea;
    assign vga_b = value & inDisplayArea;

endmodule