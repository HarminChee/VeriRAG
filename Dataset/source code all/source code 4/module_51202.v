`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module emac_single_locallink
(
    TX_CLK_OUT,
    TX_CLK_0,
    RX_LL_CLOCK_0,
    RX_LL_RESET_0,
    RX_LL_DATA_0,
    RX_LL_SOF_N_0,
    RX_LL_EOF_N_0,
    RX_LL_SRC_RDY_N_0,
    RX_LL_DST_RDY_N_0,
    RX_LL_FIFO_STATUS_0,
    TX_LL_CLOCK_0,
    TX_LL_RESET_0,
    TX_LL_DATA_0,
    TX_LL_SOF_N_0,
    TX_LL_EOF_N_0,
    TX_LL_SRC_RDY_N_0,
    TX_LL_DST_RDY_N_0,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,
    CLIENTEMAC0TXIFGDELAY,
    EMAC0CLIENTTXSTATS,
    EMAC0CLIENTTXSTATSVLD,
    EMAC0CLIENTTXSTATSBYTEVLD,
    CLIENTEMAC0PAUSEREQ,
    CLIENTEMAC0PAUSEVAL,
    GTX_CLK_0,
    GMII_TXD_0,
    GMII_TX_EN_0,
    GMII_TX_ER_0,
    GMII_TX_CLK_0,
    GMII_RXD_0,
    GMII_RX_DV_0,
    GMII_RX_ER_0,
    GMII_RX_CLK_0 ,
    RESET
);
    output          TX_CLK_OUT;
    input           TX_CLK_0;
    input           RX_LL_CLOCK_0;
    input           RX_LL_RESET_0;
    output   [7:0]  RX_LL_DATA_0;
    output          RX_LL_SOF_N_0;
    output          RX_LL_EOF_N_0;
    output          RX_LL_SRC_RDY_N_0;
    input           RX_LL_DST_RDY_N_0;
    output   [3:0]  RX_LL_FIFO_STATUS_0;
    input           TX_LL_CLOCK_0;
    input           TX_LL_RESET_0;
    input    [7:0]  TX_LL_DATA_0;
    input           TX_LL_SOF_N_0;
    input           TX_LL_EOF_N_0;
    input           TX_LL_SRC_RDY_N_0;
    output          TX_LL_DST_RDY_N_0;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;
    input    [7:0]  CLIENTEMAC0TXIFGDELAY;
    output          EMAC0CLIENTTXSTATS;
    output          EMAC0CLIENTTXSTATSVLD;
    output          EMAC0CLIENTTXSTATSBYTEVLD;
    input           CLIENTEMAC0PAUSEREQ;
    input   [15:0]  CLIENTEMAC0PAUSEVAL;
    input           GTX_CLK_0;
    output   [7:0]  GMII_TXD_0;
    output          GMII_TX_EN_0;
    output          GMII_TX_ER_0;
    output          GMII_TX_CLK_0;
    input    [7:0]  GMII_RXD_0;
    input           GMII_RX_DV_0;
    input           GMII_RX_ER_0;
    input           GMII_RX_CLK_0 ;
    input           RESET;
    wire            reset_i;
    wire            tx_clk_0_i;
    wire            rx_clk_0_i;
    wire     [7:0]  tx_data_0_i;
    wire            tx_data_valid_0_i;
    wire            tx_underrun_0_i;
    wire            tx_ack_0_i;
    wire            tx_collision_0_i;
    wire            tx_retransmit_0_i;
    wire     [7:0]  rx_data_0_i;
    wire            rx_data_valid_0_i;
    wire            rx_good_frame_0_i;
    wire            rx_bad_frame_0_i;
    reg      [7:0]  rx_data_0_r;
    reg             rx_data_valid_0_r;
    reg             rx_good_frame_0_r;
    reg             rx_bad_frame_0_r;   
    reg       [5:0] tx_pre_reset_0_i;
    reg             tx_reset_0_i;
    reg       [5:0] rx_pre_reset_0_i;
    reg             rx_reset_0_i;    
    assign reset_i = RESET; 
    emac_single_block v5_emac_block_inst
    (
    .TX_CLK_OUT                          (TX_CLK_OUT),
    .TX_CLK_0                            (TX_CLK_0),
    .EMAC0CLIENTRXD                      (rx_data_0_i),
    .EMAC0CLIENTRXDVLD                   (rx_data_valid_0_i),
    .EMAC0CLIENTRXGOODFRAME              (rx_good_frame_0_i),
    .EMAC0CLIENTRXBADFRAME               (rx_bad_frame_0_i),
    .EMAC0CLIENTRXFRAMEDROP              (EMAC0CLIENTRXFRAMEDROP),
    .EMAC0CLIENTRXSTATS                  (EMAC0CLIENTRXSTATS),
    .EMAC0CLIENTRXSTATSVLD               (EMAC0CLIENTRXSTATSVLD),
    .EMAC0CLIENTRXSTATSBYTEVLD           (EMAC0CLIENTRXSTATSBYTEVLD),
    .CLIENTEMAC0TXD                      (tx_data_0_i),
    .CLIENTEMAC0TXDVLD                   (tx_data_valid_0_i),
    .EMAC0CLIENTTXACK                    (tx_ack_0_i),
    .CLIENTEMAC0TXFIRSTBYTE              (1'b0),
    .CLIENTEMAC0TXUNDERRUN               (tx_underrun_0_i),
    .EMAC0CLIENTTXCOLLISION              (tx_collision_0_i),
    .EMAC0CLIENTTXRETRANSMIT             (tx_retransmit_0_i),
    .CLIENTEMAC0TXIFGDELAY               (CLIENTEMAC0TXIFGDELAY),
    .EMAC0CLIENTTXSTATS                  (EMAC0CLIENTTXSTATS),
    .EMAC0CLIENTTXSTATSVLD               (EMAC0CLIENTTXSTATSVLD),
    .EMAC0CLIENTTXSTATSBYTEVLD           (EMAC0CLIENTTXSTATSBYTEVLD),
    .CLIENTEMAC0PAUSEREQ                 (CLIENTEMAC0PAUSEREQ),
    .CLIENTEMAC0PAUSEVAL                 (CLIENTEMAC0PAUSEVAL),
    .GTX_CLK_0                           (GTX_CLK_0),
    .GMII_TXD_0                          (GMII_TXD_0),
    .GMII_TX_EN_0                        (GMII_TX_EN_0),
    .GMII_TX_ER_0                        (GMII_TX_ER_0),
    .GMII_TX_CLK_0                       (GMII_TX_CLK_0),
    .GMII_RXD_0                          (GMII_RXD_0),
    .GMII_RX_DV_0                        (GMII_RX_DV_0),
    .GMII_RX_ER_0                        (GMII_RX_ER_0),
    .GMII_RX_CLK_0                       (GMII_RX_CLK_0),
    .RESET                               (reset_i));
  eth_fifo_8 client_side_FIFO_emac0 (
     .tx_clk(tx_clk_0_i),
     .tx_reset(tx_reset_0_i),
     .tx_enable(1'b1),
     .tx_data(tx_data_0_i),
     .tx_data_valid(tx_data_valid_0_i),
     .tx_ack(tx_ack_0_i),
     .tx_underrun(tx_underrun_0_i),
     .tx_collision(tx_collision_0_i),
     .tx_retransmit(tx_retransmit_0_i),
     .tx_ll_clock(TX_LL_CLOCK_0),
     .tx_ll_reset(TX_LL_RESET_0),
     .tx_ll_data_in(TX_LL_DATA_0),
     .tx_ll_sof_in_n(TX_LL_SOF_N_0),
     .tx_ll_eof_in_n(TX_LL_EOF_N_0),
     .tx_ll_src_rdy_in_n(TX_LL_SRC_RDY_N_0),
     .tx_ll_dst_rdy_out_n(TX_LL_DST_RDY_N_0),
     .tx_fifo_status(),
     .tx_overflow(),
     .rx_clk(rx_clk_0_i),
     .rx_reset(rx_reset_0_i),
     .rx_enable(1'b1),
     .rx_data(rx_data_0_r),
     .rx_data_valid(rx_data_valid_0_r),
     .rx_good_frame(rx_good_frame_0_r),
     .rx_bad_frame(rx_bad_frame_0_r),
     .rx_overflow(),
     .rx_ll_clock(RX_LL_CLOCK_0),
     .rx_ll_reset(RX_LL_RESET_0),
     .rx_ll_data_out(RX_LL_DATA_0),
     .rx_ll_sof_out_n(RX_LL_SOF_N_0),
     .rx_ll_eof_out_n(RX_LL_EOF_N_0),
     .rx_ll_src_rdy_out_n(RX_LL_SRC_RDY_N_0),
     .rx_ll_dst_rdy_in_n(RX_LL_DST_RDY_N_0),
     .rx_fifo_status(RX_LL_FIFO_STATUS_0));
  always @(posedge tx_clk_0_i, posedge reset_i)
  begin
    if (reset_i === 1'b1)
    begin
      tx_pre_reset_0_i <= 6'h3F;
      tx_reset_0_i     <= 1'b1;
    end
    else
    begin
        tx_pre_reset_0_i[0]   <= 1'b0;
        tx_pre_reset_0_i[5:1] <= tx_pre_reset_0_i[4:0];
        tx_reset_0_i          <= tx_pre_reset_0_i[5];
      end
  end
always @(posedge rx_clk_0_i, posedge reset_i)
  begin
    if (reset_i === 1'b1)
    begin
      rx_pre_reset_0_i <= 6'h3F;
      rx_reset_0_i     <= 1'b1;
    end
    else
    begin
        rx_pre_reset_0_i[0]   <= 1'b0;
        rx_pre_reset_0_i[5:1] <= rx_pre_reset_0_i[4:0];
        rx_reset_0_i          <= rx_pre_reset_0_i[5];
      end
  end
  always @(posedge rx_clk_0_i, posedge reset_i)
  begin
    if (reset_i == 1'b1)
    begin
      rx_data_valid_0_r <= 1'b0;
      rx_data_0_r       <= 8'h00;
      rx_good_frame_0_r <= 1'b0;
      rx_bad_frame_0_r  <= 1'b0;
    end
    else
    begin
        rx_data_0_r       <= rx_data_0_i;
        rx_data_valid_0_r <= rx_data_valid_0_i;
        rx_good_frame_0_r <= rx_good_frame_0_i;
        rx_bad_frame_0_r  <= rx_bad_frame_0_i;
      end
  end
    assign EMAC0CLIENTRXDVLD = rx_data_valid_0_i;
    assign tx_clk_0_i = TX_CLK_0;
    assign rx_clk_0_i = GMII_RX_CLK_0;
endmodule
