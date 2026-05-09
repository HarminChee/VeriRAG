`timescale 1ns / 1ps
module ps2_receiver_corrected_ffc (
    input wire clk, clr,
    input wire ps2c, ps2d,
    output wire [15:0] xkey
);

    reg PS2Cf, PS2Df;
    reg PS2Cf_dly; // Added register to detect falling edge
    reg [ 7:0] ps2c_filter, ps2d_filter;
    reg [10:0] shift1, shift2;

    assign xkey = {shift2[8:1], shift1[8:1]};

    // Detect falling edge of PS2Cf synchronously with clk
    wire ps2cf_negedge_event = PS2Cf_dly & ~PS2Cf;

    // First block: Filter logic and PS2Cf/PS2Df generation, clocked by primary clk
    always @ (posedge clk or posedge clr)
    begin
        if (clr == 1'b1)
        begin
            ps2c_filter <= 8'b0;
            ps2d_filter <= 8'b0;
            PS2Cf       <= 1'b1;
            PS2Df       <= 1'b1;
            PS2Cf_dly   <= 1'b1; // Reset delay register
        end
        else
        begin
            ps2c_filter <= {ps2c, ps2c_filter[7:1]};
            ps2d_filter <= {ps2d, ps2d_filter[7:1]};

            // Update PS2Cf based on filter
            if (ps2c_filter == 8'b1111_1111)
                PS2Cf <= 1'b1;
            else if (ps2c_filter == 8'b0000_0000)
                PS2Cf <= 1'b0;
            // No else: PS2Cf retains its value if neither condition is met

            // Update PS2Df based on filter
            if (ps2d_filter == 8'b1111_1111)
                PS2Df <= 1'b1;
            else if (ps2d_filter == 8'b0000_0000)
                PS2Df <= 1'b0;
            // No else: PS2Df retains its value if neither condition is met

            PS2Cf_dly <= PS2Cf; // Update delay register with current PS2Cf value
        end
    end

    // Second block: Shift registers, now clocked by primary clk, enabled by PS2Cf falling edge detection
    always @ (posedge clk or posedge clr)
    begin
        if (clr == 1'b1)
        begin
            shift1 <= 11'b0;
            // Initialize shift2 to 1 as in the original code (assuming 11'b...1)
            shift2 <= 11'b00000000001;
        end
        // Update shift registers only when the falling edge of PS2Cf is detected
        else if (ps2cf_negedge_event)
        begin
            shift1 <= {PS2Df, shift1[10:1]};
            // shift2 uses the value of shift1[0] from *before* this clock edge's update
            // Non-blocking assignment ensures this behavior
            shift2 <= {shift1[0], shift2[10:1]};
        end
        // No else: shift1 and shift2 retain their values if reset is not active
        // and the falling edge event did not occur
    end

endmodule