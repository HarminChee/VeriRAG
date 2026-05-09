module glb6850(
RESET_N,
RX_CLK,
TX_CLK,
E,
DI,
DO,
IRQ,
CS,
RW_N,
RS,
TXDATA,
RXDATA,
RTS,
CTS,
DCD
);
input					RESET_N;
input					RX_CLK;
input					TX_CLK;
input					E;
input		[7:0]		DI;
output	[7:0]		DO;
output				IRQ;
input					CS;
input					RS;
input					RW_N;
output				TXDATA;
input					RXDATA;
output				RTS;
input					CTS;
input					DCD;
reg		[7:0]		TX_BUFFER;
reg		[7:0]		TX_REG;
wire		[7:0]		RX_BUFFER;
reg		[7:0]		RX_REG;
wire		[7:0]		STATUS_REG;
reg		[7:0]		CTL_REG;
wire					TX_DONE;
reg					TX_DONE0;
reg					TX_DONE1;
reg					TX_START;
reg					TDRE;
reg					RDRF;
reg		[1:0]		READ_STATE;
wire					GOT_DATA;
reg					READY0;
reg					READY1;
reg		[1:0]		TX_CLK_DIV;
reg		[1:0]		RX_CLK_DIV;
wire					TX_CLK_X;
wire					RX_CLK_X;
reg					FRAME;
wire					FRAME_BUF;
reg					OVERRUN;
reg					PARITY;
wire		[1:0]		COUNTER_DIVIDE;
wire					WORD_SELECT;
wire		[1:0]		TX_CTL;
wire					RESET_X;
wire					STOP;
wire					PARITY_ERR;
wire					PAR_DIS;
always @ (negedge TX_CLK)
	TX_CLK_DIV <= TX_CLK_DIV +1'b1;
always @ (posedge RX_CLK)
	RX_CLK_DIV <= RX_CLK_DIV +1'b1;
assign TX_CLK_X = (COUNTER_DIVIDE == 2'b10) ?	TX_CLK_DIV[1]:
																TX_CLK;
assign RX_CLK_X = (COUNTER_DIVIDE == 2'b10) ?	RX_CLK_DIV[1]:
																RX_CLK;
assign RESET_X = (COUNTER_DIVIDE == 2'b11) ?	1'b0:
															RESET_N;
assign STATUS_REG = {!IRQ, PARITY, OVERRUN, FRAME, CTS, DCD, TDRE, RDRF};
assign DO =	RS		?	RX_REG[7:0]:
							STATUS_REG;
assign IRQ =	({CTL_REG[7], RDRF} == 2'b11)		?	1'b0:
					({CTL_REG[6:5], TDRE} == 3'b011)	?	1'b0:	1'b1;
assign COUNTER_DIVIDE = CTL_REG[1:0];
assign WORD_SELECT =	CTL_REG[4];
assign TX_CTL = CTL_REG[6:5];
assign RTS = (TX_CTL == 2'b10);
assign STOP =	(CTL_REG[4:2] == 3'b000) ? 1'b1:
					(CTL_REG[4:2] == 3'b001) ? 1'b1:
					(CTL_REG[4:2] == 3'b100) ? 1'b1: 1'b0;
assign PAR_DIS =(CTL_REG[4:2] == 3'b100) ? 1'b1:
					 (CTL_REG[4:2] == 3'b101) ? 1'b1: 1'b0;
always @ (negedge E or negedge RESET_N)
begin
	if(!RESET_N)
		CTL_REG <= 8'h00;
	else
		if({RW_N, CS, RS} == 3'b010)						
			CTL_REG <= DI;
		else
			if(COUNTER_DIVIDE == 2'b11)
				CTL_REG <= 8'h03;
end
always @ (negedge E or negedge RESET_X)
begin
	if(!RESET_X)
	begin
		RDRF <= 1'b0;
		READ_STATE <= 2'b00;
		RX_REG <= 8'h00;
		TX_BUFFER <= 8'h00;
		TDRE <= 1'b1;
		TX_START <= 1'b0;
		OVERRUN <= 1'b0;
		FRAME <= 1'b0;
		PARITY <= 1'b0;
		TX_DONE1 <= 1'b1;
		TX_DONE0 <= 1'b1;
		READY1 <= 1'b0;
		READY0 <= 1'b0;
	end
	else
	begin
		TX_DONE1 <= TX_DONE0;			
		TX_DONE0 <= TX_DONE;
		READY1 <= READY0;
		READY0 <= GOT_DATA;
		case (READ_STATE)
		2'b00:
		begin
			if(READY1)										
			begin
				RDRF <= 1'b1;
				READ_STATE <= 2'b01;
				PARITY <= (PARITY_ERR & !PAR_DIS);
				OVERRUN <= 1'b0;
				FRAME <= FRAME_BUF;
				RX_REG <= RX_BUFFER;
			end
		end
		2'b01:												
		begin
			if({RW_N, CS, RS} == 3'b111)
			begin
				RDRF <= 1'b0;
				READ_STATE <= 2'b10;
			end
			else												
			begin
				if(~READY1)
					READ_STATE <= 2'b11;
			end
		end
		2'b10:												
		begin
			if(~READY1)
				READ_STATE <= 2'b00;
		end
		2'b11:												
		begin
			if({RW_N, CS, RS} == 3'b111)
			begin
				RDRF <= 1'b0;
				READ_STATE <= 2'b00;
			end
			else
			begin
				if(READY1)									
				begin
					RDRF <= 1'b1;
					READ_STATE <= 2'b01;
					OVERRUN <= 1'b1;
					PARITY <= (PARITY_ERR & !PAR_DIS);
					FRAME <= FRAME_BUF;
					RX_REG <= RX_BUFFER;
				end
			end
		end
		endcase
		if(~TDRE & TX_DONE1 & ~TX_START & ~CS)
		begin
			TX_BUFFER <= TX_REG;
			TDRE <= 1'b1;
			TX_START <= 1'b1;
		end
		else
		begin
			if({RW_N, CS, RS} == 3'b011)				
			begin
				TDRE <= 1'b0;
				TX_REG <= DI;
			end
			if(~TX_DONE1)
			begin
				TX_START <= 1'b0;
			end
		end
	end
end
UART_TX TX(
.BAUD_CLK(TX_CLK_X),
.RESET_N(RESET_X),
.TX_DATA(TXDATA),
.TX_START(TX_START),
.TX_DONE(TX_DONE),
.TX_STOP(STOP),
.TX_WORD(WORD_SELECT),
.TX_PAR_DIS(PAR_DIS),
.TX_PARITY(CTL_REG[2]),
.TX_BUFFER(TX_BUFFER)
);
UART_RX RX(
.RESET_N(RESET_X),
.BAUD_CLK(RX_CLK_X),
.RX_DATA(RXDATA),
.RX_BUFFER(RX_BUFFER),
.RX_WORD(WORD_SELECT),
.RX_PAR_DIS(PAR_DIS),
.RX_PARITY(CTL_REG[2]),
.PARITY_ERR(PARITY_ERR),
.FRAME(FRAME_BUF),
.READY(GOT_DATA)
);
endmodule
