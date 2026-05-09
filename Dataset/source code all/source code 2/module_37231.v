module uart #(
	parameter csr_addr = 4'h0,
	parameter clk_freq = 50000000,
	parameter baud = 115200
) (
	input sys_clk,
	input sys_rst,
	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output reg [31:0] csr_do,
	output rx_irq,
	output tx_irq,
	input uart_rx,
	output uart_tx
);
reg [15:0] divisor;
wire [7:0] rx_data;
wire [7:0] tx_data;
wire tx_wr;
reg thru;
wire uart_tx_transceiver;
uart_transceiver transceiver(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.uart_rx(uart_rx),
	.uart_tx(uart_tx_transceiver),
	.divisor(divisor),
	.rx_data(rx_data),
	.rx_done(rx_irq),
	.tx_data(tx_data),
	.tx_wr(tx_wr),
	.tx_done(tx_irq)
);
assign uart_tx = thru ? uart_rx : uart_tx_transceiver;
wire csr_selected = csr_a[13:10] == csr_addr;
assign tx_data = csr_di[7:0];
assign tx_wr = csr_selected & csr_we & (csr_a[1:0] == 2'b00);
parameter default_divisor = clk_freq/baud/16;
always @(posedge sys_clk) begin
	if(sys_rst) begin
		divisor <= default_divisor;
		csr_do <= 32'd0;
	end else begin
		csr_do <= 32'd0;
		if(csr_selected) begin
			case(csr_a[1:0])
				2'b00: csr_do <= rx_data;
				2'b01: csr_do <= divisor;
				2'b10: csr_do <= thru;
			endcase
			if(csr_we) begin
				case(csr_a[1:0])
					2'b00:; 
					2'b01: divisor <= csr_di[15:0];
					2'b10: thru <= csr_di[0];
				endcase
			end
		end
	end
end
endmodule
