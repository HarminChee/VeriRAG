`timescale 1ns / 1ps
`timescale 1ns / 1ps
module CIRCUIT6(a, b, c, d, e, f, g, h, num, Clk, Rst, avg);
    input Clk, Rst;
    input [15:0] a, b, c, d, e, f, g, h, num;
    output [15:0] avg;
    reg [15:0] r1, r2, r3, r4, r5, r6, r7;
    wire [15:0] avgwire;
    wire [31:0] t1, t2, t3, t4, t5, t6, t7;
    ADD #(16) add1(a, b, t1);
    ADD #(16) add2(r1, c, t2);
    ADD #(16) add3(r2, d, t3);
    ADD #(16) add4(r3, e, t4);
    ADD #(16) add5(r4, f, t5);
    ADD #(16) add6(r5, g, t6);
    ADD #(16) add7(r6, h, t7);
    DIV #(16) div1(r7, num, avgwire);
    REG #(16) reg8(avgwire, Clk, Rst, avg);
    always @(r1, r2, r3, r4, r5, r6, r7) begin
        r1 <= t1;
        r2 <= t2;
        r3 <= t3;
        r4 <= t4;
        r5 <= t5;
        r6 <= t6;
        r7 <= t7;
    end
endmodule
