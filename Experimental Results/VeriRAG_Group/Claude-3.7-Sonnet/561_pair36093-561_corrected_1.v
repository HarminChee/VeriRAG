`timescale 1ns / 1ps
module fpga_core #
(
    parameter TARGET = "GENERIC"
)
(
    input  wire       clk,
    input  wire       clk90,
    input  wire       rst,
    input  wire [3:0]  btn,
    input  wire [17:0] sw,
    output wire [8:0]  ledg,
    output wire [17:0] ledr,
    output wire [6:0]  hex0,
    output wire [6:0]  hex1,
    output wire [6:0]  hex2,
    output wire [6:0]  hex3,
    output wire [6:0]  hex4,
    output wire [6:0]  hex5,
    output wire [6:0]  hex6,
    output wire [6:0]  hex7,
    output wire [35:0] gpio,
    input  wire       phy0_rx_clk,
    input  wire [3:0] phy0_rxd,
    input  wire       phy0_rx_ctl,
    output wire       phy0_tx_clk,
    output wire [3:0] phy0_txd,
    output wire       phy0_tx_ctl,
    output wire       phy0_reset_n,
    input  wire       phy0_int_n,
    input  wire       phy1_rx_clk,
    input  wire [3:0] phy1_rxd,
    input  wire       phy1_rx_ctl,
    output wire       phy1_tx_clk,
    output wire [3:0] phy1_txd,
    output wire       phy1_tx_ctl,
    output wire       phy1_reset_n,
    input  wire       phy1_int_n,
    input  wire       test_i
);

wire dft_clk;
wire dft_rst;
assign dft_clk = test_i ? clk : clk90;
assign dft_rst = test_i ? rst : rst;

reg match_cond_reg;
reg no_match_reg;
reg [7:0] led_reg;
reg valid_last;
reg [31:0] dest_ip_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        match_cond_reg <= 0;
        no_match_reg <= 0;
    end else begin
        if (rx_udp_payload_axis_tvalid) begin
            if ((!match_cond_reg && !no_match_reg) ||
                (rx_udp_payload_axis_tvalid && rx_udp_payload_axis_tready && rx_udp_payload_axis_tlast)) begin
                match_cond_reg <= match_cond;
                no_match_reg <= no_match;
            end
        end else begin
            match_cond_reg <= 0;
            no_match_reg <= 0;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        led_reg <= 0;
        valid_last <= 0;
    end else begin
        if (tx_udp_payload_axis_tvalid) begin
            if (!valid_last) begin
                led_reg <= tx_udp_payload_axis_tdata;
                valid_last <= 1'b1;
            end
            if (tx_udp_payload_axis_tlast) begin
                valid_last <= 1'b0;
            end
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        dest_ip_reg <= 0;
    end else begin
        if (tx_udp_hdr_valid) begin
            dest_ip_reg <= tx_udp_ip_dest_ip;
        end
    end
end

endmodule