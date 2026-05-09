`timescale 1 ns / 10 ps

module icon 
  (
      control0
  );
  output [35:0] control0;
endmodule

module ila
  (
    control,
    clk,
    trig0
  );
  input [35:0] control;
  input clk;
  input [47:0] trig0;
endmodule

module aurora_201_pcore #
(
    parameter   SIM_GTPRESET_SPEEDUP = 0,      
    parameter   C_EXT_RESET_HIGH = 0
)
(
    input  wire         test_i,
    input  wire         RESET,
    output wire         USER_CLK,
    input  wire         INIT_CLK,
    input  wire         PMA_INIT,
    output wire         HARD_ERROR,
    output wire         SOFT_ERROR,
    output wire         LANE_UP,
    output wire         CHANNEL_UP,
    input  wire [0:15]  TX_D,
    input  wire         TX_SRC_RDY,
    output wire         TX_DST_RDY,
    output wire [0:15]  RX_D,
    output wire         RX_SRC_RDY,
    input  wire         GTPD4_P,
    input  wire         GTPD4_N,
    input  wire         RXP,
    input  wire         RXN,
    output wire         TXP,
    output wire         TXN
);
    reg                HARD_ERROR_reg;
    reg                SOFT_ERROR_reg;
    reg                LANE_UP_reg;
    reg                CHANNEL_UP_reg;
    reg     [0:3]      reset_debounce_r;
    reg     [0:3]      debounce_pma_init_r;
    wire   [255:0]     ila_data_i;
    wire   [35:0]      icon_ila_i;
    wire    [0:15]     tx_d_i;
    wire               tx_src_rdy_n_i;
    wire               tx_dst_rdy_n_i;
    wire    [0:15]     rx_d_i;
    wire               rx_src_rdy_n_i;
    wire               GTPD4_left_i;
    wire               hard_error_i;
    wire               soft_error_i;
    wire               channel_up_i;
    wire               lane_up_i;
    wire               warn_cc_i;
    wire               do_cc_i;
    wire               dcm_not_locked_i;
    wire               user_clk_i;
    wire               sync_clk_i;
    wire               reset_i;
    wire               power_down_i;
    wire    [0:2]      loopback_i;
    wire               tx_lock_i;
    wire               tx_out_clk_i;
    wire               buf_tx_out_clk_i;
    wire               init_clk_i;
    wire               pma_init_r; 
    wire               dft_user_clk;
    wire               dft_reset;

    IBUFDS IBUFDS_inst
    (
        .I(GTPD4_P),
        .IB(GTPD4_N),
        .O(GTPD4_left_i)
    );

    BUFG BUFG_inst
    (
        .I(tx_out_clk_i),
        .O(buf_tx_out_clk_i)
    );

    aurora_201_CLOCK_MODULE clock_module_i
    (
        .GTP_CLK(buf_tx_out_clk_i),
        .GTP_CLK_LOCKED(tx_lock_i),
        .USER_CLK(user_clk_i),
        .SYNC_CLK(sync_clk_i),
        .DCM_NOT_LOCKED(dcm_not_locked_i)
    );

    assign dft_user_clk = test_i ? INIT_CLK : user_clk_i;
    assign dft_reset = test_i ? RESET : reset_i;

    always @(posedge dft_user_clk or posedge dft_reset)
    begin
        if (dft_reset) begin
            HARD_ERROR_reg  <=  1'b0;
            SOFT_ERROR_reg  <=  1'b0;
            LANE_UP_reg     <=  1'b0;
            CHANNEL_UP_reg  <=  1'b0;
        end else begin
            HARD_ERROR_reg  <=  hard_error_i;
            SOFT_ERROR_reg  <=  soft_error_i;
            LANE_UP_reg     <=  lane_up_i;
            CHANNEL_UP_reg  <=  channel_up_i;
        end
    end

    assign HARD_ERROR = HARD_ERROR_reg;
    assign SOFT_ERROR = SOFT_ERROR_reg;
    assign LANE_UP = LANE_UP_reg;
    assign CHANNEL_UP = CHANNEL_UP_reg;

    assign tx_src_rdy_n_i = ~TX_SRC_RDY;
    assign TX_DST_RDY = ~tx_dst_rdy_n_i;
    assign RX_SRC_RDY = ~rx_src_rdy_n_i;
    assign tx_d_i = TX_D;
    assign RX_D = rx_d_i;
    assign USER_CLK = user_clk_i;
    assign power_down_i = 1'b0;
    assign loopback_i = 3'b000;

    always @(posedge dft_user_clk or posedge dft_reset)
        if (dft_reset)
            reset_debounce_r <= 4'b1111;    
        else
            reset_debounce_r <= {RESET, reset_debounce_r[0:2]}; 

    assign reset_i = &reset_debounce_r;
    assign init_clk_i = INIT_CLK;

    always @(posedge init_clk_i or posedge PMA_INIT)
        if (PMA_INIT)
            debounce_pma_init_r <= 4'b1111;
        else
            debounce_pma_init_r <= {PMA_INIT, debounce_pma_init_r[0:2]};

    assign pma_init_r = &debounce_pma_init_r;

    aurora_201 #
    (
        .SIM_GTPRESET_SPEEDUP(SIM_GTPRESET_SPEEDUP)
    )
    aurora_module_i
    (
        .TX_D(tx_d_i),
        .TX_SRC_RDY_N(tx_src_rdy_n_i),
        .TX_DST_RDY_N(tx_dst_rdy_n_i),
        .RX_D(rx_d_i),
        .RX_SRC_RDY_N(rx_src_rdy_n_i),
        .RXP(RXP),
        .RXN(RXN),
        .TXP(TXP),
        .TXN(TXN),
        .GTPD4(GTPD4_left_i),
        .HARD_ERROR(hard_error_i),
        .SOFT_ERROR(soft_error_i),
        .CHANNEL_UP(channel_up_i),
        .LANE_UP(lane_up_i),
        .WARN_CC(warn_cc_i),
        .DO_CC(do_cc_i),
        .DCM_NOT_LOCKED(dcm_not_locked_i),
        .USER_CLK(user_clk_i),
        .SYNC_CLK(sync_clk_i),
        .RESET(dft_reset),
        .POWER_DOWN(power_down_i),
        .LOOPBACK(loopback_i),
        .PMA_INIT(pma_init_r),
        .TX_LOCK(tx_lock_i),
        .TX_OUT_CLK(tx_out_clk_i)
    );

    aurora_201_STANDARD_CC_MODULE standard_cc_module_i
    (
        .WARN_CC(warn_cc_i),
        .DO_CC(do_cc_i),
        .DCM_NOT_LOCKED(dcm_not_locked_i),
        .USER_CLK(user_clk_i),
        .CHANNEL_UP(channel_up_i)
    );

    wire [35:0] control0;
endmodule