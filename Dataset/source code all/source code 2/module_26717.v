`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module alt_ddrx_timers_fsm #
    ( parameter
        BANK_ACTIVATE_WIDTH        = 10,
        ACT_TO_PCH_WIDTH           = 10,
        ACT_TO_ACT_WIDTH           = 10,
        RD_TO_RD_WIDTH             = 10,
        RD_TO_WR_WIDTH             = 10,
        RD_TO_PCH_WIDTH            = 10,
        WR_TO_WR_WIDTH             = 10,
        WR_TO_RD_WIDTH             = 10,
        WR_TO_PCH_WIDTH            = 10,
        PCH_TO_ACT_WIDTH           = 10,
        RD_AP_TO_ACT_WIDTH         = 10,
        WR_AP_TO_ACT_WIDTH         = 10,
        ARF_TO_VALID_WIDTH         = 10,
        PDN_TO_VALID_WIDTH         = 10,
        SRF_TO_VALID_WIDTH         = 10,
        LMR_TO_LMR_WIDTH           = 10,
        LMR_TO_VALID_WIDTH         = 10
    )
    (
        ctl_clk,
        ctl_reset_n,
        do_write,
        do_read,
        do_activate,
        do_precharge,
        do_auto_precharge,
        do_precharge_all,
        do_refresh,
        do_power_down,
        do_self_rfsh,
        do_lmr,
        do_enable,
        bank_active,
        act_to_pch,
        act_to_act,
        rd_to_rd,
        rd_to_wr,
        rd_to_pch,
        wr_to_wr,
        wr_to_rd,
        wr_to_pch,
        wr_to_rd_to_pch_all,
        pch_to_act,
        rd_ap_to_act,
        wr_ap_to_act,
        arf_to_valid,
        pdn_to_valid,
        srf_to_valid,
        srf_to_zq,
        lmr_to_lmr,
        lmr_to_valid,
        less_than_2_bank_active,
        less_than_2_act_to_pch,
        less_than_2_act_to_act,
        less_than_2_rd_to_rd,
        less_than_2_rd_to_wr,
        less_than_2_rd_to_pch,
        less_than_2_wr_to_wr,
        less_than_2_wr_to_rd,
        less_than_2_wr_to_pch,
        less_than_2_pch_to_act,
        less_than_2_rd_ap_to_act,
        less_than_2_wr_ap_to_act,
        less_than_2_arf_to_valid,
        less_than_2_pdn_to_valid,
        less_than_2_srf_to_valid,
        less_than_2_lmr_to_lmr,
        less_than_2_lmr_to_valid,
        less_than_3_bank_active,
        less_than_3_act_to_pch,
        less_than_3_act_to_act,
        less_than_3_rd_to_rd,
        less_than_3_rd_to_wr,
        less_than_3_rd_to_pch,
        less_than_3_wr_to_wr,
        less_than_3_wr_to_rd,
        less_than_3_wr_to_pch,
        less_than_3_wr_to_rd_to_pch_all,
        less_than_3_pch_to_act,
        less_than_3_rd_ap_to_act,
        less_than_3_wr_ap_to_act,
        less_than_3_arf_to_valid,
        less_than_3_pdn_to_valid,
        less_than_3_srf_to_valid,
        less_than_3_lmr_to_lmr,
        less_than_3_lmr_to_valid,
        less_than_4_bank_active,
        less_than_4_act_to_pch,
        less_than_4_act_to_act,
        less_than_4_rd_to_rd,
        less_than_4_rd_to_wr,
        less_than_4_rd_to_pch,
        less_than_4_wr_to_wr,
        less_than_4_wr_to_rd,
        less_than_4_wr_to_pch,
        less_than_4_wr_to_rd_to_pch_all,
        less_than_4_pch_to_act,
        less_than_4_rd_ap_to_act,
        less_than_4_wr_ap_to_act,
        less_than_4_arf_to_valid,
        less_than_4_pdn_to_valid,
        less_than_4_srf_to_valid,
        less_than_4_lmr_to_lmr,
        less_than_4_lmr_to_valid,
        more_than_2_bank_active,
        more_than_2_act_to_pch,
        more_than_2_act_to_act,
        more_than_2_rd_to_rd,
        more_than_2_rd_to_wr,
        more_than_2_rd_to_pch,
        more_than_2_wr_to_wr,
        more_than_2_wr_to_rd,
        more_than_2_wr_to_pch,
        more_than_2_pch_to_act,
        more_than_2_rd_ap_to_act,
        more_than_2_wr_ap_to_act,
        more_than_2_arf_to_valid,
        more_than_2_pdn_to_valid,
        more_than_2_srf_to_valid,
        more_than_2_lmr_to_lmr,
        more_than_2_lmr_to_valid,
        more_than_3_bank_active,
        more_than_3_act_to_pch,
        more_than_3_act_to_act,
        more_than_3_rd_to_rd,
        more_than_3_rd_to_wr,
        more_than_3_rd_to_pch,
        more_than_3_wr_to_wr,
        more_than_3_wr_to_rd,
        more_than_3_wr_to_pch,
        more_than_3_pch_to_act,
        more_than_3_rd_ap_to_act,
        more_than_3_wr_ap_to_act,
        more_than_3_arf_to_valid,
        more_than_3_pdn_to_valid,
        more_than_3_srf_to_valid,
        more_than_3_lmr_to_lmr,
        more_than_3_lmr_to_valid,
        more_than_5_pch_to_act,
        compare_wr_to_rd_to_pch_all,
        int_can_activate,
        int_can_activate_chip,
        int_can_precharge,
        int_can_read,
        int_can_write,
        int_can_refresh,
        int_can_power_down,
        int_can_self_rfsh,
        int_can_lmr,
        int_zq_cal_req
    );
input ctl_clk;
input ctl_reset_n;
input do_write;
input do_read;
input do_activate;
input do_precharge;
input do_auto_precharge;
input do_precharge_all;
input do_refresh;
input do_power_down;
input do_self_rfsh;
input do_lmr;
input do_enable;
input [BANK_ACTIVATE_WIDTH - 1 : 0] bank_active;
input [ACT_TO_PCH_WIDTH    - 1 : 0] act_to_pch;
input [ACT_TO_ACT_WIDTH    - 1 : 0] act_to_act;
input [RD_TO_RD_WIDTH      - 1 : 0] rd_to_rd;
input [RD_TO_WR_WIDTH      - 1 : 0] rd_to_wr;
input [RD_TO_PCH_WIDTH     - 1 : 0] rd_to_pch;
input [WR_TO_WR_WIDTH      - 1 : 0] wr_to_wr;
input [WR_TO_RD_WIDTH      - 1 : 0] wr_to_rd;
input [WR_TO_PCH_WIDTH     - 1 : 0] wr_to_pch;
input [WR_TO_PCH_WIDTH     - 1 : 0] wr_to_rd_to_pch_all;
input [PCH_TO_ACT_WIDTH    - 1 : 0] pch_to_act;
input [RD_AP_TO_ACT_WIDTH  - 1 : 0] rd_ap_to_act;
input [WR_AP_TO_ACT_WIDTH  - 1 : 0] wr_ap_to_act;
input [ARF_TO_VALID_WIDTH  - 1 : 0] arf_to_valid;
input [PDN_TO_VALID_WIDTH  - 1 : 0] pdn_to_valid;
input [SRF_TO_VALID_WIDTH  - 1 : 0] srf_to_valid;
input [SRF_TO_VALID_WIDTH  - 1 : 0] srf_to_zq;
input [LMR_TO_LMR_WIDTH    - 1 : 0] lmr_to_lmr;
input [LMR_TO_VALID_WIDTH  - 1 : 0] lmr_to_valid;
input less_than_2_bank_active;
input less_than_2_act_to_pch;
input less_than_2_act_to_act;
input less_than_2_rd_to_rd;
input less_than_2_rd_to_wr;
input less_than_2_rd_to_pch;
input less_than_2_wr_to_wr;
input less_than_2_wr_to_rd;
input less_than_2_wr_to_pch;
input less_than_2_pch_to_act;
input less_than_2_rd_ap_to_act;
input less_than_2_wr_ap_to_act;
input less_than_2_arf_to_valid;
input less_than_2_pdn_to_valid;
input less_than_2_srf_to_valid;
input less_than_2_lmr_to_lmr;
input less_than_2_lmr_to_valid;
input less_than_3_bank_active;
input less_than_3_act_to_pch;
input less_than_3_act_to_act;
input less_than_3_rd_to_rd;
input less_than_3_rd_to_wr;
input less_than_3_rd_to_pch;
input less_than_3_wr_to_wr;
input less_than_3_wr_to_rd;
input less_than_3_wr_to_pch;
input less_than_3_wr_to_rd_to_pch_all;
input less_than_3_pch_to_act;
input less_than_3_rd_ap_to_act;
input less_than_3_wr_ap_to_act;
input less_than_3_arf_to_valid;
input less_than_3_pdn_to_valid;
input less_than_3_srf_to_valid;
input less_than_3_lmr_to_lmr;
input less_than_3_lmr_to_valid;
input less_than_4_bank_active;
input less_than_4_act_to_pch;
input less_than_4_act_to_act;
input less_than_4_rd_to_rd;
input less_than_4_rd_to_wr;
input less_than_4_rd_to_pch;
input less_than_4_wr_to_wr;
input less_than_4_wr_to_rd;
input less_than_4_wr_to_pch;
input less_than_4_wr_to_rd_to_pch_all;
input less_than_4_pch_to_act;
input less_than_4_rd_ap_to_act;
input less_than_4_wr_ap_to_act;
input less_than_4_arf_to_valid;
input less_than_4_pdn_to_valid;
input less_than_4_srf_to_valid;
input less_than_4_lmr_to_lmr;
input less_than_4_lmr_to_valid;
input more_than_2_bank_active;
input more_than_2_act_to_pch;
input more_than_2_act_to_act;
input more_than_2_rd_to_rd;
input more_than_2_rd_to_wr;
input more_than_2_rd_to_pch;
input more_than_2_wr_to_wr;
input more_than_2_wr_to_rd;
input more_than_2_wr_to_pch;
input more_than_2_pch_to_act;
input more_than_2_rd_ap_to_act;
input more_than_2_wr_ap_to_act;
input more_than_2_arf_to_valid;
input more_than_2_pdn_to_valid;
input more_than_2_srf_to_valid;
input more_than_2_lmr_to_lmr;
input more_than_2_lmr_to_valid;
input more_than_3_bank_active;
input more_than_3_act_to_pch;
input more_than_3_act_to_act;
input more_than_3_rd_to_rd;
input more_than_3_rd_to_wr;
input more_than_3_rd_to_pch;
input more_than_3_wr_to_wr;
input more_than_3_wr_to_rd;
input more_than_3_wr_to_pch;
input more_than_3_pch_to_act;
input more_than_3_rd_ap_to_act;
input more_than_3_wr_ap_to_act;
input more_than_3_arf_to_valid;
input more_than_3_pdn_to_valid;
input more_than_3_srf_to_valid;
input more_than_3_lmr_to_lmr;
input more_than_3_lmr_to_valid;
input more_than_5_pch_to_act;
input compare_wr_to_rd_to_pch_all;
output int_can_activate;
output int_can_activate_chip;
output int_can_precharge;
output int_can_read;
output int_can_write;
output int_can_refresh;
output int_can_power_down;
output int_can_self_rfsh;
output int_can_lmr;
output int_zq_cal_req;
localparam IDLE  = 32'h49444C45;
localparam ACT   = 32'h20414354;
localparam WR    = 32'h20205752;
localparam RD    = 32'h20205244;
localparam WRAP  = 32'h57524150;
localparam RDAP  = 32'h52444150;
localparam PCH   = 32'h20504348;
localparam ARF   = 32'h20415246;
localparam PDN   = 32'h2050444E;
localparam SRF   = 32'h20535246;
localparam LMR   = 32'h204C4D52;
localparam GENERAL_COUNTER_BIT = 8;   
localparam TRC_COUNTER_BIT     = 6;   
localparam TRAS_COUNTER_BIT    = 5;   
localparam EXIT_COUNTER_BIT    = 10;  
reg [31 : 0] state;
reg did_write;
reg int_do_write;
reg int_do_read;
reg int_do_activate;
reg int_do_precharge;
reg int_do_auto_precharge;
reg int_do_precharge_all;
reg int_do_refresh;
reg int_do_power_down;
reg int_do_self_rfsh;
reg int_do_lmr;
reg int_can_activate;
reg int_can_precharge;
reg int_can_read;
reg int_can_write;
reg int_can_refresh;
reg int_can_power_down;
reg int_can_self_rfsh;
reg int_can_lmr;
reg int_zq_cal_req;
reg int_do_self_rfsh_r1;
reg [GENERAL_COUNTER_BIT - 1 : 0] cnt;
reg [TRC_COUNTER_BIT - 1 : 0]     trc_cnt;
reg [TRAS_COUNTER_BIT - 1 : 0]    tras_cnt;
reg [EXIT_COUNTER_BIT - 1 : 0]    exit_cnt;
reg read_ok;
reg write_ok;
reg activate_ok;
reg precharge_ok;
reg chip_request_ok;
reg chip_activate_ok;
reg zq_cal_req;
wire int_can_activate_chip = chip_activate_ok;
always @ (*)
begin
    int_do_write          = do_write          & do_enable ;
    int_do_read           = do_read           & do_enable ;
    int_do_activate       = do_activate       & do_enable ;
    int_do_precharge      = do_precharge      & do_enable ;
    int_do_auto_precharge = do_auto_precharge & do_enable ;
    int_do_precharge_all  = do_precharge_all              ;
    int_do_refresh        = do_refresh                    ;
    int_do_power_down     = do_power_down                 ;
    int_do_self_rfsh      = do_self_rfsh                  ;
    int_do_lmr            = do_lmr                        ;
end
always @ (*)
begin
    int_can_activate    = activate_ok;
    int_can_precharge   = precharge_ok;
    int_can_write       = write_ok;
    int_can_read        = read_ok;
    int_can_refresh     = chip_request_ok;
    int_can_self_rfsh   = chip_request_ok;
    int_can_power_down  = chip_request_ok;
    int_can_lmr         = chip_request_ok;
    int_zq_cal_req      = zq_cal_req;
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        int_do_self_rfsh_r1 <= 1'b0;
    end
    else
    begin
        int_do_self_rfsh_r1 <= int_do_self_rfsh;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        cnt <= 0;
    end
    else
    begin
        if (int_do_activate || int_do_precharge || int_do_precharge_all || int_do_write || int_do_read || int_do_refresh || int_do_lmr)
            cnt <= 5;
        else if (cnt != {GENERAL_COUNTER_BIT{1'b1}})
            cnt <= cnt + 1'b1;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        trc_cnt <= 0;
    end
    else
    begin
        if (int_do_activate)
            trc_cnt <= 5;
        else if (trc_cnt != {TRC_COUNTER_BIT{1'b1}})
            trc_cnt <= trc_cnt + 1'b1;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        exit_cnt <= 0;
    end
    else
    begin
        if (int_do_self_rfsh)
            exit_cnt <= 0;
        else if (!int_do_self_rfsh && int_do_self_rfsh_r1)
            exit_cnt <= 6;
        else if (exit_cnt != {EXIT_COUNTER_BIT{1'b1}})
            exit_cnt <= exit_cnt + 1'b1;
    end
end
always @ (posedge ctl_clk or negedge ctl_reset_n)
begin
    if (!ctl_reset_n)
    begin
        state            <= IDLE;
        activate_ok      <= 1'b0;
        precharge_ok     <= 1'b0;
        read_ok          <= 1'b0;
        write_ok         <= 1'b0;
        chip_request_ok  <= 1'b0;
        chip_activate_ok <= 1'b1;
        zq_cal_req       <= 1'b0;
        did_write        <= 1'b0;
    end
    else
    begin
        case (state)
            IDLE :
                begin
                    state            <= IDLE;
                    precharge_ok     <= 1'b1;
                    read_ok          <= 1'b0;
                    write_ok         <= 1'b0;
                    chip_activate_ok <= 1'b1;
                    zq_cal_req       <= 1'b0;
                    did_write        <= 1'b0;
                    if ((int_do_precharge || int_do_precharge_all) && more_than_5_pch_to_act)
                    begin
                        activate_ok     <= 1'b0;
                        chip_request_ok <= 1'b0;
                    end
                    else if (cnt >= pch_to_act)
                    begin
                        activate_ok     <= 1'b1;
                        chip_request_ok <= 1'b1;
                    end
                    else
                    begin
                        activate_ok     <= 1'b0;
                        chip_request_ok <= 1'b0;
                    end
                    if (int_do_activate)
                    begin
                        state            <= ACT;
                        activate_ok      <= 1'b0;
                        chip_request_ok  <= 1'b0;
                        chip_activate_ok <= 1'b1;
                        if (less_than_4_act_to_pch  && trc_cnt >= act_to_pch)
                            precharge_ok <= 1'b1;
                        else
                            precharge_ok <= 1'b0;
                        if (less_than_4_bank_active)
                        begin
                            read_ok  <= 1'b1;
                            write_ok <= 1'b1;
                        end
                        else
                        begin
                            read_ok  <= 1'b0;
                            write_ok <= 1'b0;
                        end
                    end
                    if (int_do_refresh)
                    begin
                        state            <= ARF;
                        activate_ok      <= 1'b0;
                        precharge_ok     <= 1'b0;
                        read_ok          <= 1'b0;
                        write_ok         <= 1'b0;
                        chip_activate_ok <= 1'b0;
                        chip_request_ok <= 1'b0; 
                    end
                    if (int_do_power_down)
                    begin
                        state            <= PDN;
                        activate_ok      <= 1'b0;
                        precharge_ok     <= 1'b0;
                        read_ok          <= 1'b0;
                        write_ok         <= 1'b0;
                        chip_request_ok  <= 1'b0; 
                        chip_activate_ok <= 1'b0;
                    end
                    if (int_do_self_rfsh)
                    begin
                        state            <= SRF;
                        activate_ok      <= 1'b0;
                        precharge_ok     <= 1'b0;
                        read_ok          <= 1'b0;
                        write_ok         <= 1'b0;
                        chip_request_ok  <= 1'b0; 
                        chip_activate_ok <= 1'b0;
                    end
                end
            ACT :
                begin
                    state            <= ACT;
                    chip_request_ok  <= 1'b0;
                    chip_activate_ok <= 1'b1;
                    activate_ok      <= 1'b0;
                    did_write        <= 1'b0;
                    if (trc_cnt >= act_to_pch)
                        precharge_ok <= 1'b1;
                    else
                        precharge_ok <= 1'b0;
                    if (cnt >= bank_active)
                    begin
                        read_ok  <= 1'b1;
                        write_ok <= 1'b1;
                    end
                    else
                    begin
                        read_ok  <= 1'b0;
                        write_ok <= 1'b0;
                    end
                    if (int_do_activate)
                    begin
                        $write($time);
                        $write(" DDRX Timer Warning: Back to back activate to the same bank detected\n");
                    end
                    if (int_do_write && !int_do_auto_precharge)
                    begin
                        state        <= WR;
                        activate_ok  <= 1'b0;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b1;
                        write_ok     <= 1'b1;
                        if (less_than_4_wr_to_pch && trc_cnt >= act_to_pch)
                            precharge_ok <= 1'b1;
                        else
                            precharge_ok <= 1'b0;
                    end
                    if (int_do_read && !int_do_auto_precharge)
                    begin
                        state       <= RD;
                        activate_ok <= 1'b0;
                        read_ok     <= 1'b1;
                        write_ok    <= 1'b1;
                        if (less_than_4_rd_to_pch && trc_cnt >= act_to_pch)
                            precharge_ok <= 1'b1;
                        else
                            precharge_ok <= 1'b0;
                    end
                    if (int_do_write && int_do_auto_precharge)
                    begin
                        state        <= WRAP;
                        activate_ok  <= 1'b0;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        if (less_than_4_wr_ap_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                    end
                    if (int_do_read && int_do_auto_precharge)
                    begin
                        state        <= RDAP;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        if (less_than_4_rd_ap_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                    end
                    if (int_do_precharge || int_do_precharge_all)
                    begin
                        state        <= PCH;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        if (less_than_4_pch_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                        if (less_than_4_pch_to_act) 
                            chip_request_ok <= 1'b1;
                        else
                            chip_request_ok <= 1'b0;
                    end
                end
            WR :
                begin
                    state            <= WR;
                    chip_request_ok  <= 1'b0;
                    chip_activate_ok <= 1'b1;
                    activate_ok      <= 1'b0;
                    read_ok          <= 1'b1;
                    write_ok         <= 1'b1;
                    did_write        <= 1'b1;
                    if (cnt >= wr_to_pch && trc_cnt >= act_to_pch)
                        precharge_ok <= 1'b1;
                    else
                        precharge_ok <= 1'b0;
                    if (int_do_write && !int_do_auto_precharge)
                    begin
                        state        <= WR;
                        activate_ok  <= 1'b0;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b1;
                        write_ok     <= 1'b1;
                        if (less_than_4_wr_to_pch && trc_cnt >= act_to_pch)
                            precharge_ok <= 1'b1;
                        else
                            precharge_ok <= 1'b0;
                    end
                    if (int_do_read && !int_do_auto_precharge)
                    begin
                        state        <= RD;
                        activate_ok  <= 1'b0;
                        read_ok      <= 1'b1;
                        write_ok     <= 1'b1;
                        if (compare_wr_to_rd_to_pch_all) 
                        begin
                            if (less_than_4_wr_to_rd_to_pch_all && trc_cnt >= act_to_pch)
                                precharge_ok <= 1'b1;
                            else
                                precharge_ok <= 1'b0;
                        end
                        else
                        begin
                            if (less_than_4_rd_to_pch && trc_cnt >= act_to_pch)
                                precharge_ok <= 1'b1;
                            else
                                precharge_ok <= 1'b0;
                        end
                    end
                    if (int_do_write && int_do_auto_precharge)
                    begin
                        state        <= WRAP;
                        activate_ok  <= 1'b0;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        if (less_than_4_wr_ap_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                    end
                    if (int_do_read && int_do_auto_precharge)
                    begin
                        state        <= RDAP;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        if (less_than_4_rd_ap_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                    end
                    if (int_do_precharge || int_do_precharge_all)
                    begin
                        state        <= PCH;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        if (less_than_4_pch_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                        if (less_than_4_pch_to_act) 
                            chip_request_ok <= 1'b1;
                        else
                            chip_request_ok <= 1'b0;
                    end
                end
            RD :
                begin
                    state            <= RD;
                    chip_request_ok  <= 1'b0;
                    chip_activate_ok <= 1'b1;
                    activate_ok      <= 1'b0;
                    read_ok          <= 1'b1;
                    write_ok         <= 1'b1;
                    if (did_write && compare_wr_to_rd_to_pch_all) 
                    begin
                        if (cnt >= wr_to_rd_to_pch_all && trc_cnt >= act_to_pch)
                            precharge_ok <= 1'b1;
                        else
                            precharge_ok <= 1'b0;
                    end
                    else
                    begin
                        if (cnt >= rd_to_pch && trc_cnt >= act_to_pch)
                            precharge_ok <= 1'b1;
                        else
                            precharge_ok <= 1'b0;
                    end
                    if (int_do_read && !int_do_auto_precharge)
                    begin
                        state        <= RD;
                        activate_ok  <= 1'b0;
                        read_ok      <= 1'b1;
                        write_ok     <= 1'b1;
                        did_write    <= 1'b0;
                        if (less_than_4_rd_to_pch && trc_cnt >= act_to_pch)
                            precharge_ok <= 1'b1;
                        else
                            precharge_ok <= 1'b0;
                    end
                    if (int_do_write && !int_do_auto_precharge)
                    begin
                        state        <= WR;
                        activate_ok  <= 1'b0;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b1;
                        write_ok     <= 1'b1;
                        did_write    <= 1'b0;
                        if (less_than_4_wr_to_pch && trc_cnt >= act_to_pch)
                            precharge_ok <= 1'b1;
                        else
                            precharge_ok <= 1'b0;
                    end
                    if (int_do_read && int_do_auto_precharge)
                    begin
                        state        <= RDAP;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        did_write    <= 1'b0;
                        if (less_than_4_rd_ap_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                    end
                    if (int_do_write && int_do_auto_precharge)
                    begin
                        state        <= WRAP;
                        activate_ok  <= 1'b0;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        did_write    <= 1'b0;
                        if (less_than_4_wr_ap_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                    end
                    if (int_do_precharge || int_do_precharge_all)
                    begin
                        state        <= PCH;
                        precharge_ok <= 1'b0;
                        read_ok      <= 1'b0;
                        write_ok     <= 1'b0;
                        did_write    <= 1'b0;
                        if (less_than_4_pch_to_act && trc_cnt >= act_to_act)
                            activate_ok  <= 1'b1;
                        else
                            activate_ok  <= 1'b0;
                        if (less_than_4_pch_to_act) 
                            chip_request_ok <= 1'b1;
                        else
                            chip_request_ok <= 1'b0;
                    end
                end
            PCH :
                begin
                    state            <= PCH;
                    chip_activate_ok <= 1'b1;
                    activate_ok      <= 1'b0;
                    precharge_ok     <= 1'b0;
                    read_ok          <= 1'b0;
                    write_ok         <= 1'b0;
                    did_write        <= 1'b0;
                    if (!int_do_precharge && !int_do_precharge_all)
                    begin
                        if (cnt >= pch_to_act && trc_cnt >= act_to_act)
                        begin
                            state <= IDLE;
                            activate_ok  <= 1'b1;
                        end
                        if (cnt >= pch_to_act) 
                            chip_request_ok <= 1'b1;
                        else
                            chip_request_ok <= 1'b0;
                        if (do_refresh)
                        begin
                            state            <= ARF;
                            activate_ok      <= 1'b0;
                            precharge_ok     <= 1'b0;
                            read_ok          <= 1'b0;
                            write_ok         <= 1'b0;
                            chip_request_ok  <= 1'b0;
                            chip_activate_ok <= 1'b0;
                        end
                        else if (do_power_down)
                        begin
                            state            <= PDN;
                            activate_ok      <= 1'b0;
                            precharge_ok     <= 1'b0;
                            read_ok          <= 1'b0;
                            write_ok         <= 1'b0;
                            chip_request_ok  <= 1'b0;
                            chip_activate_ok <= 1'b0;
                        end
                        else if (do_self_rfsh)
                        begin
                            state            <= SRF;
                            activate_ok      <= 1'b0;
                            precharge_ok     <= 1'b0;
                            read_ok          <= 1'b0;
                            write_ok         <= 1'b0;
                            chip_request_ok  <= 1'b0;
                            chip_activate_ok <= 1'b0;
                        end
                    end
                end
            WRAP : 
                begin
                    state            <= WRAP;
                    chip_request_ok  <= 1'b0;
                    chip_activate_ok <= 1'b1;
                    activate_ok      <= 1'b0;
                    precharge_ok     <= 1'b0;
                    read_ok          <= 1'b0;
                    write_ok         <= 1'b0;
                    did_write        <= 1'b0;
                    if (cnt >= wr_ap_to_act && trc_cnt >= act_to_act)
                    begin
                        state <= IDLE;
                        activate_ok  <= 1'b1;
                        precharge_ok <= 1'b1;
                        read_ok  <= 1'b0;
                        write_ok <= 1'b0;
                    end
                end
            RDAP : 
                begin
                    state            <= RDAP;
                    chip_request_ok  <= 1'b0;
                    chip_activate_ok <= 1'b1;
                    activate_ok      <= 1'b0;
                    precharge_ok     <= 1'b0;
                    read_ok          <= 1'b0;
                    write_ok         <= 1'b0;
                    did_write        <= 1'b0;
                    if (cnt >= rd_ap_to_act && trc_cnt >= act_to_act)
                    begin
                        state <= IDLE;
                        activate_ok  <= 1'b1;
                        precharge_ok <= 1'b1;
                        read_ok  <= 1'b0;
                        write_ok <= 1'b0;
                    end
                end
            ARF :
                begin
                    state            <= ARF;
                    activate_ok      <= 1'b0;
                    precharge_ok     <= 1'b0;
                    read_ok          <= 1'b0;
                    write_ok         <= 1'b0;
                    chip_request_ok  <= 1'b0;
                    chip_activate_ok <= 1'b0;
                    did_write        <= 1'b0;
                    if (cnt >= arf_to_valid)
                    begin
                        state <= IDLE;
                        activate_ok  <= 1'b1;
                        precharge_ok <= 1'b0;
                        read_ok  <= 1'b0;
                        write_ok <= 1'b0;
                        chip_request_ok  <= 1'b1;
                        chip_activate_ok <= 1'b1;
                    end
                end
            PDN : 
                begin
                    state            <= PDN;
                    activate_ok      <= 1'b0;
                    precharge_ok     <= 1'b0;
                    read_ok          <= 1'b0;
                    write_ok         <= 1'b0;
                    chip_request_ok  <= 1'b0;
                    chip_activate_ok <= 1'b0;
                    did_write        <= 1'b0;
                    if (!int_do_power_down) 
                    begin
                        state <= IDLE;
                        activate_ok  <= 1'b1;
                        precharge_ok <= 1'b0;
                        read_ok  <= 1'b0;
                        write_ok <= 1'b0;
                        chip_request_ok  <= 1'b1;
                        chip_activate_ok <= 1'b1;
                    end
                end
            SRF :
                begin
                    state            <= SRF;
                    activate_ok      <= 1'b0;
                    precharge_ok     <= 1'b0;
                    read_ok          <= 1'b0;
                    write_ok         <= 1'b0;
                    chip_request_ok  <= 1'b0;
                    chip_activate_ok <= 1'b0;
                    zq_cal_req       <= 1'b0;
                    did_write        <= 1'b0;
                    if (!int_do_self_rfsh && exit_cnt == srf_to_zq) 
                        zq_cal_req <= 1'b1;
                    if (!int_do_self_rfsh && exit_cnt > srf_to_valid) 
                    begin
                        state <= IDLE;
                        activate_ok  <= 1'b1;
                        precharge_ok <= 1'b0;
                        read_ok  <= 1'b0;
                        write_ok <= 1'b0;
                        chip_request_ok  <= 1'b1;
                        chip_activate_ok <= 1'b1;
                    end
                end
            default :
                state <= IDLE;
        endcase
    end
end
endmodule
