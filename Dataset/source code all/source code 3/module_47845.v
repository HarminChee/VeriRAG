`timescale 1ns/1ns
`timescale 1ns/1ns
module chnl_tester #(
	parameter C_PCI_DATA_WIDTH = 9'd32
)
(
	input CLK,
	input RST,
	output CHNL_RX_CLK, 
	input CHNL_RX, 
	output CHNL_RX_ACK, 
	input CHNL_RX_LAST, 
	input [31:0] CHNL_RX_LEN, 
	input [30:0] CHNL_RX_OFF, 
	input [C_PCI_DATA_WIDTH-1:0] CHNL_RX_DATA, 
	input CHNL_RX_DATA_VALID, 
	output CHNL_RX_DATA_REN,
	output CHNL_TX_CLK, 
	output CHNL_TX, 
	input CHNL_TX_ACK, 
	output CHNL_TX_LAST, 
	output [31:0] CHNL_TX_LEN, 
	output [30:0] CHNL_TX_OFF, 
	output [C_PCI_DATA_WIDTH-1:0] CHNL_TX_DATA, 
	output CHNL_TX_DATA_VALID, 
	input CHNL_TX_DATA_REN
);
reg [C_PCI_DATA_WIDTH-1:0] rData={C_PCI_DATA_WIDTH{1'b0}};
reg [31:0] rLen=0;
reg [31:0] rCount=0;
reg [1:0] rState=0;
assign CHNL_RX_CLK = CLK;
assign CHNL_RX_ACK = (rState == 2'd1);
assign CHNL_RX_DATA_REN = (rState == 2'd1);
assign CHNL_TX_CLK = CLK;
assign CHNL_TX = (rState == 2'd3);
assign CHNL_TX_LAST = 1'd1;
assign CHNL_TX_LEN = rLen; 
assign CHNL_TX_OFF = 0;
assign CHNL_TX_DATA = rData;
assign CHNL_TX_DATA_VALID = (rState == 2'd3);
always @(posedge CLK or posedge RST) begin
	if (RST) begin
		rLen <= #1 0;
		rCount <= #1 0;
		rState <= #1 0;
		rData <= #1 0;
	end
	else begin
		case (rState)
		2'd0: begin 
			if (CHNL_RX) begin
				rLen <= #1 CHNL_RX_LEN;
				rCount <= #1 0;
				rState <= #1 2'd1;
			end
		end
		2'd1: begin 
			if (CHNL_RX_DATA_VALID) begin
				rData <= #1 CHNL_RX_DATA;
				rCount <= #1 rCount + (C_PCI_DATA_WIDTH/32);
			end
			if (rCount >= rLen)
				rState <= #1 2'd2;
		end
		2'd2: begin 
			rCount <= #1 (C_PCI_DATA_WIDTH/32);
			rState <= #1 2'd3;
		end
		2'd3: begin 
			if (CHNL_TX_DATA_REN & CHNL_TX_DATA_VALID) begin
				rData <= #1 {rCount + 4, rCount + 3, rCount + 2, rCount + 1};
				rCount <= #1 rCount + (C_PCI_DATA_WIDTH/32);
				if (rCount >= rLen)
					rState <= #1 2'd0;
			end
		end
		endcase
	end
end
endmodule
