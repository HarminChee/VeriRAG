`timescale 1ps/1ps
module top_nto1_ddr_se_rx (
    input       reset,
    input       test_i,
    input   [7:0]   datain,
    input       clkin1, clkin2,
    output  [63:0]  dummy_out
);
parameter integer     S = 8;
parameter integer     D = 8;
parameter integer     DS = (D*S)-1;
wire            rst;
wire        [DS:0]  rxd;
reg     [DS:0]  rxr;
reg         state;
reg         bslip;
reg     [3:0]   count;
wire            dft_rst;
wire            dft_rx_bufg_x1;
assign rst = reset;
assign dummy_out = rxr;
assign dft_rst = test_i ? reset : rst;
assign dft_rx_bufg_x1 = test_i ? clkin1 : rx_bufg_x1;
serdes_1_to_n_clk_ddr_s8_se #(
    .S          (S)
)
inst_clkin (
    .clkin1         (clkin1),
    .clkin2         (clkin2),
    .rxioclkp       (rxioclkp),
    .rxioclkn       (rxioclkn),
    .rx_serdesstrobe    (rx_serdesstrobe),
    .rx_bufg_x1     (rx_bufg_x1)
);
serdes_1_to_n_data_ddr_s8_se #(
    .S          (S),
    .D          (D),
    .USE_PD         ("TRUE")
)
inst_datain (
    .use_phase_detector (1'b1),
    .datain         (datain),
    .rxioclkp       (rxioclkp),
    .rxioclkn       (rxioclkn),
    .rxserdesstrobe     (rx_serdesstrobe),
    .gclk           (rx_bufg_x1),
    .bitslip        (bslip),
    .reset          (rst),
    .data_out       (rxd),
    .debug_in       (2'b00),
    .debug          ()
);
always @ (posedge dft_rx_bufg_x1 or posedge dft_rst)
begin
    if (dft_rst == 1'b1) begin
        state <= 0;
        bslip <= 1'b0;
        count <= 4'b0000;
    end
    else begin
        if (state == 0) begin
            if (rxd[63:60] != 4'h3) begin
                bslip <= 1'b1;
                state <= 1;
                count <= 4'b0000;
            end
        end
        else if (state == 1) begin
            bslip <= 1'b0;
            count <= count + 4'b0001;
            if (count == 4'b1111) begin
                state <= 0;
            end
        end
    end
end
always @ (posedge dft_rx_bufg_x1)
begin
    rxr <= rxd;
end
endmodule