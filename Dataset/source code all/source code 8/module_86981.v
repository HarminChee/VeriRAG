module acl_token_fifo_counter 
#(
    parameter integer DEPTH = 32,           
    parameter integer STRICT_DEPTH = 1,     
    parameter integer ALLOW_FULL_WRITE = 0  
)
(
    clock,
    resetn,
    data_out,   
    valid_in,
    valid_out,
    stall_in,
    stall_out,
    empty,
    full
);
    localparam COUNTER_WIDTH = (STRICT_DEPTH == 0) ?
        ((DEPTH > 1 ? $clog2(DEPTH-1) : 0) + 2) :
        ($clog2(DEPTH) + 1);
    input clock;
    input resetn;
    output [COUNTER_WIDTH-1:0] data_out;
    input valid_in;
    output valid_out;
    input stall_in;
    output stall_out;
    output empty;
    output full;
    logic [COUNTER_WIDTH - 1:0] valid_counter ;
    logic incr, decr;
    logic [COUNTER_WIDTH - 2:0] token;
    logic token_max;
    assign data_out = token;
    assign token_max = (STRICT_DEPTH == 0) ?
        (~token[$bits(token) - 1] & token[$bits(token) - 2]) :
        (token == DEPTH - 1);
    assign empty = valid_counter[$bits(valid_counter) - 1];
    assign full = (STRICT_DEPTH == 0) ?
        (~valid_counter[$bits(valid_counter) - 1] & valid_counter[$bits(valid_counter) - 2]) :
        (valid_counter == DEPTH - 1);
    assign incr = valid_in & ~stall_out;      
    assign decr = valid_out & ~stall_in;      
    assign valid_out = ~empty;
    assign stall_out = ALLOW_FULL_WRITE ? (full & stall_in) : full;
    always @( posedge clock or negedge resetn )
        if( !resetn )
        begin
            valid_counter <= (STRICT_DEPTH == 0) ? (2^$clog2(DEPTH-1)) : DEPTH - 1; 
            token <= 0;
        end
        else
        begin
            valid_counter <= valid_counter + incr - decr;
            if (decr) 
              token <= token_max ? 0 : token+1;
        end 
endmodule
