module VGA1Interface(
    input wire         clock,
    input wire         reset,
    input wire [63:0]  framebuffer,
    output wire        vga_hsync,
    output wire        vga_vsync,
    output wire        vga_r,
    output wire        vga_g,
    output wire        vga_b
);
    reg [9:0]  CounterX;
    reg [8:0]  CounterY;
    wire       value;
    reg        clock2;

    // Generate a 2x slower clock
    always @(posedge clock or posedge reset) begin
        if (reset)
            clock2 <= 1'b0;
        else
            clock2 <= ~clock2;
    end

    // Horizontal/Vertical counters
    wire CounterXmaxed = (CounterX == 10'd767);

    always @(posedge clock2 or posedge reset) begin
        if (reset)
            CounterX <= 10'd0;
        else if (CounterXmaxed)
            CounterX <= 10'd0;
        else
            CounterX <= CounterX + 1;
    end

    always @(posedge clock2 or posedge reset) begin
        if (reset)
            CounterY <= 9'd0;
        else if (CounterXmaxed)
            CounterY <= CounterY + 1;
    end

    // Generate HSYNC and VSYNC
    reg vga_HS, vga_VS;

    always @(posedge clock2 or posedge reset) begin
        if (reset) begin
            vga_HS <= 1'b0;
            vga_VS <= 1'b0;
        end
        else begin
            vga_HS <= (CounterX[9:4] == 6'd0);
            vga_VS <= (CounterY == 9'd0);
        end
    end

    assign vga_hsync = ~vga_HS;
    assign vga_vsync = ~vga_VS;

    // Divide screen into 8x8 tiles
    reg [2:0] ix;
    reg [2:0] iy;

    always @(posedge clock2 or posedge reset) begin
        if (reset)
            ix <= 3'b000;
        else if (CounterX < 80)
            ix <= 3'b000;
        else if (CounterX < 160)
            ix <= 3'b001;
        else if (CounterX < 240)
            ix <= 3'b010;
        else if (CounterX < 320)
            ix <= 3'b011;
        else if (CounterX < 400)
            ix <= 3'b100;
        else if (CounterX < 480)
            ix <= 3'b101;
        else if (CounterX < 560)
            ix <= 3'b110;
        else if (CounterX < 640)
            ix <= 3'b111;
        else
            ix <= 3'b000; // Default or blank region
    end

    always @(posedge clock2 or posedge reset) begin
        if (reset)
            iy <= 3'b000;
        else if (CounterY < 60)
            iy <= 3'b000;
        else if (CounterY < 120)
            iy <= 3'b001;
        else if (CounterY < 180)
            iy <= 3'b010;
        else if (CounterY < 240)
            iy <= 3'b011;
        else if (CounterY < 300)
            iy <= 3'b100;
        else if (CounterY < 360)
            iy <= 3'b101;
        else if (CounterY < 420)
            iy <= 3'b110;
        else if (CounterY < 480)
            iy <= 3'b111;
        else
            iy <= 3'b000; // Default or blank region
    end

    // In-display area and framebuffer indexing
    wire inDisplayArea = (CounterX < 640 && CounterY < 480);
    assign value       = framebuffer[{iy, ix}];
    assign vga_r       = value & inDisplayArea;
    assign vga_g       = value & inDisplayArea;
    assign vga_b       = value & inDisplayArea;

endmodule