`default_nettype none
`default_nettype none
module dualportram #(
    parameter WIDTH = 64,
    parameter DEPTH = 6
) (
    input   wire                clk_a,
    input   wire                we_a,
    input   wire    [DEPTH-1:0]  addr_a,
    input   wire    [WIDTH-1:0]  din_a,
    output  reg     [WIDTH-1:0]  dout_a,
    input   wire                clk_b,
    input   wire                we_b,
    input   wire    [DEPTH-1:0]  addr_b,
    input   wire    [WIDTH-1:0]  din_b,
    output  reg     [WIDTH-1:0]  dout_b
	);
reg [WIDTH-1:0] memarray [(2**DEPTH)-1:0];
always @(posedge clk_a) begin
    dout_a      <= memarray[addr_a];
    if(we_a) begin 
        dout_a      <= din_a;
        memarray[addr_a] <= din_a;
    end
end
always @(posedge clk_b) begin
    dout_b      <= memarray[addr_b];
    if(we_b) begin 
        dout_b      <= din_b;
        memarray[addr_b] <= din_b;
    end
end
endmodule
