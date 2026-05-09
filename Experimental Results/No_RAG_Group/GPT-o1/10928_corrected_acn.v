module ALU_corrected_acn(opcode, funct, in1, in2, result, rw, clk);
  input clk;
  input [5:0] opcode, funct;
  input [31:0] in1, in2;
  output reg [31:0] result;
  output reg rw;

  wire [31:0] sum, diff, product, sum_or;
  wire carry, carryout;

  // Example external modules assumed:
  // thirtytwobitadder(in1, in2, cin, sum, cout)
  // thirtytwobitsubtractor(in1, in2, bin, diff, bout)
  // AND(in1, in2, out)
  // OR(in1, in2, out)
  thirtytwobitadder       ADD       (in1, in2, 1'b0, sum,      carryout);
  thirtytwobitsubtractor  SUBTRACT  (in1, in2, 1'b0, diff,     carry);
  AND                     prod      (in1, in2, product);
  OR                      orop      (in1, in2, sum_or);

  always @(*) begin
    // Default assignments
    rw     = 1'b0;
    result = 32'b0;

    case(opcode)
      6'b000000: begin
        case(funct)
          6'b100000: begin // ADD
            result = sum;
            rw     = 1'b1;
          end
          6'b100010: begin // SUB
            result = diff;
            rw     = 1'b1;
          end
          6'b100100: begin // AND
            result = product;
            rw     = 1'b1;
          end
          6'b100101: begin // OR
            result = sum_or;
            rw     = 1'b1;
          end
          default: begin
            result = 32'b0;
          end
        endcase
      end

      6'b100011: begin // LW
        result = sum;
        rw     = 1'b1;
      end

      6'b101011: begin // SW
        result = sum;
      end

      6'b000100: begin // BEQ
        if(diff == 32'b0) begin
          result = diff;
        end
      end

      default: begin
        result = 32'b0;
      end
    endcase
  end
endmodule