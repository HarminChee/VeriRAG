`timescale 1ns/10ps
`define tie0_1_c 1'b0 
`timescale 1ns/10ps
`define tie0_1_c 1'b0 
module rs_cfg_fe1_clk_a
		(
		input	wire		clk_a,
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
			wire		int_upd_w_p; 
			wire		tie0_1; 
			wire		u2_sync_generic_i_trans_start_p; 
			wire		u3_sync_rst_i_int_rst_n; 
			wire		u4_ccgc_iwr_clk; 
			wire		u4_ccgc_iwr_clk_en; 
			wire		u5_ccgc_ishdw_clk; 
			wire		u5_ccgc_ishdw_clk_en; 
			wire		u6_ccgc_ird_clk; 
			wire		u6_ccgc_ird_clk_en; 
			assign tie0_1 = `tie0_1_c;
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
        reg  [31:0] REG_0C;
        reg  [31:0] REG_10;
        reg  [31:0] REG_14;
        reg  [31:0] REG_18;
        reg  [31:0] REG_1C;
        reg  [31:0] REG_20;
        wire [3:0] sha_w_test_shdw;
        reg  [31:0] REG_28;
        reg  int_upd_w;
        wire wr_p;
        wire rd_p;
        reg  int_trans_done;
        wire [3:0] iaddr;
        wire addr_overshoot;
        wire trans_done_p;
        reg  rd_done_p;
        reg  wr_done_p;
        reg  fwd_txn;
        wire [0:0] fwd_decode_vec;
        wire [0:0] fwd_done_vec;
        reg  [31:0] mux_rd_data;
        reg  mux_rd_err;
        reg  [31:0] mux_rd_data_0_0;
        reg  mux_rd_err_0_0;
        reg  [31:0] mux_rd_data_0_2;
        reg  mux_rd_err_0_2;
        assign dummy_fe_par_o   = REG_00[11:9];
        assign dgatel_par_o     = REG_00[3:0];
        assign dgates_par_o     = REG_00[8:4];
        assign w_test_par_o     = REG_20[19:16];
        assign sha_w_test_shdw               = REG_20[23:20];
        assign usr_w_test_par_o = wr_data_i[3:0];
        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6];
        assign u4_ccgc_iwr_clk_en = wr_p; 
        assign u5_ccgc_ishdw_clk_en = int_upd_w; 
        assign u6_ccgc_ird_clk_en = rd_p; 
        assign wr_p = ~rd_wr_i & u2_sync_generic_i_trans_start_p;
        assign rd_p = rd_wr_i & u2_sync_generic_i_trans_start_p;
        assign fwd_done_vec = {usr_w_test_trans_done_p_i}; 
        assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 0) & fwd_txn);
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
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
        assign trans_done_o = int_trans_done;
        always @(posedge u4_ccgc_iwr_clk or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                REG_00[11:9]  <= 'h0;
                REG_00[3:0]   <= 'h4;
                REG_00[8:4]   <= 'hf;
                REG_20[19:16] <= 'h0;
                REG_20[23:20] <= 'h0;
            end
            else begin
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
        assign fwd_decode_vec = {(iaddr == `REG_20_OFFS) & ~rd_wr_i};
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                fwd_txn                           <= 0;
                usr_w_test_wr_p_o <= 0;
            end
            else begin
                usr_w_test_wr_p_o <= 0;
                if (u2_sync_generic_i_trans_start_p) begin
                    fwd_txn                           <= |fwd_decode_vec; 
                    usr_w_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
                end
                else if (trans_done_p)
                    fwd_txn <= 0; 
                end
            end
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n)
                int_upd_w <= 1;
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end
        always @(posedge u5_ccgc_ishdw_clk) begin
            if (int_upd_w) begin
                sha_w_test_par_o <= sha_w_test_shdw;
            end
        end
        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;
        always @(iaddr or mux_rd_data_0_0 or mux_rd_err_0_0 or mux_rd_data_0_2 or mux_rd_err_0_2) begin 
            case (iaddr[3:2])
                0: begin
                    mux_rd_data <= mux_rd_data_0_0;
                    mux_rd_err  <= mux_rd_err_0_0;
                end
                2: begin
                    mux_rd_data <= mux_rd_data_0_2;
                    mux_rd_err  <= mux_rd_err_0_2;
                end
                default: begin
                    mux_rd_data <= 0;
                    mux_rd_err <= 1;
                end
            endcase
        end
        always @(posedge u6_ccgc_ird_clk or negedge u3_sync_rst_i_int_rst_n) begin 
            if (~u3_sync_rst_i_int_rst_n) begin
                mux_rd_data_0_0 <= 0;
                mux_rd_err_0_0 <= 0;
            end
            else begin
                mux_rd_err_0_0 <= 0;
                case (iaddr[1:0])
                    0: begin
                        mux_rd_data_0_0[3:0] <= REG_00[3:0];
                        mux_rd_data_0_0[8:4] <= REG_00[8:4];
                        mux_rd_data_0_0[11:9] <= REG_00[11:9];
                    end
                    default: begin
                        mux_rd_data_0_0 <= 0;
                        mux_rd_err_0_0 <= 1;
                    end
                endcase
            end
        end
        always @(posedge u6_ccgc_ird_clk or negedge u3_sync_rst_i_int_rst_n) begin 
            if (~u3_sync_rst_i_int_rst_n) begin
                mux_rd_data_0_2 <= 0;
                mux_rd_err_0_2 <= 0;
            end
            else begin
                mux_rd_err_0_2 <= 0;
                case (iaddr[1:0])
                    2: begin
                        mux_rd_data_0_2[2:0] <= r_test_par_i;
                    end
                    default: begin
                        mux_rd_data_0_2 <= 0;
                        mux_rd_err_0_2 <= 1;
                    end
                endcase
            end
        end
        `ifdef ASSERT_ON
        property p_pos_pulse_check (sig); 
             @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
             sig |=> ~sig;
        endproperty
        assert property(p_pos_pulse_check(usr_w_test_trans_done_p_i));
        p_fwd_done_expected: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           usr_w_test_trans_done_p_i |-> fwd_txn
        );
        p_fwd_done_onehot: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           usr_w_test_trans_done_p_i |-> onehot(fwd_done_vec)
        );
        p_fwd_done_only_when_fwd_txn: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           fwd_done_vec != 0 |-> fwd_txn
        );
        function onehot (input [0:0] vec); 
          integer i,j;
          begin
             j = 0;
        	 for (i=0; i<1; i=i+1) j = j + vec[i] ? 1 : 0;
        	 onehot = (j==1) ? 1 : 0;
          end
        endfunction
        `endif
		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u14_sync_generic_i (	
			.clk_r(clk_a),
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
			.clk_r(clk_a),
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
			.clk_r(clk_a),
			.rst_i(res_a_n_i),
			.rst_o(u3_sync_rst_i_int_rst_n)
		);
		ccgc	#(
			.cgtransp(cgtransp) 
		) u4_ccgc_i (	
			.clk_i(clk_a),
			.clk_o(u4_ccgc_iwr_clk),
			.enable_i(u4_ccgc_iwr_clk_en),
			.test_i(test_i)
		);
		ccgc	#(
			.cgtransp(cgtransp) 
		) u5_ccgc_i (	
			.clk_i(clk_a),
			.clk_o(u5_ccgc_ishdw_clk),
			.enable_i(u5_ccgc_ishdw_clk_en),
			.test_i(test_i)
		);
		ccgc	#(
			.cgtransp(cgtransp) 
		) u6_ccgc_i (	
			.clk_i(clk_a),
			.clk_o(u6_ccgc_ird_clk),
			.enable_i(u6_ccgc_ird_clk_en),
			.test_i(test_i)
		);
endmodule
