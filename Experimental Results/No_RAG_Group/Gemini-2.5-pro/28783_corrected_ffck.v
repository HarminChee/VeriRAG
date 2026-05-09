module hi_simulate_corrected_ffc (
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk_out, // Renamed ssp_clk to ssp_clk_out for clarity if needed externally
    cross_hi, cross_lo,
    dbg,
    mod_type
);
    input pck0, ck_1356meg, ck_1356megb;
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame;
    output reg ssp_din; // Made reg as it's driven by always block
    output ssp_clk_out; // Output the generated clock value if needed externally
    input cross_hi, cross_lo;
    output dbg;
    input [2:0] mod_type;

    assign pwr_hi = 1'b0;
    assign pwr_lo = 1'b0;

    reg after_hysteresis;
    assign adc_clk = ck_1356meg; // Clock derived from primary input

    // Hysteresis logic - clocked by primary-derived clock
    always @(negedge adc_clk)
    begin
        if(& adc_d[7:5]) after_hysteresis <= 1'b1;
        else if(~(| adc_d[7:5])) after_hysteresis <= 1'b0;
        // else: keep previous value (implicit latch behavior intended here)
    end

    reg [6:0] ssp_clk_divider;
    reg [6:0] ssp_clk_divider_q; // Register to hold previous value for edge detection

    // SSP Clock Divider logic - clocked by primary-derived clock
    always @(posedge adc_clk) begin
        ssp_clk_divider <= (ssp_clk_divider + 1);
        ssp_clk_divider_q <= ssp_clk_divider; // Capture previous value
    end

    // Generate clock enable signals based on the derived clock logic
    wire ssp_clk_posedge_enable = ssp_clk_divider[4] & ~ssp_clk_divider_q[4];
    wire ssp_clk_negedge_enable = ~ssp_clk_divider[4] & ssp_clk_divider_q[4];

    // Assign the generated clock value to an output if needed, but don't use it as an internal clock
    assign ssp_clk_out = ssp_clk_divider[4];

    reg [2:0] ssp_frame_divider_to_arm;
    // SSP Frame Divider To ARM - clocked by primary-derived clock with enable
    always @(posedge adc_clk) begin
        if (ssp_clk_posedge_enable) begin
            ssp_frame_divider_to_arm <= (ssp_frame_divider_to_arm + 1);
        end
    end

    reg [2:0] ssp_frame_divider_from_arm;
    // SSP Frame Divider From ARM - clocked by primary-derived clock with enable
    always @(posedge adc_clk) begin // Use posedge adc_clk for consistency
        if (ssp_clk_negedge_enable) begin
            ssp_frame_divider_from_arm <= (ssp_frame_divider_from_arm + 1);
        end
    end

    reg ssp_frame_reg; // Use a register for the output driven by combinational logic
    // Combinational logic for SSP Frame
    always @(*) begin // Use @(*) for combinational logic sensitivity
        if(mod_type == 3'b000)
            ssp_frame_reg = (ssp_frame_divider_to_arm == 3'b000);
        else
            ssp_frame_reg = (ssp_frame_divider_from_arm == 3'b000);
    end
    assign ssp_frame = ssp_frame_reg;

    // SSP Din logic - clocked by primary-derived clock with enable
    always @(posedge adc_clk) begin
        if (ssp_clk_posedge_enable) begin
            ssp_din <= after_hysteresis;
        end
    end

    reg modulating_carrier;
    // Modulating Carrier logic - clocked by primary-derived clock with enable
    always @(posedge adc_clk) begin
        // Update only when the derived clock enable is active
        if (ssp_clk_posedge_enable) begin
             case (mod_type) // Use case statement for clarity
                3'b000: modulating_carrier <= 1'b0;
                3'b001: modulating_carrier <= ssp_dout ^ ssp_clk_divider[3];
                3'b010: modulating_carrier <= ssp_dout & ssp_clk_divider[5];
                3'b100: modulating_carrier <= ssp_dout & ssp_clk_divider[4]; // Use divider bit directly
                default: modulating_carrier <= 1'b0;
            endcase
        end
        // else: keep previous value (implicit)
    end

    assign pwr_oe2 = modulating_carrier;
    assign pwr_oe1 = modulating_carrier;
    assign pwr_oe4 = modulating_carrier;
    assign pwr_oe3 = 1'b0;

    assign dbg = after_hysteresis;

endmodule