module UART_Sender #(
	parameter N    = 5,
	parameter Full = 5'd29 
)(
	input Clk,
	input Reset,
	input [7:0]Data,
	input      Send,
	output reg Busy,
	output reg Tx	
);
reg        tSend;
reg [  7:0]Temp;
reg [N-1:0]Count;
reg [  2:0]BitCount;
reg   [1:0]State;
localparam Idle    = 2'b00;
localparam Sending = 2'b01;
localparam StopBit = 2'b11;
localparam Done    = 2'b10;
reg tReset;
always @(posedge Clk) begin
	tReset <= Reset;
	if(tReset) begin
		Busy <= 1'b0;
		Tx   <= 1'b1;
		tSend    <= 0;
		Count    <= 0;
		BitCount <= 0;
		State    <= Idle;
	end else begin
		tSend <= Send;
		if(~|Count) begin
			case(State)
				Idle: begin
					if(tSend) begin
						Count      <= Full;
						BitCount   <= 3'd7;
						{Temp, Tx} <= {Data, 1'b0};
						Busy       <= 1'b1;
						State      <= Sending;
					end
				end
				Sending: begin
					Count           <= Full;
					{Temp[6:0], Tx} <= Temp;
					if(~|BitCount) State <= StopBit;
					BitCount <= BitCount - 1'b1;
				end
				StopBit: begin
					Tx    <= 1'b1;
					Count <= Full;
					State <= Done;
				end
				Done: begin
					if(~tSend) begin
						Busy  <= 1'b0;
						Count <= 0;
						State <= Idle;
					end
				end
				default:;
			endcase
		end else begin
			Count <= Count - 1'b1;
		end
	end
end
endmodule
