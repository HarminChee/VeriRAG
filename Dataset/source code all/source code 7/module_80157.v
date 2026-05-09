`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_dwidth_converter_v2_1_a_downsizer #
  (
   parameter         C_FAMILY                         = "none", 
   parameter integer C_AXI_PROTOCOL = 0,         
   parameter integer C_AXI_ID_WIDTH                   = 1, 
   parameter integer C_SUPPORTS_ID                    = 0, 
   parameter integer C_AXI_ADDR_WIDTH                 = 32, 
   parameter integer C_S_AXI_DATA_WIDTH               = 64,
   parameter integer C_M_AXI_DATA_WIDTH               = 32,
   parameter integer C_AXI_CHANNEL                    = 0,
   parameter integer C_MAX_SPLIT_BEATS              = 256,
   parameter integer C_MAX_SPLIT_BEATS_LOG            = 8,
   parameter integer C_S_AXI_BYTES_LOG                = 3,
   parameter integer C_M_AXI_BYTES_LOG                = 2,
   parameter integer C_RATIO_LOG                      = 1
   )
  (
   input  wire                                                    ARESET,
   input  wire                                                    ACLK,
   output wire                              cmd_valid,
   output wire                              cmd_split,
   output wire                              cmd_mirror,
   output wire                              cmd_fix,
   output wire [C_S_AXI_BYTES_LOG-1:0]      cmd_first_word, 
   output wire [C_S_AXI_BYTES_LOG-1:0]      cmd_offset,
   output wire [C_S_AXI_BYTES_LOG-1:0]      cmd_mask,
   output wire [C_M_AXI_BYTES_LOG:0]        cmd_step,
   output wire [3-1:0]                      cmd_size,
   output wire [8-1:0]                      cmd_length,
   input  wire                              cmd_ready,
   output wire [C_AXI_ID_WIDTH-1:0]         cmd_id,
   output wire                              cmd_b_valid,
   output wire                              cmd_b_split,
   output wire [8-1:0]                      cmd_b_repeat,
   input  wire                              cmd_b_ready,
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
  localparam [C_AXI_ADDR_WIDTH+8-1:0]      C_DOUBLE_LEN = {{C_AXI_ADDR_WIDTH{1'b0}}, 8'b1111_1111};
  localparam [2-1:0] C_FIX_BURST         = 2'b00;
  localparam [2-1:0] C_INCR_BURST        = 2'b01;
  localparam [2-1:0] C_WRAP_BURST        = 2'b10;
  localparam integer C_FIFO_DEPTH_LOG    = 5;
  wire                                access_is_fix;
  wire                                access_is_incr;
  wire                                access_is_wrap;
  wire [C_AXI_ADDR_WIDTH+16-1:0]      alen_help_vector;
  reg  [C_S_AXI_BYTES_LOG-1:0]        size_mask;
  reg  [C_AXI_ADDR_WIDTH-1:0]         split_addr_mask;
  reg  [C_S_AXI_BYTES_LOG+8-1:0]      full_downsized_len;
  wire [8-1:0]                        downsized_len;
  reg                                 legal_wrap_len;
  reg  [8-1:0]                        fix_len;
  reg  [8-1:0]                        unalignment_addr;
  reg  [C_AXI_ADDR_WIDTH-1:0]         burst_mask;
  wire [C_AXI_ADDR_WIDTH-1:0]         masked_addr;
  wire [C_AXI_ADDR_WIDTH-1:0]         burst_unalignment;
  wire [8-1:0]                        wrap_unaligned_len;
  reg  [8-1:0]                        wrap_rest_len;
  wire [C_S_AXI_BYTES_LOG+8-1:0]      num_transactions;
  wire                                access_fit_mi_side;
  wire                                si_full_size;
  wire                                fix_need_to_split;
  wire                                incr_need_to_split;
  wire                                wrap_need_to_split;
  wire [C_AXI_ADDR_WIDTH-1:0]         pre_mi_addr;
  reg  [C_AXI_ADDR_WIDTH-1:0]         next_mi_addr;
  reg                                 split_ongoing;
  reg  [8-1:0]                        pushed_commands;
  wire                                need_to_split;
  reg                                 access_is_fix_q;
  reg                                 access_is_incr_q;
  reg                                 access_is_wrap_q;
  reg                                 access_fit_mi_side_q;
  reg                                 legal_wrap_len_q;
  reg                                 si_full_size_q;
  reg                                 fix_need_to_split_q;
  reg                                 incr_need_to_split_q;
  reg                                 wrap_need_to_split_q;
  wire                                need_to_split_q;
  reg  [C_AXI_ADDR_WIDTH-1:0]         split_addr_mask_q;
  reg  [C_S_AXI_BYTES_LOG+8-1:0]      num_transactions_q;
  reg  [8-1:0]                        wrap_unaligned_len_q;
  reg  [C_S_AXI_BYTES_LOG-1:0]        size_mask_q;
  reg  [8-1:0]                        downsized_len_q;
  reg  [8-1:0]                        fix_len_q;
  reg  [8-1:0]                        unalignment_addr_q;
  reg  [C_AXI_ADDR_WIDTH-1:0]         masked_addr_q;
  reg  [C_FIFO_DEPTH_LOG:0]           cmd_depth;
  reg                                 cmd_empty;
  reg  [C_AXI_ID_WIDTH-1:0]           queue_id;
  wire                                id_match;
  wire                                cmd_id_check;
  wire                                cmd_id_check_empty;
  wire                                s_ready;
  wire                                cmd_full;
  wire                                allow_new_cmd;
  wire                                cmd_push;
  reg                                 cmd_push_block;
  reg  [C_FIFO_DEPTH_LOG:0]           cmd_b_depth;
  reg                                 cmd_b_empty_i;
  wire                                cmd_b_empty;
  wire                                cmd_b_full;
  wire                                cmd_b_push;
  reg                                 cmd_b_push_block;
  wire                                pushed_new_cmd;
  wire                                last_fix_split;
  wire                                last_incr_split;
  wire                                last_wrap_split;
  wire                                last_split;
  wire                                cmd_valid_i;
  wire                                cmd_fix_i;
  wire                                cmd_split_i;
  wire                                cmd_mirror_i;
  reg  [C_S_AXI_BYTES_LOG-1:0]        cmd_first_word_ii;
  wire [C_S_AXI_BYTES_LOG-1:0]        cmd_first_word_i;
  wire [C_S_AXI_BYTES_LOG-1:0]        cmd_offset_i;
  reg  [C_S_AXI_BYTES_LOG-1:0]        cmd_mask_i;
  reg  [C_S_AXI_BYTES_LOG-1:0]        cmd_mask_q;
  reg  [3-1:0]                        cmd_size_i;
  wire [3-1:0]                        cmd_size_ii;
  reg  [7-1:0]                        cmd_step_i;
  wire [8-1:0]                        cmd_length_i;
  reg  [8-1:0]                        base_len;
  reg  [8-1:0]                        compensation_len;
  wire                                cmd_b_split_i;
  reg  [8-1:0]                        cmd_b_repeat_i;
  wire                                mi_stalling;
  reg                                 command_ongoing;
  reg  [C_AXI_ID_WIDTH-1:0]           S_AXI_AID_Q;
  reg  [C_AXI_ADDR_WIDTH-1:0]         S_AXI_AADDR_Q;
  reg  [8-1:0]                        S_AXI_ALEN_Q;
  reg  [3-1:0]                        S_AXI_ASIZE_Q;
  reg  [2-1:0]                        S_AXI_ABURST_Q;
  reg  [2-1:0]                        S_AXI_ALOCK_Q;
  reg  [4-1:0]                        S_AXI_ACACHE_Q;
  reg  [3-1:0]                        S_AXI_APROT_Q;
  reg  [4-1:0]                        S_AXI_AREGION_Q;
  reg  [4-1:0]                        S_AXI_AQOS_Q;
  reg                                 S_AXI_AREADY_I;
  reg  [C_AXI_ADDR_WIDTH-1:0]         M_AXI_AADDR_I;
  wire [8-1:0]                        M_AXI_ALEN_I;
  reg  [3-1:0]                        M_AXI_ASIZE_I;
  reg  [2-1:0]                        M_AXI_ABURST_I;
  reg  [2-1:0]                        M_AXI_ALOCK_I;
  wire [4-1:0]                        M_AXI_ACACHE_I;
  wire [3-1:0]                        M_AXI_APROT_I;
  wire [4-1:0]                        M_AXI_AREGION_I;
  wire [4-1:0]                        M_AXI_AQOS_I;
  wire                                M_AXI_AVALID_I;
  wire                                M_AXI_AREADY_I;
  reg [1:0] areset_d; 
  always @(posedge ACLK) begin
    areset_d <= {areset_d[0], ARESET};
  end
  always @ (posedge ACLK) begin
    if ( S_AXI_AREADY_I ) begin
      S_AXI_AID_Q     <= S_AXI_AID;
      S_AXI_AADDR_Q   <= S_AXI_AADDR;
      S_AXI_ALEN_Q    <= S_AXI_ALEN;
      S_AXI_ASIZE_Q   <= S_AXI_ASIZE;
      S_AXI_ABURST_Q  <= S_AXI_ABURST;
      S_AXI_ALOCK_Q   <= S_AXI_ALOCK;
      S_AXI_ACACHE_Q  <= S_AXI_ACACHE;
      S_AXI_APROT_Q   <= S_AXI_APROT;
      S_AXI_AREGION_Q <= S_AXI_AREGION;
      S_AXI_AQOS_Q    <= S_AXI_AQOS;
    end
  end
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      access_is_fix_q       <= 1'b0;
      access_is_incr_q      <= 1'b0;
      access_is_wrap_q      <= 1'b0;
      access_fit_mi_side_q  <= 1'b0;
      legal_wrap_len_q      <= 1'b0;
      si_full_size_q        <= 1'b0;
      fix_need_to_split_q   <= 1'b0;
      incr_need_to_split_q  <= 1'b0;
      wrap_need_to_split_q  <= 1'b0;
      split_addr_mask_q     <= {C_AXI_ADDR_WIDTH{1'b0}};
      num_transactions_q    <= {(C_S_AXI_BYTES_LOG+8){1'b0}};
      wrap_unaligned_len_q  <= 8'b0;
      cmd_mask_q            <= {C_S_AXI_BYTES_LOG{1'b0}};
      size_mask_q           <= {C_S_AXI_BYTES_LOG{1'b0}};
      downsized_len_q       <= 8'b0;
      fix_len_q             <= 8'b0;
      unalignment_addr_q    <= 8'b0;
      masked_addr_q         <= {C_AXI_ADDR_WIDTH{1'b0}};
    end else begin
      if ( S_AXI_AREADY_I ) begin
        access_is_fix_q       <= access_is_fix;
        access_is_incr_q      <= access_is_incr;
        access_is_wrap_q      <= access_is_wrap;
        access_fit_mi_side_q  <= access_fit_mi_side;
        legal_wrap_len_q      <= legal_wrap_len;
        si_full_size_q        <= si_full_size;
        fix_need_to_split_q   <= fix_need_to_split;
        incr_need_to_split_q  <= incr_need_to_split;
        wrap_need_to_split_q  <= wrap_need_to_split;
        split_addr_mask_q     <= split_addr_mask;
        num_transactions_q    <= num_transactions;
        wrap_unaligned_len_q  <= wrap_unaligned_len;
        cmd_mask_q            <= cmd_mask_i;
        size_mask_q           <= size_mask;
        downsized_len_q       <= downsized_len;
        fix_len_q             <= fix_len;
        unalignment_addr_q    <= unalignment_addr;
        masked_addr_q         <= masked_addr;
      end
    end
  end
  assign access_is_fix   = ( S_AXI_ABURST == C_FIX_BURST );
  assign access_is_incr  = ( S_AXI_ABURST == C_INCR_BURST );
  assign access_is_wrap  = ( S_AXI_ABURST == C_WRAP_BURST );
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: size_mask = ~C_DOUBLE_LEN[8 +: C_M_AXI_BYTES_LOG]; 
      3'b001: size_mask = ~C_DOUBLE_LEN[7 +: C_M_AXI_BYTES_LOG]; 
      3'b010: size_mask = ~C_DOUBLE_LEN[6 +: C_M_AXI_BYTES_LOG]; 
      3'b011: size_mask = ~C_DOUBLE_LEN[5 +: C_M_AXI_BYTES_LOG]; 
      3'b100: size_mask = ~C_DOUBLE_LEN[4 +: C_M_AXI_BYTES_LOG]; 
      3'b101: size_mask = ~C_DOUBLE_LEN[3 +: C_M_AXI_BYTES_LOG]; 
      3'b110: size_mask = ~C_DOUBLE_LEN[2 +: C_M_AXI_BYTES_LOG]; 
      3'b111: size_mask = ~C_DOUBLE_LEN[1 +: C_M_AXI_BYTES_LOG]; 
    endcase
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: split_addr_mask = ~C_DOUBLE_LEN[8 +: C_AXI_ADDR_WIDTH]; 
      3'b001: split_addr_mask = ~C_DOUBLE_LEN[7 +: C_AXI_ADDR_WIDTH]; 
      3'b010: split_addr_mask = ~C_DOUBLE_LEN[6 +: C_AXI_ADDR_WIDTH]; 
      3'b011: split_addr_mask = ~C_DOUBLE_LEN[5 +: C_AXI_ADDR_WIDTH]; 
      3'b100: split_addr_mask = ~C_DOUBLE_LEN[4 +: C_AXI_ADDR_WIDTH]; 
      3'b101: split_addr_mask = ~C_DOUBLE_LEN[3 +: C_AXI_ADDR_WIDTH]; 
      3'b110: split_addr_mask = ~C_DOUBLE_LEN[2 +: C_AXI_ADDR_WIDTH]; 
      3'b111: split_addr_mask = ~C_DOUBLE_LEN[1 +: C_AXI_ADDR_WIDTH]; 
    endcase
  end
  assign alen_help_vector = {{C_AXI_ADDR_WIDTH-8{1'b0}}, S_AXI_ALEN, 8'hFF}; 
  always @ *
  begin
    if ( access_is_wrap ) begin
      case (S_AXI_ASIZE)
        3'b000: cmd_mask_i  = alen_help_vector[8-0 +: C_S_AXI_BYTES_LOG]; 
        3'b001: cmd_mask_i  = alen_help_vector[8-1 +: C_S_AXI_BYTES_LOG]; 
        3'b010: cmd_mask_i  = alen_help_vector[8-2 +: C_S_AXI_BYTES_LOG]; 
        3'b011: cmd_mask_i  = alen_help_vector[8-3 +: C_S_AXI_BYTES_LOG]; 
        3'b100: cmd_mask_i  = alen_help_vector[8-4 +: C_S_AXI_BYTES_LOG]; 
        3'b101: cmd_mask_i  = alen_help_vector[8-5 +: C_S_AXI_BYTES_LOG]; 
        3'b110: cmd_mask_i  = alen_help_vector[8-6 +: C_S_AXI_BYTES_LOG]; 
        3'b111: cmd_mask_i  = alen_help_vector[8-7 +: C_S_AXI_BYTES_LOG]; 
      endcase
    end else begin
      cmd_mask_i          = {C_S_AXI_BYTES_LOG{1'b1}};
    end
  end
  always @ *
  begin
    if ( access_fit_mi_side ) begin
      full_downsized_len = alen_help_vector[8-0 +: C_S_AXI_BYTES_LOG + 8]; 
    end else begin
      case (S_AXI_ASIZE)
        3'b000: full_downsized_len = alen_help_vector[8+C_M_AXI_BYTES_LOG-0 +: C_S_AXI_BYTES_LOG + 8];  
        3'b001: full_downsized_len = alen_help_vector[8+C_M_AXI_BYTES_LOG-1 +: C_S_AXI_BYTES_LOG + 8];  
        3'b010: full_downsized_len = alen_help_vector[8+C_M_AXI_BYTES_LOG-2 +: C_S_AXI_BYTES_LOG + 8];  
        3'b011: full_downsized_len = alen_help_vector[8+C_M_AXI_BYTES_LOG-3 +: C_S_AXI_BYTES_LOG + 8];  
        3'b100: full_downsized_len = alen_help_vector[8+C_M_AXI_BYTES_LOG-4 +: C_S_AXI_BYTES_LOG + 8];  
        3'b101: full_downsized_len = alen_help_vector[8+C_M_AXI_BYTES_LOG-5 +: C_S_AXI_BYTES_LOG + 8];  
        3'b110: full_downsized_len = alen_help_vector[8+C_M_AXI_BYTES_LOG-6 +: C_S_AXI_BYTES_LOG + 8];  
        3'b111: full_downsized_len = alen_help_vector[8+C_M_AXI_BYTES_LOG-7 +: C_S_AXI_BYTES_LOG + 8];  
      endcase
    end
  end
  assign downsized_len = full_downsized_len[C_MAX_SPLIT_BEATS_LOG-1:0];
  always @ *
  begin
    if ( access_fit_mi_side ) begin
      legal_wrap_len = 1'b1;
    end else begin
      case (S_AXI_ASIZE)
        3'b000: legal_wrap_len = 1'b1;  
        3'b001: legal_wrap_len = 1'b1;  
        3'b010: legal_wrap_len = 1'b1;  
        3'b011: legal_wrap_len = S_AXI_ALEN < ( 16 * (2 ** C_M_AXI_NATIVE_SIZE) / (2 ** 3) );
        3'b100: legal_wrap_len = S_AXI_ALEN < ( 16 * (2 ** C_M_AXI_NATIVE_SIZE) / (2 ** 4) );
        3'b101: legal_wrap_len = S_AXI_ALEN < ( 16 * (2 ** C_M_AXI_NATIVE_SIZE) / (2 ** 5) );
        3'b110: legal_wrap_len = S_AXI_ALEN < ( 16 * (2 ** C_M_AXI_NATIVE_SIZE) / (2 ** 6) );
        3'b111: legal_wrap_len = S_AXI_ALEN < ( 16 * (2 ** C_M_AXI_NATIVE_SIZE) / (2 ** 7) );
      endcase
    end
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: fix_len = ( 8'h00 >> C_M_AXI_BYTES_LOG ); 
      3'b001: fix_len = ( 8'h01 >> C_M_AXI_BYTES_LOG ); 
      3'b010: fix_len = ( 8'h03 >> C_M_AXI_BYTES_LOG ); 
      3'b011: fix_len = ( 8'h07 >> C_M_AXI_BYTES_LOG ); 
      3'b100: fix_len = ( 8'h0F >> C_M_AXI_BYTES_LOG ); 
      3'b101: fix_len = ( 8'h1F >> C_M_AXI_BYTES_LOG ); 
      3'b110: fix_len = ( 8'h3F >> C_M_AXI_BYTES_LOG ); 
      3'b111: fix_len = ( 8'h7F >> C_M_AXI_BYTES_LOG ); 
    endcase
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: unalignment_addr  = 8'b0;
      3'b001: unalignment_addr  = {7'b0, ( S_AXI_AADDR[0 +: 1] >> C_M_AXI_BYTES_LOG )};
      3'b010: unalignment_addr  = {6'b0, ( S_AXI_AADDR[0 +: 2] >> C_M_AXI_BYTES_LOG )};
      3'b011: unalignment_addr  = {5'b0, ( S_AXI_AADDR[0 +: 3] >> C_M_AXI_BYTES_LOG )};
      3'b100: unalignment_addr  = {4'b0, ( S_AXI_AADDR[0 +: 4] >> C_M_AXI_BYTES_LOG )};
      3'b101: unalignment_addr  = {3'b0, ( S_AXI_AADDR[0 +: 5] >> C_M_AXI_BYTES_LOG )};
      3'b110: unalignment_addr  = {2'b0, ( S_AXI_AADDR[0 +: 6] >> C_M_AXI_BYTES_LOG )};
      3'b111: unalignment_addr  = {1'b0, ( S_AXI_AADDR[0 +: 7] >> C_M_AXI_BYTES_LOG )};
    endcase
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: burst_mask  = alen_help_vector[8-0 +: C_AXI_ADDR_WIDTH]; 
      3'b001: burst_mask  = alen_help_vector[8-1 +: C_AXI_ADDR_WIDTH]; 
      3'b010: burst_mask  = alen_help_vector[8-2 +: C_AXI_ADDR_WIDTH]; 
      3'b011: burst_mask  = alen_help_vector[8-3 +: C_AXI_ADDR_WIDTH]; 
      3'b100: burst_mask  = alen_help_vector[8-4 +: C_AXI_ADDR_WIDTH]; 
      3'b101: burst_mask  = alen_help_vector[8-5 +: C_AXI_ADDR_WIDTH]; 
      3'b110: burst_mask  = alen_help_vector[8-6 +: C_AXI_ADDR_WIDTH]; 
      3'b111: burst_mask  = alen_help_vector[8-7 +: C_AXI_ADDR_WIDTH]; 
    endcase
  end
  assign masked_addr        = ( S_AXI_AADDR & ~burst_mask );
  assign burst_unalignment  = ( ( S_AXI_AADDR & burst_mask ) >> C_M_AXI_BYTES_LOG );
  assign wrap_unaligned_len = burst_unalignment[0 +: 8];
  assign num_transactions   = full_downsized_len >> C_MAX_SPLIT_BEATS_LOG;
  assign access_fit_mi_side = ( S_AXI_ASIZE <= C_M_AXI_NATIVE_SIZE );
  assign si_full_size       = ( S_AXI_ASIZE == C_S_AXI_NATIVE_SIZE );
  assign fix_need_to_split  = access_is_fix & ~access_fit_mi_side &
                              ( C_MAX_SPLIT_BEATS > 0 );
  assign incr_need_to_split = access_is_incr & ( num_transactions != 0 ) &
                              ( C_MAX_SPLIT_BEATS > 0 );
  assign wrap_need_to_split = access_is_wrap &
                              (~access_fit_mi_side & ~legal_wrap_len & ( wrap_unaligned_len != 0 )) &
                              ( C_MAX_SPLIT_BEATS > 0 );
  assign need_to_split_q    = ( fix_need_to_split_q | incr_need_to_split_q | wrap_need_to_split_q );
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      split_ongoing     <= 1'b0;
    end else begin
      if ( pushed_new_cmd ) begin
        split_ongoing     <= need_to_split_q & ~last_split;
      end
    end
  end
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      pushed_commands <= 8'b0;
    end else begin
      if ( S_AXI_AREADY_I ) begin
        pushed_commands <= 8'b0;
      end else if ( pushed_new_cmd ) begin
        pushed_commands <= pushed_commands + 8'b1;
      end
    end
  end
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      wrap_rest_len <= 8'b0;
    end else begin
      wrap_rest_len <= wrap_unaligned_len_q - 8'b1;
    end
  end
  assign last_fix_split     = access_is_fix_q & ( ~fix_need_to_split_q | 
                                                ( fix_need_to_split_q & ( S_AXI_ALEN_Q[0 +: 4] == pushed_commands ) ) );
  assign last_incr_split    = access_is_incr_q & ( num_transactions_q   == pushed_commands );
  assign last_wrap_split    = access_is_wrap_q & ( ~wrap_need_to_split_q |
                                                 ( wrap_need_to_split_q & split_ongoing) );
  assign last_split         = last_fix_split | last_incr_split | last_wrap_split |
                              ( C_MAX_SPLIT_BEATS == 0 );
  assign cmd_fix_i          = access_is_fix_q & access_fit_mi_side_q;
  assign cmd_split_i        = need_to_split_q & ~last_split;
  assign cmd_b_split_i      = need_to_split_q & ~last_split;
  assign cmd_mirror_i       = ( access_fit_mi_side_q );
  always @ *
  begin
    if ( (split_ongoing & access_is_incr_q & si_full_size_q) | (split_ongoing & access_is_wrap_q) ) begin
      cmd_first_word_ii = {C_S_AXI_BYTES_LOG{1'b0}};
    end else if ( split_ongoing & access_is_incr_q ) begin
      cmd_first_word_ii = S_AXI_AADDR_Q[C_S_AXI_BYTES_LOG-1:0] & split_addr_mask_q[C_S_AXI_BYTES_LOG-1:0];
    end else begin
      cmd_first_word_ii = S_AXI_AADDR_Q[C_S_AXI_BYTES_LOG-1:0];
    end
  end
  assign cmd_first_word_i   = cmd_first_word_ii & cmd_mask_q & size_mask_q;
  assign cmd_offset_i       = cmd_first_word_ii & ~cmd_mask_q;
  assign pre_mi_addr        = ( M_AXI_AADDR_I & split_addr_mask_q & {{C_AXI_ADDR_WIDTH-C_M_AXI_BYTES_LOG{1'b1}}, {C_M_AXI_BYTES_LOG{1'b0}}} );
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      next_mi_addr  = {C_AXI_ADDR_WIDTH{1'b0}};
    end else if ( pushed_new_cmd ) begin
      next_mi_addr  = pre_mi_addr + ( C_MAX_SPLIT_BEATS << C_M_AXI_BYTES_LOG );
    end
  end
  always @ *
  begin
    if ( fix_need_to_split_q ) begin
      cmd_b_repeat_i = {4'b0, S_AXI_ALEN_Q[0 +: 4]};
    end else if ( incr_need_to_split_q ) begin
      cmd_b_repeat_i = num_transactions_q;
    end else if ( wrap_need_to_split_q ) begin
      cmd_b_repeat_i = 8'b1;
    end else begin
      cmd_b_repeat_i = 8'b0;
    end
  end
  always @ *
  begin
    if ( split_ongoing & access_is_incr_q ) begin
      M_AXI_AADDR_I = next_mi_addr;
    end else if ( split_ongoing & access_is_wrap_q ) begin
      M_AXI_AADDR_I = masked_addr_q;
    end else begin
      M_AXI_AADDR_I = S_AXI_AADDR_Q;
    end
  end
  always @ *
  begin
    if ( access_fit_mi_side_q ) begin
      base_len = S_AXI_ALEN_Q;
    end else if ( ( access_is_wrap_q & legal_wrap_len_q ) | ( access_is_incr_q & ~incr_need_to_split_q ) |
                  ( access_is_wrap_q & ~split_ongoing ) | ( access_is_incr_q & incr_need_to_split_q & last_split ) ) begin
      base_len = downsized_len_q;
    end else if ( fix_need_to_split_q ) begin
      base_len = fix_len_q;
    end else if ( access_is_wrap_q & split_ongoing ) begin
      base_len = wrap_rest_len;
    end else begin
      base_len = C_MAX_SPLIT_BEATS-1; 
    end
  end
  always @ *
  begin
    if ( wrap_need_to_split_q & ~split_ongoing ) begin
      compensation_len = wrap_unaligned_len_q;
    end else if ( ( incr_need_to_split_q & ~split_ongoing ) | 
                  ( access_is_incr_q & ~incr_need_to_split_q & ~access_fit_mi_side_q ) |
                  ( fix_need_to_split_q ) ) begin
      compensation_len = unalignment_addr_q;
    end else begin
      compensation_len = 8'b0;
    end
  end
  assign cmd_length_i = base_len - compensation_len; 
  assign M_AXI_ALEN_I = cmd_length_i;
  always @ *
  begin
    if ( ~access_fit_mi_side_q ) begin
      M_AXI_ASIZE_I  = C_M_AXI_NATIVE_SIZE;
      if ( access_is_fix_q | (access_is_wrap_q & ~legal_wrap_len_q) ) begin
        M_AXI_ABURST_I = C_INCR_BURST;
      end else begin
        M_AXI_ABURST_I = S_AXI_ABURST_Q;
      end
      cmd_size_i     = C_M_AXI_NATIVE_SIZE;
    end else begin
      M_AXI_ASIZE_I  = S_AXI_ASIZE_Q;
      M_AXI_ABURST_I = S_AXI_ABURST_Q;
      cmd_size_i     = S_AXI_ASIZE_Q;
    end
  end
  always @ *
  begin
    if ( need_to_split_q ) begin
      M_AXI_ALOCK_I = {S_AXI_ALOCK_Q[1], 1'b0};
    end else begin
      M_AXI_ALOCK_I = S_AXI_ALOCK_Q;
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      command_ongoing <= 1'b0;
      S_AXI_AREADY_I <= 1'b0;
    end else begin
      if (areset_d == 2'b10) begin
        S_AXI_AREADY_I <= 1'b1;
      end else begin
        if ( S_AXI_AVALID & S_AXI_AREADY_I ) begin
          command_ongoing <= 1'b1;
          S_AXI_AREADY_I <= 1'b0;
        end else if ( pushed_new_cmd & last_split ) begin
          command_ongoing <= 1'b0;
          S_AXI_AREADY_I <= 1'b1;
        end 
      end
    end
  end
  assign S_AXI_AREADY   = S_AXI_AREADY_I;
  assign M_AXI_AVALID_I = allow_new_cmd & command_ongoing;
  assign mi_stalling    = M_AXI_AVALID_I & ~M_AXI_AREADY_I;
  assign M_AXI_ACACHE_I   = S_AXI_ACACHE_Q;
  assign M_AXI_APROT_I    = S_AXI_APROT_Q;
  assign M_AXI_AREGION_I  = S_AXI_AREGION_Q;
  assign M_AXI_AQOS_I     = S_AXI_AQOS_Q;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      queue_id <= {C_AXI_ID_WIDTH{1'b0}};
    end else begin
      if ( cmd_push ) begin
        queue_id <= S_AXI_AID_Q;
      end
    end
  end
  assign cmd_id = queue_id;  
  assign id_match       = ( C_SUPPORTS_ID == 0 ) | ( queue_id == S_AXI_AID_Q);
  assign cmd_id_check_empty = (C_AXI_CHANNEL == 0) ? cmd_b_empty : cmd_empty;
  assign cmd_id_check   = cmd_id_check_empty | id_match;
  assign allow_new_cmd  = (~cmd_full & ~cmd_b_full & cmd_id_check) | cmd_push_block;
  assign cmd_push       = M_AXI_AVALID_I & ~cmd_push_block;
  assign cmd_b_push     = M_AXI_AVALID_I & ~cmd_b_push_block & (C_AXI_CHANNEL == 0);
  always @ (posedge ACLK) begin
    if (ARESET) begin
      cmd_push_block <= 1'b0;
    end else begin
      if ( pushed_new_cmd ) begin
        cmd_push_block <= 1'b0;
      end else if ( cmd_push & mi_stalling ) begin
        cmd_push_block <= 1'b1;
      end 
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      cmd_b_push_block <= 1'b0;
    end else begin
      if ( S_AXI_AREADY_I ) begin
        cmd_b_push_block <= 1'b0;
      end else if ( cmd_b_push ) begin
        cmd_b_push_block <= 1'b1;
      end 
    end
  end
  assign pushed_new_cmd = M_AXI_AVALID_I & M_AXI_AREADY_I;
  axi_data_fifo_v2_1_axic_fifo #
  (
   .C_FAMILY(C_FAMILY),
   .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
   .C_FIFO_WIDTH(1+1+1+C_S_AXI_BYTES_LOG+C_S_AXI_BYTES_LOG+C_S_AXI_BYTES_LOG+3+8+3),
   .C_FIFO_TYPE("lut")
   ) 
   cmd_queue
  (
   .ACLK(ACLK),
   .ARESET(ARESET),
   .S_MESG({cmd_fix_i, cmd_split_i, cmd_mirror_i, cmd_first_word_i, 
            cmd_offset_i, cmd_mask_q, cmd_size_i, cmd_length_i, S_AXI_ASIZE_Q}),
   .S_VALID(cmd_push),
   .S_READY(s_ready),
   .M_MESG({cmd_fix, cmd_split, cmd_mirror, cmd_first_word,  
            cmd_offset, cmd_mask, cmd_size_ii, cmd_length, cmd_size}),
   .M_VALID(cmd_valid_i),
   .M_READY(cmd_ready)
   );
  assign cmd_full   = ~s_ready;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      cmd_empty <= 1'b1;
      cmd_depth <= {C_FIFO_DEPTH_LOG+1{1'b0}};
    end else begin
      if ( cmd_push & ~cmd_ready ) begin
        cmd_depth <= cmd_depth + 1'b1;
        cmd_empty <= 1'b0;
      end else if ( ~cmd_push & cmd_ready ) begin
        cmd_depth <= cmd_depth - 1'b1;
        cmd_empty <= ( cmd_depth == 1 );
      end
    end
  end
  assign cmd_valid  = cmd_valid_i;
  always @ *
  begin
    case (cmd_size_ii)
      3'b000: cmd_step_i = 7'b0000001;
      3'b001: cmd_step_i = 7'b0000010;
      3'b010: cmd_step_i = 7'b0000100;
      3'b011: cmd_step_i = 7'b0001000;
      3'b100: cmd_step_i = 7'b0010000;
      3'b101: cmd_step_i = 7'b0100000;
      3'b110: cmd_step_i = 7'b1000000;
      3'b111: cmd_step_i = 7'b0000000; 
    endcase
  end
  assign cmd_step = cmd_step_i[C_M_AXI_BYTES_LOG:0];
  generate
    if ( C_AXI_CHANNEL == 0 && C_MAX_SPLIT_BEATS > 0 ) begin : USE_B_CHANNEL
      wire                                cmd_b_valid_i;
      wire                                s_b_ready;
      axi_data_fifo_v2_1_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(1+8),
       .C_FIFO_TYPE("lut")
       ) 
       cmd_b_queue
      (
       .ACLK(ACLK),
       .ARESET(ARESET),
       .S_MESG({cmd_b_split_i, cmd_b_repeat_i}),
       .S_VALID(cmd_b_push),
       .S_READY(s_b_ready),
       .M_MESG({cmd_b_split, cmd_b_repeat}),
       .M_VALID(cmd_b_valid_i),
       .M_READY(cmd_b_ready)
       );
      assign cmd_b_full   = ~s_b_ready;
      always @ (posedge ACLK) begin
        if (ARESET) begin
          cmd_b_empty_i <= 1'b1;
          cmd_b_depth <= {C_FIFO_DEPTH_LOG+1{1'b0}};
        end else begin
          if ( cmd_b_push & ~cmd_b_ready ) begin
            cmd_b_depth <= cmd_b_depth + 1'b1;
            cmd_b_empty_i <= 1'b0;
          end else if ( ~cmd_b_push & cmd_b_ready ) begin
            cmd_b_depth <= cmd_b_depth - 1'b1;
            cmd_b_empty_i <= ( cmd_b_depth == 1 );
          end
        end
      end
      assign cmd_b_valid  = cmd_b_valid_i;
      assign cmd_b_empty = cmd_b_empty_i;
    end else begin : NO_B_CHANNEL
      assign cmd_b_valid    = 1'b0;
      assign cmd_b_split    = 1'b0;
      assign cmd_b_repeat   = 8'b0;
      assign cmd_b_full     = 1'b0;
      assign cmd_b_empty    = 1'b1;
    end
  endgenerate
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
endmodule
