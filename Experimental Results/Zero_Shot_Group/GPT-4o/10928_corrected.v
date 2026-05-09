module ALU(opcode,funct,in1,in2,result,rw,clk);
input clk;
input [5:0] opcode, funct;
input [31:0] in1, in2;
output reg [31:0] result; 
output reg rw;  	
wire [31:0] sum, diff, product, sum_or;
wire carryout, carry;

thirtytwobitadder ADD(in1,in2,carryout,sum,1'b0);
thirtytwobitsubtractor SUBTRACT(in1,in2,carry,diff,1'b0);
AND prod(in1,in2,product);
OR orop(in1,in2,sum_or);

always @(*) begin
    rw = 1'b0; // Initialize rw to 0 at the start of the always block
    case(opcode)
        6'b000000: begin
            case(funct)
                6'b100000: result = sum;
                6'b100010: result = diff;
                6'b100100: result = product;
                6'b100101: result = sum_or;
                default: result = 32'b0;
            endcase
            rw = 1'b1; // Set rw to 1 after the operation
        end
        6'b100011: begin
            result = sum;
            rw = 1'b1;
        end
        6'b101011: begin
            result = sum;
        end
        6'b000100: begin
            if(diff == 32'b0) begin
                result = diff;
            end
        end
        default: begin
            result = 32'b0; // Default case to handle unspecified opcodes
            rw = 1'b0;
        end
    endcase
end

endmodule