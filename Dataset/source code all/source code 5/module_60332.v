module alt_mem_ddrx_dataid_manager
# (
    parameter
        CFG_DATA_ID_WIDTH                   = 8,
        CFG_DRAM_WLAT_GROUP                 = 1,
        CFG_LOCAL_WLAT_GROUP                = 1,
        CFG_BUFFER_ADDR_WIDTH               = 6,
        CFG_INT_SIZE_WIDTH                  = 1,
        CFG_TBP_NUM                         = 4,
        CFG_BURSTCOUNT_TRACKING_WIDTH       = 7,
        CFG_PORT_WIDTH_BURST_LENGTH         = 5,
        CFG_DWIDTH_RATIO                    = 2
)
(
    ctl_clk,
    ctl_reset_n,
    cfg_burst_length,
    cfg_enable_ecc,
    cfg_enable_auto_corr,
    cfg_enable_no_dm,
    update_cmd_if_ready,
    update_cmd_if_valid,
    update_cmd_if_data_id,    
    update_cmd_if_burstcount,    
    update_cmd_if_tbp_id,    
    update_data_if_valid,
    update_data_if_data_id,
    update_data_if_data_id_vector,
    update_data_if_burstcount,    
    update_data_if_next_burstcount,    
    notify_data_if_valid,
    notify_data_if_burstcount,    
    notify_tbp_data_ready,
    notify_tbp_data_partial_be,
    write_data_if_ready,
    write_data_if_valid,
    write_data_if_accepted,
    write_data_if_address,
    write_data_if_partial_dm,
    read_data_if_valid,
    read_data_if_data_id,
    read_data_if_data_id_vector,
    read_data_if_valid_first,
    read_data_if_data_id_first,
    read_data_if_data_id_vector_first,
    read_data_if_valid_first_vector,
    read_data_if_valid_last,
    read_data_if_data_id_last,
    read_data_if_data_id_vector_last,
    read_data_if_address,
    read_data_if_datavalid,
    read_data_if_done
);
    localparam integer CFG_DATAID_ARRAY_DEPTH      =   (2**CFG_DATA_ID_WIDTH);
    input                                               ctl_clk;
    input                                               ctl_reset_n;
    input  [CFG_PORT_WIDTH_BURST_LENGTH    - 1 : 0]     cfg_burst_length;
    input                                               cfg_enable_ecc;
    input                                               cfg_enable_auto_corr;
    input                                               cfg_enable_no_dm;
    output                                              update_cmd_if_ready;
    input                                               update_cmd_if_valid;
    input   [CFG_DATA_ID_WIDTH-1:0]                     update_cmd_if_data_id;    
    input   [CFG_INT_SIZE_WIDTH-1:0]                    update_cmd_if_burstcount;    
    input   [CFG_TBP_NUM-1:0]                           update_cmd_if_tbp_id;    
    input                                               update_data_if_valid;
    input   [CFG_DATA_ID_WIDTH-1:0]                     update_data_if_data_id;
    input   [CFG_DATAID_ARRAY_DEPTH-1:0]                update_data_if_data_id_vector;
    input   [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]         update_data_if_burstcount;    
    input   [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]         update_data_if_next_burstcount;    
    output                                              notify_data_if_valid;
    output  [CFG_INT_SIZE_WIDTH-1:0]                    notify_data_if_burstcount;
    output  [CFG_TBP_NUM-1:0]                           notify_tbp_data_ready;
    output                                              notify_tbp_data_partial_be;
    output                                              write_data_if_ready;
    input                                               write_data_if_valid;
    output                                              write_data_if_accepted;
    output  [CFG_BUFFER_ADDR_WIDTH-1:0]                 write_data_if_address;
    input                                               write_data_if_partial_dm;
    input   [CFG_DRAM_WLAT_GROUP-1:0]                           read_data_if_valid;
    input   [CFG_DRAM_WLAT_GROUP*CFG_DATA_ID_WIDTH-1:0]         read_data_if_data_id;
    input   [CFG_DRAM_WLAT_GROUP*CFG_DATAID_ARRAY_DEPTH-1:0]    read_data_if_data_id_vector;
    input                                                       read_data_if_valid_first;
    input   [CFG_DATA_ID_WIDTH-1:0]                             read_data_if_data_id_first;
    input   [CFG_DATAID_ARRAY_DEPTH-1:0]                        read_data_if_data_id_vector_first;
    input   [CFG_DRAM_WLAT_GROUP-1:0]                           read_data_if_valid_first_vector;
    input                                                       read_data_if_valid_last;
    input   [CFG_DATA_ID_WIDTH-1:0]                             read_data_if_data_id_last;
    input   [CFG_DATAID_ARRAY_DEPTH-1:0]                        read_data_if_data_id_vector_last;
    output  [CFG_DRAM_WLAT_GROUP*CFG_BUFFER_ADDR_WIDTH-1:0]     read_data_if_address;
    output  [CFG_DRAM_WLAT_GROUP-1:0]                           read_data_if_datavalid;
    output                                                      read_data_if_done;
    wire                                                ctl_clk;
    wire                                                ctl_reset_n;
    wire    [CFG_PORT_WIDTH_BURST_LENGTH    - 1 : 0]    cfg_burst_length;
    wire                                                cfg_enable_ecc;
    wire                                                cfg_enable_auto_corr;
    wire                                                cfg_enable_no_dm;
    reg                                                 update_cmd_if_ready;
    wire                                                update_cmd_if_valid;
    wire    [CFG_DATA_ID_WIDTH-1:0]                     update_cmd_if_data_id;    
    wire    [CFG_INT_SIZE_WIDTH-1:0]                    update_cmd_if_burstcount;    
    wire    [CFG_TBP_NUM-1:0]                           update_cmd_if_tbp_id;    
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]                 update_cmd_if_address;
    wire                                                update_data_if_valid;
    wire    [CFG_DATA_ID_WIDTH-1:0]                     update_data_if_data_id;
    wire    [CFG_DATAID_ARRAY_DEPTH-1:0]                update_data_if_data_id_vector;
    wire    [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]         update_data_if_burstcount;    
    wire    [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]         update_data_if_next_burstcount;    
    wire                                                notify_data_if_valid;
    wire    [CFG_INT_SIZE_WIDTH-1:0]                    notify_data_if_burstcount;    
    reg     [CFG_DATAID_ARRAY_DEPTH-1:0]                mux_notify_data_if_valid;
    reg     [CFG_INT_SIZE_WIDTH-1:0]                    mux_notify_data_if_burstcount   [CFG_DATAID_ARRAY_DEPTH-1:0];    
    reg     [CFG_DATAID_ARRAY_DEPTH-1:0]                dataid_array_valid;
    reg     [CFG_DATAID_ARRAY_DEPTH-1:0]                dataid_array_data_ready;
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]                 dataid_array_address            [CFG_DATAID_ARRAY_DEPTH-1:0];
    reg     [CFG_INT_SIZE_WIDTH-1:0]                    dataid_array_burstcount         [CFG_DATAID_ARRAY_DEPTH-1:0]; 
    reg     [CFG_TBP_NUM-1:0]                           dataid_array_tbp_id             [CFG_DATAID_ARRAY_DEPTH-1:0];
    reg     [CFG_DATAID_ARRAY_DEPTH-1:0]                mux_dataid_array_done;
    wire    [CFG_TBP_NUM-1:0]                           notify_tbp_data_ready;
    reg                                                 notify_tbp_data_partial_be;
    reg     [CFG_TBP_NUM-1:0]                           mux_tbp_data_ready              [CFG_DATAID_ARRAY_DEPTH-1:0];
    reg     [CFG_TBP_NUM-1:0]                           tbp_data_ready_r;
    reg                                                 write_data_if_ready;
    wire                                                write_data_if_valid;
    wire                                                write_data_if_accepted;
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]                 write_data_if_address;
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]                 write_data_if_nextaddress;
    wire                                                write_data_if_partial_dm;
    wire    [CFG_DRAM_WLAT_GROUP-1:0]                           read_data_if_valid;
    wire    [CFG_DRAM_WLAT_GROUP*CFG_DATA_ID_WIDTH-1:0]         read_data_if_data_id;
    wire    [CFG_DRAM_WLAT_GROUP*CFG_DATAID_ARRAY_DEPTH-1:0]    read_data_if_data_id_vector;
    reg     [CFG_DRAM_WLAT_GROUP*CFG_BUFFER_ADDR_WIDTH-1:0]     read_data_if_address;
    reg     [CFG_DRAM_WLAT_GROUP-1:0]                           read_data_if_datavalid;
    wire    [CFG_INT_SIZE_WIDTH-1:0]                            read_data_if_burstcount;   
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]                         mux_read_data_if_address        [CFG_DATAID_ARRAY_DEPTH-1:0];
    reg     [CFG_INT_SIZE_WIDTH-1:0]                            mux_read_data_if_burstcount     [CFG_DATAID_ARRAY_DEPTH-1:0];
    wire                                                        read_data_if_done;
    reg                                                 write_data_if_address_blocked;
    reg                                                 cfg_enable_partial_be_notification;
    reg     [CFG_PORT_WIDTH_BURST_LENGTH    - 1 : 0]    cfg_max_cmd_burstcount;
    reg     [CFG_PORT_WIDTH_BURST_LENGTH    - 1 : 0]    cfg_max_cmd_burstcount_2x;
    wire                                                update_cmd_if_accepted;
    wire                                                update_cmd_if_address_blocked;
    wire    [CFG_BUFFER_ADDR_WIDTH-1:0]                 update_cmd_if_nextaddress;
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]                 update_cmd_if_nextmaxaddress;
    reg                                                 update_cmd_if_nextmaxaddress_wrapped;       
    reg     [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]         update_cmd_if_unnotified_burstcount;
    reg     [CFG_BURSTCOUNT_TRACKING_WIDTH-1:0]         update_cmd_if_next_unnotified_burstcount;
    reg     [CFG_DATAID_ARRAY_DEPTH-1:0]                mux_write_data_if_address_blocked;
    reg     [CFG_DATAID_ARRAY_DEPTH-1:0]                mux_update_cmd_if_address_blocked;
    reg                                                 err_dataid_array_overwritten;
    reg                                                 err_dataid_array_invalidread;
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]                 buffer_valid_counter;               
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]                 buffer_cmd_unallocated_counter;       
    reg                                                 buffer_valid_counter_full;
    reg                                                 err_buffer_valid_counter_overflow;
    reg                                                 err_buffer_cmd_unallocated_counter_overflow;
    reg                                                 partial_be_detected;
    reg                                                 partial_be_when_no_cmd_tracked;
    wire    [CFG_DATAID_ARRAY_DEPTH-1:0]                update_data_if_burstcount_greatereq;
    wire    [CFG_DATAID_ARRAY_DEPTH-1:0]                update_data_if_burstcount_same;
    wire                                                update_data_bc_gt_update_cmd_unnotified_bc;
    wire                                 burstcount_list_read;
    wire [CFG_INT_SIZE_WIDTH - 1 : 0]    burstcount_list_read_data;
    wire                                 burstcount_list_read_data_valid;
    wire                                 burstcount_list_write;
    wire [CFG_INT_SIZE_WIDTH - 1 : 0]    burstcount_list_write_data;
    reg                                  update_data_if_burstcount_greatereq_burstcount_list;
    reg                                  update_data_if_burstcount_same_burstcount_list;
    integer k;
    always @ (posedge ctl_clk or negedge ctl_reset_n)
    begin
        if (!ctl_reset_n)
        begin
            cfg_enable_partial_be_notification <= 1'b0;
        end
        else
        begin
            cfg_enable_partial_be_notification <= cfg_enable_ecc | cfg_enable_auto_corr | cfg_enable_no_dm;
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n)
    begin
        if (!ctl_reset_n)
        begin
            cfg_max_cmd_burstcount    <= 0;
            cfg_max_cmd_burstcount_2x <= 0;
        end
        else
        begin
            cfg_max_cmd_burstcount    <= cfg_burst_length / CFG_DWIDTH_RATIO;
            cfg_max_cmd_burstcount_2x <= 2 * cfg_max_cmd_burstcount;
        end
    end
    assign burstcount_list_write      = update_cmd_if_accepted;
    assign burstcount_list_write_data = {{(CFG_DATAID_ARRAY_DEPTH - CFG_INT_SIZE_WIDTH){1'b0}}, update_cmd_if_burstcount};
    assign burstcount_list_read       = notify_data_if_valid;
    alt_mem_ddrx_list
    # (
        .CTL_LIST_WIDTH             (CFG_INT_SIZE_WIDTH),
        .CTL_LIST_DEPTH             (CFG_DATAID_ARRAY_DEPTH),
        .CTL_LIST_INIT_VALUE_TYPE   ("ZERO"),
        .CTL_LIST_INIT_VALID        ("INVALID")
    )
    burstcount_list
    (
        .ctl_clk                    (ctl_clk),
        .ctl_reset_n                (ctl_reset_n),
        .list_get_entry_valid       (burstcount_list_read_data_valid),
        .list_get_entry_ready       (burstcount_list_read),
        .list_get_entry_id          (burstcount_list_read_data),
        .list_get_entry_id_vector   (),
        .list_put_entry_valid       (burstcount_list_write),
        .list_put_entry_ready       (),
        .list_put_entry_id          (burstcount_list_write_data)
    );
    always @ (*)
    begin
        if (burstcount_list_read_data_valid && (update_data_if_burstcount >= burstcount_list_read_data))
        begin
            update_data_if_burstcount_greatereq_burstcount_list = 1'b1;
        end
        else
        begin
            update_data_if_burstcount_greatereq_burstcount_list = 1'b0;
        end
        if (burstcount_list_read_data_valid && (update_data_if_burstcount == burstcount_list_read_data))
        begin
            update_data_if_burstcount_same_burstcount_list = 1'b1;
        end
        else
        begin
            update_data_if_burstcount_same_burstcount_list = 1'b0;
        end
    end
    genvar i;
    generate
        for (i = 0; i < CFG_DATAID_ARRAY_DEPTH; i = i + 1) 
        begin : gen_dataid_array_management
            assign update_data_if_burstcount_greatereq  [i] = (update_data_if_valid & (update_data_if_data_id_vector [i])) & update_data_if_burstcount_greatereq_burstcount_list;
            assign update_data_if_burstcount_same       [i] = (update_data_if_valid & (update_data_if_data_id_vector [i])) & update_data_if_burstcount_same_burstcount_list;
            always @ (posedge ctl_clk or negedge ctl_reset_n) 
            begin
                if (~ctl_reset_n)
                begin
                    dataid_array_address    [i] <= 0;
                    dataid_array_burstcount [i] <= 0;
                    dataid_array_tbp_id     [i] <= 0;
                    dataid_array_data_ready [i] <= 1'b0;
                    dataid_array_valid      [i] <= 1'b0;
                    mux_dataid_array_done   [i] <= 1'b0;
                    err_dataid_array_overwritten <= 0;
                    err_dataid_array_invalidread <= 0;
                end
                else
                begin
                    if (update_cmd_if_accepted && (update_cmd_if_data_id == i))
                    begin
                        dataid_array_address    [i] <=  update_cmd_if_address;
                        dataid_array_burstcount [i] <=  update_cmd_if_burstcount;
                        dataid_array_tbp_id     [i] <=  update_cmd_if_tbp_id;
                        dataid_array_valid      [i] <=  1'b1;
                        mux_dataid_array_done   [i] <=  1'b0;
                        if (dataid_array_valid[i])
                        begin
                            err_dataid_array_overwritten <= 1;
                        end
                    end
                    if (update_data_if_burstcount_greatereq[i])
                    begin
                        dataid_array_data_ready         [i] <= 1'b1;
                    end
                    if (read_data_if_valid_first && (read_data_if_data_id_vector_first[i]))
                    begin
                        dataid_array_address    [i] <=  dataid_array_address    [i] + 1;
                        dataid_array_burstcount [i] <=  dataid_array_burstcount [i] - 1;
                        dataid_array_data_ready [i] <=  0;
                        if (dataid_array_burstcount [i] == 1'b1)
                        begin
                            dataid_array_valid    [i] <=  1'b0;
                            mux_dataid_array_done [i] <=  1'b1;
                        end
                        else
                        begin
                            mux_dataid_array_done [i] <=  1'b0;
                        end
                        if (~dataid_array_valid[i])
                        begin
                            err_dataid_array_invalidread <= 1;
                        end
                    end
                    else
                    begin
                        mux_dataid_array_done [i] <=  1'b0;
                    end
                end
            end
            always @ (*)
            begin
                if (update_data_if_burstcount_greatereq[i])
                begin
                    mux_notify_data_if_valid [i] = 1'b1;
                end
                else
                begin
                    mux_notify_data_if_valid [i] = 1'b0;
                end
            end
        end
    endgenerate
    assign notify_data_if_valid     = update_data_if_burstcount_greatereq_burstcount_list;
    assign notify_data_if_burstcount= burstcount_list_read_data;
    assign read_data_if_burstcount  = mux_read_data_if_burstcount   [CFG_DATAID_ARRAY_DEPTH-1];
    assign read_data_if_done        = |mux_dataid_array_done;
    assign update_cmd_if_address_blocked= |mux_update_cmd_if_address_blocked;
    generate
        if (CFG_DRAM_WLAT_GROUP == 1) 
        begin
            always @ (*)
            begin
                read_data_if_address = mux_read_data_if_address [CFG_DATAID_ARRAY_DEPTH - 1];
            end
        end
        else
        begin
            wire                                 rdata_address_list_read;
            wire [CFG_BUFFER_ADDR_WIDTH - 1 : 0] rdata_address_list_read_data;
            wire                                 rdata_address_list_read_data_valid;
            wire                                 rdata_address_list_write;
            wire [CFG_BUFFER_ADDR_WIDTH - 1 : 0] rdata_address_list_write_data;
            assign rdata_address_list_read       = read_data_if_valid_last;
            assign rdata_address_list_write      = read_data_if_valid_first;
            assign rdata_address_list_write_data = mux_read_data_if_address [CFG_DATAID_ARRAY_DEPTH - 1];
            alt_mem_ddrx_list
            # (
                .CTL_LIST_WIDTH             (CFG_BUFFER_ADDR_WIDTH),
                .CTL_LIST_DEPTH             (CFG_DRAM_WLAT_GROUP),
                .CTL_LIST_INIT_VALUE_TYPE   ("ZERO"),
                .CTL_LIST_INIT_VALID        ("INVALID")
            )
            rdata_address_list
            (
                .ctl_clk                    (ctl_clk),
                .ctl_reset_n                (ctl_reset_n),
                .list_get_entry_valid       (rdata_address_list_read_data_valid),
                .list_get_entry_ready       (rdata_address_list_read),
                .list_get_entry_id          (rdata_address_list_read_data),
                .list_get_entry_id_vector   (),
                .list_put_entry_valid       (rdata_address_list_write),
                .list_put_entry_ready       (),
                .list_put_entry_id          (rdata_address_list_write_data)
            );
            for (i = 0;i < CFG_LOCAL_WLAT_GROUP;i = i + 1)
            begin : rdata_if_address_per_dqs_group
                always @ (*)
                begin
                    if (read_data_if_valid_first_vector [i])
                    begin
                        read_data_if_address [(i + 1) * CFG_BUFFER_ADDR_WIDTH - 1 : i * CFG_BUFFER_ADDR_WIDTH] = rdata_address_list_write_data;
                    end
                    else
                    begin
                        read_data_if_address [(i + 1) * CFG_BUFFER_ADDR_WIDTH - 1 : i * CFG_BUFFER_ADDR_WIDTH] = rdata_address_list_read_data;
                    end
                end
            end
        end
    endgenerate
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            write_data_if_address_blocked <= 0;
        end
        else
        begin
            write_data_if_address_blocked <= |mux_write_data_if_address_blocked;
        end
    end
    always @ (*) 
    begin
        mux_tbp_data_ready                          [0] = (mux_notify_data_if_valid          [0]) ? dataid_array_tbp_id     [0] : {CFG_TBP_NUM{1'b0}};
        mux_notify_data_if_burstcount               [0] = (mux_notify_data_if_valid          [0]) ? dataid_array_burstcount [0] : 0;
        mux_read_data_if_address                    [0] = (read_data_if_data_id_vector_first [0]) ? dataid_array_address    [0] : 0;
        mux_read_data_if_burstcount                 [0] = (read_data_if_data_id_vector_first [0]) ? dataid_array_burstcount [0] : 0;
        mux_write_data_if_address_blocked           [0] = (dataid_array_data_ready[0] & ( (dataid_array_address[0] == write_data_if_nextaddress) | (dataid_array_address[0] == write_data_if_address) ) );
        if (update_cmd_if_nextmaxaddress_wrapped)
        begin
            mux_update_cmd_if_address_blocked   [0] =  (dataid_array_valid[0] & ~( (dataid_array_address[0] < update_cmd_if_address) & (dataid_array_address[0] > update_cmd_if_nextmaxaddress) ));
        end
        else
        begin
            mux_update_cmd_if_address_blocked   [0] =  (dataid_array_valid[0] &  ( (dataid_array_address[0] >= update_cmd_if_address) & (dataid_array_address[0] <= update_cmd_if_nextmaxaddress) ));
        end
    end
    genvar j;
    generate
        for (j = 1; j < CFG_DATAID_ARRAY_DEPTH; j = j + 1)
        begin : gen_mux_dataid_array_output
            always @ (*) 
            begin
                mux_tbp_data_ready                  [j] = mux_tbp_data_ready            [j-1] | ( (mux_notify_data_if_valid          [j]) ? dataid_array_tbp_id     [j] : {CFG_TBP_NUM{1'b0}} );
                mux_notify_data_if_burstcount       [j] = mux_notify_data_if_burstcount [j-1] | ( (mux_notify_data_if_valid          [j]) ? dataid_array_burstcount [j] : 0 );
                mux_read_data_if_address            [j] = mux_read_data_if_address      [j-1] | ( (read_data_if_data_id_vector_first [j]) ? dataid_array_address    [j] : 0 );
                mux_read_data_if_burstcount         [j] = mux_read_data_if_burstcount   [j-1] | ( (read_data_if_data_id_vector_first [j]) ? dataid_array_burstcount [j] : 0 );
                mux_write_data_if_address_blocked   [j] = (dataid_array_data_ready[j] & ( (dataid_array_address[j] == write_data_if_nextaddress) | (dataid_array_address[j] == write_data_if_address) ) );
                if (update_cmd_if_nextmaxaddress_wrapped)
                begin
                    mux_update_cmd_if_address_blocked   [j] =  (dataid_array_valid[j] & ~( (dataid_array_address[j] < update_cmd_if_address) & (dataid_array_address[j] > update_cmd_if_nextmaxaddress) ));
                end
                else
                begin
                    mux_update_cmd_if_address_blocked   [j] =  (dataid_array_valid[j] &  ( (dataid_array_address[j] >= update_cmd_if_address) & (dataid_array_address[j] <= update_cmd_if_nextmaxaddress) ));
                end
            end
        end
    endgenerate
    assign notify_tbp_data_ready    = mux_tbp_data_ready [CFG_DATAID_ARRAY_DEPTH-1];
    assign update_cmd_if_accepted = update_cmd_if_ready & update_cmd_if_valid;
    assign update_cmd_if_nextaddress = update_cmd_if_address + update_cmd_if_burstcount;
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            update_cmd_if_address                <= 0;
            update_cmd_if_nextmaxaddress         <= 0;
            update_cmd_if_nextmaxaddress_wrapped <= 1'b0;
            write_data_if_address                <= 0;
            write_data_if_nextaddress            <= 0;
        end
        else
        begin
            if (update_cmd_if_accepted)
            begin
                update_cmd_if_address                <= update_cmd_if_nextaddress;
                update_cmd_if_nextmaxaddress         <= update_cmd_if_nextaddress + cfg_max_cmd_burstcount_2x;
                if (update_cmd_if_nextaddress > (update_cmd_if_nextaddress + cfg_max_cmd_burstcount_2x))
                begin
                    update_cmd_if_nextmaxaddress_wrapped <= 1'b1;
                end
                else
                begin
                    update_cmd_if_nextmaxaddress_wrapped <= 1'b0;
                end
            end
            if (write_data_if_accepted)
            begin
                write_data_if_address     <= write_data_if_address + 1;
                write_data_if_nextaddress <= write_data_if_address + 2;
            end
            else
            begin
                write_data_if_nextaddress <= write_data_if_address + 1;
            end
        end
    end  
    always @ (*) 
    begin
        if (update_cmd_if_accepted)
        begin
            update_cmd_if_next_unnotified_burstcount = update_cmd_if_unnotified_burstcount + update_cmd_if_burstcount - mux_notify_data_if_burstcount [CFG_DATAID_ARRAY_DEPTH-1];
        end
        else
        begin
            update_cmd_if_next_unnotified_burstcount = update_cmd_if_unnotified_burstcount - mux_notify_data_if_burstcount [CFG_DATAID_ARRAY_DEPTH-1];
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            update_cmd_if_unnotified_burstcount <= 0;
        end
        else
        begin
            update_cmd_if_unnotified_burstcount <= update_cmd_if_next_unnotified_burstcount;
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            buffer_cmd_unallocated_counter <= {CFG_BUFFER_ADDR_WIDTH{1'b1}};
            err_buffer_cmd_unallocated_counter_overflow <= 0;
        end
        else
        begin
            if (update_cmd_if_accepted & read_data_if_valid_last)
            begin
                buffer_cmd_unallocated_counter <= buffer_cmd_unallocated_counter- update_cmd_if_burstcount + 1;
            end
            else if (update_cmd_if_accepted)
            begin
                {err_buffer_cmd_unallocated_counter_overflow, buffer_cmd_unallocated_counter} <= buffer_cmd_unallocated_counter - update_cmd_if_burstcount;
            end
            else if (read_data_if_valid_last)
            begin
                buffer_cmd_unallocated_counter <= buffer_cmd_unallocated_counter + 1;
            end
            else
            begin
                buffer_cmd_unallocated_counter <= buffer_cmd_unallocated_counter;
            end
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            update_cmd_if_ready <= 0;
        end
        else
        begin
            update_cmd_if_ready <= ~update_cmd_if_address_blocked;
        end
    end
    assign  write_data_if_accepted    = write_data_if_ready & write_data_if_valid;
    always @ (*) 
    begin
        if (write_data_if_address_blocked)
        begin
            write_data_if_ready = 1'b0;
        end
        else 
        begin
            write_data_if_ready = ~buffer_valid_counter_full & ~partial_be_when_no_cmd_tracked;
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            read_data_if_datavalid <= 0;
        end
        else
        begin
            read_data_if_datavalid <= read_data_if_valid;
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            buffer_valid_counter              <= 0;
            buffer_valid_counter_full         <= 1'b0;
            err_buffer_valid_counter_overflow <= 0;
        end
        else
        begin
            if (write_data_if_accepted & read_data_if_valid_last)
            begin
                buffer_valid_counter      <= buffer_valid_counter;
                buffer_valid_counter_full <= buffer_valid_counter_full;
            end
            else if (write_data_if_accepted)
            begin
                {err_buffer_valid_counter_overflow, buffer_valid_counter} <= buffer_valid_counter + 1;
                if (buffer_valid_counter == {{(CFG_BUFFER_ADDR_WIDTH - 1){1'b1}}, 1'b0}) 
                begin
                    buffer_valid_counter_full <= 1'b1;
                end
                else
                begin
                    buffer_valid_counter_full <= 1'b0;
                end
            end
            else if (read_data_if_valid_last)
            begin
                buffer_valid_counter      <= buffer_valid_counter - 1;
                buffer_valid_counter_full <= 1'b0;
            end
            else
            begin
                buffer_valid_counter      <= buffer_valid_counter;
                buffer_valid_counter_full <= buffer_valid_counter_full;
            end
        end
    end
    always @ (*) 
    begin
        if (partial_be_when_no_cmd_tracked)
        begin
            notify_tbp_data_partial_be = update_data_if_valid & (|update_data_if_burstcount_same);
        end
        else
        begin
            notify_tbp_data_partial_be = partial_be_detected;
        end    
    end
    assign update_data_bc_gt_update_cmd_unnotified_bc = ~update_data_if_valid | (update_data_if_burstcount >= update_cmd_if_unnotified_burstcount);
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            partial_be_when_no_cmd_tracked <= 1'b0;
            partial_be_detected <= 1'b0;
        end
        else
        begin
            if (cfg_enable_partial_be_notification)
            begin
                if (partial_be_when_no_cmd_tracked)
                begin
                    if (update_data_if_valid & ~notify_data_if_valid)
                    begin
                        partial_be_when_no_cmd_tracked <= 1'b0;
                    end
                    else if (update_data_if_valid & notify_data_if_valid)
                    begin
                        if (|update_data_if_burstcount_same)
                        begin
                            partial_be_when_no_cmd_tracked <= 1'b0;
                            partial_be_detected <= write_data_if_accepted & write_data_if_partial_dm;
                        end
                        else
                        begin
                        end
                    end
                end
                else if (partial_be_detected & ~notify_data_if_valid)
                begin
                    partial_be_detected <= partial_be_detected;
                end
                else
                begin
                    partial_be_when_no_cmd_tracked <= write_data_if_accepted & write_data_if_partial_dm & update_data_bc_gt_update_cmd_unnotified_bc;
                    partial_be_detected <= write_data_if_accepted & write_data_if_partial_dm;
                end
            end
            else
            begin
                partial_be_when_no_cmd_tracked <= 1'b0;
                partial_be_detected <= 1'b0;
            end
        end
    end
endmodule
