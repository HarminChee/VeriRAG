module dma_fifo_oneshot(
	input  wire clk,
	input  wire rst_n,
	input  wire wr_stb, 
	input  wire rd_stb, 
	output wire wdone, 
	output wire w511,  
	output wire rdone, 
	output wire empty, 
	input  wire [7:0] wd, 
	output wire [7:0] rd  
);
	reg [9:0] wptr;
	reg [9:0] rptr;
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		wptr = 10'd0;
	else if( wr_stb )
		wptr <= wptr + 10'd1;
	assign w511 = &wptr[8:0];
	always @(posedge clk, negedge rst_n)
	if( !rst_n )
		rptr = 10'd0;
	else if( rd_stb )
		rptr <= rptr + 10'd1;
	assign wdone = wptr[9];
	assign rdone = rptr[9];
	assign empty = ( wptr==rptr );
	mem512b fifo512_oneshot_mem512b
	(
		.clk(clk),
		.rdaddr(rptr[8:0]),
		.dataout(rd),
		.re(rd_stb),
		.wraddr(wptr[8:0]),
		.datain(wd),
		.we(wr_stb)
	);
endmodule
