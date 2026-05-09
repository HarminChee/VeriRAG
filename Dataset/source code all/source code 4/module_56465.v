`timescale 1 ns / 10 ps
`timescale 1 ns / 10 ps
module CHANNEL_INIT_SM
(
    CH_BOND_DONE,
    EN_CHAN_SYNC,
    CHANNEL_BOND_LOAD,
    GOT_A,
    GOT_V,
    RESET_LANES,
    USER_CLK,
    RESET,
    CHANNEL_UP,
    START_RX,
    DID_VER,
    GEN_VER,
    RESET_CHANNEL
);
`define DLY #1
    input              CH_BOND_DONE;
    output             EN_CHAN_SYNC;
    input              CHANNEL_BOND_LOAD;
    input   [0:3]      GOT_A;
    input              GOT_V;
    output             RESET_LANES;
    input              USER_CLK;
    input              RESET;
    output             CHANNEL_UP;
    output             START_RX;
    input              DID_VER;
    output             GEN_VER;
    input              RESET_CHANNEL;
    reg             START_RX;
    reg             free_count_done_r;
    reg     [0:15]  verify_watchdog_r;
    reg             all_lanes_v_r;
    reg             got_first_v_r;
    reg     [0:15]  v_count_r;
    reg             bad_v_r;
    reg     [0:2]   rxver_count_r;
    reg     [0:7]   txver_count_r;
    reg             wait_for_lane_up_r;
    reg             verify_r;
    reg             ready_r;
    wire            free_count_1_r;
    wire            free_count_2_r;
    wire            insert_ver_c;
    wire            verify_watchdog_done_r;
    wire            rxver_3d_done_r;
    wire            txver_8d_done_r;
    wire            reset_lanes_c;
    wire            next_verify_c;
    wire            next_ready_c;
    always @(posedge USER_CLK)
        if(RESET|RESET_CHANNEL)
        begin
            wait_for_lane_up_r <=  `DLY    1'b1;
            verify_r           <=  `DLY    1'b0;
            ready_r            <=  `DLY    1'b0;
        end
        else
        begin
            wait_for_lane_up_r <=  `DLY    1'b0;
            verify_r           <=  `DLY    next_verify_c;
            ready_r            <=  `DLY    next_ready_c;
        end
    assign  next_verify_c       =   wait_for_lane_up_r |
                                    (verify_r & (!rxver_3d_done_r|!txver_8d_done_r));
    assign  next_ready_c        =   (verify_r & txver_8d_done_r & rxver_3d_done_r)|
                                    ready_r;
    assign  CHANNEL_UP          =   ready_r;
    always @(posedge USER_CLK)
        if(RESET)   START_RX    <=  `DLY    1'b0;
        else        START_RX    <=  `DLY    !wait_for_lane_up_r;
    assign  GEN_VER             =   verify_r;
    assign reset_lanes_c =              (verify_r & verify_watchdog_done_r)|
                                        (verify_r & bad_v_r & !rxver_3d_done_r)|
                                        (RESET_CHANNEL & !wait_for_lane_up_r)|
                                        RESET;
    defparam reset_lanes_flop_i.INIT = 1'b1;
    FD reset_lanes_flop_i
    (
        .D(reset_lanes_c),
        .C(USER_CLK),
        .Q(RESET_LANES)
    );
    defparam free_count_1_i.INIT = 16'h8000;
    SRL16 free_count_1_i
    (
        .Q(free_count_1_r),
        .A0(1'b1),
        .A1(1'b1),
        .A2(1'b1),
        .A3(1'b1),
        .CLK(USER_CLK),
        .D(free_count_1_r)
    );
    defparam free_count_2_i.INIT = 16'h8000;
    SRL16E free_count_2_i
    (
        .Q(free_count_2_r),
        .A0(1'b1),
        .A1(1'b1),
        .A2(1'b1),
        .A3(1'b1),
        .CLK(USER_CLK),
        .CE(free_count_1_r),
        .D(free_count_2_r)
    );
    always @(posedge USER_CLK)
        free_count_done_r <=  `DLY    free_count_2_r & free_count_1_r;
    always @(posedge USER_CLK)
        if(free_count_done_r | !verify_r)
            verify_watchdog_r   <=  `DLY    {verify_r,verify_watchdog_r[0:14]};
    assign  verify_watchdog_done_r  =   verify_watchdog_r[15];
    assign   EN_CHAN_SYNC    =   1'b0;
    always @(posedge USER_CLK)
        all_lanes_v_r <=  `DLY  GOT_V;
    always @(posedge USER_CLK)
        if(!verify_r)                   got_first_v_r   <=  `DLY    1'b0;
        else if(all_lanes_v_r)          got_first_v_r   <=  `DLY    1'b1;
    assign  insert_ver_c    =   all_lanes_v_r & !got_first_v_r | (v_count_r[15] & verify_r);
    always @(posedge USER_CLK)
        v_count_r   <=  `DLY    {insert_ver_c,v_count_r[0:14]};
    always @(posedge USER_CLK)
        bad_v_r     <=  `DLY    (v_count_r[15] ^ all_lanes_v_r) & got_first_v_r;
    always @(posedge USER_CLK)
        if((v_count_r[15] & all_lanes_v_r) |!verify_r)
            rxver_count_r   <=  `DLY    {verify_r,rxver_count_r[0:1]};
    assign  rxver_3d_done_r     =   rxver_count_r[2];
    always @(posedge USER_CLK)
        if(DID_VER |!verify_r)
            txver_count_r   <=  `DLY    {verify_r,txver_count_r[0:6]};
    assign  txver_8d_done_r     =   txver_count_r[7];
endmodule
