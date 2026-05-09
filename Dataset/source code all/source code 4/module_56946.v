`define FIFO_DEPTH 15	
`define FIFO_HALF 8		
`define FIFO_BITS 4		
`define FIFO_WIDTH 8	
`define FIFO_DEPTH 15	
`define FIFO_HALF 8		
`define FIFO_BITS 4		
`define FIFO_WIDTH 8	
module bm_sfifo_rtl(
		clock,
		reset_n,
		data_in,
		read_n,
		write_n,
		data_out,
		full,
		empty,
		half);
input					clock;		
input					reset_n;	
input [`FIFO_WIDTH-1:0]	data_in; 	
input					read_n;	 	
input					write_n;	
output [`FIFO_WIDTH-1:0]	data_out;	
output						full;		
output						empty;		
output						half;		
wire					clock;
wire					reset_n;
wire [`FIFO_WIDTH-1:0]	data_in;
wire					read_n;
wire					write_n;
reg  [`FIFO_WIDTH-1:0]	data_out;
wire					full;
wire					empty;
wire					half;
reg [`FIFO_WIDTH-1:0]	fifo_mem[`FIFO_DEPTH-1:0];
reg [`FIFO_BITS-1:0]	counter;
reg [`FIFO_BITS-1:0]	rd_pointer;
reg [`FIFO_BITS-1:0]	wr_pointer;
assign full = (counter == `FIFO_DEPTH) ? 1'b1 : 1'b0;
assign empty = (counter == 0) ? 1'b1 : 1'b0;
assign half = (counter >= `FIFO_HALF) ? 1'b1 : 1'b0;
always @(posedge clock) begin
	if (~reset_n) begin
		rd_pointer <=  0;
		wr_pointer <=  0;
		counter <=  0;
	end
	else begin
		if (~read_n && write_n) begin
			counter <=  counter - 1;		
		end
		else if (~write_n && read_n) begin
			counter <=  counter + 1;		
		end
		if (~read_n) begin
			if (rd_pointer == `FIFO_DEPTH-1)
				rd_pointer <=  0;
			else
				rd_pointer <=  rd_pointer + 1;
		end
		if (~write_n) begin
			if (wr_pointer == `FIFO_DEPTH-1)
				wr_pointer <=  0;
			else
				wr_pointer <=  wr_pointer + 1;
		end
	end
end
always @(posedge clock) begin
	if (~read_n) begin
		data_out <=  fifo_mem[rd_pointer];
	end
	if (~write_n) begin
		fifo_mem[wr_pointer] <=  data_in;
	end
end
endmodule		
