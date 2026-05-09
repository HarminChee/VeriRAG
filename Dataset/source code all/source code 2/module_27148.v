`timescale 1ns/100ps
`define D #1
`timescale 1ns/100ps
`define D #1
module dso_ctl(
	input    core_clk,
	input    core_rst,
	input	 	scl,
	inout    sda,
	output	reg	dso_setZero,
	output	reg	[23:0]	dso_sampleDivider,
	output	reg	[23:0]	dso_triggerPos,
	output	[7:0]		dso_triggerSlope,
	output	[7:0]		dso_triggerSource,
	output	reg	[15:0]	dso_triggerValue,
	input	 	uart_rx,
	output	uart_tx
);
`define D_BAUD_FREQ			12'h120
`define D_BAUD_LIMIT		16'h3cc0
wire	[11:0]	baud_freq;	
wire	[15:0]	baud_limit;
wire	empty;
wire	[7:0]	regAddr;
wire	[7:0]	dataToRegIF;
wire	[7:0]	dataFromRegIF;
wire			writeEn;
reg	new_tx_data;
wire	new_tx_data_nxt;
wire	[7:0]	tx_data;
wire	tx_busy;
wire	[7:0]	rx_data;
wire	new_rx_data;
wire	cmd2dso;
wire	cmd2sampleDivider;
wire	cmd2triggerPos;
wire	cmd2triggerSlope;
wire	cmd2triggerSource;
wire	cmd2triggerValue;
wire	cmd2setZero;
assign baud_freq = `D_BAUD_FREQ;
assign baud_limit = `D_BAUD_LIMIT;
assign new_tx_data_nxt = (new_tx_data | tx_busy) ? 1'b0 :
								 (~empty & ~tx_busy) ? 1'b1 : new_tx_data;
always @(posedge core_clk)
begin
	if (core_rst == 1'b1)
	    new_tx_data <= 1'b0;
	else
	    new_tx_data <= new_tx_data_nxt;
end								 
i2cSlave i2cSlave(
  .clk(core_clk),
  .rst(rst),
  .sda(sda),
  .scl(scl),
  .regAddr(regAddr),
  .dataToRegIF(dataToRegIF),
  .writeEn(writeEn),
  .dataFromRegIF(dataFromRegIF)
);
assign cmd2dso = writeEn & (regAddr[7:2] == 6'd0);
assign cmd2sampleDivider = writeEn & (regAddr[7:2] == 6'd1);
assign cmd2triggerPos = writeEn & (regAddr[7:2] == 6'd2);
assign cmd2triggerSlope = writeEn & (regAddr[7:2] == 6'd3);
assign cmd2triggerSource = writeEn & (regAddr[7:2] == 6'd4);
assign cmd2triggerValue = writeEn & (regAddr[7:2] == 6'd5);
assign cmd2setZero = writeEn & (regAddr[7:2] == 6'd6);
cmd_fifo cmd_fifo (
  .clk(core_clk), 
  .rst(core_rst), 
  .din(dataToRegIF), 
  .wr_en(cmd2dso), 
  .rd_en(new_tx_data), 
  .dout(tx_data), 
  .full(), 
  .empty(empty) 
);
cmd_fifo status_fifo (
  .clk(core_clk), 
  .rst(core_rst), 
  .din(rx_data), 
  .wr_en(new_rx_data), 
  .rd_en(1'b1), 
  .dout(), 
  .full(), 
  .empty() 
);
uart_top uart1
(
	.clock(core_clk), .reset(core_rst),
	.ser_in(uart_rx), .ser_out(uart_tx),
	.rx_data(rx_data), .new_rx_data(new_rx_data), 
	.tx_data(tx_data), .new_tx_data(new_tx_data), .tx_busy(tx_busy), 
	.baud_freq(baud_freq), .baud_limit(baud_limit),
	.baud_clk() 
);
reg	set_sampleDivider;
reg	set_triggerPos;
reg	set_triggerValue;
wire	set_sampleDivider_nxt;
wire	set_triggerPos_nxt;
wire	set_triggerValue_nxt;
wire	dso_setZero_nxt;
reg	[23:0]	sampleDivider;
reg	[23:0]	triggerPos;
reg	[7:0]		triggerSlope;
reg	[7:0]		triggerSource;
reg	[15:0]	triggerValue;
wire	[23:0]	sampleDivider_nxt;
wire	[23:0]	triggerPos_nxt;
wire	[7:0]		triggerSlope_nxt;
wire	[7:0]		triggerSource_nxt;
wire	[15:0]	triggerValue_nxt;
assign sampleDivider_nxt[7:0] = (cmd2sampleDivider & (regAddr[1:0] == 2'b00)) ? dataToRegIF : sampleDivider[7:0];
assign sampleDivider_nxt[15:8] = (cmd2sampleDivider & (regAddr[1:0] == 2'b01)) ? dataToRegIF : sampleDivider[15:8];
assign sampleDivider_nxt[23:16] = (cmd2sampleDivider & (regAddr[1:0] == 2'b10)) ? dataToRegIF : sampleDivider[23:16];
assign triggerPos_nxt[7:0] = (cmd2triggerPos & (regAddr[1:0] == 2'b00)) ? dataToRegIF : triggerPos[7:0];
assign triggerPos_nxt[15:8] = (cmd2triggerPos & (regAddr[1:0] == 2'b01)) ? dataToRegIF : triggerPos[15:8];
assign triggerPos_nxt[23:16] = (cmd2triggerPos & (regAddr[1:0] == 2'b10)) ? dataToRegIF : triggerPos[23:16];
assign triggerSlope_nxt[7:0] = (cmd2triggerSlope & (regAddr[1:0] == 2'b00)) ? dataToRegIF : triggerSlope;
assign triggerSource_nxt[7:0] = (cmd2triggerSource & (regAddr[1:0] == 2'b00)) ? dataToRegIF : triggerSource;
assign triggerValue_nxt[7:0] = (cmd2triggerValue & (regAddr[1:0] == 2'b00)) ? dataToRegIF : triggerValue[7:0];
assign triggerValue_nxt[15:8] = (cmd2triggerValue & (regAddr[1:0] == 2'b01)) ? dataToRegIF : triggerValue[15:8];
assign set_sampleDivider_nxt = (cmd2sampleDivider & (regAddr[1:0] == 2'b10));
assign set_triggerPos_nxt = (cmd2triggerPos & (regAddr[1:0] == 2'b10));
assign set_triggerValue_nxt = (cmd2triggerValue & (regAddr[1:0] == 2'b01));
assign dso_setZero_nxt = (cmd2setZero & (regAddr[1:0] == 2'b10));
always @(posedge core_clk)
begin
		sampleDivider <= `D sampleDivider_nxt;
		triggerPos <= `D triggerPos_nxt;
		triggerSlope <= `D triggerSlope_nxt;
		triggerSource <= `D triggerSource_nxt;
		triggerValue <= `D triggerValue_nxt;
		set_sampleDivider <= `D set_sampleDivider_nxt;
		set_triggerPos <= `D set_triggerPos_nxt;
		set_triggerValue <= `D set_triggerValue_nxt;
		dso_setZero <= `D dso_setZero_nxt;
		dso_triggerPos <= `D set_triggerPos ? triggerPos : dso_triggerPos;
		dso_sampleDivider <= `D set_sampleDivider ? sampleDivider : dso_sampleDivider;
		dso_triggerValue <= `D set_triggerValue ? triggerValue : dso_triggerValue;		
end
assign dso_triggerSlope = triggerSlope;
assign dso_triggerSource = triggerSource;
endmodule
