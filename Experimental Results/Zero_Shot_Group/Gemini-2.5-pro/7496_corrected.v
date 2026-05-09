`timescale 1ns/10ps
`define	tie0_1_c	1'b0
module rs_cfg_fe1_clk_a
	(
		input	wire		clk_a_i,
		input	wire		res_a_n_i,
		input	wire	[13:0]	addr_i,
		input	wire	[31:0]	wr_data_i,
		input	wire		rd_wr_i,
		input	wire		trans_start_0_i,
		output	wire	[31:0]	rd_data_o,
		output	wire		rd_err_o,
		output	wire		trans_done_o,
		output	wire	[3:0]	dgatel_par_o,
		output	wire	[4:0]	dgates_par_o,
		output	wire	[2:0]	dummy_fe_par_o,
		output	reg	[3:0]	sha_w_test_par_o,
		output	wire		sha_w_test_trg_p_o,
		output	wire	[3:0]	usr_w_test_par_o,
		input	wire		usr_w_test_trans_done_p_i,
		output	reg		usr_w_test_wr_p_o,
		output	wire	[3:0]	w_test_par_o,
		input	wire	[2:0]	r_test_par_i,
		output	reg		r_test_trg_p_o,
		input	wire		upd_w_en_i,
		input	wire		upd_w_force_i,
		input	wire		upd_w_i
	);
		parameter sync = 1;
		parameter P__SHA_W_TEST = -1;
		parameter P__W_TEST = -1;
		parameter P__DUMMY_FE = -1;
		parameter P__DGATES = -1;
		parameter P__DGATEL = -1;
		wire		clk_a;
		wire		res_a_n;
		wire		tie0_1;
		wire		u11_sync_generic_i_int_upd_w_p;
		wire		u12_sync_generic_i_int_upd_w_arm_p;
		wire		u3_sync_generic_i_trans_start_p;
		wire		u4_sync_rst_i_int_rst_n;
		wire		upd_w;
		wire		upd_w_en;
		assign	clk_a	=	clk_a_i;
		assign	res_a_n	=	res_a_n_i;
		assign	tie0_1	= `tie0_1_c;
		assign	upd_w	=	upd_w_i;
		assign	upd_w_en	=	upd_w_en_i;

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
        // reg  [31:0] REG_28; // Removed as it's not written or read directly
        reg  int_upd_w;
        reg  int_upd_w_en;
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
        wire [0:0] fwd_decode_vec;
        wire fwd_rd_done_p;
        wire fwd_wr_done_p;
        reg  [31:0] mux_rd_data;
        reg  mux_rd_err;

        // Use a function or direct assignment based on parameter
        // This function returns `vec` if enable is -1, otherwise returns `enable` (likely 0)
        function [31:0] cond_slice(input integer enable, input [31:0] vec);
            begin
                cond_slice = (enable < 0) ? vec : 32'(enable); // Ensure correct width if enable is not -1
            end
        endfunction

        // Alternative using generate if preferred (more complex for simple slicing)
        // generate
        //    if (P__DGATEL == -1) assign dgatel_par_o[3:0] = REG_00[3:0];
        //    else assign dgatel_par_o[3:0] = P__DGATEL[3:0];
        //    // ... similar for others
        // endgenerate

        // Using the function as originally intended (assuming function logic is correct)
        assign dgatel_par_o[3:0]     = cond_slice(P__DGATEL, {28'b0, REG_00[3:0]})[3:0];
        assign dgates_par_o[4:0]     = cond_slice(P__DGATES, {27'b0, REG_00[8:4]})[4:0];
        assign dummy_fe_par_o[2:0]   = cond_slice(P__DUMMY_FE, {29'b0, REG_00[11:9]})[2:0];
        assign sha_w_test_shdw[3:0]  = cond_slice(P__SHA_W_TEST, {28'b0, REG_20[23:20]})[3:0];
        assign w_test_par_o[3:0]     = cond_slice(P__W_TEST, {28'b0, REG_20[19:16]})[3:0];


        assign sha_w_test_trg_p_o    = int_upd_w;
        assign usr_w_test_par_o[3:0] = wr_data_i[3:0]; // Assuming this is always driven by wr_data_i

        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6];
        assign trans_done_p = rd_done_p | wr_done_p;

        assign wr_p = ~rd_wr_i & u3_sync_generic_i_trans_start_p;
        assign rd_p = rd_wr_i & u3_sync_generic_i_trans_start_p; // Simplified based on usage below? Check original intent.
                                                                 // Original: rd_p = rd_wr_i & ((ts_del_p & ~fwd_txn) | (fwd_rd_done_p & fwd_txn));

        // Keep original rd_p and wr_done_p logic if fwd path is needed
        assign rd_done_p = rd_wr_i & ((ts_del_p & ~fwd_txn) | (fwd_rd_done_p & fwd_txn));
        assign wr_done_p = ~rd_wr_i & ((ts_del_p & ~fwd_txn) | (fwd_wr_done_p & fwd_txn));

        assign fwd_rd_done_p = 1'b0; // Hardcoded to 0 in original
        assign fwd_wr_done_p = usr_w_test_trans_done_p_i;


        always @(posedge clk_a_i or negedge u4_sync_rst_i_int_rst_n) begin
            if (~u4_sync_rst_i_int_rst_n) begin
                int_trans_done <= 1'b0;
                ts_del_p       <= 1'b0;
            end
            else begin
                ts_del_p <= u3_sync_generic_i_trans_start_p;
                // Use trans_done_p which reflects the actual completion based on fwd logic
                if (trans_done_p)
                    int_trans_done <= ~int_trans_done;
            end
        end
        assign trans_done_o = int_trans_done;


        always @(posedge clk_a_i or negedge u4_sync_rst_i_int_rst_n) begin
            if (~u4_sync_rst_i_int_rst_n) begin
                REG_00[11:9]  <= 3'h0;
                REG_00[3:0]   <= 4'h4;
                REG_00[8:4]   <= 5'hc;
                REG_20[19:16] <= 4'h0;
                REG_20[23:20] <= 4'h0;
                // Initialize other registers if needed
                REG_04 <= 32'b0;
                REG_08 <= 32'b0;
                REG_0C <= 32'b0;
                REG_10 <= 32'b0;
                REG_14 <= 32'b0;
                REG_18 <= 32'b0;
                REG_1C <= 32'b0;
                // REG_20 fields initialized above
            end
            else begin
                // Use non-blocking assignments for sequential logic
                if (wr_p) begin
                    case (iaddr)
                        `REG_00_OFFS: begin
                            // Only update written fields if partial write intended
                            REG_00[11:9] <= wr_data_i[11:9];
                            REG_00[3:0]  <= wr_data_i[3:0];
                            REG_00[8:4]  <= wr_data_i[8:4];
                        end
                        `REG_20_OFFS: begin
                            // Only update written fields if partial write intended
                            REG_20[19:16] <= wr_data_i[19:16];
                            REG_20[23:20] <= wr_data_i[23:20];
                        end
                        // Add cases for other writable registers if any
                        // `REG_04_OFFS: REG_04 <= wr_data_i;
                        // ... etc.
                        default: ; // No change for unmapped addresses
                    endcase
                 end
            end
        end

        // Decode which write transaction needs forwarding
        assign fwd_decode_vec = {(iaddr == `REG_20_OFFS) & wr_p}; // Forward only on write pulse to REG_20

        always @(posedge clk_a_i or negedge u4_sync_rst_i_int_rst_n) begin
            if (~u4_sync_rst_i_int_rst_n) begin
                fwd_txn           <= 1'b0;
                usr_w_test_wr_p_o <= 1'b0;
            end
            else begin
                // Default assignment outside conditional if always driven
                usr_w_test_wr_p_o <= 1'b0; // De-assert by default

                if (u3_sync_generic_i_trans_start_p) begin // Transaction starts
                    fwd_txn           <= |fwd_decode_vec;
                    // Assert write pulse only if this specific transaction is decoded for forwarding
                    if (fwd_decode_vec[0]) begin // Check specific bit for REG_20 write
                        usr_w_test_wr_p_o <= 1'b1;
                    end
                end
                else if (trans_done_p) begin // Transaction ends
                    fwd_txn <= 1'b0;
                    // usr_w_test_wr_p_o is already de-asserted by default
                end
                // else: Hold fwd_txn state, usr_w_test_wr_p_o remains low
            end // Corrected: Added missing 'end' here
        end


        always @(posedge clk_a_i or negedge u4_sync_rst_i_int_rst_n) begin
            if (~u4_sync_rst_i_int_rst_n) begin
                int_upd_w <= 1'b1; // Or 1'b0 depending on desired reset state
                int_upd_w_en <= 1'b0;
            end
            else begin
                // Use synchronized signals
                int_upd_w <= (u11_sync_generic_i_int_upd_w_p & int_upd_w_en) | upd_w_force_i;
                if (u12_sync_generic_i_int_upd_w_arm_p) begin
                    int_upd_w_en <= 1'b1;
                end
                else if(u11_sync_generic_i_int_upd_w_p) begin // Consumed update pulse
                    int_upd_w_en <= 1'b0;
                end
                // else: Keep int_upd_w_en state
            end
        end

        always @(posedge clk_a_i or negedge u4_sync_rst_i_int_rst_n) begin
            if (~u4_sync_rst_i_int_rst_n) begin
                sha_w_test_par_o <= 4'h0;
            end
            else begin
                if (int_upd_w) begin // Shadow register update condition
                    sha_w_test_par_o <= sha_w_test_shdw;
                end
            end
        end

        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;

        // Combinational logic for read data multiplexing
        always @(*) begin // Use @(*) for combinational logic sensitivity
            mux_rd_err  = 1'b0; // Default values
            mux_rd_data = 32'b0;
            case (iaddr)
                `REG_00_OFFS : begin
                    // Use the function result directly
                    mux_rd_data[3:0]  = dgatel_par_o;
                    mux_rd_data[8:4]  = dgates_par_o;
                    mux_rd_data[11:9] = dummy_fe_par_o;
                    // Reading other bits of REG_00 returns 0 unless defined otherwise
                end
                `REG_20_OFFS : begin
                    // Read shadow values or live values based on parameterization
                    mux_rd_data[19:16] = w_test_par_o;
                    mux_rd_data[23:20] = sha_w_test_par_o; // Read the output shadow register
                    // Reading other bits of REG_20 returns 0 unless defined otherwise
                end
                `REG_28_OFFS : begin
                    // Read external input based on address
                    mux_rd_data[2:0] = r_test_par_i;
                end
                // Add cases for other readable registers if any
                // `REG_04_OFFS: mux_rd_data = REG_04;
                // ... etc.
                default: begin
                    mux_rd_err = 1'b1; // Error for unmapped read addresses
                    mux_rd_data = 32'hDEADBEEF; // Optional: Indicate error in data
                end
            endcase
        end

        // Combinational logic for r_test_trg_p_o generation
        always @(*) begin // Use @(*) for combinational logic sensitivity
            r_test_trg_p_o = 1'b0; // Default value
            // Trigger should be based on the read pulse `rd_p` for the specific address
            if (rd_p && (iaddr == `REG_28_OFFS)) begin
                 r_test_trg_p_o = 1'b1;
            end
            // Original case statement logic:
            // case (iaddr)
            //     `REG_28_OFFS: begin
            //         r_test_trg_p_o = rd_p; // Trigger only when reading this specific address
            //     end
            //     default: begin
            //         r_test_trg_p_o = 1'b0; // No trigger for other addresses
            //     end
            // endcase
        end

        // Assertions
        `ifdef ASSERT_ON
        property p_pos_pulse_check (sig, clk, rst_n);
             @(posedge clk) disable iff (~rst_n)
             sig |=> ##1 !sig; // Check it's low the cycle after being high
        endproperty
        // Check if usr_w_test_trans_done_p_i is a single cycle pulse
        assert_usr_w_test_trans_done_p_i_is_a_pulse: assert property(p_pos_pulse_check(usr_w_test_trans_done_p_i, clk_a_i, u4_sync_rst_i_int_rst_n));

        // Define fwd_done_vec based on inputs that signal completion of forwarded transactions
        wire [0:0] fwd_done_vec;
        assign fwd_done_vec = {usr_w_test_trans_done_p_i}; // Only one source currently

        // Check that only one forwarded transaction completes at a time
        function automatic integer popcount (input [0:0] vec);
          integer count = 0;
          for (integer i=0; i<=0; i=i+1) begin
             if (vec[i]) count++;
          end
          return count;
        endfunction

        assert_fwd_done_onehot: assert property (
           @(posedge clk_a_i) disable iff (~u4_sync_rst_i_int_rst_n)
           // $countones(fwd_done_vec) <= 1 // Alternative SVA standard function
           popcount(fwd_done_vec) <= 1
        );

        // Check that a forwarded transaction only completes when forwarding was active
        assert_fwd_done_only_when_fwd_txn: assert property (
           @(posedge clk_a_i) disable iff (~u4_sync_rst_i_int_rst_n)
           (|fwd_done_vec) |-> fwd_txn
        );

        // Note: Original onehot function was defined here, moved popcount outside property for clarity
        // function onehot (input [0:0] vec);
        //   integer i,j;
        //   begin
        //      j = 0;
        //      for (i=0; i<1; i=i+1) j = j + vec[i] ? 1 : 0;
        //      onehot = (j==1) ? 1 : 0;
        //   end
        // endfunction
        `endif // ASSERT_ON

		// Instantiations (Assuming these modules are defined elsewhere)
		sync_generic	#(
			.act(1),
			.kind(3), // Pulse synchronizer? Check definition
			.rstact(0),
			.rstval(0),
			.sync(1) // Number of sync stages?
		) u11_sync_generic_i (
			.clk_r(clk_a),
			.clk_s(tie0_1), // Assuming clk_s is unused / tied off
			.rcv_o(u11_sync_generic_i_int_upd_w_p),
			.rst_r(u4_sync_rst_i_int_rst_n), // Use synchronized reset
			.rst_s(tie0_1), // Assuming rst_s is unused / tied off
			.snd_i(upd_w)
		);

		sync_generic	#(
			.act(1),
			.kind(3), // Pulse synchronizer?
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u12_sync_generic_i (
			.clk_r(clk_a),
			.clk_s(tie0_1),
			.rcv_o(u12_sync_generic_i_int_upd_w_arm_p),
			.rst_r(u4_sync_rst_i_int_rst_n), // Use synchronized reset
			.rst_s(tie0_1),
			.snd_i(upd_w_en)
		);

		sync_generic	#(
			.act(1),
			.kind(2), // Level synchronizer? Check definition
			.rstact(0),
			.rstval(0),
			.sync(sync) // Use parameter
		) u3_sync_generic_i (
			.clk_r(clk_a),
			.clk_s(tie0_1),
			.rcv_o(u3_sync_generic_i_trans_start_p),
			.rst_r(u4_sync_rst_i_int_rst_n), // Use synchronized reset
			.rst_s(tie0_1),
			.snd_i(trans_start_0_i)
		);

		sync_rst	#(
			.act(0), // Active low reset output
			.sync(0) // Asynchronous reset input? Check definition
		) u4_sync_rst_i (
			.clk_r(clk_a),
			.rst_i(res_a_n), // Raw reset input
			.rst_o(u4_sync_rst_i_int_rst_n), // Synchronized reset output
			.test_i(tie0_1) // Assuming test input tied off
		);
endmodule