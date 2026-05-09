`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module aur1 #
(
     parameter   SIM_GTPRESET_SPEEDUP=   0      
)
(
    TX_D,
    TX_SRC_RDY_N,
    TX_DST_RDY_N,
    RX_D,
    RX_SRC_RDY_N,
    DO_CC,
    WARN_CC,
    RXP,
    RXN,
    TXP,
    TXN,
   GTPD7,
    HARD_ERROR,
    SOFT_ERROR,
    CHANNEL_UP,
    LANE_UP,
    USER_CLK,
    SYNC_CLK,
    RESET,
    POWER_DOWN,
    LOOPBACK,
    GT_RESET,
    TX_OUT_CLK,
    TX_LOCK,
	 TXDIFF,
	 TXPREEMP
);
`define DLY #1
    input   [0:63]     TX_D;
    input              TX_SRC_RDY_N;
    output             TX_DST_RDY_N;
    output  [0:63]     RX_D;
    output             RX_SRC_RDY_N;
    input              DO_CC;
    input              WARN_CC;
    input   [0:3]      RXP;
    input   [0:3]      RXN;
    output  [0:3]      TXP;
    output  [0:3]      TXN;
    input              GTPD7;
    output             HARD_ERROR;
    output             SOFT_ERROR;
    output             CHANNEL_UP;
    output  [0:3]      LANE_UP;
    input              USER_CLK;
    input              SYNC_CLK;
    input              RESET;
    input              POWER_DOWN;
    input   [2:0]      LOOPBACK;
    input              GT_RESET;
    output             TX_LOCK;    
    output             TX_OUT_CLK;
	input		[2:0]		TXDIFF;
	input		[2:0]		TXPREEMP;
    wire    [15:0]     open_i;
    wire    [0:3]      TX1N_OUT_unused;
    wire    [0:3]      TX1P_OUT_unused;
    wire    [0:3]      RX1N_IN_unused;
    wire    [0:3]      RX1P_IN_unused;
    wire    [3:0]      ch_bond_done_i_unused;   
    wire    [7:0]      rx_char_is_comma_i_unused;   
    wire    [3:0]      rx_buf_err_i_unused;   
    wire    [7:0]      rx_char_is_k_i_unused;   
    wire    [63:0]     rx_data_i_unused;
    wire    [7:0]      rx_disp_err_i_unused;   
    wire    [7:0]      rx_not_in_table_i_unused;   
    wire    [3:0]      rx_realign_i_unused;   
    wire    [3:0]      tx_buf_err_i_unused;   
    wire    [3:0]      ch_bond_done_i;
    wire               channel_up_i;
    wire               en_chan_sync_i;
    wire    [3:0]      ena_comma_align_i;
    wire    [0:3]      gen_a_i;
    wire               gen_cc_i;
    wire               gen_ecp_i;
    wire    [0:7]      gen_k_i;
    wire    [0:3]      gen_pad_i;
    wire    [0:7]      gen_r_i;
    wire               gen_scp_i;
    wire    [0:7]      gen_v_i;
    wire    [0:7]      got_a_i;
    wire    [0:3]      got_v_i;
    wire    [0:3]      hard_error_i;
    wire    [0:3]      lane_up_i;
    wire    [0:3]      raw_tx_out_clk_i;
    wire    [0:3]      reset_lanes_i;
    wire    [3:0]      rx_buf_err_i;
    wire    [7:0]      rx_char_is_comma_i;
    wire    [7:0]      rx_char_is_k_i;
    wire    [11:0]     rx_clk_cor_cnt_i;
    wire    [63:0]     rx_data_i;
    wire    [7:0]      rx_disp_err_i;
    wire    [0:3]      rx_ecp_i;
    wire    [7:0]      rx_not_in_table_i;
    wire    [0:3]      rx_pad_i;
    wire    [0:63]     rx_pe_data_i;
    wire    [0:3]      rx_pe_data_v_i;
    wire    [3:0]      rx_polarity_i;
    wire    [3:0]      rx_realign_i;
    wire    [3:0]      rx_reset_i;
    wire    [0:3]      rx_scp_i;
    wire    [0:3]      soft_error_i;
    wire               start_rx_i;
    wire               tied_to_ground_i;
    wire    [47:0]     tied_to_ground_vec_i;
    wire               tied_to_vcc_i;
    wire    [3:0]      tx_buf_err_i;
    wire    [7:0]      tx_char_is_k_i;
    wire    [63:0]     tx_data_i;
    wire    [0:1]      tx_lock_i;
    wire    [0:63]     tx_pe_data_i;
    wire    [0:3]      tx_pe_data_v_i;
    wire    [3:0]      tx_reset_i;
    reg   [0:3]      ch_bond_load_pulse_i;
    reg   [0:3]      ch_bond_done_dly_i;
    wire             reset_lism_i; 
    wire             reset_done_i; 
    assign          tied_to_ground_vec_i    = 64'd0;
    assign          tied_to_ground_i        = 1'b0;
    assign          tied_to_vcc_i           = 1'b1;
    assign          CHANNEL_UP  =   channel_up_i;
    assign  TX_OUT_CLK  =   raw_tx_out_clk_i[0];
    assign  TX_LOCK =   &tx_lock_i;
    assign          LANE_UP[0] =   lane_up_i[0];
    aur1_AURORA_LANE aurora_lane_0_i
    (
        .RESETDONE(reset_done_i), 
        .RESET_LISM(reset_lism_i), 
        .RX_DATA(rx_data_i[15:0]),
        .RX_NOT_IN_TABLE(rx_not_in_table_i[1:0]),
        .RX_DISP_ERR(rx_disp_err_i[1:0]),
        .RX_CHAR_IS_K(rx_char_is_k_i[1:0]),
        .RX_CHAR_IS_COMMA(rx_char_is_comma_i[1:0]),
        .RX_STATUS(tied_to_ground_vec_i[5:0]),
        .TX_BUF_ERR(tx_buf_err_i[0]),
        .RX_BUF_ERR(rx_buf_err_i[0]),
        .RX_REALIGN(rx_realign_i[0]),
        .RX_POLARITY(rx_polarity_i[0]),
        .RX_RESET(rx_reset_i[0]),
        .TX_CHAR_IS_K(tx_char_is_k_i[1:0]),
        .TX_DATA(tx_data_i[15:0]),
        .TX_RESET(tx_reset_i[0]),
        .ENA_COMMA_ALIGN(ena_comma_align_i[0]),
        .GEN_SCP(gen_scp_i),
        .GEN_ECP(tied_to_ground_i),
        .GEN_PAD(gen_pad_i[0]),
        .TX_PE_DATA(tx_pe_data_i[0:15]),
        .TX_PE_DATA_V(tx_pe_data_v_i[0]),
        .GEN_CC(gen_cc_i),
        .RX_PAD(rx_pad_i[0]),
        .RX_PE_DATA(rx_pe_data_i[0:15]),
        .RX_PE_DATA_V(rx_pe_data_v_i[0]),
        .RX_SCP(rx_scp_i[0]),
        .RX_ECP(rx_ecp_i[0]),
        .GEN_A(gen_a_i[0]),
        .GEN_K(gen_k_i[0:1]),
        .GEN_R(gen_r_i[0:1]),
        .GEN_V(gen_v_i[0:1]),
        .LANE_UP(lane_up_i[0]),
        .SOFT_ERROR(soft_error_i[0]),
        .HARD_ERROR(hard_error_i[0]),
        .CHANNEL_BOND_LOAD(),
        .GOT_A(got_a_i[0:1]),
        .GOT_V(got_v_i[0]),
        .USER_CLK(USER_CLK),
        .RESET(reset_lanes_i[0])
    );
    assign          LANE_UP[1] =   lane_up_i[1];
    aur1_AURORA_LANE aurora_lane_1_i
    (
        .RESETDONE(reset_done_i), 
        .RESET_LISM(reset_lism_i), 
        .RX_DATA(rx_data_i[31:16]),
        .RX_NOT_IN_TABLE(rx_not_in_table_i[3:2]),
        .RX_DISP_ERR(rx_disp_err_i[3:2]),
        .RX_CHAR_IS_K(rx_char_is_k_i[3:2]),
        .RX_CHAR_IS_COMMA(rx_char_is_comma_i[3:2]),
        .RX_STATUS(tied_to_ground_vec_i[5:0]),
        .TX_BUF_ERR(tx_buf_err_i[1]),
        .RX_BUF_ERR(rx_buf_err_i[1]),
        .RX_REALIGN(rx_realign_i[1]),
        .RX_POLARITY(rx_polarity_i[1]),
        .RX_RESET(rx_reset_i[1]),
        .TX_CHAR_IS_K(tx_char_is_k_i[3:2]),
        .TX_DATA(tx_data_i[31:16]),
        .TX_RESET(tx_reset_i[1]),
        .ENA_COMMA_ALIGN(ena_comma_align_i[1]),
        .GEN_SCP(tied_to_ground_i),
        .GEN_ECP(tied_to_ground_i),
        .GEN_PAD(gen_pad_i[1]),
        .TX_PE_DATA(tx_pe_data_i[16:31]),
        .TX_PE_DATA_V(tx_pe_data_v_i[1]),
        .GEN_CC(gen_cc_i),
        .RX_PAD(rx_pad_i[1]),
        .RX_PE_DATA(rx_pe_data_i[16:31]),
        .RX_PE_DATA_V(rx_pe_data_v_i[1]),
        .RX_SCP(rx_scp_i[1]),
        .RX_ECP(rx_ecp_i[1]),
        .GEN_A(gen_a_i[1]),
        .GEN_K(gen_k_i[2:3]),
        .GEN_R(gen_r_i[2:3]),
        .GEN_V(gen_v_i[2:3]),
        .LANE_UP(lane_up_i[1]),
        .SOFT_ERROR(soft_error_i[1]),
        .HARD_ERROR(hard_error_i[1]),
        .CHANNEL_BOND_LOAD(),
        .GOT_A(got_a_i[2:3]),
        .GOT_V(got_v_i[1]),
        .USER_CLK(USER_CLK),
        .RESET(reset_lanes_i[1])
    );
    assign          LANE_UP[2] =   lane_up_i[2];
    aur1_AURORA_LANE aurora_lane_2_i
    (
        .RESETDONE(reset_done_i), 
        .RESET_LISM(reset_lism_i), 
        .RX_DATA(rx_data_i[47:32]),
        .RX_NOT_IN_TABLE(rx_not_in_table_i[5:4]),
        .RX_DISP_ERR(rx_disp_err_i[5:4]),
        .RX_CHAR_IS_K(rx_char_is_k_i[5:4]),
        .RX_CHAR_IS_COMMA(rx_char_is_comma_i[5:4]),
        .RX_STATUS(tied_to_ground_vec_i[5:0]),
        .TX_BUF_ERR(tx_buf_err_i[2]),
        .RX_BUF_ERR(rx_buf_err_i[2]),
        .RX_REALIGN(rx_realign_i[2]),
        .RX_POLARITY(rx_polarity_i[2]),
        .RX_RESET(rx_reset_i[2]),
        .TX_CHAR_IS_K(tx_char_is_k_i[5:4]),
        .TX_DATA(tx_data_i[47:32]),
        .TX_RESET(tx_reset_i[2]),
        .ENA_COMMA_ALIGN(ena_comma_align_i[2]),
        .GEN_SCP(tied_to_ground_i),
        .GEN_ECP(tied_to_ground_i),
        .GEN_PAD(gen_pad_i[2]),
        .TX_PE_DATA(tx_pe_data_i[32:47]),
        .TX_PE_DATA_V(tx_pe_data_v_i[2]),
        .GEN_CC(gen_cc_i),
        .RX_PAD(rx_pad_i[2]),
        .RX_PE_DATA(rx_pe_data_i[32:47]),
        .RX_PE_DATA_V(rx_pe_data_v_i[2]),
        .RX_SCP(rx_scp_i[2]),
        .RX_ECP(rx_ecp_i[2]),
        .GEN_A(gen_a_i[2]),
        .GEN_K(gen_k_i[4:5]),
        .GEN_R(gen_r_i[4:5]),
        .GEN_V(gen_v_i[4:5]),
        .LANE_UP(lane_up_i[2]),
        .SOFT_ERROR(soft_error_i[2]),
        .HARD_ERROR(hard_error_i[2]),
        .CHANNEL_BOND_LOAD(),
        .GOT_A(got_a_i[4:5]),
        .GOT_V(got_v_i[2]),
        .USER_CLK(USER_CLK),
        .RESET(reset_lanes_i[2])
    );
    assign          LANE_UP[3] =   lane_up_i[3];
    aur1_AURORA_LANE aurora_lane_3_i
    (
        .RESETDONE(reset_done_i), 
        .RESET_LISM(reset_lism_i), 
        .RX_DATA(rx_data_i[63:48]),
        .RX_NOT_IN_TABLE(rx_not_in_table_i[7:6]),
        .RX_DISP_ERR(rx_disp_err_i[7:6]),
        .RX_CHAR_IS_K(rx_char_is_k_i[7:6]),
        .RX_CHAR_IS_COMMA(rx_char_is_comma_i[7:6]),
        .RX_STATUS(tied_to_ground_vec_i[5:0]),
        .TX_BUF_ERR(tx_buf_err_i[3]),
        .RX_BUF_ERR(rx_buf_err_i[3]),
        .RX_REALIGN(rx_realign_i[3]),
        .RX_POLARITY(rx_polarity_i[3]),
        .RX_RESET(rx_reset_i[3]),
        .TX_CHAR_IS_K(tx_char_is_k_i[7:6]),
        .TX_DATA(tx_data_i[63:48]),
        .TX_RESET(tx_reset_i[3]),
        .ENA_COMMA_ALIGN(ena_comma_align_i[3]),
        .GEN_SCP(tied_to_ground_i),
        .GEN_ECP(gen_ecp_i),
        .GEN_PAD(gen_pad_i[3]),
        .TX_PE_DATA(tx_pe_data_i[48:63]),
        .TX_PE_DATA_V(tx_pe_data_v_i[3]),
        .GEN_CC(gen_cc_i),
        .RX_PAD(rx_pad_i[3]),
        .RX_PE_DATA(rx_pe_data_i[48:63]),
        .RX_PE_DATA_V(rx_pe_data_v_i[3]),
        .RX_SCP(rx_scp_i[3]),
        .RX_ECP(rx_ecp_i[3]),
        .GEN_A(gen_a_i[3]),
        .GEN_K(gen_k_i[6:7]),
        .GEN_R(gen_r_i[6:7]),
        .GEN_V(gen_v_i[6:7]),
        .LANE_UP(lane_up_i[3]),
        .SOFT_ERROR(soft_error_i[3]),
        .HARD_ERROR(hard_error_i[3]),
        .CHANNEL_BOND_LOAD(),
        .GOT_A(got_a_i[6:7]),
        .GOT_V(got_v_i[3]),
        .USER_CLK(USER_CLK),
        .RESET(reset_lanes_i[3])
    );
    aur1_GTP_WRAPPER #
    (
         .SIM_GTPRESET_SPEEDUP(SIM_GTPRESET_SPEEDUP)
    )
    gtp_wrapper_i
    (
        .RESETDONE(reset_done_i), 
        .RESET_LISM(reset_lism_i), 
        .RXPOLARITY_IN(rx_polarity_i[0]),
        .RXPOLARITY_IN_LANE1(rx_polarity_i[1]),
        .RXPOLARITY_IN_LANE2(rx_polarity_i[2]),
        .RXPOLARITY_IN_LANE3(rx_polarity_i[3]),
        .RXRESET_IN(rx_reset_i[0]),
        .RXRESET_IN_LANE1(rx_reset_i[1]),
        .RXRESET_IN_LANE2(rx_reset_i[2]),
        .RXRESET_IN_LANE3(rx_reset_i[3]),
        .TXCHARISK_IN(tx_char_is_k_i[1:0]),
        .TXCHARISK_IN_LANE1(tx_char_is_k_i[3:2]),
        .TXCHARISK_IN_LANE2(tx_char_is_k_i[5:4]),
        .TXCHARISK_IN_LANE3(tx_char_is_k_i[7:6]),
        .TXDATA_IN(tx_data_i[15:0]),
        .TXDATA_IN_LANE1(tx_data_i[31:16]),
        .TXDATA_IN_LANE2(tx_data_i[47:32]),
        .TXDATA_IN_LANE3(tx_data_i[63:48]),
        .TXRESET_IN(tx_reset_i[0]),
        .TXRESET_IN_LANE1(tx_reset_i[1]),
        .TXRESET_IN_LANE2(tx_reset_i[2]),
        .TXRESET_IN_LANE3(tx_reset_i[3]),
        .RXDATA_OUT(rx_data_i[15:0]),
        .RXDATA_OUT_LANE1(rx_data_i[31:16]),
        .RXDATA_OUT_LANE2(rx_data_i[47:32]),
        .RXDATA_OUT_LANE3(rx_data_i[63:48]),
        .RXNOTINTABLE_OUT(rx_not_in_table_i[1:0]),
        .RXNOTINTABLE_OUT_LANE1(rx_not_in_table_i[3:2]),
        .RXNOTINTABLE_OUT_LANE2(rx_not_in_table_i[5:4]),
        .RXNOTINTABLE_OUT_LANE3(rx_not_in_table_i[7:6]),
        .RXDISPERR_OUT(rx_disp_err_i[1:0]),
        .RXDISPERR_OUT_LANE1(rx_disp_err_i[3:2]),
        .RXDISPERR_OUT_LANE2(rx_disp_err_i[5:4]),
        .RXDISPERR_OUT_LANE3(rx_disp_err_i[7:6]),
        .RXCHARISK_OUT(rx_char_is_k_i[1:0]),
        .RXCHARISK_OUT_LANE1(rx_char_is_k_i[3:2]),
        .RXCHARISK_OUT_LANE2(rx_char_is_k_i[5:4]),
        .RXCHARISK_OUT_LANE3(rx_char_is_k_i[7:6]),
        .RXCHARISCOMMA_OUT(rx_char_is_comma_i[1:0]),
        .RXCHARISCOMMA_OUT_LANE1(rx_char_is_comma_i[3:2]),
        .RXCHARISCOMMA_OUT_LANE2(rx_char_is_comma_i[5:4]),
        .RXCHARISCOMMA_OUT_LANE3(rx_char_is_comma_i[7:6]),
        .RXREALIGN_OUT(rx_realign_i[0]),
        .RXREALIGN_OUT_LANE1(rx_realign_i[1]),
        .RXREALIGN_OUT_LANE2(rx_realign_i[2]),
        .RXREALIGN_OUT_LANE3(rx_realign_i[3]),
        .RXBUFERR_OUT(rx_buf_err_i[0]),
        .RXBUFERR_OUT_LANE1(rx_buf_err_i[1]),
        .RXBUFERR_OUT_LANE2(rx_buf_err_i[2]),
        .RXBUFERR_OUT_LANE3(rx_buf_err_i[3]),
        .TXBUFERR_OUT(tx_buf_err_i[0]),
        .TXBUFERR_OUT_LANE1(tx_buf_err_i[1]),
        .TXBUFERR_OUT_LANE2(tx_buf_err_i[2]),
        .TXBUFERR_OUT_LANE3(tx_buf_err_i[3]),
        .ENMCOMMAALIGN_IN(ena_comma_align_i[0]),
        .ENMCOMMAALIGN_IN_LANE1(ena_comma_align_i[1]),
        .ENMCOMMAALIGN_IN_LANE2(ena_comma_align_i[2]),
        .ENMCOMMAALIGN_IN_LANE3(ena_comma_align_i[3]),
        .ENPCOMMAALIGN_IN(ena_comma_align_i[0]),
        .ENPCOMMAALIGN_IN_LANE1(ena_comma_align_i[1]),
        .ENPCOMMAALIGN_IN_LANE2(ena_comma_align_i[2]),
        .ENPCOMMAALIGN_IN_LANE3(ena_comma_align_i[3]),
        .RXRECCLK1_OUT(),
        .RXRECCLK1_OUT_LANE1(),
        .RXRECCLK1_OUT_LANE2(),
        .RXRECCLK1_OUT_LANE3(),
        .RXRECCLK2_OUT(),
        .RXRECCLK2_OUT_LANE1(),
        .RXRECCLK2_OUT_LANE2(),
        .RXRECCLK2_OUT_LANE3(),
        .ENCHANSYNC_IN(tied_to_vcc_i),
        .ENCHANSYNC_IN_LANE1(en_chan_sync_i),
        .ENCHANSYNC_IN_LANE2(tied_to_vcc_i),
        .ENCHANSYNC_IN_LANE3(tied_to_vcc_i),
        .CHBONDDONE_OUT(ch_bond_done_i[0]),
        .CHBONDDONE_OUT_LANE1(ch_bond_done_i[1]),
        .CHBONDDONE_OUT_LANE2(ch_bond_done_i[2]),
        .CHBONDDONE_OUT_LANE3(ch_bond_done_i[3]),
        .RX1N_IN(RXN[0]),
        .RX1N_IN_LANE1(RXN[1]),
        .RX1N_IN_LANE2(RXN[2]),
        .RX1N_IN_LANE3(RXN[3]),
        .RX1P_IN(RXP[0]),
        .RX1P_IN_LANE1(RXP[1]),
        .RX1P_IN_LANE2(RXP[2]),
        .RX1P_IN_LANE3(RXP[3]),
        .TX1N_OUT(TXN[0]),
        .TX1N_OUT_LANE1(TXN[1]),
        .TX1N_OUT_LANE2(TXN[2]),
        .TX1N_OUT_LANE3(TXN[3]),
        .TX1P_OUT(TXP[0]),
        .TX1P_OUT_LANE1(TXP[1]),
        .TX1P_OUT_LANE2(TXP[2]),
        .TX1P_OUT_LANE3(TXP[3]),
        .RXUSRCLK_IN(SYNC_CLK),
        .RXUSRCLK2_IN(USER_CLK),
        .TXUSRCLK_IN(SYNC_CLK),
        .TXUSRCLK2_IN(USER_CLK), 
        .REFCLK(GTPD7),
        .TXOUTCLK1_OUT(raw_tx_out_clk_i[0]),
        .TXOUTCLK2_OUT(),
        .TXOUTCLK1_OUT_LANE1(raw_tx_out_clk_i[1]),
        .TXOUTCLK2_OUT_LANE1(),
        .TXOUTCLK1_OUT_LANE2(raw_tx_out_clk_i[2]),
        .TXOUTCLK2_OUT_LANE2(),
        .TXOUTCLK1_OUT_LANE3(raw_tx_out_clk_i[3]),
        .TXOUTCLK2_OUT_LANE3(),
        .PLLLKDET_OUT(tx_lock_i[0]),
        .PLLLKDET_OUT_LANE1(tx_lock_i[1]),
        .REFCLKOUT_OUT(),
        .REFCLKOUT_OUT_LANE1(),
        .GTPRESET_IN(GT_RESET),
        .LOOPBACK_IN(LOOPBACK),
		  .TXDIFF(TXDIFF),
		  .TXPREEMP(TXPREEMP),		
        .POWERDOWN_IN(POWER_DOWN)
    );
 always @(posedge USER_CLK)
                if (RESET)
                ch_bond_done_dly_i <= 2'b0;
                else if (en_chan_sync_i)
                     ch_bond_done_dly_i <= ch_bond_done_i;
                     else
                          ch_bond_done_dly_i <= 2'b0;
 always @(posedge USER_CLK)
           if (RESET)
                ch_bond_load_pulse_i <= 2'b0;
           else if(en_chan_sync_i)
                ch_bond_load_pulse_i <= ch_bond_done_i & ~ch_bond_done_dly_i;
           else
                   ch_bond_load_pulse_i <= 2'b00;
    aur1_GLOBAL_LOGIC    global_logic_i
    (
        .CH_BOND_DONE(ch_bond_done_i),
        .EN_CHAN_SYNC(en_chan_sync_i),
        .LANE_UP(lane_up_i),
        .SOFT_ERROR(soft_error_i),
        .HARD_ERROR(hard_error_i),
        .CHANNEL_BOND_LOAD(ch_bond_load_pulse_i),
        .GOT_A(got_a_i),
        .GOT_V(got_v_i),
        .GEN_A(gen_a_i),
        .GEN_K(gen_k_i),
        .GEN_R(gen_r_i),
        .GEN_V(gen_v_i),
        .RESET_LANES(reset_lanes_i),
        .USER_CLK(USER_CLK),
        .RESET(RESET),
        .POWER_DOWN(POWER_DOWN),
        .CHANNEL_UP(channel_up_i),
        .START_RX(start_rx_i),
        .CHANNEL_SOFT_ERROR(SOFT_ERROR),
        .CHANNEL_HARD_ERROR(HARD_ERROR)
    );
    aur1_TX_STREAM tx_stream_i
    (
        .TX_D(TX_D),
        .TX_SRC_RDY_N(TX_SRC_RDY_N),
        .TX_DST_RDY_N(TX_DST_RDY_N),
        .CHANNEL_UP(channel_up_i),
        .DO_CC(DO_CC),
        .WARN_CC(WARN_CC),
        .GEN_SCP(gen_scp_i),
        .GEN_ECP(gen_ecp_i),
        .TX_PE_DATA_V(tx_pe_data_v_i),
        .GEN_PAD(gen_pad_i),
        .TX_PE_DATA(tx_pe_data_i),
        .GEN_CC(gen_cc_i),
        .USER_CLK(USER_CLK)
    );
    aur1_RX_STREAM rx_stream_i
    (
        .RX_D(RX_D),
        .RX_SRC_RDY_N(RX_SRC_RDY_N),
        .START_RX(start_rx_i),
        .RX_PAD(rx_pad_i),
        .RX_PE_DATA(rx_pe_data_i),
        .RX_PE_DATA_V(rx_pe_data_v_i),
        .RX_SCP(rx_scp_i),
        .RX_ECP(rx_ecp_i),
        .USER_CLK(USER_CLK)
    );
endmodule
