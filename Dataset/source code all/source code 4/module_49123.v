module alt_mem_ddrx_buffer_manager
# (
    parameter
        CFG_BUFFER_ADDR_WIDTH         =   6
)
(
    ctl_clk,
    ctl_reset_n,
    writeif_ready,
    writeif_valid,
    writeif_address,
    writeif_address_blocked,
    buffwrite_valid,
    buffwrite_address,
    readif_valid,
    readif_address,
    buffread_valid,
    buffread_datavalid,
    buffread_address
);
    localparam CTL_BUFFER_DEPTH             =   two_pow_N(CFG_BUFFER_ADDR_WIDTH);
    input                                           ctl_clk;
    input                                           ctl_reset_n;
    output                                          writeif_ready;
    input                                           writeif_valid;
    input  [CFG_BUFFER_ADDR_WIDTH-1:0]              writeif_address;
    input                                           writeif_address_blocked;
    output                                          buffwrite_valid;
    output  [CFG_BUFFER_ADDR_WIDTH-1:0]             buffwrite_address;
    input                                           readif_valid;
    input   [CFG_BUFFER_ADDR_WIDTH-1:0]             readif_address;
    output                                          buffread_valid;
    output                                          buffread_datavalid;
    output  [CFG_BUFFER_ADDR_WIDTH-1:0]             buffread_address;
    wire                                            ctl_clk;
    wire                                            ctl_reset_n;
    reg                                             writeif_ready;
    wire                                            writeif_valid;
    wire     [CFG_BUFFER_ADDR_WIDTH-1:0]            writeif_address;
    wire                                            writeif_address_blocked;
    wire                                            buffwrite_valid;
    wire     [CFG_BUFFER_ADDR_WIDTH-1:0]            buffwrite_address;
    wire                                            readif_valid;
    wire    [CFG_BUFFER_ADDR_WIDTH-1:0]             readif_address;
    wire                                            buffread_valid;
    reg                                             buffread_datavalid;
    wire    [CFG_BUFFER_ADDR_WIDTH-1:0]             buffread_address;
    wire                                            writeif_accepted;
    reg     [CTL_BUFFER_DEPTH-1:0]                  mux_writeif_ready;
    reg     [CTL_BUFFER_DEPTH-1:0]                  buffer_valid_array;    
    reg     [CFG_BUFFER_ADDR_WIDTH-1:0]             buffer_valid_counter;
    reg                                             err_buffer_valid_counter_overflow;
    assign  writeif_accepted    = writeif_ready & writeif_valid;
    assign  buffwrite_address   = writeif_address;
    assign  buffwrite_valid     = writeif_accepted;
    assign  buffread_address    = readif_address;
    assign  buffread_valid      = readif_valid;
    always @ (*) 
    begin
        if (writeif_address_blocked)
        begin
            writeif_ready = 1'b0;
        end
        else 
        begin
            writeif_ready = ~&buffer_valid_counter;
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            buffread_datavalid <= 0;
        end
        else
        begin
            buffread_datavalid <= buffread_valid;
        end
    end
    always @ (posedge ctl_clk or negedge ctl_reset_n) 
    begin
        if (~ctl_reset_n)
        begin
            buffer_valid_counter <= 0;
            err_buffer_valid_counter_overflow <= 0;
        end
        else
        begin
            if (writeif_accepted & readif_valid)
            begin
                buffer_valid_counter <= buffer_valid_counter;
            end
            else if (writeif_accepted)
            begin
                {err_buffer_valid_counter_overflow, buffer_valid_counter} <= buffer_valid_counter + 1;
            end
            else if (readif_valid)
            begin
                buffer_valid_counter <= buffer_valid_counter - 1;
            end
            else
            begin
                buffer_valid_counter <= buffer_valid_counter;
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
