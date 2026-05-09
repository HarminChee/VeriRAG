module ALU(opcode, funct, in1, in2, result, rw, clk, rst);
input clk;
input rst;  // Added reset as a primary input
input [5:0] opcode, funct;
input [31:0] in1, in2;
output [31:0] result; 
reg [31:0] result;
output rw;
reg rw;  	
wire [31:0] sum, diff, product, sum_or;

thirtytwobitadder ADD(in1, in2, carryout, sum, 1'b0);
thirtytwobitsubtractor SUBTRACT(in1, in2, carry, diff, 1'b0);
AND prod(in1, in2, product);
OR orop(in1, in2, sum_or);

always @(posedge clk or posedge rst)
begin
    if (rst) begin
        rw <= 1'b0;
        result <= 32'b0;
    end else begin
        if (opcode == 6'b000000) begin
            if (funct == 6'b100000) begin
                rw <= 1'b0;
                result <= sum;
                rw <= 1'b1;
            end
            if (funct == 6'b100010) begin
                rw <= 1'b0;
                result <= diff;
                rw <= 1'b1;
            end
            if (funct == 6'b100100) begin
                rw <= 1'b0;
                result <= product;
                rw <= 1'b1;
            end
            if (funct == 6'b100101) begin
                rw <= 1'b0;
                result <= sum_or;
                rw <= 1'b1;
            end
        end
        if (opcode == 6'b100011) begin
            rw <= 1'b0;
            result <= sum;
            rw <= 1'b1;
        end
        if (opcode == 6'b101011) begin
            rw <= 1'b0;
            result <= sum;
        end
        if (opcode == 6'b000100) begin
            rw <= 1'b0;
            if (diff == 32'b00000000000000000000000000000000) begin
                result <= diff;
            end
        end
    end
end
endmodule