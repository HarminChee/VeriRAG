module VGA1Interface (
    input wire        clock,        // Main system clock (e.g., 50 MHz)
    input wire        reset,        // Asynchronous reset
    input wire [63:0] framebuffer,  // 8x8 bit framebuffer input
    output wire       vga_hsync,    // Horizontal sync (active low)
    output wire       vga_vsync,    // Vertical sync (active low)
    output wire       vga_r,        // Red output
    output wire       vga_g,        // Green output
    output wire       vga_b         // Blue output
);

    // VGA Timing Constants for 640x480 @ 60 Hz (requires ~25 MHz pixel clock)
    localparam H_DISPLAY      = 640; // Horizontal display area
    localparam H_FRONT_PORCH  = 16;  // Front porch
    localparam H_SYNC_PULSE   = 96;  // Sync pulse
    localparam H_BACK_PORCH   = 48;  // Back porch
    localparam H_TOTAL        = H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; // Total horizontal pixels (800)

    localparam V_DISPLAY      = 480; // Vertical display area
    localparam V_FRONT_PORCH  = 10;  // Front porch
    localparam V_SYNC_PULSE   = 2;   // Sync pulse
    localparam V_BACK_PORCH   = 33;  // Back porch
    localparam V_TOTAL        = V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH; // Total vertical lines (525)

    // Pixel Clock Generation (Divide input clock by 2)
    reg clock_pix = 0;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            clock_pix <= 1'b0;
        end else begin
            clock_pix <= ~clock_pix;
        end
    end

    // Counters for horizontal and vertical position
    reg [9:0] CounterX; // Needs 10 bits for 0-799
    reg [9:0] CounterY; // Needs 10 bits for 0-524

    // Sync Signal Registers
    reg vga_HS_reg;
    reg vga_VS_reg;

    // Wires for timing conditions
    wire CounterXmaxed;
    wire CounterYmaxed;
    wire inDisplayArea;

    // Determine if counters reached their max limits
    assign CounterXmaxed = (CounterX == H_TOTAL - 1);
    assign CounterYmaxed = (CounterY == V_TOTAL - 1);

    // Determine if current pixel is within the visible display area
    assign inDisplayArea = (CounterX < H_DISPLAY) && (CounterY < V_DISPLAY);

    // Horizontal Counter Logic
    always @(posedge clock_pix or posedge reset) begin
        if (reset) begin
            CounterX <= 0;
        end else begin
            if (CounterXmaxed) begin
                CounterX <= 0;
            end else begin
                CounterX <= CounterX + 1;
            end
        end
    end

    // Vertical Counter Logic
    always @(posedge clock_pix or posedge reset) begin
        if (reset) begin
            CounterY <= 0;
        end else begin
            if (CounterXmaxed) begin // Increment Y only when X finishes a line
                if (CounterYmaxed) begin
                    CounterY <= 0;
                end else begin
                    CounterY <= CounterY + 1;
                end
            end
        end
    end

    // Horizontal Sync Signal Generation
    always @(posedge clock_pix or posedge reset) begin
        if (reset) begin
            vga_HS_reg <= 1'b1; // Inactive state (high for active low sync)
        end else begin
            // HSync pulse is active (low) during the H_SYNC_PULSE interval
            if ((CounterX >= H_DISPLAY + H_FRONT_PORCH) && (CounterX < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE)) begin
                vga_HS_reg <= 1'b0; // Active low
            end else begin
                vga_HS_reg <= 1'b1; // Inactive high
            end
        end
    end

    // Vertical Sync Signal Generation
    always @(posedge clock_pix or posedge reset) begin
        if (reset) begin
            vga_VS_reg <= 1'b1; // Inactive state (high for active low sync)
        end else begin
            // VSync pulse is active (low) during the V_SYNC_PULSE interval
            if ((CounterY >= V_DISPLAY + V_FRONT_PORCH) && (CounterY < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE)) begin
                vga_VS_reg <= 1'b0; // Active low
            end else begin
                vga_VS_reg <= 1'b1; // Inactive high
            end
        end
    end

    // Assign registered sync signals to outputs
    assign vga_hsync = vga_HS_reg;
    assign vga_vsync = vga_VS_reg;

    // Framebuffer Index Calculation (maps 640x480 display area to 8x8 framebuffer)
    reg [2:0] ix; // Index for 8 horizontal sections
    reg [2:0] iy; // Index for 8 vertical sections
    wire [5:0] fb_addr;
    wire       value;

    // Calculate horizontal index (ix) based on CounterX
    // Divides the 640 pixel width into 8 sections of 80 pixels each
    always @(*) begin
        if (CounterX < 80)      ix = 3'd0;
        else if (CounterX < 160) ix = 3'd1;
        else if (CounterX < 240) ix = 3'd2;
        else if (CounterX < 320) ix = 3'd3;
        else if (CounterX < 400) ix = 3'd4;
        else if (CounterX < 480) ix = 3'd5;
        else if (CounterX < 560) ix = 3'd6;
        else if (CounterX < 640) ix = 3'd7;
        else                     ix = 3'd0; // Default outside display area
    end

    // Calculate vertical index (iy) based on CounterY
    // Divides the 480 line height into 8 sections of 60 lines each
    always @(*) begin
        if (CounterY < 60)       iy = 3'd0;
        else if (CounterY < 120) iy = 3'd1;
        else if (CounterY < 180) iy = 3'd2;
        else if (CounterY < 240) iy = 3'd3;
        else if (CounterY < 300) iy = 3'd4;
        else if (CounterY < 360) iy = 3'd5;
        else if (CounterY < 420) iy = 3'd6;
        else if (CounterY < 480) iy = 3'd7;
        else                     iy = 3'd0; // Default outside display area
    end

    // Combine iy and ix to form the 6-bit address for the 64-bit framebuffer
    assign fb_addr = {iy, ix};
    assign value = framebuffer[fb_addr];

    // VGA RGB Output - Monochrome based on 'value' within display area
    assign vga_r = value & inDisplayArea;
    assign vga_g = value & inDisplayArea;
    assign vga_b = value & inDisplayArea;

endmodule