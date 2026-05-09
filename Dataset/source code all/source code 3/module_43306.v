`resetall
`timescale 1ns / 1ps
`default_nettype none
`resetall
`resetall
`timescale 1ns / 1ps
`default_nettype none
module eth_mac_1g_gmii #
(
    parameter TARGET = "GENERIC",
    parameter IODDR_STYLE = "IODDR2",
    parameter CLOCK_INPUT_STYLE = "BUFIO2",
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        gtx_clk,
    input  wire        gtx_rst,
    output wire        rx_clk,
    output wire        rx_rst,
    output wire        tx_clk,
    output wire        tx_rst,
    input  wire [7:0]  tx_axis_tdata,
    input  wire        tx_axis_tvalid,
    output wire        tx_axis_tready,
    input  wire        tx_axis_tlast,
    input  wire        tx_axis_tuser,
    output wire [7:0]  rx_axis_tdata,
    output wire        rx_axis_tvalid,
    output wire        rx_axis_tlast,
    output wire        rx_axis_tuser,
    input  wire        gmii_rx_clk,
    input  wire [7:0]  gmii_rxd,
    input  wire        gmii_rx_dv,
    input  wire        gmii_rx_er,
    input  wire        mii_tx_clk,
    output wire        gmii_tx_clk,
    output wire [7:0]  gmii_txd,
    output wire        gmii_tx_en,
    output wire        gmii_tx_er,
    output wire        tx_error_underflow,
    output wire        rx_error_bad_frame,
    output wire        rx_error_bad_fcs,
    output wire [1:0]  speed,
    input  wire [7:0]  ifg_delay
);
wire [7:0]  mac_gmii_rxd;
wire        mac_gmii_rx_dv;
wire        mac_gmii_rx_er;
wire [7:0]  mac_gmii_txd;
wire        mac_gmii_tx_en;
wire        mac_gmii_tx_er;
reg [1:0] speed_reg = 2'b10;
reg mii_select_reg = 1'b0;
reg [1:0] tx_mii_select_sync = 2'd0;
always @(posedge tx_clk) begin
    tx_mii_select_sync <= {tx_mii_select_sync[0], mii_select_reg};
end
reg [1:0] rx_mii_select_sync = 2'd0;
always @(posedge rx_clk) begin
    rx_mii_select_sync <= {rx_mii_select_sync[0], mii_select_reg};
end
reg [2:0] rx_prescale = 3'd0;
always @(posedge rx_clk) begin
    rx_prescale <= rx_prescale + 3'd1;
end
reg [2:0] rx_prescale_sync = 3'd0;
always @(posedge gtx_clk) begin
    rx_prescale_sync <= {rx_prescale_sync[1:0], rx_prescale[2]};
end
reg [6:0] rx_speed_count_1 = 0;
reg [1:0] rx_speed_count_2 = 0;
always @(posedge gtx_clk) begin
    if (gtx_rst) begin
        rx_speed_count_1 <= 0;
        rx_speed_count_2 <= 0;
        speed_reg <= 2'b10;
        mii_select_reg <= 1'b0;
    end else begin
        rx_speed_count_1 <= rx_speed_count_1 + 1;
        if (rx_prescale_sync[1] ^ rx_prescale_sync[2]) begin
            rx_speed_count_2 <= rx_speed_count_2 + 1;
        end
        if (&rx_speed_count_1) begin
            rx_speed_count_1 <= 0;
            rx_speed_count_2 <= 0;
            speed_reg <= 2'b00;
            mii_select_reg <= 1'b1;
        end
        if (&rx_speed_count_2) begin
            rx_speed_count_1 <= 0;
            rx_speed_count_2 <= 0;
            if (rx_speed_count_1[6:5]) begin
                speed_reg <= 2'b01;
                mii_select_reg <= 1'b1;
            end else begin
                speed_reg <= 2'b10;
                mii_select_reg <= 1'b0;
            end
        end
    end
end
assign speed = speed_reg;
gmii_phy_if #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE)
)
gmii_phy_if_inst (
    .clk(gtx_clk),
    .rst(gtx_rst),
    .mac_gmii_rx_clk(rx_clk),
    .mac_gmii_rx_rst(rx_rst),
    .mac_gmii_rxd(mac_gmii_rxd),
    .mac_gmii_rx_dv(mac_gmii_rx_dv),
    .mac_gmii_rx_er(mac_gmii_rx_er),
    .mac_gmii_tx_clk(tx_clk),
    .mac_gmii_tx_rst(tx_rst),
    .mac_gmii_txd(mac_gmii_txd),
    .mac_gmii_tx_en(mac_gmii_tx_en),
    .mac_gmii_tx_er(mac_gmii_tx_er),
    .phy_gmii_rx_clk(gmii_rx_clk),
    .phy_gmii_rxd(gmii_rxd),
    .phy_gmii_rx_dv(gmii_rx_dv),
    .phy_gmii_rx_er(gmii_rx_er),
    .phy_mii_tx_clk(mii_tx_clk),
    .phy_gmii_tx_clk(gmii_tx_clk),
    .phy_gmii_txd(gmii_txd),
    .phy_gmii_tx_en(gmii_tx_en),
    .phy_gmii_tx_er(gmii_tx_er),
    .mii_select(mii_select_reg)
);
eth_mac_1g #(
    .ENABLE_PADDING(ENABLE_PADDING),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
eth_mac_1g_inst (
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),
    .gmii_rxd(mac_gmii_rxd),
    .gmii_rx_dv(mac_gmii_rx_dv),
    .gmii_rx_er(mac_gmii_rx_er),
    .gmii_txd(mac_gmii_txd),
    .gmii_tx_en(mac_gmii_tx_en),
    .gmii_tx_er(mac_gmii_tx_er),
    .rx_clk_enable(1'b1),
    .tx_clk_enable(1'b1),
    .rx_mii_select(rx_mii_select_sync[1]),
    .tx_mii_select(tx_mii_select_sync[1]),
    .tx_error_underflow(tx_error_underflow),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .ifg_delay(ifg_delay)
);
endmodule
`resetall
