module ac97_transceiver(
	input sys_clk,
	input sys_rst,
	input ac97_clk,
	input ac97_rst_n,
	input ac97_sin,
	output reg ac97_sout,
	output reg ac97_sync,
	output up_stb,
	input up_ack,
	output up_sync,
	output up_data,
	output down_ready,
	input down_stb,
	input down_sync,
	input down_data
);
reg ac97_sin_r;
always @(negedge ac97_clk) ac97_sin_r <= ac97_sin;
reg ac97_syncfb_r;
always @(negedge ac97_clk) ac97_syncfb_r <= ac97_sync;
wire up_empty;
asfifo #(
	.data_width(2),
	.address_width(6)
) up_fifo (
	.data_out({up_sync, up_data}),
	.empty(up_empty),
	.read_en(up_ack),
	.clk_read(sys_clk),
	.data_in({ac97_syncfb_r, ac97_sin_r}),
	.full(),
	.write_en(1'b1),
	.clk_write(~ac97_clk),
	.rst(sys_rst)
);
assign up_stb = ~up_empty;
wire ac97_sync_r;
always @(negedge ac97_rst_n, posedge ac97_clk) begin
	if(~ac97_rst_n)
		ac97_sync <= 1'b0;
	else
		ac97_sync <= ac97_sync_r;
end
wire ac97_sout_r;
always @(negedge ac97_rst_n, posedge ac97_clk) begin
	if(~ac97_rst_n)
		ac97_sout <= 1'b0;
	else
		ac97_sout <= ac97_sout_r;
end
wire down_full;
asfifo #(
	.data_width(2),
	.address_width(6)
) down_fifo (
	.data_out({ac97_sync_r, ac97_sout_r}),
	.empty(),
	.read_en(1'b1),
	.clk_read(ac97_clk),
	.data_in({down_sync, down_data}),
	.full(down_full),
	.write_en(down_stb),
	.clk_write(sys_clk),
	.rst(sys_rst)
);
assign down_ready = ~down_full;
endmodule
