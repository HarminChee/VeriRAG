module memory_controller #(
    parameter                              DATA_WIDTH       = 16,    
    parameter                              AUB              = 8,    
    parameter                              ADDR_WIDTH       = 16,    
    parameter                              MEMORY_SIZE      = 256,    
    parameter                              PERIPHERAL_BASE  = 128,    
    parameter                              REGISTER_COUNT   = 8,    
    parameter                              DATA_BYTES       = DATA_WIDTH/AUB,    
    parameter                              CONTROL_RANGE    = 'h40    
) (
    input                               clk_i,    
    input                               rst_i,    
    input                               sys_active_i,
    input          [ADDR_WIDTH-1:0]     sys_address_i,
    input          [DATA_WIDTH-1:0]     sys_data_i,
    input                               sys_we_i,
    output         [DATA_WIDTH-1:0]     sys_data_o,
    output                              sys_rdy_o,
    output                              sys_read_rdy_o,
    input          [DATA_WIDTH-1:0]     local_read_data,
    output         [ADDR_WIDTH-1:0]     local_address_o,
    output         [DATA_WIDTH-1:0]     local_write_data,
    output                              local_write_o,
    input          [DATA_WIDTH-1:0]     periph_data_i,
    input                               periph_slave_rdy,
    output reg     [ADDR_WIDTH-1:0]     periph_address_o,
    output reg     [DATA_WIDTH-1:0]     periph_data_o,
    output reg                          periph_master_rdy,
    output reg                          periph_we_o
);
    wire local_mem_active = sys_active_i && sys_address_i < PERIPHERAL_BASE;
    wire periph_mem_active = sys_active_i && sys_address_i >= PERIPHERAL_BASE;
    reg periph_mem_rdy;
    reg local_mem_rdy;
    reg [DATA_WIDTH-1:0] periph_load_value;
    reg read_operation;
    assign sys_data_o = periph_mem_active ? periph_load_value : local_read_data;
    assign local_write_data = sys_data_i;
    assign local_write_o = sys_we_i;
    assign local_address_o = sys_address_i;
    assign sys_rdy_o = local_mem_rdy | periph_mem_rdy;
    assign sys_read_rdy_o = sys_rdy_o && read_operation;
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1) begin
            local_mem_rdy <= 0;
            read_operation <= 0;
        end
        else begin
            if (local_mem_active) begin
                local_mem_rdy <= 1;
            end
            else begin
                local_mem_rdy <= 0;
            end
            if (local_mem_active || sys_active_i) begin
                read_operation <= ~sys_we_i;
            end
            else begin
                read_operation <= 0;
            end
        end
    end
    reg [1:0] state;
    parameter [1:0]
        S_WAIT          = 2'd0, 
        S_WAIT_WRITE     = 2'd1, 
        S_WAIT_READ     = 2'd2, 
        S_DEASSERT     = 2'd3;
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1) begin
            state <= S_WAIT;
            periph_mem_rdy <= 0;
            periph_load_value <= 0;
            periph_address_o <= 0;
            periph_data_o <= 0;
            periph_master_rdy <= 0;
            periph_we_o <= 0;
        end
        else begin
        case(state)
            S_WAIT: begin
                if (periph_mem_active == 1) begin
                    if (sys_we_i == 1) begin
                        periph_we_o <= 1;
                        periph_data_o <= sys_data_i;
                        state <= S_WAIT_WRITE;
                    end
                    else begin
                        state <= S_WAIT_READ;
                    end
                    periph_master_rdy <= 1;
                    periph_address_o <= sys_address_i - PERIPHERAL_BASE;
                end
            end
            S_WAIT_WRITE: begin
                periph_master_rdy <= 0;
                if (periph_slave_rdy == 1) begin
                    state <= S_DEASSERT;
                    periph_mem_rdy <= 1;
                    periph_we_o  <= 0;
                end
            end
            S_WAIT_READ: begin
                periph_master_rdy <= 0;
                if (periph_slave_rdy == 1) begin
                    state <= S_DEASSERT;
                    periph_load_value <= periph_data_i;
                    periph_mem_rdy <= 1;
                end
            end
            S_DEASSERT: begin
                state <= S_WAIT;
                periph_mem_rdy <= 0;
            end
            default: begin
                $display("ERROR: Unkown state: %d", state);
            end
        endcase
        end
    end
endmodule
