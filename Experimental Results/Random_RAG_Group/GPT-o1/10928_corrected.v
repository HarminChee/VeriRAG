module ALU(opcode,funct,in1,in2,result,rw,clk);
input clk;
input [5:0] opcode, funct;
input [31:0] in1, in2;
output reg [31:0] result;
output reg rw;

wire [31:0] sum, diff, product, sum_or;
wire carryout, carry;

thirtytwobitadder ADD(
    .A(in1),
    .B(in2),
    .carryout(carryout),
    .sum(sum),
    .cin(1'b0)
);

thirtytwobitsubtractor SUBTRACT(
    .A(in1),
    .B(in2),
    .borrowout(carry),
    .diff(diff),
    .cin(1'b0)
);

AND prod(
    .A(in1),
    .B(in2),
    .Y(product)
);

OR orop(
    .A(in1),
    .B(in2),
    .Y(sum_or)
);

always @(*) begin
    rw = 1'b0;
    result = 32'b0;
    if(opcode == 6'b000000) begin
        case(funct)
            6'b100000: begin
                rw = 1'b1;
                result = sum;
            end
            6'b100010: begin
                rw = 1'b1;
                result = diff;
            end
            6'b100100: begin
                rw = 1'b1;
                result = product;
            end
            6'b100101: begin
                rw = 1'b1;
                result = sum_or;
            end
            default: begin
            end
        endcase
    end
    else if(opcode == 6'b100011) begin
        rw = 1'b1;
        result = sum;
    end
    else if(opcode == 6'b101011) begin
        rw = 1'b0;
        result = sum;
    end
    else if(opcode == 6'b000100) begin
        rw = 1'b0;
        if(diff == 32'b0) begin
            result = diff;
        end
    end
end
endmodule