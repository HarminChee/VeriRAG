`define S_SGR32_RD_0		3'b000
`define S_SGR32_RD_1		3'b001
`define S_SGR32_RD_2		3'b010
`define S_SGR32_RD_3		3'b011
`define S_SGR32_RD_WAIT		3'b100
`define S_SGR32_CAP_0		3'b000
`define S_SGR32_CAP_1		3'b001
`define S_SGR32_CAP_2		3'b010
`define S_SGR32_CAP_3		3'b011
`define S_SGR32_CAP_RDY		3'b100
`timescale 1ns/1ns
`define S_SGR32_RD_0		3'b000
`define S_SGR32_RD_1		3'b001
`define S_SGR32_RD_2		3'b010
`define S_SGR32_RD_3		3'b011
`define S_SGR32_RD_WAIT		3'b100
`define S_SGR32_CAP_0		3'b000
`define S_SGR32_CAP_1		3'b001
`define S_SGR32_CAP_2		3'b010
`define S_SGR32_CAP_3		3'b011
`define S_SGR32_CAP_RDY		3'b100
`timescale 1ns/1ns
module sg_list_reader_32 #(
	parameter C_DATA_WIDTH = 9'd32
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
reg		[2:0]				rRdState=`S_SGR32_RD_0, _rRdState=`S_SGR32_RD_0;
reg		[2:0]				rCapState=`S_SGR32_CAP_0, _rCapState=`S_SGR32_CAP_0;
reg		[C_DATA_WIDTH-1:0]	rData={C_DATA_WIDTH{1'd0}}, _rData={C_DATA_WIDTH{1'd0}};
reg		[63:0]				rAddr=64'd0, _rAddr=64'd0;
reg		[31:0]				rLen=0, _rLen=0;
reg							rFifoValid=0, _rFifoValid=0;
reg							rDataValid=0, _rDataValid=0;
assign BUF_DATA_REN = !rRdState[2]; 
assign VALID = rCapState[2]; 
assign EMPTY = (BUF_DATA_EMPTY & !rRdState[2]); 
assign ADDR = rAddr;
assign LEN = rLen;
always @ (posedge CLK) begin
	rRdState <= #1 (RST ? `S_SGR32_RD_0 : _rRdState);
	rCapState <= #1 (RST ? `S_SGR32_CAP_0 : _rCapState);
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
	`S_SGR32_CAP_0: begin
		if (rDataValid) begin
			_rAddr[31:0] = rData;
			_rCapState = `S_SGR32_CAP_1;
		end
	end
	`S_SGR32_CAP_1: begin
		if (rDataValid) begin
			_rAddr[63:32] = rData;
			_rCapState = `S_SGR32_CAP_2;
		end
	end
	`S_SGR32_CAP_2: begin
		if (rDataValid) begin
			_rLen = rData;
			_rCapState = `S_SGR32_CAP_3;
		end
	end
	`S_SGR32_CAP_3: begin
		if (rDataValid)
			_rCapState = `S_SGR32_CAP_RDY;
	end
	`S_SGR32_CAP_RDY: begin
		if (REN)
			_rCapState = `S_SGR32_CAP_0;
	end
	default: begin
		_rCapState = `S_SGR32_CAP_0;
	end
	endcase
	case (rRdState)
	`S_SGR32_RD_0: begin 
		if (!BUF_DATA_EMPTY)
			_rRdState = `S_SGR32_RD_1;
	end
	`S_SGR32_RD_1: begin 
		if (!BUF_DATA_EMPTY)
			_rRdState = `S_SGR32_RD_2;
	end
	`S_SGR32_RD_2: begin 
		if (!BUF_DATA_EMPTY)
			_rRdState = `S_SGR32_RD_3;
	end
	`S_SGR32_RD_3: begin 
		if (!BUF_DATA_EMPTY)
			_rRdState = `S_SGR32_RD_WAIT;
	end
	`S_SGR32_RD_WAIT: begin 
		if (REN)
			_rRdState = `S_SGR32_RD_0;
	end
	default: begin
		_rRdState = `S_SGR32_RD_0;
	end
	endcase
end
endmodule
