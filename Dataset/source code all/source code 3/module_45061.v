module ram_based_cam (clk,rst,start_write,waddr,wdata,wcare,
	lookup_data,match_lines,ready,match_found);
parameter DATA_BLOCKS = 4;  
parameter ADDR_WIDTH = 5; 
localparam DATA_PER_BLOCK = 8;   
localparam DATA_WIDTH = DATA_BLOCKS * DATA_PER_BLOCK;
localparam WORDS = (1 << ADDR_WIDTH);
input clk,rst,start_write;
input [ADDR_WIDTH-1:0] waddr;
input [DATA_WIDTH-1:0] wdata,wcare;
input [DATA_WIDTH-1:0] lookup_data;
output [WORDS-1:0] match_lines;
wire [WORDS-1:0] match_lines;
output ready;
output match_found;
wire match_found;
reg match_found_reg;
wire [DATA_BLOCKS * WORDS-1:0] block_match_lines;
wire [DATA_BLOCKS-1:0] block_ready;
genvar i,j;
generate
	for (i=0;i<DATA_BLOCKS;i=i+1)
	begin : db			
		cam_ram_block cr (
			.clk(clk),
			.rst(rst),
			.waddr(waddr),
			.wdata(wdata[DATA_PER_BLOCK*(i+1)-1:DATA_PER_BLOCK*i]),
			.wcare(wcare[DATA_PER_BLOCK*(i+1)-1:DATA_PER_BLOCK*i]),
			.start_write(start_write),
			.ready(block_ready[i]),
			.lookup_data(lookup_data[DATA_PER_BLOCK*(i+1)-1:DATA_PER_BLOCK*i]),
			.match_lines(block_match_lines[WORDS*(i+1)-1:WORDS*i])
		);
		defparam cr .DATA_WIDTH = DATA_PER_BLOCK;
		defparam cr .ADDR_WIDTH = ADDR_WIDTH;
	end
endgenerate
assign ready = block_ready[0];
generate
	for (j=0;j<WORDS;j=j+1) 
	begin : mta
		wire [DATA_BLOCKS-1:0] tmp_match;
		for (i=0;i<DATA_BLOCKS;i=i+1)
		begin : mtb
			assign tmp_match[i] = block_match_lines[WORDS*i+j];
		end
		assign match_lines[j] = &tmp_match;
	end
endgenerate
always@(match_lines) begin
	if (match_lines != 0) begin
		match_found_reg = 1'b1;
	end
	else
		match_found_reg = 1'b0;
end
assign match_found = match_found_reg;
endmodule
