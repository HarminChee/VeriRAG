`timescale 1ps/1ps
`timescale 1ps/1ps
module top_nto1_ddr_diff_tx (
    input           test_i,
    input           test_clk,
    input           reset,
    input           refclkin_p, 
    input           refclkin_n,
    output  [7:0]   dataout_p, 
    output  [7:0]   dataout_n,
    output          clkout_p,  
    output          clkout_n
);
parameter integer S  = 8; 
parameter integer D  = 8;
parameter integer DS = (D*S)-1;

wire        rst;
wire        txioclkp;
wire        txioclkn;
wire        tx_serdesstrobe;
wire        tx_bufg_x1;
wire        dft_tx_bufg_x1;
reg  [DS:0] txd;

parameter [S-1:0] TX_CLK_GEN = 8'hAA;

assign rst = reset;
assign dft_tx_bufg_x1 = test_i ? test_clk : tx_bufg_x1;

clock_generator_ddr_s8_diff #(
    .S(S)
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

always @ (posedge dft_tx_bufg_x1 or posedge rst) begin
    if (rst == 1'b1) begin
        txd <= 64'h3000000000000001;
    end else begin
        txd <= {txd[63:60], txd[58:0], txd[59]};
    end
end

serdes_n_to_1_ddr_s8_diff #(
    .S(S),
    .D(1)
) inst_clkout (
    .dataout_p      (clkout_p),
    .dataout_n      (clkout_n),
    .txioclkp       (txioclkp),
    .txioclkn       (txioclkn),
    .txserdesstrobe (tx_serdesstrobe),
    .gclk           (dft_tx_bufg_x1),
    .reset          (rst),
    .datain         (TX_CLK_GEN)
);

serdes_n_to_1_ddr_s8_diff #(
    .S(S),
    .D(D)
) inst_dataout (
    .dataout_p      (dataout_p),
    .dataout_n      (dataout_n),
    .txioclkp       (txioclkp),
    .txioclkn       (txioclkn),
    .txserdesstrobe (tx_serdesstrobe),
    .gclk           (dft_tx_bufg_x1),
    .reset          (rst),
    .datain         (txd)
);

endmodule