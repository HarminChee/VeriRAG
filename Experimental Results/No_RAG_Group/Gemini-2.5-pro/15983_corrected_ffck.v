module VGA1Interface_corrected_ffc (
    input wire         clock,
    input wire         reset, // Assuming active-high reset
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

    // FF to generate state for clock enable signal
    reg clock_div_reg = 0;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            clock_div_reg <= 1'b0;
        end else begin
            clock_div_reg <= ~clock_div_reg;
        end
    end

    // Clock enable signal: Active when the original divided clock (clock2) would have its positive edge.
    // This happens when clock_div_reg is 0 before the clock edge.
    wire clk_en = ~clock_div_reg;

    // VGA Sync Registers
    reg vga_HS; // Internal register for HSync generation logic
    reg vga_VS; // Internal register for VSync generation logic

    // Counter Max Values (based on original code's apparent logic)
    localparam COUNTER_X_MAX = 10'd767; // Use original max value
    // Determine CounterY max value - needs definition for wrap-around. Assume 525 lines total for VGA timing.
    localparam COUNTER_Y_MAX = 9'd524; // Example for standard VGA timing (adjust if needed)

    // CounterX logic - Clocked by primary clock, enabled by clk_en
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            CounterX <= 10'd0;
        end else if (clk_en) begin
            if (CounterX == COUNTER_X_MAX) begin
                CounterX <= 10'd0;
            else begin
                CounterX <= CounterX + 1;
            end
        end
    end

    // CounterY logic: Increments only when CounterX wraps - Clocked by primary clock, enabled by clk_en
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            CounterY <= 9'd0;
        end else if (clk_en) begin
            // Check if CounterX was maxed out *before* this enabled clock edge
            if (CounterX == COUNTER_X_MAX) begin
                 if (CounterY == COUNTER_Y_MAX) begin
                     CounterY <= 9'd0;
                 else begin
                     CounterY <= CounterY + 1;
                 end
            end
             // No change to CounterY if CounterX is not maxed out
        end
    end

    // VGA Sync signal generation logic - Clocked by primary clock, enabled by clk_en
    always @(posedge clock or posedge reset) begin
        if (reset) begin
             // Initialize to inactive state (assuming active low sync outputs)
            vga_HS <= 1'b1; // vga_hsync will be high (inactive)
            vga_VS <= 1'b1; // vga_vsync will be high (inactive)
        end else if (clk_en) begin
             // Original logic: vga_HS <= (CounterX[9:4]==0); vga_VS <= (CounterY==0);
             // This sets the internal register high during the condition.
             // Since outputs are inverted (~vga_HS, ~vga_VS), this makes the output sync LOW (active).
             vga_HS <= (CounterX[9:4] == 6'b000000); // Sync active (output low) during CounterX 0-15
             vga_VS <= (CounterY == 9'd0);         // Sync active (output low) during CounterY 0
        end
    end

    // Index calculation logic for framebuffer lookup - Clocked by primary clock, enabled by clk_en
    reg [2:0] ix;
    reg [2:0] iy;

    // ix calculation
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            ix <= 3'd0;
        end else if (clk_en) begin
            // Map CounterX (0-639 assumed active range) to ix (0-7) based on 80-pixel blocks
            if (CounterX < 80)        ix <= 3'd0;
            else if (CounterX < 160)  ix <= 3'd1;
            else if (CounterX < 240)  ix <= 3'd2;
            else if (CounterX < 320)  ix <= 3'd3;
            else if (CounterX < 400)  ix <= 3'd4;
            else if (CounterX < 480)  ix <= 3'd5;
            else if (CounterX < 560)  ix <= 3'd6;
            else if (CounterX < 640)  ix <= 3'd7; // Assumed active horizontal range: 0-639
            else                      ix <= 3'd0; // Default outside active area
        end
    end

    // iy calculation
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            iy <= 3'd0;
        end else if (clk_en) begin
             // Map CounterY (0-479