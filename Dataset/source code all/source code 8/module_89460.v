module uart_filter (
	input clk,
	input uart_rx,
	output reg tx_rx = 1'b0
);
	reg rx, meta;
	always @ (posedge clk)
		{rx, meta} <= {meta, uart_rx};
	wire sample0 = rx;
	reg sample1, sample2;
	always @ (posedge clk)
	begin
		{sample2, sample1} <= {sample1, sample0};
		if ((sample2 & sample1) | (sample1 & sample0) | (sample2 & sample0))
			tx_rx <= 1'b1;
		else
			tx_rx <= 1'b0;
	end
endmodule
module uart_receiver # (
	parameter comm_clk_frequency = 100000000,
	parameter baud_rate = 115200
) (
	input clk,
	input uart_rx,
	output reg tx_new_byte = 1'b0,
	output reg [7:0] tx_byte = 8'd0
);
	localparam [15:0] baud_delay = (comm_clk_frequency / baud_rate) - 1;
	wire rx;
	uart_filter uart_fitler_blk (
		.clk (clk),
		.uart_rx (uart_rx),
		.tx_rx (rx)
	);
	reg old_rx = 1'b1, idle = 1'b1;
	reg [15:0] delay_cnt = 16'd0;
	reg [8:0] incoming = 9'd0;
	always @ (posedge clk)
	begin
		old_rx <= rx;
		tx_new_byte <= 1'b0;
		delay_cnt <= delay_cnt + 16'd1;
		if (delay_cnt == baud_delay)
			delay_cnt <= 0;
		if (idle && old_rx && !rx)    
		begin
			idle <= 1'b0;
			incoming <= 9'd511;
			delay_cnt <= 16'd0;   
		end
		else if (!idle && (delay_cnt == (baud_delay >> 1)))
		begin
			incoming <= {rx, incoming[8:1]};    
			if (incoming == 9'd511 && rx)       
				idle <= 1'b1;
			if (!incoming[0])    
			begin
				idle <= 1'b1;
				if (rx)
				begin
					tx_new_byte <= 1'b1;
					tx_byte <= incoming[8:1];
				end
			end
		end
	end
endmodule
module uart_filter (
	input clk,
	input uart_rx,
	output reg tx_rx = 1'b0
);
	reg rx, meta;
	always @ (posedge clk)
		{rx, meta} <= {meta, uart_rx};
	wire sample0 = rx;
	reg sample1, sample2;
	always @ (posedge clk)
	begin
		{sample2, sample1} <= {sample1, sample0};
		if ((sample2 & sample1) | (sample1 & sample0) | (sample2 & sample0))
			tx_rx <= 1'b1;
		else
			tx_rx <= 1'b0;
	end
endmodule
