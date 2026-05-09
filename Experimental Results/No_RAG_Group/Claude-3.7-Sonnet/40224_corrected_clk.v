`timescale 1ns/10ps
`define tie0_1_c 1'b0 
module rs_cfg_fe1_clk_a
		(
		input	wire		clk_i, // Primary input clock
		input	wire		res_a_n_i,
		input	wire		test_i,
		input	wire	[13:0]	addr_i,
		input	wire		trans_start,
		input	wire	[31:0]	wr_data_i,
		input	wire		rd_wr_i,
		output	wire	[31:0]	rd_data_o,
		output	wire		rd_err_o,
		output	wire		trans_done_o,
		output	wire	[3:0]	dgatel_par_o,
		output	wire	[4:0]	dgates_par_o,
		output	wire	[2:0]	dummy_fe_par_o,
		output	wire	[3:0]	usr_w_test_par_o,
		input	wire		usr_w_test_trans_done_p_i,
		output	reg		usr_w_test_wr_p_o,
		output	wire	[3:0]	w_test_par_o,
		output	reg	[3:0]	sha_w_test_par_o,
		input	wire	[2:0]	r_test_par_i,
		input	wire		upd_w_en_i,
		input	wire		upd_w_force_i,
		input	wire		upd_w_i
		);
		parameter sync = 1;
		parameter cgtransp = 0;

// ... existing code ...

        always @(posedge clk_i or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                int_trans_done <= 0;
                wr_done_p <= 0;
                rd_done_p <= 0;
            end
            else begin
                wr_done_p <= wr_p;
                rd_done_p <= rd_p;
                if (trans_done_p)
                    int_trans_done <= ~int_trans_done;
            end
        end

// ... existing code ...

        always @(posedge clk_i or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                REG_00[11:9]  <= 'h0;
                REG_00[3:0]   <= 'h4;
                REG_00[8:4]   <= 'hf;
                REG_20[19:16] <= 'h0;
                REG_20[23:20] <= 'h0;
            end
            else if (u4_ccgc_iwr_clk_en) begin
                case (iaddr)
                    `REG_00_OFFS: begin
                        REG_00[11:9] <= wr_data_i[11:9];
                        REG_00[3:0]  <= wr_data_i[3:0];
                        REG_00[8:4]  <= wr_data_i[8:4];
                    end
                    `REG_20_OFFS: begin
                        REG_20[19:16] <= wr_data_i[19:16];
                        REG_20[23:20] <= wr_data_i[23:20];
                    end
                endcase
            end
        end

// ... existing code ...

        always @(posedge clk_i or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                fwd_txn <= 0;
                usr_w_test_wr_p_o <= 0;
            end
            else begin
                usr_w_test_wr_p_o <= 0;
                if (u2_sync_generic_i_trans_start_p) begin
                    fwd_txn <= |fwd_decode_vec;
                    usr_w_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
                end
                else if (trans_done_p)
                    fwd_txn <= 0;
            end
        end

// ... existing code ...

        always @(posedge clk_i or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n)
                int_upd_w <= 1;
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end

        always @(posedge clk_i) begin
            if (int_upd_w & u5_ccgc_ishdw_clk_en) begin
                sha_w_test_par_o <= sha_w_test_shdw;
            end
        end

// ... existing code ...

		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u12_sync_generic_i (
			.clk_r(clk_i),
			.clk_s(tie0_1),
			.rcv_o(int_upd_w_p),
			.rst_r(res_a_n_i),
			.rst_s(tie0_1),
			.snd_i(upd_w_i)
		);

		sync_generic	#(
			.act(1),
			.kind(2),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u2_sync_generic_i (
			.clk_r(clk_i),
			.clk_s(tie0_1),
			.rcv_o(u2_sync_generic_i_trans_start_p),
			.rst_r(res_a_n_i),
			.rst_s(tie0_1),
			.snd_i(trans_start)
		);

		sync_rst	#(
			.act(0),
			.sync(1)
		) u3_sync_rst_i (
			.clk_r(clk_i),
			.rst_i(res_a_n_i),
			.rst_o(u3_sync_rst_i_int_rst_n)
		);

		ccgc	#(
			.cgtransp(cgtransp)
		) u4_ccgc_i (
			.clk_i(clk_i),
			.clk_o(u4_ccgc_iwr_clk),
			.enable_i(u4_ccgc_iwr_clk_en),
			.test_i(test_i)
		);

		ccgc	#(
			.cgtransp(cgtransp)
		) u5_ccgc_i (
			.clk_i(clk_i),
			.clk_o(u5_ccgc_ishdw_clk),
			.enable_i(u5_ccgc_ishdw_clk_en),
			.test_i(test_i)
		);

endmodule

module sync_generic (
	output	clk_r,
	input	clk_s,
	output	rcv_o,
	output	rst_r,
	input	rst_s,
	output	snd_i
);
parameter act = 1 ;
parameter kind = 1 ;
parameter rstact = 1 ;
parameter rstval = 1 ;
parameter sync = 1 ;
endmodule

module sync_rst (
	input	clk_r,
	output	rst_i,
	output	rst_o
);
parameter act = 1 ;
parameter sync = 1 ;
endmodule

module ccgc(
	input	clk_i,
	output	clk_o,
	input	enable_i,
	input	test_i
);
parameter cgtransp = 0 ;
endmodule