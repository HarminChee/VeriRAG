module ALU_corrected_acn (
    input clk,
    input rst,  // Added reset as primary input
    input [5:0] opcode, 
    input [5:0] funct,
    input [31:0] in1, 
    input [31:0] in2,
    output reg [31:0] result,
    output reg rw
);
    wire [31:0] sum, diff, product, sum_or;
    wire carryout, carry;
    
    thirtytwobitadder ADD (
        .a(in1), 
        .b(in2), 
        .cout(carryout), 
        .sum(sum), 
        .cin(1'b0)
    );
    
    thirtytwobitsubtractor SUBTRACT (
        .a(in1), 
        .b(in2), 
        .cout(carry), 
        .diff(diff), 
        .cin(1'b0)
    );
    
    AND prod (
        .a(in1), 
        .b(in2), 
        .out(product)
    );
    
    OR orop (
        .a(in1), 
        .b(in2), 
        .out(sum_or)
    );
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 32'b0;
            rw <= 1'b0;
        end
        else begin
            case (opcode)
                6'b000000: begin
                    case (funct)
                        6'b100000: begin
                            result <= sum;
                            rw <= 1'b1;
                        end
                        6'b100010: begin
                            result <= diff;
                            rw <= 1'b1;
                        end
                        6'b100100: begin
                            result <= product;
                            rw <= 1'b1;
                        end
                        6'b100101: begin
                            result <= sum_or;
                            rw <= 1'b1;
                        end
                        default: begin
                            result <= result;
                            rw <= 1'b0;
                        end
                    endcase
                end
                6'b100011: begin
                    result <= sum;
                    rw <= 1'b1;
                end
                6'b101011: begin
                    result <= sum;
                    rw <= 1'b0;
                end
                6'b000100: begin
                    if (diff == 32'b0) begin
                        result <= diff;
                    end
                    rw <= 1'b0;
                end
                default: begin
                    result <= result;
                    rw <= 1'b0;
                end
            endcase
        end
    end
endmodule