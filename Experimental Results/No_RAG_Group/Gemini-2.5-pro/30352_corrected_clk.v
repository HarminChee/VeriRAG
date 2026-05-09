`resetall
`timescale 1ns / 1ps
`default_nettype none
`resetall
`resetall
`timescale 1ns / 1ps
`default_nettype none
module rgmii_phy_if #
(
    parameter TARGET = "GENERIC",
    parameter IODDR_STYLE = "IODDR2",
    parameter CLOCK_INPUT_STYLE = "BUFG",
    parameter USE_CLK90 = "TRUE"
)
(
    input  wire        clk,
    input  wire        clk90,
    input  wire        rst,
    // DFT Input
    input  wire        test_mode, // Added for DFT clock selection
    output wire        mac_gmii_rx_clk,
    output wire        mac_gmii_rx_rst,
    output wire [7:0]  mac_gmii_rxd,
    output wire        mac_gmii_rx_dv,
    output wire        mac_gmii_rx_er,
    output wire        mac_gmii_tx_clk,
    output wire        mac_gmii_tx_rst,
    output wire        mac_gmii_tx_clk_en,
    input  wire [7:0]  mac_gmii_txd,
    input  wire        mac_gmii_tx_en,
    input  wire        mac_gmii_tx_er,
    input  wire        phy_rgmii_rx_clk,
    input  wire [3:0]  phy_rgmii_rxd,
    input  wire        phy_rgmii_rx_ctl,
    output wire        phy_rgmii_tx_clk,
    output wire [3:0]  phy_rgmii_txd,
    output wire        phy_rgmii_tx_ctl,
    input  wire [1:0]  speed
);

wire rgmii_rx_ctl_1;
wire rgmii_rx_ctl_2;

// Instantiation of ssio_ddr_in remains the same
ssio_ddr_in #
(
    .TARGET(TARGET),
    .CLOCK_INPUT_STYLE(CLOCK_INPUT_STYLE),
    .IODDR_STYLE(IODDR_STYLE),
    .WIDTH(5)
)
rx_ssio_ddr_inst (
    .input_clk(phy_rgmii_rx_clk),
    .input_d({phy_rgmii_rxd, phy_rgmii_rx_ctl}),
    .output_clk(mac_gmii_rx_clk), // This clock is generated internally
    .output_q1({mac_gmii_rxd[3:0], rgmii_rx_ctl_1}),
    .output_q2({mac_gmii_rxd[7:4], rgmii_rx_ctl_2})
);

assign mac_gmii_rx_dv = rgmii_rx_ctl_1;
assign mac_gmii_rx_er = rgmii_rx_ctl_1 ^ rgmii_rx_ctl_2;

// TX clock generation logic remains the same
reg rgmii_tx_clk_1 = 1'b1;
reg rgmii_tx_clk_2 = 1'b0;
reg rgmii_tx_clk_rise = 1'b1;
reg rgmii_tx_clk_fall = 1'b1;
reg [5:0] count_reg = 6'd0, count_next;

always @(posedge clk) begin
    if (rst) begin
        rgmii_tx_clk_1 <= 1'b1;
        rgmii_tx_clk_2 <= 1'b0;
        rgmii_tx_clk_rise <= 1'b1;
        rgmii_tx_clk_fall <= 1'b1;
        count_reg <= 0;
    end else begin
        rgmii_tx_clk_1 <= rgmii_tx_clk_2;
        if (speed == 2'b00) begin // 10 Mbps
            count_reg <= count_reg + 1;
            rgmii_tx_clk_rise <= 1'b0;
            rgmii_tx_clk_fall <= 1'b0;
            if (count_reg == 24) begin
                rgmii_tx_clk_1 <= 1'b1;
                rgmii_tx_clk_2 <= 1'b1;
                rgmii_tx_clk_rise <= 1'b1;
            end else if (count_reg >= 49) begin
                rgmii_tx_clk_1 <= 1'b0;
                rgmii_tx_clk_2 <= 1'b0;
                rgmii_tx_clk_fall <= 1'b1;
                count_reg <= 0;
            end
        end else if (speed == 2'b01) begin // 100 Mbps
            count_reg <= count_reg + 1;
            rgmii_tx_clk_rise <= 1'b0;
            rgmii_tx_clk_fall <= 1'b0;
            if (count_reg == 2) begin
                rgmii_tx_clk_1 <= 1'b1;
                rgmii_tx_clk_2 <= 1'b1;
                rgmii_tx_clk_rise <= 1'b1;
            end else if (count_reg >= 4) begin
                 rgmii_tx_clk_1 <= 1'b0; // Corrected: Need to assign tx_clk_1 as well
                 rgmii_tx_clk_2 <= 1'b0;
                 rgmii_tx_clk_fall <= 1'b1;
                 count_reg <= 0;
            end
        end else begin // 1000 Mbps
            // In 1000Mbps, rgmii_tx_clk_1/2 are driven by ODDR based on clk/clk90
            // Keep the default toggle based on the original logic if needed,
            // but the actual phy_rgmii_tx_clk comes from ODDR clocked by clk/clk90.
            // Resetting count_reg might be useful here.
            rgmii_tx_clk_1 <= 1'b1;
            rgmii_tx_clk_2 <= 1'b0;
            rgmii_tx_clk_rise <= 1'b1;
            rgmii_tx_clk_fall <= 1'b1;
            count_reg <= 0; // Keep counter reset for consistency
        end
    end
end

// Combinational logic for TX data/control remains the same
reg [3:0] rgmii_txd_1 = 0;
reg [3:0] rgmii_txd_2 = 0;
reg rgmii_tx_ctl_1 = 1'b0;
reg rgmii_tx_ctl_2 = 1'b0;
reg gmii_clk_en = 1'b1;

always @* begin
    if (speed == 2'b00 || speed == 2'b01) begin // 10/100 Mbps
        rgmii_txd_1 = mac_gmii_txd[3:0];
        rgmii_txd_2 = mac_gmii_txd[3:0]; // Data repeated on both edges
        if (rgmii_tx_clk_2) begin // Rising edge data phase
            rgmii_tx_ctl_1 = mac_gmii_tx_en;
            rgmii_tx_ctl_2 = mac_gmii_tx_en;
        end else begin // Falling edge data phase
            rgmii_tx_ctl_1 = mac_gmii_tx_en ^ mac_gmii_tx_er;
            rgmii_tx_ctl_2 = mac_gmii_tx_en ^ mac_gmii_tx_er;
        end
        gmii_clk_en = rgmii_tx_clk_fall; // Enable logic based on generated clock state
    end else begin // 1000 Mbps
        rgmii_txd_1 = mac_gmii_txd[3:0]; // Low nibble on rising edge
        rgmii_txd_2 = mac_gmii_txd[7:4]; // High nibble on falling edge
        rgmii_tx_ctl_1 = mac_gmii_tx_en;
        rgmii_tx_ctl_2 = mac_gmii_tx_en ^ mac_gmii_tx_er;
        gmii_clk_en = 1'b1; // Always enabled for 1000 Mbps GMII clock
    end
end

// Instantiation of ODDRs remains the same
oddr #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .WIDTH(1)
)
clk_oddr_inst (
    .clk(USE_CLK90 == "TRUE" ? clk90 : clk), // Clocked by primary input clk or clk90
    .d1(rgmii_tx_clk_1),
    .d2(rgmii_tx_clk_2),
    .q(phy_rgmii_tx_clk)
);

oddr #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .WIDTH(5)
)
data_oddr_inst (
    .clk(clk), // Clocked by primary input clk
    .d1({rgmii_txd_1, rgmii_tx_ctl_1}),
    .d2({rgmii_txd_2, rgmii_tx_ctl_2}),
    .q({phy_rgmii_txd, phy_rgmii_tx_ctl})
);

// Assign MAC TX clock directly from primary input clock
assign mac_gmii_tx_clk = clk;
assign mac_gmii_tx_clk_en = gmii_clk_en;

// TX Reset Synchronizer - Clocked by primary input clk (via mac_gmii_tx_clk)
reg [3:0] tx_rst_reg = 4'hf;
assign mac_gmii_tx_rst = tx_rst_reg[0];
always @(posedge mac_gmii_tx_clk or posedge rst) begin
    if (rst) begin
        tx_rst_reg <= 4'hf;
    end else begin
        tx_rst_reg <= {1'b0, tx_rst_reg[3:1]};
    end
end

// RX Reset Synchronizer - DFT Correction for CLKNPI
reg [3:0] rx_rst_reg = 4'hf;
assign mac_gmii_rx_rst = rx_rst_reg[0];

// DFT Clock Mux: Select primary clock 'clk' in test_mode, otherwise use functional 'mac_gmii_rx_clk'
wire rx_clk_muxed;
assign rx_clk_muxed = test_mode ? clk : mac_gmii_rx_clk;

// Use the muxed clock for the RX reset synchronizer flops
always @(posedge rx_clk_muxed or posedge rst) begin // Changed clock source
    if (rst) begin
        rx_rst_reg <= 4'hf;
    end else begin
        rx_rst_reg <= {1'b0, rx_rst_reg[3:1]};
    end
end

endmodule
`resetall