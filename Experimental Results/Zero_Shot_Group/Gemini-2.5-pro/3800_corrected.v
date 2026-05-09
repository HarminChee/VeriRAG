`timescale 1ns/10ps
`define tie0_1_c 1'b0

module rs_cfg_fe1_clk_a
		(
		input	wire		clk_a,
		input	wire		res_a_n_i,
		input	wire		test_i, // Unused?
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

			wire		int_upd_w_p;
			wire		tie0_1;
			wire		u2_sync_generic_i_trans_start_p;
			wire		u3_sync_rst_i_int_rst_n;

			assign tie0_1 = `tie0_1_c;

        `define REG_00_OFFS 0
        `define REG_04_OFFS 1 // Defined but not used
        `define REG_08_OFFS 2 // Defined but not used
        `define REG_0C_OFFS 3 // Defined but not used
        `define REG_10_OFFS 4 // Defined but not used
        `define REG_14_OFFS 5 // Defined but not used
        `define REG_18_OFFS 6 // Defined but not used
        `define REG_1C_OFFS 7 // Defined but not used
        `define REG_20_OFFS 8
        `define REG_28_OFFS 10

        // Register Declarations - Note: Many are declared but only partially written/read or not used
        reg  [31:0] REG_00;
        // reg  [31:0] REG_04; // Declared but not used
        // reg  [31:0] REG_08; // Declared but not used
        // reg  [31:0] REG_0C; // Declared but not used
        // reg  [31:0] REG_10; // Declared but not used
        // reg  [31:0] REG_14; // Declared but not used
        // reg  [31:0] REG_18; // Declared but not used
        // reg  [31:0] REG_1C; // Declared but not used
        reg  [31:0] REG_20;
        wire [3:0] sha_w_test_shdw;
        // reg  [31:0] REG_28; // Declared but not written; read logic uses r_test_par_i instead

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
        assign sha_w_test_shdw  = REG_20[23:20];
        assign usr_w_test_par_o = wr_data_i[3:0]; // Note: Directly from input write data

        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6]; // Address out of range check

        assign wr_p = ~rd_wr_i & u2_sync_generic_i_trans_start_p;
        assign rd_p = rd_wr_i & u2_sync_generic_i_trans_start_p;

        assign fwd_done_vec = {usr_w_test_trans_done_p_i};
        assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 1'b0) & fwd_txn); // Corrected check for non-zero vector

        // Transaction done logic
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                int_trans_done <= 1'b0;
                wr_done_p <= 1'b0;
                rd_done_p <= 1'b0;
            end
            else begin
                // Capture single cycle pulses for read/write operations
                wr_done_p <= wr_p;
                rd_done_p <= rd_p;
                // Toggle done signal upon completion
                if (trans_done_p)
                    int_trans_done <= ~int_trans_done;
            end
        end
        assign trans_done_o = int_trans_done;

        // Register write logic
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                // Reset values for used registers/fields
                REG_00[11:9]  <= 3'h0;
                REG_00[3:0]   <= 4'h4;
                REG_00[8:4]   <= 5'hf;
                REG_20[19:16] <= 4'h0;
                REG_20[23:20] <= 4'h0;
                // Consider resetting unused bits of REG_00 and REG_20 if necessary
                REG_00[31:12] <= 20'b0;
                REG_00[2:1] <= 2'b0; // Assuming bits 1&2 are unused in addr 0
                REG_20[31:24] <= 8'b0;
                REG_20[15:0] <= 16'b0; // Assuming other bits are unused in addr 20

            end
            else begin
                if (wr_p & ~addr_overshoot) begin // Only write if address is valid
                    case (iaddr)
                        `REG_00_OFFS: begin
                            REG_00[11:9] <= wr_data_i[11:9];
                            REG_00[3:0]  <= wr_data_i[3:0];
                            REG_00[8:4]  <= wr_data_i[8:4];
                            // Consider writing other bits if they are meant to be writable
                        end
                        `REG_20_OFFS: begin
                            REG_20[19:16] <= wr_data_i[19:16];
                            REG_20[23:20] <= wr_data_i[23:20]; // This drives sha_w_test_shdw
                            // Consider writing other bits if they are meant to be writable
                        end
                        // Add cases for other registers if they become writable
                        default: begin
                            // No write action for undefined addresses
                        end
                    endcase
                end
            end
        end

        // Forwarded transaction logic
        assign fwd_decode_vec = {(iaddr == `REG_20_OFFS) & ~rd_wr_i}; // Forward write to REG_20

        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                fwd_txn           <= 1'b0;
                usr_w_test_wr_p_o <= 1'b0;
            end
            else begin
                usr_w_test_wr_p_o <= 1'b0; // Default to 0, pulse generation
                if (u2_sync_generic_i_trans_start_p) begin
                    fwd_txn           <= |fwd_decode_vec; // Set if any forwarded transaction is decoded
                    usr_w_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i; // Generate pulse if specific forward condition met
                end
                else if (trans_done_p) begin // Clear fwd_txn when transaction completes
                    fwd_txn <= 1'b0;
                end
                // else fwd_txn retains its value if no start or done pulse
            end
        end // Added missing end

        // Shadow register update logic
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n)
                int_upd_w <= 1'b1; // Initialize to allow first update? Or should be 0? Assuming 1 based on original code.
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end

        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin // Added reset
            if (~u3_sync_rst_i_int_rst_n) begin
                sha_w_test_par_o <= 4'h0; // Reset shadow register
            end else begin
                if (int_upd_w) begin
                    sha_w_test_par_o <= sha_w_test_shdw; // Update shadow from main reg
                end
            end
        end

        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot; // Error if address out of range or read from invalid offset

        // Read multiplexer logic
        always @(*) begin // Use wildcard sensitivity list for combinational logic
            mux_rd_err  = 1'b0; // Default no error
            mux_rd_data = 32'b0; // Default read data
            case (iaddr)
                `REG_00_OFFS : begin
                    // Return only the implemented bits of REG_00
                    mux_rd_data[3:0]  = REG_00[3:0];
                    mux_rd_data[8:4]  = REG_00[8:4];
                    mux_rd_data[11:9] = REG_00[11:9];
                    // Other bits read as 0
                end
                `REG_20_OFFS : begin
                    // Return only the implemented bits of REG_20
                    mux_rd_data[19:16] = REG_20[19:16]; // w_test_par_o
                    mux_rd_data[23:20] = REG_20[23:20]; // sha_w_test_shdw
                     // Other bits read as 0
                end
                `REG_28_OFFS : begin
                    // Special read - directly maps input r_test_par_i
                    mux_rd_data[2:0] = r_test_par_i;
                    // Other bits read as 0
                end
                default: begin
                    // Access to unimplemented or reserved address
                    mux_rd_err = 1'b1;
                    mux_rd_data = 32'hDEADBEEF; // Indicate error via data bus too (optional)
                end
            endcase
        end

        // Assertions (optional, kept as in original)
        `ifdef ASSERT_ON
        property p_pos_pulse_check (sig);
             @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
             sig |=> ~sig;
        endproperty
        // Check usr_w_test_trans_done_p_i is a positive pulse
        a_usr_w_test_trans_done_p_i_pulse: assert property(p_pos_pulse_check(usr_w_test_trans_done_p_i));

        // Check fwd_txn is active when done signal arrives
        p_fwd_done_expected: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           usr_w_test_trans_done_p_i |-> fwd_txn
        );

        // Check fwd_done_vec is onehot when asserted (trivial for 1 bit)
        p_fwd_done_onehot: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           usr_w_test_trans_done_p_i |-> onehot(fwd_done_vec)
        );

        // Check fwd_done only happens when fwd_txn is active
        p_fwd_done_only_when_fwd_txn: assert property
        (
           @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
           (fwd_done_vec != 1'b0) |-> fwd_txn // Corrected check for non-zero
        );

        // onehot function (correct for 1-bit input)
        function automatic onehot (input [0:0] vec);
          // integer i,j; // Unneeded for 1 bit
          // begin
          //    j = 0;
        	 // for (i=0; i<1; i=i+1) j = j + vec[i] ? 1 : 0; // Simpler check below
        	 // onehot = (j==1) ? 1'b1 : 1'b0;
          // end
          return vec[0]; // For a 1-bit vector, it's onehot if it's 1
        endfunction
        `endif

		// Instantiations of synchronizer cells
		sync_generic	#(
			.act(1),    // Active high
			.kind(2),   // Pulse synchronizer
			.rstact(0), // Async reset active low
			.rstval(0), // Reset value
			.sync(1)    // Number of sync stages
		) u2_sync_generic_i (
			.clk_r(clk_a),     // Receiving clock
			.clk_s(tie0_1),    // Sending clock (tied off - implies async input)
			.rcv_o(u2_sync_generic_i_trans_start_p), // Synchronized output pulse
			.rst_r(res_a_n_i), // Receiving reset
			.rst_s(tie0_1),    // Sending reset (tied off)
			.snd_i(trans_start) // Async input signal
		);

		sync_rst	#(
			.act(0),    // Active low reset output
			.sync(1)    // Number of sync stages
		) u3_sync_rst_i (
			.clk_r(clk_a),     // Clock domain for reset
			.rst_i(res_a_n_i), // Async reset input
			.rst_o(u3_sync_rst_i_int_rst_n) // Synchronized reset output
		);

		sync_generic	#(
			.act(1),    // Active high
			.kind(3),   // Level synchronizer
			.rstact(0), // Async reset active low
			.rstval(0), // Reset value
			.sync(1)    // Number of sync stages
		) u8_sync_generic_i (
			.clk_r(clk_a),     // Receiving clock
			.clk_s(tie0_1),    // Sending clock (tied off - implies async input)
			.rcv_o(int_upd_w_p), // Synchronized output level
			.rst_r(res_a_n_i), // Receiving reset
			.rst_s(tie0_1),    // Sending reset (tied off)
			.snd_i(upd_w_i)    // Async input signal
		);

endmodule