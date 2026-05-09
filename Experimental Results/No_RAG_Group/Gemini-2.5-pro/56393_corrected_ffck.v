// 1_corrected_ffc.v
module hi_read_tx(
    pck0, ck_1356meg, ck_1356megb, // Primary Clocks
    test_mode, test_clk, test_se, // DFT Ports
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk_out, // Renamed ssp_clk to ssp_clk_out
    cross_hi, cross_lo,
    dbg,
    shallow_modulation
);
    input pck0, ck_1356meg, ck_1356megb;
    input test_mode; // DFT control signal
    input test_clk;  // DFT clock
    input test_se;   // DFT scan enable

    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk_out; // Renamed ssp_clk to ssp_clk_out
    input cross_hi, cross_lo;
    output dbg;
    input shallow_modulation;

    // Internal signals
    wire clk; // Muxed clock for functional/test mode

    // Clock Mux for DFT
    // Selects functional clock (ck_1356meg) or test clock (test_clk)
    assign clk = test_mode ? test_clk : ck_1356meg;
    // Use negedge based on original design, create negedge clk mux
    wire nclk;
    assign nclk = test_mode ? test_clk : ck_1356megb; // Assuming ck_1356megb is negedge of ck_1356meg or use dedicated negedge test clock if available

assign pwr_lo = 1'b0;
assign pwr_oe2 = 1'b0;
reg pwr_hi;
reg pwr_oe1;
reg pwr_oe3;
reg pwr_oe4;

// This block seemed combinational but sensitive to a clock edge.
// Assuming it should be synchronous logic clocked by ck_1356meg.
// If ck_1356megb was intended as clock, use 'nclk'. Here using 'clk' (posedge).
always @(posedge clk) // Changed to use muxed clock 'clk'
begin
    if(shallow_modulation)
    begin
        // Assigning clock signal directly to data is unusual, kept as per original logic intent
        pwr_hi <= ck_1356megb;
        pwr_oe1 <= 1'b0;
        pwr_oe3 <= 1'b0;
        pwr_oe4 <= ~ssp_dout;
    end
    else
    begin
        // Assigning clock signal directly to data is unusual, kept as per original logic intent
        pwr_hi <= ck_1356megb & ssp_dout;
        pwr_oe1 <= 1'b0;
        pwr_oe3 <= 1'b0;
        pwr_oe4 <= 1'b0;
    end
end

reg [6:0] hi_div_by_128;
always @(posedge clk) // Changed clock to muxed clock 'clk'
    hi_div_by_128 <= hi_div_by_128 + 1;

// ssp_clk was generated from hi_div_by_128[6] and used as clock - FFCKNP violation
// Generate an enable signal instead for the logic previously clocked by ssp_clk
wire ssp_clk_internal = hi_div_by_128[6];
assign ssp_clk_out = ssp_clk_internal; // Output the generated signal if needed externally

reg ssp_clk_internal_prev;
always @(posedge clk) begin // Use primary muxed clock 'clk'
    ssp_clk_internal_prev <= ssp_clk_internal;
end

// Enable signal captures the negedge of the internal ssp_clk
wire hi_byte_div_enable = ssp_clk_internal_prev & ~ssp_clk_internal;

reg [2:0] hi_byte_div;
// Clock hi_byte_div with the primary muxed clock 'clk' and use the enable signal
always @(posedge clk) // Changed clock to muxed clock 'clk'
begin
    if (hi_byte_div_enable) begin
        hi_byte_div <= hi_byte_div + 1;
    end
end

assign ssp_frame = (hi_byte_div == 3'b000);

// Assign primary clock to adc_clk output
// If adc_clk needs to be controllable/observable for test, it might need muxing too.
// Assuming ck_1356meg is acceptable here based on original code.
assign adc_clk = ck_1356meg;

// This FF uses adc_clk (which is ck_1356meg) negedge.
// Need to use a muxed negedge clock 'nclk' for DFT compatibility.
reg after_hysteresis;
always @(negedge nclk) // Changed clock to muxed negedge clock 'nclk'
begin
    if(& adc_d[7:0]) after_hysteresis <= 1'b1;
    else if(~(| adc_d[7:0])) after_hysteresis <= 1'b0;
    // Consider adding reset logic if needed
end

assign ssp_din = after_hysteresis;
assign dbg = ssp_din;

endmodule