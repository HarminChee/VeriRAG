`timescale 1ns / 1ps
`define DLY #1
`timescale 1ns / 1ps
`define DLY #1
module TX_SYNC_GTP 
(
    output          TXENPMAPHASEALIGN,
    output          TXPMASETPHASE,
    output          SYNC_DONE,
    input           USER_CLK,
    input           RESET
);
    reg            begin_r;
    reg            phase_align_r;
    reg            ready_r;
    reg   [14:0]   sync_counter_r;
    reg   [9:0]    wait_before_sync_r;
    reg            wait_stable_r;
    wire           count_512_complete_r;
    wire           next_phase_align_c;
    wire           next_ready_c;
    wire           next_wait_stable_c;
    wire           sync_count_complete_r;
    always @(posedge USER_CLK)
        if(RESET)
            {begin_r,wait_stable_r,phase_align_r,ready_r}  <=  `DLY    4'b1000;
        else
        begin
            begin_r                <=  `DLY    1'b0;
            wait_stable_r          <=  `DLY    next_wait_stable_c;
            phase_align_r          <=  `DLY    next_phase_align_c;
            ready_r                <=  `DLY    next_ready_c;
        end
    assign  next_wait_stable_c      =   begin_r |
                                        (wait_stable_r & !count_512_complete_r);
    assign  next_phase_align_c      =   (wait_stable_r & count_512_complete_r) |
                                        (phase_align_r & !sync_count_complete_r);
    assign  next_ready_c            =   (phase_align_r & sync_count_complete_r) |
                                        ready_r;
    always @(posedge USER_CLK)
    begin
        if (!wait_stable_r)
            wait_before_sync_r <= `DLY  10'b000000000;
        else
            wait_before_sync_r <= `DLY  wait_before_sync_r + 1'b1;
    end
    assign count_512_complete_r = wait_before_sync_r[9];
    always @(posedge USER_CLK)
    begin
        if (!phase_align_r)
            sync_counter_r <= `DLY  15'b000000000000000;
        else
            sync_counter_r <= `DLY  sync_counter_r + 1'b1;
    end
    assign sync_count_complete_r = sync_counter_r[12];
    assign TXENPMAPHASEALIGN = !begin_r;
    assign TXPMASETPHASE     = phase_align_r;
    assign SYNC_DONE = ready_r;
endmodule
