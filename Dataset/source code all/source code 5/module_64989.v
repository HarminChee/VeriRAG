module alt_mem_ddrx_fifo
# (
    parameter
        CTL_FIFO_DATA_WIDTH              =    8,
        CTL_FIFO_ADDR_WIDTH              =    3
)
(
    ctl_clk,
    ctl_reset_n,
    get_valid,
    get_ready,
    get_data,   
    put_valid,
    put_ready,
    put_data   
);
    localparam CTL_FIFO_DEPTH              = (2 ** CTL_FIFO_ADDR_WIDTH);
    localparam CTL_FIFO_TYPE               = "SCFIFO";                      
    input                               ctl_clk;
    input                               ctl_reset_n;
    input                               get_ready;
    output                              get_valid;
    output [CTL_FIFO_DATA_WIDTH-1:0]    get_data;   
    output                              put_ready;
    input                               put_valid;
    input  [CTL_FIFO_DATA_WIDTH-1:0]    put_data;
    wire                                get_valid;
    wire                                get_ready;
    wire [CTL_FIFO_DATA_WIDTH-1:0]      get_data;   
    wire                                put_valid;
    wire                                put_ready;
    wire [CTL_FIFO_DATA_WIDTH-1:0]      put_data;
    reg [CTL_FIFO_DATA_WIDTH-1:0]       fifo          [CTL_FIFO_DEPTH-1:0];
    reg [CTL_FIFO_DEPTH-1:0]            fifo_v;
    wire                                fifo_get;
    wire                                fifo_put;
    wire                                fifo_empty;
    wire                                fifo_full;
    wire zero;
    assign fifo_get = get_valid & get_ready;
    assign fifo_put = put_valid & put_ready;
    assign zero = 1'b0;
    generate
    begin : gen_fifo_instance
        if (CTL_FIFO_TYPE == "SCFIFO")
        begin
            assign get_valid = ~fifo_empty;
            assign put_ready = ~fifo_full;
            scfifo	#(
                .add_ram_output_register    ( "ON"                  ),
                .intended_device_family     ( "Stratix IV"          ),
                .lpm_numwords               ( CTL_FIFO_DEPTH        ),
                .lpm_showahead              ( "ON"                  ),
                .lpm_type                   ( "scfifo"              ),
                .lpm_width                  ( CTL_FIFO_DATA_WIDTH   ),
                .lpm_widthu                 ( CTL_FIFO_ADDR_WIDTH   ),
                .overflow_checking          ( "OFF"                 ),
                .underflow_checking         ( "OFF"                 ),
                .use_eab                    ( "ON"                  )
            ) scfifo_component (
                .aclr                       (~ctl_reset_n),
                .clock                      (ctl_clk),
                .data                       (put_data),
                .rdreq                      (fifo_get),
                .wrreq                      (fifo_put),
                .empty                      (fifo_empty),
                .full                       (fifo_full),
                .q                          (get_data),
                .almost_empty               (),
                .almost_full                (),
                .sclr                       (zero),
                .usedw                      ()
            );
        end
        else 
        begin
            assign get_valid = fifo_v[0];
            assign put_ready = ~fifo_v[CTL_FIFO_DEPTH-1];
            assign get_data  = fifo[0];
                integer i; 
                always @ (posedge ctl_clk or negedge ctl_reset_n) 
                begin
                    if (~ctl_reset_n)
                    begin
                        for (i = 0; i < CTL_FIFO_DEPTH; i = i + 1'b1)
                        begin
                            fifo           [i]     <= 0;
                            fifo_v         [i]     <= 1'b0;
                        end
                    end
                    else
                    begin
                        if (fifo_get)
                        begin
                            for (i = 1; i < CTL_FIFO_DEPTH; i = i + 1'b1)
                            begin
                                fifo_v     [i-1]   <=  fifo_v [i];
                                fifo       [i-1]   <=  fifo   [i];
                            end
                                fifo_v     [CTL_FIFO_DEPTH-1]   <=  0;
                        end
                        if (fifo_put)
                        begin
                            if (~fifo_get)
                            begin
                                for (i = 1; i < CTL_FIFO_DEPTH; i = i + 1'b1)
                                begin
                                    if ( fifo_v[i-1] & ~fifo_v[i])
                                    begin
                                        fifo_v     [i]   <=  1'b1;
                                        fifo       [i]   <=  put_data;
                                    end
                                end
                                if (~fifo_v[0])
                                begin
                                    fifo_v     [0]   <=  1'b1;
                                    fifo       [0]   <=  put_data;
                                end
                            end
                            else
                            begin
                                for (i = 1; i < CTL_FIFO_DEPTH; i = i + 1'b1)
                                begin
                                    if ( fifo_v[i-1] & ~fifo_v[i])
                                    begin
                                        fifo_v     [i-1]   <=  1'b1;
                                        fifo       [i-1]   <=  put_data;
                                    end
                                end
                                if (~fifo_v[0])
                                begin
                                    $display("error - fifo underflow");
                                end
                            end
                        end
                    end
                end
        end
    end
    endgenerate
endmodule
