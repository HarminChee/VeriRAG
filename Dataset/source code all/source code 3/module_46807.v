`define S_SGR128_RD_0		1'b1
`define S_SGR128_RD_WAIT	1'b0
`define S_SGR128_CAP_0		1'b0
`define S_SGR128_CAP_RDY	1'b1
`timescale 1ns/1ns
`define S_SGR128_RD_0		1'b1
`define S_SGR128_RD_WAIT	1'b0
`define S_SGR128_CAP_0		1'b0
`define S_SGR128_CAP_RDY	1'b1
`timescale 1ns/1ns
module sg_list_reader_128 #(
	parameter C_DATA_WIDTH = 9'd128
)
(
	input CLK,
	input RST,
	input [C_DATA_WIDTH-1:0] BUF_DATA,	
	input BUF_DATA_EMPTY,				
	output BUF_DATA_REN,				
	output VALID,						
	output EMPTY,						
	input REN,							
	output [63:0] ADDR,					
	output [31:0] LEN					
);
reg							rRdState=`S_SGR128_RD_0, _rRdState=`S_SGR128_RD_0;
reg							rCapState=`S_SGR128_CAP_0, _rCapState=`S_SGR128_CAP_0;
reg		[C_DATA_WIDTH-1:0]	rData={C_DATA_WIDTH{1'd0}}, _rData={C_DATA_WIDTH{1'd0}};
reg		[63:0]				rAddr=64'd0, _rAddr=64'd0;
reg		[31:0]				rLen=0, _rLen=0;
reg							rFifoValid=0, _rFifoValid=0;
reg							rDataValid=0, _rDataValid=0;
assign BUF_DATA_REN = rRdState; 
assign VALID = rCapState; 
assign EMPTY = (BUF_DATA_EMPTY & rRdState); 
assign ADDR = rAddr;
assign LEN = rLen;
always @ (posedge CLK) begin
	rRdState <= #1 (RST ? `S_SGR128_RD_0 : _rRdState);
	rCapState <= #1 (RST ? `S_SGR128_CAP_0 : _rCapState);
	rData <= #1 _rData;
	rFifoValid <= #1 (RST ? 1'd0 : _rFifoValid);
	rDataValid <= #1 (RST ? 1'd0 : _rDataValid);
	rAddr <= #1 _rAddr;
	rLen <= #1 _rLen;
end
always @ (*) begin
	_rRdState = rRdState;
	_rCapState = rCapState;
	_rAddr = rAddr;
	_rLen = rLen;
	_rData = BUF_DATA;
	_rFifoValid = (BUF_DATA_REN & !BUF_DATA_EMPTY);
	_rDataValid = rFifoValid;
	case (rCapState)
	`S_SGR128_CAP_0: begin
		if (rDataValid) begin
			_rAddr = rData[63:0];
			_rLen = rData[95:64];
			_rCapState = `S_SGR128_CAP_RDY;
		end
	end
	`S_SGR128_CAP_RDY: begin
		if (REN)
			_rCapState = `S_SGR128_CAP_0;
	end
	endcase
	case (rRdState)
	`S_SGR128_RD_0: begin 
		if (!BUF_DATA_EMPTY)
			_rRdState = `S_SGR128_RD_WAIT;
	end
	`S_SGR128_RD_WAIT: begin 
		if (REN)
			_rRdState = `S_SGR128_RD_0;
	end
	endcase
end
endmodule
