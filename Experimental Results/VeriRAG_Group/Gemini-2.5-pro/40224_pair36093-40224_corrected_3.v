`timescale 1ns/10ps
`define tie0_1_c 1'b0
module rs_cfg_fe1_clk_a
		(
//		input	wire		test_i, // This line was commented out, keep it commented
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


	// Internal signals

		//
		// Generated Signal List
		//
			wire		int_upd_w_p;
			wire		tie0_1;
			wire		u2_sync_generic_i_trans_start_p;
			wire		u3_sync_rst_i_int_rst_n;
			wire		u4_ccgc_iwr_clk;
			wire		u4_ccgc_iwr_clk_en;
			wire		u5_ccgc_ishdw_clk;
			wire		u5_ccgc_ishdw_clk_en;
		//
		// End of Generated Signal List
		//

        // DFT signals
        wire dft_res_n;
        wire dft_u4_clk;
        wire dft_u5_clk;


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign tie0_1 = `tie0_1_c;

        // DFT Signal Assignments
            assign dft_res_n = test_i ? res_a_n_i : u3_sync_rst_i_int_rst_n;
            assign dft_u4_clk = test_i ? clk_a : u4_ccgc_iwr_clk;
            assign dft_u5_clk = test_i ? clk_a : u5_ccgc_ishdw_clk;


        /*
          Generator information:
          used package Micronas::Reg is version 1.16
        */

        /*
          local definitions
        */
        `define REG_00_OFFS 0 // reg_0x0
        `define REG_04_OFFS 1 // reg_0x4
        `define REG_08_OFFS 2 // reg_0x8
        `define REG_0C_OFFS 3 // reg_0xC
        `define REG_10_OFFS 4 // reg_0x10
        `define REG_14_OFFS 5 // reg_0x14
        `define REG_18_OFFS 6 // reg_0x18
        `define REG_1C_OFFS 7 // reg_0x1C
        `define REG_20_OFFS 8 // reg_0x20
        `define REG_28_OFFS 10 // reg_0x28

        /*
          local wire or register declarations
        */
        reg  [31:0] REG_00;
        reg  [31:0] REG_04; // Declared but not fully used
        reg  [31:0] REG_08; // Declared but not fully used
        reg  [31:0] REG_0C; // Declared but not fully used
        reg  [31:0] REG_10; // Declared but not fully used
        reg  [31:0] REG_14; // Declared but not fully used
        reg  [31:0] REG_18; // Declared but not fully used
        reg  [31:0] REG_1C; // Declared but not fully used
        reg  [31:0] REG_20;
        wire [3:0] sha_w_test_shdw;
        reg  [31:0] REG_28; // Declared but never written locally
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
        wire fwd_decode_vec; // Width is 1 bit
        wire fwd_done_vec; // Width is 1 bit
        reg  [31:0] mux_rd_data;
        reg  mux_rd_err;

        /*
          local wire and output assignments
        */
        assign dummy_fe_par_o   = REG_00[11:9];
        assign dgatel_par_o     = REG_00[3:0];
        assign dgates_par_o     = REG_00[8:4];
        assign w_test_par_o     = REG_20[19:16];
        assign sha_w_test_shdw  = REG_20[23:20];
        assign usr_w_test_par_o = wr_data_i[3:0];

        // clip address to decoded range
        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6];

        /*
          clock enable signals
        */
        assign u4_ccgc_iwr_clk_en = wr_p; // write-clock enable
        assign u5_ccgc_ishdw_clk_en = int_upd_w; // shadow-clock enable

        // write txn start pulse
        assign wr_p = ~rd_wr_i & u2_sync_generic_i_trans_start_p;

        // read txn start pulse
        assign rd_p = rd_wr_i & u2_sync_generic_i_trans_start_p;

        /*
          generate txn done signals
        */
        assign fwd_done_vec = usr_w_test_trans_done_p_i; // ack for forwarded txns (1 bit)
        assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 1'b0) & fwd_txn); // Use explicit width comparison

        always @(posedge clk_a or negedge dft_res_n) begin
		 	if (~dft_res_n) begin
                int_trans_done <= 1'b0;
                wr_done_p <= 1'b0;
                rd_done_p <= 1'b0;
            end
            else begin
                wr_done_p <= wr_p;
                rd_done_p <= rd_p;
                if (trans_done_p)
                    int_trans_done <= ~int_trans_done; // Toggles on completion pulse
                // else int_trans_done holds value
            end
        end
        assign trans_done_o = int_trans_done;

        /*
          write process
        */
        always @(posedge dft_u4_clk or negedge dft_res_n) begin
			if (~dft_res_n) begin
                REG_00[11:9]  <= 3'h0;
                REG_00[3:0]   <= 4'h4;
                REG_00[8:4]   <= 5'hf;
                REG_20[19:16] <= 4'h0;
                REG_20[23:20] <= 4'h0;
            end
            else if (u4_ccgc_iwr_clk_en) begin // Write only when clock enable is asserted (functional mode) or test_i=1 (DFT mode)
                                               // Note: Actual clock gating is handled by dft_u4_clk mux and ccgc cell
                // Use non-blocking assignments inside sequential blocks
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
                    // No default case needed for writes if unaddressed regs should hold state
                endcase
            end
        end

        /*
          txn forwarding process
        */
        // decode addresses of USR registers and read/write
        assign fwd_decode_vec = (iaddr == `REG_20_OFFS) & ~rd_wr_i; // Removed unnecessary {}

        always @(posedge clk_a or negedge dft_res_n) begin
			if (~dft_res_n) begin
                fwd_txn           <= 1'b0;
                usr_w_test_wr_p_o <= 1'b0;
            end
            else begin
                // Default assignments
                usr_w_test_wr_p_o <= 1'b0;

                if (u2_sync_generic_i_trans_start_p) begin
                    fwd_txn           <= fwd_decode_vec; // set flag for forwarded txn (use signal directly)
                    usr_w_test_wr_p_o <= fwd_decode_vec & ~rd_wr_i; // Use signal directly
                end
                else if (trans_done_p) begin
                    fwd_txn <= 1'b0; // reset flag for forwarded transaction
                    // usr_w_test_wr_p_o keeps its default 1'b0 value here
                end
                // else fwd_txn holds value
            end
        end

        /*
          shadowing for update signal 'upd_w'
        */
        // generate internal update signal
       always @(posedge clk_a or negedge dft_res_n) begin
	  	    if (~dft_res_n)
                int_upd_w <= 1'b1; // Initialize update signal high during reset? Check spec. Assuming OK.
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end
        // shadow process
        always @(posedge dft_u5_clk) begin // Removed reset sensitivity as original didn't have one.
             // Update only when clock enable (int_upd_w / u5_ccgc_ishdw_clk_en) is active (handled by clock gating cell / dft mux)
             sha_w_test_par_o <= sha_w_test_shdw;
        end

        /*
          read logic and mux process
        */
        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;
        always @(*) begin // Use implicit sensitivity list
            mux_rd_err  = 1'b0; // Default assignment
            mux_rd_data = 32'b0; // Default assignment