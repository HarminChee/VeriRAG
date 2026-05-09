`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_dwidth_converter_v2_1_8_r_upsizer #
  (
   parameter         C_FAMILY                         = "rtl", 
   parameter integer C_AXI_ID_WIDTH                   = 4, 
   parameter integer C_S_AXI_DATA_WIDTH               = 64,
   parameter integer C_M_AXI_DATA_WIDTH               = 32,
   parameter integer C_S_AXI_REGISTER                 = 0,
   parameter integer C_PACKING_LEVEL                    = 1,
   parameter integer C_S_AXI_BYTES_LOG                = 3,
   parameter integer C_M_AXI_BYTES_LOG                = 3,
   parameter integer C_RATIO                          = 2,
   parameter integer C_RATIO_LOG                      = 1
   )
  (
   input  wire                                                    ARESET,
   input  wire                                                    ACLK,
   input  wire                              cmd_valid,
   input  wire                              cmd_fix,
   input  wire                              cmd_modified,
   input  wire                              cmd_complete_wrap,
   input  wire                              cmd_packed_wrap,
   input  wire [C_M_AXI_BYTES_LOG-1:0]      cmd_first_word, 
   input  wire [C_M_AXI_BYTES_LOG-1:0]      cmd_next_word,
   input  wire [C_M_AXI_BYTES_LOG-1:0]      cmd_last_word,
   input  wire [C_M_AXI_BYTES_LOG-1:0]      cmd_offset,
   input  wire [C_M_AXI_BYTES_LOG-1:0]      cmd_mask,
   input  wire [C_S_AXI_BYTES_LOG:0]        cmd_step,
   input  wire [8-1:0]                      cmd_length,
   input  wire [C_AXI_ID_WIDTH-1:0]         cmd_id,
   output wire                              cmd_ready,
   output wire [C_AXI_ID_WIDTH-1:0]           S_AXI_RID,
   output wire [C_S_AXI_DATA_WIDTH-1:0]    S_AXI_RDATA,
   output wire [2-1:0]                          S_AXI_RRESP,
   output wire                                                    S_AXI_RLAST,
   output wire                                                    S_AXI_RVALID,
   input  wire                                                    S_AXI_RREADY,
   input  wire [C_M_AXI_DATA_WIDTH-1:0]    M_AXI_RDATA,
   input  wire [2-1:0]                         M_AXI_RRESP,
   input  wire                                                   M_AXI_RLAST,
   input  wire                                                   M_AXI_RVALID,
   output wire                                                   M_AXI_RREADY
   );
  genvar bit_cnt;
  localparam integer C_NEVER_PACK        = 0;
  localparam integer C_DEFAULT_PACK      = 1;
  localparam integer C_ALWAYS_PACK       = 2;
  wire                            sel_first_word;
  reg                             first_word;
  reg  [C_M_AXI_BYTES_LOG-1:0]    current_word_1;
  reg  [C_M_AXI_BYTES_LOG-1:0]    current_word_cmb;
  wire [C_M_AXI_BYTES_LOG-1:0]    current_word;
  wire [C_M_AXI_BYTES_LOG-1:0]    current_word_adjusted;
  wire                            last_beat;
  wire                            last_word;
  wire [C_M_AXI_BYTES_LOG-1:0]    cmd_step_i;
  wire [C_M_AXI_BYTES_LOG-1:0]    pre_next_word_i;
  wire [C_M_AXI_BYTES_LOG-1:0]    pre_next_word;
  reg  [C_M_AXI_BYTES_LOG-1:0]    pre_next_word_1;
  wire [C_M_AXI_BYTES_LOG-1:0]    next_word_i;
  wire [C_M_AXI_BYTES_LOG-1:0]    next_word;
  wire                            first_mi_word;
  wire [8-1:0]                    length_counter_1;
  reg  [8-1:0]                    length_counter;
  wire [8-1:0]                    next_length_counter;
  wire                            store_in_wrap_buffer;
  reg                             use_wrap_buffer;
  reg                             wrap_buffer_available;
  reg [2-1:0]                     rresp_wrap_buffer;
  wire                            next_word_wrap;
  wire                            word_complete_next_wrap;
  wire                            word_complete_next_wrap_ready;
  wire                            word_complete_next_wrap_pop;
  wire                            word_complete_last_word;
  wire                            word_complete_rest;
  wire                            word_complete_rest_ready;
  wire                            word_complete_rest_pop;
  wire                            word_completed;
  wire                            cmd_ready_i;
  wire                            pop_si_data;
  wire                            pop_mi_data;
  wire                            si_stalling;
  reg  [C_M_AXI_DATA_WIDTH-1:0]   M_AXI_RDATA_I;
  wire                            M_AXI_RLAST_I;
  wire                            M_AXI_RVALID_I;
  wire                            M_AXI_RREADY_I;
  wire [C_AXI_ID_WIDTH-1:0]       S_AXI_RID_I;
  wire [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA_I;
  wire [2-1:0]                    S_AXI_RRESP_I;
  wire                            S_AXI_RLAST_I;
  wire                            S_AXI_RVALID_I;
  wire                            S_AXI_RREADY_I;
  generate
    if ( C_RATIO_LOG > 1 ) begin : USE_LARGE_UPSIZING
      assign cmd_step_i = {{C_RATIO_LOG-1{1'b0}}, cmd_step};
    end else begin : NO_LARGE_UPSIZING
      assign cmd_step_i = cmd_step;
    end
  endgenerate
  generate
    if ( C_FAMILY == "rtl" || 
       ( C_PACKING_LEVEL == C_NEVER_PACK ) ) begin : USE_RTL_WORD_COMPLETED
      assign word_completed = cmd_valid & 
                              ( ( cmd_fix ) |
                                ( ~cmd_fix & ~cmd_complete_wrap & next_word == {C_M_AXI_BYTES_LOG{1'b0}} ) | 
                                ( ~cmd_fix & last_word & ~use_wrap_buffer ) | 
                                ( ~cmd_modified & ( C_PACKING_LEVEL == C_DEFAULT_PACK ) ) |
                                ( C_PACKING_LEVEL == C_NEVER_PACK ) );
      assign word_complete_next_wrap       = ( ~cmd_fix & ~cmd_complete_wrap & next_word == {C_M_AXI_BYTES_LOG{1'b0}} ) | 
                                            ( C_PACKING_LEVEL == C_NEVER_PACK );
      assign word_complete_next_wrap_ready = word_complete_next_wrap & M_AXI_RVALID_I & ~si_stalling;
      assign word_complete_next_wrap_pop   = word_complete_next_wrap_ready & M_AXI_RVALID_I;
      assign word_complete_last_word  = last_word & (~cmd_fix & ~use_wrap_buffer);
      assign word_complete_rest       = word_complete_last_word | cmd_fix | 
                                        ( ~cmd_modified & ( C_PACKING_LEVEL == C_DEFAULT_PACK ) );
      assign word_complete_rest_ready = word_complete_rest & M_AXI_RVALID_I & ~si_stalling;
      assign word_complete_rest_pop   = word_complete_rest_ready & M_AXI_RVALID_I;
    end else begin : USE_FPGA_WORD_COMPLETED
      wire sel_word_complete_next_wrap;
      wire sel_word_completed;
      wire sel_m_axi_rready;
      wire sel_word_complete_last_word;
      wire sel_word_complete_rest;
      generic_baseblocks_v2_1_0_comparator_sel_static #
        (
         .C_FAMILY(C_FAMILY),
         .C_VALUE({C_M_AXI_BYTES_LOG{1'b0}}),
         .C_DATA_WIDTH(C_M_AXI_BYTES_LOG)
         ) next_word_wrap_inst
        (
         .CIN(1'b1),
         .S(sel_first_word),
         .A(pre_next_word_1),
         .B(cmd_next_word),
         .COUT(next_word_wrap)
         );
      assign sel_word_complete_next_wrap = ~cmd_fix & ~cmd_complete_wrap;
      generic_baseblocks_v2_1_0_carry_and #
        (
         .C_FAMILY(C_FAMILY)
         ) word_complete_next_wrap_inst
        (
         .CIN(next_word_wrap),
         .S(sel_word_complete_next_wrap),
         .COUT(word_complete_next_wrap)
         );
      assign sel_m_axi_rready = cmd_valid & S_AXI_RREADY_I;
      generic_baseblocks_v2_1_0_carry_and #
        (
         .C_FAMILY(C_FAMILY)
         ) word_complete_next_wrap_ready_inst
        (
         .CIN(word_complete_next_wrap),
         .S(sel_m_axi_rready),
         .COUT(word_complete_next_wrap_ready)
         );
      generic_baseblocks_v2_1_0_carry_and #
        (
         .C_FAMILY(C_FAMILY)
         ) word_complete_next_wrap_pop_inst
        (
         .CIN(word_complete_next_wrap_ready),
         .S(M_AXI_RVALID_I),
         .COUT(word_complete_next_wrap_pop)
         );
      assign sel_word_complete_last_word = ~cmd_fix & ~use_wrap_buffer;
      generic_baseblocks_v2_1_0_carry_and #
        (
         .C_FAMILY(C_FAMILY)
         ) word_complete_last_word_inst
        (
         .CIN(last_word),
         .S(sel_word_complete_last_word),
         .COUT(word_complete_last_word)
         );
      assign sel_word_complete_rest = cmd_fix | ( ~cmd_modified & ( C_PACKING_LEVEL == C_DEFAULT_PACK ) );
      generic_baseblocks_v2_1_0_carry_or #
        (
         .C_FAMILY(C_FAMILY)
         ) word_complete_rest_inst
        (
         .CIN(word_complete_last_word),
         .S(sel_word_complete_rest),
         .COUT(word_complete_rest)
         );
      generic_baseblocks_v2_1_0_carry_and #
        (
         .C_FAMILY(C_FAMILY)
         ) word_complete_rest_ready_inst
        (
         .CIN(word_complete_rest),
         .S(sel_m_axi_rready),
         .COUT(word_complete_rest_ready)
         );
      generic_baseblocks_v2_1_0_carry_and #
        (
         .C_FAMILY(C_FAMILY)
         ) word_complete_rest_pop_inst
        (
         .CIN(word_complete_rest_ready),
         .S(M_AXI_RVALID_I),
         .COUT(word_complete_rest_pop)
         );
      assign word_completed = word_complete_next_wrap | word_complete_rest;
    end
  endgenerate
  assign M_AXI_RVALID_I = M_AXI_RVALID & cmd_valid;
  generate
    if ( C_FAMILY == "rtl" ) begin : USE_RTL_CTRL
      assign M_AXI_RREADY_I = word_completed & S_AXI_RREADY_I;
      assign pop_mi_data    = M_AXI_RVALID_I & M_AXI_RREADY_I;
      assign cmd_ready_i    = cmd_valid & S_AXI_RLAST_I & pop_si_data;
    end else begin : USE_FPGA_CTRL
      wire sel_cmd_ready;
      assign M_AXI_RREADY_I = word_complete_next_wrap_ready | word_complete_rest_ready;
      assign pop_mi_data    = word_complete_next_wrap_pop | word_complete_rest_pop;
      assign sel_cmd_ready  = cmd_valid & pop_si_data;
      generic_baseblocks_v2_1_0_carry_latch_and #
        (
         .C_FAMILY(C_FAMILY)
         ) cmd_ready_inst
        (
         .CIN(S_AXI_RLAST_I),
         .I(sel_cmd_ready),
         .O(cmd_ready_i)
         );
    end
  endgenerate
  assign S_AXI_RVALID_I = ( M_AXI_RVALID_I | use_wrap_buffer );
  assign pop_si_data    = S_AXI_RVALID_I & S_AXI_RREADY_I;
  assign M_AXI_RREADY   = M_AXI_RREADY_I;
  assign cmd_ready      = cmd_ready_i;
  assign si_stalling    = S_AXI_RVALID_I & ~S_AXI_RREADY_I;
  assign sel_first_word = first_word | cmd_fix;
  assign current_word   = sel_first_word ? cmd_first_word : 
                                           current_word_1;
  generate
    if ( C_FAMILY == "rtl" ) begin : USE_RTL_NEXT_WORD
      assign pre_next_word_i  = ( next_word_i + cmd_step_i );
      assign next_word_i      = sel_first_word ? cmd_next_word : 
                                                 pre_next_word_1;
    end else begin : USE_FPGA_NEXT_WORD
      wire [C_M_AXI_BYTES_LOG-1:0]  next_sel;
      wire [C_M_AXI_BYTES_LOG:0]    next_carry_local;
      assign next_carry_local[0]      = 1'b0;
      for (bit_cnt = 0; bit_cnt < C_M_AXI_BYTES_LOG ; bit_cnt = bit_cnt + 1) begin : LUT_LEVEL
        LUT6_2 # (
         .INIT(64'h5A5A_5A66_F0F0_F0CC) 
        ) LUT6_2_inst (
        .O6(next_sel[bit_cnt]),         
        .O5(next_word_i[bit_cnt]),      
        .I0(cmd_step_i[bit_cnt]),       
        .I1(pre_next_word_1[bit_cnt]),  
        .I2(cmd_next_word[bit_cnt]),    
        .I3(first_word),                
        .I4(cmd_fix),                   
        .I5(1'b1)                       
        );
        MUXCY next_carry_inst 
        (
         .O (next_carry_local[bit_cnt+1]), 
         .CI (next_carry_local[bit_cnt]), 
         .DI (cmd_step_i[bit_cnt]), 
         .S (next_sel[bit_cnt])
        ); 
        XORCY next_xorcy_inst 
        (
         .O(pre_next_word_i[bit_cnt]),
         .CI(next_carry_local[bit_cnt]),
         .LI(next_sel[bit_cnt])
        );
      end 
    end
  endgenerate
  assign next_word              = next_word_i     & cmd_mask;
  assign pre_next_word          = pre_next_word_i & cmd_mask;
  assign current_word_adjusted  = current_word | cmd_offset;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      first_word      <= 1'b1;
      current_word_1  <= 'b0;
      pre_next_word_1 <= {C_M_AXI_BYTES_LOG{1'b0}};
    end else begin
      if ( pop_si_data ) begin
        if ( last_word ) begin
          first_word      <=  1'b1;
        end else begin
          first_word      <=  1'b0;
        end
        current_word_1  <= next_word;
        pre_next_word_1 <= pre_next_word;
      end
    end
  end
  always @ *
  begin
    if ( first_mi_word )
      length_counter = cmd_length;
    else
      length_counter = length_counter_1;
  end
  assign next_length_counter = length_counter - 1'b1;
  generate
    if ( C_FAMILY == "rtl" ) begin : USE_RTL_LENGTH
      reg  [8-1:0]                    length_counter_q;
      reg                             first_mi_word_q;
      always @ (posedge ACLK) begin
        if (ARESET) begin
          first_mi_word_q  <= 1'b1;
          length_counter_q <= 8'b0;
        end else begin
          if ( pop_mi_data ) begin
            if ( M_AXI_RLAST ) begin
              first_mi_word_q  <= 1'b1;
            end else begin
              first_mi_word_q  <= 1'b0;
            end
            length_counter_q <= next_length_counter;
          end
        end
      end
      assign first_mi_word    = first_mi_word_q;
      assign length_counter_1 = length_counter_q;
    end else begin : USE_FPGA_LENGTH
      wire [8-1:0]  length_counter_i;
      wire [8-1:0]  length_sel;
      wire [8-1:0]  length_di;
      wire [8:0]    length_local_carry;
      assign length_local_carry[0] = 1'b0;
      for (bit_cnt = 0; bit_cnt < 8 ; bit_cnt = bit_cnt + 1) begin : BIT_LANE
        LUT6_2 # (
         .INIT(64'h333C_555A_FFF0_FFF0) 
        ) LUT6_2_inst (
        .O6(length_sel[bit_cnt]),           
        .O5(length_di[bit_cnt]),            
        .I0(length_counter_1[bit_cnt]),     
        .I1(cmd_length[bit_cnt]),           
        .I2(word_complete_next_wrap_pop),  
        .I3(word_complete_rest_pop),        
        .I4(first_mi_word),                 
        .I5(1'b1)                           
        );
        MUXCY and_inst 
        (
         .O (length_local_carry[bit_cnt+1]), 
         .CI (length_local_carry[bit_cnt]), 
         .DI (length_di[bit_cnt]), 
         .S (length_sel[bit_cnt])
        ); 
        XORCY xorcy_inst 
        (
         .O(length_counter_i[bit_cnt]),
         .CI(length_local_carry[bit_cnt]),
         .LI(length_sel[bit_cnt])
        );
        FDRE #(
         .INIT(1'b0)                    
         ) FDRE_inst (
         .Q(length_counter_1[bit_cnt]), 
         .C(ACLK),                      
         .CE(1'b1),                     
         .R(ARESET),                    
         .D(length_counter_i[bit_cnt])  
         );
      end 
      wire first_mi_word_i;
      LUT6 # (
       .INIT(64'hAAAC_AAAC_AAAC_AAAC) 
      ) LUT6_cnt_inst (
      .O(first_mi_word_i),                
      .I0(M_AXI_RLAST),                   
      .I1(first_mi_word),                 
      .I2(word_complete_next_wrap_pop),  
      .I3(word_complete_rest_pop),        
      .I4(1'b1),                          
      .I5(1'b1)                           
      );
      FDSE #(
       .INIT(1'b1)                    
       ) FDRE_inst (
       .Q(first_mi_word),             
       .C(ACLK),                      
       .CE(1'b1),                     
       .S(ARESET),                    
       .D(first_mi_word_i)            
       );
    end
  endgenerate
  generate
    if ( C_FAMILY == "rtl" ) begin : USE_RTL_LAST_WORD
      assign last_beat = ( length_counter == 8'b0 );
      assign last_word = ( last_beat & ( current_word == cmd_last_word ) & ~wrap_buffer_available & ( current_word == cmd_last_word ) ) |
                         ( use_wrap_buffer & ( current_word == cmd_last_word ) ) |
                         ( last_beat & ( current_word == cmd_last_word ) & ( C_PACKING_LEVEL == C_NEVER_PACK ) );
    end else begin : USE_FPGA_LAST_WORD
      wire sel_last_word;
      wire last_beat_ii;
      comparator_sel_static #
        (
         .C_FAMILY(C_FAMILY),
         .C_VALUE(8'b0),
         .C_DATA_WIDTH(8)
         ) last_beat_inst
        (
         .CIN(1'b1),
         .S(first_mi_word),
         .A(length_counter_1),
         .B(cmd_length),
         .COUT(last_beat)
         );
      if ( C_PACKING_LEVEL != C_NEVER_PACK  ) begin : USE_FPGA_PACK
        wire sel_last_beat;
        wire last_beat_i;
        assign sel_last_beat = ~wrap_buffer_available;
        carry_and #
          (
           .C_FAMILY(C_FAMILY)
           ) last_beat_inst_1
          (
           .CIN(last_beat),
           .S(sel_last_beat),
           .COUT(last_beat_i)
           );
        carry_or #
          (
           .C_FAMILY(C_FAMILY)
           ) last_beat_wrap_inst
          (
           .CIN(last_beat_i),
           .S(use_wrap_buffer),
           .COUT(last_beat_ii)
           );
      end else begin : NO_PACK
        assign last_beat_ii = last_beat;
      end
      comparator_sel #
        (
         .C_FAMILY(C_FAMILY),
         .C_DATA_WIDTH(C_M_AXI_BYTES_LOG)
         ) last_beat_curr_word_inst
        (
         .CIN(last_beat_ii),
         .S(sel_first_word),
         .A(current_word_1),
         .B(cmd_first_word),
         .V(cmd_last_word),
         .COUT(last_word)
         );
    end
  endgenerate
  assign store_in_wrap_buffer = M_AXI_RVALID_I & cmd_packed_wrap & first_mi_word & ~use_wrap_buffer;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      wrap_buffer_available <= 1'b0;
    end else begin
      if ( store_in_wrap_buffer & word_completed & pop_si_data  ) begin
        wrap_buffer_available <= 1'b1;
      end else if ( last_beat & word_completed & pop_si_data  ) begin
        wrap_buffer_available <= 1'b0;
      end
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      use_wrap_buffer <= 1'b0;
    end else begin
      if ( wrap_buffer_available & last_beat & word_completed & pop_si_data ) begin
        use_wrap_buffer <= 1'b1;
      end else if ( cmd_ready_i ) begin
        use_wrap_buffer <= 1'b0;
      end
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      M_AXI_RDATA_I     <= {C_M_AXI_DATA_WIDTH{1'b0}};
      rresp_wrap_buffer <= 2'b0;
    end else begin
      if ( store_in_wrap_buffer ) begin
        M_AXI_RDATA_I     <= M_AXI_RDATA;
        rresp_wrap_buffer <= M_AXI_RRESP;
      end
    end
  end
  assign S_AXI_RID_I    = cmd_id;
  assign S_AXI_RRESP_I  = ( use_wrap_buffer ) ? 
                          rresp_wrap_buffer :
                          M_AXI_RRESP;
  generate
    if ( C_RATIO == 1 ) begin : SINGLE_WORD
      assign S_AXI_RDATA_I  = ( use_wrap_buffer ) ? 
                              M_AXI_RDATA_I :
                              M_AXI_RDATA;
    end else begin : MULTIPLE_WORD
      wire [C_RATIO_LOG-1:0]          current_index;
      assign current_index  = current_word_adjusted[C_M_AXI_BYTES_LOG-C_RATIO_LOG +: C_RATIO_LOG];
      assign S_AXI_RDATA_I  = ( use_wrap_buffer ) ? 
                              M_AXI_RDATA_I[current_index * C_S_AXI_DATA_WIDTH +: C_S_AXI_DATA_WIDTH] :
                              M_AXI_RDATA[current_index * C_S_AXI_DATA_WIDTH +: C_S_AXI_DATA_WIDTH];
    end
  endgenerate
  assign M_AXI_RLAST_I  = ( M_AXI_RLAST | use_wrap_buffer );
  assign S_AXI_RLAST_I  = last_word;
  generate
    if ( C_S_AXI_REGISTER ) begin : USE_REGISTER
      reg  [C_AXI_ID_WIDTH-1:0]       S_AXI_RID_q;
      reg  [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA_q;
      reg  [2-1:0]                    S_AXI_RRESP_q;
      reg                             S_AXI_RLAST_q;
      reg                             S_AXI_RVALID_q;
      reg                             S_AXI_RREADY_q;
      always @ (posedge ACLK) begin
        if (ARESET) begin
          S_AXI_RID_q       <= {C_AXI_ID_WIDTH{1'b0}};
          S_AXI_RDATA_q     <= {C_S_AXI_DATA_WIDTH{1'b0}};
          S_AXI_RRESP_q     <= 2'b0;
          S_AXI_RLAST_q     <= 1'b0;
          S_AXI_RVALID_q    <= 1'b0;
        end else begin
          if ( S_AXI_RREADY_I ) begin
            S_AXI_RID_q       <= S_AXI_RID_I;
            S_AXI_RDATA_q     <= S_AXI_RDATA_I;
            S_AXI_RRESP_q     <= S_AXI_RRESP_I;
            S_AXI_RLAST_q     <= S_AXI_RLAST_I;
            S_AXI_RVALID_q    <= S_AXI_RVALID_I;
          end
        end
      end
      assign S_AXI_RID      = S_AXI_RID_q;
      assign S_AXI_RDATA    = S_AXI_RDATA_q;
      assign S_AXI_RRESP    = S_AXI_RRESP_q;
      assign S_AXI_RLAST    = S_AXI_RLAST_q;
      assign S_AXI_RVALID   = S_AXI_RVALID_q;
      assign S_AXI_RREADY_I = ( S_AXI_RVALID_q & S_AXI_RREADY) | ~S_AXI_RVALID_q;
    end else begin : NO_REGISTER
      assign S_AXI_RREADY_I = S_AXI_RREADY;
      assign S_AXI_RVALID   = S_AXI_RVALID_I;
      assign S_AXI_RID      = S_AXI_RID_I;
      assign S_AXI_RDATA    = S_AXI_RDATA_I;
      assign S_AXI_RRESP    = S_AXI_RRESP_I;
      assign S_AXI_RLAST    = S_AXI_RLAST_I;
    end
  endgenerate
endmodule
