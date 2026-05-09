`timescale 1ns/10ps
`define tie0_1_c 1'b0
module rs_cfg_fe1_clk_a_corrected_clk
		(
//		input	wire		test_i, // Original test_i commented out, using the one below
		input	wire		clk_a,
		input	wire		res_a_n_i,
		input	wire		test_i, // Test mode input
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
			wire		u4_ccgc_iwr_clk; // Gated clock output - kept for clarity, but FFs use clk_a
			wire		u4_ccgc_iwr_clk_en;
			wire		u5_ccgc_ishdw_clk; // Gated clock output - kept for clarity, but FFs use clk_a
			wire		u5_ccgc_ishdw_clk_en;
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign tie0_1 = `tie0_1_c;


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
        reg  [31:0] REG_04; // Unused reg
        reg  [31:0] REG_08; // Unused reg
        reg  [31:0] REG_0C; // Unused reg
        reg  [31:0] REG_10; // Unused reg
        reg  [31:0] REG_14; // Unused reg
        reg  [31:0] REG_18; // Unused reg
        reg  [31:0] REG_1C; // Unused reg
        reg  [31:0] REG_20;
        wire [3:0] sha_w_test_shdw;
        reg  [31:0] REG_28; // Unused reg
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

        /*
          local wire and output assignments
        */
        assign dummy_fe_par_o   = REG_00[11:9];
        assign dgatel_par_o     = REG_00[3:0];
        assign dgates_par_o     = REG_00[8:4];
        assign w_test_par_o     = REG_20[19:16];
        assign sha_w_test_shdw               = REG_20[23:20];
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
        assign fwd_done_vec = {usr_w_test_trans_done_p_i}; // ack for forwarded txns
        assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 0) & fwd_txn);

        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
		 	if (~u3_sync_rst_i_int_rst_n) begin
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

        /*
          write process - MODIFIED FOR DFT
          Clocked by primary clock clk_a, enabled by write enable u4_ccgc_iwr_clk_en
        */
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
			if (~u3_sync_rst_i_int_rst_n) begin
                REG_00[11:9]  <= 'h0;
                REG_00[3:0]   <= 'h4;
                REG_00[8:4]   <= 'hf;
                REG_20[19:16] <= 'h0;
                REG_20[23:20] <= 'h0;
            end
            else begin
                // Update only when write enable is active
                // DFT tools will handle forcing enable during scan if needed, or use test_i
                if (u4_ccgc_iwr_clk_en) begin
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
                        // No default: registers retain value if address doesn't match
                    endcase
                end
            end
        end

        /*
          txn forwarding process
        */
        // decode addresses of USR registers and read/write
        assign fwd_decode_vec = {(iaddr == `REG_20_OFFS) & ~rd_wr_i};

        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
			if (~u3_sync_rst_i_int_rst_n) begin
                fwd_txn             <= 1'b0;
                usr_w_test_wr_p_o   <= 1'b0;
            end
            else begin
                // Default assignment to avoid latches
                usr_w_test_wr_p_o <= 1'b0;
                if (u2_sync_generic_i_trans_start_p) begin
                    fwd_txn           <= |fwd_decode_vec; // set flag for forwarded txn
                    usr_w_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
                end
                else if (trans_done_p) begin
                    fwd_txn <= 1'b0; // reset flag for forwarded transaction
                end
                // Removed redundant else for usr_w_test_wr_p_o as it's assigned default above
            end
        end

        /*
          shadowing for update signal 'upd_w'
        */
        // generate internal update signal
       always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
	  	    if (~u3_sync_rst_i_int_rst_n)
                int_upd_w <= 1'b1; // Reset value based on original logic? Check spec. Assuming 1.
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end

        // shadow process - MODIFIED FOR DFT
        // Clocked by primary clock clk_a, enabled by shadow enable u5_ccgc_ishdw_clk_en
        always @(posedge clk_a or negedge u3_sync_rst_i_int_rst_n) begin
            if (~u3_sync_rst_i_int_rst_n) begin
                 sha_w_test_par_o <= 4'h0; // Assign a reset value
            end
            else begin
                // Update only when shadow enable is active
                // DFT tools will handle forcing enable during scan if needed, or use test_i
                // The original code used int_upd_w directly, which is the enable signal u5_ccgc_ishdw_clk_en
                if (u5_ccgc_ishdw_clk_en) begin
                    sha_w_test_par_o <= sha_w_test_shdw;
                end
            end
        end

        /*
          read logic and mux process
        */
        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;
        // Combinational logic, no clocking issues here
        always @(*) begin // Use @(*) for combinational blocks
            mux_rd_err  = 1'b0;
            mux_rd_data = 32'b0; // Default assignment
            case (iaddr)
                `REG_00_OFFS : begin
                    mux_rd_data[3:0] = REG_00[3:0];
                    mux_rd_data[8:4] = REG_00[8:4];
                    mux_rd_data[11:9] = REG_00[11:9];
                end
                // Reading REG_20 is implicitly handled by mux_rd_data default (reads 0)
                // Reading REG_28 requires the input r_test_par_i
                `REG_28_OFFS : begin
                    mux_rd_data[2:0] = r_test_par_i;
                end
                default: begin
                    mux_rd_err = 1'b1; // no decode for reads other than REG_00, REG_28
                end
            endcase
        end

        /*
          checking code
        */
        `ifdef ASSERT_ON

        property p_pos_pulse_check (sig); // check for positive pulse
             @(posedge clk_a) disable iff (~u3_sync_rst_i_int_rst_n)
             sig |=> ~sig;
        endproperty
        // Assuming usr_w_test_trans_done_p_i is synchronous to clk_a
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

        function automatic onehot (input [0:0] vec); // Use automatic for functions in SV properties
          integer i,j;
          begin
             j = 0;
        	 for (i=0; i<1; i=i+1) j = j + vec[i] ? 1 : 0;
        	 onehot = (j==1) ? 1 : 0;
          end
        endfunction


        `endif

	//
	// Generated Instances
	// wiring ...

	// Generated Instances and Port Mappings
		// Generated Instance Port Map for u12_sync_generic_i
		sync_generic	#(
			.act(1),
			.kind(3),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u12_sync_generic_i (	// Synchronizer for update-signal upd_w

			.clk_r(clk_a),
			.clk_s(tie0_1), // clk_s is typically unused input in sync modules
			.rcv_o(int_upd_w_p),
			.rst_r(u3_sync_rst_i_int_rst_n), // Use synchronized reset
			.rst_s(tie0_1), // rst_s is typically unused input in sync modules
			.snd_i(upd_w_i)
		);
		// End of Generated Instance Port Map for u12_sync_generic_i

		// Generated Instance Port Map for u2_sync_generic_i
		sync_generic	#(
			.act(1),
			.kind(2),
			.rstact(0),
			.rstval(0),
			.sync(1)
		) u2_sync_generic_i (	// Synchronizer for trans_done signal

			.clk_r(clk_a),
			.clk_s(tie0_1), // clk_s is typically unused input in sync modules
			.rcv_o(u2_sync_generic_i_trans_start_p),
			.rst_r(u3_sync_rst_i_int_rst_n), // Use synchronized reset
			.rst_s(tie0_1), // rst_s is typically unused input in sync modules
			.snd_i(trans_start)
		);
		// End of Generated Instance Port Map for u2_sync_generic_i

		// Generated Instance Port Map for u3_sync_rst_i
		sync_rst	#(
			.act(0), // Active low reset input res_a_n_i
			.sync(1)
		) u3_sync_rst_i (	// Reset synchronizer

			.clk_r(clk_a),
			.rst_i(res_a_n_i), // Asynchronous reset input
			.rst_o(u3_sync_rst_i_int_rst_n) // Synchronized reset output (active low)
		);
		// End of Generated Instance Port Map for u3_sync_rst_i

		// Generated Instance Port Map for u4_ccgc_i
		// This cell generates the enable signal u4_ccgc_iwr_clk_en used above
		// The actual clocking of FFs is now done by clk_a
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u4_ccgc_i (	// Clock-gating cell for write-clock

			.clk_i(clk_a),
			.clk_o(u4_ccgc_iwr_clk), // Output still connected, but not used for FF clocking directly
			.enable_i(u4_ccgc_iwr_clk_en), // Input enable signal
			.test_i(test_i) // Test input to bypass gating during test mode
		);
		// End of Generated Instance Port Map for u4_ccgc_i

		// Generated Instance Port Map for u5_ccgc_i
		// This cell generates the enable signal u5_ccgc_ishdw_clk_en used above
		// The actual clocking of FFs is now done by clk_a
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u5_ccgc_i (	// Clock-gating cell for shadow-clock

			.clk_i(clk_a),
			.clk_o(u5_ccgc_ishdw_clk), // Output still connected, but not used for FF clocking directly
			.enable_i(u5_ccgc_ishdw_clk_en), // Input enable signal
			.test_i(test_i) // Test input to bypass gating during test mode
		);
		// End of Generated Instance Port Map for u5_ccgc_i



