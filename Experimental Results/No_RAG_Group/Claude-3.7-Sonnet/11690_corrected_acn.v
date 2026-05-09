`timescale 1ns/10ps

module rs_cfg_fe1 (
    input wire clk_f20,
    input wire res_f20_n_i,
    input wire test_i,
    input wire [13:0] addr_i,
    input wire trans_start,
    input wire [31:0] wr_data_i,
    input wire rd_wr_i,
    input wire rst_n, // Added primary input reset
    output wire [31:0] rd_data_o,
    output wire rd_err_o,
    output wire trans_done_o,
    output wire Cvbsdetect_par_o,
    input wire Cvbsdetect_set_p_i,
    input wire ycdetect_par_i,
    input wire usr_r_test_par_i,
    input wire usr_r_test_trans_done_p_i,
    output reg usr_r_test_rd_p_o,
    input wire [7:0] sha_r_test_par_i,
    output wire [4:0] mvstart_par_o,
    output reg [5:0] mvstop_par_o,
    output wire [3:0] usr_rw_test_par_o,
    input wire [3:0] usr_rw_test_par_i,
    input wire usr_rw_test_trans_done_p_i,
    output reg usr_rw_test_rd_p_o,
    output reg usr_rw_test_wr_p_o,
    output reg [31:0] sha_rw2_par_o,
    output wire [15:0] wd_16_test_par_o,
    output wire [7:0] wd_16_test2_par_o,
    input wire upd_rw_en_i,
    input wire upd_rw_force_i,
    input wire upd_rw_i,
    input wire upd_r_en_i,
    input wire upd_r_force_i,
    input wire upd_r_i
);

// Rest of code remains the same until reset signal usage changes
// Replace all instances of u7_sync_rst_i_int_rst_n with rst_n
// For example:

always @(posedge clk_f20 or negedge rst_n) begin
    if (~rst_n) begin
        int_trans_done <= 0;
        wr_done_p <= 0;
        rd_done_p <= 0;
    end
    else begin
        // Rest of logic remains same
    end
end

// Continue with rest of module implementation with rst_n replacing u7_sync_rst_i_int_rst_n
// Remove u7_sync_rst_i instance since reset is now from primary input

endmodule

module ccgc(
    output clk_i,
    output clk_o, 
    output enable_i,
    output test_i
);
parameter cgtransp = 0;
endmodule

module sync_generic(
    output clk_r,
    input clk_s,
    output rcv_o,
    output rst_r,
    input rst_s, 
    output snd_i
);
parameter act = 0;
parameter kind = 0;
parameter rstact = 0;
parameter rstval = 0;
parameter sync = 0;
endmodule