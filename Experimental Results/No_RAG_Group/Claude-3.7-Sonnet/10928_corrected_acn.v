module ALU(opcode, funct, in1, in2, result, clk, rst);
input clk, rst;
input [5:0] opcode, funct;
input [31:0] in1, in2;
output [31:0] result;
reg [31:0] result;
output rw;
reg rw;
wire [31:0] sum, diff, product, sum_or;
wire carryout, carry;

thirtytwobitadder ADD(in1, in2, carryout, sum, 1'b0);
thirtytwobitsubtractor SUBTRACT(in1, in2, carry, diff, 1'b0);
AND prod(in1, in2, product);
OR orop(in1, in2, sum_or);

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    result <= 32'b0;
    rw <= 1'b0;
  end else begin
    if (opcode == 6'b000000) begin
      if (funct == 6'b100000) begin
        rw <= 1'b1;
        result <= sum;
      end else if (funct == 6'b100010) begin
        rw <= 1'b1;
        result <= diff;
      end else if (funct == 6'b100100) begin
        rw <= 1'b1;
        result <= product;
      end else if (funct == 6'b100101) begin
        rw <= 1'b1;
        result <= sum_or;
      end
    end else if (opcode == 6'b100011) begin
      rw <= 1'b1;
      result <= sum;
    end else if (opcode == 6'b101011) begin
      rw <= 1'b0;
      result <= sum;
    end else if (opcode == 6'b000100) begin
      rw <= 1'b0;
      if (diff == 32'b0) begin
        result <= diff;
      end
    end
  end
end

endmodule