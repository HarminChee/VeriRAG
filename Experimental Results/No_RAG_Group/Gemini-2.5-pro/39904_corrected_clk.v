`timescale 1ps/1ps
module top_nto1_pll_diff_tx (
    input           reset,
    input           refclkin_p,  refclkin_n,
    // DFT Inputs for Testability
    input           scan_mode, // Test mode select
    input           scan_clk,  // Test clock input
    output  [5:0]   dataout_p, dataout_n,
    output          clkout_p,  clkout_n
);

    parameter integer     S = 7 ;
    parameter integer     D = 6 ;
    parameter integer     DS = (D*S)-1 ;

    wire        rst ;
    reg [DS:0]  txd ;
    parameter [S-1:0] TX_CLK_GEN   = 7'b1100001 ;

    // Internal wires
    wire        tx_bufpll_clk_xn;
    wire        tx_serdesstrobe;
    wire        tx_bufg_x1; // Original clock from PLL
    wire        tx_bufpll_lckd;
    wire        ff_clk;     // Multiplexed clock for FFs and SERDES

    assign rst = reset ;

    // DFT Clock Mux: Select scan_clk in test mode, functional clock otherwise
    assign ff_clk = scan_mode ? scan_clk : tx_bufg_x1;

    clock_generator_pll_s8_diff #(
        .S              (S),
        .PLLX           (7),
        .PLLD           (1),
        .CLKIN_PERIOD   (7.000)
    ) inst_clkgen (
        .reset          (rst),
        .clkin_p        (refclkin_p),
        .clkin_n        (refclkin_n),
        .ioclk          (tx_bufpll_clk_xn),
        .serdesstrobe   (tx_serdesstrobe),
        .gclk           (tx_bufg_x1), // Output from PLL
        .bufpll_lckd    (tx_bufpll_lckd)
    );

    // Shift register logic clocked by the multiplexed clock ff_clk
    always @ (posedge ff_clk or posedge rst)
    begin
        if (rst == 1'b1) begin
            // Use original reset value
            txd <= 42'h00000000001 ;
        end
        else begin
            // Use original shift logic (rotate left)
            txd <= {txd[DS-1:0], txd[DS]} ;
        end
    end

    serdes_n_to_1_s8_diff #(
        .S              (S),
        .D              (1)
    ) inst_clkout (
        .dataout_p      (clkout_p),
        .dataout_n      (clkout_n),
        .txioclk        (tx_bufpll_clk_xn), // This clock might also need muxing depending on SERDES internal structure, but gclk is the primary concern for core logic FFs
        .txserdesstrobe (tx_serdesstrobe),
        .gclk           (ff_clk),           // Use multiplexed clock
        .reset          (rst),
        .datain         (TX_CLK_GEN)
    );

    serdes_n_to_1_s8_diff #(
        .S              (S),
        .D              (D)
    ) inst_dataout (
        .dataout_p      (dataout_p),
        .dataout_n      (dataout_n),
        .txioclk        (tx_bufpll_clk_xn), // This clock might also need muxing depending on SERDES internal structure
        .txserdesstrobe (tx_serdesstrobe),
        .gclk           (ff_clk),           // Use multiplexed clock
        .reset          (rst),
        .datain         (txd)
    );

endmodule