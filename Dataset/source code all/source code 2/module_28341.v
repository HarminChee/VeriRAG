module Rx_Module (CLK, reset, Start, iRX_BUF_FRAME_TYPE, iALERT, iRECEIVE_DETECT, iRECEIVE_BYTE_COUNT, 
					Tx_State_Machine_ACTIVE, Unexpected_GoodCRC, CC_Busy, CC_IDLE, Data_In, oALERT, 
					oRECEIVE_BYTE_COUNT, oGoodCRC_to_PHY, oDIR_WRITE, oDATA_to_Buffer);
input wire CC_Busy, CC_IDLE;
input wire CLK;
input wire [7:0] Data_In;
input wire [15:0] iALERT; 
input wire [7:0] iRECEIVE_BYTE_COUNT;
input wire [7:0] iRECEIVE_DETECT;
input wire [7:0] iRX_BUF_FRAME_TYPE; 
input wire reset;
input wire Start;
input wire Tx_State_Machine_ACTIVE;
input wire Unexpected_GoodCRC;
output reg [15:0] oALERT;
output reg [7:0] oDATA_to_Buffer;
output reg [7:0] oDIR_WRITE;
output reg oGoodCRC_to_PHY;
output reg [7:0] oRECEIVE_BYTE_COUNT;
reg [15:0] nxt_oALERT;
reg [7:0] nxt_oDATA_to_Buffer;
reg [7:0] nxt_oDIR_WRITE;
reg nxt_oGoodCRC_to_PHY;
reg [7:0] nxt_oRECEIVE_BYTE_COUNT;
reg [5:0] nxt_State;
wire PHY_Reset;
reg [5:0] state;
assign PHY_Reset = (iRX_BUF_FRAME_TYPE[2:0] == 3'b110) || (iALERT[3] == 1);
localparam IDLE = 6'b000001;
localparam PRL_Rx_Wait_for_PHY_message = 6'b000010;
localparam PRL_Rx_Message_Discard = 6'b000100;
localparam PRL_RX_Send_GoodCRC = 6'b001000;
localparam PRL_RX_Report_SOP = 6'b010000;
parameter max_iRECEIVE_BYTE_COUNT = 31; 
always @(posedge CLK) begin 
	if (~reset) begin
		state <= IDLE; 
		oDIR_WRITE <= 8'b0;
		oALERT <= 16'b0;
		oRECEIVE_BYTE_COUNT <= 0;
		oGoodCRC_to_PHY <= 0;
		oDATA_to_Buffer <= 8'b0;
	end else begin
		state <= nxt_State;
		oDIR_WRITE <= nxt_oDIR_WRITE;
		oALERT <= nxt_oALERT;
		oRECEIVE_BYTE_COUNT <= nxt_oRECEIVE_BYTE_COUNT;
		oGoodCRC_to_PHY <= nxt_oGoodCRC_to_PHY;
		oDATA_to_Buffer <= nxt_oDATA_to_Buffer;
	end 
end 
always @ (*) begin
	nxt_State <= state;
	nxt_oGoodCRC_to_PHY <= oGoodCRC_to_PHY;
	nxt_oDIR_WRITE <= oDIR_WRITE;
	nxt_oALERT <= oALERT;
	nxt_oRECEIVE_BYTE_COUNT <= oRECEIVE_BYTE_COUNT;
	nxt_oGoodCRC_to_PHY <= oGoodCRC_to_PHY;
	nxt_oDATA_to_Buffer <= oDATA_to_Buffer;
	case (state)
		IDLE: begin
			if (!PHY_Reset && !Start) begin 
				nxt_State <= IDLE; 
			end else begin
				nxt_State <= PRL_Rx_Wait_for_PHY_message;
			end
		end 
		PRL_Rx_Wait_for_PHY_message: begin
			if (iALERT[10]) begin 
				nxt_State <= PRL_Rx_Wait_for_PHY_message; 
			end else begin
				if (iRECEIVE_DETECT & 8'b1) begin 
					nxt_State <= PRL_Rx_Message_Discard;
				end else begin
					nxt_State <= IDLE; 
				end
			end
		end 
		PRL_Rx_Message_Discard: begin
			if (Tx_State_Machine_ACTIVE) begin 
				nxt_oALERT <= oALERT | 16'b100000; 
				nxt_oRECEIVE_BYTE_COUNT <= 0; 
			end else begin
				nxt_oALERT <= oALERT;
			end
			if (Unexpected_GoodCRC) begin 
				nxt_State <= PRL_RX_Report_SOP;
			end else begin
				nxt_State <= PRL_RX_Send_GoodCRC;
			end
		end 
		PRL_RX_Send_GoodCRC: begin
			nxt_oGoodCRC_to_PHY <= 1; 
			if (CC_Busy || CC_IDLE || Tx_State_Machine_ACTIVE) begin
				nxt_State <= PRL_Rx_Wait_for_PHY_message;	
			end else begin 
				nxt_State <= PRL_RX_Report_SOP;	
			end
		end 
		PRL_RX_Report_SOP: begin
			nxt_oDATA_to_Buffer <= Data_In; 
			nxt_oDIR_WRITE <= iRECEIVE_BYTE_COUNT + 8'h31; 
			nxt_oRECEIVE_BYTE_COUNT <= iRECEIVE_BYTE_COUNT + 1; 
			if (oRECEIVE_BYTE_COUNT == 31) begin 
				nxt_oALERT <= oALERT | 16'b10000000000; 
			end else begin
				nxt_oALERT <= oALERT & 16'b1111101111111111; 
			end
			nxt_oALERT <= oALERT | 16'b000100; 
			nxt_State <= PRL_Rx_Wait_for_PHY_message;
		end 
	endcase 	
end 
endmodule
