module wb_slave #(
    parameter                              ADDR_WIDTH       = 16,    
    parameter                              DATA_WIDTH       = 32,    
    parameter                              DATA_COUNT       = 8,    
    parameter                              BASE_ADDRESS     = 'h0F00    
) (
    input          [ADDR_WIDTH-1:0]     adr_i,    
    input                               cyc_i,    
    input          [DATA_WIDTH-1:0]     dat_i,    
    input                               stb_i,    
    input                               we_i,    
    output reg                          ack_o,    
    output reg     [DATA_WIDTH-1:0]     dat_o,    
    output reg                          err_o,    
    input                               clk_i,    
    input                               rst_i    
);
    localparam AUB = 8;
    localparam AU_IN_DATA = DATA_WIDTH/AUB;
    localparam MEMORY_SIZE = DATA_COUNT*4;
    reg [AUB-1:0] memory [MEMORY_SIZE-1:0];
    integer index;
    reg [0:0] state;
    parameter [0:0]
        S_WAIT      = 1'd0, 
        S_DEASSERT  = 1'd1; 
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1) begin
            ack_o <= 0; 
            dat_o <= 0; 
            err_o <= 0; 
            state <= S_WAIT; 
        end
        else begin
            if (state == S_WAIT) begin
                if ( cyc_i == 1 && stb_i == 1 ) begin
                    if (adr_i < BASE_ADDRESS + MEMORY_SIZE && adr_i >= BASE_ADDRESS) begin
                        ack_o <= 1;
                        if ( we_i == 1 ) begin
                            for (index = 0; index < AU_IN_DATA; index = index + 1) begin
                                memory[adr_i - BASE_ADDRESS + index] <= dat_i[(index*AUB)+:AUB];
                            end
                        end
                        else begin
                            for (index = 0; index < AU_IN_DATA; index = index + 1) begin
                                dat_o[(index*AUB)+:AUB] <= memory[adr_i - BASE_ADDRESS + index];
                            end
                        end
                    end
                    else begin
                        err_o <= 1;
                    end
                    state <= S_DEASSERT;
                end
            end
            else if (state == S_DEASSERT) begin
                ack_o <= 0;
                err_o <= 0;
                state <= S_WAIT;
            end
            else
                $display("ERROR: Unkown state: %d", state);
        end
    end
endmodule
