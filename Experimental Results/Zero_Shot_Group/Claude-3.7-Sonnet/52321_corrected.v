`timescale 1ns / 1ps
module mccomp (
    input wire stp,rst,clk,
    input wire [1:0] dptype,
    input wire [4:0] regselect,
    output wire exec,
    output wire [5:0] initype,
    output wire [3:0] node,
    output wire [7:0] segment
);

wire clock,reset,resetn,mem_clk;
wire [31:0] a,b,alu,adr,tom,fromm,pc,ir,dpdata;
wire [2:0] q;
reg [15:0] digit,count;

initial begin
    count = 0;
end

pbdebounce p0(clk,stp,clock);

always @(posedge clock) 
    count <= count + 1;

pbdebounce p1(clk,rst,reset);

assign resetn = ~reset;
assign mem_clk = clk;

mccpu mc_cpu (
    .clock(clock),
    .resetn(resetn),
    .fromm(fromm),
    .pc(pc),
    .ir(ir),
    .a(a),
    .b(b),
    .alu(alu),
    .wmem(wmem),
    .adr(adr),
    .tom(tom),
    .q(q),
    .regselect(regselect),
    .dpdata(dpdata)
);

mcmem memory (
    .adr(adr[7:2]),
    .tom(tom),
    .mem_clk(mem_clk),
    .wmem(wmem),
    .fromm(fromm)
);

display dp(
    .clk(clk),
    .digit(digit),
    .node(node),
    .segment(segment)
);

always @(*) begin
    case (dptype)
        2'b00: digit <= dpdata[15:0];
        2'b01: digit <= dpdata[31:16];
        2'b10: digit <= pc[15:0];
        2'b11: digit <= count;
    endcase
end

assign exec = clock;
assign initype = ir[31:26];

endmodule