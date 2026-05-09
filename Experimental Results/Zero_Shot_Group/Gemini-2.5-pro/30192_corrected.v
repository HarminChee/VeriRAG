`timescale 1ns / 1ps

module ps2_receiver(
    input wire clk, clr,
    input wire ps2c, ps2d,
    output wire [15:0] xkey
    );

    reg PS2Cf, PS2Df;
    reg [ 7:0] ps2c_filter, ps2d_filter;
    reg [10:0] shift1, shift2;
    reg PS2Cf_fall_event; // Flag to signal falling edge of filtered clock
    reg PS2Cf_reg; // Register to detect falling edge

    // Filtered PS2 clock and data signals
    always @ (posedge clk or posedge clr)
    begin
        if (clr == 1'b1)
        begin
            ps2c_filter <= 8'b1111_1111; // Initialize filter high
            ps2d_filter <= 8'b1111_1111; // Initialize filter high
            PS2Cf       <= 1'b1;
            PS2Df       <= 1'b1;
            PS2Cf_reg   <= 1'b1; // Initialize previous state high
        end
        else
        begin
            // Shift in new samples
            ps2c_filter <= {ps2c, ps2c_filter[7:1]};
            ps2d_filter <= {ps2d, ps2d_filter[7:1]};

            // Update filtered clock signal based on majority
            if (&ps2c_filter[3:0]) // Check if last 4 samples are high
                PS2Cf <= 1'b1;
            else if (~|ps2c_filter[3:0]) // Check if last 4 samples are low
                PS2Cf <= 1'b0;
            // else: PS2Cf retains its value (hysteresis)

            // Update filtered data signal based on majority
            if (&ps2d_filter[3:0]) // Check if last 4 samples are high
                PS2Df <= 1'b1;
            else if (~|ps2d_filter[3:0]) // Check if last 4 samples are low
                PS2Df <= 1'b0;
            // else: PS2Df retains its value (hysteresis)

            // Detect falling edge of filtered clock
            PS2Cf_reg <= PS2Cf; // Store current value for next cycle comparison
        end
    end

    // Generate a single cycle pulse on the falling edge of PS2Cf
    assign PS2Cf_fall_event = PS2Cf_reg & ~PS2Cf;

    // Shift registers clocked by system clock, enabled by PS2Cf falling edge
    always @ (posedge clk or posedge clr)
    begin
        if (clr == 1'b1)
        begin
            shift1 <= 11'b0;
            shift2 <= 11'b0; // Standard reset to 0
        end
        else if (PS2Cf_fall_event) // Shift only on the detected falling edge
        begin
            shift1 <= {PS2Df, shift1[10:1]}; // Shift data bit into shift1
            // The logic for shift2 seems to cascade from shift1's LSB.
            // Assuming this specific cascading behavior is intended.
            shift2 <= {shift1[0], shift2[10:1]};
        end
        // else: retain shift register values
    end

    // Output assignment: Extract data bits (assuming standard PS/2 frame: Start, D0-D7, Parity, Stop)
    // shift1[8:1] contains D7-D0 from the most recent frame.
    // shift2[8:1] contains D7-D0 from the second most recent frame (due to cascade).
    assign xkey = {shift2[8:1], shift1[8:1]};

endmodule