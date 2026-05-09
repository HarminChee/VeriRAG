`timescale 1ps/1ps
module top_nto1_ddr_diff_tx (
    input       reset,
    input       refclkin_p, refclkin_n,
    input       test_i,
    output [7:0] dataout_p, dataout_n,
    output      clkout_p, clkout_n
);
parameter integer     S = 8;
parameter integer     D = 8;
parameter integer     DS = (D*S)-1;
wire                  rst, dft_rst, dft_gclk;
reg [DS:0]            txd;
parameter [S-1:0]     TX_CLK_GEN = 8'hAA;
wire                  txioclkp, txioclkn, tx_serdesstrobe, tx_bufg_x1;

assign rst = reset;
assign dft_rst = test_i ? reset : rst;
assign dft_gclk = test_i ? refclkin_p : tx_bufg_x1;

clock_generator_ddr_s8_diff #(
    .S          (S))
inst_clkgen (
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

always @ (posedge dft_gclk or posedge dft_rst)
begin
    if (dft_rst == 1'b1) begin
        txd <= 64'h3000000000000001;
    end else begin
        txd <= {txd[63:60], txd[58:0], txd[59]};
    end
end

serdes_n_to_1_ddr_s8_diff #(
    .S          (S),
    .D          (1))
inst_clkout (
    .dataout_p      (clkout_p),
    .dataout_n      (clkout_n),
    .txioclkp       (txioclkp),
    .txioclkn       (txioclkn),
    .txserdesstrobe (tx_serdesstrobe),
    .gclk           (dft_gclk),
    .reset          (dft_rst),
    .datain         (TX_CLK_GEN)
);

serdes_n_to_1_ddr_s8_diff #(
    .S          (S),
    .D          (D))
inst_dataout (
    .dataout_p      (dataout_p),
    .dataout_n      (dataout_n),
    .txioclkp       (txioclkp),
    .txioclkn       (txioclkn),
    .txserdesstrobe (tx_serdesstrobe),
    .gclk           (dft_gclk),
    .reset          (dft_rst),
    .datain         (txd)
);

endmodule