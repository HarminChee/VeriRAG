`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module v6_emac_v1_5_locallink
(
    TX_CLK_OUT,
    TX_CLK,
    RX_LL_CLOCK,
    RX_LL_RESET,
    RX_LL_DATA,
    RX_LL_SOF_N,
    RX_LL_EOF_N,
    RX_LL_SRC_RDY_N,
    RX_LL_DST_RDY_N,
    RX_LL_FIFO_STATUS,
    TX_LL_CLOCK,
    TX_LL_RESET,
    TX_LL_DATA,
    TX_LL_SOF_N,
    TX_LL_EOF_N,
    TX_LL_SRC_RDY_N,
    TX_LL_DST_RDY_N,
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
    PHY_RX_CLK,
    GTX_CLK,
    GMII_TXD,
    GMII_TX_EN,
    GMII_TX_ER,
    GMII_TX_CLK,
    GMII_RXD,
    GMII_RX_DV,
    GMII_RX_ER,
    GMII_RX_CLK,
    RESET
);
    output          TX_CLK_OUT;
    input           TX_CLK;
    input           RX_LL_CLOCK;
    input           RX_LL_RESET;
    output   [7:0]  RX_LL_DATA;
    output          RX_LL_SOF_N;
    output          RX_LL_EOF_N;
    output          RX_LL_SRC_RDY_N;
    input           RX_LL_DST_RDY_N;
    output   [3:0]  RX_LL_FIFO_STATUS;
    input           TX_LL_CLOCK;
    input           TX_LL_RESET;
    input    [7:0]  TX_LL_DATA;
    input           TX_LL_SOF_N;
    input           TX_LL_EOF_N;
    input           TX_LL_SRC_RDY_N;
    output          TX_LL_DST_RDY_N;
    output          EMACCLIENTRXDVLD;
    output          EMACCLIENTRXFRAMEDROP;
    output   [6:0]  EMACCLIENTRXSTATS;
    output          EMACCLIENTRXSTATSVLD;
    output          EMACCLIENTRXSTATSBYTEVLD;
    input    [7:0]  CLIENTEMACTXIFGDELAY;
    output          EMACCLIENTTXSTATS;
    output          EMACCLIENTTXSTATSVLD;
    output          EMACCLIENTTXSTATSBYTEVLD;
    input           CLIENTEMACPAUSEREQ;
    input   [15:0]  CLIENTEMACPAUSEVAL;
    input           PHY_RX_CLK;
    input           GTX_CLK;
    output   [7:0]  GMII_TXD;
    output          GMII_TX_EN;
    output          GMII_TX_ER;
    output          GMII_TX_CLK;
    input    [7:0]  GMII_RXD;
    input           GMII_RX_DV;
    input           GMII_RX_ER;
    input           GMII_RX_CLK;
    input           RESET;
    wire            reset_i;
    wire            tx_clk_i;
    wire            rx_clk_i;
    wire     [7:0]  tx_data_i;
    wire            tx_data_valid_i;
    wire            tx_underrun_i;
    wire            tx_ack_i;
    wire            tx_collision_i;
    wire            tx_retransmit_i;
    wire     [7:0]  rx_data_i;
    wire            rx_data_valid_i;
    wire            rx_good_frame_i;
    wire            rx_bad_frame_i;
    reg      [7:0]  rx_data_r;
    reg             rx_data_valid_r;
    reg             rx_good_frame_r;
    reg             rx_bad_frame_r;
    reg       [5:0] tx_pre_reset_i;
    reg             tx_reset_i;
    reg       [5:0] rx_pre_reset_i;
    reg             rx_reset_i;
    assign reset_i = RESET;
    v6_emac_v1_5_block v6_emac_v1_5_block_inst
    (
    .TX_CLK_OUT               (TX_CLK_OUT),
    .TX_CLK                   (TX_CLK),
    .EMACCLIENTRXD            (rx_data_i),
    .EMACCLIENTRXDVLD         (rx_data_valid_i),
    .EMACCLIENTRXGOODFRAME    (rx_good_frame_i),
    .EMACCLIENTRXBADFRAME     (rx_bad_frame_i),
    .EMACCLIENTRXFRAMEDROP    (EMACCLIENTRXFRAMEDROP),
    .EMACCLIENTRXSTATS        (EMACCLIENTRXSTATS),
    .EMACCLIENTRXSTATSVLD     (EMACCLIENTRXSTATSVLD),
    .EMACCLIENTRXSTATSBYTEVLD (EMACCLIENTRXSTATSBYTEVLD),
    .CLIENTEMACTXD            (tx_data_i),
    .CLIENTEMACTXDVLD         (tx_data_valid_i),
    .EMACCLIENTTXACK          (tx_ack_i),
    .CLIENTEMACTXFIRSTBYTE    (1'b0),
    .CLIENTEMACTXUNDERRUN     (tx_underrun_i),
    .EMACCLIENTTXCOLLISION    (tx_collision_i),
    .EMACCLIENTTXRETRANSMIT   (tx_retransmit_i),
    .CLIENTEMACTXIFGDELAY     (CLIENTEMACTXIFGDELAY),
    .EMACCLIENTTXSTATS        (EMACCLIENTTXSTATS),
    .EMACCLIENTTXSTATSVLD     (EMACCLIENTTXSTATSVLD),
    .EMACCLIENTTXSTATSBYTEVLD (EMACCLIENTTXSTATSBYTEVLD),
    .CLIENTEMACPAUSEREQ       (CLIENTEMACPAUSEREQ),
    .CLIENTEMACPAUSEVAL       (CLIENTEMACPAUSEVAL),
    .PHY_RX_CLK               (PHY_RX_CLK),
    .GTX_CLK                  (GTX_CLK),
    .GMII_TXD                 (GMII_TXD),
    .GMII_TX_EN               (GMII_TX_EN),
    .GMII_TX_ER               (GMII_TX_ER),
    .GMII_TX_CLK              (GMII_TX_CLK),
    .GMII_RXD                 (GMII_RXD),
    .GMII_RX_DV               (GMII_RX_DV),
    .GMII_RX_ER               (GMII_RX_ER),
    .GMII_RX_CLK              (GMII_RX_CLK),
    .RESET                    (reset_i)
    );
  eth_fifo_8 client_side_FIFO (
     .tx_clk              (tx_clk_i),
     .tx_reset            (tx_reset_i),
     .tx_enable           (1'b1),
     .tx_data             (tx_data_i),
     .tx_data_valid       (tx_data_valid_i),
     .tx_ack              (tx_ack_i),
     .tx_underrun         (tx_underrun_i),
     .tx_collision        (tx_collision_i),
     .tx_retransmit       (tx_retransmit_i),
     .tx_ll_clock         (TX_LL_CLOCK),
     .tx_ll_reset         (TX_LL_RESET),
     .tx_ll_data_in       (TX_LL_DATA),
     .tx_ll_sof_in_n      (TX_LL_SOF_N),
     .tx_ll_eof_in_n      (TX_LL_EOF_N),
     .tx_ll_src_rdy_in_n  (TX_LL_SRC_RDY_N),
     .tx_ll_dst_rdy_out_n (TX_LL_DST_RDY_N),
     .tx_fifo_status      (),
     .tx_overflow         (),
     .rx_clk              (rx_clk_i),
     .rx_reset            (rx_reset_i),
     .rx_enable           (1'b1),
     .rx_data             (rx_data_r),
     .rx_data_valid       (rx_data_valid_r),
     .rx_good_frame       (rx_good_frame_r),
     .rx_bad_frame        (rx_bad_frame_r),
     .rx_overflow         (),
     .rx_ll_clock         (RX_LL_CLOCK),
     .rx_ll_reset         (RX_LL_RESET),
     .rx_ll_data_out      (RX_LL_DATA),
     .rx_ll_sof_out_n     (RX_LL_SOF_N),
     .rx_ll_eof_out_n     (RX_LL_EOF_N),
     .rx_ll_src_rdy_out_n (RX_LL_SRC_RDY_N),
     .rx_ll_dst_rdy_in_n  (RX_LL_DST_RDY_N),
     .rx_fifo_status      (RX_LL_FIFO_STATUS)
  );
  always @(posedge tx_clk_i, posedge reset_i)
  begin
    if (reset_i === 1'b1)
    begin
      tx_pre_reset_i <= 6'h3F;
      tx_reset_i     <= 1'b1;
    end
    else
    begin
        tx_pre_reset_i[0]   <= 1'b0;
        tx_pre_reset_i[5:1] <= tx_pre_reset_i[4:0];
        tx_reset_i          <= tx_pre_reset_i[5];
      end
  end
  always @(posedge rx_clk_i, posedge reset_i)
  begin
    if (reset_i === 1'b1)
    begin
      rx_pre_reset_i <= 6'h3F;
      rx_reset_i     <= 1'b1;
    end
    else
    begin
        rx_pre_reset_i[0]   <= 1'b0;
        rx_pre_reset_i[5:1] <= rx_pre_reset_i[4:0];
        rx_reset_i          <= rx_pre_reset_i[5];
      end
  end
  always @(posedge rx_clk_i, posedge reset_i)
  begin
    if (reset_i == 1'b1)
    begin
      rx_data_valid_r <= 1'b0;
      rx_data_r       <= 8'h00;
      rx_good_frame_r <= 1'b0;
      rx_bad_frame_r  <= 1'b0;
    end
    else
    begin
        rx_data_r       <= rx_data_i;
        rx_data_valid_r <= rx_data_valid_i;
        rx_good_frame_r <= rx_good_frame_i;
        rx_bad_frame_r  <= rx_bad_frame_i;
      end
  end
  assign EMACCLIENTRXDVLD = rx_data_valid_i;
  assign tx_clk_i = TX_CLK;
  assign rx_clk_i = PHY_RX_CLK;
endmodule
