module gic_master #(
  parameter idle   = 4'b1111
) (
  input               wb_clk_i,
  input               wb_rst_i,
  input  [31:0]       wb_adr_i,
  input  [31:0]       wb_dat_i,
  input  [3:0]        wb_sel_i,
  input               wb_we_i,
  input  [1:0]        wb_bte_i,
  input  [2:0]        wb_cti_i,
  input               wb_cyc_i,
  input               wb_stb_i,
  output              wb_ack_o,
  output              wb_err_o,
  output              wb_rty_o,
  output [31:0]       wb_dat_o,
  input  [3:0]        gic_dat_i,
  output [3:0]        gic_dat_o,
  output              gic_cs_o
);
  localparam          master_initiate = 4'b1010;
  localparam          slave_initiate = 4'b0101;
  localparam          state_m_init = 0;
  localparam          state_m_cmd = 1;
  localparam          state_m_sel = 2;
  localparam          state_m_adr = 3;
  localparam          state_m_dat = 4;
  localparam          state_m_cksum = 5;
  localparam          state_s_init = 6;
  localparam          state_s_resp = 7;
  localparam          state_s_dat = 8;
  localparam          state_s_cksum = 9;
  reg [3:0]           state_r = state_m_init;
  reg [3:0]           next_state_r = state_m_init;
  reg [2:0]           cntr_r = 0;
  reg                 wb_ack_r = 1'b0;
  reg [31:0]          wb_dat_r = 0;
  reg [3:0]           gic_dat_r = 0;
  reg [3:0]           gic_chksum_r = 0;
  reg                 data_correct_r = 0;
  wire valid = wb_cyc_i & wb_stb_i & ~data_correct_r;
  wire cs = (state_r >= state_s_init) & (state_r <= state_s_cksum);
  wire [3:0] chksum_operand = (cntr_r == 0) ? 4'b1100 : 4'b0000;
  assign wb_err_o = 1'b0;
  assign wb_rty_o = 1'b0;
  assign wb_ack_o = data_correct_r;
  assign wb_dat_o = wb_dat_r;
  assign gic_dat_o = gic_dat_r;
  assign gic_cs_o = cs;
  always @(posedge wb_clk_i)
  begin
    if (wb_rst_i) begin
      state_r <= state_m_init;
    end else begin
      state_r <= next_state_r;
    end
  end
  always @(posedge wb_clk_i)
  begin
    if (wb_rst_i) begin
      cntr_r <= 7;
    end else begin
      cntr_r <= 7;
      if ((state_r == state_m_adr) | (state_r == state_m_dat) |
          (state_r == state_s_dat)) begin
        cntr_r <= cntr_r - 1;
      end
    end
  end
  always @(state_r or cntr_r or valid)
  begin
    gic_dat_r <= idle;
    case (state_r)
      state_m_init:
        if (valid)
          gic_dat_r <= master_initiate;
      state_m_cmd:
        gic_dat_r <= {wb_we_i, 1'b0, 1'b0, 1'b0};
      state_m_sel:
        gic_dat_r <= wb_sel_i;
      state_m_adr:
        gic_dat_r <= wb_adr_i[cntr_r*4+:4];
      state_m_dat:
        gic_dat_r <= wb_dat_i[cntr_r*4+:4];
      state_m_cksum:
        gic_dat_r <= gic_chksum_r;
    endcase
  end
  always @(state_r or cntr_r)
  begin
    wb_dat_r <= wb_dat_r;
    case (state_r)
      state_s_dat:
        wb_dat_r[cntr_r*4+:4] <= gic_dat_i;
    endcase
  end
  always @(posedge wb_clk_i)
  begin
    gic_chksum_r <= gic_chksum_r;
    case (state_r)
      state_m_sel:
        gic_chksum_r <= wb_sel_i;
      state_m_adr:
        gic_chksum_r <= gic_chksum_r ^ wb_adr_i[cntr_r*4+:4] ^ chksum_operand;
      state_m_dat:
        gic_chksum_r <= gic_chksum_r ^ wb_dat_i[cntr_r*4+:4] ^ chksum_operand;
      state_s_resp:
        gic_chksum_r <= 0;
      state_s_dat:
        gic_chksum_r <= gic_chksum_r ^ gic_dat_i ^ chksum_operand;
    endcase
  end
  always @(state_r)
  begin
    data_correct_r <= 1'b0;
    case (state_r)
      state_s_resp:
        if (wb_we_i)
          data_correct_r <= 1'b1;
      state_s_cksum:
        data_correct_r <= (gic_dat_i == gic_chksum_r);
    endcase
  end
  always @(state_r or cntr_r or valid)
  begin
    next_state_r <= state_r;
    case (state_r)
      state_m_init:
        if (valid)
          next_state_r <= state_m_cmd;
      state_m_cmd:
        next_state_r <= state_m_sel;
      state_m_sel:
        next_state_r <= state_m_adr;
      state_m_adr:
        if (cntr_r == 0)
          next_state_r <= wb_we_i ? state_m_dat : state_m_cksum;
      state_m_dat:
        if (cntr_r == 0)
          next_state_r <= state_m_cksum;
      state_m_cksum:
        next_state_r <= state_s_init;
      state_s_init:
        if (gic_dat_i == slave_initiate)
          next_state_r <= state_s_resp;
      state_s_resp:
        next_state_r <= wb_we_i ? state_m_init : state_s_dat;
      state_s_dat:
        if (cntr_r == 0)
          next_state_r <= state_s_cksum;
      state_s_cksum:
        next_state_r <= state_m_init;
    endcase
  end
  always @(posedge wb_clk_i)
  begin
    if ((gic_dat_i != gic_chksum_r) & (state_r == state_s_cksum)) begin
      $display("Checksum error, retrying: 0x%08x", wb_adr_i);
    end
  end
`ifdef DEBUG_GIC_MASTER
  always @(posedge wb_clk_i)
  begin
    if (valid & (state_r == state_m_init))
      $display("\nNew %s cycle: 0x%08x", wb_we_i ? "write" : "read", wb_adr_i);
    if (~((state_r == state_m_init) & ~valid) & (state_r != state_s_init)) begin
      $display(
        "GIC: OUT: %04b IN: %04b CS: %b CKS: %04b CNTR: %d S: %d O: %4b",
        gic_dat_r, gic_dat_i, cs, gic_chksum_r, cntr_r, state_r, chksum_operand);
    end
    if (wb_ack_o)
      $display("Finished %s cycle: 0x%08x = %08x)", wb_we_i ? "write" : "read",
        wb_adr_i, wb_we_i ? wb_dat_i : wb_dat_o);
  end
`endif
endmodule
