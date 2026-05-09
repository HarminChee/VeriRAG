`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif
`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif
module pcie_blk_ll_tx
  #( parameter TX_CPL_STALL_THRESHOLD   = 6,
     parameter TX_DATACREDIT_FIX_EN     = 1,
     parameter TX_DATACREDIT_FIX_1DWONLY= 1,
     parameter TX_DATACREDIT_FIX_MARGIN = 6,
     parameter MPS                      = 0,
     parameter LEGACY_EP                = 0
  )
  (
   input  wire        clk,
   input  wire        rst_n,
   input  wire        trn_lnk_up_n,
   output wire [63:0] llk_tx_data,
   output reg         llk_tx_src_rdy_n = 1'b1,
   output wire        llk_tx_src_dsc_n,
   output wire        llk_tx_sof_n,
   output wire        llk_tx_eof_n,
   output wire        llk_tx_sop_n,
   output wire        llk_tx_eop_n,
   output wire  [1:0] llk_tx_enable_n,
   output reg   [2:0] llk_tx_ch_tc = 0,
   output reg   [1:0] llk_tx_ch_fifo = 2'b11,
   input  wire        llk_tx_dst_rdy_n,
   input  wire  [9:0] llk_tx_chan_space,
   input  wire  [7:0] llk_tx_ch_posted_ready_n,     
   input  wire  [7:0] llk_tx_ch_non_posted_ready_n, 
   input  wire  [7:0] llk_tx_ch_completion_ready_n, 
   input  wire [63:0] trn_td,
   input  wire  [7:0] trn_trem_n,
   input  wire        trn_tsof_n,
   input  wire        trn_teof_n,
   input  wire        trn_tsrc_rdy_n,
   input  wire        trn_tsrc_dsc_n,
   input  wire        trn_terrfwd_n,  
   output reg         trn_tdst_rdy_n = 1'b0,
   output wire        trn_tdst_dsc_n,
   output wire        trn_tbuf_av_cpl,
   input  wire  [7:0] tx_ch_credits_consumed,
   input  wire [11:0] tx_pd_credits_available,
   input  wire [11:0] tx_pd_credits_consumed,
   input  wire [11:0] tx_npd_credits_available,
   input  wire [11:0] tx_npd_credits_consumed,
   input  wire [11:0] tx_cd_credits_available,
   input  wire [11:0] tx_cd_credits_consumed,
   output wire        clear_cpl_count,
   input  wire        pd_credit_limited,
   input  wire        npd_credit_limited,
   input  wire        cd_credit_limited,
   input  wire        trn_pfc_cplh_cl_upd,   
   input  wire  [7:0] trn_pfc_cplh_cl,       
   input  wire        l0_stats_cfg_transmitted
   );
  localparam POSTED_CAT     = 2'b00;
  localparam NONPOSTED_CAT  = 2'b01;
  localparam COMPLETION_CAT = 2'b10;
  localparam MRD            = 7'b0X_00000; 
  localparam MRDLK          = 7'b0X_00001; 
  localparam MWR            = 7'b1X_00000; 
  localparam MSG            = 7'bX1_10XXX; 
  localparam IORD           = 7'b00_00010; 
  localparam IOWR           = 7'b10_00010; 
  localparam CFGRD          = 7'b00_0010X; 
  localparam CFGWR          = 7'b10_0010X; 
  localparam CPL            = 7'bX0_0101X; 
  localparam CHANSPACE_CPLEMPTY = (MPS==0)? 8'h48 : (MPS==1)? 8'h80 : 8'h80;
  assign trn_tdst_dsc_n    = 1'b1;
  reg [63:0]       td_q1 = 0;       
  reg              sof_q1 = 0;      
  reg              eof_q1 = 0;      
  reg              rem_q1 = 0;      
  reg              dsc_q1 = 0;      
  reg              vld_q1 = 0;      
  reg [63:0]       td_q2 = 0;
  reg [5:0]        td_q2_credits = 0; 
  reg              td_q2_credits_prev = 0;
  reg              td_q2_posted  = 0;
  reg              td_q2_iowr    = 0;
  reg              td_q2_cpl     = 0;
  reg              sof_q2_reg    = 0;
  wire             sofpd_q2_rose;
  wire             sofnpd_q2_rose;
  wire             sofcpl_q2_rose;
  reg              pd_q1_reg     = 0;
  reg              npd_q1_reg    = 0;
  reg              cpl_q1_reg    = 0;
  reg              sof_q2 = 0;
  reg              eof_q2 = 0;
  reg              rem_q2 = 0;
  reg              dsc_q2 = 0;
  reg              vld_q2 = 0;
  reg              sof_gap_q2 = 0;  
  reg [1:0]        fifo_q2 = 0;     
  reg [2:0]        tc_q2 = 0;       
  reg [63:0]       td_q3 = 0;
  reg              sof_q3 = 0;
  reg              eof_q3 = 0;
  reg              rem_q3 = 0;
  reg              dsc_q3 = 0;
  reg              vld_q3 = 0;
  reg              sof_gap_q3 = 0;
  reg [1:0]        fifo_q3 = 0;
  reg [2:0]        tc_q3 = 0;
  reg [1:0]        fifo_last = 0;
  reg [2:0]        tc_last = 0;
  wire             shift_pipe;
  wire             only_eof;        
  reg              sof_gap_q3_and_block = 1;
  reg              block_sof = 1;   
  reg [2:0]        block_cnt = 0;   
  reg [63:0]       td_buf;
  reg              sof_buf;
  reg              eof_buf;
  reg              rem_buf;
  reg              dsc_buf;
  reg              vld_buf = 1'b0;  
  wire             buf_divert;      
  wire             buf_rd;          
  reg  [ 4:0]      cpl_in_count;
  wire  [4:0]      cpls_buffered;
  reg              llk_tlp_halt;
  reg              llk_tx_src_rdy_n_int;
  reg  [11:0]      user_pd_data_credits_in    = 0;
  reg  [11:0]      user_npd_data_credits_in   = 0;
  reg  [11:0]      user_cd_data_credits_in    = 0;
  reg  [11:0]      all_cd_data_credits_in    = 0;
  reg  [11:0]      l0_stats_cfg_transmitted_cnt=0;
  reg  [11:0]      user_cd_data_credits_in_minus_trn_pfc_cplh_cl_plus1    = 0;
  reg              pd_credits_near_gte_far    = 0;
  reg              npd_credits_near_gte_far   = 0;
  reg              llk_cpl_second_cycle       = 0;
  reg              llk_tx_ch_fifo_d           = 2'b11;
  reg              q2_cpl_second_cycle        = 0;
  wire [11:0]      near_end_pd_credits_buffered;
  wire [11:0]      near_end_npd_credits_buffered;
  wire [11:0]      near_end_cd_credits_buffered;
  reg              near_end_cd_credits_buffered_11_d;
  wire             packet_in_progress;
  reg              packet_in_progress_reg     = 0;
  reg              len_eq1_q2                 = 0;
  reg              llk_tx_chan_space_cpl_empty= 0;
  reg              eof_q3_only = 0;
  reg              eof_q2_only = 0;
  reg              eof_q1_or_eof_q2_only = 0;
  reg              tc_fifo_change = 1'b0;
  reg              block_fifo     = 1'b1;
  reg  [11:0]      cd_space_remaining_int     = 0;
  reg              cd_space_remaining_int_zero= 0;
  reg   [8:0]      trn_pfc_cplh_cl_plus1      = 9;
  reg              trn_pfc_cplh_cl_upd_d1     = 0;
  reg              trn_pfc_cplh_cl_upd_d2     = 0;
  always @(posedge clk) begin
    if (!rst_n) begin
      vld_buf         <= #`TCQ 1'b0;
    end else begin
      if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && buf_divert) begin
        vld_buf       <= #`TCQ 1'b1;
      end else if (buf_rd) begin
        vld_buf       <= #`TCQ 1'b0;
      end
    end
  end
  always @(posedge clk) begin
    if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n) begin
      td_buf        <= #`TCQ trn_td;
      sof_buf       <= #`TCQ !trn_tsof_n;
      eof_buf       <= #`TCQ !trn_teof_n;
      rem_buf       <= #`TCQ !trn_trem_n[0];
      dsc_buf       <= #`TCQ !trn_tsrc_dsc_n;
    end
  end
  assign buf_divert = vld_q1 && !shift_pipe;
  assign buf_rd     = vld_buf && shift_pipe;
  always @(posedge clk) begin
    if (!rst_n) begin
      trn_tdst_rdy_n  <= #`TCQ 1'b0;
    end else begin
      trn_tdst_rdy_n  <= #`TCQ !((!vld_buf &&
                  !(buf_divert && !trn_tdst_rdy_n && !trn_tsrc_rdy_n)) ||
                                 buf_rd);
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      vld_q1       <= #`TCQ 1'b0;
    end else begin
      vld_q1   <= #`TCQ (((!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert) || buf_rd) ||
                       (vld_q1 && !shift_pipe));
    end
    if (!rst_n) begin
      sof_q1  <= #`TCQ 1'b0;
    end else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert) begin
      sof_q1  <= #`TCQ !trn_tsof_n;
    end else if (buf_rd) begin
      sof_q1  <= #`TCQ sof_buf;
    end else begin
      sof_q1  <= #`TCQ (!shift_pipe && sof_q1);
    end
    if (!rst_n) begin
      eof_q1  <= #`TCQ 0;
      dsc_q1  <= #`TCQ 0;
    end else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert) begin
      eof_q1  <= #`TCQ !trn_teof_n;
      dsc_q1  <= #`TCQ !trn_tsrc_dsc_n;
    end else if (buf_rd) begin
      eof_q1  <= #`TCQ eof_buf;
      dsc_q1  <= #`TCQ dsc_buf;
    end
  end
  always @(posedge clk) begin
    if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert) begin 
      td_q1   <= #`TCQ trn_td;
      rem_q1  <= #`TCQ !trn_trem_n[0];
    end else if (shift_pipe) begin       
      td_q1   <= #`TCQ td_buf;
      rem_q1  <= #`TCQ rem_buf;
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      sof_q2     <= #`TCQ 1'b0;
      vld_q2     <= #`TCQ 1'b0;
      len_eq1_q2 <= #`TCQ 1'b0;
      sof_q3     <= #`TCQ 1'b0;
      eof_q3     <= #`TCQ 1'b0;
      vld_q3     <= #`TCQ 1'b0;
    end else begin
      if (shift_pipe) begin
        sof_q2     <= #`TCQ sof_q1;
        vld_q2     <= #`TCQ vld_q1;
        if (sof_q1) len_eq1_q2 <= #`TCQ (td_q1[41:32] == 10'h001) && !(!td_q1[62] && td_q1[60:57] != 4'b0000);
        sof_q3     <= #`TCQ sof_q2;
        eof_q3     <= #`TCQ eof_q2 && vld_q2; 
        vld_q3     <= #`TCQ vld_q2;
      end
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      td_q2      <= #`TCQ 0;
      td_q2_credits <= #`TCQ 'h0;
      td_q2_posted  <= #`TCQ 0;
      td_q2_iowr    <= #`TCQ 0;
      td_q2_cpl     <= #`TCQ 0;
      pd_q1_reg     <= #`TCQ 0;
      npd_q1_reg    <= #`TCQ 0;
      cpl_q1_reg    <= #`TCQ 0;
      eof_q2     <= #`TCQ 0;
      rem_q2     <= #`TCQ 0;
      dsc_q2     <= #`TCQ 0;
    end else if (shift_pipe) begin
      td_q2      <= #`TCQ td_q1;
      if (sof_q1)
        td_q2_credits <= #`TCQ (td_q1[39:34] + (|td_q1[33:32])); 
      td_q2_posted  <= #`TCQ (td_q1[62:57] == 'b10_0000) || (td_q1[62:57] == 'b11_0000) || (td_q1[62:59] == 'b11_10);
      td_q2_iowr    <= #`TCQ (td_q1[62:57] == 'b10_0001);
      td_q2_cpl     <= #`TCQ (td_q1[62:57] == 'b10_0101);
      pd_q1_reg     <= #`TCQ (td_q1[62:57] == 'b100_000) || (td_q1[62:57] == 'b110_000) || (td_q1[62:59] == 'b111_0);
      npd_q1_reg    <= #`TCQ (td_q1[62:57] == 'b10_0001);
      cpl_q1_reg    <= #`TCQ (td_q1[62:57] == 'b10_0101);
      eof_q2     <= #`TCQ eof_q1;
      rem_q2     <= #`TCQ rem_q1 || !eof_q1; 
      dsc_q2     <= #`TCQ dsc_q1;
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      sof_q2_reg    <= #`TCQ 0;
    end else begin
      sof_q2_reg    <= #`TCQ sof_q2;
    end
  end
  assign sofpd_q2_rose  = (sof_q2 && !sof_q2_reg && pd_q1_reg);
  assign sofnpd_q2_rose = (sof_q2 && !sof_q2_reg && npd_q1_reg);
  assign sofcpl_q2_rose = (sof_q2 && !sof_q2_reg && cpl_q1_reg);
  always @(posedge clk) begin
    if (!rst_n) begin
      td_q3      <= #`TCQ 0;
      rem_q3     <= #`TCQ 0;
      dsc_q3     <= #`TCQ 0;
      tc_q3      <= #`TCQ 0;
      fifo_q3    <= #`TCQ 0;
    end else if (shift_pipe) begin
      td_q3      <= #`TCQ td_q2;
      rem_q3     <= #`TCQ rem_q2;
      dsc_q3     <= #`TCQ dsc_q2;
      if (sof_q2) begin
        tc_q3    <= #`TCQ tc_q2;
        fifo_q3  <= #`TCQ fifo_q2;
      end
    end
  end
  always @(posedge clk) begin
    if (sof_q1 && shift_pipe) begin
      casex (td_q1[62:56])
        MWR,    
        MSG:    
          fifo_q2 <= #`TCQ POSTED_CAT;
        MRD,    
        MRDLK,  
        IORD,   
        IOWR,   
        CFGRD,  
        CFGWR:  
          fifo_q2 <= #`TCQ NONPOSTED_CAT;
        CPL:    
          fifo_q2 <= #`TCQ COMPLETION_CAT;
        default:
          fifo_q2 <= #`TCQ POSTED_CAT;
      endcase
      tc_q2  <= #`TCQ td_q1[54:52];
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      sof_gap_q3    <= #`TCQ 1'b0;
      fifo_last     <= #`TCQ 2'b00;
      tc_last       <= #`TCQ 0;
    end else if (sof_q2 && shift_pipe) begin 
      if ((tc_q2 != tc_last) || (fifo_q2 != fifo_last)) begin
        sof_gap_q3  <= #`TCQ 1'b1;
      end else begin
        sof_gap_q3  <= #`TCQ 1'b0;
      end
      fifo_last     <= #`TCQ fifo_q2;
      tc_last       <= #`TCQ tc_q2;
    end else if (vld_q2 && shift_pipe) begin
      sof_gap_q3    <= #`TCQ 1'b0;
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      block_sof          <= #`TCQ 1'b1;
    end else begin
      if (tc_fifo_change) begin
        block_sof        <= #`TCQ 1'b0;
      end else if (sof_q2) begin
        block_sof        <= #`TCQ 1'b1;
      end
    end
  end
  always @(posedge clk) begin
    if (!rst_n)
      sof_gap_q3_and_block  <= #`TCQ 1'b0;
    else begin
      if      (tc_fifo_change)
        sof_gap_q3_and_block  <= #`TCQ 1'b0;
      else if (  sof_q2 && shift_pipe )
        sof_gap_q3_and_block  <= #`TCQ ((tc_q2 != tc_last) || (fifo_q2 != fifo_last)) && (block_sof || sof_q2);
      else if (  vld_q2 && shift_pipe )
        sof_gap_q3_and_block  <= #`TCQ 1'b0;
      else 
        sof_gap_q3_and_block  <= #`TCQ sof_gap_q3 && (block_sof || sof_q2);
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      block_cnt          <= #`TCQ 0;
      block_fifo         <= #`TCQ 1'b0;
      tc_fifo_change     <= #`TCQ 1'b0;
      llk_tx_ch_tc       <= #`TCQ 0;
      llk_tx_ch_fifo     <= #`TCQ 2'b11;
      llk_tx_ch_fifo_d   <= #`TCQ 2'b11;
    end else begin
      if (!llk_tx_dst_rdy_n && !llk_tlp_halt) begin
        block_cnt[0]     <= #`TCQ !llk_tx_eof_n && !llk_tx_src_rdy_n_int;
      end
      if (!llk_tx_dst_rdy_n && !llk_tlp_halt) begin
        block_cnt[2:1]   <= #`TCQ block_cnt[1:0];
      end
      if (eof_q3) begin
        block_fifo       <= #`TCQ 1'b1;
      end else if (block_cnt[1] && !llk_tx_dst_rdy_n && !llk_tlp_halt) begin 
        block_fifo       <= #`TCQ 1'b0;
      end
      if (!block_fifo && 
           (llk_tx_ch_tc != tc_q3 || llk_tx_ch_fifo != fifo_q3)) begin
        llk_tx_ch_tc     <= #`TCQ tc_q3;
        llk_tx_ch_fifo   <= #`TCQ fifo_q3;
        tc_fifo_change   <= #`TCQ 1'b1;
      end else begin
        tc_fifo_change   <= #`TCQ 1'b0;
      end
      llk_tx_ch_fifo_d   <= #`TCQ llk_tx_ch_fifo;
    end
  end
  always @* begin
      llk_tx_src_rdy_n_int <= sof_gap_q3_and_block || !(vld_q3 && (only_eof || !trn_tsrc_rdy_n || vld_buf));
  end
  always @* begin
      llk_tx_src_rdy_n <= sof_gap_q3_and_block || llk_tlp_halt || !(vld_q3 && (only_eof || !trn_tsrc_rdy_n || vld_buf));
  end
  assign   only_eof = eof_q1_or_eof_q2_only   ||   eof_q3_only;
  wire shift_pipe_old = (!llk_tx_src_rdy_n_int && !llk_tx_dst_rdy_n && !llk_tlp_halt) ||
                        ((!trn_tsrc_rdy_n || vld_buf) && !vld_q3) ||
                        (!vld_q3 && (eof_q1   ||   (eof_q2 && !sof_q1)   ||   (eof_q3 && !sof_q2 && !sof_q1)));
  wire   shift_pipe_input0 = (vld_buf || eof_q1 || eof_q2_only || eof_q3_only);
  LUT6 #(.INIT(64'b00100011_00100011_00100011_00100011_00100011_00100011_00100011_11111111)) 
  shift_pipe1                 (.O (shift_pipe),
                               .I5(llk_tx_dst_rdy_n),
                               .I4(llk_tlp_halt),
                               .I3(llk_tx_src_rdy_n_int),
                               .I2(trn_tsrc_rdy_n),
                               .I1(vld_q3),
                               .I0(shift_pipe_input0));
  always @(posedge clk) begin
    if (!rst_n) begin
      eof_q3_only           <= #`TCQ 0;
      eof_q2_only           <= #`TCQ 0;
      eof_q1_or_eof_q2_only <= #`TCQ 0;
    end else begin
      if      (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert &&  shift_pipe)
        eof_q3_only <= #`TCQ (eof_q2 && vld_q2) && !sof_q1  && trn_tsof_n;
      else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert && !shift_pipe)
        eof_q3_only <= #`TCQ (eof_q3)           && !sof_q2  && trn_tsof_n;
      else if (buf_rd &&  shift_pipe)
        eof_q3_only <= #`TCQ (eof_q2 && vld_q2) && !sof_q1  && !sof_buf;
      else if (buf_rd && !shift_pipe)
        eof_q3_only <= #`TCQ (eof_q3)           && !sof_q2  && !sof_buf;
      else if (shift_pipe)
        eof_q3_only <= #`TCQ (eof_q2 && vld_q2) && !sof_q1;
      if      (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert &&  shift_pipe)
        eof_q2_only <= #`TCQ eof_q1 && trn_tsof_n;
      else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert && !shift_pipe)
        eof_q2_only <= #`TCQ eof_q2 && trn_tsof_n;
      else if (buf_rd &&  shift_pipe)
        eof_q2_only <= #`TCQ eof_q1 && !sof_buf;
      else if (buf_rd && !shift_pipe)
        eof_q2_only <= #`TCQ eof_q2 && !sof_buf;
      else if (shift_pipe)
        eof_q2_only <= #`TCQ eof_q1;
      if      (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert &&  shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ (eof_q1 && trn_tsof_n) || !trn_teof_n;
      else if (!trn_tdst_rdy_n && !trn_tsrc_rdy_n && !buf_divert && !shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ (eof_q2 && trn_tsof_n) || !trn_teof_n;
      else if (buf_rd &&  shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ (eof_q1 && !sof_buf) || eof_buf;
      else if (buf_rd && !shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ (eof_q2 && !sof_buf) || eof_buf;
      else if (shift_pipe)
        eof_q1_or_eof_q2_only <= #`TCQ eof_q1;
      else
        eof_q1_or_eof_q2_only <= #`TCQ eof_q2_only || eof_q1;
    end
  end
  assign llk_tx_data      = td_q3;
  assign llk_tx_enable_n  = {1'b0, !rem_q3};
  assign llk_tx_sof_n     = !(sof_q3);
  assign llk_tx_eof_n     = !(eof_q3);
  assign llk_tx_sop_n     = 1'b1; 
  assign llk_tx_eop_n     = 1'b1; 
  assign llk_tx_src_dsc_n = !(dsc_q3);
  always @(posedge clk) begin
    if (!rst_n) begin
      cpl_in_count <= #`TCQ 'b0;
      llk_tlp_halt <= #`TCQ 'b0;
    end else begin
      cpl_in_count <= #`TCQ cpl_in_count + l0_stats_cfg_transmitted + 
                            (!llk_tx_sof_n && !llk_tx_src_rdy_n_int && !llk_tx_dst_rdy_n && !llk_tlp_halt &&
                            (llk_tx_data[61:57] == 5'b0_0101));
      llk_tlp_halt <= #`TCQ 
          ((cpls_buffered >= TX_CPL_STALL_THRESHOLD) && fifo_q2[1] && (llk_tlp_halt || (sof_q2 && shift_pipe)))
                                                      ||
          (TX_DATACREDIT_FIX_EN && (len_eq1_q2 || !TX_DATACREDIT_FIX_1DWONLY) && (
           (pd_credits_near_gte_far              && ~|fifo_q2[1:0] && (llk_tlp_halt || (sof_q2 && shift_pipe))) ||
           (npd_credits_near_gte_far             &&   fifo_q2[0]   && (llk_tlp_halt || (sof_q2 && shift_pipe)) && LEGACY_EP))
                            );
    end
  end
  reg llk_tlp_halt_cpl8buf;
  reg llk_tlp_halt_cpldatacredit;
  reg llk_tlp_halt_pdatacredit;
  reg llk_tlp_halt_npdatacredit;
  always @(posedge clk) begin
    if (!rst_n) begin
      llk_tlp_halt_cpl8buf       <= #`TCQ 1'b0;
      llk_tlp_halt_cpldatacredit <= #`TCQ 1'b0;
      llk_tlp_halt_pdatacredit   <= #`TCQ 1'b0;
      llk_tlp_halt_npdatacredit  <= #`TCQ 1'b0;
    end else begin
      llk_tlp_halt_cpl8buf       <= #`TCQ ((cpls_buffered >= TX_CPL_STALL_THRESHOLD) && fifo_q2[1] &&
                                           (llk_tlp_halt || (sof_q2 && shift_pipe)));
      llk_tlp_halt_cpldatacredit <= #`TCQ (TX_DATACREDIT_FIX_EN && ({6'b0,td_q2_credits} > cd_space_remaining_int));
      llk_tlp_halt_pdatacredit   <= #`TCQ (TX_DATACREDIT_FIX_EN && (len_eq1_q2 || !TX_DATACREDIT_FIX_1DWONLY) && 
                                           (pd_credits_near_gte_far && ~|fifo_q2[1:0] &&
                                           (llk_tlp_halt || (sof_q2 && shift_pipe))));
      llk_tlp_halt_npdatacredit  <= #`TCQ (TX_DATACREDIT_FIX_EN && (len_eq1_q2 || !TX_DATACREDIT_FIX_1DWONLY) &&
                                           (npd_credits_near_gte_far &&  fifo_q2[0]   &&
                                           (llk_tlp_halt || (sof_q2 && shift_pipe)) && LEGACY_EP));
    end
  end
  assign cpls_buffered   = cpl_in_count - tx_ch_credits_consumed[4:0];
  assign trn_tbuf_av_cpl = (cpls_buffered < (TX_CPL_STALL_THRESHOLD - 2)); 
  assign near_end_pd_credits_buffered  = (user_pd_data_credits_in  - tx_pd_credits_consumed);
  assign near_end_npd_credits_buffered = (user_npd_data_credits_in - tx_npd_credits_consumed);
  assign near_end_cd_credits_buffered  = (all_cd_data_credits_in  - tx_cd_credits_consumed);
  assign clear_cpl_count = llk_tx_chan_space_cpl_empty;
  assign packet_in_progress = packet_in_progress_reg || (sof_q3 && !llk_tx_src_rdy_n);
  always @(posedge clk) begin
    if (!rst_n) begin
       packet_in_progress_reg <= #`TCQ 0;
    end else if (sof_q3 && !llk_tx_src_rdy_n) begin
       packet_in_progress_reg <= #`TCQ 1;
    end else if (eof_q3 && !llk_tx_src_rdy_n) begin
       packet_in_progress_reg <= #`TCQ 0;
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      user_pd_data_credits_in     <= #`TCQ TX_DATACREDIT_FIX_MARGIN;
      user_npd_data_credits_in    <= #`TCQ 'h1; 
      user_cd_data_credits_in     <= #`TCQ TX_DATACREDIT_FIX_MARGIN;
      all_cd_data_credits_in      <= #`TCQ TX_DATACREDIT_FIX_MARGIN;
      l0_stats_cfg_transmitted_cnt<= #`TCQ 0;
      near_end_cd_credits_buffered_11_d<= #`TCQ 0;
    end else begin
      near_end_cd_credits_buffered_11_d<= #`TCQ near_end_cd_credits_buffered[11];
      if (sofpd_q2_rose)
        user_pd_data_credits_in    <= #`TCQ user_pd_data_credits_in + td_q2_credits;
      if (sofnpd_q2_rose)
        user_npd_data_credits_in   <= #`TCQ user_npd_data_credits_in + 1;
      if (sofcpl_q2_rose) begin
        user_cd_data_credits_in    <= #`TCQ user_cd_data_credits_in + td_q2_credits;
        user_cd_data_credits_in_minus_trn_pfc_cplh_cl_plus1 <= #`TCQ user_cd_data_credits_in + td_q2_credits -
                                                              trn_pfc_cplh_cl_plus1;
      end
      if (llk_tx_chan_space_cpl_empty || near_end_cd_credits_buffered_11_d)
        l0_stats_cfg_transmitted_cnt <= #`TCQ tx_cd_credits_consumed - user_cd_data_credits_in_minus_trn_pfc_cplh_cl_plus1;
      else
        l0_stats_cfg_transmitted_cnt <= #`TCQ l0_stats_cfg_transmitted_cnt + l0_stats_cfg_transmitted;
      if (sofcpl_q2_rose)
        all_cd_data_credits_in     <= #`TCQ user_cd_data_credits_in + l0_stats_cfg_transmitted_cnt + td_q2_credits;
      else
        all_cd_data_credits_in     <= #`TCQ user_cd_data_credits_in + l0_stats_cfg_transmitted_cnt;
    end
  end
  always @(posedge clk) begin
    if (!rst_n) begin
      td_q2_credits_prev           <= #`TCQ 'h0;
      llk_tx_chan_space_cpl_empty  <= #`TCQ 1'b0;
      llk_cpl_second_cycle         <= #`TCQ 1'b0;
      q2_cpl_second_cycle          <= #`TCQ 1'b0;
      trn_pfc_cplh_cl_upd_d1       <= #`TCQ 1'b0;
      trn_pfc_cplh_cl_upd_d2       <= #`TCQ 1'b0;
      trn_pfc_cplh_cl_plus1        <= #`TCQ 'd9; 
    end else begin
      if (sofcpl_q2_rose)
        td_q2_credits_prev           <= #`TCQ td_q2_credits[0];
      llk_tx_chan_space_cpl_empty  <= #`TCQ (llk_tx_chan_space[7:0] == CHANSPACE_CPLEMPTY) && (llk_tx_ch_fifo==2'b10);
      llk_cpl_second_cycle         <= #`TCQ !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && llk_tx_ch_fifo[1];
      q2_cpl_second_cycle          <= #`TCQ sof_q2 && vld_q2 && shift_pipe && td_q2_cpl;
      trn_pfc_cplh_cl_upd_d1       <= #`TCQ trn_pfc_cplh_cl_upd;
      trn_pfc_cplh_cl_upd_d2       <= #`TCQ trn_pfc_cplh_cl_upd_d1;
      if (trn_pfc_cplh_cl_upd && !trn_pfc_cplh_cl_upd_d1)
        trn_pfc_cplh_cl_plus1        <= #`TCQ {1'b0,trn_pfc_cplh_cl} + 1;
    end
  end
  always @(posedge clk) begin
    if (!pd_credit_limited)
      pd_credits_near_gte_far     <= #`TCQ 1'b0;
    else
      pd_credits_near_gte_far     <= #`TCQ (near_end_pd_credits_buffered  >= tx_pd_credits_available);
    if (!npd_credit_limited)
      npd_credits_near_gte_far    <= #`TCQ 1'b0;
    else
      npd_credits_near_gte_far    <= #`TCQ (near_end_npd_credits_buffered >  tx_npd_credits_available);
  end
  always @(posedge clk) begin
    if (!cd_credit_limited) begin
      cd_space_remaining_int      <= #`TCQ 12'hFFF;
      cd_space_remaining_int_zero <= #`TCQ 1'b0;
    end else begin
      cd_space_remaining_int      <= #`TCQ (tx_cd_credits_available  - near_end_cd_credits_buffered);
      cd_space_remaining_int_zero <= #`TCQ (tx_cd_credits_available <= near_end_cd_credits_buffered);
    end
  end
 reg [11:0] llk_pd_credit_count;
 reg [11:0] llk_pd_credit_count_reg;
 reg [11:0] llk_npd_credit_count;
 reg [11:0] llk_npd_credit_count_reg;
 reg [11:0] llk_cpl_credit_count;
 reg [11:0] llk_cpl_credit_count_reg;
  always @(posedge clk) begin
     if (!rst_n)
        llk_pd_credit_count_reg <= #`TCQ TX_DATACREDIT_FIX_MARGIN;
     else if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && 
              ((llk_tx_data[62] && (llk_tx_data[60:56]==5'b00000)) || (llk_tx_data[62:59] == 4'b11_10)))
        if (llk_tx_data[41:32]==10'h0)
          llk_pd_credit_count_reg <= #`TCQ llk_pd_credit_count_reg + {1'b1,llk_tx_data[41:34]};
        else
          llk_pd_credit_count_reg <= #`TCQ llk_pd_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
  end
  always @* begin
     if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && 
         ((llk_tx_data[62] && (llk_tx_data[60:56]==5'b00000)) || (llk_tx_data[62:59] == 4'b11_10)))
        if (llk_tx_data[41:32]==10'h0)
          llk_pd_credit_count = llk_pd_credit_count_reg + {1'b1,llk_tx_data[41:34]};
        else
          llk_pd_credit_count = llk_pd_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
     else
       llk_pd_credit_count = llk_pd_credit_count_reg;
  end
  always @(posedge clk) begin
     if (!rst_n)
        llk_npd_credit_count_reg <= #`TCQ 'h1;
     else if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && (llk_tx_data[62:56]==7'b100_0010))
        llk_npd_credit_count_reg <= #`TCQ llk_npd_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
  end
  always @* begin
     if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && (llk_tx_data[62:56]==7'b100_0010))
        llk_npd_credit_count = llk_npd_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
     else
        llk_npd_credit_count = llk_npd_credit_count_reg;
  end
  always @(posedge clk) begin
     if (!trn_pfc_cplh_cl_upd_d2)
        llk_cpl_credit_count_reg <= #`TCQ {3'b000, trn_pfc_cplh_cl_plus1};
     else if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && (llk_tx_data[62:57]==6'b100_101))
        llk_cpl_credit_count_reg <= #`TCQ llk_cpl_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
  end
  always @* begin
     if (!llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && (llk_tx_data[62:57]==6'b100_101))
        llk_cpl_credit_count = llk_cpl_credit_count_reg + llk_tx_data[41:34] + |llk_tx_data[33:32];
     else
        llk_cpl_credit_count = llk_cpl_credit_count_reg;
  end
  wire  [11:0] user_pd_data_credits_in_raw  = user_pd_data_credits_in  - TX_DATACREDIT_FIX_MARGIN;
  wire  [11:0] user_npd_data_credits_in_raw = user_npd_data_credits_in - 1;
  wire  [11:0] user_cd_data_credits_in_raw  = all_cd_data_credits_in  - TX_DATACREDIT_FIX_MARGIN;
  `ifdef SV
   ASSERT_LLK_TX_NOCPL_BEYOND_THRESHOLD: assert property (@(posedge clk)
       !llk_tx_sof_n && !llk_tx_src_rdy_n && llk_tx_ch_fifo[1] |->
              (cpls_buffered <= TX_CPL_STALL_THRESHOLD)  
                                                         ) else $fatal;
   ASSERT_SHIFT_PIPE_LUT_EQ_EQUATION:    assert property (@(posedge clk)
        rst_n  |-> (shift_pipe == shift_pipe_old)
                                                         ) else $fatal;
   ASSERT_EOFQ1Q2_REPLACEMENT:           assert property (@(posedge clk)
        rst_n  |-> (eof_q1_or_eof_q2_only == (eof_q1 || (eof_q2 && !sof_q1)))
                                                         ) else $fatal;
   ASSERT_LLKHALT_RISES_ONLY_ON_LLKSOF:  assert property (@(posedge clk)
        rst_n && llk_tlp_halt |-> !llk_tx_sof_n
                                                         ) else $fatal;
   ASSERT_LLK_PD_CREDITCNT_INCONSISTENT: assert property (@(posedge clk)
        rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n |-> (llk_pd_credit_count != user_pd_data_credits_in)
                                                         ) else $fatal;
   ASSERT_LLK_NPD_CREDITCNT_INCONSISTENT:assert property (@(posedge clk)
        rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n |-> (llk_npd_credit_count!= user_npd_data_credits_in)
                                                         ) else $fatal;
  `else
     always @(posedge clk) if (rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && llk_tx_ch_fifo[1] && (cpls_buffered > TX_CPL_STALL_THRESHOLD)) begin
        $display("ASSERT_LLK_TX_NOCPL_BEYOND_THRESHOLD");
        $finish;
     end
     always @(posedge clk) if (rst_n && (shift_pipe != shift_pipe_old)) begin
        $display("ASSERT_SHIFT_PIPE_LUT_EQ_EQUATION");
        $finish;
     end
     always @(posedge clk) if (rst_n && (eof_q1_or_eof_q2_only != (eof_q1 || (eof_q2 && !sof_q1)))) begin
        $display("ASSERT_EOFQ1Q2_REPLACEMENT");
        $finish;
     end
     always @(posedge clk) if (rst_n && llk_tlp_halt && llk_tx_sof_n) begin
        $display("ASSERT_LLKHALT_RISES_ONLY_ON_LLKSOF");
        $finish;
     end
     always @(posedge clk) if (rst_n && llk_tlp_halt && llk_tx_sof_n) begin
        $display("ASSERT_LLKHALT_RISES_ONLY_ON_LLKSOF");
        $finish;
     end
     always @(posedge clk) if (rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && 
                               (llk_pd_credit_count != user_pd_data_credits_in)) begin
        $display("ASSERT_LLK_PD_CREDITCNT_INCONSISTENT");
        $finish;
     end
     always @(posedge clk) if (rst_n && !llk_tx_sof_n && !llk_tx_src_rdy_n && !llk_tx_dst_rdy_n && 
                               (llk_npd_credit_count != user_npd_data_credits_in)) begin
        $display("ASSERT_LLK_NPD_CREDITCNT_INCONSISTENT");
        $finish;
     end
     reg [9:0] initcnt = 0;
     always @(posedge clk) begin
       if (!rst_n)
         initcnt <= #`TCQ 0;
       else if (trn_pfc_cplh_cl_upd && !(&initcnt))
         initcnt <= #`TCQ initcnt + 1;
     end
     always @(posedge clk) if (rst_n && pd_credit_limited &&  (near_end_pd_credits_buffered  > (tx_pd_credits_available + 512))) begin
        $display("ASSERT_TX_TOOMUCH_POSTEDDATA_OUTSTANDING");
        $finish;
     end
     always @(posedge clk) if (rst_n && npd_credit_limited && (near_end_npd_credits_buffered  > (tx_npd_credits_available + 1))) begin
        $display("ASSERT_TX_TOOMUCH_NONPOSTEDDATA_OUTSTANDING");
        $finish;
     end
  `endif
endmodule 
