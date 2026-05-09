module acl_multi_fanout_adaptor #(
    parameter integer DATA_WIDTH = 32,  
    parameter integer NUM_FANOUTS = 2   
)
(
    input logic clock,
    input logic resetn,
    input logic [DATA_WIDTH-1:0] data_in,   
    input logic valid_in,
    output logic stall_out,
    output logic [DATA_WIDTH-1:0] data_out,    
    output logic [NUM_FANOUTS-1:0] valid_out,
    input logic [NUM_FANOUTS-1:0] stall_in
);
    genvar i;
    logic [NUM_FANOUTS-1:0] consumed, true_stall_in;
    assign true_stall_in = stall_in & ~consumed;
    assign stall_out = |true_stall_in;
    generate
        if( DATA_WIDTH > 0 )
            assign data_out = data_in;
    endgenerate
    assign valid_out = {NUM_FANOUTS{valid_in}} & ~consumed;
    generate
        for( i = 0; i < NUM_FANOUTS; i = i + 1 )
        begin:c
            always @( posedge clock or negedge resetn )
                if( !resetn )
                    consumed[i] <= 1'b0;
                else if( valid_in & (|true_stall_in) )
                begin
                    if( ~stall_in[i] )
                        consumed[i] <= 1'b1;
                end
                else
                    consumed[i] <= 1'b0;
        end
    endgenerate
endmodule
