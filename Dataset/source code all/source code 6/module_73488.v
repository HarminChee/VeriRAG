module altera_up_rs232_in_deserializer (
	clk,
	reset,
	serial_data_in,
	receive_data_en,
	fifo_read_available,
	received_data_valid,
	received_data
);
parameter CW							= 9;		
parameter BAUD_TICK_COUNT			= 433;
parameter HALF_BAUD_TICK_COUNT	= 216;
parameter TDW							= 11;		
parameter DW							= 9;		
input						clk;
input						reset;
input						serial_data_in;
input						receive_data_en;
output reg	[ 7: 0]	fifo_read_available;
output					received_data_valid;
output		[DW: 0]	received_data;
wire						shift_data_reg_en;
wire						all_bits_received;
wire						fifo_is_empty;
wire						fifo_is_full;
wire			[ 6: 0]	fifo_used;
reg						receiving_data;
reg		[(TDW-1):0]	data_in_shift_reg;
always @(posedge clk)
begin
	if (reset)
		fifo_read_available <= 8'h00;
	else
		fifo_read_available <= {fifo_is_full, fifo_used};
end
always @(posedge clk)
begin
	if (reset)
		receiving_data <= 1'b0;
	else if (all_bits_received)
		receiving_data <= 1'b0;
	else if (serial_data_in == 1'b0)
		receiving_data <= 1'b1;
end
always @(posedge clk)
begin
	if (reset)
		data_in_shift_reg	<= {TDW{1'b0}};
	else if (shift_data_reg_en)
		data_in_shift_reg	<= 
			{serial_data_in, data_in_shift_reg[(TDW - 1):1]};
end
assign received_data_valid = ~fifo_is_empty;
altera_up_rs232_counters RS232_In_Counters (
	.clk								(clk),
	.reset							(reset),
	.reset_counters				(~receiving_data),
	.baud_clock_rising_edge		(),
	.baud_clock_falling_edge	(shift_data_reg_en),
	.all_bits_transmitted		(all_bits_received)
);
defparam 
	RS232_In_Counters.CW							= CW,
	RS232_In_Counters.BAUD_TICK_COUNT		= BAUD_TICK_COUNT,
	RS232_In_Counters.HALF_BAUD_TICK_COUNT	= HALF_BAUD_TICK_COUNT,
	RS232_In_Counters.TDW						= TDW;
altera_up_sync_fifo RS232_In_FIFO (
	.clk				(clk),
	.reset			(reset),
	.write_en		(all_bits_received & ~fifo_is_full),
	.write_data		(data_in_shift_reg[(DW + 1):1]),
	.read_en			(receive_data_en & ~fifo_is_empty),
	.fifo_is_empty	(fifo_is_empty),
	.fifo_is_full	(fifo_is_full),
	.words_used		(fifo_used),
	.read_data		(received_data)
);
defparam 
	RS232_In_FIFO.DW				= DW,
	RS232_In_FIFO.DATA_DEPTH	= 128,
	RS232_In_FIFO.AW				= 6;
endmodule
