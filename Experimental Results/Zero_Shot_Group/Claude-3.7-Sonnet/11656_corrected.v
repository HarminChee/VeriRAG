`timescale 1 ps / 1 ps

module v6_emac_v1_5_example_design (
    EMACCLIENTRXDVLD,
    EMACCLIENTRXFRAMEDROP,
    EMACCLIENTRXSTATS,
    EMACCLIENTRXSTATSVLD,
    EMACCLIENTRXSTATSBYTEVLD,
    CLIENTEMACTXIFGDELAY,
    EMACCLIENTTXSTATS,
    EMACCLIENTTXSTATSVLD,
    EMACCLIENTTXSTATSBYTEVLD,
    CLIENTEMACPAUSEREQ,
    CLIENTEMACPAUSEVAL,
    GTX_CLK,
    GMII_TXD,
    GMII_TX_EN,
    GMII_TX_ER,
    GMII_TX_CLK,
    GMII_RXD,
    GMII_RX_DV,
    GMII_RX_ER,
    GMII_RX_CLK,
    REFCLK,
    RESET
);

    output          EMACCLIENTRXDVLD;
    output          EMACCLIENTRXFRAMEDROP;
    output  [6:0]   EMACCLIENTRXSTATS;
    output          EMACCLIENTRXSTATSVLD;
    output          EMACCLIENTRXSTATSBYTEVLD;
    input   [7:0]   CLIENTEMACTXIFGDELAY;
    output          EMACCLIENTTXSTATS;
    output          EMACCLIENTTXSTATSVLD;
    output          EMACCLIENTTXSTATSBYTEVLD;
    input           CLIENTEMACPAUSEREQ;
    input   [15:0]  CLIENTEMACPAUSEVAL;
    input           GTX_CLK;
    output  [7:0]   GMII_TXD;
    output          GMII_TX_EN;
    output          GMII_TX_ER;
    output          GMII_TX_CLK;
    input   [7:0]   GMII_RXD;
    input           GMII_RX_DV;
    input           GMII_RX_ER;
    input           GMII_RX_CLK;
    input           REFCLK;
    input           RESET;

    wire            reset_i;
    wire            ll_clk_i;
    wire    [7:0]   tx_ll_data_i;
    wire            tx_ll_sof_n_i;
    wire            tx_ll_eof_n_i;
    wire            tx_ll_src_rdy_n_i;
    wire            tx_ll_dst_rdy_n_i;
    wire    [7:0]   rx_ll_data_i;
    wire            rx_ll_sof_n_i;
    wire            rx_ll_eof_n_i;
    wire            rx_ll_src_rdy_n_i;
    wire            rx_ll_dst_rdy_n_i;

    (* ASYNC_REG = "TRUE" *)
    reg     [5:0]   ll_pre_reset_i;
    reg             ll_reset_i;

    wire            refclk_ibufg_i;
    wire            refclk_bufg_i;

    (* KEEP = "TRUE" *)
    wire            tx_clk;
    wire            rx_clk_i;
    wire            gmii_rx_clk_bufio;
    wire            gmii_rx_clk_delay;

    reg     [12:0]  idelayctrl_reset_r;
    wire            idelayctrl_reset_i;
    wire            gtx_clk_i;

    IBUF reset_ibuf (
        .I (RESET),
        .O (reset_i)
    );

    (* SYN_NOPRUNE = "TRUE" *)
    IDELAYCTRL dlyctrl (
        .RDY    (),
        .REFCLK (refclk_bufg_i),
        .RST    (idelayctrl_reset_i)
    );

    always @(posedge refclk_bufg_i, posedge reset_i)
    begin
        if (reset_i == 1'b1)
        begin
            idelayctrl_reset_r[0]    <= 1'b1;
            idelayctrl_reset_r[12:1] <= 12'b111111111111;
        end
        else
        begin
            idelayctrl_reset_r[0]    <= 1'b0;
            idelayctrl_reset_r[12:1] <= idelayctrl_reset_r[11:0];
        end
    end

    assign idelayctrl_reset_i = idelayctrl_reset_r[12];

    IODELAY #(
        .IDELAY_TYPE           ("FIXED"),
        .IDELAY_VALUE          (0),
        .DELAY_SRC             ("I"),
        .SIGNAL_PATTERN        ("CLOCK"),
        .HIGH_PERFORMANCE_MODE ("TRUE")
    )
    gmii_rxc_delay (
        .IDATAIN (GMII_RX_CLK),
        .ODATAIN (1'b0),
        .DATAOUT (gmii_rx_clk_delay),
        .DATAIN  (1'b0),
        .C       (1'b0),
        .T       (1'b0),
        .CE      (1'b0),
        .INC     (1'b0),
        .RST     (1'b0)
    );

    BUFG bufg_tx (
        .I (gtx_clk_i),
        .O (GMII_TX_CLK) // tx_clk)
    );

    BUFIO bufio_rx (
        .I (gmii_rx_clk_delay),
        .O (gmii_rx_clk_bufio)
    );

    BUFR bufr_rx (
        .I   (gmii_rx_clk_delay),
        .O   (rx_clk_i),
        .CE  (1'b1),
        .CLR (1'b0)
    );

    assign ll_clk_i = tx_clk;

    v6_emac_v1_5_locallink v6_emac_v1_5_locallink_inst (
        .TX_CLK_OUT               (GMII_TX_CLK),//() ,
        .TX_CLK                   (tx_clk),
        .RX_LL_CLOCK              (ll_clk_i),
        .RX_LL_RESET              (ll_reset_i),
        .RX_LL_DATA               (rx_ll_data_i),
        .RX_LL_SOF_N              (rx_ll_sof_n_i),
        .RX_LL_EOF_N              (rx_ll_eof_n_i),
        .RX_LL_SRC_RDY_N          (rx_ll_src_rdy_n_i),
        .RX_LL_DST_RDY_N          (rx_ll_dst_rdy_n_i),
        .RX_LL_FIFO_STATUS        (),
        .EMACCLIENTRXDVLD         (EMACCLIENTRXDVLD),
        .EMACCLIENTRXFRAMEDROP    (EMACCLIENTRXFRAMEDROP),
        .EMACCLIENTRXSTATS        (EMACCLIENTRXSTATS),
        .EMACCLIENTRXSTATSVLD     (EMACCLIENTRXSTATSVLD),
        .EMACCLIENTRXSTATSBYTEVLD (EMACCLIENTRXSTATSBYTEVLD),
        .TX_LL_CLOCK              (ll_clk_i),
        .TX_LL_RESET              (ll_reset_i),
        .TX_LL_DATA               (tx_ll_data_i),
        .TX_LL_SOF_N              (tx_ll_sof_n_i),
        .TX_LL_EOF_N              (tx_ll_eof_n_i),
        .TX_LL_SRC_RDY_N          (tx_ll_src_rdy_n_i),
        .TX_LL_DST_RDY_N          (tx_ll_dst_rdy_n_i),
        .CLIENTEMACTXIFGDELAY     (CLIENTEMACTXIFGDELAY),
        .EMACCLIENTTXSTATS        (EMACCLIENTTXSTATS),
        .EMACCLIENTTXSTATSVLD     (EMACCLIENTTXSTATSVLD),
        .EMACCLIENTTXSTATSBYTEVLD (EMACCLIENTTXSTATSBYTEVLD),
        .CLIENTEMACPAUSEREQ       (CLIENTEMACPAUSEREQ),
        .CLIENTEMACPAUSEVAL       (CLIENTEMACPAUSEVAL),
        .PHY_RX_CLK               (rx_clk_i),
        .GTX_CLK                  (GTX_CLK), //1'b0),
        .GMII_TXD                 (GMII_TXD),
        .GMII_TX_EN               (GMII_TX_EN),
        .GMII_TX_ER               (GMII_TX_ER),
        .GMII_TX_CLK              (GMII_TX_CLK),
        .GMII_RXD                 (GMII_RXD),
        .GMII_RX_DV               (GMII_RX_DV),
        .GMII_RX_ER               (GMII_RX_ER),
        .GMII_RX_CLK              (gmii_rx_clk_bufio),
        .RESET                    (reset_i)
    );

    address_swap_module_8 client_side_asm (
        .rx_ll_clock         (ll_clk_i),
        .rx_ll_reset         (ll_reset_i),
        .rx_ll_data_in       (rx_ll_data_i),
        .rx_ll_sof_in_n      (rx_ll_sof_n_i),
        .rx_ll_eof_in_n      (rx_ll_eof_n_i),
        .rx_ll_src_rdy_in_n  (rx_ll_src_rdy_n_i),
        .rx_ll_data_out      (tx_ll_data_i),
        .rx_ll_sof_out_n     (tx_ll_sof_n_i),
        .rx_ll_eof_out_n     (tx_ll_eof_n_i),
        .rx_ll_src_rdy_out_n (tx_ll_src_rdy_n_i),
        .rx_ll_dst_rdy_in_n  (tx_ll_dst_rdy_n_i)
    );

    assign rx_ll_dst_rdy_n_i = tx_ll_dst_rdy_n_i;

    always @(posedge ll_clk_i, posedge reset_i)
    begin
        if (reset_i == 1'b1)
        begin
            ll_pre_reset_i <= 6'h3F;
            ll_reset_i     <= 1'b1;
        end
        else
        begin
            ll_pre_reset_i[0]   <= 1'b1;
            ll_pre_reset_i[5:1] <= ll_pre_reset_i[4:0];
            ll_reset_i          <= ll_pre_reset_i[5];
        end
    end

    IBUFG refclk_ibufg (
        .I (REFCLK),
        .O (refclk_ibufg_i)
    );

    BUFG refclk_bufg (
        .I (refclk_ibufg_i),
        .O (refclk_bufg_i)
    );

    IBUFG gtx_clk_ibufg (
        .I (GTX_CLK),
        .O (gtx_clk_i)
    );

endmodule