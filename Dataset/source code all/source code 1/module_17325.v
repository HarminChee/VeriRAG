module alu #(
    parameter                              DATA_WIDTH       = 16,    
    parameter                              ALU_OP_WIDTH     = 3    
) (
    input          [ALU_OP_WIDTH-1:0]   alu_op_i,
    input          [DATA_WIDTH-1:0]     register_value_i1,
    input          [DATA_WIDTH-1:0]     register_value_i2,
    output reg     [DATA_WIDTH-1:0]     alu_result_o,
    output reg     [DATA_WIDTH-1:0]     alu_status_o
);
    parameter [ALU_OP_WIDTH-1:0]
        OP_PLUS         = 3'b000, 
        OP_MINUS        = 3'b001, 
        OP_MUL          = 3'b010, 
        OP_DIV          = 3'b011, 
        OP_CMP          = 3'b100;
    parameter [1:0]
        C_OUT           = 2'd3, 
        NEGATIVE        = 2'd2,
        ZERO            = 2'd1, 
        DIV_ZERO        = 2'd0;
    reg [DATA_WIDTH*2-1:0] operation_result;
    integer div_zero;
    always @* begin
        div_zero = 0;
        case(alu_op_i)
            OP_PLUS: operation_result <= register_value_i1 + register_value_i2;
            OP_MINUS: operation_result <= register_value_i1 - register_value_i2;
            OP_MUL: operation_result <= register_value_i1 * register_value_i2;
            OP_DIV: begin
                if (register_value_i2 == 0) begin
                    operation_result <= 0;
                    div_zero = 1;
                end
                else begin
                    operation_result <= register_value_i1 / register_value_i2;
                end
            end
            OP_CMP : operation_result <= register_value_i1 != register_value_i2;
            default: begin
                $display("ERROR: Unknown ALU operation: %d", alu_op_i);
                operation_result <= 0;
            end
        endcase
        alu_result_o <= operation_result[DATA_WIDTH-1:0];
        alu_status_o[DATA_WIDTH-1:C_OUT+1] = 0;
        alu_status_o[C_OUT] = operation_result[DATA_WIDTH];
        alu_status_o[NEGATIVE] = operation_result[DATA_WIDTH-1];
        alu_status_o[ZERO] = (operation_result == 0);
        alu_status_o[DIV_ZERO] = div_zero;
    end
endmodule
