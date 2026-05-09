`timescale 1ps/1ps
module top_nto1_ddr_diff_tx_corrected (
    input       reset,
    input       refclkin_p, refclkin_n,
    // DFT inputs
    input       test_mode, // Scan enable or test mode signal
    input       test_clk,  // Test clock input

    output [7:0] dataout_p, dataout_n,
    output      clkout_p,  clkout_n
);

    parameter integer S = 8;
    parameter integer D = 8;
    parameter integer DS = (D * S) - 1;

    wire        rst;
    reg  [DS:0] txd;
    parameter [S-1:0] TX_CLK_GEN = 8'hAA;

    wire        txioclkp;
    wire        txioclkn;
    wire        tx_serdesstrobe;
    wire        tx_bufg_x1; // Internally generated clock

    // DFT Clock Selection Logic
    wire        scan_clk; // Clock used for the txd register
    assign      scan_clk = test_mode ? test_clk : tx_bufg_x1;

    assign rst = reset;

    // Instantiate the clock generator
    // This internally generated clock tx_bufg_x1 is problematic for DFT if used directly by flops
    clock_generator_ddr_s8_diff #(
        .S (S)
    ) inst_clkgen (
        .clkin_p        (refclkin_p),
        .clkin_n        (refclkin_n),
        .ioclkap        (txioclkp),
        .ioclkan        (txioclkn),
        .serdesstrobea  (tx_serdesstrobe),
        .ioclkbp        (),
        .ioclkbn        (),
        .serdesstrobeb  (),
        .gclk           (tx_bufg_x1)
    );

    // Modified always block using the scan_clk
    // This flop is now controllable by test_clk during test_mode
    always @(posedge scan_clk or posedge rst)
    begin
        if (rst == 1'b1) begin
            txd <= 64'h3000000000000001;
        end
        else begin
            // Keep original functional logic
            txd <= {txd[63:60], txd[58:0], txd[59]};
        end
    end

    // Instantiate SERDES for clkout
    // Note: For full DFT compliance, this instance might also need modification
    // if its internal flops are clocked by tx_bufg_x1 without a test clock mux.
    // However, the fix here focuses on the 'txd' register as per the CLKNPI description provided.
    serdes_n_to_1_ddr_s8_diff #(
        .S (S),
        .D (1)
    ) inst_clkout (
        .dataout_p      (clkout_p),
        .dataout_n      (clkout_n),
        .txioclkp       (txioclkp),
        .txioclkn       (txioclkn),
        .txserdesstrobe (tx_serdesstrobe),
        .gclk           (tx_bufg_x1), // This clock connection might need DFT modification internally
        .reset          (rst),
        .datain         (TX_CLK_GEN)
    );

    // Instantiate SERDES for dataout
    // Note: Similar to inst_clkout, this instance might need internal DFT modifications.
    serdes_n_to_1_ddr_s8_diff #(
        .S (S),
        .D (D)
    ) inst_dataout (
        .dataout_p      (dataout_p),
        .dataout_n      (dataout_n),
        .txioclkp       (txioclkp),
        .txioclkn       (txioclkn),
        .txserdesstrobe (tx_serdesstrobe),
        .gclk           (tx_bufg_x1), // This clock connection might need DFT modification internally
        .reset          (rst),
        .datain         (txd)
    );

endmodule

// Note: The definitions for clock_generator_ddr_s8_diff and serdes_n_to_1_ddr_s8_diff
// modules are assumed to exist elsewhere and are not provided or modified here.
// Full DFT compliance might require modifications within those submodules as well,
// particularly ensuring their internal flip-flops can be clocked by test_clk during test_mode.