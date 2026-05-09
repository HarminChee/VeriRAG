module ALU(
    input [5:0] opcode,
    input [5:0] funct,
    input [31:0] in1,
    input [31:0] in2,
    output reg [31:0] result,
    output reg rw
    // input clk; // clk is not used in this combinational implementation
);

    // Internal signals for intermediate results
    wire [31:0] sum;
    wire [31:0] diff;
    wire [31:0] product;
    wire [31:0] sum_or;
    // Unused carry signals removed for clarity if using simple operators
    // wire carryout, carry;

    // Use standard Verilog operators for arithmetic/logic operations
    assign sum = in1 + in2;
    assign diff = in1 - in2;
    assign product = in1 & in2; // Bitwise AND
    assign sum_or = in1 | in2;  // Bitwise OR

    // Combinational logic block
    always @(*) begin
        // Default assignments to avoid latches and define behavior for unused opcodes/functs
        result = 32'b0;
        rw = 1'b0; // Default: do not write to register file

        // Decode based on opcode
        case (opcode)
            6'b000000: begin // R-type instructions
                // R-type instructions generally write back to the register file
                rw = 1'b1;
                case (funct)
                    6'b100000: result = sum;     // ADD
                    6'b100010: result = diff;    // SUB
                    6'b100100: result = product; // AND
                    6'b100101: result = sum_or;  // OR
                    default: begin
                        // Undefined funct code for R-type
                        result = 32'b0; // Or some other default/error value
                        rw = 1'b0;      // Don't write on undefined function
                    end
                endcase
            end
            6'b100011: begin // LW (Load Word) - ALU calculates address
                result = sum; // Address calculation: base + offset
                rw = 1'b1;    // LW instruction writes back to register file (data from memory)
            end
            6'b101011: begin // SW (Store Word) - ALU calculates address
                result = sum; // Address calculation: base + offset
                rw = 1'b0;    // SW instruction does not write back to register file
            end
            6'b000100: begin // BEQ (Branch if Equal) - ALU calculates difference
                result = diff; // Result holds difference for comparison (zero flag check usually external)
                rw = 1'b0;    // BEQ instruction does not write back to register file
                // The condition check (if diff == 0) is typically done outside the ALU
                // to control the PC, not to modify the ALU result itself.
            end
            // Add cases for other opcodes as needed
            default: begin
                // Undefined or unsupported opcode
                result = 32'b0;
                rw = 1'b0;
            end
        endcase
    end

endmodule