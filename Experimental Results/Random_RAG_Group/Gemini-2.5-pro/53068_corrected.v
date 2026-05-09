`default_nettype none
`timescale 1 ns / 1 ps

module RedundantFF(
    input wire clear, // Note: This input remains unused in the original logic.
    input wire test_clk, // Added test clock input
    input wire test_mode, // Added test mode input
    input wire reset_n, // Added reset input for DFT
    output wire underflow
);
    wire clk_108hz;
    GP_LFOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OUT_DIV(16)
    ) lfosc (
        .PWRDN(1'b0),
        .CLKOUT(clk_108hz)
    );

    wire mux_clk;
    // Select functional clock or test clock based on test_mode
    assign mux_clk = test_mode ? test_clk : clk_108hz;

    reg[7:0] count; // Initial value removed, rely on reset
    always @(posedge mux_clk or negedge reset_n) begin
        if (!reset_n) begin
            count <= 8'd15; // Use synchronous reset
        end else begin
            // Keep original counter logic, but driven by mux_clk
            if (count == 0) begin
                count <= 8'd15;
            end else begin
                count <= count - 1'h1;
            end
        end
    end

    assign underflow = (count == 0);

endmodule
`default_nettype wire // Resetting default_nettype if needed downstream