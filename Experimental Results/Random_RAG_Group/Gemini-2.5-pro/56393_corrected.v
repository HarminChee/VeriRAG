module hi_read_tx(
    input pck0, // Assuming pck0 is the primary reset, rename to reset_n for clarity? Using added reset_n instead.
    input ck_1356meg,
    input ck_1356megb,
    input reset_n, // Added primary asynchronous reset
    input test_i,  // Added test mode signal

    output pwr_lo,
    output pwr_hi,
    output pwr_oe1,
    output pwr_oe2,
    output pwr_oe3,
    output pwr_oe4,

    input [7:0] adc_d,
    output adc_clk,

    input ssp_dout,
    output ssp_frame,
    output ssp_din,
    output ssp_clk,

    input cross_hi, cross_lo, // Unused inputs? Retained.
    output dbg,
    input shallow_modulation
);

    // Fixed assignments
    assign pwr_lo = 1'b0;
    assign pwr_oe2 = 1'b0;
    assign adc_clk = ck_1356meg; // OK: Primary clock assigned to output

    // Internal registers
    reg pwr_hi_enable; // Changed pwr_hi from reg to wire driven by registered enable
    reg pwr_oe1_reg;
    reg pwr_oe3_reg;
    reg pwr_oe4_reg;
    reg [6:0] hi_div_by_128;
    reg [2:0] hi_byte_div;
    reg after_hysteresis;

    // Internal wires for next state logic
    wire pwr_hi_enable_next;
    wire pwr_oe1_next;
    wire pwr_oe3_next;
    wire pwr_oe4_next;
    wire hi_byte_div_en;
    wire after_hysteresis_next;
    wire dft_ssp_clk; // DFT-friendly clock source for ssp_clk output

    // DFT Fix: Clock Generation (ssp_clk)
    // ssp_clk is derived from FF output hi_div_by_128[6]. Use primary clock in test mode.
    assign dft_ssp_clk = hi_div_by_128[6];
    assign ssp_clk = test_i ? ck_1356meg : dft_ssp_clk;

    // DFT Fix: Clocking hi_byte_div
    // Original used negedge ssp_clk (derived clock). Clock with primary clock ck_1356meg and use enable.
    // Enable when hi_div_by_128 goes from 7'b011_1111 to 7'b100_0000 (which causes negedge on bit 6)
    assign hi_byte_div_en = (hi_div_by_128 == 7'b011_1111);

    always @(posedge ck_1356meg or negedge reset_n) begin
        if (!reset_n) begin
            hi_div_by_128 <= 7'b0;
        end else begin
            hi_div_by_128 <= hi_div_by_128 + 1;
        end
    end

    always @(posedge ck_1356meg or negedge reset_n) begin
        if (!reset_n) begin
            hi_byte_div <= 3'b0;
        end else if (hi_byte_div_en) begin // Use enable instead of derived clock
            hi_byte_div <= hi_byte_div + 1;
        end
    end

    assign ssp_frame = (hi_byte_div == 3'b000); // OK: Combinational logic based on FF state

    // DFT Fix: Hysteresis logic FF
    // Original used negedge adc_clk. Use posedge primary clock ck_1356meg and reset.
    always @(posedge ck_1356meg or negedge reset_n) begin
        if (!reset_n) begin
            after_hysteresis <= 1'b0;
        end else begin
            // Calculate next state based on current state and input
            if (&adc_d[7:0]) begin
                after_hysteresis <= 1'b1;
            end else if (~(|adc_d[7:0])) begin
                after_hysteresis <= 1'b0;
            end else begin
                after_hysteresis <= after_hysteresis; // Hold value
            end
        end
    end

    assign ssp_din = after_hysteresis; // OK: Output driven by FF
    assign dbg = ssp_din;            // OK: Output driven by FF

    // DFT Fix: Output registers (pwr_hi, pwr_oe*)
    // Original used combinational always block inferring latches and using clock as data.
    // Implement as FFs clocked by primary clock ck_1356meg with async reset reset_n.

    // Combinational logic for next state of output registers
    assign pwr_oe1_next = 1'b0;
    assign pwr_oe3_next = 1'b0;
    assign pwr_oe4_next = shallow_modulation ? ~ssp_dout : 1'b0;
    assign pwr_hi_enable_next = shallow_modulation ? 1'b1 : ssp_dout;

    // Output Register Flip-Flops
    always @(posedge ck_1356meg or negedge reset_n) begin
        if (!reset_n) begin
            pwr_oe1_reg <= 1'b0;
            pwr_oe3_reg <= 1'b0;
            pwr_oe4_reg <= 1'b0;
            pwr_hi_enable <= 1'b0;
        end else begin
            pwr_oe1_reg <= pwr_oe1_next;
            pwr_oe3_reg <= pwr_oe3_next;
            pwr_oe4_reg <= pwr_oe4_next;
            pwr_hi_enable <= pwr_hi_enable_next;
        end
    end

    // Assign registered values to outputs
    assign pwr_oe1 = pwr_oe1_reg;
    assign pwr_oe3 = pwr_oe3_reg;
    assign pwr_oe4 = pwr_oe4_reg;

    // DFT Fix: Avoid clock as data for pwr_hi output generation
    // Generate pwr_hi combinationally using the registered enable signal.
    // This still creates a gated clock output, which might need further handling depending on context,
    // but avoids clocking FFs with gated clocks or using clocks in FF data paths directly.
    assign pwr_hi = pwr_hi_enable ? ck_1356megb : 1'b0;

endmodule