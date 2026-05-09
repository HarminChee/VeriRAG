`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module alt_mem_ddrx_burst_tracking
# (
    parameter
        CFG_BURSTCOUNT_TRACKING_WIDTH   =   7,
        CFG_BUFFER_ADDR_WIDTH           =   6,
        CFG_INT_SIZE_WIDTH              =   4
)
(
    ctl_clk,
    ctl_reset_n,
    burst_ready,
    burst_valid,
    burst_pending_burstcount,
    burst_next_pending_burstcount,
    burst_consumed_valid,
    burst_counsumed_burstcount
);
    input                                           ctl_clk;
    input                                           ctl_reset_n;
    input                                           burst_ready;
    input                                           burst_valid;
    output  [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]     burst_pending_burstcount;
    output  [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]     burst_next_pending_burstcount;
    input                                           burst_consumed_valid;
    input   [CFG_INT_SIZE_WIDTH-1:0]                burst_counsumed_burstcount;
    wire                                            ctl_clk;
    wire                                            ctl_reset_n;
    wire                                            burst_ready;
    wire                                            burst_valid;
    wire    [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]     burst_pending_burstcount;
    wire    [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]     burst_next_pending_burstcount;
    wire                                            burst_consumed_valid;
    wire    [CFG_INT_SIZE_WIDTH-1:0]                burst_counsumed_burstcount;
    reg     [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]     burst_counter;
    reg     [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]     burst_counter_next;
    wire                                            burst_accepted;
    assign burst_pending_burstcount      = burst_counter;
    assign burst_next_pending_burstcount = burst_counter_next;
    assign burst_accepted = burst_ready & burst_valid;
    always @ (*) 
    begin
        if (burst_accepted & burst_consumed_valid)
        begin
            burst_counter_next = burst_counter + 1 - burst_counsumed_burstcount;
        end
        else if (burst_accepted)
        begin
            burst_counter_next = burst_counter + 1;
        end
        else if (burst_consumed_valid)
        begin
            burst_counter_next = burst_counter - burst_counsumed_burstcount;
        end
        else 
        begin
            burst_counter_next = burst_counter;
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            burst_counter <= 0;
        end
        else
        begin
            burst_counter <= burst_counter_next;
        end
    end
endmodule
