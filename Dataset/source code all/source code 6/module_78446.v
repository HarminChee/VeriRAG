`timescale 1ns / 1ps
`timescale 1ns / 1ps
module crypto_sha256_top (
	input wb_clk_i,
	input wb_rst_i,
	input core_clk,
	input [31:0] wb_adr_i,
	input [31:0] wb_dat_i,
	input [3:0] wb_sel_i,
	input wb_we_i,
	input [1:0] wb_bte_i,
	input [2:0] wb_cti_i,
	input wb_cyc_i,
	input wb_stb_i,
	output wb_ack_o,
	output wb_err_o,
	output wb_rty_o,
	output [31:0] wb_dat_o
);
wire [255:0] wb2core_state, core2wb_state;
wire [511:0] wb2core_data;
wire load_clk1, busy_clk2;
reg [1:0] busy_clk1_buf;
reg [1:0] load_clk2_buf;
wire busy_clk1 = busy_clk1_buf[1];
wire load_clk2 = load_clk2_buf[1];
wb_sha256_ctrl wb_ctrl_inst (
	.wb_clk_i(wb_clk_i),
	.wb_rst_i(wb_rst_i),
	.wb_adr_i(wb_adr_i[6:0]),
	.wb_dat_i(wb_dat_i),
	.wb_sel_i(wb_sel_i),
	.wb_we_i(wb_we_i),
	.wb_bte_i(wb_bte_i),
	.wb_cti_i(wb_cti_i),
	.wb_cyc_i(wb_cyc_i),
	.wb_stb_i(wb_stb_i),
	.wb_ack_o(wb_ack_o),
	.wb_err_o(wb_err_o),
	.wb_rty_o(wb_rty_o),
	.wb_dat_o(wb_dat_o),
	.load_o(load_clk1),
	.state_o(wb2core_state),
	.data_o(wb2core_data),
	.busy_i(busy_clk1),
	.state_i(core2wb_state)
);
always @(posedge wb_clk_i) busy_clk1_buf <= { busy_clk1_buf[0], busy_clk2 };
always @(posedge core_clk) load_clk2_buf <= { load_clk2_buf[0], load_clk1 };
sha256_core sha256_inst (
	.clk(core_clk),
	.load_i(load_clk2),
	.data_i(wb2core_data),
	.state_i(wb2core_state),
	.state_o(core2wb_state),
	.busy_o(busy_clk2)
);
endmodule
