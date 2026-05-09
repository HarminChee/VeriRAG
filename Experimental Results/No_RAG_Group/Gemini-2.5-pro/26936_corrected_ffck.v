`timescale 1ns/1ns
module ym2i2s_corrected_ffc (
    input nRESET,
    input CLK_I2S, // Primary clock input
    input [5:0] ANA,
    input SH1, SH2, OP0, PHI_M, // Unused inputs in the original logic shown
    output I2S_MCLK,
    output I2S_BICK,
    output I2S_SDTI,
    output I2S_LRCK
);

    // Internal signals
    wire [23:0] I2S_SAMPLE;
    reg  [23:0] I2S_SR;
    reg  [3:0]  SR_CNT;
    reg  [7:0]  CLKDIV;
    reg         bick_prev; // Register to store previous state of CLKDIV[4]
    wire        bick_negedge_enable; // Enable signal for logic previously clocked by I2S_BICK

    // Assignments
    assign I2S_SAMPLE = {18'b0, ANA}; // Pad ANA data
    assign I2S_MCLK = CLK_I2S;        // MCLK is the primary clock
    assign I2S_LRCK = CLKDIV[7];      // LRCK derived from CLKDIV
    assign I2S_BICK = CLKDIV[4];      // BICK derived from CLKDIV
    assign I2S_SDTI = I2S_SR[23];     // Serial data out is MSB of shift register

    // Clock Divider Logic - Clocked by primary clock CLK_I2S
    always @(posedge CLK_I2S or negedge nRESET) begin
        if (!nRESET) begin
            CLKDIV <= 8'b0;
        end else begin
            CLKDIV <= CLKDIV + 1'b1;
        end
    end

    // Generate enable signal based on the falling edge of the derived BICK signal
    // bick_prev stores the value of CLKDIV[4] from the previous CLK_I2S cycle
    always @(posedge CLK_I2S or negedge nRESET) begin
        if (!nRESET) begin
            bick_prev <= 1'b0; // Reset value for previous state
        end else begin
            bick_prev <= CLKDIV[4]; // Capture current CLKDIV[4] for next cycle comparison
        end
    end

    // Enable signal is high for one CLK_I2S cycle when CLKDIV[4] transitions from 1 to 0
    assign bick_negedge_enable = bick_prev & ~CLKDIV[4];

    // I2S Shift Register and Counter Logic - Now clocked by primary clock CLK_I2S
    // Logic is enabled by bick_negedge_enable
    always @(posedge CLK_I2S or negedge nRESET) begin
        if (!nRESET) begin
            SR_CNT <= 4'b0;
            I2S_SR <= 24'b0;
        end else if (bick_negedge_enable) begin // Only update when enable is active
            if (SR_CNT == 4'd0) begin // Check counter value before update
                I2S_SR <= I2S_SAMPLE;   // Load new sample when counter is 0
            end else begin
                I2S_SR <= {I2S_SR[22:0], 1'b0}; // Shift data otherwise
            end
            SR_CNT <= SR_CNT + 1'b1; // Increment counter after load/shift operation
                                      // Note: Original code didn't increment when SR_CNT was 0.
                                      // This version assumes increment should always happen on enable.
                                      // Counter will wrap around. Reset mechanism based on LRCK etc. might be needed for full protocol.
        end
    end

endmodule