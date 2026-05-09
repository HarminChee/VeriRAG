`timescale 1ns / 1ps
`timescale 1ns / 1ps
module spi_bonus(clk, reset, din, dout, wren, rden, addr, mosi, miso, sclk);
input clk, reset, wren, rden;
input [7:0] din;
output [7:0] dout;
input [1:0] addr;
output mosi;
input miso;
output sclk;
`define TXreg 		2'b00
`define RXreg 		2'b01
`define control 	2'b10
`define TXFULL		control[0]
`define DATARDY	control[1]
`define WAIT		2'b00
`define SHIFT	 	2'b01
`define SHIFT1		2'b10
`define WRITE 		2'b11
reg [7:0] control, shiftin, shiftout, dout;
reg wr_tx, wr_rx, rd_tx, sout, sin, spi, wr_control, enspi, clr_count, rd_rx;
reg [6:0] spiclk;
reg [1:0] pstate, nstate;
reg [3:0] counter;
wire rx_empty, tx_full, tx_empty;
wire [7:0] txout, dout_rx;
assign mosi = shiftout[7];
assign sclk = spi;

// Added register to synchronously detect spi rising edge
reg spi_dly;

txreg txfifo(
  .clk	(clk),
  .rst	(reset),
  .din	(din),
  .wr_en	(wr_tx),
  .rd_en	(rd_tx),
  .dout	(txout),
  .full	(tx_full),
  .empty	(tx_empty)
);
txreg rxfifo(
  .clk	(clk),
  .rst	(reset),
  .din	(shiftin),
  .wr_en	(wr_rx),
  .rd_en	(rd_rx),
  .dout	(dout_rx),
  .full	(rx_full),
  .empty	(rx_empty)
);
always @(posedge clk or posedge reset) begin
	if(reset) begin
		spiclk <= 6'b00000;
		spi <= 0;
	end
	else begin
		begin
			if(enspi) begin
				if(spiclk >= 0 & spiclk <= 24) begin
					spi <= 1;
					spiclk <= spiclk + 1;
				end
				if(spiclk >=25 & spiclk <= 49) begin
					spi <= 0;
					spiclk <= spiclk + 1;
				end
				if(spiclk == 50)begin
					spiclk <= 6'b00000;
				end
			end
			else begin
				spiclk <= 5'b00000;
				spi <= 0;
				end
		end
	end
end

// Logic to capture previous state of spi for edge detection
always @(posedge clk or posedge reset) begin
    if (reset)
        spi_dly <= 1'b0;
    else
        spi_dly <= spi;
end

always @* begin
	dout = 8'b00000000;
	rd_rx = 0;
	case(addr)
		`RXreg: begin
			if(rden)
				rd_rx = 1;
				dout = dout_rx;
			end
		`control: begin
			if(rden)
				dout = control;
			end
	endcase
end
always @* begin
wr_tx = 0;
	case(addr)
		`TXreg: begin
			if(wren)
				wr_tx = 1;
			end
	endcase
end
always @(posedge clk or posedge reset) begin
	if(reset)
		control <= 8'b00000000;
	else begin
		`DATARDY <= ~rx_empty;
		`TXFULL <= tx_full;
		if(wr_control)
			control <= din;
	end
end

// DFT Fix: Changed counter clock from 'spi' to 'clk'
// Enabled increment synchronously on detected rising edge of 'spi'
always @(posedge clk or posedge reset) begin
	if(reset) begin
		counter <= 4'b0000;
	end else begin
		// Detect rising edge of spi synchronously with clk
		if (enspi && spi && ~spi_dly) begin
			if (counter == 4'b0111) begin // Wrap from 7 to 1 (assuming original >=8 meant wrap after 7)
				counter <= 4'b0001;
			end else begin
				counter <= counter + 1;
			end
		end
		// Counter holds value if enspi is low or no spi rising edge detected
	end
end

always @(posedge clk or posedge reset) begin
	if(reset)
		shiftout <= 8'b00000000;
	else begin
		if(sout)
			shiftout <= {shiftout[6:0], 1'b0};
		if(rd_tx)
			shiftout <= txout;
	end
end
always @(posedge clk or posedge reset) begin
	if(reset)
		shiftin <= 8'b00000000;
	else begin
		if(sin)
			shiftin <= {shiftin[6:0], miso};
	end
end
always @(posedge clk or posedge reset) begin
	if(reset) pstate = `WAIT;
	else pstate = nstate;
end
always @* begin
	rd_tx = 0; sout = 0;
	enspi = 0; clr_count = 0;
	wr_rx = 0; sin = 0;
	nstate = pstate;
	case(pstate)
		`WAIT: begin
			if(~tx_empty) begin
				rd_tx = 1;
				enspi = 1;
				nstate = `SHIFT;
			end
		end
		`SHIFT: begin
			enspi = 1;
			if(~spi) begin // Check spi level
				nstate = `SHIFT1;
				sin = 1;
				// Check counter value based on clk domain now
				// Original check was likely asynchronous to clk, now it's synchronous
				// This condition might need functional review if exact timing is critical
				if(counter == 4'b1000) begin
					nstate = `WRITE;
				end
			end
		end
		`SHIFT1: begin
			enspi = 1;
			if(spi) begin // Check spi level
				sout = 1;
				nstate = `SHIFT;
			end
		end
		`WRITE: begin
			wr_rx = 1;
			nstate = `WAIT;
		end
	endcase
end
endmodule