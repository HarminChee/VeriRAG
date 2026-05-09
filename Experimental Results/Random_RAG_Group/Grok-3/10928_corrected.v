module ALU (
    input wire test_i,
    input wire clk,
    input wire rst,
    input wire [5:0] opcode, funct,
    input wire [31:0] in1, in2,
    output reg [31:0] result,
    output reg rw
);
    wire [31:0] sum, diff, product, sum_or;
    wire carryout, carry;
    wire dft_clk;

    thirtytwobitadder ADD (
        .a(in1),
        .b(in2),
        .carryout(carryout),
        .sum(sum),
        .cin(1'b0)
    );

    thirtytwobitsubtractor SUBTRACT (
        .a(in1),
        .b(in2),
        .carry(carry),
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

    assign dft_clk = test_i ? clk : clk;

    always @(posedge dft_clk or posedge rst) begin
        if (rst) begin
            result <= 32'b0;
            rw <= 1'b0;
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