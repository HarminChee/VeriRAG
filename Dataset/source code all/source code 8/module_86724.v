module altera_up_rs232_out_serializer (
	clk,
	reset,
	transmit_data,
	transmit_data_en,
	fifo_write_space,
	serial_data_out
);
parameter CW							= 9;			
parameter BAUD_TICK_COUNT			= 433;
parameter HALF_BAUD_TICK_COUNT	= 216;
parameter TDW							= 11;			
parameter DW							= 9;			
input						clk;
input						reset;
input			[DW: 0]	transmit_data;
input						transmit_data_en;
output reg	[ 7: 0]	fifo_write_space;
output reg				serial_data_out;
wire						shift_data_reg_en;
wire						all_bits_transmitted;
wire						read_fifo_en;
wire						fifo_is_empty;
wire						fifo_is_full;
wire			[ 6: 0]	fifo_used;
wire			[DW: 0]	data_from_fifo;
reg						transmitting_data;
reg			[DW+1:0]	data_out_shift_reg;
always @(posedge clk)
begin
	if (reset)
		fifo_write_space <= 8'h00;
	else
		fifo_write_space <= 8'h80 - {fifo_is_full, fifo_used};
end
always @(posedge clk)
begin
	if (reset)
		serial_data_out <= 1'b1;
	else
		serial_data_out <= data_out_shift_reg[0];
end
always @(posedge clk)
begin
	if (reset)
		transmitting_data <= 1'b0;
	else if (all_bits_transmitted)
		transmitting_data <= 1'b0;
	else if (fifo_is_empty == 1'b0)
		transmitting_data <= 1'b1;
end
always @(posedge clk)
begin
	if (reset)
		data_out_shift_reg	<= {(DW + 2){1'b1}};
	else if (read_fifo_en)
		data_out_shift_reg	<= {data_from_fifo, 1'b0};
	else if (shift_data_reg_en)
		data_out_shift_reg	<= 
			{1'b1, data_out_shift_reg[DW+1:1]};
end
assign read_fifo_en = 
			~transmitting_data & ~fifo_is_empty & ~all_bits_transmitted;
altera_up_rs232_counters RS232_Out_Counters (
	.clk								(clk),
	.reset							(reset),
	.reset_counters				(~transmitting_data),
	.baud_clock_rising_edge		(shift_data_reg_en),
	.baud_clock_falling_edge	(),
	.all_bits_transmitted		(all_bits_transmitted)
);
defparam 
	RS232_Out_Counters.CW		= CW,
	RS232_Out_Counters.BAUD_TICK_COUNT			= BAUD_TICK_COUNT,
	RS232_Out_Counters.HALF_BAUD_TICK_COUNT	= HALF_BAUD_TICK_COUNT,
	RS232_Out_Counters.TDW							= TDW;
altera_up_sync_fifo RS232_Out_FIFO (
	.clk				(clk),
	.reset			(reset),
	.write_en		(transmit_data_en & ~fifo_is_full),
	.write_data		(transmit_data),
	.read_en			(read_fifo_en),
	.fifo_is_empty	(fifo_is_empty),
	.fifo_is_full	(fifo_is_full),
	.words_used		(fifo_used),
	.read_data		(data_from_fifo)
);
defparam 
	RS232_Out_FIFO.DW				= DW,
	RS232_Out_FIFO.DATA_DEPTH	= 128,
	RS232_Out_FIFO.AW				= 6;
endmodule
