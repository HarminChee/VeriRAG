module ALU(opcode, funct, in1, in2, result, rw, clk);
input clk;
input [5:0] opcode, funct;
input [31:0] in1, in2;
output reg [31:0] result;
output reg rw;
wire [31:0] sum, diff, product, sum_or;
wire carryout, carry;

thirtytwobitadder ADD (.a(in1), .b(in2), .cout(carryout), .sum(sum), .cin(1'b0));
thirtytwobitsubtractor SUBTRACT (.a(in1), .b(in2), .cout(carry), .diff(diff), .cin(1'b0));
AND prod (.a(in1), .b(in2), .out(product));
OR orop (.a(in1), .b(in2), .out(sum_or));

always @(*) begin
    rw = 1'b0;
    case(opcode)
        6'b000000: begin
            case(funct)
                6'b100000: result = sum;
                6'b100010: result = diff;
                6'b100100: result = product;
                6'b100101: result = sum_or;
                default: result = 32'b0;
            endcase
            rw = 1'b1;
        end
        6'b100011: begin
            result = sum;
            rw = 1'b1;
        end
        6'b101011: begin
            result = sum;
            rw = 1'b0;
        end
        6'b000100: begin
            if (diff == 32'b0) begin
                result = diff;
            end else begin
                result = 32'b0;
            end
            rw = 1'b0;
        end
        default: result = 32'b0;
    endcase
end

endmodule

module thirtytwobitadder(a, b, cout, sum, cin);
input [31:0] a, b;
input cin;
output [31:0] sum;
output cout;
assign {cout, sum} = a + b + cin;
endmodule

module thirtytwobitsubtractor(a, b, cout, diff, cin);
input [31:0] a, b;
input cin;
output [31:0] diff;
output cout;
assign {cout, diff} = a - b - cin;
endmodule

module AND(a, b, out);
input [31:0] a, b;
output [31:0] out;
assign out = a & b;
endmodule

module OR(a, b, out);
input [31:0] a, b;
output [31:0] out;
assign out = a | b;
endmodule