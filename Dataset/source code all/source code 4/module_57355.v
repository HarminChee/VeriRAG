`timescale 1ns/1ns
`timescale 1ns/1ns
module fifo_packer_128 (
	input CLK,
	input RST,
	input [127:0] DATA_IN,		
	input [2:0] DATA_IN_EN,		
	input DATA_IN_DONE,			
	input DATA_IN_ERR,			
	input DATA_IN_FLUSH,		
	output [127:0] PACKED_DATA,	
	output PACKED_WEN,			
	output PACKED_DATA_DONE,	
	output PACKED_DATA_ERR,		
	output PACKED_DATA_FLUSHED	
);
reg		[2:0]		rPackedCount=0, _rPackedCount=0;
reg					rPackedDone=0, _rPackedDone=0;
reg					rPackedErr=0, _rPackedErr=0;
reg					rPackedFlush=0, _rPackedFlush=0;
reg					rPackedFlushed=0, _rPackedFlushed=0;
reg		[223:0]		rPackedData=224'd0, _rPackedData=224'd0;
reg		[127:0]		rDataIn=128'd0, _rDataIn=128'd0;
reg		[2:0]		rDataInEn=0, _rDataInEn=0;
reg		[127:0]		rDataMasked=128'd0, _rDataMasked=128'd0;
reg		[2:0]		rDataMaskedEn=0, _rDataMaskedEn=0;
assign PACKED_DATA = rPackedData[127:0];
assign PACKED_WEN = rPackedCount[2];
assign PACKED_DATA_DONE = rPackedDone;
assign PACKED_DATA_ERR = rPackedErr;
assign PACKED_DATA_FLUSHED = rPackedFlushed;
wire [127:0] wMask = {128{1'b1}}<<(32*rDataInEn);
wire [127:0] wDataMasked = ~wMask & rDataIn;
always @ (posedge CLK) begin
	rPackedCount <= #1 (RST ? 3'd0 : _rPackedCount);
	rPackedDone <= #1 (RST ? 1'd0 : _rPackedDone);
	rPackedErr <= #1 (RST ? 1'd0 : _rPackedErr);
	rPackedFlush <= #1 (RST ? 1'd0 : _rPackedFlush);
	rPackedFlushed <= #1 (RST ? 1'd0 : _rPackedFlushed);
	rPackedData <= #1 (RST ? 224'd0 : _rPackedData);
	rDataIn <= #1 _rDataIn;
	rDataInEn <= #1 (RST ? 3'd0 : _rDataInEn);
	rDataMasked <= #1 _rDataMasked;
	rDataMaskedEn <= #1 (RST ? 3'd0 : _rDataMaskedEn);
end
always @ (*) begin
	_rDataIn = DATA_IN;
	_rDataInEn = DATA_IN_EN;
	_rDataMasked = wDataMasked;
	_rDataMaskedEn = rDataInEn;
	if (rPackedFlush && (rPackedCount[1] | rPackedCount[0]))
		_rPackedCount = 4;
	else
		_rPackedCount = rPackedCount + rDataMaskedEn - {rPackedCount[2], 2'd0};
	if (rDataMaskedEn != 3'd0)
		_rPackedData = ((rPackedData>>(32*{rPackedCount[2], 2'd0})) | (rDataMasked<<(32*rPackedCount[1:0])));
	else
		_rPackedData = (rPackedData>>(32*{rPackedCount[2], 2'd0}));
	_rPackedDone = DATA_IN_DONE;
	_rPackedErr = DATA_IN_ERR;
	_rPackedFlush = DATA_IN_FLUSH;
	_rPackedFlushed = rPackedFlush;
end
endmodule
