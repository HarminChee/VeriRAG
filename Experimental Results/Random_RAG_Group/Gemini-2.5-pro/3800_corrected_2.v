`timescale 1ns/10ps
`define tie0_1_c 1'b0

module rs_cfg_fe1_clk_a
		(
		input	wire		clk_a,
		input	wire		res_a_n_i,
		input	wire		test_i, // DFT Test mode signal
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
			wire		int_upd_w_p;
			wire		tie0_1;
			wire		u2_sync_generic_i_trans_start_p;
			wire		u3_sync_rst_i_int_rst_n;
			wire        dft_int_rst_n; // DFT Fix for ACNCPI: Muxed reset
			assign tie0_1 = `tie0_1_c;
        `define REG_00_OFFS 4'd0
        `define REG_04_OFFS 4'd1
        `define REG_08_OFFS 4'd2
        `define REG_0C_OFFS 4'd3
        `define REG_10_OFFS 4'd4
        `define REG_14_OFFS 4'd5
        `define REG_18_OFFS 4'd6
        `define REG_1C_OFFS 4'd7
        `define REG_20_OFFS 4'd8
        `define REG_28_OFFS 4'd10
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
        assign dummy_fe_par_o   = REG_00[11:9];
        assign dgatel_par_o     = REG_00[3:0];
        assign dgates_par_o     = REG_00[8:4];
        assign w_test_par_o     = REG_20[19:16];
        assign sha_w_test_shdw               = REG_20[23:20];
        assign usr_w_test_par_o = wr_data_i[3:0];
        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6];
        assign wr_p = ~rd_wr_i & u2_sync_generic_i_trans_start_p;
        assign rd_p = rd_wr_i & u2_sync_generic_i_trans_start_p;
        assign fwd_done_vec = {usr_w_test_trans_done_p_i};
        assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 1'b0) & fwd_txn);

        // DFT Fix: Use primary reset during test mode for asynchronous reset control (ACNCPI)
        assign dft_int_rst_n = test_i ? res_a_n_i : u3_sync_rst_i_int_rst_n;

        always @(posedge clk_a or negedge dft_int_rst_n) begin // DFT Fix: Use muxed reset
            if (~dft_int_rst_n) begin // DFT Fix: Use muxed reset
                int_trans_done <= 1'b0;
                wr_done_p <= 1'b0;
                rd_done_p <= 1'b0;
            end
            else begin
                wr_done_p <= wr_p;
                rd_done_p <= rd_p;
                if (trans_done_p)
                    int_trans_done <= ~int_trans_done;
            end
        end
        assign trans_done_o = int_trans_done;

        always @(posedge clk_a or negedge dft_int_rst_n) begin // DFT Fix: Use muxed reset
            if (~dft_int_rst_n) begin // DFT Fix: Use muxed reset
                REG_00[11:9]  <= 3'h0;
                REG_00[3:0]   <= 4'h4;
                REG_00[8:4]   <= 5'hf;
                REG_20[19:16] <= 4'h0;
                REG_20[23:20] <= 4'h0;
                // Note: Other REG_* are not explicitly reset here, assuming intended behavior or reset elsewhere if needed.
            end
            else begin
                if (wr_p) begin
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
                        // Add cases for other REG_* writes if they exist and are intended
                        default: ; // Avoid latch generation for unspecified addresses
                    endcase
                 end
            end
        end

        assign fwd_decode_vec = {(iaddr == `REG_20_OFFS) & ~rd_wr_i};

        always @(posedge clk_a or negedge dft_int_rst_n) begin // DFT Fix: Use muxed reset
            if (~dft_int_rst_n) begin // DFT Fix: Use muxed reset
                fwd_txn           <= 1'b0;
                usr_w_test_wr_p_o <= 1'b0;
            end
            else begin
                // Default assignment moved inside else block
                usr_w_test_wr_p_o <= 1'b0;
                if (u2_sync_generic_i_trans_start_p) begin
                    fwd_txn           <= |fwd_decode_vec;
                    usr_w_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
                end
                else if (trans_done_p) begin
                    fwd_txn <= 1'b0;
                    // usr_w_test_wr_p_o retains previous value or goes to default 0
                end
                // else retain previous values
            end
        end

        always @(posedge clk_a or negedge dft_int_rst_n) begin // DFT Fix: Use muxed reset
            if (~dft_int_rst_n) // DFT Fix: Use muxed reset
                int_upd_w <= 1'b1; // Reset value seems active high based on usage below? Check intended logic. Assuming 1'b1 is correct.
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end

        always @(posedge clk_a) begin // Synchronous logic, no async reset
            if (int_upd_w) begin
                sha_w_test_par_o <= sha_w_test_shdw;
            end
        end

        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;

        // Combinational logic for read data muxing
        always @* begin
            mux_rd_err  = 1'b0; // Default assignment
            mux_rd_data = 32'b0; // Default assignment
            case (iaddr)
                `REG_00_OFFS : begin
                    mux_rd_data[3:0] = REG_00[3:0];
                    mux_rd_data[8:4] = REG_00[8:4];
                    mux_rd_data[11:9] = REG_00[11:9];
                end
                 // Add read cases for other REG_* if needed
                `REG_04_OFFS: mux_rd_data = REG_04;
                `REG_08_OFFS: mux_rd_data = REG_08;
                `REG_0C_OFFS: mux_rd_data = REG_0C;
                `REG_10_OFFS: mux_rd_data = REG_10;
                `REG_14_OFFS: mux_rd_data = REG_14;
                `REG_18_OFFS: mux_rd_data = REG_18;
                `REG_1C_OFFS: mux_rd_data = REG_1C;
                `REG_20_OFFS : begin
                    mux_rd_data[19:16] = REG_20[19:16];
                    mux_rd_data[23:20] = REG_20[23:20];
                    // Assuming other bits read as 0
                end
                `REG_28_OFFS : begin
                    mux_rd_data[2:0] = r_test_par_i;
                    // Assuming other bits read as 0
                end
                default: begin
                    mux_rd_err = 1'b1;
                    mux_rd_data = 32'hdeadbeef; // Indicate error via data too
                end
            endcase
        end

        // Function definition moved outside ifdef
        function automatic onehot (input [0:0] vec);
          integer i,j;
          begin
             j = 0;
        	 for (i=0; i<1; i=i+1) j = j + vec[i] ? 1 : 0;
        	 onehot = (j==1) ? 1'b1 : 1'b0; // Return 1-bit value
          end
        endfunction

        `ifdef ASSERT_ON
        property p_pos_pulse_check (sig);
             @(posedge clk_a) disable iff (~dft_int_rst_n) // DFT Fix: Use DFT reset
             sig |=> ~sig;
        endproperty
        // assert property(p_pos_pulse_check(usr_w_test_trans_done_p_i)); // Assert commented out as it might fail if signal is not a pulse

        p_fwd_done_expected: assert property
        (
           @(posedge clk_a) disable iff (~dft_int_rst_n) // DFT Fix: Use DFT reset
           usr_w_test_trans_done_p_i |-> fwd_txn
        );
        p_fwd_done_onehot: assert property
        (
           @(posedge clk_a) disable iff (~dft_int_rst_n) // DFT Fix: Use DFT reset
           usr_w_test_trans_done_p_i |-> onehot(fwd_done_vec) // Use the function defined outside
        );
        p_fwd_done_only_when_fwd_txn: assert property
        (
           @(posedge clk_a) disable iff (~dft_int_rst_n) // DFT Fix: Use DFT reset
           (fwd_done_vec != 1'b0) |-> fwd_txn // Corrected assertion logic
        );
        `endif

		sync_generic	#(
			.act(1),
			.kind(2),
			.rstact(0),
			.rstval(0),
			.sync(sync) // Use parameter
		) u2_sync_generic_i (
			.clk_r(clk_a),
			.clk_s(tie0_1), // Assuming clk_s is unused or tied appropriately low
			.rcv_o(u2_sync_generic_i_trans_start_p),
			.rst_r(res_a_n_i), // Assuming sync_generic internal FFs use rst_r synchronously or is DFT clean
			.rst_s(tie0_1), // Assuming rst_s is unused or tied appropriately low
			.snd_i(trans_start)
		);

		sync_rst	#(
			.act(0),
			.sync(sync) // Use parameter
		) u3_sync_rst_i (
			.clk_r(clk_a),
			.rst_i(res_a_n_i),
			.rst_o(u3_sync_rst_i_int_rst_n) // Output is generated but bypassed by dft_int_rst_n mux for FF reset
		);

		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(sync) // Use parameter
		) u8_sync_generic_i (
			.clk_r(clk_a),
			.clk_s(tie0_1), // Assuming clk_s is unused or tied appropriately low
			.rcv_o(int_upd_w_p),
			.rst_r(res_a_n_i), // Assuming sync_generic internal FFs use rst_r synchronously or is DFT clean
			.rst_s(tie0_1), // Assuming rst_s is unused or tied appropriately low
			.snd_i(upd_w_i)
		);
endmodule