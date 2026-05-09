`timescale 1ns/10ps
`define tie0_1_c 1'b0
module rs_cfg_fe1_clk_a
		(
//		input	wire		test_i,
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
			wire		dft_clk_wr;
			wire		dft_clk_shdw;
		//
		// End of Generated Signal List
		//


	// %COMPILER_OPTS%

	// Generated Signal Assignments
			assign tie0_1 = `tie0_1_c;
			assign dft_clk_wr = test_i ? clk_a : u4_ccgc_iwr_clk;
			assign dft_clk_shdw = test_i ? clk_a : u5_ccgc_ishdw_clk;


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

        always @(posedge clk_a or negedge res_a_n_i) begin
        //always @(posedge clk_a ) begin
		 	if (~res_a_n_i) begin
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
          write process
        */
        always @(posedge dft_clk_wr or negedge res_a_n_i) begin
		//always @(posedge u4_ccgc_iwr_clk ) begin
			if (~res_a_n_i) begin
                REG_00[11:9]  <= 'h0;
                REG_00[3:0]   <= 'h4;
                REG_00[8:4]   <= 'hf;
                REG_20[19:16] <= 'h0;
                REG_20[23:20] <= 'h0;
            end
            else if (u4_ccgc_iwr_clk_en) begin // Add clock enable check
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
                    default: begin // Avoid latch generation
                        REG_00[11:9]  <= REG_00[11:9];
                        REG_00[3:0]   <= REG_00[3:0];
                        REG_00[8:4]   <= REG_00[8:4];
                        REG_20[19:16] <= REG_20[19:16];
                        REG_20[23:20] <= REG_20[23:20];
                    end
                endcase
            end
        end

        /*
          txn forwarding process
        */
        // decode addresses of USR registers and read/write
        assign fwd_decode_vec = {(iaddr == `REG_20_OFFS) & ~rd_wr_i};

        always @(posedge clk_a or negedge res_a_n_i) begin
		//always @(posedge clk_a ) begin
			if (~res_a_n_i) begin
                fwd_txn                           <= 1'b0;
                usr_w_test_wr_p_o <= 1'b0;
            end
            else begin
                // Default assignments to avoid latches
                fwd_txn <= fwd_txn;
                usr_w_test_wr_p_o <= 1'b0;

                if (u2_sync_generic_i_trans_start_p) begin
                    fwd_txn                           <= |fwd_decode_vec; // set flag for forwarded txn
                    usr_w_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
                end
                else if (trans_done_p) begin
                    fwd_txn <= 1'b0; // reset flag for forwarded transaction
                end
            end
        end // Added missing 'end'

        /*
          shadowing for update signal 'upd_w'
        */
        // generate internal update signal

		//reg u3_reg1;
		//always @(posedge clk_a) begin

       always @(posedge clk_a or negedge res_a_n_i) begin
      	//always @(posedge clk_a) begin
	  	    if (~res_a_n_i)
                int_upd_w <= 1'b1; // Use 'b1 for clarity
            else
                int_upd_w <= (int_upd_w_p & upd_w_en_i) | upd_w_force_i;
        end
        // shadow process
        always @(posedge dft_clk_shdw or negedge res_a_n_i) begin // Added async reset
            if (~res_a_n_i) begin
                 sha_w_test_par_o <= 4'b0; // Reset shadow register
            end else if (u5_ccgc_ishdw_clk_en) begin // Add clock enable check
                sha_w_test_par_o <= sha_w_test_shdw;
            end
        end

        /*
          read logic and mux process
        */
        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;
        always @(*) begin // Use @(*) for combinational logic
            mux_rd_err  = 1'b0;
            mux_rd_data = 32'b0; // Default assignment
            case (iaddr)
                `REG_00_OFFS : begin
                    mux_rd_data[3:0] = REG_00[3:0];
                    mux_rd_data[8:4] = REG_00[8:4];
                    mux_rd_data[11:9] = REG_00[11:9];
                end
                `REG_28_OFFS : begin
                    mux_rd_data[2:0] = r_test_par_i;
                end
                default: begin
                    mux_rd_err = 1'b1; // no decode
                end
            endcase
        end

        /*
          checking code
        */
        `ifdef ASSERT_ON

        property p_pos_pulse_check (sig); // check for positive pulse
             @(posedge clk_a) disable iff (~res_a_n_i)
             sig |=> ~sig;
        endproperty
        // assert property(p_pos_pulse_check(usr_w_test_trans_done_p_i)); // Assertion commented out as per original

        p_fwd_done_expected: assert property
        (
           @(posedge clk_a) disable iff (~res_a_n_i)
           usr_w_test_trans_done_p_i |-> fwd_txn
        );

        p_fwd_done_onehot: assert property
        (
           @(posedge clk_a) disable iff (~res_a_n_i)
           usr_w_test_trans_done_p_i |-> onehot(fwd_done_vec)
        );

        p_fwd_done_only_when_fwd_txn: assert property
        (
           @(posedge clk_a) disable iff (~res_a_n_i)
           fwd_done_vec != 0 |-> fwd_txn
        );

        function automatic onehot (input [0:0] vec); // not built-in to SV yet
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
			.clk_s(tie0_1), // Assuming clk_s is an input connected to tie0
			.rcv_o(int_upd_w_p),
			.rst_r(res_a_n_i), // Assuming rst_r is the async reset input
			.rst_s(tie0_1), // Assuming rst_s is an input connected to tie0
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
			.clk_s(tie0_1), // Assuming clk_s is an input connected to tie0
			.rcv_o(u2_sync_generic_i_trans_start_p),
			.rst_r(res_a_n_i), // Assuming rst_r is the async reset input
			.rst_s(tie0_1), // Assuming rst_s is an input connected to tie0
			.snd_i(trans_start)
		);
		// End of Generated Instance Port Map for u2_sync_generic_i

		// Generated Instance Port Map for u3_sync_rst_i
		sync_rst	#(
			.act(0),
			.sync(1)
		) u3_sync_rst_i (	// Reset synchronizer

			.clk_r(clk_a),
			.rst_i(res_a_n_i),
			.rst_o(u3_sync_rst_i_int_rst_n) // This output is unused in the design
		);
		// End of Generated Instance Port Map for u3_sync_rst_i

		// Generated Instance Port Map for u4_ccgc_i
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u4_ccgc_i (	// Clock-gating cell for write-clock

			.clk_i(clk_a),
			.clk_o(u4_ccgc_iwr_clk),
			.enable_i(u4_ccgc_iwr_clk_en),
			.test_i(test_i)
		);
		// End of Generated Instance Port Map for u4_ccgc_i

		// Generated Instance Port Map for u5_ccgc_i
		ccgc	#(
			.cgtransp(cgtransp) // __W_ILLEGAL_PARAM
		) u5_ccgc_i (	// Clock-gating cell for shadow-clock

			.clk_i(clk_a),
			.clk_o(u5_ccgc_ishdw_clk),
			.enable_i(u5_ccgc_ishdw_clk_en),
			.test_i(test_i)
		);
		// End of Generated Instance Port Map for u5_ccgc_i



endmodule
//
// Corrected Stub Modules
//
module sync_generic (
	input  wire clk_r,
	input  wire clk_s, // Added input definition
	output wire rcv_o,
	input  wire rst_r,
	input  wire rst_s, // Added input definition
	input  wire snd_i
);
parameter act = 1 ;
parameter kind = 1 ;
parameter rstact = 1 ;
parameter rstval = 1 ;
parameter sync = 1 ;
// Dummy body for elaboration - actual implementation needed
reg rcv_o_reg;
always @(posedge clk_r or negedge rst_r) begin
    if (!rst_r)
        rcv_o_reg <= rstval;
    else
        rcv_o_reg <= snd_i; // Simplified logic for elaboration
end
assign rcv_o = rcv_o_reg;
endmodule

module sync_rst (
	input  wire clk_r,
	input  wire rst_i,
	output wire rst_o
);
parameter act = 1 ;
parameter sync = 1 ;
// Dummy body for elaboration - actual implementation needed
reg rst_s1, rst_s2;
always @(posedge clk_r or posedge rst_i) begin // Use appropriate polarity based on 'act'
    if (rst_i == act) begin
        rst_s1 <= 1'b1;
        rst_s2 <= 1'b1;
    end else begin
        rst_s1 <= 1'b0;
        rst_s2 <= rst_s1;
    end
end
assign rst_o = rst_s2;
endmodule

module ccgc(
	input  wire clk_i,
	output wire clk_o,
	input  wire enable_i,
	input  wire test_i
);
parameter cgtransp = 0 ;
// Dummy body for elaboration - actual implementation needed
reg q;
wire gated_enable;
assign gated_enable = enable_i | test_i; // Test signal bypasses enable latch
always @(posedge clk_i) begin // Latch enable on positive edge
    if (cgtransp == 0) // Assuming cgtransp=0 means latch based
      q <= gated_enable;
    else // Transparent latch (approximation)
      q = gated_enable;
end
assign clk_o = clk_i & q; // Simple AND gate for clock gating
endmodule