`timescale 1 ps / 1 ps
module emac_single_example_design
(
    input  wire        test_i,
    output wire        EMAC0CLIENTRXDVLD,
    output wire        EMAC0CLIENTRXFRAMEDROP,
    output wire [6:0]  EMAC0CLIENTRXSTATS,
    output wire        EMAC0CLIENTRXSTATSVLD,
    output wire        EMAC0CLIENTRXSTATSBYTEVLD,
    input  wire [7:0]  CLIENTEMAC0TXIFGDELAY,
    output wire        EMAC0CLIENTTXSTATS,
    output wire        EMAC0CLIENTTXSTATSVLD,
    output wire        EMAC0CLIENTTXSTATSBYTEVLD,
    input  wire        CLIENTEMAC0PAUSEREQ,
    input  wire [15:0] CLIENTEMAC0PAUSEVAL,
    input  wire        GTX_CLK_0,
    output wire [7:0]  GMII_TXD_0,
    output wire        GMII_TX_EN_0,
    output wire        GMII_TX_ER_0,
    output wire        GMII_TX_CLK_0,
    input  wire [7:0]  GMII_RXD_0,
    input  wire        GMII_RX_DV_0,
    input  wire        GMII_RX_ER_0,
    input  wire        GMII_RX_CLK_0,
    input  wire        REFCLK,
    input  wire        RESET
);
    wire            reset_i;
    wire            ll_clk_0_i;
    wire      [7:0] tx_ll_data_0_i;
    wire            tx_ll_sof_n_0_i;
    wire            tx_ll_eof_n_0_i;
    wire            tx_ll_src_rdy_n_0_i;
    wire            tx_ll_dst_rdy_n_0_i;
    wire      [7:0] rx_ll_data_0_i;
    wire            rx_ll_sof_n_0_i;
    wire            rx_ll_eof_n_0_i;
    wire            rx_ll_src_rdy_n_0_i;
    wire            rx_ll_dst_rdy_n_0_i;
    reg       [5:0] ll_pre_reset_0_i;
    reg             ll_reset_0_i;
    wire            refclk_ibufg_i;
    wire            refclk_bufg_i;
    wire            tx_clk_0;
    wire            rx_clk_0_i;
    wire            gmii_rx_clk_0_delay;
    reg  [12:0]     idelayctrl_reset_0_r;
    wire            idelayctrl_reset_0_i;
    wire            gtx_clk_0_i;
    wire            dft_tx_clk;
    wire            dft_rx_clk;
    wire            dft_ll_clk;

    IBUF reset_ibuf (.I(RESET), .O(reset_i));

    IDELAYCTRL dlyctrl0 (
        .RDY(),
        .REFCLK(refclk_bufg_i),
        .RST(idelayctrl_reset_0_i)
    );

    always @(posedge refclk_bufg_i or posedge reset_i)
    begin
        if (reset_i == 1'b1)
        begin
            idelayctrl_reset_0_r[0]    <= 1'b0;
            idelayctrl_reset_0_r[12:1] <= 12'b111111111111;
        end
        else
        begin
            idelayctrl_reset_0_r[0]    <= 1'b0;
            idelayctrl_reset_0_r[12:1] <= idelayctrl_reset_0_r[11:0];
        end
    end

    assign idelayctrl_reset_0_i = idelayctrl_reset_0_r[12];

    IODELAY gmii_rxc0_delay
    (.IDATAIN(GMII_RX_CLK_0),
     .ODATAIN(1'b0),
     .DATAOUT(gmii_rx_clk_0_delay),
     .DATAIN(1'b0),
     .C(1'b0),
     .T(1'b0),
     .CE(1'b0),
     .INC(1'b0),
     .RST(1'b0));
    defparam gmii_rxc0_delay.IDELAY_TYPE = "FIXED";
    defparam gmii_rxc0_delay.IDELAY_VALUE = 0;
    defparam gmii_rxc0_delay.DELAY_SRC = "I";
    defparam gmii_rxc0_delay.SIGNAL_PATTERN = "CLOCK";

    BUFG bufg_tx_0 (.I(gtx_clk_0_i), .O(tx_clk_0));
    BUFG bufg_rx_0 (.I(gmii_rx_clk_0_delay), .O(rx_clk_0_i));

    assign dft_tx_clk = test_i ? refclk_bufg_i : tx_clk_0;
    assign dft_rx_clk = test_i ? refclk_bufg_i : rx_clk_0_i;
    assign dft_ll_clk = test_i ? refclk_bufg_i : ll_clk_0_i;
    assign ll_clk_0_i = tx_clk_0;

    emac_single_locallink v5_emac_ll
    (
        .TX_CLK_OUT                          (),
        .TX_CLK_0                            (dft_tx_clk),
        .RX_LL_CLOCK_0                       (dft_ll_clk),
        .RX_LL_RESET_0                       (ll_reset_0_i),
        .RX_LL_DATA_0                        (rx_ll_data_0_i),
        .RX_LL_SOF_N_0                       (rx_ll_sof_n_0_i),
        .RX_LL_EOF_N_0                       (rx_ll_eof_n_0_i),
        .RX_LL_SRC_RDY_N_0                   (rx_ll_src_rdy_n_0_i),
        .RX_LL_DST_RDY_N_0                   (rx_ll_dst_rdy_n_0_i),
        .RX_LL_FIFO_STATUS_0                 (),
        .EMAC0CLIENTRXDVLD                   (EMAC0CLIENTRXDVLD),
        .EMAC0CLIENTRXFRAMEDROP              (EMAC0CLIENTRXFRAMEDROP),
        .EMAC0CLIENTRXSTATS                  (EMAC0CLIENTRXSTATS),
        .EMAC0CLIENTRXSTATSVLD               (EMAC0CLIENTRXSTATSVLD),
        .EMAC0CLIENTRXSTATSBYTEVLD           (EMAC0CLIENTRXSTATSBYTEVLD),
        .TX_LL_CLOCK_0                       (dft_ll_clk),
        .TX_LL_RESET_0                       (ll_reset_0_i),
        .TX_LL_DATA_0                        (tx_ll_data_0_i),
        .TX_LL_SOF_N_0                       (tx_ll_sof_n_0_i),
        .TX_LL_EOF_N_0                       (tx_ll_eof_n_0_i),
        .TX_LL_SRC_RDY_N_0                   (tx_ll_src_rdy_n_0_i),
        .TX_LL_DST_RDY_N_0                   (tx_ll_dst_rdy_n_0_i),
        .CLIENTEMAC0TXIFGDELAY               (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS                  (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD               (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD           (EMAC0CLIENTTXSTATSBYTEVLD),
        .CLIENTEMAC0PAUSEREQ                 (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL                 (CLIENTEMAC0PAUSEVAL),
        .GTX_CLK_0                           (1'b0),
        .GMII_TXD_0                          (GMII_TXD_0),
        .GMII_TX_EN_0                        (GMII_TX_EN_0),
        .GMII_TX_ER_0                        (GMII_TX_ER_0),
        .GMII_TX_CLK_0                       (GMII_TX_CLK_0),
        .GMII_RXD_0                          (GMII_RXD_0),
        .GMII_RX_DV_0                        (GMII_RX_DV_0),
        .GMII_RX_ER_0                        (GMII_RX_ER_0),
        .GMII_RX_CLK_0                       (dft_rx_clk),
        .RESET                               (reset_i)
    );

    address_swap_module_8 client_side_asm_emac0 
    (
        .rx_ll_clock(dft_ll_clk),
        .rx_ll_reset(ll_reset_0_i),
        .rx_ll_data_in(rx_ll_data_0_i),
        .rx_ll_sof_in_n(rx_ll_sof_n_0_i),
        .rx_ll_eof_in_n(rx_ll_eof_n_0_i),
        .rx_ll_src_rdy_in_n(rx_ll_src_rdy_n_0_i),
        .rx_ll_data_out(tx_ll_data_0_i),
        .rx_ll_sof_out_n(tx_ll_sof_n_0_i),
        .rx_ll_eof_out_n(tx_ll_eof_n_0_i),
        .rx_ll_src_rdy_out_n(tx_ll_src_rdy_n_0_i),
        .rx_ll_dst_rdy_in_n(tx_ll_dst_rdy_n_0_i)
    );

    assign rx_ll_dst_rdy_n_0_i = tx_ll_dst_rdy_n_0_i;

    always @(posedge dft_ll_clk or posedge reset_i)
    begin
        if (reset_i === 1'b1)
        begin
            ll_pre_reset_0_i <= 6'h3F;
            ll_reset_0_i     <= 1'b1;
        end
        else
        begin
            ll_pre_reset_0_i[0]   <= 1'b0;
            ll_pre_reset_0_i[5:1] <= ll_pre_reset_0_i[4:0];
            ll_reset_0_i          <= ll_pre_reset_0_i[5];
        end
    end

    IBUFG refclk_ibufg (.I(REFCLK), .O(refclk_ibufg_i));
    BUFG  refclk_bufg  (.I(refclk_ibufg_i), .O(refclk_bufg_i));
    IBUF gtx_clk0_ibuf (.I(GTX_CLK_0), .O(gtx_clk_0_i));
endmodule