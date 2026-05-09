`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module arb_row_col #
  (
   parameter TCQ = 100,
   parameter ADDR_CMD_MODE            = "1T",
   parameter EARLY_WR_DATA_ADDR       = "OFF",
   parameter nBANK_MACHS              = 4,
   parameter nCK_PER_CLK              = 2,
   parameter nCNFG2WR                 = 2
  )
  (
  grant_row_r, sent_row, sending_row, grant_config_r,
  io_config_strobe, force_io_config_rd_r1, io_config_valid_r,
  grant_col_r, sending_col, sent_col, grant_col_wr, send_cmd0_col,
  send_cmd1_row, cs_en0, cs_en1, insert_maint_r1,
  clk, rst, rts_row, insert_maint_r, rts_col, rtc,
  force_io_config_rd_r, col_rdy_wr
  );
  input clk;
  input rst;
  input [nBANK_MACHS-1:0] rts_row;
  input insert_maint_r;
  input [nBANK_MACHS-1:0] rts_col;
  reg io_config_strobe_r;
  wire block_grant_row;
  wire block_grant_col;
  wire io_config_kill_rts_col = (nCNFG2WR == 1) ? 1'b0 : io_config_strobe_r;
  wire [nBANK_MACHS-1:0] col_request;
  wire granted_col_ns = |col_request;
  wire [nBANK_MACHS-1:0] row_request =
                          rts_row & {nBANK_MACHS{~insert_maint_r}};
  wire granted_row_ns = |row_request;
  generate
    if (ADDR_CMD_MODE == "2T") begin : row_col_2T_arb
      assign col_request =
          rts_col & {nBANK_MACHS{~(io_config_kill_rts_col || insert_maint_r)}};
      wire [1:0] row_col_grant;
      wire [1:0] current_master = ~granted_row_ns ? 2'b10 : row_col_grant;
      wire upd_last_master = ~granted_row_ns || |row_col_grant;
      round_robin_arb #
        (.WIDTH                       (2))
        row_col_arb0
          (.grant_ns                  (),
           .grant_r                   (row_col_grant),
           .upd_last_master           (upd_last_master),
           .current_master            (current_master),
           .clk                       (clk),
           .rst                       (rst),
           .req                       ({granted_row_ns, granted_col_ns}),
           .disable_grant             (1'b0));
      assign {block_grant_col, block_grant_row} = row_col_grant;
    end
    else begin : row_col_1T_arb
      assign col_request = rts_col & {nBANK_MACHS{~io_config_kill_rts_col}};
      assign block_grant_row = 1'b0;
      assign block_grant_col = 1'b0;
    end
  endgenerate
  wire[nBANK_MACHS-1:0] grant_row_r_lcl;
  output wire[nBANK_MACHS-1:0] grant_row_r;
  assign grant_row_r = grant_row_r_lcl;
  reg granted_row_r;
  always @(posedge clk) granted_row_r <= #TCQ granted_row_ns;
  wire sent_row_lcl = granted_row_r && ~block_grant_row;
  output wire sent_row;
  assign sent_row = sent_row_lcl;
  round_robin_arb #
   (.WIDTH                              (nBANK_MACHS))
    row_arb0
    (.grant_ns                          (),
     .grant_r                           (grant_row_r_lcl[nBANK_MACHS-1:0]),
     .upd_last_master                   (sent_row_lcl),
     .current_master                    (grant_row_r_lcl[nBANK_MACHS-1:0]),
     .clk                               (clk),
     .rst                               (rst),
     .req                               (row_request),
     .disable_grant                     (1'b0));
  output wire [nBANK_MACHS-1:0] sending_row;
  assign sending_row = grant_row_r_lcl & {nBANK_MACHS{~block_grant_row}};
`ifdef MC_SVA
  all_bank_machines_row_arb:
    cover property (@(posedge clk) (~rst && &rts_row));
`endif
  input [nBANK_MACHS-1:0] rtc;
  wire [nBANK_MACHS-1:0] grant_config_r_lcl;
  output wire [nBANK_MACHS-1:0] grant_config_r;
  assign grant_config_r = grant_config_r_lcl;
  wire upd_io_config_last_master;
  round_robin_arb #
   (.WIDTH                              (nBANK_MACHS))
    config_arb0
    (.grant_ns                          (),
     .grant_r                           (grant_config_r_lcl[nBANK_MACHS-1:0]),
     .upd_last_master                   (upd_io_config_last_master),
     .current_master                    (grant_config_r_lcl[nBANK_MACHS-1:0]),
     .clk                               (clk),
     .rst                               (rst),
     .req                               (rtc[nBANK_MACHS-1:0]),
     .disable_grant                     (1'b0));
`ifdef MC_SVA
  all_bank_machines_config_arb: cover property (@(posedge clk) (~rst && &rtc));
