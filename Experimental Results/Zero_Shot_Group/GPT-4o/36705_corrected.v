`timescale 1 ps/1 ps

module tri_mode_eth_mac_v5_2_example_design (
    input         glbl_rst,
    input         clk_in_p,
    input         clk_in_n,
    output        phy_resetn,
    output [7:0]  gmii_txd,
    output        gmii_tx_en,
    output        gmii_tx_er,
    output        gmii_tx_clk,
    input  [7:0]  gmii_rxd,
    input         gmii_rx_dv,
    input         gmii_rx_er,
    input         gmii_rx_clk,
    input         gmii_col,
    input         gmii_crs,
    inout         mdio,
    output        mdc,
    output        tx_statistics_s,
    output        rx_statistics_s,
    input         pause_req_s,
    input  [1:0]  mac_speed,
    input         update_speed,
    input         config_board,
    output        serial_response,
    input         gen_tx_data,
    input         chk_tx_data,
    input         reset_error,
    output        frame_error,
    output        frame_errorn,
    output        activity_flash,
    output        activity_flashn
);

parameter MAC_BASE_ADDR = 32'h0;

wire gtx_clk_bufg, refclk_bufg, s_axi_aclk, rx_mac_aclk;
reg phy_resetn_int;
wire s_axi_reset_int, chk_reset_int, gtx_clk_reset_int, rx_reset, tx_reset, dcm_locked, glbl_rst_int;
reg [5:0] phy_reset_count;
wire glbl_rst_intn, rx_fifo_clock, rx_fifo_resetn, tx_fifo_clock, tx_fifo_resetn;
wire [7:0] rx_axis_fifo_tdata, tx_axis_fifo_tdata;
wire rx_axis_fifo_tvalid, rx_axis_fifo_tlast, rx_axis_fifo_tready;
wire tx_axis_fifo_tvalid, tx_axis_fifo_tlast, tx_axis_fifo_tready;
wire rx_statistics_valid, tx_statistics_valid;
reg rx_statistics_valid_reg, tx_statistics_valid_reg;
wire [27:0] rx_statistics_vector;
reg [27:0] rx_stats;
reg rx_stats_toggle = 0;
wire rx_stats_toggle_sync;
reg rx_stats_toggle_sync_reg = 0;
reg [29:0] rx_stats_shift;
wire [31:0] tx_statistics_vector;
reg [33:0] tx_stats_shift;
reg [18:0] pause_shift;
reg pause_req;
reg [15:0] pause_val;
wire [31:0] s_axi_awaddr, s_axi_wdata, s_axi_araddr, s_axi_rdata;
wire s_axi_awvalid, s_axi_awready, s_axi_wvalid, s_axi_wready, s_axi_bvalid, s_axi_bready;
wire [1:0] s_axi_bresp, s_axi_rresp;
wire s_axi_arvalid, s_axi_arready, s_axi_rvalid, s_axi_rready;
reg enable_address_swap = 1, enable_phy_loopback = 0;
wire [7:0] tx_ifg_delay = 0;
assign frame_errorn = ~frame_error;
assign activity_flashn = ~activity_flash;
wire mdio_i, mdio_o, mdio_t;
assign mdio = mdio_t ? 1'bz : mdio_o;
assign mdio_i = mdio;

always @(posedge gtx_clk_bufg) begin
    if (config_board) enable_address_swap <= gen_tx_data;
end

always @(posedge s_axi_aclk) begin
    if (config_board) enable_phy_loopback <= chk_tx_data;
end

clk_wiz_v2_1 clock_generator (
    .CLK_IN1_P(clk_in_p),
    .CLK_IN1_N(clk_in_n),
    .CLK_OUT1(gtx_clk_bufg),
    .CLK_OUT2(s_axi_aclk),
    .CLK_OUT3(refclk_bufg),
    .RESET(glbl_rst),
    .LOCKED(dcm_locked)
);

reset_sync glbl_reset_gen (
    .clk(gtx_clk_bufg),
    .enable(dcm_locked),
    .reset_in(glbl_rst),
    .reset_out(glbl_rst_int)
);

assign glbl_rst_intn = ~glbl_rst_int;
assign tx_fifo_clock = gtx_clk_bufg;
assign rx_fifo_clock = gtx_clk_bufg;

reset_sync axi_lite_reset_gen (
    .clk(s_axi_aclk),
    .enable(phy_resetn_int),
    .reset_in(glbl_rst),
    .reset_out(s_axi_reset_int)
);

always @(posedge s_axi_aclk) begin
    if (s_axi_reset_int) begin
        s_axi_resetn <= 0;
    end else begin
        s_axi_resetn <= 1;
    end
end 

reset_sync gtx_reset_gen (
    .clk(gtx_clk_bufg),
    .enable(dcm_locked),
    .reset_in(glbl_rst || rx_reset || tx_reset),
    .reset_out(gtx_clk_reset_int)
);

always @(posedge gtx_clk_bufg) begin
    if (gtx_clk_reset_int) begin
        gtx_resetn <= 0;
    end else begin
        gtx_resetn <= 1;
    end
end 

reset_sync chk_reset_gen (
    .clk(gtx_clk_bufg),
    .enable(dcm_locked),
    .reset_in(glbl_rst || reset_error),
    .reset_out(chk_reset_int)
);

always @(posedge gtx_clk_bufg) begin
    if (chk_reset_int) begin
        chk_resetn <= 0;
    end else begin
        chk_resetn <= 1;
    end
end 

always @(posedge gtx_clk_bufg) begin
    if (!glbl_rst_intn) begin
        phy_resetn_int <= 0;
        phy_reset_count <= 0;
    end else if (!(&phy_reset_count)) begin
        phy_reset_count <= phy_reset_count + 1;
    end else begin
        phy_resetn_int <= 1;
    end
end

assign phy_resetn = phy_resetn_int;
assign tx_fifo_resetn = gtx_resetn;
assign rx_fifo_resetn = gtx_resetn;

always @(posedge rx_mac_aclk) begin
    rx_statistics_valid_reg <= rx_statistics_valid;
    if (!rx_statistics_valid_reg & rx_statistics_valid) begin
        rx_stats <= rx_statistics_vector;
        rx_stats_toggle <= ~rx_stats_toggle;
    end
end

sync_block rx_stats_sync (
    .clk(gtx_clk_bufg),
    .data_in(rx_stats_toggle),
    .data_out(rx_stats_toggle_sync)
);

always @(posedge gtx_clk_bufg) begin
    rx_stats_toggle_sync_reg <= rx_stats_toggle_sync;
    rx_stats_shift <= rx_stats_toggle_sync_reg != rx_stats_toggle_sync ? {1'b1, rx_stats, 1'b1} : {rx_stats_shift[28:0], 1'b0};
end

assign rx_statistics_s = rx_stats_shift[29];

always @(posedge gtx_clk_bufg) begin
    tx_statistics_valid_reg <= tx_statistics_valid;
    tx_stats_shift <= !tx_statistics_valid_reg & tx_statistics_valid ? {1'b1, tx_statistics_vector, 1'b1} : {tx_stats_shift[32:0], 1'b0};
end

assign tx_statistics_s = tx_stats_shift[33];

always @(posedge gtx_clk_bufg) begin
    pause_shift <= {pause_shift[17:0], pause_req_s};
    if (pause_shift[18] == 1'b0 && pause_shift[17] == 1'b1 && pause_shift[0] == 1'b1) begin
        pause_req <= 1'b1;
        pause_val <= pause_shift[16:1];
    end else begin
        pause_req <= 1'b0;
        pause_val <= 0;
    end
end

axi_lite_sm #(.MAC_BASE_ADDR(MAC_BASE_ADDR)) axi_lite_controller (
    .s_axi_aclk(s_axi_aclk),
    .s_axi_resetn(s_axi_resetn),
    .mac_speed(mac_speed),
    .update_speed(update_speed),
    .serial_command(pause_req_s),
    .serial_response(serial_response),
    .phy_loopback(enable_phy_loopback),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready)
);

endmodule