module wb_master #(
    parameter                              ADDR_WIDTH       = 16,    
    parameter                              DATA_WIDTH       = 32,    
    parameter                              BASE_ADDRESS     = 'h0F00,    
    parameter                              RANGE            = 'h0200    
) (
    input          [ADDR_WIDTH-1:0]     mem_address_in,    
    input          [DATA_WIDTH-1:0]     mem_data_in,    
    input                               mem_master_rdy,    
    input                               mem_we_in,    
    output reg     [DATA_WIDTH-1:0]     mem_data_out,    
    output reg                          mem_slave_rdy,    
    input                               wb_ack_i,    
    input          [DATA_WIDTH-1:0]     wb_dat_i,    
    input                               wb_err_i,    
    output reg     [ADDR_WIDTH-1:0]     wb_adr_o,    
    output reg                          wb_cyc_o,    
    output reg     [DATA_WIDTH-1:0]     wb_dat_o,    
    output reg                          wb_stb_o,    
    output reg                          wb_we_o,    
    input                               clk_i,    
    input                               rst_i    
);
    reg [2:0] state;
    parameter [2:0]
        S_CMD               = 3'd0, 
        S_WRITE_INIT        = 3'd1, 
        S_WAIT_WRITE_ACK    = 3'd2, 
        S_READ_INIT         = 3'd3, 
        S_WAIT_READ_ACK     = 3'd4, 
        S_DEASSERT     = 3'd5;
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1) begin
            state <= S_CMD;
            wb_dat_o <= 0;
            wb_cyc_o <= 0;
            wb_stb_o <= 0;
            wb_we_o <= 0;
            wb_adr_o <=  0;
            mem_data_out <= 0;
            mem_slave_rdy <= 0;
        end
        else begin
        case(state)
            S_CMD: begin
                if (mem_master_rdy == 1'b1) begin
                    if (mem_we_in == 1'b1) begin
                        state <=  S_WRITE_INIT;
                    end
                    else begin
                        state <=  S_READ_INIT;
                    end
                end
            end
            S_WRITE_INIT: begin
                wb_cyc_o <= 1;
                wb_stb_o <= 1;
                wb_we_o <= 1;
                wb_dat_o <= mem_data_in;
                wb_adr_o <= mem_address_in;
                state <= S_WAIT_WRITE_ACK;
            end
            S_WAIT_WRITE_ACK: begin
                if (wb_err_i == 1'b1 || wb_ack_i == 1'b1) begin
                    wb_cyc_o <= 0;
                    wb_stb_o <= 0;
                    wb_we_o <= 0;
                    mem_slave_rdy <= 1;
                    state <=  S_DEASSERT;
                end
            end
            S_READ_INIT: begin
                wb_cyc_o <= 1;
                wb_stb_o <= 1;
                wb_we_o <= 0;
                wb_adr_o <= mem_address_in;
                state <= S_WAIT_READ_ACK;
            end
            S_WAIT_READ_ACK: begin
                if (wb_err_i == 1'b1 || wb_ack_i == 1'b1) begin
                    wb_cyc_o <= 0;
                    wb_stb_o <= 0;
                    wb_we_o <= 0;
                    mem_slave_rdy <= 1;
                    if (wb_err_i == 1'b1) begin
                        mem_data_out <= 0;
                    end
                    else begin
                        mem_data_out <= wb_dat_i;
                    end
                    state <=  S_DEASSERT;
                end
            end
            S_DEASSERT: begin
                state <= S_CMD;
                mem_slave_rdy <= 0;
            end
            default: begin
                $display("ERROR: Unkown state: %d", state);
            end
        endcase
        end
    end
endmodule
