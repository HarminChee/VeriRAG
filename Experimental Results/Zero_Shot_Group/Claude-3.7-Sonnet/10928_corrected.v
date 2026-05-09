module ALU(opcode, funct, in1, in2, result, rw, clk);
  input clk;
  input [5:0] opcode, funct;
  input [31:0] in1, in2;
  output reg [31:0] result;
  output reg rw;

  wire [31:0] sum, diff, product, sum_or;
  wire carryout, carry;

  thirtytwobitadder ADD( .a(in1), .b(in2), .cin(1'b0), .cout(carryout), .sum(sum));
  thirtytwobitsubtractor SUBTRACT( .a(in1), .b(in2), .borrow_in(1'b0), .difference(diff), .borrow_out(carry));
  AND prod( .in1(in1), .in2(in2), .out(product));
  OR orop( .in1(in1), .in2(in2), .out(sum_or));

  always @(*) begin
    rw = 1'b0;
    case (opcode)
      6'b000000: begin
        case (funct)
          6'b100000: begin
            result = sum;
          end
          6'b100010: begin
            result = diff;
          end
          6'b100100: begin
            result = product;
          end
          6'b100101: begin
            result = sum_or;
          end
          default: result = 32'bx;
        endcase
        rw = 1'b1;
      end
      6'b100011: begin
        result = sum;
        rw = 1'b1;
      end
      6'b101011: begin
        result = sum;
      end
      6'b000100: begin
        if (diff == 32'b0) begin
          result = diff;
        end else begin
          result = 32'bx;
        end
      end
      default: result = 32'bx;
    endcase
  end

endmodule