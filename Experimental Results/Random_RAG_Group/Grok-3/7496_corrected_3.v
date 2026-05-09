`timescale 1ns/10ps
`define tie0_1_c 1'b0  
module rs_cfg_fe1_clk_a
    (
        input  wire        test_i,
        input  wire        clk_a_i,
        input  wire        res_a_n_i,
        input  wire [13:0] addr_i,
        input  wire [31:0] wr_data_i,
        input  wire        rd_wr_i,
        input  wire        trans_start_0_i,
        output wire [31:0] rd_data_o,
        output wire        rd_err_o,
        output wire        trans_done_o,
        output wire [3:0]  dgatel_par_o,
        output wire [4:0]  dgates_par_o,
        output wire [2:0]  dummy_fe_par_o,
        output reg  [3:0]  sha_w_test_par_o,
        output wire        sha_w_test_trg_p_o,
        output wire [3:0]  usr_w_test_par_o,
        input  wire        usr_w_test_trans_done_p_i,
        output reg         usr_w_test_wr_p_o,
        output wire [3:0]  w_test_par_o,
        input  wire [2:0]  r_test_par_i,
        output reg         r_test_trg_p_o,
        input  wire        upd_w_en_i,
        input  wire        upd_w_force_i,
        input  wire        upd_w_i
    );
        parameter sync = 1;
        parameter P__SHA_W_TEST = -1;
        parameter P__W_TEST = -1;
        parameter P__DUMMY_FE = -1;
        parameter P__DGATES = -1;
        parameter P__DGATEL = -1;
        wire        clk_a; 
        wire        res_a_n; 
        wire        tie0_1; 
        wire        u11_sync_generic_i_int_upd_w_p; 
        wire        u12_sync_generic_i_int_upd_w_arm_p; 
        wire        u3_sync_generic_i_trans_start_p; 
        wire        u4_sync_rst_i_int_rst_n; 
        wire        upd_w; 
        wire        upd_w_en; 
        wire        dft_clk_a;
        wire        dft_res_a_n;
        assign    clk_a    = clk_a_i;  
        assign    res_a_n    = res_a_n_i;  
        assign    tie0_1    = `tie0_1_c;
        assign    upd_w    = upd_w_i;  
        assign    upd_w_en    = upd_w_en_i;  
        assign    dft_clk_a = test_i ? clk_a_i : clk_a;
        assign    dft_res_a_n = test_i ? res_a_n_i : res_a_n;
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
        assign dgatel_par_o[3:0]     = cond_slice(P__DGATEL, REG_00[3:0]);
        assign dgates_par_o[4:0]     = cond_slice(P__DGATES, REG_00[8:4]);
        assign dummy_fe_par_o[2:0]   = cond_slice(P__DUMMY_FE, REG_00[11:9]);
        assign sha_w_test_shdw[3:0]  = cond_slice(P__SHA_W_TEST, REG_20[23:20]);
        assign w_test_par_o[3:0]     = cond_slice(P__W_TEST, REG_20[19:16]);
        assign sha_w_test_trg_p_o    = int_upd_w;
        assign usr_w_test_par_o[3:0] = wr_data_i[3:0];
        assign iaddr = addr_i[5:2];
        assign addr_overshoot = |addr_i[13:6];
        assign trans_done_p = rd_done_p | wr_done_p;
        assign
        #0.1
        wr_p = ~rd_wr_i & u3_sync_generic_i_trans_start_p;
        assign rd_done_p = rd_p;
        assign fwd_rd_done_p = 1'b0;
        assign fwd_wr_done_p = usr_w_test_trans_done_p_i;
        assign rd_p = rd_wr_i & ((ts_del_p & ~fwd_txn) | (fwd_rd_done_p & fwd_txn)); 
        assign wr_done_p = ~rd_wr_i & ((ts_del_p & ~fwd_txn) | (fwd_wr_done_p & fwd_txn)); 
        always @(posedge dft_clk_a or negedge dft_res_a_n) begin
            if (~dft_res_a_n) begin
                int_trans_done <= 1'b0;
                ts_del_p       <= 1'b0;
            end
            else begin
                ts_del_p <= u3_sync_generic_i_trans_start_p;
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
        always @(posedge dft_clk_a or negedge dft_res_a_n) begin
            if (~dft_res_a_n) begin
                REG_00[11:9]  <= 3'h0;
                REG_00[3:0]   <= 4'h4;
                REG_00[8:4]   <= 5'hc;
                REG_20[19:16] <= 4'h0;
                REG_20[23:20] <= 4'h0;
            end
            else begin
                if (wr_p)
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
                        default: ;
                    endcase
            end
        end
        assign fwd_decode_vec = {(iaddr == `REG_20_OFFS) & ~rd_wr_i};
        always @(posedge dft_clk_a or negedge dft_res_a_n) begin
            if (~dft_res_a_n) begin
                fwd_txn            <= 1'b0;
                usr_w_test_wr_p_o  <= 1'b0;
            end
            else begin
                usr_w_test_wr_p_o <= 1'b0;
                if (u3_sync_generic_i_trans_start_p) begin
                    fwd_txn           <= |fwd_decode_vec; 
                    usr_w_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
                end
                else if (trans_done_p)
                    fwd_txn <= 1'b0; 
            end
        end
        always @(posedge dft_clk_a or negedge dft_res_a_n) begin
            if (~dft_res_a_n) begin
                int_upd_w    <= 1'b1;
                int_upd_w_en <= 1'b0;
            end
            else begin
                int_upd_w <= (u11_sync_generic_i_int_upd_w_p & int_upd_w_en) | upd_w_force_i;
                if (u12_sync_generic_i_int_upd_w_arm_p)
                    int_upd_w_en <= 1'b1; 
                else if(u11_sync_generic_i_int_upd_w_p)
                    int_upd_w_en <= 1'b0; 
            end
        end
        always @(posedge dft_clk_a or negedge dft_res_a_n) begin
            if (~dft_res_a_n) begin
                sha_w_test_par_o <= 4'h0;
            end
            else begin
                if (int_upd_w) begin
                    sha_w_test_par_o <= sha_w_test_shdw;
                end
            end
        end
        assign rd_data_o = mux_rd_data;
        assign rd_err_o = mux_rd_err | addr_overshoot;
        always @(*) begin
            mux_rd_err  <= 1'b0;
            mux_rd_data <= 32'b0;
            case (iaddr)
                `REG_00_OFFS : begin
                    mux_rd_data[3:0]  <= cond_slice(P__DGATEL, REG_00[3:0]);
                    mux_rd_data[8:4]  <= cond_slice(P__DGATES, REG_00[8:4]);
                    mux_rd_data[11:9] <= cond_slice(P__DUMMY_FE, REG_00[11:9]);
                end
                `REG_28_OFFS : begin
                    mux_rd_data[2:0] <= r_test_par_i;
                end
                default: begin
                    mux_rd_err <= 1'b1; 
                end
            endcase
        end
        always @(*) begin
            r_test_trg_p_o = 1'b0;
            case (iaddr)
                `REG_28_OFFS: begin
                    r_test_trg_p_o = rd_p;
                end
                default: begin
                    r_test_trg_p_o = 1'b0;
                end
            endcase
        end
        `ifdef ASSERT_ON
        property p_pos_pulse_check (sig); 
             @(posedge dft_clk_a) disable iff (~dft_res_a_n)
             sig |=> ~sig;
        endproperty
        assert_usr_w_test_trans_done_p_i_is_a_pulse: assert property(p_pos_pulse_check(usr_w_test_trans_done_p_i));
        wire [0:0] fwd_done_vec;
        assign fwd_done_vec = {usr_w_test_trans_done_p_i};
        assert_fwd_done_onehot: assert property
        (
           @(posedge dft_clk_a) disable iff (~dft_res_a_n)
           fwd_done_vec != 1'b0 |-> $onehot(fwd_done_vec)
        );
        assert_fwd_done_only_when_fwd_txn: assert property
        (
           @(posedge dft_clk_a) disable iff (~dft_res_a_n)
           fwd_done_vec != 1'b0 |-> fwd_txn
        );
        `endif
        sync_generic    #(
            .act(1),
            .kind(3),
            .rstact(0),
            .rstval(0),
            .sync(1)
        ) u11_sync_generic_i (    
            .clk_r(dft_clk_a),
            .clk_s(tie0_1),
            .rcv_o(u11_sync_generic_i_int_upd_w_p),
            .rst_r(dft_res_a_n),
            .rst_s(tie0_1),
            .snd_i(upd_w)
        );
        sync_generic    #(
            .act(1),
            .kind(3),
            .rstact(0),
            .rstval(0),
            .sync(1)
        ) u12_sync_generic_i (    
            .clk_r(dft_clk_a),
            .clk_s(tie0_1),
            .rcv_o(u12_sync_generic_i_int_upd_w_arm_p),
            .rst_r(dft_res_a_n),
            .rst_s(tie0_1),
            .snd_i(upd_w_en)
        );
        sync_generic    #(
            .act(1),
            .kind(2),
            .rstact(0),
            .rstval(0),
            .sync(sync)
        ) u3_sync_generic_i (    
            .clk_r(dft_clk_a),
            .clk_s(tie0_1),
            .rcv_o(u3_sync_generic_i_trans_start_p),
            .rst_r(dft_res_a_n),
            .rst_s(tie0_1),
            .snd_i(trans_start_0_i)    
        );
        sync_rst    #(
            .act(0),
            .sync(0)
        ) u4_sync_rst_i (    
            .clk_r(dft_clk_a),
            .rst_i(dft_res_a_n),
            .rst_o(u4_sync_rst_i_int_rst_n),
            .test_i(tie0_1)
        );
endmodule