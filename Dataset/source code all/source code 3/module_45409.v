module niosII_system_rs232_0 (
	clk,
	reset,
	address,
	chipselect,
	byteenable,
	read,
	write,
	writedata,
	UART_RXD,
	irq,
	readdata,
	UART_TXD
);
parameter CW							= 9;		
parameter BAUD_TICK_COUNT			= 434;
parameter HALF_BAUD_TICK_COUNT	= 217;
parameter TDW							= 10;		
parameter DW							= 8;		
parameter ODD_PARITY					= 1'b0;
input						clk;
input						reset;
input						address;
input						chipselect;
input			[ 3: 0]	byteenable;
input						read;
input						write;
input			[31: 0]	writedata;
input						UART_RXD;
output reg				irq;
output reg	[31: 0]	readdata;
output					UART_TXD;
wire						read_fifo_read_en;
wire			[ 7: 0]	read_available;
wire						read_data_valid;
wire		[(DW-1):0]	read_data;
wire						parity_error;
wire						write_data_parity;
wire			[ 7: 0]	write_space;
reg						read_interrupt_en;
reg						write_interrupt_en;
reg						read_interrupt;
reg						write_interrupt;
reg						write_fifo_write_en;
reg		[(DW-1):0]	data_to_uart;
always @(posedge clk)
begin
	if (reset)
		irq <= 1'b0;
	else
		irq <= write_interrupt | read_interrupt;
end
always @(posedge clk)
begin
	if (reset)
		readdata <= 32'h00000000;
	else if (chipselect)
	begin
		if (address == 1'b0)
			readdata <= 
				{8'h00,
				 read_available,
				 read_data_valid,
				 5'h00,
				 parity_error,
				 1'b0,
				 read_data[(DW - 1):0]};
		else
			readdata <= 
				{8'h00,
				 write_space,
				 6'h00,
				 write_interrupt,
				 read_interrupt,
				 6'h00,
				 write_interrupt_en,
				 read_interrupt_en};
	end
end
always @(posedge clk)
begin
	if (reset)
		read_interrupt_en <= 1'b0;
	else if ((chipselect) && (write) && (address) && (byteenable[0]))
		read_interrupt_en <= writedata[0];
end
always @(posedge clk)
begin
	if (reset)
		write_interrupt_en <= 1'b0;
	else if ((chipselect) && (write) && (address) && (byteenable[0]))
		write_interrupt_en <= writedata[1];
end
always @(posedge clk)
begin
	if (reset)
		read_interrupt <= 1'b0;
	else if (read_interrupt_en == 1'b0)
		read_interrupt <= 1'b0;
	else
		read_interrupt <= (&(read_available[6:5]) | read_available[7]);
end
always @(posedge clk)
begin
	if (reset)
		write_interrupt <= 1'b0;
	else if (write_interrupt_en == 1'b0)
		write_interrupt <= 1'b0;
	else
		write_interrupt <= (&(write_space[6:5]) | write_space[7]);
end
always @(posedge clk)
begin
	if (reset)
		write_fifo_write_en <= 1'b0;
	else
		write_fifo_write_en <= 
			chipselect & write & ~address & byteenable[0];
end
always @(posedge clk)
begin
	if (reset)
		data_to_uart <= 'h0;
	else
		data_to_uart <= writedata[(DW - 1):0];
end
assign parity_error = 1'b0;
assign read_fifo_read_en = chipselect & read & ~address & byteenable[0];
assign write_data_parity = (^(data_to_uart)) ^ ODD_PARITY;
altera_up_rs232_in_deserializer RS232_In_Deserializer (
	.clk						(clk),
	.reset					(reset),
	.serial_data_in		(UART_RXD),
	.receive_data_en		(read_fifo_read_en),
	.fifo_read_available	(read_available),
	.received_data_valid	(read_data_valid),
	.received_data			(read_data)
);
defparam 
	RS232_In_Deserializer.CW							= CW,
	RS232_In_Deserializer.BAUD_TICK_COUNT			= BAUD_TICK_COUNT,
	RS232_In_Deserializer.HALF_BAUD_TICK_COUNT	= HALF_BAUD_TICK_COUNT,
	RS232_In_Deserializer.TDW							= TDW,
	RS232_In_Deserializer.DW							= (DW - 1);
altera_up_rs232_out_serializer RS232_Out_Serializer (
	.clk						(clk),
	.reset					(reset),
	.transmit_data			(data_to_uart),
	.transmit_data_en		(write_fifo_write_en),
	.fifo_write_space		(write_space),
	.serial_data_out		(UART_TXD)
);
defparam 
	RS232_Out_Serializer.CW							= CW,
	RS232_Out_Serializer.BAUD_TICK_COUNT		= BAUD_TICK_COUNT,
	RS232_Out_Serializer.HALF_BAUD_TICK_COUNT	= HALF_BAUD_TICK_COUNT,
	RS232_Out_Serializer.TDW						= TDW,
	RS232_Out_Serializer.DW							= (DW - 1);
endmodule
