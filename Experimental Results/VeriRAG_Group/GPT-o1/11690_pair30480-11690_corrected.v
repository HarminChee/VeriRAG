`timescale 1ns/10ps

module rs_cfg_fe1
(
  input  wire        sys_clk,
  input  wire        sys_rst,
  input  wire        clk_f20,
  input  wire        res_f20_n_i,
  input  wire        test_i,
  input  wire [13:0] addr_i,
  input  wire        trans_start,
  input  wire [31:0] wr_data_i,
  input  wire        rd_wr_i,
  output wire [31:0] rd_data_o,
  output wire        rd_err_o,
  output wire        trans_done_o,
  output wire        Cvbsdetect_par_o,
  input  wire        Cvbsdetect_set_p_i,
  input  wire        ycdetect_par_i,
  input  wire        usr_r_test_par_i,
  input  wire        usr_r_test_trans_done_p_i,
  output reg         usr_r_test_rd_p_o,
  input  wire [ 7:0] sha_r_test_par_i,
  output wire [ 4:0] mvstart_par_o,
  output reg  [ 5:0] mvstop_par_o,
  output wire [ 3:0] usr_rw_test_par_o,
  input  wire [ 3:0] usr_rw_test_par_i,
  input  wire        usr_rw_test_trans_done_p_i,
  output reg         usr_rw_test_rd_p_o,
  output reg         usr_rw_test_wr_p_o,
  output reg  [31:0] sha_rw2_par_o,
  output wire [15:0] wd_16_test_par_o,
  output wire [ 7:0] wd_16_test2_par_o,
  input  wire        upd_rw_en_i,
  input  wire        upd_rw_force_i,
  input  wire        upd_rw_i,
  input  wire        upd_r_en_i,
  input  wire        upd_r_force_i,
  input  wire        upd_r_i
);

`define tie0_1_c 1'b0

wire dft_clk_f20;
assign dft_clk_f20 = test_i ? sys_clk : clk_f20;

wire u8_ccgc_iwr_clk = dft_clk_f20;
wire u9_ccgc_ishdw_clk = dft_clk_f20;

