`define S_RXPORTREQ_RX_TX		2'b00
`define S_RXPORTREQ_TX_RX		2'b01
`define S_RXPORTREQ_ISSUE		2'b10
`timescale 1ns/1ns
`define S_RXPORTREQ_RX_TX		2'b00
`define S_RXPORTREQ_TX_RX		2'b01
`define S_RXPORTREQ_ISSUE		2'b10
`timescale 1ns/1ns
module rx_port_requester_mux (
	input RST,
	input CLK,
	input SG_RX_REQ,				
	input [9:0] SG_RX_LEN,			
	input [63:0] SG_RX_ADDR,		
	output SG_RX_REQ_PROC,			
	input SG_TX_REQ,				
	input [9:0] SG_TX_LEN,			
	input [63:0] SG_TX_ADDR,		
	output SG_TX_REQ_PROC,			
	input MAIN_REQ,					
	input [9:0] MAIN_LEN,			
	input [63:0] MAIN_ADDR,			
	output MAIN_REQ_PROC,			
	output RX_REQ,					
	input RX_REQ_ACK,				
	output [1:0] RX_REQ_TAG,		
	output [63:0] RX_REQ_ADDR,		
	output [9:0] RX_REQ_LEN,		
	output REQ_ACK					
);
reg									rRxReqAck=0, _rRxReqAck=0;
reg		[1:0]						rState=`S_RXPORTREQ_RX_TX, _rState=`S_RXPORTREQ_RX_TX;
reg		[9:0]						rLen=0, _rLen=0;
reg		[63:0]						rAddr=64'd0, _rAddr=64'd0;
reg									rSgRxAck=0, _rSgRxAck=0;
reg									rSgTxAck=0, _rSgTxAck=0;
reg									rMainAck=0, _rMainAck=0;
reg									rAck=0, _rAck=0;
assign SG_RX_REQ_PROC = rSgRxAck;
assign SG_TX_REQ_PROC = rSgTxAck;
assign MAIN_REQ_PROC = rMainAck;
assign RX_REQ = rState[1]; 
assign RX_REQ_TAG = {rSgTxAck, rSgRxAck};
assign RX_REQ_ADDR = rAddr;
assign RX_REQ_LEN = rLen;
assign REQ_ACK = rAck;
always @ (posedge CLK) begin
	rRxReqAck <= #1 (RST ? 1'd0 : _rRxReqAck);
end
always @ (*) begin
	_rRxReqAck = RX_REQ_ACK;
end
always @ (posedge CLK) begin
	rState <= #1 (RST ? `S_RXPORTREQ_RX_TX : _rState);
	rLen <= #1 _rLen;
	rAddr <= #1 _rAddr;
	rSgRxAck <= #1 _rSgRxAck;
	rSgTxAck <= #1 _rSgTxAck;
	rMainAck <= #1 _rMainAck;
	rAck <= #1 _rAck;
end
always @ (*) begin
	_rState = rState;
	_rLen = rLen;
	_rAddr = rAddr;
	_rSgRxAck = rSgRxAck;
	_rSgTxAck = rSgTxAck;
	_rMainAck = rMainAck;
	_rAck = rAck;
	case (rState)
	`S_RXPORTREQ_RX_TX: begin 
		if (SG_RX_REQ) begin
			_rLen = SG_RX_LEN;
			_rAddr = SG_RX_ADDR;
			_rSgRxAck = 1;
			_rAck = 1;
			_rState = `S_RXPORTREQ_ISSUE;
		end
		else if (SG_TX_REQ) begin
			_rLen = SG_TX_LEN;
			_rAddr = SG_TX_ADDR;
			_rSgTxAck = 1;
			_rAck = 1;
			_rState = `S_RXPORTREQ_ISSUE;
		end
		else if (MAIN_REQ) begin
			_rLen = MAIN_LEN;
			_rAddr = MAIN_ADDR;
			_rMainAck = 1;
			_rAck = 1;
			_rState = `S_RXPORTREQ_ISSUE;
		end
		else begin
			_rState = `S_RXPORTREQ_TX_RX;
		end
	end
	`S_RXPORTREQ_TX_RX: begin 
		if (SG_TX_REQ) begin
			_rLen = SG_TX_LEN;
			_rAddr = SG_TX_ADDR;
			_rSgTxAck = 1;
			_rAck = 1;
			_rState = `S_RXPORTREQ_ISSUE;
		end
		else if (SG_RX_REQ) begin
			_rLen = SG_RX_LEN;
			_rAddr = SG_RX_ADDR;
			_rSgRxAck = 1;
			_rAck = 1;
			_rState = `S_RXPORTREQ_ISSUE;
		end
		else if (MAIN_REQ) begin
			_rLen = MAIN_LEN;
			_rAddr = MAIN_ADDR;
			_rMainAck = 1;
			_rAck = 1;
			_rState = `S_RXPORTREQ_ISSUE;
		end
		else begin
			_rState = `S_RXPORTREQ_RX_TX;
		end
	end
	`S_RXPORTREQ_ISSUE: begin 
		_rAck = 0;
		if (rRxReqAck) begin
			_rSgRxAck = 0;
			_rSgTxAck = 0;
			_rMainAck = 0;
			if (rSgRxAck)
				_rState = `S_RXPORTREQ_TX_RX;
			else
				_rState = `S_RXPORTREQ_RX_TX;
		end
	end
	default: begin
		_rState = `S_RXPORTREQ_RX_TX;
	end
	endcase
end
endmodule
