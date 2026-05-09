`timescale 1ns/1ns
`timescale 1ns/1ns
module fifo_packer_32 (
	input CLK,
	input RST,
	input [31:0] DATA_IN,		
	input DATA_IN_EN,			
	input DATA_IN_DONE,			
	input DATA_IN_ERR,			
	input DATA_IN_FLUSH,		
	output [31:0] PACKED_DATA,	
	output PACKED_WEN,			
	output PACKED_DATA_DONE,	
	output PACKED_DATA_ERR,		
	output PACKED_DATA_FLUSHED	
);
reg					rPackedDone=0, _rPackedDone=0;
reg					rPackedErr=0, _rPackedErr=0;
reg					rPackedFlush=0, _rPackedFlush=0;
reg					rPackedFlushed=0, _rPackedFlushed=0;
reg		[31:0]		rDataIn=64'd0, _rDataIn=64'd0;
reg					rDataInEn=0, _rDataInEn=0;
assign PACKED_DATA = rDataIn;
assign PACKED_WEN = rDataInEn;
assign PACKED_DATA_DONE = rPackedDone;
assign PACKED_DATA_ERR = rPackedErr;
assign PACKED_DATA_FLUSHED = rPackedFlushed;
always @ (posedge CLK) begin
	rPackedDone <= #1 (RST ? 1'd0 : _rPackedDone);
	rPackedErr <= #1 (RST ? 1'd0 : _rPackedErr);
	rPackedFlush <= #1 (RST ? 1'd0 : _rPackedFlush);
	rPackedFlushed <= #1 (RST ? 1'd0 : _rPackedFlushed);
	rDataIn <= #1 _rDataIn;
	rDataInEn <= #1 (RST ? 1'd0 : _rDataInEn);
end
always @ (*) begin
	_rDataIn = DATA_IN;
	_rDataInEn = DATA_IN_EN;
	_rPackedDone = DATA_IN_DONE;
	_rPackedErr = DATA_IN_ERR;
	_rPackedFlush = DATA_IN_FLUSH;
	_rPackedFlushed = rPackedFlush;
end
endmodule
