module wb_sum_buffer #(
    parameter                              BUFFER_SIZE      = 16,    
    parameter                              ADDR_WIDTH       = 16,    
    parameter                              DATA_WIDTH       = 32,    
    parameter                              BASE_ADDRESS     = 'h0F00,    
    parameter                              BUFFER_INDEX_WIDTH = $clog2(BUFFER_SIZE),    
    parameter                              COLUMN_WIDTH     = 1    
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
    reg [DATA_WIDTH-1:0] memory [BUFFER_SIZE-1:0];
    reg [DATA_WIDTH-1:0] result;
    reg [BUFFER_INDEX_WIDTH-1:0] index;
    localparam AUB = 8;
    localparam AU_IN_DATA = DATA_WIDTH/AUB;
    reg [0:0] state;
    integer lastValue;
    integer newValue;
    integer iterator;
    parameter [0:0]
        S_WAIT      = 1'd0, 
        S_DEASSERT  = 1'd1; 
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1) begin
            ack_o <= 0; 
            dat_o <= 0; 
            err_o <= 0; 
            state <= S_WAIT; 
            result <= 0;
            index <= 0;
            for (iterator = 0; iterator < BUFFER_SIZE; iterator = iterator +1) begin
                memory[iterator] <= 0;
            end
        end
        else begin
            if (state == S_WAIT) begin
                if ( cyc_i == 1 && stb_i == 1 ) begin
                    if (adr_i == BUFFER_SIZE+BASE_ADDRESS && we_i == 1) begin
                        ack_o <= 1;
                        lastValue = memory[index];
                        newValue = dat_i * COLUMN_WIDTH;
                        memory[index] <= newValue;
                        result <= result - lastValue + newValue;
                        if (index < BUFFER_SIZE-1) begin
                            index <= index + 1;
                        end
                        else begin
                            index <= 0;
                        end
                    end
                    else if (adr_i == BUFFER_SIZE+BASE_ADDRESS+AU_IN_DATA && we_i == 0) begin
                        ack_o <= 1;
                        dat_o = result;
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
