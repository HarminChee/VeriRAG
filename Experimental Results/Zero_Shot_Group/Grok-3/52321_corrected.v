`timescale 1ns / 1ps
module mccomp (
    input wire stp, rst, clk,
    input wire [1:0] dptype,
    input wire [4:0] regselect,
    output wire exec,
    output wire [5:0] initype,
    output wire [3:0] node,
    output wire [7:0] segment
    );
    wire clock, reset, resetn, mem_clk;
    wire [31:0] a, b, alu, adr, tom, fromm, pc, ir, dpdata;
    wire [2:0] q;
    reg [15:0] digit;
    reg [15:0] count = 0;
    wire wmem;
    
    pbdebounce p0(clk, stp, clock);
    always @(posedge clock) count = count + 1;
    pbdebounce p1(clk, rst, reset);
    assign resetn = ~reset;
    assign mem_clk = clk;
    
    mccpu mc_cpu (clock, resetn, fromm, pc, ir, a, b, alu, wmem, adr, tom, q, regselect, dpdata);
    mcmem memory (adr[7:2], tom, mem_clk, wmem, fromm);
    display dp(clk, digit, node, segment);
    
    always @(*) begin
        case (dptype)
            2'b00: digit = dpdata[15:0];
            2'b01: digit = dpdata[31:16];
            2'b10: digit = pc[15:0];
            2'b11: digit = count;
        endcase
    end
    
    assign exec = clock;
    assign initype = ir[31:26];
endmodule