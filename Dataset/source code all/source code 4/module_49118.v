`timescale 1ns/1ns
`timescale 1ns/1ns
module rx_port_channel_gate #(
	parameter C_DATA_WIDTH = 9'd64
)
(
	input RST,
	input CLK,
	input RX,								
	output RX_RECVD,						
	output RX_ACK_RECVD,					
	input RX_LAST,							
	input [31:0] RX_LEN,					
	input [30:0] RX_OFF,					
	output [31:0] RX_CONSUMED,				
	input [C_DATA_WIDTH-1:0] RD_DATA,		
	input RD_EMPTY,							
	output RD_EN,							
	input CHNL_CLK,							
	output CHNL_RX,							
	input CHNL_RX_ACK,						
	output CHNL_RX_LAST,					
	output [31:0] CHNL_RX_LEN,				
	output [30:0] CHNL_RX_OFF,				
	output [C_DATA_WIDTH-1:0] CHNL_RX_DATA,	
	output CHNL_RX_DATA_VALID,				
	input CHNL_RX_DATA_REN					
);
reg								rAckd=0, _rAckd=0;
reg								rChnlRxAck=0, _rChnlRxAck=0;
reg		[31:0]					rConsumed=0, _rConsumed=0;
reg		[31:0]					rConsumedStable=0, _rConsumedStable=0;
reg		[31:0]					rConsumedSample=0, _rConsumedSample=0;
reg								rCountRead=0, _rCountRead=0;
wire							wCountRead;
wire							wCountStable;
wire							wDataRead = (CHNL_RX_DATA_REN & CHNL_RX_DATA_VALID);
assign RX_CONSUMED = rConsumedSample;
assign RD_EN = CHNL_RX_DATA_REN;
assign CHNL_RX_LAST = RX_LAST;
assign CHNL_RX_LEN = RX_LEN;
assign CHNL_RX_OFF = RX_OFF;
assign CHNL_RX_DATA = RD_DATA;
assign CHNL_RX_DATA_VALID = !RD_EMPTY;
always @ (posedge CHNL_CLK) begin
	rChnlRxAck <= #1 (RST ? 1'd0 : _rChnlRxAck);
end
always @ (*) begin
	_rChnlRxAck = CHNL_RX_ACK;
end
cross_domain_signal rxSig (
	.CLK_A(CLK), 
	.CLK_A_SEND(RX), 
	.CLK_A_RECV(RX_RECVD), 
	.CLK_B(CHNL_CLK), 
	.CLK_B_RECV(CHNL_RX), 
	.CLK_B_SEND(CHNL_RX)
);
syncff rxAckSig (.CLK(CLK), .IN_ASYNC(rAckd), .OUT_SYNC(RX_ACK_RECVD));
always @ (posedge CHNL_CLK) begin
	rAckd <= #1 (RST ? 1'd0 : _rAckd);
end
always @ (*) begin
	_rAckd = (CHNL_RX & (rAckd | rChnlRxAck));
end
always @ (posedge CHNL_CLK) begin
	rConsumed <= #1 _rConsumed;
	rConsumedStable <= #1 _rConsumedStable;
	rCountRead <= #1 (RST ? 1'd0 : _rCountRead);
end
always @ (*) begin
	_rConsumed = (!CHNL_RX ? 0 : rConsumed + (wDataRead*(C_DATA_WIDTH/32)));
	_rConsumedStable = (wCountRead | rCountRead ? rConsumedStable : rConsumed);
	_rCountRead = !wCountRead;
end
always @ (posedge CLK) begin
	rConsumedSample <= #1 _rConsumedSample;
end
always @ (*) begin
	_rConsumedSample = (wCountStable ? rConsumedStable : rConsumedSample);
end
cross_domain_signal countSync (
	.CLK_A(CHNL_CLK), 
	.CLK_A_SEND(rCountRead), 
	.CLK_A_RECV(wCountRead), 
	.CLK_B(CLK), 
	.CLK_B_RECV(wCountStable), 
	.CLK_B_SEND(wCountStable)
);
endmodule