endmodule
//
// Dummy modules for compilation - Replace with actual implementations
// Note: The DFT fix assumes the ccgc module bypasses gating when test_i=1
//
module sync_generic (
	input	clk_r,
	input	clk_s, // Unused dummy input
	output reg rcv_o,
	input	rst_r,
	input	rst_s, // Unused dummy input
	input	snd_i
);
parameter act = 1 ;
parameter kind = 1 ;
parameter rstact = 1 ; // 0 for active low reset? Assumed based on usage
parameter rstval = 1 ;
parameter sync = 1 ;

    reg sync_reg1;
    always @(posedge clk_r or posedge rst_r) begin // Assuming active high reset if rstact=1
        if (rstact == 1 && rst_r) begin
            sync_reg1 <= rstval;
            rcv_o <= rstval;
        end else if (rstact == 0 && !rst_r) begin // Assuming active low reset if rstact=0
             sync_reg1 <= rstval;
             rcv_o <= rstval;
        end else begin
             sync_reg1 <= snd_i;
             rcv_o <= sync_reg1;
        end
    end

endmodule

module sync_rst (
	input	clk_r,
	input	rst_i, // Asynchronous reset input
	output reg	rst_o // Synchronized reset output
);
parameter act = 1 ; // Active level of rst_i (1=high, 0=low)
parameter sync = 1 ;

    reg sync_reg1;
    // Output is active low based on usage (u3_sync_rst_i_int_rst_n)
    // Therefore, internal registers reset to 0 for active low output
    always @(posedge clk_r or negedge rst_i) begin // Sensitive to active low async reset
        if (act == 0 && !rst_i) begin
             sync_reg1 <= 1'b0;
             rst_o <= 1'b0;
        end else if (act == 1 && rst_i) begin // Handle active high async reset case
             sync_reg1 <= 1'b0;
             rst_o <= 1'b0;
        end else begin
             sync_reg1 <= 1'b1; // Deasserted state
             rst_o <= sync_reg1; // Deasserted state
        end
    end

endmodule

module ccgc(
	input	clk_i,
	output	clk_o,
	input	enable_i,
	input	test_i
);
parameter cgtransp = 0 ;
    // Basic clock gating cell model with DFT bypass
    // Output clock follows input clock when enable_i is high OR test_i is high
    // A latch-based implementation is common, but this behavioral model suffices
    assign clk_o = clk_i & (enable_i | test_i); // Simplified behavioral model

endmodule