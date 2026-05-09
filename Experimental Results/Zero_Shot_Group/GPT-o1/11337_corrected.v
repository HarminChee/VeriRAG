module rs_cfg_fe1
(
	input	wire		clk_f20_i,
	input	wire		res_f20_n_i,
	input	wire	[13:0]	addr_i,
	input	wire	[31:0]	wr_data_i,
	input	wire		rd_wr_i,
	output	wire	[31:0]	rd_data_o,
	output	wire		rd_err_o,
	output	wire		trans_done_o,
	input	wire		trans_start_1_i,
	output	wire	[2:0]	cvbsdetect_par_o,
	input	wire	[2:0]	cvbsdetect_set_p_i,
	output	reg		cvbsdetect_trg_p_o,
	input	wire	[7:0]	sha_r_test_par_i,
	output	wire		sha_r_test_trg_p_o,
	input	wire		usr_r_test_par_i,
	input	wire		usr_r_test_trans_done_p_i,
	output	reg		usr_r_test_rd_p_o,
	input	wire		ycdetect_par_i,
	output	wire	[3:0]	mvstart_par_o,
	output	reg	[3:0]	mvstop_par_o,
	input	wire	[1:0]	usr_ali_par_i,
	input	wire		usr_ali_trans_done_p_i,
	output	reg		usr_ali_rd_p_o,
	output	wire	[3:0]	usr_rw_test_par_o,
	input	wire	[3:0]	usr_rw_test_in_par_i,
	input	wire		usr_rw_test_trans_done_p_i,
	output	reg		usr_rw_test_rd_p_o,
	output	reg		usr_rw_test_wr_p_o,
	output	reg	[31:0]	sha_rw2_par_o,
	output	wire	[15:0]	wd_16_test_par_o,
	output	wire	[7:0]	wd_16_test2_par_o,
	output	wire		wd_16_test2_trg_p_o,
	input	wire		upd_rw_en_i,
	input	wire		upd_rw_force_i,
	input	wire		upd_rw_i,
	input	wire		upd_r_en_i,
	input	wire		upd_r_force_i,
	input	wire		upd_r_i
);

	parameter sync = 0;
	parameter P__MVSTOP = -1;
	parameter P__CVBSDETECT = -1;
	parameter P__WD_16_TEST2 = -1;
	parameter P__WD_16_TEST = -1;
	parameter P__SHA_RW2 = -1;
	parameter P__MVSTART = -1;