`endif
  input force_io_config_rd_r;
  wire io_config_strobe_ns =
    ~io_config_strobe_r && (|rtc || force_io_config_rd_r) && ~granted_col_ns;
  always @(posedge clk) io_config_strobe_r <= #TCQ io_config_strobe_ns;
  output wire io_config_strobe;
  assign io_config_strobe = io_config_strobe_r;
  reg force_io_config_rd_r1_lcl;
  always @(posedge clk) force_io_config_rd_r1_lcl <= 
                          #TCQ force_io_config_rd_r;
  output wire force_io_config_rd_r1;
  assign force_io_config_rd_r1 = force_io_config_rd_r1_lcl;
  assign upd_io_config_last_master =
          io_config_strobe_r && ~force_io_config_rd_r1_lcl;
  reg io_config_valid_r_lcl;
  wire io_config_valid_ns;
  assign io_config_valid_ns =
          ~rst && (io_config_valid_r_lcl || io_config_strobe_ns);
  always @(posedge clk) io_config_valid_r_lcl <= #TCQ io_config_valid_ns;
  output wire io_config_valid_r;
  assign io_config_valid_r = io_config_valid_r_lcl;
  wire [nBANK_MACHS-1:0] grant_col_r_lcl;
  output wire [nBANK_MACHS-1:0] grant_col_r;
  assign grant_col_r = grant_col_r_lcl;
  reg granted_col_r;
  always @(posedge clk) granted_col_r <= #TCQ granted_col_ns;
  wire sent_col_lcl;
  round_robin_arb #
   (.WIDTH                              (nBANK_MACHS))
    col_arb0
    (.grant_ns                          (),
     .grant_r                           (grant_col_r_lcl[nBANK_MACHS-1:0]),
     .upd_last_master                   (sent_col_lcl),
     .current_master                    (grant_col_r_lcl[nBANK_MACHS-1:0]),
     .clk                               (clk),
     .rst                               (rst),
     .req                               (col_request),
     .disable_grant                     (1'b0));
`ifdef MC_SVA
  all_bank_machines_col_arb:
    cover property (@(posedge clk) (~rst && &rts_col));
`endif
  output wire [nBANK_MACHS-1:0] sending_col;
  assign sending_col = grant_col_r_lcl & {nBANK_MACHS{~block_grant_col}};
  assign sent_col_lcl = granted_col_r && ~block_grant_col;
  output wire sent_col;
  assign sent_col = sent_col_lcl;
  input [nBANK_MACHS-1:0] col_rdy_wr;
  output wire [nBANK_MACHS-1:0] grant_col_wr;
  generate
    if (EARLY_WR_DATA_ADDR == "OFF") begin : early_wr_addr_arb_off
      assign grant_col_wr = {nBANK_MACHS{1'b0}};
    end
    else begin : early_wr_addr_arb_on
      wire [nBANK_MACHS-1:0] grant_col_wr_raw;
      round_robin_arb #
        (.WIDTH                           (nBANK_MACHS))
        col_arb0
          (.grant_ns                      (grant_col_wr_raw),
           .grant_r                       (),
           .upd_last_master               (sent_col_lcl),
           .current_master                (grant_col_r_lcl[nBANK_MACHS-1:0]),
           .clk                           (clk),
           .rst                           (rst),
           .req                           (col_rdy_wr),
           .disable_grant                 (1'b0));
      reg [nBANK_MACHS-1:0] grant_col_wr_r;
      wire [nBANK_MACHS-1:0] grant_col_wr_ns = granted_col_ns
                                                 ? grant_col_wr_raw
                                                 : grant_col_wr_r;
      always @(posedge clk) grant_col_wr_r <= #TCQ grant_col_wr_ns;
      assign grant_col_wr = grant_col_wr_ns;
    end 
  endgenerate
  output reg send_cmd0_col = 1'b0;
  output reg send_cmd1_row = 1'b0;
  output reg cs_en0 = 1'b0;
  output reg cs_en1 = 1'b0;
  reg insert_maint_r1_lcl;
  always @(posedge clk) insert_maint_r1_lcl <= #TCQ insert_maint_r;
  output wire insert_maint_r1;
  assign insert_maint_r1 = insert_maint_r1_lcl;
  wire sent_row_or_maint = sent_row_lcl || insert_maint_r1_lcl;
  generate
    case ({(nCK_PER_CLK == 2), (ADDR_CMD_MODE == "2T")})
      2'b00 : begin : one_one_not2T
      end
      2'b01 : begin : one_one_2T
      end
      2'b10 : begin : two_one_not2T
        always @(sent_row_or_maint) cs_en0 = sent_row_or_maint;
        always @(sent_col_lcl) cs_en1 = sent_col_lcl;
      end
      2'b11 : begin : two_one_2T
        always @(sent_col_lcl or sent_row_or_maint) cs_en1 = sent_row_or_maint || sent_col_lcl;
        always @(sent_col_lcl) send_cmd0_col = sent_col_lcl;
        always @(sent_row_or_maint) send_cmd1_row = sent_row_or_maint;
      end
    endcase
  endgenerate
endmodule
