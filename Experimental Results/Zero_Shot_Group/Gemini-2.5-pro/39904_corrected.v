`timescale 1ps/1ps

module top_nto1_pll_diff_tx (
    input               reset,
    input               refclkin_p, refclkin_n,
    output  [5:0]       dataout_p, dataout_n,
    output              clkout_p,  clkout_n
);

    parameter integer     S = 7 ;
    parameter integer     D = 6 ;
    parameter integer     DS = (D*S)-1 ;

    wire                rst ;
    reg     [DS:0]      txd ;
    parameter [S-1:0]   TX_CLK_GEN   = 7'b1100001 ;

    // Internal wires connecting modules
    wire                tx_bufpll_clk_xn;
    wire                tx_serdesstrobe;
    wire                tx_bufg_x1;
    wire                tx_bufpll_lckd;

    assign rst = reset ;

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
        .gclk           (tx_bufg_x1),
        .bufpll_lckd    (tx_bufpll_lckd)
    );

    always @ (posedge tx_bufg_x1 or posedge rst)
    begin
        if (rst == 1'b1) begin
            txd <= {DS+1{1'b0}}; // Initialize to all zeros or a specific pattern
            // Original code had: txd <= 42'h00000000001 ; - keeping this if it was intentional
            // txd <= 42'h00000000001 ;
        end
        else begin
            txd <= {txd[DS-1:0], txd[DS]} ; // Corrected rotation logic for [DS:0]
        end
    end

    serdes_n_to_1_s8_diff #(
        .S              (S),
        .D              (1)
    ) inst_clkout (
        .dataout_p      (clkout_p),
        .dataout_n      (clkout_n),
        .txioclk        (tx_bufpll_clk_xn),
        .txserdesstrobe (tx_serdesstrobe),
        .gclk           (tx_bufg_x1),
        .reset          (rst),
        .datain         (TX_CLK_GEN)
    );

    serdes_n_to_1_s8_diff #(
        .S              (S),
        .D              (D)
    ) inst_dataout (
        .dataout_p      (dataout_p),
        .dataout_n      (dataout_n),
        .txioclk        (tx_bufpll_clk_xn),
        .txserdesstrobe (tx_serdesstrobe),
        .gclk           (tx_bufg_x1),
        .reset          (rst),
        .datain         (txd)
    );

endmodule