`timescale 1ns/10ps
`define tie0_1_c 1'b0

	wire		clk_f20;
	wire		res_f20_n;
	wire		tie0_1;
	wire		u10_sync_generic_i_int_upd_r_arm_p; 
	wire		u5_sync_generic_i_trans_start_p; 
	wire		u6_sync_rst_i_int_rst_n; 
	wire		u7_sync_generic_i_int_upd_rw_p; 
	wire		u8_sync_generic_i_int_upd_rw_arm_p; 
	wire		u9_sync_generic_i_int_upd_r_p; 
	wire		upd_r;
	wire		upd_r_en;
	wire		upd_rw;
	wire		upd_rw_en;

	assign	clk_f20	=	clk_f20_i;  
	assign	res_f20_n	=	res_f20_n_i;  
	assign	tie0_1	= `tie0_1_c;
	assign	upd_r	=	upd_r_i;  
	assign	upd_r_en	=	upd_r_en_i;  
	assign	upd_rw	=	upd_rw_i;  
	assign	upd_rw_en	=	upd_rw_en_i;  

	`define REG_00_OFFS 0 
	`define REG_04_OFFS 1 
	`define REG_08_OFFS 2 
	`define REG_0C_OFFS 3 
	`define REG_10_OFFS 4 
	`define REG_14_OFFS 5 
	`define REG_18_OFFS 6 
	`define REG_1C_OFFS 7 
	`define REG_20_OFFS 8 
	`define REG_28_OFFS 10 

	reg  [31:0] REG_00;
	reg  [31:0] REG_04;
	reg  [31:0] REG_08;
	reg  [7:0]  sha_r_test_shdw;
	reg  [31:0] REG_0C;
	wire [3:0]  mvstop_shdw;
	reg  [31:0] REG_10;
	reg  [31:0] REG_14;
	wire [31:0] sha_rw2_shdw;
	reg  [31:0] REG_18;
	reg  [31:0] REG_1C;
	reg         int_REG_1C_trg_p;
	reg  [31:0] REG_20;
	reg  [31:0] REG_28;
	reg         int_upd_rw;
	reg         int_upd_rw_en;
	reg         int_upd_r;
	reg         int_upd_r_en;

	wire wr_p;
	wire wr_done_p;
	wire rd_p;
	wire rd_done_p;
	wire [3:0] iaddr;
	wire addr_overshoot;
	wire trans_done_p;
	reg  ts_del_p;
	reg  int_trans_done;

	reg  fwd_txn;
	wire [2:0] fwd_decode_vec;
	wire fwd_rd_done_p;
	wire fwd_wr_done_p;
	reg  [31:0] mux_rd_data;
	reg  mux_rd_err;

	assign cvbsdetect_par_o[2:0]  = cond_slice(P__CVBSDETECT, REG_04[2:0]);
	assign mvstart_par_o[3:0]     = cond_slice(P__MVSTART, REG_0C[3:0]);
	assign mvstop_shdw[3:0]       = cond_slice(P__MVSTOP, REG_0C[7:4]);
	assign sha_rw2_shdw[31:0]     = cond_slice(P__SHA_RW2, REG_14);
	assign wd_16_test_par_o[15:0] = cond_slice(P__WD_16_TEST, REG_18[15:0]);
	assign wd_16_test2_par_o[7:0] = cond_slice(P__WD_16_TEST2, REG_1C[7:0]);
	assign wd_16_test2_trg_p_o    = int_REG_1C_trg_p;
	assign sha_r_test_trg_p_o     = int_upd_r;
	assign usr_rw_test_par_o[3:0] = wr_data_i[14:11];

	assign iaddr = addr_i[5:2];
	assign addr_overshoot = |addr_i[13:6];

	assign trans_done_p = rd_done_p | wr_done_p;

	assign #0.1 wr_p = ~rd_wr_i & u5_sync_generic_i_trans_start_p;
	assign rd_done_p = rd_p;
	assign fwd_rd_done_p = usr_r_test_trans_done_p_i | usr_rw_test_trans_done_p_i | usr_ali_trans_done_p_i;
	assign fwd_wr_done_p = usr_rw_test_trans_done_p_i;
	assign rd_p = rd_wr_i & ((ts_del_p & ~fwd_txn) | (fwd_rd_done_p & fwd_txn));
	assign wr_done_p = ~rd_wr_i & ((ts_del_p & ~fwd_txn) | (fwd_wr_done_p & fwd_txn));

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			int_trans_done <= 0;
			ts_del_p       <= 0;
		end
		else begin
			ts_del_p <= u5_sync_generic_i_trans_start_p;
			if (trans_done_p)
				int_trans_done <= ~int_trans_done;
		end
	end
	assign trans_done_o = int_trans_done;

	function [31:0] cond_slice(input integer enable, input [31:0] vec);
		begin
			cond_slice = (enable < 0) ? vec : enable;
		end
	endfunction

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			REG_0C[3:0]  <= 'h7;
			REG_0C[7:4]  <= 'hc;
			REG_14       <= 'h0;
			REG_18[15:0] <= 'ha;
			REG_1C[7:0]  <= 'hff;
		end
		else begin
			if (wr_p)
				case (iaddr)
					`REG_0C_OFFS: begin
						REG_0C[3:0] <= wr_data_i[3:0];
						REG_0C[7:4] <= wr_data_i[7:4];
					end
					`REG_14_OFFS: begin
						REG_14 <= wr_data_i;
					end
					`REG_18_OFFS: begin
						REG_18[15:0] <= wr_data_i[15:0];
					end
					`REG_1C_OFFS: begin
						REG_1C[7:0] <= wr_data_i[7:0];
					end
					default: ;
				endcase
		end
	end

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			int_REG_1C_trg_p <= 0;
		end
		else begin
			int_REG_1C_trg_p <= 0;
			case (iaddr)
				`REG_1C_OFFS: int_REG_1C_trg_p <= wr_p;
				default: ;
			endcase
		end
	end

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			REG_04[2:0] <= 'h0;
			cvbsdetect_trg_p_o <= 0;
		end
		else begin
			if (cvbsdetect_set_p_i[0])
				REG_04[0] <= 1;
			else if (wr_p && iaddr == `REG_04_OFFS)
				REG_04[0] <= REG_04[0] & ~wr_data_i[0];

			if (wr_p && iaddr == `REG_04_OFFS)
				cvbsdetect_trg_p_o <= 1;
			else
				cvbsdetect_trg_p_o <= 0;

			if (cvbsdetect_set_p_i[1])
				REG_04[1] <= 1;
			else if (wr_p && iaddr == `REG_04_OFFS)
				REG_04[1] <= REG_04[1] & ~wr_data_i[1];

			if (cvbsdetect_set_p_i[2])
				REG_04[2] <= 1;
			else if (wr_p && iaddr == `REG_04_OFFS)
				REG_04[2] <= REG_04[2] & ~wr_data_i[2];
		end
	end

	assign fwd_decode_vec = {(iaddr == `REG_08_OFFS) & rd_wr_i, (iaddr == `REG_0C_OFFS) & rd_wr_i, (iaddr == `REG_10_OFFS)};

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			fwd_txn                            <= 0;
			usr_r_test_rd_p_o  <= 0;
			usr_ali_rd_p_o     <= 0;
			usr_rw_test_rd_p_o <= 0;
			usr_rw_test_wr_p_o <= 0;
		end
		else begin
			usr_r_test_rd_p_o  <= 0;
			usr_ali_rd_p_o     <= 0;
			usr_rw_test_rd_p_o <= 0;
			usr_rw_test_wr_p_o <= 0;
			if (u5_sync_generic_i_trans_start_p) begin
				fwd_txn            <= |fwd_decode_vec;
				usr_r_test_rd_p_o  <= fwd_decode_vec[2] & rd_wr_i;
				usr_ali_rd_p_o     <= fwd_decode_vec[1] & rd_wr_i;
				usr_rw_test_rd_p_o <= fwd_decode_vec[0] & rd_wr_i;
				usr_rw_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
			end
			else if (trans_done_p) begin
				fwd_txn <= 0;
			end
		end
	end

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			int_upd_rw <= 1;
			int_upd_rw_en <= 0;
		end
		else begin
			int_upd_rw <= (u7_sync_generic_i_int_upd_rw_p & int_upd_rw_en) | upd_rw_force_i;
			if (u8_sync_generic_i_int_upd_rw_arm_p)
				int_upd_rw_en <= 1;
			else if(u7_sync_generic_i_int_upd_rw_p)
				int_upd_rw_en <= 0;
		end
	end

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			mvstop_par_o  <= 'hc;
			sha_rw2_par_o <= 'h0;
		end
		else begin
			if (int_upd_rw) begin
				mvstop_par_o  <= mvstop_shdw;
				sha_rw2_par_o <= sha_rw2_shdw;
			end
		end
	end

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			int_upd_r <= 1;
			int_upd_r_en <= 0;
		end
		else begin
			int_upd_r <= (u9_sync_generic_i_int_upd_r_p & int_upd_r_en) | upd_r_force_i;
			if (u10_sync_generic_i_int_upd_r_arm_p)
				int_upd_r_en <= 1;
			else if(u9_sync_generic_i_int_upd_r_p)
				int_upd_r_en <= 0;
		end
	end

	always @(posedge clk_f20_i or negedge u6_sync_rst_i_int_rst_n) begin
		if (~u6_sync_rst_i_int_rst_n) begin
			sha_r_test_shdw <= 'h0;
		end
		else begin
			if (int_upd_r) begin
				sha_r_test_shdw <= sha_r_test_par_i;
			end
		end
	end

	assign rd_data_o = mux_rd_data;
	assign rd_err_o = mux_rd_err | addr_overshoot;

	always @(
		REG_04 or REG_0C or REG_18 or iaddr or mvstop_shdw or sha_r_test_shdw 
		or sha_rw2_shdw or usr_ali_par_i or usr_r_test_par_i or usr_rw_test_in_par_i 
		or ycdetect_par_i
	) begin
		mux_rd_err  <= 0;
		mux_rd_data <= 0;
		case (iaddr)
			`REG_04_OFFS : begin
				mux_rd_data[2:0] <= cond_slice(P__CVBSDETECT, REG_04[2:0]);
			end
			`REG_08_OFFS : begin
				mux_rd_data[10:3] <= sha_r_test_shdw;
				mux_rd_data[2] <= usr_r_test_par_i;
				mux_rd_data[1] <= ycdetect_par_i;
			end
			`REG_0C_OFFS : begin
				mux_rd_data[3:0] <= cond_slice(P__MVSTART, REG_0C[3:0]);
				mux_rd_data[7:4] <= mvstop_shdw;
				mux_rd_data[9:8] <= usr_ali_par_i;
			end
			`REG_10_OFFS : begin
				mux_rd_data[14:11] <= usr_rw_test_in_par_i;
			end
			`REG_14_OFFS : begin
				mux_rd_data <= sha_rw2_shdw;
			end
			`REG_18_OFFS : begin
				mux_rd_data[15:0] <= cond_slice(P__WD_16_TEST, REG_18[15:0]);
			end
			default: begin
				mux_rd_err <= 1;
			end
		endcase
	end

	sync_generic	#(
		.act(1),
		.kind(3),
		.rstact(0),
		.rstval(0),
		.sync(1)
	) u10_sync_generic_i (
		.clk_r(clk_f20),
		.clk_s(tie0_1),
		.rcv_o(u10_sync_generic_i_int_upd_r_arm_p),
		.rst_r(res_f20_n),
		.rst_s(tie0_1),
		.snd_i(upd_r_en)
	);

	sync_generic	#(
		.act(1),
		.kind(2),
		.rstact(0),
		.rstval(0),
		.sync(sync)
	) u5_sync_generic_i (
		.clk_r(clk_f20),
		.clk_s(tie0_1),
		.rcv_o(u5_sync_generic_i_trans_start_p),
		.rst_r(res_f20_n),
		.rst_s(tie0_1),
		.snd_i(trans_start_1_i)
	);

	sync_rst	#(
		.act(0),
		.sync(0)
	) u6_sync_rst_i (
		.clk_r(clk_f20),
		.rst_i(res_f20_n),
		.rst_o(u6_sync_rst_i_int_rst_n),
		.test_i(tie0_1)
	);

	sync_generic	#(
		.act(1),
		.kind(3),
		.rstact(0),
		.rstval(0),
		.sync(1)
	) u7_sync_generic_i (
		.clk_r(clk_f20),
		.clk_s(tie0_1),
		.rcv_o(u7_sync_generic_i_int_upd_rw_p),
		.rst_r(res_f20_n),
		.rst_s(tie0_1),
		.snd_i(upd_rw)
	);

	sync_generic	#(
		.act(1),
		.kind(3),
		.rstact(0),
		.rstval(0),
		.sync(1)
	) u8_sync_generic_i (
		.clk_r(clk_f20),
		.clk_s(tie0_1),
		.rcv_o(u8_sync_generic_i_int_upd_rw_arm_p),
		.rst_r(res_f20_n),
		.rst_s(tie0_1),
		.snd_i(upd_rw_en)
	);

	sync_generic	#(
		.act(1),
		.kind(3),
		.rstact(0),
		.rstval(0),
		.sync(1)
	) u9_sync_generic_i (
		.clk_r(clk_f20),
		.clk_s(tie0_1),
		.rcv_o(u9_sync_generic_i_int_upd_r_p),
		.rst_r(res_f20_n),
		.rst_s(tie0_1),
		.snd_i(upd_r)
	);

endmodule

module sync_generic(
	input  wire clk_r,
	input  wire clk_s,
	output wire rcv_o,
	input  wire rst_r,
	input  wire rst_s,
	input  wire snd_i
);
	parameter act = 1;
	parameter kind = 3;
	parameter rstact = 0;
	parameter rstval = 0;
	parameter sync = 1;
endmodule

module sync_rst(
	input  wire clk_r,
	input  wire rst_i,
	output wire rst_o,
	input  wire test_i
);
	parameter act = 0;
	parameter sync = 0;
endmodule