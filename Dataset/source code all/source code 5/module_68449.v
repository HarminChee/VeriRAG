module altera_up_rs232_counters (
	clk,
	reset,
	reset_counters,
	baud_clock_rising_edge,
	baud_clock_falling_edge,
	all_bits_transmitted
);
parameter CW							= 9;		
parameter BAUD_TICK_COUNT			= 433;
parameter HALF_BAUD_TICK_COUNT	= 216;
parameter TDW							= 11;		
input						clk;
input						reset;
input						reset_counters;
output reg				baud_clock_rising_edge;
output reg				baud_clock_falling_edge;
output reg				all_bits_transmitted;
reg		[(CW-1):0]	baud_counter;
reg			[ 3: 0]	bit_counter;
always @(posedge clk)
begin
	if (reset)
		baud_counter <= {CW{1'b0}};
	else if (reset_counters)
		baud_counter <= {CW{1'b0}};
	else if (baud_counter == BAUD_TICK_COUNT)
		baud_counter <= {CW{1'b0}};
	else
		baud_counter <= baud_counter + 1;
end
always @(posedge clk)
begin
	if (reset)
		baud_clock_rising_edge <= 1'b0;
	else if (baud_counter == BAUD_TICK_COUNT)
		baud_clock_rising_edge <= 1'b1;
	else
		baud_clock_rising_edge <= 1'b0;
end
always @(posedge clk)
begin
	if (reset)
		baud_clock_falling_edge <= 1'b0;
	else if (baud_counter == HALF_BAUD_TICK_COUNT)
		baud_clock_falling_edge <= 1'b1;
	else
		baud_clock_falling_edge <= 1'b0;
end
always @(posedge clk)
begin
	if (reset)
		bit_counter <= 4'h0;
	else if (reset_counters)
		bit_counter <= 4'h0;
	else if (bit_counter == TDW)
		bit_counter <= 4'h0;
	else if (baud_counter == BAUD_TICK_COUNT)
		bit_counter <= bit_counter + 4'h1;
end
always @(posedge clk)
begin
	if (reset)
		all_bits_transmitted <= 1'b0;
	else if (bit_counter == TDW)
		all_bits_transmitted <= 1'b1;
	else
		all_bits_transmitted <= 1'b0;
end
endmodule
