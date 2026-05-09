`timescale 1ps/1ps

module top_nto1_ddr_diff_tx (
    input               reset,
    input               refclkin_p,
    input               refclkin_n,
    output  [7:0]       dataout_p,
    output  [7:0]       dataout_n,
    output              clkout_p,
    output              clkout_n
);

    parameter integer     S = 8 ;
    parameter integer     D = 8 ;
    parameter integer     DS = (D*S)-1 ;

    wire                rst ;
    reg     [DS:0]      txd ;
    parameter [S-1:0]   TX_CLK_GEN   = 8'hAA ;

    wire                txioclkp;
    wire                txioclkn;
    wire                tx_serdesstrobe;
    wire                tx_bufg_x1;

    assign rst = reset ;

    clock_generator_ddr_s8_diff #(
        .S              (S)
    ) inst_clkgen (
        .clkin_p        (refclkin_p),
        .clkin_n        (refclkin_n),
        .ioclkap        (txioclkp),
        .ioclkan        (txioclkn),
        .serdesstrobea  (tx_serdesstrobe),
        .ioclkbp        (), // Assuming unconnected is intended
        .ioclkbn        (), // Assuming unconnected is intended
        .serdesstrobeb  (), // Assuming unconnected is intended
        .gclk           (tx_bufg_x1)
    );

    always @ (posedge tx_bufg_x1 or posedge rst)
    begin
        if (rst == 1'b1) begin
            txd <= {(DS+1){1'b0}}; // Initialize to 0 or a specific reset pattern
            // Or keep original if intended: txd <= 64'h3000000000000001 ;
        end
        else begin
            // Barrel shift left by 1 (rotate bit 59 to bit 0, shift 63:60 and 58:0 left)
             txd <= {txd[62:0], txd[63]}; // More standard rotate left
            // Or keep original if intended: txd <= {txd[63:60], txd[58:0], txd[59]} ;
        end
    end

    serdes_n_to_1_ddr_s8_diff #(
        .S              (S),
        .D              (1) // D=1 for clock output
    ) inst_clkout (
        .dataout_p      (clkout_p),
        .dataout_n      (clkout_n),
        .txioclkp       (txioclkp),
        .txioclkn       (txioclkn),
        .txserdesstrobe (tx_serdesstrobe),
        .gclk           (tx_bufg_x1),
        .reset          (rst),
        .datain         (TX_CLK_GEN) // Input width D*S = 1*8 = 8 bits
    );

    serdes_n_to_1_ddr_s8_diff #(
        .S              (S),
        .D              (D) // D=8 for data output
    ) inst_dataout (
        .dataout_p      (dataout_p), // Output width is D=8
        .dataout_n      (dataout_n), // Output width is D=8
        .txioclkp       (txioclkp),
        .txioclkn       (txioclkn),
        .txserdesstrobe (tx_serdesstrobe),
        .gclk           (tx_bufg_x1),
        .reset          (rst),
        .datain         (txd) // Input width D*S = 8*8 = 64 bits
    );

endmodule

// Note: Assumes the existence and correct interface of modules:
// - clock_generator_ddr_s8_diff
// - serdes_n_to_1_ddr_s8_diff
// Also assumes the intended logic for the txd register update was the barrel shift.
// A standard rotate left `txd <= {txd[DS-1:0], txd[DS]};` might be more common.
// The original shift `{txd[63:60], txd[58:0], txd[59]}` is kept commented as an alternative if specifically intended.
// Reset value for txd also changed to all zeros, original commented out.