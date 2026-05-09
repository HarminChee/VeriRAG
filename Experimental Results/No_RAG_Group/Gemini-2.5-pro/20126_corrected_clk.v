`timescale 1ns / 1ps
module 1_corrected_clk #
(
    parameter TARGET = "GENERIC",
    parameter IODDR_STYLE = "IODDR2",
    parameter CLOCK_INPUT_STYLE = "BUFIO2",
    parameter USE_CLK90 = "TRUE",
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        gtx_clk,         // Primary clock input
    input  wire        gtx_clk90,
    input  wire        gtx_rst,         // Primary reset input
    output wire        rx_clk,          // Generated clock (potential DFT issue)
    output wire        rx_rst,
    output wire        tx_clk,          // Generated clock (potential DFT issue)
    output wire        tx_rst,
    input  wire        scan_mode,       // DFT input: Scan mode enable
    input  wire [7:0]  tx_axis_tdata,
    input  wire        tx_axis_tvalid,
    output wire        tx_axis_tready,
    input  wire        tx_axis_tlast,
    input  wire        tx_axis_tuser,
    output wire [7:0]  rx_axis_tdata,
    output wire        rx_axis_tvalid,
    output wire        rx_axis_tlast,
    output wire        rx_axis_tuser,
    input  wire        rgmii_rx_clk,    // Primary clock input (for PHY)
    input  wire [3:0]  rgmii_rxd,
    input  wire        rgmii_rx_ctl,
    output wire        rgmii_tx_clk,
    output wire [3:0]  rgmii_txd,
    output wire        rgmii_tx_ctl,
    output wire        tx_error_underflow,
    output wire        rx_error_bad_frame,
    output wire        rx_error_bad_fcs,
    output wire [1:0]  speed,
    input  wire [7:0]  ifg_delay
);

// Internal signals
wire [7:0]  mac_gmii_rxd;
wire        mac_gmii_rx_dv;
wire        mac_gmii_rx_er;
wire        mac_gmii_tx_clk_en;
wire [7:0]  mac_gmii_txd;
wire        mac_gmii_tx_en;
wire        mac_gmii_tx_er;

// Speed detection and MII select logic (clocked by primary gtx_clk)
reg [1:0] speed_reg = 2'b10;
reg mii_select_reg = 1'b0;
reg [2:0] rx_prescale_sync = 3'd0;
reg [6:0] rx_speed_count_1 = 0;
reg [1:0] rx_speed_count_2 = 0;

// DFT Clock Muxing: Select primary clock (gtx_clk) during scan_mode
wire tx_clk_muxed;
wire rx_clk_muxed;

// Use BUFGCE or equivalent preferred for clock muxing in real hardware
// Using assign for behavioral representation of clock muxing intent
assign tx_clk_muxed = scan_mode ? gtx_clk : tx_clk;
assign rx_clk_muxed = scan_mode ? gtx_clk : rx_clk;

// Synchronizers using DFT-friendly clocks
reg [1:0] tx_mii_select_sync = 2'd0;
always @(posedge tx_clk_muxed or posedge gtx_rst) begin // Use muxed clock, add reset
    if (gtx_rst) begin
        tx_mii_select_sync <= 2'd0;
    end else begin
        tx_mii_select_sync <= {tx_mii_select_sync[0], mii_select_reg};
    end
end

reg [1:0] rx_mii_select_sync = 2'd0;
always @(posedge rx_clk_muxed or posedge gtx_rst) begin // Use muxed clock, add reset
     if (gtx_rst) begin
        rx_mii_select_sync <= 2'd0;
    end else begin
        rx_mii_select_sync <= {rx_mii_select_sync[0], mii_select_reg};
    end
end

reg [2:0] rx_prescale = 3'd0;
always @(posedge rx_clk_muxed or posedge gtx_rst) begin // Use muxed clock, add reset
    if (gtx_rst) begin // Assuming gtx_rst should reset this domain too during test
        rx_prescale <= 3'd0;
    end else begin
        rx_prescale <= rx_prescale + 3'd1;
    end
end

// Speed detection logic (already clocked by primary gtx_clk)
always @(posedge gtx_clk) begin
    rx_prescale_sync <= {rx_prescale_sync[1:0], rx_prescale[2]}; // Sample rx_prescale output
end

always @(posedge gtx_clk) begin
    if (gtx_rst) begin
        rx_speed_count_1 <= 0;
        rx_speed_count_2 <= 0;
        speed_reg <= 2'b10;
        mii_select_reg <= 1'b0;
    end else begin
        // Existing speed detection logic remains unchanged
        rx_speed_count_1 <= rx_speed_count_1 + 1;
        if (rx_prescale_sync[1] ^ rx_prescale_sync[2]) begin
            rx_speed_count_2 <= rx_speed_count_2 + 1;
        end
        if (&rx_speed_count_1) begin
            rx_speed_count_1 <= 0;
            rx_speed_count_2 <= 0;
            // Check rx_speed_count_2 to determine speed
            if (&rx_speed_count_2) begin // ~125MHz (Gigabit)
                 speed_reg <= 2'b10;
                 mii_select_reg <= 1'b0; // GMII
            end else if (rx_speed_count_2 > 2) begin // ~25MHz (100M) based on count comparison
                 speed_reg <= 2'b01;
                 mii_select_reg <= 1'b1; // MII
            end else begin // ~2.5MHz (10M)
                 speed_reg <= 2'b00;
                 mii_select_reg <= 1'b1; // MII
            end
        end
        // Simplified original logic - kept for reference, replaced by above
        // if (&rx_speed_count_1) begin
        //     rx_speed_count_1 <= 0;
        //     rx_speed_count_2 <= 0;
        //     speed_reg <= 2'b00;
        //     mii_select_reg <= 1'b1;
        // end
        // if (&rx_speed_count_2) begin
        //     rx_speed_count_1 <= 0;
        //     rx_speed_count_2 <= 0;
        //     if (rx_speed_count_1[6:5]) begin // This comparison seems suspect
        //         speed_reg <= 2'b01;
        //         mii_select_reg <= 1'b1;
        //     end else begin
        //         speed_reg <= 2'b10;
        //         mii_select_reg <= 1'b0;
        //     end
        // end
    end
end

assign speed = speed_reg;

// Instantiation of PHY Interface
rgmii_phy_if #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE),
    .USE_CLK90(USE_CLK90)
)
rgmii_phy_if_inst (
    .clk(gtx_clk),          // Primary clock input
    .clk90(gtx_clk90),
    .rst(gtx_rst),          // Primary reset input
    .mac_gmii_rx_clk(rx_clk), // Generated clock output
    .mac_gmii_rx_rst(rx_rst),
    .mac_gmii_rxd(mac_gmii_rxd),
    .mac_gmii_rx_dv(mac_gmii_rx_dv),
    .mac_gmii_rx_er(mac_gmii_rx_er),
    .mac_gmii_tx_clk(tx_clk), // Generated clock output
    .mac_gmii_tx_rst(tx_rst),
    .mac_gmii_tx_clk_en(mac_gmii_tx_clk_en),
    .mac_gmii_txd(mac_gmii_txd),
    .mac_gmii_tx_en(mac_gmii_tx_en),
    .mac_gmii_tx_er(mac_gmii_tx_er),
    .phy_rgmii_rx_clk(rgmii_rx_clk), // PHY clock input
    .phy_rgmii_rxd(rgmii_rxd),
    .phy_rgmii_rx_ctl(rgmii_rx_ctl),
    .phy_rgmii_tx_clk(rgmii_tx_clk),
    .phy_rgmii_txd(rgmii_txd),
    .phy_rgmii_tx_ctl(rgmii_tx_ctl),
    .speed(speed)
);

// Instantiation of MAC Core
eth_mac_1g #(
    .ENABLE_PADDING(ENABLE_PADDING),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH)
)
eth_mac_1g_inst (
    // Use the generated clocks for the MAC instance's functional operation
    .tx_clk(tx_clk),
    .tx_rst(tx_rst), // Assuming MAC handles its own reset sync if needed
    .rx_clk(rx_clk),
    .rx_rst(rx_rst), // Assuming MAC handles its own reset sync if needed
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
    .rx_clk_enable(1'b1), // Clock enables should be controllable/observable for DFT
    .tx_clk_enable(mac_gmii_tx_clk_en), // Clock enables should be controllable/observable for DFT
    .rx_mii_select(rx_mii_select_sync[1]), // Use synchronized MII select
    .tx_mii_select(tx_mii_select_sync[1]), // Use synchronized MII select
    .tx_error_underflow(tx_error_underflow),
    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),
    .ifg_delay(ifg_delay)
);

endmodule