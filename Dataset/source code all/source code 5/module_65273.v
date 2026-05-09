module alt_mem_ddrx_list
# (
    parameter
        CTL_LIST_WIDTH              =    3,        
        CTL_LIST_DEPTH              =    8,
        CTL_LIST_INIT_VALUE_TYPE    =    "INCR",   
        CTL_LIST_INIT_VALID         =    "VALID"   
)
(
    ctl_clk,
    ctl_reset_n,
    list_get_entry_valid,
    list_get_entry_ready,
    list_get_entry_id,   
    list_get_entry_id_vector,
    list_put_entry_valid,
    list_put_entry_ready,
    list_put_entry_id   
);
    input                               ctl_clk;
    input                               ctl_reset_n;
    input                               list_get_entry_ready;
    output                              list_get_entry_valid;
    output [CTL_LIST_WIDTH-1:0]         list_get_entry_id;
    output [CTL_LIST_DEPTH-1:0]         list_get_entry_id_vector;
    output                              list_put_entry_ready;
    input                               list_put_entry_valid;
    input [CTL_LIST_WIDTH-1:0]          list_put_entry_id;
    reg                                 list_get_entry_valid;
    wire                                list_get_entry_ready;
    reg  [CTL_LIST_WIDTH-1:0]           list_get_entry_id;   
    reg  [CTL_LIST_DEPTH-1:0]           list_get_entry_id_vector;
    wire                                list_put_entry_valid;
    reg                                 list_put_entry_ready;
    wire [CTL_LIST_WIDTH-1:0]           list_put_entry_id;
    reg [CTL_LIST_WIDTH-1:0]            list          [CTL_LIST_DEPTH-1:0];
    reg                                 list_v        [CTL_LIST_DEPTH-1:0];
    reg [CTL_LIST_DEPTH-1:0]            list_vector;
    wire                                list_get = list_get_entry_valid & list_get_entry_ready;
    wire                                list_put = list_put_entry_valid & list_put_entry_ready;
    always @ (*) 
    begin
        list_get_entry_valid     = list_v[0];
        list_get_entry_id        = list[0];
        list_get_entry_id_vector = list_vector;
        list_put_entry_ready     = ~list_v[CTL_LIST_DEPTH-1];
    end
    integer i; 
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            for (i = 0; i < CTL_LIST_DEPTH; i = i + 1'b1)
            begin
                if (CTL_LIST_INIT_VALUE_TYPE == "INCR")
                begin
                    list           [i]     <= i;
                end
                else
                begin
                    list           [i]     <= {CTL_LIST_WIDTH{1'b0}};
                end
                if (CTL_LIST_INIT_VALID == "VALID")
                begin
                    list_v         [i]     <= 1'b1;
                end
                else
                begin
                    list_v         [i]     <= 1'b0;
                end
            end
            list_vector <= {CTL_LIST_DEPTH{1'b0}};
        end
        else
        begin
            if (list_get)
            begin
                for (i = 1; i < CTL_LIST_DEPTH; i = i + 1'b1)
                begin
                    list_v     [i-1]   <=  list_v [i];
                    list       [i-1]   <=  list   [i];
                end
                    list_v     [CTL_LIST_DEPTH-1]   <=  0;
                for (i = 0; i < CTL_LIST_DEPTH;i = i + 1'b1)
                begin
                    if (i == list [1])
                    begin
                        list_vector [i] <= 1'b1;
                    end
                    else
                    begin
                        list_vector [i] <= 1'b0;
                    end
                end
            end
            if (list_put)
            begin
                if (~list_get)
                begin
                    for (i = 1; i < CTL_LIST_DEPTH; i = i + 1'b1)
                    begin
                        if ( list_v[i-1] & ~list_v[i])
                        begin
                            list_v     [i]   <=  1'b1;
                            list       [i]   <=  list_put_entry_id;
                        end
                    end
                    if (~list_v[0])
                    begin
                        list_v     [0]   <=  1'b1;
                        list       [0]   <=  list_put_entry_id;
                        for (i = 0; i < CTL_LIST_DEPTH;i = i + 1'b1)
                        begin
                            if (i == list_put_entry_id)
                            begin
                                list_vector [i] <= 1'b1;
                            end
                            else
                            begin
                                list_vector [i] <= 1'b0;
                            end
                        end
                    end
                end
                else
                begin
                    for (i = 1; i < CTL_LIST_DEPTH; i = i + 1'b1)
                    begin
                        if (list_v[i-1] & ~list_v[i])
                        begin
                            list_v     [i-1]   <=  1'b1;
                            list       [i-1]   <=  list_put_entry_id;
                        end
                    end
                    for (i = 0; i < CTL_LIST_DEPTH;i = i + 1'b1)
                    begin
                        if (list_v[0] & ~list_v[1])
                        begin
                            if (i == list_put_entry_id)
                            begin
                                list_vector [i] <= 1'b1;
                            end
                            else
                            begin
                                list_vector [i] <= 1'b0;
                            end
                        end
                        else
                        begin
                            if (i == list [1])
                            begin
                                list_vector [i] <= 1'b1;
                            end
                            else
                            begin
                                list_vector [i] <= 1'b0;
                            end
                        end
                    end
                end
            end
        end
    end
    function integer two_pow_N;
        input integer value;
    begin
        two_pow_N = 2 << (value-1);
    end
    endfunction
endmodule
