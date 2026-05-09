`timescale 1ns/10ps
`define tie0_1_c 1'b0

module rs_cfg_fe1
		(
		input	wire		clk_f20,
		input	wire		res_f20_n_i,
		input	wire		test_i,
		input	wire	[13:0]	addr_i,
		input	wire		trans_start,
		input	wire	[31:0]	wr_data_i,
		input	wire		rd_wr_i,
		input	wire		rst_n, // Added reset input
		output	wire	[31:0]	rd_data_o,
		output	wire		rd_err_o,
		output	wire		trans_done_o,
		output	wire		Cvbsdetect_par_o,
		input	wire		Cvbsdetect_set_p_i,
		input	wire		ycdetect_par_i,
		input	wire		usr_r_test_par_i,
		input	wire		usr_r_test_trans_done_p_i,
		output	reg		usr_r_test_rd_p_o,
		input	wire	[7:0]	sha_r_test_par_i,
		output	wire	[4:0]	mvstart_par_o,
		output	reg	[5:0]	mvstop_par_o,
		output	wire	[3:0]	usr_rw_test_par_o,
		input	wire	[3:0]	usr_rw_test_par_i,
		input	wire		usr_rw_test_trans_done_p_i,
		output	reg		usr_rw_test_rd_p_o,
		output	reg		usr_rw_test_wr_p_o,
		output	reg	[31:0]	sha_rw2_par_o,
		output	wire	[15:0]	wd_16_test_par_o,
		output	wire	[7:0]	wd_16_test2_par_o,
		input	wire		upd_rw_en_i,
		input	wire		upd_rw_force_i,
		input	wire		upd_rw_i,
		input	wire		upd_r_en_i,
		input	wire		upd_r_force_i,
		input	wire		upd_r_i
		);
		parameter sync = 0;
			wire		int_upd_r_p; 
			wire		int_upd_rw_p; 
			wire		tie0_1; 
			wire		u4_sync_generic_i_trans_start_p; 
			assign tie0_1 = `tie0_1_c;
        // ... existing code ...

        always @(posedge clk_f20 or negedge rst_n) begin
            if (~rst_n) begin
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

        always @(posedge clk_f20 or negedge rst_n) begin
            if (~rst_n) begin
                REG_0C[10:5] <= 'hc;
                REG_0C[4:0]  <= 'h7;
                REG_14       <= 'h0;
                REG_18[15:0] <= 'ha;
                REG_1C[7:0]  <= 'hff;
            end
            else begin
                // ... existing code ...
            end
        end

        always @(posedge clk_f20 or negedge rst_n) begin
            if (~rst_n) begin
                REG_04[0] <= 'h0;
            end
            else begin
                // ... existing code ...
            end
        end

        // ... existing code ...

        always @(posedge clk_f20 or negedge rst_n) begin
            if (~rst_n) begin
                fwd_txn                            <= 0;
                usr_r_test_rd_p_o  <= 0;
                usr_rw_test_rd_p_o <= 0;
                usr_rw_test_wr_p_o <= 0;
            end
            else begin
                // ... existing code ...
            end
        end

        always @(posedge clk_f20 or negedge rst_n) begin
            if (~rst_n)
                int_upd_rw <= 1;
            else
                int_upd_rw <= (int_upd_rw_p & upd_rw_en_i) | upd_rw_force_i;
        end

        // ... existing code ...

        always @(posedge clk_f20 or negedge rst_n) begin
            if (~rst_n)
                int_upd_r <= 1;
            else
                int_upd_r <= (int_upd_r_p & upd_r_en_i) | upd_r_force_i;
        end

        // ... existing code ...

		sync_generic	#(
			.act(1),
			.kind(2),
			.rstact(0),
			.rstval(0),
			.sync(0)
		) u4_sync_generic_i (	
			.clk_r(clk_f20),
			.clk_s(tie0_1),
			.rcv_o(u4_sync_generic_i_trans_start_p),
			.rst_r(rst_n),
			.rst_s(tie0_1),
			.snd_i(trans_start)
		);

		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u6_sync_generic_i (	
			.clk_r(clk_f20),
			.clk_s(tie0_1),
			.rcv_o(int_upd_rw_p),
			.rst_r(rst_n),
			.rst_s(tie0_1),
			.snd_i(upd_rw_i)
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
			.rcv_o(int_upd_r_p),
			.rst_r(rst_n),
			.rst_s(tie0_1),
			.snd_i(upd_r_i)
		);

endmodule