`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_dwidth_converter_v2_1_8_a_upsizer #
  (
   parameter         C_FAMILY                         = "rtl", 
   parameter integer C_AXI_PROTOCOL = 0, 
   parameter integer C_AXI_ID_WIDTH                   = 1, 
   parameter integer C_SUPPORTS_ID                    = 0, 
   parameter integer C_AXI_ADDR_WIDTH                 = 32, 
   parameter integer C_S_AXI_DATA_WIDTH               = 64,
   parameter integer C_M_AXI_DATA_WIDTH               = 32,
   parameter integer C_M_AXI_REGISTER                 = 0,
   parameter integer C_AXI_CHANNEL                      = 0,
   parameter integer C_PACKING_LEVEL                    = 1,
   parameter integer C_FIFO_MODE                        = 0,
   parameter integer C_ID_QUEUE                         = 0,
   parameter integer C_S_AXI_BYTES_LOG                = 3,
   parameter integer C_M_AXI_BYTES_LOG                = 3
   )
  (
   input  wire                                                    ARESET,
   input  wire                                                    ACLK,
   output wire                              cmd_valid,
   output wire                              cmd_fix,
   output wire                              cmd_modified,
   output wire                              cmd_complete_wrap,
   output wire                              cmd_packed_wrap,
   output wire [C_M_AXI_BYTES_LOG-1:0]      cmd_first_word, 
   output wire [C_M_AXI_BYTES_LOG-1:0]      cmd_next_word, 
   output wire [C_M_AXI_BYTES_LOG-1:0]      cmd_last_word,
   output wire [C_M_AXI_BYTES_LOG-1:0]      cmd_offset,
   output wire [C_M_AXI_BYTES_LOG-1:0]      cmd_mask,
   output wire [C_S_AXI_BYTES_LOG:0]        cmd_step,
   output wire [8-1:0]                      cmd_length,
   output wire [C_AXI_ID_WIDTH-1:0]         cmd_id,
   input  wire                              cmd_ready,
   input  wire                              cmd_id_ready,
   output  wire [C_AXI_ADDR_WIDTH-1:0]       cmd_si_addr,
   output wire [C_AXI_ID_WIDTH-1:0]          cmd_si_id,
   output  wire [8-1:0]                      cmd_si_len,
   output  wire [3-1:0]                      cmd_si_size,
   output  wire [2-1:0]                      cmd_si_burst,
   input  wire [C_AXI_ID_WIDTH-1:0]            S_AXI_AID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]          S_AXI_AADDR,
   input  wire [8-1:0]                         S_AXI_ALEN,
   input  wire [3-1:0]                         S_AXI_ASIZE,
   input  wire [2-1:0]                         S_AXI_ABURST,
   input  wire [2-1:0]                         S_AXI_ALOCK,
   input  wire [4-1:0]                         S_AXI_ACACHE,
   input  wire [3-1:0]                         S_AXI_APROT,
   input  wire [4-1:0]                         S_AXI_AREGION,
   input  wire [4-1:0]                         S_AXI_AQOS,
   input  wire                                                   S_AXI_AVALID,
   output wire                                                   S_AXI_AREADY,
   output wire [C_AXI_ADDR_WIDTH-1:0]          M_AXI_AADDR,
   output wire [8-1:0]                         M_AXI_ALEN,
   output wire [3-1:0]                         M_AXI_ASIZE,
   output wire [2-1:0]                         M_AXI_ABURST,
   output wire [2-1:0]                         M_AXI_ALOCK,
   output wire [4-1:0]                         M_AXI_ACACHE,
   output wire [3-1:0]                         M_AXI_APROT,
   output wire [4-1:0]                         M_AXI_AREGION,
   output wire [4-1:0]                         M_AXI_AQOS,
   output wire                                                   M_AXI_AVALID,
   input  wire                                                   M_AXI_AREADY
   );
  localparam [3-1:0] C_S_AXI_NATIVE_SIZE = (C_S_AXI_DATA_WIDTH == 1024) ? 3'b111 :
                                           (C_S_AXI_DATA_WIDTH ==  512) ? 3'b110 :
                                           (C_S_AXI_DATA_WIDTH ==  256) ? 3'b101 :
                                           (C_S_AXI_DATA_WIDTH ==  128) ? 3'b100 :
                                           (C_S_AXI_DATA_WIDTH ==   64) ? 3'b011 :
                                           (C_S_AXI_DATA_WIDTH ==   32) ? 3'b010 :
                                           (C_S_AXI_DATA_WIDTH ==   16) ? 3'b001 :
                                           3'b000;
  localparam [3-1:0] C_M_AXI_NATIVE_SIZE = (C_M_AXI_DATA_WIDTH == 1024) ? 3'b111 :
                                           (C_M_AXI_DATA_WIDTH ==  512) ? 3'b110 :
                                           (C_M_AXI_DATA_WIDTH ==  256) ? 3'b101 :
                                           (C_M_AXI_DATA_WIDTH ==  128) ? 3'b100 :
                                           (C_M_AXI_DATA_WIDTH ==   64) ? 3'b011 :
                                           (C_M_AXI_DATA_WIDTH ==   32) ? 3'b010 :
                                           (C_M_AXI_DATA_WIDTH ==   16) ? 3'b001 :
                                           3'b000;
  localparam [24-1:0] C_DOUBLE_LEN       = 24'b0000_0000_0000_0000_1111_1111;
  localparam [2-1:0] C_FIX_BURST         = 2'b00;
  localparam [2-1:0] C_INCR_BURST        = 2'b01;
  localparam [2-1:0] C_WRAP_BURST        = 2'b10;
  localparam integer C_NEVER_PACK        = 0;
  localparam integer C_DEFAULT_PACK      = 1;
  localparam integer C_ALWAYS_PACK       = 2;
  localparam integer C_FIFO_DEPTH_LOG    = 5;
  localparam integer C_BURST_BYTES_LOG   = 4 + C_S_AXI_BYTES_LOG;
  localparam integer C_SI_UNUSED_LOG     = C_AXI_ADDR_WIDTH-C_S_AXI_BYTES_LOG;
  localparam integer C_MI_UNUSED_LOG     = C_AXI_ADDR_WIDTH-C_M_AXI_BYTES_LOG;
  genvar bit_cnt;
  wire                                access_is_fix;
  wire                                access_is_incr;
  wire                                access_is_wrap;
  wire                                access_is_modifiable;
  wire                                access_is_unaligned;
  reg  [8-1:0]                        si_maximum_length;
  wire [16-1:0]                       mi_word_intra_len_complete;
  wire [20-1:0]                       mask_help_vector;
  reg  [C_M_AXI_BYTES_LOG-1:0]        mi_word_intra_len;
  reg  [8-1:0]                        upsized_length;
  wire                                sub_sized_wrap;
  reg  [C_M_AXI_BYTES_LOG-1:0]        size_mask;
  reg  [C_BURST_BYTES_LOG-1:0]        burst_mask;
  wire                                access_need_extra_word;
  wire [8-1:0]                        adjusted_length;
  wire [C_BURST_BYTES_LOG-1:0]        wrap_addr_aligned;
  wire                                cmd_empty;
  wire                                s_ready;
  wire                                cmd_full;
  wire                                allow_new_cmd;
  wire                                cmd_push;
  reg                                 cmd_push_block;
  wire                                s_id_ready;
  wire                                cmd_valid_i;
  wire                                cmd_fix_i;
  wire                                cmd_modified_i;
  wire                                cmd_complete_wrap_i;
  wire                                cmd_packed_wrap_i;
  wire [C_M_AXI_BYTES_LOG-1:0]        cmd_first_word_ii;
  wire [C_M_AXI_BYTES_LOG-1:0]        cmd_first_word_i;
  wire [C_M_AXI_BYTES_LOG-1:0]        cmd_next_word_ii;
  wire [C_M_AXI_BYTES_LOG-1:0]        cmd_next_word_i;
  wire [C_M_AXI_BYTES_LOG:0]          cmd_last_word_ii;
  wire [C_M_AXI_BYTES_LOG-1:0]        cmd_last_word_i;
  wire [C_M_AXI_BYTES_LOG-1:0]        cmd_offset_i;
  reg  [C_M_AXI_BYTES_LOG-1:0]        cmd_mask_i;
  wire [3-1:0]                        cmd_size_i;
  wire [3-1:0]                        cmd_size;
  reg  [8-1:0]                        cmd_step_ii;
  wire [C_S_AXI_BYTES_LOG:0]          cmd_step_i;
  reg  [8-1:0]                        cmd_length_i;
  wire                                S_AXI_AREADY_I;
  reg  [C_AXI_ADDR_WIDTH-1:0]         M_AXI_AADDR_I;
  reg  [8-1:0]                        M_AXI_ALEN_I;
  reg  [3-1:0]                        M_AXI_ASIZE_I;
  reg  [2-1:0]                        M_AXI_ABURST_I;
  wire [2-1:0]                        M_AXI_ALOCK_I;
  wire [4-1:0]                        M_AXI_ACACHE_I;
  wire [3-1:0]                        M_AXI_APROT_I;
  wire [4-1:0]                        M_AXI_AREGION_I;
  wire [4-1:0]                        M_AXI_AQOS_I;
  wire                                M_AXI_AVALID_I;
  wire                                M_AXI_AREADY_I;
  assign cmd_si_addr  = S_AXI_AADDR;
  assign cmd_si_id    = C_SUPPORTS_ID ? S_AXI_AID : 1'b0;
  assign cmd_si_len   = S_AXI_ALEN;
  assign cmd_si_size  = S_AXI_ASIZE;
  assign cmd_si_burst = S_AXI_ABURST;
  assign access_is_fix          = ( S_AXI_ABURST == C_FIX_BURST );
  assign access_is_incr         = ( S_AXI_ABURST == C_INCR_BURST );
  assign access_is_wrap         = ( S_AXI_ABURST == C_WRAP_BURST );
  assign cmd_fix_i              = access_is_fix;
  assign access_is_modifiable   = S_AXI_ACACHE[1];
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: si_maximum_length = C_S_AXI_NATIVE_SIZE >= 3'b000 ? C_DOUBLE_LEN[ 8-C_M_AXI_BYTES_LOG +: 8] : 8'b0;
      3'b001: si_maximum_length = C_S_AXI_NATIVE_SIZE >= 3'b001 ? C_DOUBLE_LEN[ 9-C_M_AXI_BYTES_LOG +: 8] : 8'b0;
      3'b010: si_maximum_length = C_S_AXI_NATIVE_SIZE >= 3'b010 ? C_DOUBLE_LEN[10-C_M_AXI_BYTES_LOG +: 8] : 8'b0;
      3'b011: si_maximum_length = C_S_AXI_NATIVE_SIZE >= 3'b011 ? C_DOUBLE_LEN[11-C_M_AXI_BYTES_LOG +: 8] : 8'b0;
      3'b100: si_maximum_length = C_S_AXI_NATIVE_SIZE >= 3'b100 ? C_DOUBLE_LEN[12-C_M_AXI_BYTES_LOG +: 8] : 8'b0;
      3'b101: si_maximum_length = C_S_AXI_NATIVE_SIZE >= 3'b101 ? C_DOUBLE_LEN[13-C_M_AXI_BYTES_LOG +: 8] : 8'b0;
      3'b110: si_maximum_length = C_S_AXI_NATIVE_SIZE >= 3'b110 ? C_DOUBLE_LEN[14-C_M_AXI_BYTES_LOG +: 8] : 8'b0;
      3'b111: si_maximum_length = C_S_AXI_NATIVE_SIZE >= 3'b111 ? C_DOUBLE_LEN[15-C_M_AXI_BYTES_LOG +: 8] : 8'b0;
    endcase
  end
  assign mi_word_intra_len_complete = {S_AXI_ALEN, 8'b0};
  always @ *
  begin
      if ( ~cmd_fix_i ) begin
        case (S_AXI_ASIZE)
          3'b000: mi_word_intra_len = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                                      mi_word_intra_len_complete[8-0 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
          3'b001: mi_word_intra_len = C_S_AXI_NATIVE_SIZE >= 3'b001 ? 
                                      mi_word_intra_len_complete[8-1 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
          3'b010: mi_word_intra_len = C_S_AXI_NATIVE_SIZE >= 3'b010 ? 
                                      mi_word_intra_len_complete[8-2 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
          3'b011: mi_word_intra_len = C_S_AXI_NATIVE_SIZE >= 3'b011 ? 
                                      mi_word_intra_len_complete[8-3 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
          3'b100: mi_word_intra_len = C_S_AXI_NATIVE_SIZE >= 3'b100 ? 
                                      mi_word_intra_len_complete[8-4 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
          3'b101: mi_word_intra_len = C_S_AXI_NATIVE_SIZE >= 3'b101 ? 
                                      mi_word_intra_len_complete[8-5 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
          3'b110: mi_word_intra_len = C_S_AXI_NATIVE_SIZE >= 3'b110 ? 
                                      mi_word_intra_len_complete[8-6 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
          3'b111: mi_word_intra_len = C_S_AXI_NATIVE_SIZE >= 3'b111 ? 
                                      mi_word_intra_len_complete[8-7 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};  
        endcase
      end else begin
        mi_word_intra_len = {C_M_AXI_BYTES_LOG{1'b0}};
      end
  end
  always @ *
  begin
      if ( cmd_fix_i | ~cmd_modified_i ) begin
        upsized_length = S_AXI_ALEN;
      end else begin
        case (S_AXI_ASIZE)
          3'b000: upsized_length = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                                   (S_AXI_ALEN >> C_M_AXI_BYTES_LOG-0) : 8'b0;
          3'b001: upsized_length = C_S_AXI_NATIVE_SIZE >= 3'b001 ? 
                                   (S_AXI_ALEN >> C_M_AXI_BYTES_LOG-1) : 8'b0;
          3'b010: upsized_length = C_S_AXI_NATIVE_SIZE >= 3'b010 ? 
                                   (S_AXI_ALEN >> C_M_AXI_BYTES_LOG-2) : 8'b0;
          3'b011: upsized_length = C_S_AXI_NATIVE_SIZE >= 3'b011 ? 
                                   (S_AXI_ALEN >> C_M_AXI_BYTES_LOG-3) : 8'b0;
          3'b100: upsized_length = C_S_AXI_NATIVE_SIZE >= 3'b100 ? 
                                   (S_AXI_ALEN >> C_M_AXI_BYTES_LOG-4) : 8'b0;
          3'b101: upsized_length = C_S_AXI_NATIVE_SIZE >= 3'b101 ? 
                                   (S_AXI_ALEN >> C_M_AXI_BYTES_LOG-5) : 8'b0;
          3'b110: upsized_length = C_S_AXI_NATIVE_SIZE >= 3'b110 ? 
                                   (S_AXI_ALEN >> C_M_AXI_BYTES_LOG-6) : 8'b0;
          3'b111: upsized_length = C_S_AXI_NATIVE_SIZE >= 3'b111 ? 
                                   (S_AXI_ALEN                       ) : 8'b0;  
        endcase
      end
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: size_mask = ~C_DOUBLE_LEN[8 +: C_S_AXI_BYTES_LOG];
      3'b001: size_mask = ~C_DOUBLE_LEN[7 +: C_S_AXI_BYTES_LOG];
      3'b010: size_mask = ~C_DOUBLE_LEN[6 +: C_S_AXI_BYTES_LOG];
      3'b011: size_mask = ~C_DOUBLE_LEN[5 +: C_S_AXI_BYTES_LOG];
      3'b100: size_mask = ~C_DOUBLE_LEN[4 +: C_S_AXI_BYTES_LOG];
      3'b101: size_mask = ~C_DOUBLE_LEN[3 +: C_S_AXI_BYTES_LOG];
      3'b110: size_mask = ~C_DOUBLE_LEN[2 +: C_S_AXI_BYTES_LOG];
      3'b111: size_mask = ~C_DOUBLE_LEN[1 +: C_S_AXI_BYTES_LOG];  
    endcase
  end
  assign mask_help_vector = {4'b0, S_AXI_ALEN, 8'b1};
  always @ *
  begin
    if ( sub_sized_wrap ) begin
      case (S_AXI_ASIZE)
        3'b000: cmd_mask_i = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                             mask_help_vector[8-0 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
        3'b001: cmd_mask_i = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                             mask_help_vector[8-1 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
        3'b010: cmd_mask_i = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                             mask_help_vector[8-2 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
        3'b011: cmd_mask_i = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                             mask_help_vector[8-3 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
        3'b100: cmd_mask_i = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                             mask_help_vector[8-4 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
        3'b101: cmd_mask_i = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                             mask_help_vector[8-5 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
        3'b110: cmd_mask_i = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                             mask_help_vector[8-6 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};
        3'b111: cmd_mask_i = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                             mask_help_vector[8-7 +: C_M_AXI_BYTES_LOG] : {C_M_AXI_BYTES_LOG{1'b0}};  
      endcase
    end else begin
      cmd_mask_i = {C_M_AXI_BYTES_LOG{1'b1}};
    end
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: burst_mask = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                           mask_help_vector[8-0 +: C_BURST_BYTES_LOG] : {C_BURST_BYTES_LOG{1'b0}};
      3'b001: burst_mask = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                           mask_help_vector[8-1 +: C_BURST_BYTES_LOG] : {C_BURST_BYTES_LOG{1'b0}};
      3'b010: burst_mask = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                           mask_help_vector[8-2 +: C_BURST_BYTES_LOG] : {C_BURST_BYTES_LOG{1'b0}};
      3'b011: burst_mask = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                           mask_help_vector[8-3 +: C_BURST_BYTES_LOG] : {C_BURST_BYTES_LOG{1'b0}};
      3'b100: burst_mask = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                           mask_help_vector[8-4 +: C_BURST_BYTES_LOG] : {C_BURST_BYTES_LOG{1'b0}};
      3'b101: burst_mask = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                           mask_help_vector[8-5 +: C_BURST_BYTES_LOG] : {C_BURST_BYTES_LOG{1'b0}};
      3'b110: burst_mask = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                           mask_help_vector[8-6 +: C_BURST_BYTES_LOG] : {C_BURST_BYTES_LOG{1'b0}};
      3'b111: burst_mask = C_S_AXI_NATIVE_SIZE >= 3'b000 ? 
                           mask_help_vector[8-7 +: C_BURST_BYTES_LOG] : {C_BURST_BYTES_LOG{1'b0}};  
    endcase
  end
  assign cmd_size_i = S_AXI_ASIZE;
  assign access_is_unaligned = ( S_AXI_AADDR[0 +: C_M_AXI_BYTES_LOG] != {C_M_AXI_BYTES_LOG{1'b0}} );
  assign cmd_modified_i = ~access_is_fix &
                          ( ( C_PACKING_LEVEL == C_ALWAYS_PACK  ) | 
                            ( access_is_modifiable & ( S_AXI_ALEN != 8'b0 ) & ( C_PACKING_LEVEL == C_DEFAULT_PACK ) ) );
  assign sub_sized_wrap         = access_is_wrap & ( S_AXI_ALEN <= si_maximum_length );
  assign cmd_complete_wrap_i    = cmd_modified_i & sub_sized_wrap;
  assign cmd_packed_wrap_i      = cmd_modified_i & access_is_wrap & ( S_AXI_ALEN > si_maximum_length ) & 
                                  access_is_unaligned;
  assign cmd_first_word_ii      = S_AXI_AADDR[C_M_AXI_BYTES_LOG-1:0];
  assign cmd_first_word_i       = cmd_first_word_ii & cmd_mask_i & size_mask;
  assign cmd_next_word_ii       = cmd_first_word_ii + cmd_step_ii[C_M_AXI_BYTES_LOG-1:0];
  assign cmd_next_word_i        = cmd_next_word_ii & cmd_mask_i & size_mask;
  assign cmd_offset_i           = cmd_first_word_ii & ~cmd_mask_i;
  generate
    if ( C_FAMILY == "rtl" ) begin : USE_RTL_ADJUSTED_LEN
      assign cmd_last_word_ii       = cmd_first_word_i + mi_word_intra_len;
      assign cmd_last_word_i        = cmd_last_word_ii[C_M_AXI_BYTES_LOG-1:0] & cmd_mask_i & size_mask;
      assign access_need_extra_word = cmd_last_word_ii[C_M_AXI_BYTES_LOG] & 
                                      access_is_incr & cmd_modified_i;
      assign adjusted_length        = upsized_length + access_need_extra_word;
    end else begin : USE_FPGA_ADJUSTED_LEN
      wire [C_M_AXI_BYTES_LOG:0]          last_word_local_carry;
      wire [C_M_AXI_BYTES_LOG-1:0]        last_word_sel;
      wire [C_M_AXI_BYTES_LOG:0]          last_word_for_mask_local_carry;
      wire [C_M_AXI_BYTES_LOG-1:0]        last_word_for_mask_dummy_carry1;
      wire [C_M_AXI_BYTES_LOG-1:0]        last_word_for_mask_dummy_carry2;
      wire [C_M_AXI_BYTES_LOG-1:0]        last_word_for_mask_dummy_carry3;
      wire [C_M_AXI_BYTES_LOG-1:0]        last_word_for_mask_sel;
      wire [C_M_AXI_BYTES_LOG-1:0]        last_word_for_mask;
      wire [C_M_AXI_BYTES_LOG-1:0]        last_word_mask;
      wire                                sel_access_need_extra_word;
      wire [8:0]                          adjusted_length_local_carry;
      wire [8-1:0]                        adjusted_length_sel;
      assign last_word_local_carry[0] = 1'b0;
      assign last_word_for_mask_local_carry[0] = 1'b0;
      for (bit_cnt = 0; bit_cnt < C_M_AXI_BYTES_LOG ; bit_cnt = bit_cnt + 1) begin : LUT_LAST_MASK
        assign last_word_for_mask_sel[bit_cnt]  = cmd_first_word_ii[bit_cnt] ^ mi_word_intra_len[bit_cnt];
        assign last_word_mask[bit_cnt]          = cmd_mask_i[bit_cnt] & size_mask[bit_cnt];
        MUXCY and_inst1 
        (
         .O (last_word_for_mask_dummy_carry1[bit_cnt]), 
         .CI (last_word_for_mask_local_carry[bit_cnt]), 
         .DI (mi_word_intra_len[bit_cnt]), 
         .S (last_word_for_mask_sel[bit_cnt])
        ); 
        MUXCY and_inst2 
        (
         .O (last_word_for_mask_dummy_carry2[bit_cnt]), 
         .CI (last_word_for_mask_dummy_carry1[bit_cnt]), 
         .DI (1'b0), 
         .S (1'b1)
        ); 
        MUXCY and_inst3 
        (
         .O (last_word_for_mask_dummy_carry3[bit_cnt]), 
         .CI (last_word_for_mask_dummy_carry2[bit_cnt]), 
         .DI (1'b0), 
         .S (1'b1)
        ); 
        MUXCY and_inst4 
        (
         .O (last_word_for_mask_local_carry[bit_cnt+1]), 
         .CI (last_word_for_mask_dummy_carry3[bit_cnt]), 
         .DI (1'b0), 
         .S (1'b1)
        ); 
        XORCY xorcy_inst 
        (
         .O(last_word_for_mask[bit_cnt]),
         .CI(last_word_for_mask_local_carry[bit_cnt]),
         .LI(last_word_for_mask_sel[bit_cnt])
        );
        generic_baseblocks_v2_1_0_carry_latch_and #
          (
           .C_FAMILY(C_FAMILY)
           ) last_mask_inst
          (
           .CIN(last_word_for_mask[bit_cnt]),
           .I(last_word_mask[bit_cnt]),
           .O(cmd_last_word_i[bit_cnt])
           );
      end 
      for (bit_cnt = 0; bit_cnt < C_M_AXI_BYTES_LOG ; bit_cnt = bit_cnt + 1) begin : LUT_LAST
        assign last_word_sel[bit_cnt] = cmd_first_word_ii[bit_cnt] ^ mi_word_intra_len[bit_cnt];
        MUXCY and_inst 
        (
         .O (last_word_local_carry[bit_cnt+1]), 
         .CI (last_word_local_carry[bit_cnt]), 
         .DI (mi_word_intra_len[bit_cnt]), 
         .S (last_word_sel[bit_cnt])
        ); 
        XORCY xorcy_inst 
        (
         .O(cmd_last_word_ii[bit_cnt]),
         .CI(last_word_local_carry[bit_cnt]),
         .LI(last_word_sel[bit_cnt])
        );
      end 
      assign sel_access_need_extra_word = access_is_incr & cmd_modified_i;
      generic_baseblocks_v2_1_0_carry_and #
        (
         .C_FAMILY(C_FAMILY)
         ) access_need_extra_word_inst
        (
         .CIN(last_word_local_carry[C_M_AXI_BYTES_LOG]),
         .S(sel_access_need_extra_word),
         .COUT(adjusted_length_local_carry[0])
         );
      for (bit_cnt = 0; bit_cnt < 8 ; bit_cnt = bit_cnt + 1) begin : LUT_ADJUST
        assign adjusted_length_sel[bit_cnt] = ( upsized_length[bit_cnt] &  cmd_modified_i) |
                                              ( S_AXI_ALEN[bit_cnt]     & ~cmd_modified_i);
        MUXCY and_inst 
        (
         .O (adjusted_length_local_carry[bit_cnt+1]), 
         .CI (adjusted_length_local_carry[bit_cnt]), 
         .DI (1'b0), 
         .S (adjusted_length_sel[bit_cnt])
        ); 
        XORCY xorcy_inst 
        (
         .O(adjusted_length[bit_cnt]),
         .CI(adjusted_length_local_carry[bit_cnt]),
         .LI(adjusted_length_sel[bit_cnt])
        );
      end 
    end
  endgenerate
  assign wrap_addr_aligned      = ( C_AXI_CHANNEL != 0 ) ? 
                                  ( S_AXI_AADDR[0 +: C_BURST_BYTES_LOG] ) :
                                  ( S_AXI_AADDR[0 +: C_BURST_BYTES_LOG] + ( 2 ** C_M_AXI_BYTES_LOG ) );
  always @ *
  begin
    if ( cmd_modified_i ) begin
      if ( cmd_complete_wrap_i ) begin
        M_AXI_AADDR_I  = S_AXI_AADDR & {{C_MI_UNUSED_LOG{1'b1}}, ~cmd_mask_i};
        M_AXI_ABURST_I = C_INCR_BURST;
      end else begin
        if ( cmd_packed_wrap_i ) begin
            M_AXI_AADDR_I  = {S_AXI_AADDR[C_BURST_BYTES_LOG +: C_AXI_ADDR_WIDTH-C_BURST_BYTES_LOG], 
                              (S_AXI_AADDR[0 +: C_BURST_BYTES_LOG] & ~burst_mask) | (wrap_addr_aligned & burst_mask) } & 
                             {{C_MI_UNUSED_LOG{1'b1}}, ~cmd_mask_i};
        end else begin
          M_AXI_AADDR_I  = S_AXI_AADDR;
        end
        M_AXI_ABURST_I = S_AXI_ABURST;
      end
      M_AXI_ASIZE_I  = C_M_AXI_NATIVE_SIZE;
    end else begin
      M_AXI_AADDR_I  = S_AXI_AADDR;
      M_AXI_ASIZE_I  = S_AXI_ASIZE;
      M_AXI_ABURST_I = S_AXI_ABURST;
    end
    M_AXI_ALEN_I   = adjusted_length;
    cmd_length_i   = adjusted_length;
  end
  generate
    if ( C_FAMILY == "rtl" || ( C_SUPPORTS_ID == 0 ) ) begin : USE_RTL_AVALID
      assign M_AXI_AVALID_I = allow_new_cmd & S_AXI_AVALID;
    end else begin : USE_FPGA_AVALID
      wire sel_s_axi_avalid;
      assign sel_s_axi_avalid = S_AXI_AVALID & ~ARESET;
      generic_baseblocks_v2_1_0_carry_and #
        (
         .C_FAMILY(C_FAMILY)
         ) avalid_inst
        (
         .CIN(allow_new_cmd),
         .S(sel_s_axi_avalid),
         .COUT(M_AXI_AVALID_I)
         );
    end
  endgenerate
  assign M_AXI_ALOCK_I    = S_AXI_ALOCK;
  assign M_AXI_ACACHE_I   = S_AXI_ACACHE;
  assign M_AXI_APROT_I    = S_AXI_APROT;
  assign M_AXI_AREGION_I  = S_AXI_AREGION;
  assign M_AXI_AQOS_I     = S_AXI_AQOS;
  generate
    if ( C_ID_QUEUE != 0 ) begin : gen_id_queue
      generic_baseblocks_v2_1_0_command_fifo #
      (
       .C_FAMILY                    ("rtl"),
       .C_ENABLE_S_VALID_CARRY      (0),
       .C_ENABLE_REGISTERED_OUTPUT  (1),
       .C_FIFO_DEPTH_LOG            (C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH                (C_AXI_ID_WIDTH)
       ) 
       id_queue
      (
       .ACLK    (ACLK),
       .ARESET  (ARESET),
       .EMPTY   (),
       .S_MESG  (S_AXI_AID),
       .S_VALID (cmd_push),
       .S_READY (s_id_ready),
       .M_MESG  (cmd_id),
       .M_VALID (),
       .M_READY (cmd_id_ready)
       );
    end else begin : gen_no_id_queue
      assign cmd_id = 1'b0;
      assign s_id_ready = 1'b1;
    end
  endgenerate
      assign allow_new_cmd  = (~cmd_full & s_id_ready) | cmd_push_block;
      assign cmd_push       = M_AXI_AVALID_I & ~cmd_push_block;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      cmd_push_block <= 1'b0;
    end else begin
      cmd_push_block <= M_AXI_AVALID_I & ~M_AXI_AREADY_I;
    end
  end
  assign S_AXI_AREADY_I = M_AXI_AREADY_I & allow_new_cmd & ~ARESET;
  assign S_AXI_AREADY   = S_AXI_AREADY_I;
  always @ *
  begin
    case (cmd_size_i)
      3'b000: cmd_step_ii = 8'b00000001;
      3'b001: cmd_step_ii = 8'b00000010;
      3'b010: cmd_step_ii = 8'b00000100;
      3'b011: cmd_step_ii = 8'b00001000;
      3'b100: cmd_step_ii = 8'b00010000;
      3'b101: cmd_step_ii = 8'b00100000;
      3'b110: cmd_step_ii = 8'b01000000;
      3'b111: cmd_step_ii = 8'b10000000; 
    endcase
  end
  assign cmd_step_i = cmd_step_ii[C_S_AXI_BYTES_LOG:0];
  generate
  if (C_FIFO_MODE == 0) begin : GEN_CMD_QUEUE
      generic_baseblocks_v2_1_0_command_fifo #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_ENABLE_S_VALID_CARRY      (1),
       .C_ENABLE_REGISTERED_OUTPUT  (1),
       .C_FIFO_DEPTH_LOG            (C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH                (1+1+1+1+C_M_AXI_BYTES_LOG+C_M_AXI_BYTES_LOG+
                                     C_M_AXI_BYTES_LOG+C_M_AXI_BYTES_LOG+C_M_AXI_BYTES_LOG+C_S_AXI_BYTES_LOG+1+8)
       ) 
       cmd_queue
      (
       .ACLK    (ACLK),
       .ARESET  (ARESET),
       .EMPTY   (cmd_empty),
       .S_MESG  ({cmd_fix_i, cmd_modified_i, cmd_complete_wrap_i, cmd_packed_wrap_i, cmd_first_word_i, cmd_next_word_i, 
                  cmd_last_word_i, cmd_offset_i, cmd_mask_i, cmd_step_i, cmd_length_i}),
       .S_VALID (cmd_push),
       .S_READY (s_ready),
       .M_MESG  ({cmd_fix, cmd_modified, cmd_complete_wrap, cmd_packed_wrap, cmd_first_word, cmd_next_word, 
                  cmd_last_word, cmd_offset, cmd_mask, cmd_step, cmd_length}),
       .M_VALID (cmd_valid_i),
       .M_READY (cmd_ready)
       );
    assign cmd_full = ~s_ready;
    assign cmd_valid = cmd_valid_i;
  end else begin : NO_CMD_QUEUE
    reg [C_FIFO_DEPTH_LOG-1:0] cmd_cnt;
    always @ (posedge ACLK) begin
      if (ARESET) begin
        cmd_cnt <= 0;
      end else begin
        if (cmd_push & ~cmd_ready) begin
          cmd_cnt <= cmd_cnt + 1;
        end else if (~cmd_push & cmd_ready & |cmd_cnt) begin
          cmd_cnt <= cmd_cnt - 1;
        end
      end
    end
    assign cmd_full = &cmd_cnt;
    assign cmd_empty = cmd_cnt == 0;
    assign cmd_fix           = 1'b0 ;
    assign cmd_modified      = 1'b0 ;
    assign cmd_complete_wrap = 1'b0 ;
    assign cmd_packed_wrap   = 1'b0 ;
    assign cmd_first_word    = 0 ;
    assign cmd_next_word     = 0 ;
    assign cmd_last_word     = 0 ;
    assign cmd_offset        = 0 ;
    assign cmd_mask          = 0 ;
    assign cmd_step          = 0 ;
    assign cmd_length        = 0 ;
    assign cmd_valid = 1'b0;
  end
  endgenerate
  generate
    if ( C_M_AXI_REGISTER ) begin : USE_REGISTER
      reg  [C_AXI_ADDR_WIDTH-1:0]         M_AXI_AADDR_q;
      reg  [8-1:0]                        M_AXI_ALEN_q;
      reg  [3-1:0]                        M_AXI_ASIZE_q;
      reg  [2-1:0]                        M_AXI_ABURST_q;
      reg  [2-1:0]                        M_AXI_ALOCK_q;
      reg  [4-1:0]                        M_AXI_ACACHE_q;
      reg  [3-1:0]                        M_AXI_APROT_q;
      reg  [4-1:0]                        M_AXI_AREGION_q;
      reg  [4-1:0]                        M_AXI_AQOS_q;
      reg                                 M_AXI_AVALID_q;
      always @ (posedge ACLK) begin
        if (ARESET) begin
          M_AXI_AVALID_q    <= 1'b0;
        end else if ( M_AXI_AREADY_I ) begin
          M_AXI_AVALID_q    <= M_AXI_AVALID_I;
        end
        if ( M_AXI_AREADY_I ) begin
          M_AXI_AADDR_q     <= M_AXI_AADDR_I;
          M_AXI_ALEN_q      <= M_AXI_ALEN_I;
          M_AXI_ASIZE_q     <= M_AXI_ASIZE_I;
          M_AXI_ABURST_q    <= M_AXI_ABURST_I;
          M_AXI_ALOCK_q     <= M_AXI_ALOCK_I;
          M_AXI_ACACHE_q    <= M_AXI_ACACHE_I;
          M_AXI_APROT_q     <= M_AXI_APROT_I;
          M_AXI_AREGION_q   <= M_AXI_AREGION_I;
          M_AXI_AQOS_q      <= M_AXI_AQOS_I;
        end
      end
      assign M_AXI_AADDR      = M_AXI_AADDR_q;
      assign M_AXI_ALEN       = M_AXI_ALEN_q;
      assign M_AXI_ASIZE      = M_AXI_ASIZE_q;
      assign M_AXI_ABURST     = M_AXI_ABURST_q;
      assign M_AXI_ALOCK      = M_AXI_ALOCK_q;
      assign M_AXI_ACACHE     = M_AXI_ACACHE_q;
      assign M_AXI_APROT      = M_AXI_APROT_q;
      assign M_AXI_AREGION    = M_AXI_AREGION_q;
      assign M_AXI_AQOS       = M_AXI_AQOS_q;
      assign M_AXI_AVALID     = M_AXI_AVALID_q;
      assign M_AXI_AREADY_I = ( M_AXI_AVALID_q & M_AXI_AREADY) | ~M_AXI_AVALID_q;
    end else begin : NO_REGISTER
      assign M_AXI_AADDR    = M_AXI_AADDR_I;
      assign M_AXI_ALEN     = M_AXI_ALEN_I;
      assign M_AXI_ASIZE    = M_AXI_ASIZE_I;
      assign M_AXI_ABURST   = M_AXI_ABURST_I;
      assign M_AXI_ALOCK    = M_AXI_ALOCK_I;
      assign M_AXI_ACACHE   = M_AXI_ACACHE_I;
      assign M_AXI_APROT    = M_AXI_APROT_I;
      assign M_AXI_AREGION  = M_AXI_AREGION_I;
      assign M_AXI_AQOS     = M_AXI_AQOS_I;
      assign M_AXI_AVALID   = M_AXI_AVALID_I;
      assign M_AXI_AREADY_I = M_AXI_AREADY;
    end
  endgenerate
endmodule