wire tie0_1;
assign tie0_1 = `tie0_1_c;

wire int_upd_r_p;
wire int_upd_rw_p;
wire u6_sync_generic_i_trans_start_p;
wire u7_sync_rst_i_int_rst_n;

reg  int_trans_done;
reg  wr_done_p;
reg  rd_done_p;
reg  fwd_txn;
wire [1:0] fwd_decode_vec;
wire [1:0] fwd_done_vec;
wire trans_done_p;
wire addr_overshoot;
wire [ 3:0] iaddr;
reg  [31:0] mux_rd_data;
reg  mux_rd_err;

reg  [31:0] REG_04;
reg  [31:0] REG_0C;
reg  [31:0] REG_14;
reg  [31:0] REG_18;
reg  [31:0] REG_1C;
reg  [ 7:0] sha_r_test_shdw;
wire [ 5:0] mvstop_shdw;
wire [31:0] sha_rw2_shdw;

reg  int_upd_rw;
reg  int_upd_r;

wire wr_p;
wire rd_p;

assign Cvbsdetect_par_o   = REG_04[0];
assign mvstop_shdw        = REG_0C[10:5];
assign mvstart_par_o      = REG_0C[4:0];
assign sha_rw2_shdw       = REG_14;
assign wd_16_test_par_o   = REG_18[15:0];
assign wd_16_test2_par_o  = REG_1C[7:0];
assign usr_rw_test_par_o  = wr_data_i[14:11];
assign iaddr              = addr_i[5:2];
assign addr_overshoot     = |addr_i[13:6];
assign wr_p               = ~rd_wr_i & u6_sync_generic_i_trans_start_p;
assign rd_p               = rd_wr_i & u6_sync_generic_i_trans_start_p;
assign fwd_decode_vec     = {(iaddr == 2'h2) & rd_wr_i, (iaddr == 4'h4)};
assign fwd_done_vec       = {usr_r_test_trans_done_p_i, usr_rw_test_trans_done_p_i};
assign trans_done_p       = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 0) & fwd_txn);

always @(posedge dft_clk_f20 or negedge u7_sync_rst_i_int_rst_n) begin
  if (~u7_sync_rst_i_int_rst_n) begin
    int_trans_done <= 1'b0;
    wr_done_p <= 1'b0;
    rd_done_p <= 1'b0;
  end else begin
    wr_done_p <= wr_p;
    rd_done_p <= rd_p;
    if (trans_done_p)
      int_trans_done <= ~int_trans_done;
  end
end

assign trans_done_o = int_trans_done;

always @(posedge u8_ccgc_iwr_clk or negedge u7_sync_rst_i_int_rst_n) begin
  if (~u7_sync_rst_i_int_rst_n) begin
    REG_0C[10:5] <= 6'h0c;
    REG_0C[4:0]  <= 5'h07;
    REG_14       <= 32'h0;
    REG_18[15:0] <= 16'ha;
    REG_1C[7:0]  <= 8'hff;
  end else begin
    case (iaddr)
      3'h3: begin
        REG_0C[10:5] <= wr_data_i[10:5];
        REG_0C[4:0]  <= wr_data_i[4:0];
      end
      3'h5: begin
        REG_14 <= wr_data_i;
      end
      3'h6: begin
        REG_18[15:0] <= wr_data_i[15:0];
      end
      3'h7: begin
        REG_1C[7:0] <= wr_data_i[7:0];
      end
    endcase
  end
end

always @(posedge dft_clk_f20 or negedge u7_sync_rst_i_int_rst_n) begin
  if (~u7_sync_rst_i_int_rst_n) begin
    REG_04[0] <= 1'b0;
  end else begin
    if (Cvbsdetect_set_p_i)
      REG_04[0] <= 1'b1;
    else if (wr_p && iaddr == 3'h1)
      REG_04[0] <= REG_04[0] & ~wr_data_i[0];
  end
end

always @(posedge dft_clk_f20 or negedge u7_sync_rst_i_int_rst_n) begin
  if (~u7_sync_rst_i_int_rst_n) begin
    fwd_txn            <= 1'b0;
    usr_r_test_rd_p_o  <= 1'b0;
    usr_rw_test_rd_p_o <= 1'b0;
    usr_rw_test_wr_p_o <= 1'b0;
  end else begin
    usr_r_test_rd_p_o  <= 1'b0;
    usr_rw_test_rd_p_o <= 1'b0;
    usr_rw_test_wr_p_o <= 1'b0;
    if (u6_sync_generic_i_trans_start_p) begin
      fwd_txn            <= |fwd_decode_vec;
      usr_r_test_rd_p_o  <= fwd_decode_vec[1] & rd_wr_i;
      usr_rw_test_rd_p_o <= fwd_decode_vec[0] & rd_wr_i;
      usr_rw_test_wr_p_o <= fwd_decode_vec[0] & ~rd_wr_i;
    end else if (trans_done_p)
      fwd_txn <= 1'b0;
  end
end

always @(posedge dft_clk_f20 or negedge u7_sync_rst_i_int_rst_n) begin
  if (~u7_sync_rst_i_int_rst_n)
    int_upd_rw <= 1'b1;
  else
    int_upd_rw <= (int_upd_rw_p & upd_rw_en_i) | upd_rw_force_i;
end

always @(posedge u9_ccgc_ishdw_clk) begin
  if (int_upd_rw) begin
    mvstop_par_o  <= mvstop_shdw;
    sha_rw2_par_o <= sha_rw2_shdw;
  end
end

always @(posedge dft_clk_f20 or negedge u7_sync_rst_i_int_rst_n) begin
  if (~u7_sync_rst_i_int_rst_n)
    int_upd_r <= 1'b1;
  else
    int_upd_r <= (int_upd_r_p & upd_r_en_i) | upd_r_force_i;
end

always @(posedge u9_ccgc_ishdw_clk) begin
  if (int_upd_r)
    sha_r_test_shdw <= sha_r_test_par_i;
end

assign rd_data_o = mux_rd_data;
assign rd_err_o  = mux_rd_err | addr_overshoot;

always @(*) begin
  mux_rd_err  = 1'b0;
  mux_rd_data = 32'h0;
  case (iaddr)
    3'h1: begin
      mux_rd_data[0] = REG_04[0];
    end
    3'h2: begin
      mux_rd_data[1]      = ycdetect_par_i;
      mux_rd_data[2]      = usr_r_test_par_i;
      mux_rd_data[10:3]   = sha_r_test_shdw;
    end
    3'h3: begin
      mux_rd_data[4:0]    = REG_0C[4:0];
      mux_rd_data[10:5]   = mvstop_shdw;
    end
    3'h4: begin
      mux_rd_data[14:11]  = usr_rw_test_par_i;
    end
    3'h5: begin
      mux_rd_data         = sha_rw2_shdw;
    end
    3'h6: begin
      mux_rd_data[15:0]   = REG_18[15:0];
    end
    default: begin
      mux_rd_err = 1'b1;
    end
  endcase
end

sync_generic #(
  .act(1),
  .kind(3),
  .rstact(0),
  .rstval(0),
  .sync(1)
) u10_sync_generic_i (
  .clk_r(dft_clk_f20),
  .clk_s(tie0_1),
  .rcv_o(int_upd_rw_p),
  .rst_r(res_f20_n_i),
  .rst_s(tie0_1),
  .snd_i(upd_rw_i)
);

sync_generic #(
  .act(1),
  .kind(3),
  .rstact(0),
  .rstval(0),
  .sync(1)
) u11_sync_generic_i (
  .clk_r(dft_clk_f20),
  .clk_s(tie0_1),
  .rcv_o(int_upd_r_p),
  .rst_r(res_f20_n_i),
  .rst_s(tie0_1),
  .snd_i(upd_r_i)
);

sync_generic #(
  .act(1),
  .kind(2),
  .rstact(0),
  .rstval(0),
  .sync(0)
) u6_sync_generic_i (
  .clk_r(dft_clk_f20),
  .clk_s(tie0_1),
  .rcv_o(u6_sync_generic_i_trans_start_p),
  .rst_r(res_f20_n_i),
  .rst_s(tie0_1),
  .snd_i(trans_start)
);

sync_rst #(
  .act(0),
  .sync(0)
) u7_sync_rst_i (
  .clk_r(dft_clk_f20),
  .rst_i(res_f20_n_i),
  .rst_o(u7_sync_rst_i_int_rst_n)
);

endmodule

module ccgc(
  output clk_i,
  output clk_o,
  output enable_i,
  output test_i
);
parameter cgtransp = 0;
endmodule

module sync_rst (
  input  clk_r,
  output rst_i,
  output rst_o
);
parameter act  = 0;
parameter sync = 0;
endmodule

module sync_generic(
  output clk_r,
  input  clk_s,
  output rcv_o,
  output rst_r,
  input  rst_s,
  output snd_i
);
parameter act    = 0;
parameter kind   = 0;
parameter rstact = 0;
parameter rstval = 0;
parameter sync   = 0;
endmodule