`timescale 1ns / 1ps
module mccomp (
    input wire stp,
    input wire rst,
    input wire clk,
    input wire [1:0] dptype,
    input wire [4:0] regselect,
    output wire exec,
    output wire [5:0] initype,
    output wire [3:0] node,
    output wire [7:0] segment
);

wire stp_debounced;
wire reset;
wire resetn;
wire mem_clk;
wire [31:0] a,b,alu,adr,tom,fromm,pc,ir,dpdata;
wire [2:0] q;
reg [15:0] digit;
reg [15:0] count = 0;
wire wmem;

pbdebounce p0(
    .clk(clk),
    .pb_1(stp),
    .pb_out(stp_debounced)
);

pbdebounce p1(
    .clk(clk),
    .pb_1(rst),
    .pb_out(reset)
);

assign resetn = ~reset;
assign mem_clk = clk;

mccpu mc_cpu (
    .clock(clk),
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
    .addr(adr[7:2]),
    .din(tom),
    .clk(mem_clk),
    .we(wmem),
    .dout(fromm)
);

display dp(
    .clk(clk),
    .digit(digit),
    .node(node),
    .segment(segment)
);

always @(posedge clk) begin
    if (stp_debounced)
        count <= count + 1;
end

always @* begin
    case (dptype)
        2'b00: digit <= dpdata[15:0];
        2'b01: digit <= dpdata[31:16];
        2'b10: digit <= pc[15:0];
        2'b11: digit <= count;
    endcase
end

assign exec = clk;
assign initype = ir[31:26];

endmodule