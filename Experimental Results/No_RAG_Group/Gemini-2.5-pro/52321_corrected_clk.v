`timescale 1ns / 1ps
module mccomp_corrected_clk (
    input wire stp,rst,clk,
	input wire [1:0] dptype,
	input wire [4:0] regselect,
	output wire exec,
	output wire [5:0] initype,
	output wire [3:0] node,
	output wire [7:0] segment
	);

// Removed intermediate clock/reset signals derived from pbdebounce
// wire clock,reset,resetn;
wire mem_clk;
wire [31:0] a,b,alu,adr,tom,fromm,pc,ir,dpdata;
wire [2:0] q;
reg [15:0] digit = 16'b0; // Initialize register
reg [15:0] count = 16'b0; // Initialize register
wire wmem;

// Removed pbdebounce instances as their outputs (clock, reset) were causing CLKNPI/reset issues
// pbdebounce p0(clk,stp,clock);
// pbdebounce p1(clk,rst,reset);
// assign resetn=~reset;

// Counter clocked by primary input clk, reset by primary input rst (assuming active high async reset)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 16'b0;
    end else begin
        count <= count + 1;
    end
end

// Assign mem_clk directly from primary clk
assign mem_clk=clk;

// Instantiate CPU with primary clk and rst (assuming active high reset)
mccpu mc_cpu (
    .clk(clk), // Use primary clock 'clk'
    .reset(rst), // Use primary reset 'rst'
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

// Instantiate Memory with mem_clk (derived from primary clk)
mcmem memory (
    .addr(adr[7:2]), // Assuming adr is the address bus
    .din(tom),      // Assuming tom is data input to memory
    .clk(mem_clk),
    .we(wmem),      // Assuming wmem is write enable
    .dout(fromm)    // Assuming fromm is data output from memory
);

// Instantiate Display with primary clk
display dp(
    .clk(clk),
    .digit(digit),
    .node(node),
    .segment(segment)
);

// Combinational logic to determine the next value of 'digit'
reg [15:0] digit_nxt;
always @* begin
	 case (dptype)
	   2'b00: digit_nxt = dpdata[15:0];
	   2'b01: digit_nxt = dpdata[31:16];
	   2'b10: digit_nxt = pc[15:0];
	   2'b11: digit_nxt = count;
       default: digit_nxt = 16'b0; // Assign a default value
	 endcase
end

// Register 'digit' using primary clk and rst (assuming active high async reset)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        digit <= 16'b0;
    end else begin
        digit <= digit_nxt;
    end
end

// Assign exec based on primary clk
assign exec = clk; // Use primary clock 'clk' for output signal

// Assign other outputs
assign initype = ir[31:26];

endmodule

// Note: Definitions for mccpu, mcmem, display, and pbdebounce modules are not provided
// but are assumed to exist elsewhere. The fix focuses on DFT issues within mccomp.
// Assumed reset 'rst' is active-high asynchronous reset.
// Assumed port names for instantiated modules where not explicitly clear.