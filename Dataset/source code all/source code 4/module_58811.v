`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_a_axi3_conv #
  (
   parameter C_FAMILY                            = "none",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_AUSER_WIDTH           = 1,
   parameter integer C_AXI_CHANNEL                    = 0,
   parameter integer C_SUPPORT_SPLITTING              = 1,
   parameter integer C_SUPPORT_BURSTS                 = 1,
   parameter integer C_SINGLE_THREAD                  = 1
   )
  (
   input wire ACLK,
   input wire ARESET,
   output wire                              cmd_valid,
   output wire                              cmd_split,
   output wire [C_AXI_ID_WIDTH-1:0]         cmd_id,
   output wire [4-1:0]                      cmd_length,
   input  wire                              cmd_ready,
   output wire                              cmd_b_valid,
   output wire                              cmd_b_split,
   output wire [4-1:0]                      cmd_b_repeat,
   input  wire                              cmd_b_ready,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_AID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AADDR,
   input  wire [8-1:0]                  S_AXI_ALEN,
   input  wire [3-1:0]                  S_AXI_ASIZE,
   input  wire [2-1:0]                  S_AXI_ABURST,
   input  wire [1-1:0]                  S_AXI_ALOCK,
   input  wire [4-1:0]                  S_AXI_ACACHE,
   input  wire [3-1:0]                  S_AXI_APROT,
   input  wire [4-1:0]                  S_AXI_AQOS,
   input  wire [C_AXI_AUSER_WIDTH-1:0]  S_AXI_AUSER,
   input  wire                          S_AXI_AVALID,
   output wire                          S_AXI_AREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_AID,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_AADDR,
   output wire [4-1:0]                  M_AXI_ALEN,
   output wire [3-1:0]                  M_AXI_ASIZE,
   output wire [2-1:0]                  M_AXI_ABURST,
   output wire [2-1:0]                  M_AXI_ALOCK,
   output wire [4-1:0]                  M_AXI_ACACHE,
   output wire [3-1:0]                  M_AXI_APROT,
   output wire [4-1:0]                  M_AXI_AQOS,
   output wire [C_AXI_AUSER_WIDTH-1:0]  M_AXI_AUSER,
   output wire                          M_AXI_AVALID,
   input  wire                          M_AXI_AREADY
   );
  localparam [2-1:0] C_FIX_BURST         = 2'b00;
  localparam [2-1:0] C_INCR_BURST        = 2'b01;
  localparam [2-1:0] C_WRAP_BURST        = 2'b10;
  localparam integer C_FIFO_DEPTH_LOG    = 5;
  localparam [C_AXI_ADDR_WIDTH+8-1:0] C_SIZE_MASK = {{C_AXI_ADDR_WIDTH{1'b1}}, 8'b0000_0000};
  wire                                access_is_incr;
  wire [4-1:0]                        num_transactions;
  wire                                incr_need_to_split;
  reg  [C_AXI_ADDR_WIDTH-1:0]         next_mi_addr = {C_AXI_ADDR_WIDTH{1'b0}};
  reg                                 split_ongoing = 1'b0;
  reg  [4-1:0]                        pushed_commands = 4'b0;
  reg  [16-1:0]                       addr_step;
  reg  [16-1:0]                       first_step;
  wire [8-1:0]                        first_beats;
  reg  [C_AXI_ADDR_WIDTH-1:0]         size_mask;
  reg                                 access_is_incr_q = 1'b0;
  reg                                 incr_need_to_split_q = 1'b0;
  wire                                need_to_split_q;
  reg  [4-1:0]                        num_transactions_q = 4'b0;
  reg  [16-1:0]                       addr_step_q = 16'b0;
  reg  [16-1:0]                       first_step_q = 16'b0;
  reg  [C_AXI_ADDR_WIDTH-1:0]         size_mask_q = {C_AXI_ADDR_WIDTH{1'b0}};
  reg  [C_FIFO_DEPTH_LOG:0]           cmd_depth = {C_FIFO_DEPTH_LOG+1{1'b0}};
  reg                                 cmd_empty = 1'b1;
  reg  [C_AXI_ID_WIDTH-1:0]           queue_id = {C_AXI_ID_WIDTH{1'b0}};
  wire                                id_match;
  wire                                cmd_id_check;
  wire                                s_ready;
  wire                                cmd_full;
  wire                                allow_this_cmd;
  wire                                allow_new_cmd;
  wire                                cmd_push;
  reg                                 cmd_push_block = 1'b0;
  reg  [C_FIFO_DEPTH_LOG:0]           cmd_b_depth = {C_FIFO_DEPTH_LOG+1{1'b0}};
  reg                                 cmd_b_empty = 1'b1;
  wire                                cmd_b_full;
  wire                                cmd_b_push;
  reg                                 cmd_b_push_block = 1'b0;
  wire                                pushed_new_cmd;
  wire                                last_incr_split;
  wire                                last_split;
  wire                                first_split;
  wire                                no_cmd;
  wire                                allow_split_cmd;
  wire                                almost_empty;
  wire                                no_b_cmd;
  wire                                allow_non_split_cmd;
  wire                                almost_b_empty;
  reg                                 multiple_id_non_split = 1'b0;
  reg                                 split_in_progress = 1'b0;
  wire                                cmd_split_i;
  wire [C_AXI_ID_WIDTH-1:0]           cmd_id_i;
  reg  [4-1:0]                        cmd_length_i = 4'b0;
  wire                                cmd_b_split_i;
  wire [4-1:0]                        cmd_b_repeat_i;
  wire                                mi_stalling;
  reg                                 command_ongoing = 1'b0;
  reg  [C_AXI_ID_WIDTH-1:0]           S_AXI_AID_Q;
  reg  [C_AXI_ADDR_WIDTH-1:0]         S_AXI_AADDR_Q;
  reg  [8-1:0]                        S_AXI_ALEN_Q;
  reg  [3-1:0]                        S_AXI_ASIZE_Q;
  reg  [2-1:0]                        S_AXI_ABURST_Q;
  reg  [2-1:0]                        S_AXI_ALOCK_Q;
  reg  [4-1:0]                        S_AXI_ACACHE_Q;
  reg  [3-1:0]                        S_AXI_APROT_Q;
  reg  [4-1:0]                        S_AXI_AQOS_Q;
  reg  [C_AXI_AUSER_WIDTH-1:0]        S_AXI_AUSER_Q;
  reg                                 S_AXI_AREADY_I = 1'b0;
  wire [C_AXI_ID_WIDTH-1:0]           M_AXI_AID_I;
  reg  [C_AXI_ADDR_WIDTH-1:0]         M_AXI_AADDR_I;
  reg  [8-1:0]                        M_AXI_ALEN_I;
  wire [3-1:0]                        M_AXI_ASIZE_I;
  wire [2-1:0]                        M_AXI_ABURST_I;
  reg  [2-1:0]                        M_AXI_ALOCK_I;
  wire [4-1:0]                        M_AXI_ACACHE_I;
  wire [3-1:0]                        M_AXI_APROT_I;
  wire [4-1:0]                        M_AXI_AQOS_I;
  wire [C_AXI_AUSER_WIDTH-1:0]        M_AXI_AUSER_I;
  wire                                M_AXI_AVALID_I;
  wire                                M_AXI_AREADY_I;
  reg [1:0] areset_d = 2'b0; 
  always @(posedge ACLK) begin
    areset_d <= {areset_d[0], ARESET};
  end
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      S_AXI_AID_Q     <= {C_AXI_ID_WIDTH{1'b0}};
      S_AXI_AADDR_Q   <= {C_AXI_ADDR_WIDTH{1'b0}};
      S_AXI_ALEN_Q    <= 8'b0;
      S_AXI_ASIZE_Q   <= 3'b0;
      S_AXI_ABURST_Q  <= 2'b0;
      S_AXI_ALOCK_Q   <= 2'b0;
      S_AXI_ACACHE_Q  <= 4'b0;
      S_AXI_APROT_Q   <= 3'b0;
      S_AXI_AQOS_Q    <= 4'b0;
      S_AXI_AUSER_Q   <= {C_AXI_AUSER_WIDTH{1'b0}};
    end else begin
      if ( S_AXI_AREADY_I ) begin
        S_AXI_AID_Q     <= S_AXI_AID;
        S_AXI_AADDR_Q   <= S_AXI_AADDR;
        S_AXI_ALEN_Q    <= S_AXI_ALEN;
        S_AXI_ASIZE_Q   <= S_AXI_ASIZE;
        S_AXI_ABURST_Q  <= S_AXI_ABURST;
        S_AXI_ALOCK_Q   <= S_AXI_ALOCK;
        S_AXI_ACACHE_Q  <= S_AXI_ACACHE;
        S_AXI_APROT_Q   <= S_AXI_APROT;
        S_AXI_AQOS_Q    <= S_AXI_AQOS;
        S_AXI_AUSER_Q   <= S_AXI_AUSER;
      end
    end
  end
  assign access_is_incr   = ( S_AXI_ABURST == C_INCR_BURST );
  assign num_transactions = S_AXI_ALEN[4 +: 4];
  assign first_beats = {3'b0, S_AXI_ALEN[0 +: 4]} + 7'b01;
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: first_step = first_beats << 0;
      3'b001: first_step = first_beats << 1;
      3'b010: first_step = first_beats << 2;
      3'b011: first_step = first_beats << 3;
      3'b100: first_step = first_beats << 4;
      3'b101: first_step = first_beats << 5;
      3'b110: first_step = first_beats << 6;
      3'b111: first_step = first_beats << 7;
    endcase
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: addr_step = 16'h0010;
      3'b001: addr_step = 16'h0020;
      3'b010: addr_step = 16'h0040;
      3'b011: addr_step = 16'h0080;
      3'b100: addr_step = 16'h0100;
      3'b101: addr_step = 16'h0200;
      3'b110: addr_step = 16'h0400;
      3'b111: addr_step = 16'h0800;
    endcase
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: size_mask = C_SIZE_MASK[8 +: C_AXI_ADDR_WIDTH];
      3'b001: size_mask = C_SIZE_MASK[7 +: C_AXI_ADDR_WIDTH];
      3'b010: size_mask = C_SIZE_MASK[6 +: C_AXI_ADDR_WIDTH];
      3'b011: size_mask = C_SIZE_MASK[5 +: C_AXI_ADDR_WIDTH];
      3'b100: size_mask = C_SIZE_MASK[4 +: C_AXI_ADDR_WIDTH];
      3'b101: size_mask = C_SIZE_MASK[3 +: C_AXI_ADDR_WIDTH];
      3'b110: size_mask = C_SIZE_MASK[2 +: C_AXI_ADDR_WIDTH];
      3'b111: size_mask = C_SIZE_MASK[1 +: C_AXI_ADDR_WIDTH];
    endcase
  end
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      access_is_incr_q      <= 1'b0;
      incr_need_to_split_q  <= 1'b0;
      num_transactions_q    <= 4'b0;
      addr_step_q           <= 16'b0;
      first_step_q           <= 16'b0;
      size_mask_q           <= {C_AXI_ADDR_WIDTH{1'b0}};
    end else begin
      if ( S_AXI_AREADY_I ) begin
        access_is_incr_q      <= access_is_incr;
        incr_need_to_split_q  <= incr_need_to_split;
        num_transactions_q    <= num_transactions;
        addr_step_q           <= addr_step;
        first_step_q          <= first_step;
        size_mask_q           <= size_mask;
      end
    end
  end
  assign incr_need_to_split = access_is_incr & ( num_transactions != 0 ) &
                              ( C_SUPPORT_SPLITTING == 1 ) &
                              ( C_SUPPORT_BURSTS == 1 );
  assign need_to_split_q    = incr_need_to_split_q;
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
      pushed_commands <= 4'b0;
    end else begin
      if ( S_AXI_AREADY_I ) begin
        pushed_commands <= 4'b0;
      end else if ( pushed_new_cmd ) begin
        pushed_commands <= pushed_commands + 4'b1;
      end
    end
  end
  assign last_incr_split    = access_is_incr_q & ( num_transactions_q   == pushed_commands );
  assign last_split         = last_incr_split | ~access_is_incr_q | 
                              ( C_SUPPORT_SPLITTING == 0 ) |
                              ( C_SUPPORT_BURSTS == 0 );
  assign first_split = (pushed_commands == 4'b0);
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      next_mi_addr  = {C_AXI_ADDR_WIDTH{1'b0}};
    end else if ( pushed_new_cmd ) begin
      next_mi_addr  = M_AXI_AADDR_I + (first_split ? first_step_q : addr_step_q);
    end
  end
  assign cmd_split_i        = need_to_split_q & ~last_split;
  assign cmd_b_split_i      = need_to_split_q & ~last_split;
  assign cmd_id_i           = S_AXI_AID_Q;
  assign cmd_b_repeat_i     = num_transactions_q;
  always @ *
  begin
    if ( split_ongoing & access_is_incr_q ) begin
      M_AXI_AADDR_I = next_mi_addr & size_mask_q;
    end else begin
      M_AXI_AADDR_I = S_AXI_AADDR_Q;
    end
  end
  always @ *
  begin
    if ( first_split | ~need_to_split_q ) begin
      M_AXI_ALEN_I = S_AXI_ALEN_Q[0 +: 4];
      cmd_length_i = S_AXI_ALEN_Q[0 +: 4];
    end else begin
      M_AXI_ALEN_I = 4'hF;
      cmd_length_i = 4'hF;
    end
  end
  always @ *
  begin
    if ( need_to_split_q ) begin
      M_AXI_ALOCK_I = 2'b00;
    end else begin
      M_AXI_ALOCK_I = {1'b0, S_AXI_ALOCK_Q};
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
  assign M_AXI_AID_I      = S_AXI_AID_Q;
  assign M_AXI_ASIZE_I    = S_AXI_ASIZE_Q;
  assign M_AXI_ABURST_I   = S_AXI_ABURST_Q;
  assign M_AXI_ACACHE_I   = S_AXI_ACACHE_Q;
  assign M_AXI_APROT_I    = S_AXI_APROT_Q;
  assign M_AXI_AQOS_I     = S_AXI_AQOS_Q;
  assign M_AXI_AUSER_I    = ( C_AXI_SUPPORTS_USER_SIGNALS ) ? S_AXI_AUSER_Q : {C_AXI_AUSER_WIDTH{1'b0}};
  always @ (posedge ACLK) begin
    if (ARESET) begin
      queue_id              <= {C_AXI_ID_WIDTH{1'b0}};
      multiple_id_non_split <= 1'b0;
      split_in_progress     <= 1'b0;
    end else begin
      if ( cmd_push ) begin
        queue_id              <= S_AXI_AID_Q;
      end
      if ( no_cmd & no_b_cmd ) begin
        multiple_id_non_split <= 1'b0;
      end else if ( cmd_push & allow_non_split_cmd & ~id_match ) begin
        multiple_id_non_split <= 1'b1;
      end
      if ( no_cmd & no_b_cmd ) begin
        split_in_progress     <= 1'b0;
      end else if ( cmd_push & allow_split_cmd ) begin
        split_in_progress     <= 1'b1;
      end
    end
  end
  assign no_cmd               = almost_empty   & cmd_ready   | cmd_empty;
  assign no_b_cmd             = almost_b_empty & cmd_b_ready | cmd_b_empty;
  assign id_match             = ( C_SINGLE_THREAD == 0 ) | ( queue_id == S_AXI_AID_Q);
  assign cmd_id_check         = (cmd_empty & cmd_b_empty) | ( id_match & (~cmd_empty | ~cmd_b_empty) );
  assign allow_split_cmd      = need_to_split_q & cmd_id_check & ~multiple_id_non_split;
  assign allow_non_split_cmd  = ~need_to_split_q & (cmd_id_check | ~split_in_progress);
  assign allow_this_cmd       = allow_split_cmd | allow_non_split_cmd | ( C_SINGLE_THREAD == 0 );
  assign allow_new_cmd        = (~cmd_full & ~cmd_b_full & allow_this_cmd) | 
                                cmd_push_block;
  assign cmd_push             = M_AXI_AVALID_I & ~cmd_push_block;
  assign cmd_b_push           = M_AXI_AVALID_I & ~cmd_b_push_block & (C_AXI_CHANNEL == 0);
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
  generate
    if ( C_AXI_CHANNEL == 1 && C_SUPPORT_SPLITTING == 1 && C_SUPPORT_BURSTS == 1 ) begin : USE_R_CHANNEL
      axi_data_fifo_v2_1_12_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(1),
       .C_FIFO_TYPE("lut")
       ) 
       cmd_queue
      (
       .ACLK(ACLK),
       .ARESET(ARESET),
       .S_MESG({cmd_split_i}),
       .S_VALID(cmd_push),
       .S_READY(s_ready),
       .M_MESG({cmd_split}),
       .M_VALID(cmd_valid),
       .M_READY(cmd_ready)
       );
       assign cmd_id            = {C_AXI_ID_WIDTH{1'b0}};
       assign cmd_length        = 4'b0;
    end else if (C_SUPPORT_BURSTS == 1) begin : USE_BURSTS
      axi_data_fifo_v2_1_12_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(C_AXI_ID_WIDTH+4),
       .C_FIFO_TYPE("lut")
       ) 
       cmd_queue
      (
       .ACLK(ACLK),
       .ARESET(ARESET),
       .S_MESG({cmd_id_i, cmd_length_i}),
       .S_VALID(cmd_push),
       .S_READY(s_ready),
       .M_MESG({cmd_id, cmd_length}),
       .M_VALID(cmd_valid),
       .M_READY(cmd_ready)
       );
       assign cmd_split         = 1'b0;
    end else begin : NO_BURSTS
      axi_data_fifo_v2_1_12_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(C_AXI_ID_WIDTH),
       .C_FIFO_TYPE("lut")
       ) 
       cmd_queue
      (
       .ACLK(ACLK),
       .ARESET(ARESET),
       .S_MESG({cmd_id_i}),
       .S_VALID(cmd_push),
       .S_READY(s_ready),
       .M_MESG({cmd_id}),
       .M_VALID(cmd_valid),
       .M_READY(cmd_ready)
       );
       assign cmd_split         = 1'b0;
       assign cmd_length        = 4'b0;
    end
  endgenerate
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
        cmd_empty <= almost_empty;
      end
    end
  end
  assign almost_empty = ( cmd_depth == 1 );
  generate
    if ( C_AXI_CHANNEL == 0 && C_SUPPORT_SPLITTING == 1 && C_SUPPORT_BURSTS == 1 ) begin : USE_B_CHANNEL
      wire                                cmd_b_valid_i;
      wire                                s_b_ready;
      axi_data_fifo_v2_1_12_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(1+4),
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
          cmd_b_empty <= 1'b1;
          cmd_b_depth <= {C_FIFO_DEPTH_LOG+1{1'b0}};
        end else begin
          if ( cmd_b_push & ~cmd_b_ready ) begin
            cmd_b_depth <= cmd_b_depth + 1'b1;
            cmd_b_empty <= 1'b0;
          end else if ( ~cmd_b_push & cmd_b_ready ) begin
            cmd_b_depth <= cmd_b_depth - 1'b1;
            cmd_b_empty <= ( cmd_b_depth == 1 );
          end
        end
      end
      assign almost_b_empty = ( cmd_b_depth == 1 );
      assign cmd_b_valid  = cmd_b_valid_i;
    end else begin : NO_B_CHANNEL
      assign cmd_b_valid    = 1'b0;
      assign cmd_b_split    = 1'b0;
      assign cmd_b_repeat   = 4'b0;
      assign cmd_b_full     = 1'b0;
      assign almost_b_empty = 1'b0;
      always @ (posedge ACLK) begin
        if (ARESET) begin
          cmd_b_empty <= 1'b1;
          cmd_b_depth <= {C_FIFO_DEPTH_LOG+1{1'b0}};
        end else begin
          cmd_b_empty <= 1'b1;
          cmd_b_depth <= {C_FIFO_DEPTH_LOG+1{1'b0}};
        end
      end
    end
  endgenerate
  assign M_AXI_AID      = M_AXI_AID_I;
  assign M_AXI_AADDR    = M_AXI_AADDR_I;
  assign M_AXI_ALEN     = M_AXI_ALEN_I;
  assign M_AXI_ASIZE    = M_AXI_ASIZE_I;
  assign M_AXI_ABURST   = M_AXI_ABURST_I;
  assign M_AXI_ALOCK    = M_AXI_ALOCK_I;
  assign M_AXI_ACACHE   = M_AXI_ACACHE_I;
  assign M_AXI_APROT    = M_AXI_APROT_I;
  assign M_AXI_AQOS     = M_AXI_AQOS_I;
  assign M_AXI_AUSER    = M_AXI_AUSER_I;
  assign M_AXI_AVALID   = M_AXI_AVALID_I;
  assign M_AXI_AREADY_I = M_AXI_AREADY;
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_axi3_conv #
  (
   parameter C_FAMILY                            = "none",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_AWUSER_WIDTH          = 1,
   parameter integer C_AXI_ARUSER_WIDTH          = 1,
   parameter integer C_AXI_WUSER_WIDTH           = 1,
   parameter integer C_AXI_RUSER_WIDTH           = 1,
   parameter integer C_AXI_BUSER_WIDTH           = 1,
   parameter integer C_AXI_SUPPORTS_WRITE             = 1,
   parameter integer C_AXI_SUPPORTS_READ              = 1,
   parameter integer C_SUPPORT_SPLITTING              = 1,
   parameter integer C_SUPPORT_BURSTS                 = 1,
   parameter integer C_SINGLE_THREAD                  = 1
   )
  (
   input wire ACLK,
   input wire ARESETN,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_AWID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
   input  wire [8-1:0]                  S_AXI_AWLEN,
   input  wire [3-1:0]                  S_AXI_AWSIZE,
   input  wire [2-1:0]                  S_AXI_AWBURST,
   input  wire [1-1:0]                  S_AXI_AWLOCK,
   input  wire [4-1:0]                  S_AXI_AWCACHE,
   input  wire [3-1:0]                  S_AXI_AWPROT,
   input  wire [4-1:0]                  S_AXI_AWQOS,
   input  wire [C_AXI_AWUSER_WIDTH-1:0] S_AXI_AWUSER,
   input  wire                          S_AXI_AWVALID,
   output wire                          S_AXI_AWREADY,
   input  wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
   input  wire                          S_AXI_WLAST,
   input  wire [C_AXI_WUSER_WIDTH-1:0]  S_AXI_WUSER,
   input  wire                          S_AXI_WVALID,
   output wire                          S_AXI_WREADY,
   output wire [C_AXI_ID_WIDTH-1:0]    S_AXI_BID,
   output wire [2-1:0]                 S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0] S_AXI_BUSER,
   output wire                         S_AXI_BVALID,
   input  wire                         S_AXI_BREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_ARID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
   input  wire [8-1:0]                  S_AXI_ARLEN,
   input  wire [3-1:0]                  S_AXI_ARSIZE,
   input  wire [2-1:0]                  S_AXI_ARBURST,
   input  wire [1-1:0]                  S_AXI_ARLOCK,
   input  wire [4-1:0]                  S_AXI_ARCACHE,
   input  wire [3-1:0]                  S_AXI_ARPROT,
   input  wire [4-1:0]                  S_AXI_ARQOS,
   input  wire [C_AXI_ARUSER_WIDTH-1:0] S_AXI_ARUSER,
   input  wire                          S_AXI_ARVALID,
   output wire                          S_AXI_ARREADY,
   output wire [C_AXI_ID_WIDTH-1:0]    S_AXI_RID,
   output wire [C_AXI_DATA_WIDTH-1:0]  S_AXI_RDATA,
   output wire [2-1:0]                 S_AXI_RRESP,
   output wire                         S_AXI_RLAST,
   output wire [C_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER,
   output wire                         S_AXI_RVALID,
   input  wire                         S_AXI_RREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_AWID,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_AWADDR,
   output wire [4-1:0]                  M_AXI_AWLEN,
   output wire [3-1:0]                  M_AXI_AWSIZE,
   output wire [2-1:0]                  M_AXI_AWBURST,
   output wire [2-1:0]                  M_AXI_AWLOCK,
   output wire [4-1:0]                  M_AXI_AWCACHE,
   output wire [3-1:0]                  M_AXI_AWPROT,
   output wire [4-1:0]                  M_AXI_AWQOS,
   output wire [C_AXI_AWUSER_WIDTH-1:0] M_AXI_AWUSER,
   output wire                          M_AXI_AWVALID,
   input  wire                          M_AXI_AWREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_WID,
   output wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
   output wire                          M_AXI_WLAST,
   output wire [C_AXI_WUSER_WIDTH-1:0]  M_AXI_WUSER,
   output wire                          M_AXI_WVALID,
   input  wire                          M_AXI_WREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]    M_AXI_BID,
   input  wire [2-1:0]                 M_AXI_BRESP,
   input  wire [C_AXI_BUSER_WIDTH-1:0] M_AXI_BUSER,
   input  wire                         M_AXI_BVALID,
   output wire                         M_AXI_BREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_ARID,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_ARADDR,
   output wire [4-1:0]                  M_AXI_ARLEN,
   output wire [3-1:0]                  M_AXI_ARSIZE,
   output wire [2-1:0]                  M_AXI_ARBURST,
   output wire [2-1:0]                  M_AXI_ARLOCK,
   output wire [4-1:0]                  M_AXI_ARCACHE,
   output wire [3-1:0]                  M_AXI_ARPROT,
   output wire [4-1:0]                  M_AXI_ARQOS,
   output wire [C_AXI_ARUSER_WIDTH-1:0] M_AXI_ARUSER,
   output wire                          M_AXI_ARVALID,
   input  wire                          M_AXI_ARREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]    M_AXI_RID,
   input  wire [C_AXI_DATA_WIDTH-1:0]  M_AXI_RDATA,
   input  wire [2-1:0]                 M_AXI_RRESP,
   input  wire                         M_AXI_RLAST,
   input  wire [C_AXI_RUSER_WIDTH-1:0] M_AXI_RUSER,
   input  wire                         M_AXI_RVALID,
   output wire                         M_AXI_RREADY
   );
  generate
    if (C_AXI_SUPPORTS_WRITE == 1) begin : USE_WRITE
      wire                              wr_cmd_valid;
      wire [C_AXI_ID_WIDTH-1:0]         wr_cmd_id;
      wire [4-1:0]                      wr_cmd_length;
      wire                              wr_cmd_ready;
      wire                              wr_cmd_b_valid;
      wire                              wr_cmd_b_split;
      wire [4-1:0]                      wr_cmd_b_repeat;
      wire                              wr_cmd_b_ready;
      axi_protocol_converter_v2_1_13_a_axi3_conv #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
       .C_AXI_ADDR_WIDTH            (C_AXI_ADDR_WIDTH),
       .C_AXI_DATA_WIDTH            (C_AXI_DATA_WIDTH),
       .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
       .C_AXI_AUSER_WIDTH           (C_AXI_AWUSER_WIDTH),
       .C_AXI_CHANNEL               (0),
       .C_SUPPORT_SPLITTING         (C_SUPPORT_SPLITTING),
       .C_SUPPORT_BURSTS            (C_SUPPORT_BURSTS),
       .C_SINGLE_THREAD             (C_SINGLE_THREAD)
        ) write_addr_inst
       (
        .ARESET                     (~ARESETN),
        .ACLK                       (ACLK),
        .cmd_valid                  (wr_cmd_valid),
        .cmd_split                  (),
        .cmd_id                     (wr_cmd_id),
        .cmd_length                 (wr_cmd_length),
        .cmd_ready                  (wr_cmd_ready),
        .cmd_b_valid                (wr_cmd_b_valid),
        .cmd_b_split                (wr_cmd_b_split),
        .cmd_b_repeat               (wr_cmd_b_repeat),
        .cmd_b_ready                (wr_cmd_b_ready),
        .S_AXI_AID                  (S_AXI_AWID),
        .S_AXI_AADDR                (S_AXI_AWADDR),
        .S_AXI_ALEN                 (S_AXI_AWLEN),
        .S_AXI_ASIZE                (S_AXI_AWSIZE),
        .S_AXI_ABURST               (S_AXI_AWBURST),
        .S_AXI_ALOCK                (S_AXI_AWLOCK),
        .S_AXI_ACACHE               (S_AXI_AWCACHE),
        .S_AXI_APROT                (S_AXI_AWPROT),
        .S_AXI_AQOS                 (S_AXI_AWQOS),
        .S_AXI_AUSER                (S_AXI_AWUSER),
        .S_AXI_AVALID               (S_AXI_AWVALID),
        .S_AXI_AREADY               (S_AXI_AWREADY),
        .M_AXI_AID                  (M_AXI_AWID),
        .M_AXI_AADDR                (M_AXI_AWADDR),
        .M_AXI_ALEN                 (M_AXI_AWLEN),
        .M_AXI_ASIZE                (M_AXI_AWSIZE),
        .M_AXI_ABURST               (M_AXI_AWBURST),
        .M_AXI_ALOCK                (M_AXI_AWLOCK),
        .M_AXI_ACACHE               (M_AXI_AWCACHE),
        .M_AXI_APROT                (M_AXI_AWPROT),
        .M_AXI_AQOS                 (M_AXI_AWQOS),
        .M_AXI_AUSER                (M_AXI_AWUSER),
        .M_AXI_AVALID               (M_AXI_AWVALID),
        .M_AXI_AREADY               (M_AXI_AWREADY)
       );
      axi_protocol_converter_v2_1_13_w_axi3_conv #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
       .C_AXI_DATA_WIDTH            (C_AXI_DATA_WIDTH),
       .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
       .C_AXI_WUSER_WIDTH           (C_AXI_WUSER_WIDTH),
       .C_SUPPORT_SPLITTING         (C_SUPPORT_SPLITTING),
       .C_SUPPORT_BURSTS            (C_SUPPORT_BURSTS)
        ) write_data_inst
       (
        .ARESET                     (~ARESETN),
        .ACLK                       (ACLK),
        .cmd_valid                  (wr_cmd_valid),
        .cmd_id                     (wr_cmd_id),
        .cmd_length                 (wr_cmd_length),
        .cmd_ready                  (wr_cmd_ready),
        .S_AXI_WDATA                (S_AXI_WDATA),
        .S_AXI_WSTRB                (S_AXI_WSTRB),
        .S_AXI_WLAST                (S_AXI_WLAST),
        .S_AXI_WUSER                (S_AXI_WUSER),
        .S_AXI_WVALID               (S_AXI_WVALID),
        .S_AXI_WREADY               (S_AXI_WREADY),
        .M_AXI_WID                  (M_AXI_WID),
        .M_AXI_WDATA                (M_AXI_WDATA),
        .M_AXI_WSTRB                (M_AXI_WSTRB),
        .M_AXI_WLAST                (M_AXI_WLAST),
        .M_AXI_WUSER                (M_AXI_WUSER),
        .M_AXI_WVALID               (M_AXI_WVALID),
        .M_AXI_WREADY               (M_AXI_WREADY)
       );
      if ( C_SUPPORT_SPLITTING == 1 && C_SUPPORT_BURSTS == 1 ) begin : USE_SPLIT_W
        axi_protocol_converter_v2_1_13_b_downsizer #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
         .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
         .C_AXI_BUSER_WIDTH           (C_AXI_BUSER_WIDTH)
          ) write_resp_inst
         (
          .ARESET                     (~ARESETN),
          .ACLK                       (ACLK),
          .cmd_valid                  (wr_cmd_b_valid),
          .cmd_split                  (wr_cmd_b_split),
          .cmd_repeat                 (wr_cmd_b_repeat),
          .cmd_ready                  (wr_cmd_b_ready),
          .S_AXI_BID                  (S_AXI_BID),
          .S_AXI_BRESP                (S_AXI_BRESP),
          .S_AXI_BUSER                (S_AXI_BUSER),
          .S_AXI_BVALID               (S_AXI_BVALID),
          .S_AXI_BREADY               (S_AXI_BREADY),
          .M_AXI_BID                  (M_AXI_BID),
          .M_AXI_BRESP                (M_AXI_BRESP),
          .M_AXI_BUSER                (M_AXI_BUSER),
          .M_AXI_BVALID               (M_AXI_BVALID),
          .M_AXI_BREADY               (M_AXI_BREADY)
         );
      end else begin : NO_SPLIT_W
        assign S_AXI_BID      = M_AXI_BID;
        assign S_AXI_BRESP    = M_AXI_BRESP;
        assign S_AXI_BUSER    = M_AXI_BUSER;
        assign S_AXI_BVALID   = M_AXI_BVALID;
        assign M_AXI_BREADY   = S_AXI_BREADY;
      end
    end else begin : NO_WRITE
      assign S_AXI_AWREADY = 1'b0;
      assign S_AXI_WREADY  = 1'b0;
      assign S_AXI_BID     = {C_AXI_ID_WIDTH{1'b0}};
      assign S_AXI_BRESP   = 2'b0;
      assign S_AXI_BUSER   = {C_AXI_BUSER_WIDTH{1'b0}};
      assign S_AXI_BVALID  = 1'b0;
      assign M_AXI_AWID    = {C_AXI_ID_WIDTH{1'b0}};
      assign M_AXI_AWADDR  = {C_AXI_ADDR_WIDTH{1'b0}};
      assign M_AXI_AWLEN   = 4'b0;
      assign M_AXI_AWSIZE  = 3'b0;
      assign M_AXI_AWBURST = 2'b0;
      assign M_AXI_AWLOCK  = 2'b0;
      assign M_AXI_AWCACHE = 4'b0;
      assign M_AXI_AWPROT  = 3'b0;
      assign M_AXI_AWQOS   = 4'b0;
      assign M_AXI_AWUSER  = {C_AXI_AWUSER_WIDTH{1'b0}};
      assign M_AXI_AWVALID = 1'b0;
      assign M_AXI_WDATA   = {C_AXI_DATA_WIDTH{1'b0}};
      assign M_AXI_WSTRB   = {C_AXI_DATA_WIDTH/8{1'b0}};
      assign M_AXI_WLAST   = 1'b0;
      assign M_AXI_WUSER   = {C_AXI_WUSER_WIDTH{1'b0}};
      assign M_AXI_WVALID  = 1'b0;
      assign M_AXI_BREADY  = 1'b0;
    end
  endgenerate
  generate
    if (C_AXI_SUPPORTS_READ == 1) begin : USE_READ
      if ( C_SUPPORT_SPLITTING == 1 && C_SUPPORT_BURSTS == 1 ) begin : USE_SPLIT_R
        wire                              rd_cmd_valid;
        wire                              rd_cmd_split;
        wire                              rd_cmd_ready;
        axi_protocol_converter_v2_1_13_a_axi3_conv #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
         .C_AXI_ADDR_WIDTH            (C_AXI_ADDR_WIDTH),
         .C_AXI_DATA_WIDTH            (C_AXI_DATA_WIDTH),
         .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
         .C_AXI_AUSER_WIDTH           (C_AXI_ARUSER_WIDTH),
         .C_AXI_CHANNEL               (1),
         .C_SUPPORT_SPLITTING         (C_SUPPORT_SPLITTING),
         .C_SUPPORT_BURSTS            (C_SUPPORT_BURSTS),
         .C_SINGLE_THREAD             (C_SINGLE_THREAD)
          ) read_addr_inst
         (
          .ARESET                     (~ARESETN),
          .ACLK                       (ACLK),
          .cmd_valid                  (rd_cmd_valid),
          .cmd_split                  (rd_cmd_split),
          .cmd_id                     (),
          .cmd_length                 (),
          .cmd_ready                  (rd_cmd_ready),
          .cmd_b_valid                (),
          .cmd_b_split                (),
          .cmd_b_repeat               (),
          .cmd_b_ready                (1'b0),
          .S_AXI_AID                  (S_AXI_ARID),
          .S_AXI_AADDR                (S_AXI_ARADDR),
          .S_AXI_ALEN                 (S_AXI_ARLEN),
          .S_AXI_ASIZE                (S_AXI_ARSIZE),
          .S_AXI_ABURST               (S_AXI_ARBURST),
          .S_AXI_ALOCK                (S_AXI_ARLOCK),
          .S_AXI_ACACHE               (S_AXI_ARCACHE),
          .S_AXI_APROT                (S_AXI_ARPROT),
          .S_AXI_AQOS                 (S_AXI_ARQOS),
          .S_AXI_AUSER                (S_AXI_ARUSER),
          .S_AXI_AVALID               (S_AXI_ARVALID),
          .S_AXI_AREADY               (S_AXI_ARREADY),
          .M_AXI_AID                  (M_AXI_ARID),
          .M_AXI_AADDR                (M_AXI_ARADDR),
          .M_AXI_ALEN                 (M_AXI_ARLEN),
          .M_AXI_ASIZE                (M_AXI_ARSIZE),
          .M_AXI_ABURST               (M_AXI_ARBURST),
          .M_AXI_ALOCK                (M_AXI_ARLOCK),
          .M_AXI_ACACHE               (M_AXI_ARCACHE),
          .M_AXI_APROT                (M_AXI_ARPROT),
          .M_AXI_AQOS                 (M_AXI_ARQOS),
          .M_AXI_AUSER                (M_AXI_ARUSER),
          .M_AXI_AVALID               (M_AXI_ARVALID),
          .M_AXI_AREADY               (M_AXI_ARREADY)
         );
        axi_protocol_converter_v2_1_13_r_axi3_conv #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
         .C_AXI_DATA_WIDTH            (C_AXI_DATA_WIDTH),
         .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
         .C_AXI_RUSER_WIDTH           (C_AXI_RUSER_WIDTH),
         .C_SUPPORT_SPLITTING         (C_SUPPORT_SPLITTING),
         .C_SUPPORT_BURSTS            (C_SUPPORT_BURSTS)
          ) read_data_inst
         (
          .ARESET                     (~ARESETN),
          .ACLK                       (ACLK),
          .cmd_valid                  (rd_cmd_valid),
          .cmd_split                  (rd_cmd_split),
          .cmd_ready                  (rd_cmd_ready),
          .S_AXI_RID                  (S_AXI_RID),
          .S_AXI_RDATA                (S_AXI_RDATA),
          .S_AXI_RRESP                (S_AXI_RRESP),
          .S_AXI_RLAST                (S_AXI_RLAST),
          .S_AXI_RUSER                (S_AXI_RUSER),
          .S_AXI_RVALID               (S_AXI_RVALID),
          .S_AXI_RREADY               (S_AXI_RREADY),
          .M_AXI_RID                  (M_AXI_RID),
          .M_AXI_RDATA                (M_AXI_RDATA),
          .M_AXI_RRESP                (M_AXI_RRESP),
          .M_AXI_RLAST                (M_AXI_RLAST),
          .M_AXI_RUSER                (M_AXI_RUSER),
          .M_AXI_RVALID               (M_AXI_RVALID),
          .M_AXI_RREADY               (M_AXI_RREADY)
         );
      end else begin : NO_SPLIT_R
        assign M_AXI_ARID     = S_AXI_ARID;
        assign M_AXI_ARADDR   = S_AXI_ARADDR;
        assign M_AXI_ARLEN    = S_AXI_ARLEN;
        assign M_AXI_ARSIZE   = S_AXI_ARSIZE;
        assign M_AXI_ARBURST  = S_AXI_ARBURST;
        assign M_AXI_ARLOCK   = S_AXI_ARLOCK;
        assign M_AXI_ARCACHE  = S_AXI_ARCACHE;
        assign M_AXI_ARPROT   = S_AXI_ARPROT;
        assign M_AXI_ARQOS    = S_AXI_ARQOS;
        assign M_AXI_ARUSER   = S_AXI_ARUSER;
        assign M_AXI_ARVALID  = S_AXI_ARVALID;
        assign S_AXI_ARREADY  = M_AXI_ARREADY;
        assign S_AXI_RID      = M_AXI_RID;
        assign S_AXI_RDATA    = M_AXI_RDATA;
        assign S_AXI_RRESP    = M_AXI_RRESP;
        assign S_AXI_RLAST    = M_AXI_RLAST;
        assign S_AXI_RUSER    = M_AXI_RUSER;
        assign S_AXI_RVALID   = M_AXI_RVALID;
        assign M_AXI_RREADY   = S_AXI_RREADY;
      end
    end else begin : NO_READ
      assign S_AXI_ARREADY = 1'b0;
      assign S_AXI_RID     = {C_AXI_ID_WIDTH{1'b0}};
      assign S_AXI_RDATA   = {C_AXI_DATA_WIDTH{1'b0}};
      assign S_AXI_RRESP   = 2'b0;
      assign S_AXI_RLAST   = 1'b0;
      assign S_AXI_RUSER   = {C_AXI_RUSER_WIDTH{1'b0}};
      assign S_AXI_RVALID  = 1'b0;
      assign M_AXI_ARID    = {C_AXI_ID_WIDTH{1'b0}};
      assign M_AXI_ARADDR  = {C_AXI_ADDR_WIDTH{1'b0}};
      assign M_AXI_ARLEN   = 4'b0;
      assign M_AXI_ARSIZE  = 3'b0;
      assign M_AXI_ARBURST = 2'b0;
      assign M_AXI_ARLOCK  = 2'b0;
      assign M_AXI_ARCACHE = 4'b0;
      assign M_AXI_ARPROT  = 3'b0;
      assign M_AXI_ARQOS   = 4'b0;
      assign M_AXI_ARUSER  = {C_AXI_ARUSER_WIDTH{1'b0}};
      assign M_AXI_ARVALID = 1'b0;
      assign M_AXI_RREADY  = 1'b0;
    end
  endgenerate
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_axilite_conv #
  (
   parameter         C_FAMILY                    = "virtex6",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_WRITE        = 1,
   parameter integer C_AXI_SUPPORTS_READ         = 1,
   parameter integer C_AXI_RUSER_WIDTH                = 1,
   parameter integer C_AXI_BUSER_WIDTH                = 1
   )
  (
   input  wire                          ACLK,
   input  wire                          ARESETN,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_AWID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
   input  wire [3-1:0]                  S_AXI_AWPROT,
   input  wire                          S_AXI_AWVALID,
   output wire                          S_AXI_AWREADY,
   input  wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
   input  wire                          S_AXI_WVALID,
   output wire                          S_AXI_WREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     S_AXI_BID,
   output wire [2-1:0]                  S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0]  S_AXI_BUSER,    
   output wire                          S_AXI_BVALID,
   input  wire                          S_AXI_BREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_ARID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
   input  wire [3-1:0]                  S_AXI_ARPROT,
   input  wire                          S_AXI_ARVALID,
   output wire                          S_AXI_ARREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     S_AXI_RID,
   output wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA,
   output wire [2-1:0]                  S_AXI_RRESP,
   output wire                          S_AXI_RLAST,    
   output wire [C_AXI_RUSER_WIDTH-1:0]  S_AXI_RUSER,    
   output wire                          S_AXI_RVALID,
   input  wire                          S_AXI_RREADY,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_AWADDR,
   output wire [3-1:0]                  M_AXI_AWPROT,
   output wire                          M_AXI_AWVALID,
   input  wire                          M_AXI_AWREADY,
   output wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
   output wire                          M_AXI_WVALID,
   input  wire                          M_AXI_WREADY,
   input  wire [2-1:0]                  M_AXI_BRESP,
   input  wire                          M_AXI_BVALID,
   output wire                          M_AXI_BREADY,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_ARADDR,
   output wire [3-1:0]                  M_AXI_ARPROT,
   output wire                          M_AXI_ARVALID,
   input  wire                          M_AXI_ARREADY,
   input  wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_RDATA,
   input  wire [2-1:0]                  M_AXI_RRESP,
   input  wire                          M_AXI_RVALID,
   output wire                          M_AXI_RREADY
  );
  wire s_awvalid_i;
  wire s_arvalid_i;
  wire [C_AXI_ADDR_WIDTH-1:0] m_axaddr;
  reg read_active = 1'b0;
  reg write_active = 1'b0;
  reg busy = 1'b0;
  wire read_req;
  wire write_req;
  wire read_complete;
  wire write_complete;
  reg [1:0] areset_d = 2'b0; 
  always @(posedge ACLK) begin
    areset_d <= {areset_d[0], ~ARESETN};
  end
  assign s_awvalid_i = S_AXI_AWVALID & (C_AXI_SUPPORTS_WRITE != 0);
  assign s_arvalid_i = S_AXI_ARVALID & (C_AXI_SUPPORTS_READ != 0);
  assign read_req  = s_arvalid_i & ~busy & ~|areset_d & ~write_active;
  assign write_req = s_awvalid_i & ~busy & ~|areset_d & ((~read_active & ~s_arvalid_i) | write_active);
  assign read_complete  = M_AXI_RVALID & S_AXI_RREADY;
  assign write_complete = M_AXI_BVALID & S_AXI_BREADY;
  always @(posedge ACLK) begin : arbiter_read_ff
    if (|areset_d)
      read_active <= 1'b0;
    else if (read_complete)
      read_active <= 1'b0;
    else if (read_req)
      read_active <= 1'b1;
  end
  always @(posedge ACLK) begin : arbiter_write_ff
    if (|areset_d)
      write_active <= 1'b0;
    else if (write_complete)
      write_active <= 1'b0;
    else if (write_req)
      write_active <= 1'b1;
  end
  always @(posedge ACLK) begin : arbiter_busy_ff
    if (|areset_d)
      busy <= 1'b0;
    else if (read_complete | write_complete)
      busy <= 1'b0;
    else if ((write_req & M_AXI_AWREADY) | (read_req & M_AXI_ARREADY))
      busy <= 1'b1;
  end
  assign M_AXI_ARVALID = read_req;
  assign S_AXI_ARREADY = M_AXI_ARREADY & read_req;
  assign M_AXI_AWVALID = write_req;
  assign S_AXI_AWREADY = M_AXI_AWREADY & write_req;
  assign M_AXI_RREADY  = S_AXI_RREADY & read_active;
  assign S_AXI_RVALID  = M_AXI_RVALID & read_active;
  assign M_AXI_BREADY  = S_AXI_BREADY & write_active;
  assign S_AXI_BVALID  = M_AXI_BVALID & write_active;
  assign m_axaddr = (read_req | (C_AXI_SUPPORTS_WRITE == 0)) ? S_AXI_ARADDR : S_AXI_AWADDR;
  reg [C_AXI_ID_WIDTH-1:0] s_axid;
  always @(posedge ACLK) begin : axid
    if      (read_req)  s_axid <= S_AXI_ARID;
    else if (write_req) s_axid <= S_AXI_AWID;
  end
  assign S_AXI_BID = s_axid;
  assign S_AXI_RID = s_axid;
  assign M_AXI_AWADDR = m_axaddr;
  assign M_AXI_ARADDR = m_axaddr;
  assign S_AXI_WREADY   = M_AXI_WREADY & ~|areset_d;
  assign S_AXI_BRESP    = M_AXI_BRESP;
  assign S_AXI_RDATA    = M_AXI_RDATA;
  assign S_AXI_RRESP    = M_AXI_RRESP;
  assign S_AXI_RLAST    = 1'b1;
  assign S_AXI_BUSER    = {C_AXI_BUSER_WIDTH{1'b0}};
  assign S_AXI_RUSER    = {C_AXI_RUSER_WIDTH{1'b0}};
  assign M_AXI_AWPROT   = S_AXI_AWPROT;
  assign M_AXI_WVALID   = S_AXI_WVALID & ~|areset_d;
  assign M_AXI_WDATA    = S_AXI_WDATA;
  assign M_AXI_WSTRB    = S_AXI_WSTRB;
  assign M_AXI_ARPROT   = S_AXI_ARPROT;
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_r_axi3_conv #
  (
   parameter C_FAMILY                            = "none",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_RUSER_WIDTH           = 1,
   parameter integer C_SUPPORT_SPLITTING              = 1,
   parameter integer C_SUPPORT_BURSTS                 = 1
   )
  (
   input wire ACLK,
   input wire ARESET,
   input  wire                              cmd_valid,
   input  wire                              cmd_split,
   output wire                              cmd_ready,
   output wire [C_AXI_ID_WIDTH-1:0]    S_AXI_RID,
   output wire [C_AXI_DATA_WIDTH-1:0]  S_AXI_RDATA,
   output wire [2-1:0]                 S_AXI_RRESP,
   output wire                         S_AXI_RLAST,
   output wire [C_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER,
   output wire                         S_AXI_RVALID,
   input  wire                         S_AXI_RREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]    M_AXI_RID,
   input  wire [C_AXI_DATA_WIDTH-1:0]  M_AXI_RDATA,
   input  wire [2-1:0]                 M_AXI_RRESP,
   input  wire                         M_AXI_RLAST,
   input  wire [C_AXI_RUSER_WIDTH-1:0] M_AXI_RUSER,
   input  wire                         M_AXI_RVALID,
   output wire                         M_AXI_RREADY
   );
  localparam [2-1:0] C_RESP_OKAY        = 2'b00;
  localparam [2-1:0] C_RESP_EXOKAY      = 2'b01;
  localparam [2-1:0] C_RESP_SLVERROR    = 2'b10;
  localparam [2-1:0] C_RESP_DECERR      = 2'b11;
  wire                            cmd_ready_i;
  wire                            pop_si_data;
  wire                            si_stalling;
  wire                            M_AXI_RREADY_I;
  wire [C_AXI_ID_WIDTH-1:0]       S_AXI_RID_I;
  wire [C_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA_I;
  wire [2-1:0]                    S_AXI_RRESP_I;
  wire                            S_AXI_RLAST_I;
  wire [C_AXI_RUSER_WIDTH-1:0]    S_AXI_RUSER_I;
  wire                            S_AXI_RVALID_I;
  wire                            S_AXI_RREADY_I;
  assign M_AXI_RREADY_I = ~si_stalling & cmd_valid;
  assign M_AXI_RREADY   = M_AXI_RREADY_I;
  assign S_AXI_RVALID_I = M_AXI_RVALID & cmd_valid;
  assign pop_si_data    = S_AXI_RVALID_I & S_AXI_RREADY_I;
  assign cmd_ready_i    = cmd_valid & pop_si_data & M_AXI_RLAST;
  assign cmd_ready      = cmd_ready_i;
  assign si_stalling    = S_AXI_RVALID_I & ~S_AXI_RREADY_I;
  assign S_AXI_RLAST_I  = M_AXI_RLAST & 
                          ( ~cmd_split | ( C_SUPPORT_SPLITTING == 0 ) );
  assign S_AXI_RID_I    = M_AXI_RID;
  assign S_AXI_RUSER_I  = M_AXI_RUSER;
  assign S_AXI_RDATA_I  = M_AXI_RDATA;
  assign S_AXI_RRESP_I  = M_AXI_RRESP;
  assign S_AXI_RREADY_I = S_AXI_RREADY;
  assign S_AXI_RVALID   = S_AXI_RVALID_I;
  assign S_AXI_RID      = S_AXI_RID_I;
  assign S_AXI_RDATA    = S_AXI_RDATA_I;
  assign S_AXI_RRESP    = S_AXI_RRESP_I;
  assign S_AXI_RLAST    = S_AXI_RLAST_I;
  assign S_AXI_RUSER    = S_AXI_RUSER_I;
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_w_axi3_conv #
  (
   parameter C_FAMILY                            = "none",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_WUSER_WIDTH           = 1,
   parameter integer C_SUPPORT_SPLITTING              = 1,
   parameter integer C_SUPPORT_BURSTS                 = 1
   )
  (
   input wire ACLK,
   input wire ARESET,
   input  wire                              cmd_valid,
   input  wire [C_AXI_ID_WIDTH-1:0]         cmd_id,
   input  wire [4-1:0]                      cmd_length,
   output wire                              cmd_ready,
   input  wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
   input  wire                          S_AXI_WLAST,
   input  wire [C_AXI_WUSER_WIDTH-1:0]  S_AXI_WUSER,
   input  wire                          S_AXI_WVALID,
   output wire                          S_AXI_WREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_WID,
   output wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
   output wire                          M_AXI_WLAST,
   output wire [C_AXI_WUSER_WIDTH-1:0]  M_AXI_WUSER,
   output wire                          M_AXI_WVALID,
   input  wire                          M_AXI_WREADY
   );
  reg                             first_mi_word = 1'b0;
  reg  [8-1:0]                    length_counter_1;
  reg  [8-1:0]                    length_counter;
  wire [8-1:0]                    next_length_counter;
  wire                            last_beat;
  wire                            last_word;
  wire                            cmd_ready_i;
  wire                            pop_mi_data;
  wire                            mi_stalling;
  wire                            S_AXI_WREADY_I;
  wire [C_AXI_ID_WIDTH-1:0]       M_AXI_WID_I;
  wire [C_AXI_DATA_WIDTH-1:0]     M_AXI_WDATA_I;
  wire [C_AXI_DATA_WIDTH/8-1:0]   M_AXI_WSTRB_I;
  wire                            M_AXI_WLAST_I;
  wire [C_AXI_WUSER_WIDTH-1:0]    M_AXI_WUSER_I;
  wire                            M_AXI_WVALID_I;
  wire                            M_AXI_WREADY_I;
  assign S_AXI_WREADY_I = S_AXI_WVALID & cmd_valid & ~mi_stalling;
  assign S_AXI_WREADY   = S_AXI_WREADY_I;
  assign M_AXI_WVALID_I = S_AXI_WVALID & cmd_valid;
  assign pop_mi_data    = M_AXI_WVALID_I & M_AXI_WREADY_I;
  assign cmd_ready_i    = cmd_valid & pop_mi_data & last_word;
  assign cmd_ready      = cmd_ready_i;
  assign mi_stalling    = M_AXI_WVALID_I & ~M_AXI_WREADY_I;
  always @ *
  begin
    if ( first_mi_word )
      length_counter = cmd_length;
    else
      length_counter = length_counter_1;
  end
  assign next_length_counter = length_counter - 1'b1;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      first_mi_word    <= 1'b1;
      length_counter_1 <= 4'b0;
    end else begin
      if ( pop_mi_data ) begin
        if ( M_AXI_WLAST_I ) begin
          first_mi_word    <= 1'b1;
        end else begin
          first_mi_word    <= 1'b0;
        end
        length_counter_1 <= next_length_counter;
      end
    end
  end
  assign last_beat = ( length_counter == 4'b0 );
  assign last_word = ( last_beat ) |
                     ( C_SUPPORT_BURSTS == 0 );
  assign M_AXI_WUSER_I  = ( C_AXI_SUPPORTS_USER_SIGNALS ) ? S_AXI_WUSER : {C_AXI_WUSER_WIDTH{1'b0}};
  assign M_AXI_WDATA_I  = S_AXI_WDATA;
  assign M_AXI_WSTRB_I  = S_AXI_WSTRB;
  assign M_AXI_WID_I    = cmd_id;
  assign M_AXI_WLAST_I  = last_word;
  assign M_AXI_WID      = M_AXI_WID_I;
  assign M_AXI_WDATA    = M_AXI_WDATA_I;
  assign M_AXI_WSTRB    = M_AXI_WSTRB_I;
  assign M_AXI_WLAST    = M_AXI_WLAST_I;
  assign M_AXI_WUSER    = M_AXI_WUSER_I;
  assign M_AXI_WVALID   = M_AXI_WVALID_I;
  assign M_AXI_WREADY_I = M_AXI_WREADY;
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_b_downsizer #
  (
   parameter         C_FAMILY                         = "none", 
   parameter integer C_AXI_ID_WIDTH                   = 4, 
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS      = 0,
   parameter integer C_AXI_BUSER_WIDTH                = 1
   )
  (
   input  wire                                                    ARESET,
   input  wire                                                    ACLK,
   input  wire                              cmd_valid,
   input  wire                              cmd_split,
   input  wire [4-1:0]                      cmd_repeat,
   output wire                              cmd_ready,
   output wire [C_AXI_ID_WIDTH-1:0]           S_AXI_BID,
   output wire [2-1:0]                          S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0]          S_AXI_BUSER,
   output wire                                                    S_AXI_BVALID,
   input  wire                                                    S_AXI_BREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]          M_AXI_BID,
   input  wire [2-1:0]                         M_AXI_BRESP,
   input  wire [C_AXI_BUSER_WIDTH-1:0]         M_AXI_BUSER,
   input  wire                                                   M_AXI_BVALID,
   output wire                                                   M_AXI_BREADY
   );
  localparam [2-1:0] C_RESP_OKAY        = 2'b00;
  localparam [2-1:0] C_RESP_EXOKAY      = 2'b01;
  localparam [2-1:0] C_RESP_SLVERROR    = 2'b10;
  localparam [2-1:0] C_RESP_DECERR      = 2'b11;
  wire                            cmd_ready_i;
  wire                            pop_mi_data;
  wire                            mi_stalling;
  reg  [4-1:0]                    repeat_cnt_pre;
  reg  [4-1:0]                    repeat_cnt;
  wire [4-1:0]                    next_repeat_cnt;
  reg                             first_mi_word = 1'b0;
  wire                            last_word;
  wire                            load_bresp;
  wire                            need_to_update_bresp;
  reg  [2-1:0]                    S_AXI_BRESP_ACC;
  wire                            M_AXI_BREADY_I;
  wire [C_AXI_ID_WIDTH-1:0]       S_AXI_BID_I;
  reg  [2-1:0]                    S_AXI_BRESP_I;
  wire [C_AXI_BUSER_WIDTH-1:0]    S_AXI_BUSER_I;
  wire                            S_AXI_BVALID_I;
  wire                            S_AXI_BREADY_I;
  assign M_AXI_BREADY_I = M_AXI_BVALID & ~mi_stalling;
  assign M_AXI_BREADY   = M_AXI_BREADY_I;
  assign S_AXI_BVALID_I = M_AXI_BVALID & last_word;
  assign pop_mi_data    = M_AXI_BVALID & M_AXI_BREADY_I;
  assign cmd_ready_i    = cmd_valid & pop_mi_data & last_word;
  assign cmd_ready      = cmd_ready_i;
  assign mi_stalling    = (~S_AXI_BREADY_I & last_word);
  assign load_bresp           = (cmd_split & first_mi_word);
  assign need_to_update_bresp = ( M_AXI_BRESP > S_AXI_BRESP_ACC );
  always @ *
  begin
    if ( cmd_split ) begin
      if ( load_bresp || need_to_update_bresp ) begin
        S_AXI_BRESP_I = M_AXI_BRESP;
      end else begin
        S_AXI_BRESP_I = S_AXI_BRESP_ACC;
      end
    end else begin
      S_AXI_BRESP_I = M_AXI_BRESP;
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      S_AXI_BRESP_ACC <= C_RESP_OKAY;
    end else begin
      if ( pop_mi_data ) begin
        S_AXI_BRESP_ACC <= S_AXI_BRESP_I;
      end
    end
  end
  assign last_word  = ( ( repeat_cnt == 4'b0 ) & ~first_mi_word ) | 
                      ~cmd_split;
  always @ *
  begin
    if ( first_mi_word ) begin
      repeat_cnt_pre  =  cmd_repeat;
    end else begin
      repeat_cnt_pre  =  repeat_cnt;
    end
  end
  assign next_repeat_cnt  = repeat_cnt_pre - 1'b1;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      repeat_cnt    <= 4'b0;
      first_mi_word <= 1'b1;
    end else begin
      if ( pop_mi_data ) begin
        repeat_cnt    <= next_repeat_cnt;
        first_mi_word <= last_word;
      end
    end
  end
  assign S_AXI_BID_I  = M_AXI_BID;
  assign S_AXI_BUSER_I = {C_AXI_BUSER_WIDTH{1'b0}};
  assign S_AXI_BID      = S_AXI_BID_I;
  assign S_AXI_BRESP    = S_AXI_BRESP_I;
  assign S_AXI_BUSER    = S_AXI_BUSER_I;
  assign S_AXI_BVALID   = S_AXI_BVALID_I;
  assign S_AXI_BREADY_I = S_AXI_BREADY;
endmodule
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_decerr_slave #
  (
   parameter integer C_AXI_ID_WIDTH           = 1,
   parameter integer C_AXI_DATA_WIDTH         = 32,
   parameter integer C_AXI_BUSER_WIDTH        = 1,
   parameter integer C_AXI_RUSER_WIDTH        = 1,
   parameter integer C_AXI_PROTOCOL           = 0,
   parameter integer C_RESP                   = 2'b11,
   parameter integer C_IGNORE_ID              = 0
   )
  (
   input   wire                                         ACLK,
   input   wire                                         ARESETN,
   input   wire [(C_AXI_ID_WIDTH-1):0]                  S_AXI_AWID,
   input   wire                                         S_AXI_AWVALID,
   output  wire                                         S_AXI_AWREADY,
   input   wire                                         S_AXI_WLAST,
   input   wire                                         S_AXI_WVALID,
   output  wire                                         S_AXI_WREADY,
   output  wire [(C_AXI_ID_WIDTH-1):0]                  S_AXI_BID,
   output  wire [1:0]                                   S_AXI_BRESP,
   output  wire [C_AXI_BUSER_WIDTH-1:0]                 S_AXI_BUSER,
   output  wire                                         S_AXI_BVALID,
   input   wire                                         S_AXI_BREADY,
   input   wire [(C_AXI_ID_WIDTH-1):0]                  S_AXI_ARID,
   input   wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]   S_AXI_ARLEN,
   input   wire                                         S_AXI_ARVALID,
   output  wire                                         S_AXI_ARREADY,
   output  wire [(C_AXI_ID_WIDTH-1):0]                  S_AXI_RID,
   output  wire [(C_AXI_DATA_WIDTH-1):0]                S_AXI_RDATA,
   output  wire [1:0]                                   S_AXI_RRESP,
   output  wire [C_AXI_RUSER_WIDTH-1:0]                 S_AXI_RUSER,
   output  wire                                         S_AXI_RLAST,
   output  wire                                         S_AXI_RVALID,
   input   wire                                         S_AXI_RREADY
   );
  reg s_axi_awready_i = 1'b0;
  reg s_axi_wready_i = 1'b0;
  reg s_axi_bvalid_i = 1'b0;
  reg s_axi_arready_i = 1'b0;
  reg s_axi_rvalid_i = 1'b0;
  localparam P_WRITE_IDLE = 2'b00;
  localparam P_WRITE_DATA = 2'b01;
  localparam P_WRITE_RESP = 2'b10;
  localparam P_READ_IDLE  = 2'b00;
  localparam P_READ_START = 2'b01;
  localparam P_READ_DATA  = 2'b10;
  localparam integer  P_AXI4 = 0;
  localparam integer  P_AXI3 = 1;
  localparam integer  P_AXILITE = 2;
  assign S_AXI_BRESP = C_RESP;
  assign S_AXI_RRESP = C_RESP;
  assign S_AXI_RDATA = {C_AXI_DATA_WIDTH{1'b0}};
  assign S_AXI_BUSER = {C_AXI_BUSER_WIDTH{1'b0}};
  assign S_AXI_RUSER = {C_AXI_RUSER_WIDTH{1'b0}};
  assign S_AXI_AWREADY = s_axi_awready_i;
  assign S_AXI_WREADY = s_axi_wready_i;
  assign S_AXI_BVALID = s_axi_bvalid_i;
  assign S_AXI_ARREADY = s_axi_arready_i;
  assign S_AXI_RVALID = s_axi_rvalid_i;
  generate
  if (C_AXI_PROTOCOL == P_AXILITE) begin : gen_axilite
    reg s_axi_rvalid_en;
    assign S_AXI_RLAST = 1'b1;
    assign S_AXI_BID = 0;
    assign S_AXI_RID = 0;
    always @(posedge ACLK) begin
      if (~ARESETN) begin
        s_axi_awready_i <= 1'b0;
        s_axi_wready_i <= 1'b0;
        s_axi_bvalid_i <= 1'b0;
      end else begin
        if (s_axi_bvalid_i) begin
          if (S_AXI_BREADY) begin
            s_axi_bvalid_i <= 1'b0;
            s_axi_awready_i <= 1'b1;
          end
        end else if (S_AXI_WVALID & s_axi_wready_i) begin
            s_axi_wready_i <= 1'b0;
            s_axi_bvalid_i <= 1'b1;
        end else if (S_AXI_AWVALID & s_axi_awready_i) begin
          s_axi_awready_i <= 1'b0;
          s_axi_wready_i <= 1'b1;
        end else begin
          s_axi_awready_i <= 1'b1;
        end
      end
    end
    always @(posedge ACLK) begin
      if (~ARESETN) begin
        s_axi_arready_i <= 1'b0;
        s_axi_rvalid_i <= 1'b0;
        s_axi_rvalid_en <= 1'b0;
      end else begin
        if (s_axi_rvalid_i) begin
          if (S_AXI_RREADY) begin
            s_axi_rvalid_i <= 1'b0;
            s_axi_arready_i <= 1'b1;
          end
        end else if (s_axi_rvalid_en) begin
          s_axi_rvalid_en <= 1'b0;
          s_axi_rvalid_i <= 1'b1;
        end else if (S_AXI_ARVALID & s_axi_arready_i) begin
          s_axi_arready_i <= 1'b0;
          s_axi_rvalid_en <= 1'b1;
        end else begin
          s_axi_arready_i <= 1'b1;
        end
      end
    end
  end else begin : gen_axi
    reg s_axi_rlast_i;
    reg [(C_AXI_ID_WIDTH-1):0] s_axi_bid_i;
    reg [(C_AXI_ID_WIDTH-1):0] s_axi_rid_i;
    reg [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] read_cnt;
    reg [1:0] write_cs = P_WRITE_IDLE;
    reg [1:0] read_cs = P_READ_IDLE;
    assign S_AXI_RLAST = s_axi_rlast_i;
    assign S_AXI_BID = C_IGNORE_ID ? 0 : s_axi_bid_i;
    assign S_AXI_RID = C_IGNORE_ID ? 0 : s_axi_rid_i;
    always @(posedge ACLK) begin
      if (~ARESETN) begin
        write_cs <= P_WRITE_IDLE;
        s_axi_awready_i <= 1'b0;
        s_axi_wready_i <= 1'b0;
        s_axi_bvalid_i <= 1'b0;
        s_axi_bid_i <= 0;
      end else begin
        case (write_cs) 
          P_WRITE_IDLE: 
            begin
              if (S_AXI_AWVALID & s_axi_awready_i) begin
                s_axi_awready_i <= 1'b0;
                if (C_IGNORE_ID == 0) s_axi_bid_i <= S_AXI_AWID;
                s_axi_wready_i <= 1'b1;
                write_cs <= P_WRITE_DATA;
              end else begin
                s_axi_awready_i <= 1'b1;
              end
            end
          P_WRITE_DATA:
            begin
              if (S_AXI_WVALID & S_AXI_WLAST) begin
                s_axi_wready_i <= 1'b0;
                s_axi_bvalid_i <= 1'b1;
                write_cs <= P_WRITE_RESP;
              end
            end
          P_WRITE_RESP:
            begin
              if (S_AXI_BREADY) begin
                s_axi_bvalid_i <= 1'b0;
                s_axi_awready_i <= 1'b1;
                write_cs <= P_WRITE_IDLE;
              end
            end
        endcase
      end
    end
    always @(posedge ACLK) begin
      if (~ARESETN) begin
        read_cs <= P_READ_IDLE;
        s_axi_arready_i <= 1'b0;
        s_axi_rvalid_i <= 1'b0;
        s_axi_rlast_i <= 1'b0;
        s_axi_rid_i <= 0;
        read_cnt <= 0;
      end else begin
        case (read_cs) 
          P_READ_IDLE: 
            begin
              if (S_AXI_ARVALID & s_axi_arready_i) begin
                s_axi_arready_i <= 1'b0;
                if (C_IGNORE_ID == 0) s_axi_rid_i <= S_AXI_ARID;
                read_cnt <= S_AXI_ARLEN;
                s_axi_rlast_i <= (S_AXI_ARLEN == 0);
                read_cs <= P_READ_START;
              end else begin
                s_axi_arready_i <= 1'b1;
              end
            end
          P_READ_START:
            begin
              s_axi_rvalid_i <= 1'b1;
              read_cs <= P_READ_DATA;
            end
          P_READ_DATA:
            begin
              if (S_AXI_RREADY) begin
                if (read_cnt == 0) begin
                  s_axi_rvalid_i <= 1'b0;
                  s_axi_rlast_i <= 1'b0;
                  s_axi_arready_i <= 1'b1;
                  read_cs <= P_READ_IDLE;
                end else begin
                  if (read_cnt == 1) begin
                    s_axi_rlast_i <= 1'b1;
                  end
                  read_cnt <= read_cnt - 1;
                end
              end
            end
        endcase
      end
    end
  end  
  endgenerate
endmodule
`default_nettype wire
`timescale 1ns / 100ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_simple_fifo #
(
  parameter C_WIDTH  = 8,
  parameter C_AWIDTH = 4,
  parameter C_DEPTH  = 16
)
(
  input  wire               clk,       
  input  wire               rst,       
  input  wire               wr_en,     
  input  wire               rd_en,     
  input  wire [C_WIDTH-1:0] din,       
  output wire [C_WIDTH-1:0] dout,      
  output wire               a_full,
  output wire               full,      
  output wire               a_empty,
  output wire               empty      
);
localparam [C_AWIDTH-1:0] C_EMPTY = ~(0);
localparam [C_AWIDTH-1:0] C_EMPTY_PRE =  (0);
localparam [C_AWIDTH-1:0] C_FULL  = C_EMPTY-1;
localparam [C_AWIDTH-1:0] C_FULL_PRE  = (C_DEPTH < 8) ? C_FULL-1 : C_FULL-(C_DEPTH/8);
reg [C_WIDTH-1:0]  memory [C_DEPTH-1:0];
reg [C_AWIDTH-1:0] cnt_read = C_EMPTY;
always @(posedge clk) begin : BLKSRL
integer i;
  if (wr_en) begin
    for (i = 0; i < C_DEPTH-1; i = i + 1) begin
      memory[i+1] <= memory[i];
    end
    memory[0] <= din;
  end
end
always @(posedge clk) begin
  if (rst) cnt_read <= C_EMPTY;
  else if ( wr_en & !rd_en) cnt_read <= cnt_read + 1'b1;
  else if (!wr_en &  rd_en) cnt_read <= cnt_read - 1'b1;
end
assign full  = (cnt_read == C_FULL);
assign empty = (cnt_read == C_EMPTY);
assign a_full  = ((cnt_read >= C_FULL_PRE) && (cnt_read != C_EMPTY));
assign a_empty = (cnt_read == C_EMPTY_PRE);
assign dout  = (C_DEPTH == 1) ? memory[0] : memory[cnt_read];
endmodule 
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_wrap_cmd #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32
)
(
  input  wire                                 clk           , 
  input  wire                                 reset         , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          axaddr        , 
  input  wire [7:0]                           axlen         , 
  input  wire [2:0]                           axsize        , 
  input  wire                                 axhandshake   , 
  output wire [C_AXI_ADDR_WIDTH-1:0]          cmd_byte_addr , 
  input  wire                                 next          , 
  output reg                                  next_pending 
);
reg                         sel_first;
wire [11:0]                 axaddr_i;
wire [3:0]                  axlen_i;
reg  [11:0]                 wrap_boundary_axaddr;
reg  [3:0]                  axaddr_offset;
reg  [3:0]                  wrap_second_len;
reg  [11:0]                 wrap_boundary_axaddr_r;
reg  [3:0]                  axaddr_offset_r;
reg  [3:0]                  wrap_second_len_r;
reg  [4:0]                  axlen_cnt;
reg  [4:0]                  wrap_cnt_r;
wire [4:0]                  wrap_cnt;
reg  [11:0]                 axaddr_wrap;
reg                         next_pending_r;
localparam    L_AXI_ADDR_LOW_BIT = (C_AXI_ADDR_WIDTH >= 12) ? 12 : 11;
generate
  if (C_AXI_ADDR_WIDTH > 12) begin : ADDR_GT_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : {axaddr[C_AXI_ADDR_WIDTH-1:L_AXI_ADDR_LOW_BIT],axaddr_wrap[11:0]};
  end else begin : ADDR_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : axaddr_wrap[11:0];
  end
endgenerate
assign axaddr_i = axaddr[11:0];
assign axlen_i = axlen[3:0];
always @( * ) begin
  if(axhandshake) begin
    wrap_boundary_axaddr = axaddr_i & ~(axlen_i << axsize[1:0]);
    axaddr_offset = axaddr_i[axsize[1:0] +: 4] & axlen_i;
  end else begin
    wrap_boundary_axaddr = wrap_boundary_axaddr_r;
    axaddr_offset = axaddr_offset_r; 
  end
end
always @( * ) begin
  if(axhandshake) begin
    wrap_second_len = (axaddr_offset >0) ? axaddr_offset - 1 : 0;
  end else begin
    wrap_second_len = wrap_second_len_r;
  end
end
always @(posedge clk) begin
  wrap_boundary_axaddr_r <= wrap_boundary_axaddr;
  axaddr_offset_r <= axaddr_offset;
  wrap_second_len_r <= wrap_second_len;
end
assign wrap_cnt = {1'b0, wrap_second_len + {3'b000, (|axaddr_offset)}}; 
always @(posedge clk)
  wrap_cnt_r <= wrap_cnt;
always @(posedge clk) begin
  if (axhandshake) begin
    axaddr_wrap <= axaddr[11:0];
  end if(next)begin
    if(axlen_cnt == wrap_cnt_r) begin
      axaddr_wrap <= wrap_boundary_axaddr_r;
    end else begin
      axaddr_wrap <= axaddr_wrap + (1 << axsize[1:0]);
    end
  end
end 
always @(posedge clk) begin
  if (axhandshake)begin
    axlen_cnt <= axlen_i;
    next_pending_r <= axlen_i >= 1;
  end else if (next) begin
    if (axlen_cnt > 1) begin
      axlen_cnt <= axlen_cnt - 1;
      next_pending_r <= (axlen_cnt - 1) >= 1;
    end else begin
      axlen_cnt <= 5'd0;
      next_pending_r <= 1'b0;
    end
  end  
end  
always @( * ) begin
  if (axhandshake)begin
    next_pending = axlen_i >= 1;
  end else if (next) begin
    if (axlen_cnt > 1) begin
      next_pending = (axlen_cnt - 1) >= 1;
    end else begin
      next_pending = 1'b0;
    end
  end else begin
    next_pending = next_pending_r;
  end 
end  
always @(posedge clk) begin
  if (reset | axhandshake) begin
    sel_first <= 1'b1;
  end else if (next) begin
    sel_first <= 1'b0;
  end
end
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_incr_cmd #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32
)
(
  input  wire                                 clk           ,
  input  wire                                 reset         ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]          axaddr        ,
  input  wire [7:0]                           axlen         ,
  input  wire [2:0]                           axsize        ,
  input  wire                                 axhandshake   ,
  output wire [C_AXI_ADDR_WIDTH-1:0]          cmd_byte_addr ,
  input  wire                                 next          ,
  output reg                                  next_pending
);
reg                           sel_first;
reg  [11:0]                   axaddr_incr;
reg  [8:0]                    axlen_cnt;
reg                           next_pending_r;
wire [3:0]                    axsize_shift;
wire [11:0]                   axsize_mask;
localparam    L_AXI_ADDR_LOW_BIT = (C_AXI_ADDR_WIDTH >= 12) ? 12 : 11;
generate
  if (C_AXI_ADDR_WIDTH > 12) begin : ADDR_GT_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : {axaddr[C_AXI_ADDR_WIDTH-1:L_AXI_ADDR_LOW_BIT],axaddr_incr[11:0]};
  end else begin : ADDR_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : axaddr_incr[11:0];
  end
endgenerate
assign axsize_shift = (1 << axsize[1:0]);
assign axsize_mask  = ~(axsize_shift - 1'b1);
always @(posedge clk) begin
  if (sel_first) begin
    if(~next) begin
      axaddr_incr <= axaddr[11:0] & axsize_mask;
    end else begin
      axaddr_incr <= (axaddr[11:0] & axsize_mask) + axsize_shift;
    end
  end else if (next) begin
    axaddr_incr <= axaddr_incr + axsize_shift;
  end
end
always @(posedge clk) begin
  if (axhandshake)begin
     axlen_cnt <= axlen;
     next_pending_r <= (axlen >= 1);
  end else if (next) begin
    if (axlen_cnt > 1) begin
      axlen_cnt <= axlen_cnt - 1;
      next_pending_r <= ((axlen_cnt - 1) >= 1);
    end else begin
      axlen_cnt <= 9'd0;
      next_pending_r <= 1'b0;
    end
  end
end
always @( * ) begin
  if (axhandshake)begin
     next_pending = (axlen >= 1);
  end else if (next) begin
    if (axlen_cnt > 1) begin
      next_pending = ((axlen_cnt - 1) >= 1);
    end else begin
      next_pending = 1'b0;
    end
  end else begin
    next_pending = next_pending_r;
  end
end
always @(posedge clk) begin
  if (reset | axhandshake) begin
    sel_first <= 1'b1;
  end else if (next) begin
    sel_first <= 1'b0;
  end
end
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_wr_cmd_fsm (
  input  wire                                 clk           ,
  input  wire                                 reset         ,
  output wire                                 s_awready       ,
  input  wire                                 s_awvalid       ,
  output wire                                 m_awvalid        ,
  input  wire                                 m_awready      ,
  output wire                                 next          ,
  input  wire                                 next_pending  ,
  output wire                                 b_push        ,
  input  wire                                 b_full        ,
  output wire                                 a_push
);
localparam SM_IDLE                = 2'b00;
localparam SM_CMD_EN              = 2'b01;
localparam SM_CMD_ACCEPTED        = 2'b10;
localparam SM_DONE_WAIT           = 2'b11;
reg [1:0]       state = SM_IDLE;
reg [1:0]       next_state;
always @(posedge clk) begin
  if (reset) begin
    state <= SM_IDLE;
  end else begin
    state <= next_state;
  end
end
always @( * )
begin
  next_state = state;
  case (state)
    SM_IDLE:
      if (s_awvalid) begin
        next_state = SM_CMD_EN;
      end else
        next_state = state;
    SM_CMD_EN:
      if (m_awready & next_pending)
        next_state = SM_CMD_ACCEPTED;
      else if (m_awready & ~next_pending & b_full)
        next_state = SM_DONE_WAIT;
      else if (m_awready & ~next_pending & ~b_full)
        next_state = SM_IDLE;
      else
        next_state = state;
    SM_CMD_ACCEPTED:
      next_state = SM_CMD_EN;
    SM_DONE_WAIT:
      if (!b_full)
        next_state = SM_IDLE;
      else
        next_state = state;
      default:
        next_state = SM_IDLE;
  endcase
end
assign m_awvalid  = (state == SM_CMD_EN);
assign next    = ((state == SM_CMD_ACCEPTED)
                 | (((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE))) ;
assign a_push  = (state == SM_IDLE);
assign s_awready = ((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE);
assign b_push  = ((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_rd_cmd_fsm (
  input  wire                                 clk           ,
  input  wire                                 reset         ,
  output wire                                 s_arready       ,
  input  wire                                 s_arvalid       ,
  input  wire [7:0]                           s_arlen         ,
  output wire                                 m_arvalid        ,
  input  wire                                 m_arready      ,
  output wire                                 next          ,
  input  wire                                 next_pending  ,
  input  wire                                 data_ready    ,
  output wire                                 a_push        ,
  output wire                                 r_push
);
localparam SM_IDLE                = 2'b00;
localparam SM_CMD_EN              = 2'b01;
localparam SM_CMD_ACCEPTED        = 2'b10;
localparam SM_DONE                = 2'b11;
reg [1:0]       state = SM_IDLE;
reg [1:0]       state_r1 = SM_IDLE;
reg [1:0]       next_state;
reg [7:0]       s_arlen_r;
always @(posedge clk) begin
  if (reset) begin
    state <= SM_IDLE;
    state_r1 <= SM_IDLE;
    s_arlen_r  <= 0;
  end else begin
    state <= next_state;
    state_r1 <= state;
    s_arlen_r  <= s_arlen;
  end
end
always @( * ) begin
  next_state = state;
  case (state)
    SM_IDLE:
      if (s_arvalid & data_ready) begin
        next_state = SM_CMD_EN;
      end else begin
        next_state = state;
      end
    SM_CMD_EN:
      if (~data_ready & m_arready & next_pending) begin
        next_state = SM_CMD_ACCEPTED;
      end else if (m_arready & ~next_pending)begin
         next_state = SM_DONE;
      end else if (m_arready & next_pending) begin
        next_state = SM_CMD_EN;
      end else begin
        next_state = state;
      end
    SM_CMD_ACCEPTED:
      if (data_ready) begin
        next_state = SM_CMD_EN;
      end else begin
        next_state = state;
      end
    SM_DONE:
        next_state = SM_IDLE;
      default:
        next_state = SM_IDLE;
  endcase
end
assign m_arvalid  = (state == SM_CMD_EN);
assign next    = m_arready && (state == SM_CMD_EN);
assign         r_push  = next;
assign a_push  = (state == SM_IDLE);
assign s_arready = ((state == SM_CMD_EN) || (state == SM_DONE))  && (next_state == SM_IDLE);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_cmd_translator #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32
)
(
  input  wire                                 clk           , 
  input  wire                                 reset         , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          s_axaddr        , 
  input  wire [7:0]                           s_axlen         , 
  input  wire [2:0]                           s_axsize        , 
  input  wire [1:0]                           s_axburst       , 
  input  wire                                 s_axhandshake   , 
  output wire [C_AXI_ADDR_WIDTH-1:0]          m_axaddr , 
  output wire                                 incr_burst    , 
  input  wire                                 next          , 
  output wire                                 next_pending
);
localparam P_AXBURST_FIXED = 2'b00;
localparam P_AXBURST_INCR  = 2'b01;
localparam P_AXBURST_WRAP  = 2'b10;
wire [C_AXI_ADDR_WIDTH-1:0]     incr_cmd_byte_addr;
wire                            incr_next_pending;
wire [C_AXI_ADDR_WIDTH-1:0]     wrap_cmd_byte_addr;
wire                            wrap_next_pending;
reg                             sel_first;
reg                             s_axburst_eq1;
reg                             s_axburst_eq0;
reg                             sel_first_i;   
assign m_axaddr         = (s_axburst == P_AXBURST_FIXED) ?  s_axaddr : 
                          (s_axburst == P_AXBURST_INCR)  ?  incr_cmd_byte_addr : 
                                                            wrap_cmd_byte_addr;
assign incr_burst       = (s_axburst[1]) ? 1'b0 : 1'b1;
always @(posedge clk) begin
  if (reset | s_axhandshake) begin
    sel_first <= 1'b1;
  end else if (next) begin
    sel_first <= 1'b0;
  end
end
always @( * ) begin
  if (reset | s_axhandshake) begin
    sel_first_i = 1'b1;
  end else if (next) begin
    sel_first_i = 1'b0;
  end else begin
    sel_first_i = sel_first;
  end
end
assign next_pending = s_axburst[1] ? s_axburst_eq1 : s_axburst_eq0;
always @(posedge clk) begin
  if (sel_first_i || s_axburst[1]) begin
    s_axburst_eq1 <= wrap_next_pending;
  end else begin
    s_axburst_eq1 <= incr_next_pending;
  end
  if (sel_first_i || !s_axburst[1]) begin
    s_axburst_eq0 <= incr_next_pending;
  end else begin
    s_axburst_eq0 <= wrap_next_pending;
  end
end
axi_protocol_converter_v2_1_13_b2s_incr_cmd #(
  .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH)
)
incr_cmd_0
(
  .clk           ( clk                ) ,
  .reset         ( reset              ) ,
  .axaddr        ( s_axaddr           ) ,
  .axlen         ( s_axlen            ) ,
  .axsize        ( s_axsize           ) ,
  .axhandshake   ( s_axhandshake      ) ,
  .cmd_byte_addr ( incr_cmd_byte_addr ) ,
  .next          ( next               ) ,
  .next_pending  ( incr_next_pending  ) 
);
axi_protocol_converter_v2_1_13_b2s_wrap_cmd #(
  .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH)
)
wrap_cmd_0
(
  .clk           ( clk                ) ,
  .reset         ( reset              ) ,
  .axaddr        ( s_axaddr           ) ,
  .axlen         ( s_axlen            ) ,
  .axsize        ( s_axsize           ) ,
  .axhandshake   ( s_axhandshake      ) ,
  .cmd_byte_addr ( wrap_cmd_byte_addr ) ,
  .next          ( next               ) ,
  .next_pending  ( wrap_next_pending  ) 
);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_r_channel #
(
  parameter integer C_ID_WIDTH                = 4,
  parameter integer C_DATA_WIDTH              = 32
)
(
  input  wire                                 clk              ,
  input  wire                                 reset            ,
  output wire  [C_ID_WIDTH-1:0]               s_rid              ,
  output wire  [C_DATA_WIDTH-1:0]             s_rdata            ,
  output wire [1:0]                           s_rresp            ,
  output wire                                 s_rlast            ,
  output wire                                 s_rvalid           ,
  input  wire                                 s_rready           ,
  input  wire [C_DATA_WIDTH-1:0]              m_rdata   ,
  input  wire [1:0]                           m_rresp   ,
  input  wire                                 m_rvalid  ,
  output wire                                 m_rready  ,
  input  wire                                 r_push           ,
  output wire                                 r_full           ,
  input  wire [C_ID_WIDTH-1:0]                r_arid           ,
  input  wire                                 r_rlast
);
localparam P_WIDTH = 1+C_ID_WIDTH;
localparam P_DEPTH = 32;
localparam P_AWIDTH = 5;
localparam P_D_WIDTH = C_DATA_WIDTH + 2;
localparam P_D_DEPTH  = 32;
localparam P_D_AWIDTH = 5;
wire [C_ID_WIDTH+1-1:0]    trans_in;
wire [C_ID_WIDTH+1-1:0]    trans_out;
wire                       tr_empty;
wire                       rhandshake;
wire                       r_valid_i;
wire [P_D_WIDTH-1:0]       rd_data_fifo_in;
wire [P_D_WIDTH-1:0]       rd_data_fifo_out;
wire                       rd_en;
wire                       rd_full;
wire                       rd_empty;
wire                       rd_a_full;
wire                       fifo_a_full;
reg [C_ID_WIDTH-1:0]       r_arid_r;
reg                        r_rlast_r;
reg                        r_push_r;
wire                       fifo_full;
assign s_rresp  = rd_data_fifo_out[P_D_WIDTH-1:C_DATA_WIDTH];
assign s_rid    = trans_out[1+:C_ID_WIDTH];
assign s_rdata  = rd_data_fifo_out[C_DATA_WIDTH-1:0];
assign s_rlast  = trans_out[0];
assign s_rvalid = ~rd_empty & ~tr_empty;
assign rd_en      = rhandshake & (~rd_empty);
assign rhandshake =(s_rvalid & s_rready);
always @(posedge clk) begin
  r_arid_r <= r_arid;
  r_rlast_r <= r_rlast;
  r_push_r <= r_push;
end
assign trans_in[0]  = r_rlast_r;
assign trans_in[1+:C_ID_WIDTH]  = r_arid_r;
axi_protocol_converter_v2_1_13_b2s_simple_fifo #(
  .C_WIDTH                (P_D_WIDTH),
  .C_AWIDTH               (P_D_AWIDTH),
  .C_DEPTH                (P_D_DEPTH)
)
rd_data_fifo_0
(
  .clk     ( clk              ) ,
  .rst     ( reset            ) ,
  .wr_en   ( m_rvalid & m_rready ) ,
  .rd_en   ( rd_en            ) ,
  .din     ( rd_data_fifo_in  ) ,
  .dout    ( rd_data_fifo_out ) ,
  .a_full  ( rd_a_full        ) ,
  .full    ( rd_full          ) ,
  .a_empty (                  ) ,
  .empty   ( rd_empty         )
);
assign rd_data_fifo_in = {m_rresp, m_rdata};
axi_protocol_converter_v2_1_13_b2s_simple_fifo #(
  .C_WIDTH                  (P_WIDTH),
  .C_AWIDTH                 (P_AWIDTH),
  .C_DEPTH                  (P_DEPTH)
)
transaction_fifo_0
(
  .clk     ( clk         ) ,
  .rst     ( reset       ) ,
  .wr_en   ( r_push_r    ) ,
  .rd_en   ( rd_en       ) ,
  .din     ( trans_in    ) ,
  .dout    ( trans_out   ) ,
  .a_full  ( fifo_a_full ) ,
  .full    (             ) ,
  .a_empty (             ) ,
  .empty   ( tr_empty    )
);
assign fifo_full = fifo_a_full | rd_a_full ;
assign r_full = fifo_full ;
assign m_rready = ~rd_a_full;
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_aw_channel #
(
  parameter integer C_ID_WIDTH          = 4,
  parameter integer C_AXI_ADDR_WIDTH    = 32
)
(
  input  wire                                 clk             ,
  input  wire                                 reset           ,
  input  wire [C_ID_WIDTH-1:0]                s_awid            ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]          s_awaddr          ,
  input  wire [7:0]                           s_awlen           ,
  input  wire [2:0]                           s_awsize          ,
  input  wire [1:0]                           s_awburst         ,
  input  wire                                 s_awvalid         ,
  output wire                                 s_awready         ,
  output wire                                 m_awvalid         ,
  output wire [C_AXI_ADDR_WIDTH-1:0]          m_awaddr          ,
  input  wire                                 m_awready         ,
  output wire                                 b_push           ,
  output wire [C_ID_WIDTH-1:0]                b_awid           ,
  output wire [7:0]                           b_awlen          ,
  input  wire                                 b_full
);
wire                        next         ;
wire                        next_pending ;
wire                        a_push;
wire                        incr_burst;
reg  [C_ID_WIDTH-1:0]       s_awid_r;
reg  [7:0]                  s_awlen_r;
axi_protocol_converter_v2_1_13_b2s_cmd_translator #
(
  .C_AXI_ADDR_WIDTH ( C_AXI_ADDR_WIDTH )
)
cmd_translator_0
(
  .clk           ( clk                   ) ,
  .reset         ( reset                 ) ,
  .s_axaddr      ( s_awaddr              ) ,
  .s_axlen       ( s_awlen               ) ,
  .s_axsize      ( s_awsize              ) ,
  .s_axburst     ( s_awburst             ) ,
  .s_axhandshake ( s_awvalid & a_push    ) ,
  .m_axaddr      ( m_awaddr              ) ,
  .incr_burst    ( incr_burst            ) ,
  .next          ( next                  ) ,
  .next_pending  ( next_pending          )
);
axi_protocol_converter_v2_1_13_b2s_wr_cmd_fsm aw_cmd_fsm_0
(
  .clk          ( clk            ) ,
  .reset        ( reset          ) ,
  .s_awready    ( s_awready      ) ,
  .s_awvalid    ( s_awvalid      ) ,
  .m_awvalid    ( m_awvalid      ) ,
  .m_awready    ( m_awready      ) ,
  .next         ( next           ) ,
  .next_pending ( next_pending   ) ,
  .b_push       ( b_push         ) ,
  .b_full       ( b_full         ) ,
  .a_push       ( a_push         )
);
assign b_awid = s_awid_r;
assign b_awlen = s_awlen_r;
always @(posedge clk) begin
  s_awid_r <= s_awid ;
  s_awlen_r <= s_awlen ;
end
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_ar_channel #
(
  parameter integer C_ID_WIDTH          = 4,
  parameter integer C_AXI_ADDR_WIDTH    = 32
)
(
  input  wire                                 clk             ,
  input  wire                                 reset           ,
  input  wire [C_ID_WIDTH-1:0]                s_arid            ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]          s_araddr          ,
  input  wire [7:0]                           s_arlen           ,
  input  wire [2:0]                           s_arsize          ,
  input  wire [1:0]                           s_arburst         ,
  input  wire                                 s_arvalid         ,
  output wire                                 s_arready         ,
  output wire                                 m_arvalid         ,
  output wire [C_AXI_ADDR_WIDTH-1:0]          m_araddr          ,
  input  wire                                 m_arready         ,
  output wire [C_ID_WIDTH-1:0]                r_arid            ,
  output wire                                 r_push            ,
  output wire                                 r_rlast           ,
  input  wire                                 r_full
);
wire                        next      ;
wire                        next_pending ;
wire                        a_push;
wire                        incr_burst;
reg [C_ID_WIDTH-1:0]        s_arid_r;
axi_protocol_converter_v2_1_13_b2s_cmd_translator #
(
  .C_AXI_ADDR_WIDTH ( C_AXI_ADDR_WIDTH )
)
cmd_translator_0
(
  .clk           ( clk                   ) ,
  .reset         ( reset                 ) ,
  .s_axaddr      ( s_araddr              ) ,
  .s_axlen       ( s_arlen               ) ,
  .s_axsize      ( s_arsize              ) ,
  .s_axburst     ( s_arburst             ) ,
  .s_axhandshake ( s_arvalid & a_push    ) ,
  .incr_burst    ( incr_burst            ) ,
  .m_axaddr      ( m_araddr              ) ,
  .next          ( next                  ) ,
  .next_pending  ( next_pending          )
);
axi_protocol_converter_v2_1_13_b2s_rd_cmd_fsm ar_cmd_fsm_0
(
  .clk          ( clk            ) ,
  .reset        ( reset          ) ,
  .s_arready    ( s_arready      ) ,
  .s_arvalid    ( s_arvalid      ) ,
  .s_arlen      ( s_arlen        ) ,
  .m_arvalid    ( m_arvalid      ) ,
  .m_arready    ( m_arready      ) ,
  .next         ( next           ) ,
  .next_pending ( next_pending   ) ,
  .data_ready   ( ~r_full        ) ,
  .a_push       ( a_push         ) ,
  .r_push       ( r_push         )
);
assign r_arid  = s_arid_r;
assign r_rlast = ~next_pending;
always @(posedge clk) begin
  s_arid_r <= s_arid ;
end
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s #(
  parameter C_S_AXI_PROTOCOL                      = 0,
  parameter integer C_AXI_ID_WIDTH                = 4,
  parameter integer C_AXI_ADDR_WIDTH              = 30,
  parameter integer C_AXI_DATA_WIDTH              = 32,
  parameter integer C_AXI_SUPPORTS_WRITE          = 1,
  parameter integer C_AXI_SUPPORTS_READ           = 1
)
(
  input  wire                               aclk              ,
  input  wire                               aresetn           ,
  input  wire [C_AXI_ID_WIDTH-1:0]          s_axi_awid        ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]        s_axi_awaddr      ,
  input  wire [((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_awlen,
  input  wire [2:0]                         s_axi_awsize      ,
  input  wire [1:0]                         s_axi_awburst     ,
  input  wire [2:0]                         s_axi_awprot      ,
  input  wire                               s_axi_awvalid     ,
  output wire                               s_axi_awready     ,
  input  wire [C_AXI_DATA_WIDTH-1:0]        s_axi_wdata       ,
  input  wire [C_AXI_DATA_WIDTH/8-1:0]      s_axi_wstrb       ,
  input  wire                               s_axi_wlast       ,
  input  wire                               s_axi_wvalid      ,
  output wire                               s_axi_wready      ,
  output wire [C_AXI_ID_WIDTH-1:0]          s_axi_bid         ,
  output wire [1:0]                         s_axi_bresp       ,
  output wire                               s_axi_bvalid      ,
  input  wire                               s_axi_bready      ,
  input  wire [C_AXI_ID_WIDTH-1:0]          s_axi_arid        ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]        s_axi_araddr      ,
  input  wire [((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_arlen,
  input  wire [2:0]                         s_axi_arsize      ,
  input  wire [1:0]                         s_axi_arburst     ,
  input  wire [2:0]                         s_axi_arprot      ,
  input  wire                               s_axi_arvalid     ,
  output wire                               s_axi_arready     ,
  output wire [C_AXI_ID_WIDTH-1:0]          s_axi_rid         ,
  output wire [C_AXI_DATA_WIDTH-1:0]        s_axi_rdata       ,
  output wire [1:0]                         s_axi_rresp       ,
  output wire                               s_axi_rlast       ,
  output wire                               s_axi_rvalid      ,
  input  wire                               s_axi_rready      ,
  output wire [C_AXI_ADDR_WIDTH-1:0]        m_axi_awaddr      ,
  output wire [2:0]                         m_axi_awprot      ,
  output wire                               m_axi_awvalid     ,
  input  wire                               m_axi_awready     ,
  output wire [C_AXI_DATA_WIDTH-1:0]        m_axi_wdata       ,
  output wire [C_AXI_DATA_WIDTH/8-1:0]      m_axi_wstrb       ,
  output wire                               m_axi_wvalid      ,
  input  wire                               m_axi_wready      ,
  input  wire [1:0]                         m_axi_bresp       ,
  input  wire                               m_axi_bvalid      ,
  output wire                               m_axi_bready      ,
  output wire [C_AXI_ADDR_WIDTH-1:0]        m_axi_araddr      ,
  output wire [2:0]                         m_axi_arprot      ,
  output wire                               m_axi_arvalid     ,
  input  wire                               m_axi_arready     ,
  input  wire [C_AXI_DATA_WIDTH-1:0]        m_axi_rdata       ,
  input  wire [1:0]                         m_axi_rresp       ,
  input  wire                               m_axi_rvalid      ,
  output wire                               m_axi_rready
);
reg                            areset_d1 = 1'b0;
always @(posedge aclk)
  areset_d1 <= ~aresetn;
wire                                b_push;
wire [C_AXI_ID_WIDTH-1:0]           b_awid;
wire [7:0]                          b_awlen;
wire                                b_full;
wire [C_AXI_ID_WIDTH-1:0]                   si_rs_awid;
wire [C_AXI_ADDR_WIDTH-1:0]                 si_rs_awaddr;
wire [8-1:0]                                si_rs_awlen;
wire [3-1:0]                                si_rs_awsize;
wire [2-1:0]                                si_rs_awburst;
wire [3-1:0]                                si_rs_awprot;
wire                                        si_rs_awvalid;
wire                                        si_rs_awready;
wire [C_AXI_DATA_WIDTH-1:0]                 si_rs_wdata;
wire [C_AXI_DATA_WIDTH/8-1:0]               si_rs_wstrb;
wire                                        si_rs_wlast;
wire                                        si_rs_wvalid;
wire                                        si_rs_wready;
wire [C_AXI_ID_WIDTH-1:0]                   si_rs_bid;
wire [2-1:0]                                si_rs_bresp;
wire                                        si_rs_bvalid;
wire                                        si_rs_bready;
wire [C_AXI_ID_WIDTH-1:0]                   si_rs_arid;
wire [C_AXI_ADDR_WIDTH-1:0]                 si_rs_araddr;
wire [8-1:0]                                si_rs_arlen;
wire [3-1:0]                                si_rs_arsize;
wire [2-1:0]                                si_rs_arburst;
wire [3-1:0]                                si_rs_arprot;
wire                                        si_rs_arvalid;
wire                                        si_rs_arready;
wire [C_AXI_ID_WIDTH-1:0]                   si_rs_rid;
wire [C_AXI_DATA_WIDTH-1:0]                 si_rs_rdata;
wire [2-1:0]                                si_rs_rresp;
wire                                        si_rs_rlast;
wire                                        si_rs_rvalid;
wire                                        si_rs_rready;
wire [C_AXI_ADDR_WIDTH-1:0]                 rs_mi_awaddr;
wire                                        rs_mi_awvalid;
wire                                        rs_mi_awready;
wire [C_AXI_DATA_WIDTH-1:0]                 rs_mi_wdata;
wire [C_AXI_DATA_WIDTH/8-1:0]               rs_mi_wstrb;
wire                                        rs_mi_wvalid;
wire                                        rs_mi_wready;
wire [2-1:0]                                rs_mi_bresp;
wire                                        rs_mi_bvalid;
wire                                        rs_mi_bready;
wire [C_AXI_ADDR_WIDTH-1:0]                 rs_mi_araddr;
wire                                        rs_mi_arvalid;
wire                                        rs_mi_arready;
wire [C_AXI_DATA_WIDTH-1:0]                 rs_mi_rdata;
wire [2-1:0]                                rs_mi_rresp;
wire                                        rs_mi_rvalid;
wire                                        rs_mi_rready;
axi_register_slice_v2_1_13_axi_register_slice #(
  .C_AXI_PROTOCOL              ( C_S_AXI_PROTOCOL            ) ,
  .C_AXI_ID_WIDTH              ( C_AXI_ID_WIDTH              ) ,
  .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
  .C_AXI_DATA_WIDTH            ( C_AXI_DATA_WIDTH            ) ,
  .C_AXI_SUPPORTS_USER_SIGNALS ( 0 ) ,
  .C_AXI_AWUSER_WIDTH          ( 1 ) ,
  .C_AXI_ARUSER_WIDTH          ( 1 ) ,
  .C_AXI_WUSER_WIDTH           ( 1 ) ,
  .C_AXI_RUSER_WIDTH           ( 1 ) ,
  .C_AXI_BUSER_WIDTH           ( 1 ) ,
  .C_REG_CONFIG_AW             ( 1 ) ,
  .C_REG_CONFIG_AR             ( 1 ) ,
  .C_REG_CONFIG_W              ( 0 ) ,
  .C_REG_CONFIG_R              ( 1 ) ,
  .C_REG_CONFIG_B              ( 1 )
) SI_REG (
  .aresetn                    ( aresetn     ) ,
  .aclk                       ( aclk          ) ,
  .s_axi_awid                 ( s_axi_awid    ) ,
  .s_axi_awaddr               ( s_axi_awaddr  ) ,
  .s_axi_awlen                ( s_axi_awlen   ) ,
  .s_axi_awsize               ( s_axi_awsize  ) ,
  .s_axi_awburst              ( s_axi_awburst ) ,
  .s_axi_awlock               ( {((C_S_AXI_PROTOCOL == 1) ? 2 : 1){1'b0}}  ) ,
  .s_axi_awcache              ( 4'h0 ) ,
  .s_axi_awprot               ( s_axi_awprot  ) ,
  .s_axi_awqos                ( 4'h0 ) ,
  .s_axi_awuser               ( 1'b0  ) ,
  .s_axi_awvalid              ( s_axi_awvalid ) ,
  .s_axi_awready              ( s_axi_awready ) ,
  .s_axi_awregion             ( 4'h0 ) ,
  .s_axi_wid                  ( {C_AXI_ID_WIDTH{1'b0}} ) ,
  .s_axi_wdata                ( s_axi_wdata   ) ,
  .s_axi_wstrb                ( s_axi_wstrb   ) ,
  .s_axi_wlast                ( s_axi_wlast   ) ,
  .s_axi_wuser                ( 1'b0  ) ,
  .s_axi_wvalid               ( s_axi_wvalid  ) ,
  .s_axi_wready               ( s_axi_wready  ) ,
  .s_axi_bid                  ( s_axi_bid     ) ,
  .s_axi_bresp                ( s_axi_bresp   ) ,
  .s_axi_buser                ( ) ,
  .s_axi_bvalid               ( s_axi_bvalid  ) ,
  .s_axi_bready               ( s_axi_bready  ) ,
  .s_axi_arid                 ( s_axi_arid    ) ,
  .s_axi_araddr               ( s_axi_araddr  ) ,
  .s_axi_arlen                ( s_axi_arlen   ) ,
  .s_axi_arsize               ( s_axi_arsize  ) ,
  .s_axi_arburst              ( s_axi_arburst ) ,
  .s_axi_arlock               ( {((C_S_AXI_PROTOCOL == 1) ? 2 : 1){1'b0}}  ) ,
  .s_axi_arcache              ( 4'h0 ) ,
  .s_axi_arprot               ( s_axi_arprot  ) ,
  .s_axi_arqos                ( 4'h0 ) ,
  .s_axi_aruser               ( 1'b0  ) ,
  .s_axi_arvalid              ( s_axi_arvalid ) ,
  .s_axi_arready              ( s_axi_arready ) ,
  .s_axi_arregion             ( 4'h0 ) ,
  .s_axi_rid                  ( s_axi_rid     ) ,
  .s_axi_rdata                ( s_axi_rdata   ) ,
  .s_axi_rresp                ( s_axi_rresp   ) ,
  .s_axi_rlast                ( s_axi_rlast   ) ,
  .s_axi_ruser                ( ) ,
  .s_axi_rvalid               ( s_axi_rvalid  ) ,
  .s_axi_rready               ( s_axi_rready  ) ,
  .m_axi_awid                 ( si_rs_awid    ) ,
  .m_axi_awaddr               ( si_rs_awaddr  ) ,
  .m_axi_awlen                ( si_rs_awlen[((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] ) ,
  .m_axi_awsize               ( si_rs_awsize  ) ,
  .m_axi_awburst              ( si_rs_awburst ) ,
  .m_axi_awlock               ( ) ,
  .m_axi_awcache              ( ) ,
  .m_axi_awprot               ( si_rs_awprot  ) ,
  .m_axi_awqos                ( ) ,
  .m_axi_awuser               ( ) ,
  .m_axi_awvalid              ( si_rs_awvalid ) ,
  .m_axi_awready              ( si_rs_awready ) ,
  .m_axi_awregion             ( ) ,
  .m_axi_wid                  ( ) ,
  .m_axi_wdata                ( si_rs_wdata   ) ,
  .m_axi_wstrb                ( si_rs_wstrb   ) ,
  .m_axi_wlast                ( si_rs_wlast   ) ,
  .m_axi_wuser                ( ) ,
  .m_axi_wvalid               ( si_rs_wvalid  ) ,
  .m_axi_wready               ( si_rs_wready  ) ,
  .m_axi_bid                  ( si_rs_bid     ) ,
  .m_axi_bresp                ( si_rs_bresp   ) ,
  .m_axi_buser                ( 1'b0 ) ,
  .m_axi_bvalid               ( si_rs_bvalid  ) ,
  .m_axi_bready               ( si_rs_bready  ) ,
  .m_axi_arid                 ( si_rs_arid    ) ,
  .m_axi_araddr               ( si_rs_araddr  ) ,
  .m_axi_arlen                ( si_rs_arlen[((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] ) ,
  .m_axi_arsize               ( si_rs_arsize  ) ,
  .m_axi_arburst              ( si_rs_arburst ) ,
  .m_axi_arlock               ( ) ,
  .m_axi_arcache              ( ) ,
  .m_axi_arprot               ( si_rs_arprot  ) ,
  .m_axi_arqos                ( ) ,
  .m_axi_aruser               ( ) ,
  .m_axi_arvalid              ( si_rs_arvalid ) ,
  .m_axi_arready              ( si_rs_arready ) ,
  .m_axi_arregion             ( ) ,
  .m_axi_rid                  ( si_rs_rid     ) ,
  .m_axi_rdata                ( si_rs_rdata   ) ,
  .m_axi_rresp                ( si_rs_rresp   ) ,
  .m_axi_rlast                ( si_rs_rlast   ) ,
  .m_axi_ruser                ( 1'b0 ) ,
  .m_axi_rvalid               ( si_rs_rvalid  ) ,
  .m_axi_rready               ( si_rs_rready  )
);
generate
  if (C_AXI_SUPPORTS_WRITE == 1) begin : WR
    axi_protocol_converter_v2_1_13_b2s_aw_channel #
    (
      .C_ID_WIDTH                       ( C_AXI_ID_WIDTH   ),
      .C_AXI_ADDR_WIDTH                 ( C_AXI_ADDR_WIDTH )
    )
    aw_channel_0
    (
      .clk                              ( aclk              ) ,
      .reset                            ( areset_d1         ) ,
      .s_awid                           ( si_rs_awid        ) ,
      .s_awaddr                         ( si_rs_awaddr      ) ,
      .s_awlen                          ( (C_S_AXI_PROTOCOL == 1) ? {4'h0,si_rs_awlen[3:0]} : si_rs_awlen),
      .s_awsize                         ( si_rs_awsize      ) ,
      .s_awburst                        ( si_rs_awburst     ) ,
      .s_awvalid                        ( si_rs_awvalid     ) ,
      .s_awready                        ( si_rs_awready     ) ,
      .m_awvalid                        ( rs_mi_awvalid     ) ,
      .m_awaddr                         ( rs_mi_awaddr      ) ,
      .m_awready                        ( rs_mi_awready     ) ,
      .b_push                           ( b_push            ) ,
      .b_awid                           ( b_awid            ) ,
      .b_awlen                          ( b_awlen           ) ,
      .b_full                           ( b_full            )
    );
    axi_protocol_converter_v2_1_13_b2s_b_channel #
    (
      .C_ID_WIDTH                       ( C_AXI_ID_WIDTH   )
    )
    b_channel_0
    (
      .clk                              ( aclk            ) ,
      .reset                            ( areset_d1       ) ,
      .s_bid                            ( si_rs_bid       ) ,
      .s_bresp                          ( si_rs_bresp     ) ,
      .s_bvalid                         ( si_rs_bvalid    ) ,
      .s_bready                         ( si_rs_bready    ) ,
      .m_bready                         ( rs_mi_bready    ) ,
      .m_bvalid                         ( rs_mi_bvalid    ) ,
      .m_bresp                          ( rs_mi_bresp     ) ,
      .b_push                           ( b_push          ) ,
      .b_awid                           ( b_awid          ) ,
      .b_awlen                          ( b_awlen         ) ,
      .b_full                           ( b_full          ) ,
      .b_resp_rdy                       ( si_rs_awready   )
    );
    assign rs_mi_wdata        = si_rs_wdata;
    assign rs_mi_wstrb        = si_rs_wstrb;
    assign rs_mi_wvalid       = si_rs_wvalid;
    assign si_rs_wready       = rs_mi_wready;
  end else begin : NO_WR
    assign rs_mi_awaddr       = {C_AXI_ADDR_WIDTH{1'b0}};
    assign rs_mi_awvalid      = 1'b0;
    assign si_rs_awready      = 1'b0;
    assign rs_mi_wdata        = {C_AXI_DATA_WIDTH{1'b0}};
    assign rs_mi_wstrb        = {C_AXI_DATA_WIDTH/8{1'b0}};
    assign rs_mi_wvalid       = 1'b0;
    assign si_rs_wready       = 1'b0;
    assign rs_mi_bready    = 1'b0;
    assign si_rs_bvalid       = 1'b0;
    assign si_rs_bresp        = 2'b00;
    assign si_rs_bid          = {C_AXI_ID_WIDTH{1'b0}};
  end
endgenerate
wire                                r_push        ;
wire [C_AXI_ID_WIDTH-1:0]           r_arid        ;
wire                                r_rlast       ;
wire                                r_full        ;
generate
  if (C_AXI_SUPPORTS_READ == 1) begin : RD
    axi_protocol_converter_v2_1_13_b2s_ar_channel #
    (
      .C_ID_WIDTH                       ( C_AXI_ID_WIDTH   ),
      .C_AXI_ADDR_WIDTH                 ( C_AXI_ADDR_WIDTH )
    )
    ar_channel_0
    (
      .clk                              ( aclk              ) ,
      .reset                            ( areset_d1         ) ,
      .s_arid                           ( si_rs_arid        ) ,
      .s_araddr                         ( si_rs_araddr      ) ,
      .s_arlen                          ( (C_S_AXI_PROTOCOL == 1) ? {4'h0,si_rs_arlen[3:0]} : si_rs_arlen),
      .s_arsize                         ( si_rs_arsize      ) ,
      .s_arburst                        ( si_rs_arburst     ) ,
      .s_arvalid                        ( si_rs_arvalid     ) ,
      .s_arready                        ( si_rs_arready     ) ,
      .m_arvalid                        ( rs_mi_arvalid     ) ,
      .m_araddr                         ( rs_mi_araddr      ) ,
      .m_arready                        ( rs_mi_arready     ) ,
      .r_push                           ( r_push            ) ,
      .r_arid                           ( r_arid            ) ,
      .r_rlast                          ( r_rlast           ) ,
      .r_full                           ( r_full            )
    );
    axi_protocol_converter_v2_1_13_b2s_r_channel #
    (
      .C_ID_WIDTH                       ( C_AXI_ID_WIDTH   ),
      .C_DATA_WIDTH                     ( C_AXI_DATA_WIDTH )
    )
    r_channel_0
    (
      .clk                              ( aclk            ) ,
      .reset                            ( areset_d1       ) ,
      .s_rid                            ( si_rs_rid       ) ,
      .s_rdata                          ( si_rs_rdata     ) ,
      .s_rresp                          ( si_rs_rresp     ) ,
      .s_rlast                          ( si_rs_rlast     ) ,
      .s_rvalid                         ( si_rs_rvalid    ) ,
      .s_rready                         ( si_rs_rready    ) ,
      .m_rvalid                         ( rs_mi_rvalid    ) ,
      .m_rready                         ( rs_mi_rready    ) ,
      .m_rdata                          ( rs_mi_rdata     ) ,
      .m_rresp                          ( rs_mi_rresp     ) ,
      .r_push                           ( r_push          ) ,
      .r_full                           ( r_full          ) ,
      .r_arid                           ( r_arid          ) ,
      .r_rlast                          ( r_rlast         )
    );
  end else begin : NO_RD
    assign rs_mi_araddr       = {C_AXI_ADDR_WIDTH{1'b0}};
    assign rs_mi_arvalid      = 1'b0;
    assign si_rs_arready      = 1'b0;
    assign si_rs_rlast        = 1'b1;
    assign si_rs_rdata        = {C_AXI_DATA_WIDTH{1'b0}};
    assign si_rs_rvalid       = 1'b0;
    assign si_rs_rresp        = 2'b00;
    assign si_rs_rid          = {C_AXI_ID_WIDTH{1'b0}};
    assign rs_mi_rready       = 1'b0;
  end
endgenerate
axi_register_slice_v2_1_13_axi_register_slice #(
  .C_AXI_PROTOCOL              ( 2 ) ,
  .C_AXI_ID_WIDTH              ( 1 ) ,
  .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
  .C_AXI_DATA_WIDTH            ( C_AXI_DATA_WIDTH            ) ,
  .C_AXI_SUPPORTS_USER_SIGNALS ( 0 ) ,
  .C_AXI_AWUSER_WIDTH          ( 1 ) ,
  .C_AXI_ARUSER_WIDTH          ( 1 ) ,
  .C_AXI_WUSER_WIDTH           ( 1 ) ,
  .C_AXI_RUSER_WIDTH           ( 1 ) ,
  .C_AXI_BUSER_WIDTH           ( 1 ) ,
  .C_REG_CONFIG_AW             ( 0 ) ,
  .C_REG_CONFIG_AR             ( 0 ) ,
  .C_REG_CONFIG_W              ( 0 ) ,
  .C_REG_CONFIG_R              ( 0 ) ,
  .C_REG_CONFIG_B              ( 0 )
) MI_REG (
  .aresetn                    ( aresetn       ) ,
  .aclk                       ( aclk          ) ,
  .s_axi_awid                 ( 1'b0          ) ,
  .s_axi_awaddr               ( rs_mi_awaddr  ) ,
  .s_axi_awlen                ( 8'h00         ) ,
  .s_axi_awsize               ( 3'b000        ) ,
  .s_axi_awburst              ( 2'b01         ) ,
  .s_axi_awlock               ( 1'b0          ) ,
  .s_axi_awcache              ( 4'h0          ) ,
  .s_axi_awprot               ( si_rs_awprot  ) ,
  .s_axi_awqos                ( 4'h0          ) ,
  .s_axi_awuser               ( 1'b0          ) ,
  .s_axi_awvalid              ( rs_mi_awvalid ) ,
  .s_axi_awready              ( rs_mi_awready ) ,
  .s_axi_awregion             ( 4'h0          ) ,
  .s_axi_wid                  ( 1'b0          ) ,
  .s_axi_wdata                ( rs_mi_wdata   ) ,
  .s_axi_wstrb                ( rs_mi_wstrb   ) ,
  .s_axi_wlast                ( 1'b1          ) ,
  .s_axi_wuser                ( 1'b0          ) ,
  .s_axi_wvalid               ( rs_mi_wvalid  ) ,
  .s_axi_wready               ( rs_mi_wready  ) ,
  .s_axi_bid                  (               ) ,
  .s_axi_bresp                ( rs_mi_bresp   ) ,
  .s_axi_buser                (               ) ,
  .s_axi_bvalid               ( rs_mi_bvalid  ) ,
  .s_axi_bready               ( rs_mi_bready  ) ,
  .s_axi_arid                 ( 1'b0          ) ,
  .s_axi_araddr               ( rs_mi_araddr  ) ,
  .s_axi_arlen                ( 8'h00         ) ,
  .s_axi_arsize               ( 3'b000        ) ,
  .s_axi_arburst              ( 2'b01         ) ,
  .s_axi_arlock               ( 1'b0          ) ,
  .s_axi_arcache              ( 4'h0          ) ,
  .s_axi_arprot               ( si_rs_arprot  ) ,
  .s_axi_arqos                ( 4'h0          ) ,
  .s_axi_aruser               ( 1'b0          ) ,
  .s_axi_arvalid              ( rs_mi_arvalid ) ,
  .s_axi_arready              ( rs_mi_arready ) ,
  .s_axi_arregion             ( 4'h0          ) ,
  .s_axi_rid                  (               ) ,
  .s_axi_rdata                ( rs_mi_rdata   ) ,
  .s_axi_rresp                ( rs_mi_rresp   ) ,
  .s_axi_rlast                (               ) ,
  .s_axi_ruser                (               ) ,
  .s_axi_rvalid               ( rs_mi_rvalid  ) ,
  .s_axi_rready               ( rs_mi_rready  ) ,
  .m_axi_awid                 (               ) ,
  .m_axi_awaddr               ( m_axi_awaddr  ) ,
  .m_axi_awlen                (               ) ,
  .m_axi_awsize               (               ) ,
  .m_axi_awburst              (               ) ,
  .m_axi_awlock               (               ) ,
  .m_axi_awcache              (               ) ,
  .m_axi_awprot               ( m_axi_awprot  ) ,
  .m_axi_awqos                (               ) ,
  .m_axi_awuser               (               ) ,
  .m_axi_awvalid              ( m_axi_awvalid ) ,
  .m_axi_awready              ( m_axi_awready ) ,
  .m_axi_awregion             (               ) ,
  .m_axi_wid                  (               ) ,
  .m_axi_wdata                ( m_axi_wdata   ) ,
  .m_axi_wstrb                ( m_axi_wstrb   ) ,
  .m_axi_wlast                (               ) ,
  .m_axi_wuser                (               ) ,
  .m_axi_wvalid               ( m_axi_wvalid  ) ,
  .m_axi_wready               ( m_axi_wready  ) ,
  .m_axi_bid                  ( 1'b0          ) ,
  .m_axi_bresp                ( m_axi_bresp   ) ,
  .m_axi_buser                ( 1'b0          ) ,
  .m_axi_bvalid               ( m_axi_bvalid  ) ,
  .m_axi_bready               ( m_axi_bready  ) ,
  .m_axi_arid                 (               ) ,
  .m_axi_araddr               ( m_axi_araddr  ) ,
  .m_axi_arlen                (               ) ,
  .m_axi_arsize               (               ) ,
  .m_axi_arburst              (               ) ,
  .m_axi_arlock               (               ) ,
  .m_axi_arcache              (               ) ,
  .m_axi_arprot               ( m_axi_arprot  ) ,
  .m_axi_arqos                (               ) ,
  .m_axi_aruser               (               ) ,
  .m_axi_arvalid              ( m_axi_arvalid ) ,
  .m_axi_arready              ( m_axi_arready ) ,
  .m_axi_arregion             (               ) ,
  .m_axi_rid                  ( 1'b0          ) ,
  .m_axi_rdata                ( m_axi_rdata   ) ,
  .m_axi_rresp                ( m_axi_rresp   ) ,
  .m_axi_rlast                ( 1'b1          ) ,
  .m_axi_ruser                ( 1'b0          ) ,
  .m_axi_rvalid               ( m_axi_rvalid  ) ,
  .m_axi_rready               ( m_axi_rready  )
);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_axi_protocol_converter #(
  parameter         C_FAMILY                    = "virtex6",
  parameter integer C_M_AXI_PROTOCOL            = 0, 
  parameter integer C_S_AXI_PROTOCOL            = 0, 
  parameter integer C_IGNORE_ID                = 0,
  parameter integer C_AXI_ID_WIDTH              = 4,
  parameter integer C_AXI_ADDR_WIDTH            = 32,
  parameter integer C_AXI_DATA_WIDTH            = 32,
  parameter integer C_AXI_SUPPORTS_WRITE        = 1,
  parameter integer C_AXI_SUPPORTS_READ         = 1,
  parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
  parameter integer C_AXI_AWUSER_WIDTH          = 1,
  parameter integer C_AXI_ARUSER_WIDTH          = 1,
  parameter integer C_AXI_WUSER_WIDTH           = 1,
  parameter integer C_AXI_RUSER_WIDTH           = 1,
  parameter integer C_AXI_BUSER_WIDTH           = 1,
  parameter integer C_TRANSLATION_MODE                  = 1
) (
   input wire aclk,
   input wire aresetn,
   input  wire [C_AXI_ID_WIDTH-1:0]     s_axi_awid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,
   input  wire [((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_awlen,
   input  wire [3-1:0]                  s_axi_awsize,
   input  wire [2-1:0]                  s_axi_awburst,
   input  wire [((C_S_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  s_axi_awlock,
   input  wire [4-1:0]                  s_axi_awcache,
   input  wire [3-1:0]                  s_axi_awprot,
   input  wire [4-1:0]                  s_axi_awregion,
   input  wire [4-1:0]                  s_axi_awqos,
   input  wire [C_AXI_AWUSER_WIDTH-1:0] s_axi_awuser,
   input  wire                          s_axi_awvalid,
   output wire                          s_axi_awready,
   input wire [C_AXI_ID_WIDTH-1:0]      s_axi_wid,
   input  wire [C_AXI_DATA_WIDTH-1:0]   s_axi_wdata,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
   input  wire                          s_axi_wlast,
   input  wire [C_AXI_WUSER_WIDTH-1:0]  s_axi_wuser,
   input  wire                          s_axi_wvalid,
   output wire                          s_axi_wready,
   output wire [C_AXI_ID_WIDTH-1:0]    s_axi_bid,
   output wire [2-1:0]                 s_axi_bresp,
   output wire [C_AXI_BUSER_WIDTH-1:0] s_axi_buser,
   output wire                         s_axi_bvalid,
   input  wire                         s_axi_bready,
   input  wire [C_AXI_ID_WIDTH-1:0]     s_axi_arid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   s_axi_araddr,
   input  wire [((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_arlen,
   input  wire [3-1:0]                  s_axi_arsize,
   input  wire [2-1:0]                  s_axi_arburst,
   input  wire [((C_S_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  s_axi_arlock,
   input  wire [4-1:0]                  s_axi_arcache,
   input  wire [3-1:0]                  s_axi_arprot,
   input  wire [4-1:0]                  s_axi_arregion,
   input  wire [4-1:0]                  s_axi_arqos,
   input  wire [C_AXI_ARUSER_WIDTH-1:0] s_axi_aruser,
   input  wire                          s_axi_arvalid,
   output wire                          s_axi_arready,
   output wire [C_AXI_ID_WIDTH-1:0]    s_axi_rid,
   output wire [C_AXI_DATA_WIDTH-1:0]  s_axi_rdata,
   output wire [2-1:0]                 s_axi_rresp,
   output wire                         s_axi_rlast,
   output wire [C_AXI_RUSER_WIDTH-1:0] s_axi_ruser,
   output wire                         s_axi_rvalid,
   input  wire                         s_axi_rready,
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_awid,
   output wire [C_AXI_ADDR_WIDTH-1:0]   m_axi_awaddr,
   output wire [((C_M_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_awlen,
   output wire [3-1:0]                  m_axi_awsize,
   output wire [2-1:0]                  m_axi_awburst,
   output wire [((C_M_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_awlock,
   output wire [4-1:0]                  m_axi_awcache,
   output wire [3-1:0]                  m_axi_awprot,
   output wire [4-1:0]                  m_axi_awregion,
   output wire [4-1:0]                  m_axi_awqos,
   output wire [C_AXI_AWUSER_WIDTH-1:0] m_axi_awuser,
   output wire                          m_axi_awvalid,
   input  wire                          m_axi_awready,
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_wid,
   output wire [C_AXI_DATA_WIDTH-1:0]   m_axi_wdata,
   output wire [C_AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,
   output wire                          m_axi_wlast,
   output wire [C_AXI_WUSER_WIDTH-1:0]  m_axi_wuser,
   output wire                          m_axi_wvalid,
   input  wire                          m_axi_wready,
   input  wire [C_AXI_ID_WIDTH-1:0]    m_axi_bid,
   input  wire [2-1:0]                 m_axi_bresp,
   input  wire [C_AXI_BUSER_WIDTH-1:0] m_axi_buser,
   input  wire                         m_axi_bvalid,
   output wire                         m_axi_bready,
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_arid,
   output wire [C_AXI_ADDR_WIDTH-1:0]   m_axi_araddr,
   output wire [((C_M_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_arlen,
   output wire [3-1:0]                  m_axi_arsize,
   output wire [2-1:0]                  m_axi_arburst,
   output wire [((C_M_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_arlock,
   output wire [4-1:0]                  m_axi_arcache,
   output wire [3-1:0]                  m_axi_arprot,
   output wire [4-1:0]                  m_axi_arregion,
   output wire [4-1:0]                  m_axi_arqos,
   output wire [C_AXI_ARUSER_WIDTH-1:0] m_axi_aruser,
   output wire                          m_axi_arvalid,
   input  wire                          m_axi_arready,
   input  wire [C_AXI_ID_WIDTH-1:0]    m_axi_rid,
   input  wire [C_AXI_DATA_WIDTH-1:0]  m_axi_rdata,
   input  wire [2-1:0]                 m_axi_rresp,
   input  wire                         m_axi_rlast,
   input  wire [C_AXI_RUSER_WIDTH-1:0] m_axi_ruser,
   input  wire                         m_axi_rvalid,
   output wire                         m_axi_rready
);
localparam P_AXI4 = 32'h0;
localparam P_AXI3 = 32'h1;
localparam P_AXILITE = 32'h2;
localparam P_AXILITE_SIZE = (C_AXI_DATA_WIDTH == 32) ? 3'b010 : 3'b011;
localparam P_INCR = 2'b01;
localparam P_DECERR = 2'b11;
localparam P_SLVERR = 2'b10;
localparam integer P_PROTECTION = 1;
localparam integer P_CONVERSION = 2;
wire                          s_awvalid_i;
wire                          s_arvalid_i;
wire                          s_wvalid_i ;
wire                          s_bready_i ;
wire                          s_rready_i ;
wire                          s_awready_i; 
wire                          s_wready_i;
wire                          s_bvalid_i;
wire [C_AXI_ID_WIDTH-1:0]     s_bid_i;
wire [1:0]                    s_bresp_i;
wire [C_AXI_BUSER_WIDTH-1:0]  s_buser_i;
wire                          s_arready_i; 
wire                          s_rvalid_i;
wire [C_AXI_ID_WIDTH-1:0]     s_rid_i;
wire [1:0]                    s_rresp_i;
wire [C_AXI_RUSER_WIDTH-1:0]  s_ruser_i;
wire [C_AXI_DATA_WIDTH-1:0]   s_rdata_i;
wire                          s_rlast_i;
generate
  if ((C_M_AXI_PROTOCOL == P_AXILITE)  || (C_S_AXI_PROTOCOL == P_AXILITE)) begin : gen_axilite
    assign m_axi_awid         = 0;
    assign m_axi_awlen        = 0;
    assign m_axi_awsize       = P_AXILITE_SIZE;
    assign m_axi_awburst      = P_INCR;
    assign m_axi_awlock       = 0;
    assign m_axi_awcache      = 0;
    assign m_axi_awregion     = 0;
    assign m_axi_awqos        = 0;
    assign m_axi_awuser       = 0;
    assign m_axi_wid          = 0;
    assign m_axi_wlast        = 1'b1;
    assign m_axi_wuser        = 0;
    assign m_axi_arid         = 0;
    assign m_axi_arlen        = 0;
    assign m_axi_arsize       = P_AXILITE_SIZE;
    assign m_axi_arburst      = P_INCR;
    assign m_axi_arlock       = 0;
    assign m_axi_arcache      = 0;
    assign m_axi_arregion     = 0;
    assign m_axi_arqos        = 0;
    assign m_axi_aruser       = 0;
    if (((C_IGNORE_ID == 1) && (C_TRANSLATION_MODE != P_CONVERSION)) || (C_S_AXI_PROTOCOL == P_AXILITE)) begin : gen_axilite_passthru
      assign m_axi_awaddr       = s_axi_awaddr;
      assign m_axi_awprot       = s_axi_awprot;
      assign m_axi_awvalid      = s_awvalid_i;
      assign s_awready_i        = m_axi_awready;
      assign m_axi_wdata        = s_axi_wdata;
      assign m_axi_wstrb        = s_axi_wstrb;
      assign m_axi_wvalid       = s_wvalid_i;
      assign s_wready_i         = m_axi_wready;
      assign s_bid_i            = 0;
      assign s_bresp_i          = m_axi_bresp;
      assign s_buser_i          = 0;
      assign s_bvalid_i         = m_axi_bvalid;
      assign m_axi_bready       = s_bready_i;
      assign m_axi_araddr       = s_axi_araddr;
      assign m_axi_arprot       = s_axi_arprot;
      assign m_axi_arvalid      = s_arvalid_i;
      assign s_arready_i        = m_axi_arready;
      assign s_rid_i            = 0;
      assign s_rdata_i          = m_axi_rdata;
      assign s_rresp_i          = m_axi_rresp;
      assign s_rlast_i          = 1'b1;
      assign s_ruser_i          = 0;
      assign s_rvalid_i         = m_axi_rvalid;
      assign m_axi_rready       = s_rready_i;
    end else if (C_TRANSLATION_MODE == P_CONVERSION) begin : gen_b2s_conv
      assign s_buser_i = {C_AXI_BUSER_WIDTH{1'b0}};
      assign s_ruser_i = {C_AXI_RUSER_WIDTH{1'b0}};
      axi_protocol_converter_v2_1_13_b2s #(
        .C_S_AXI_PROTOCOL                 (C_S_AXI_PROTOCOL),
        .C_AXI_ID_WIDTH                   (C_AXI_ID_WIDTH),
        .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
        .C_AXI_DATA_WIDTH                 (C_AXI_DATA_WIDTH),
        .C_AXI_SUPPORTS_WRITE             (C_AXI_SUPPORTS_WRITE),
        .C_AXI_SUPPORTS_READ              (C_AXI_SUPPORTS_READ)
      ) axilite_b2s (
        .aresetn                          (aresetn),
        .aclk                             (aclk),
        .s_axi_awid                       (s_axi_awid),
        .s_axi_awaddr                     (s_axi_awaddr),
        .s_axi_awlen                      (s_axi_awlen),
        .s_axi_awsize                     (s_axi_awsize),
        .s_axi_awburst                    (s_axi_awburst),
        .s_axi_awprot                     (s_axi_awprot),
        .s_axi_awvalid                    (s_awvalid_i),
        .s_axi_awready                    (s_awready_i),
        .s_axi_wdata                      (s_axi_wdata),
        .s_axi_wstrb                      (s_axi_wstrb),
        .s_axi_wlast                      (s_axi_wlast),
        .s_axi_wvalid                     (s_wvalid_i),
        .s_axi_wready                     (s_wready_i),
        .s_axi_bid                        (s_bid_i),
        .s_axi_bresp                      (s_bresp_i),
        .s_axi_bvalid                     (s_bvalid_i),
        .s_axi_bready                     (s_bready_i),
        .s_axi_arid                       (s_axi_arid),
        .s_axi_araddr                     (s_axi_araddr),
        .s_axi_arlen                      (s_axi_arlen),
        .s_axi_arsize                     (s_axi_arsize),
        .s_axi_arburst                    (s_axi_arburst),
        .s_axi_arprot                     (s_axi_arprot),
        .s_axi_arvalid                    (s_arvalid_i),
        .s_axi_arready                    (s_arready_i),
        .s_axi_rid                        (s_rid_i),
        .s_axi_rdata                      (s_rdata_i),
        .s_axi_rresp                      (s_rresp_i),
        .s_axi_rlast                      (s_rlast_i),
        .s_axi_rvalid                     (s_rvalid_i),
        .s_axi_rready                     (s_rready_i),
        .m_axi_awaddr                     (m_axi_awaddr),
        .m_axi_awprot                     (m_axi_awprot),
        .m_axi_awvalid                    (m_axi_awvalid),
        .m_axi_awready                    (m_axi_awready),
        .m_axi_wdata                      (m_axi_wdata),
        .m_axi_wstrb                      (m_axi_wstrb),
        .m_axi_wvalid                     (m_axi_wvalid),
        .m_axi_wready                     (m_axi_wready),
        .m_axi_bresp                      (m_axi_bresp),
        .m_axi_bvalid                     (m_axi_bvalid),
        .m_axi_bready                     (m_axi_bready),
        .m_axi_araddr                     (m_axi_araddr),
        .m_axi_arprot                     (m_axi_arprot),
        .m_axi_arvalid                    (m_axi_arvalid),
        .m_axi_arready                    (m_axi_arready),
        .m_axi_rdata                      (m_axi_rdata),
        .m_axi_rresp                      (m_axi_rresp),
        .m_axi_rvalid                     (m_axi_rvalid),
        .m_axi_rready                     (m_axi_rready)
      );
    end else begin : gen_axilite_conv
      axi_protocol_converter_v2_1_13_axilite_conv #(
        .C_FAMILY                         (C_FAMILY),
        .C_AXI_ID_WIDTH                   (C_AXI_ID_WIDTH),
        .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
        .C_AXI_DATA_WIDTH                 (C_AXI_DATA_WIDTH),
        .C_AXI_SUPPORTS_WRITE             (C_AXI_SUPPORTS_WRITE),
        .C_AXI_SUPPORTS_READ              (C_AXI_SUPPORTS_READ),
        .C_AXI_RUSER_WIDTH                (C_AXI_RUSER_WIDTH),
        .C_AXI_BUSER_WIDTH                (C_AXI_BUSER_WIDTH)
      ) axilite_conv_inst (
        .ARESETN                          (aresetn),
        .ACLK                             (aclk),
        .S_AXI_AWID                       (s_axi_awid),
        .S_AXI_AWADDR                     (s_axi_awaddr),
        .S_AXI_AWPROT                     (s_axi_awprot),
        .S_AXI_AWVALID                    (s_awvalid_i),
        .S_AXI_AWREADY                    (s_awready_i),
        .S_AXI_WDATA                      (s_axi_wdata),
        .S_AXI_WSTRB                      (s_axi_wstrb),
        .S_AXI_WVALID                     (s_wvalid_i),
        .S_AXI_WREADY                     (s_wready_i),
        .S_AXI_BID                        (s_bid_i),
        .S_AXI_BRESP                      (s_bresp_i),
        .S_AXI_BUSER                      (s_buser_i),
        .S_AXI_BVALID                     (s_bvalid_i),
        .S_AXI_BREADY                     (s_bready_i),
        .S_AXI_ARID                       (s_axi_arid),
        .S_AXI_ARADDR                     (s_axi_araddr),
        .S_AXI_ARPROT                     (s_axi_arprot),
        .S_AXI_ARVALID                    (s_arvalid_i),
        .S_AXI_ARREADY                    (s_arready_i),
        .S_AXI_RID                        (s_rid_i),
        .S_AXI_RDATA                      (s_rdata_i),
        .S_AXI_RRESP                      (s_rresp_i),
        .S_AXI_RLAST                      (s_rlast_i),
        .S_AXI_RUSER                      (s_ruser_i),
        .S_AXI_RVALID                     (s_rvalid_i),
        .S_AXI_RREADY                     (s_rready_i),
        .M_AXI_AWADDR                     (m_axi_awaddr),
        .M_AXI_AWPROT                     (m_axi_awprot),
        .M_AXI_AWVALID                    (m_axi_awvalid),
        .M_AXI_AWREADY                    (m_axi_awready),
        .M_AXI_WDATA                      (m_axi_wdata),
        .M_AXI_WSTRB                      (m_axi_wstrb),
        .M_AXI_WVALID                     (m_axi_wvalid),
        .M_AXI_WREADY                     (m_axi_wready),
        .M_AXI_BRESP                      (m_axi_bresp),
        .M_AXI_BVALID                     (m_axi_bvalid),
        .M_AXI_BREADY                     (m_axi_bready),
        .M_AXI_ARADDR                     (m_axi_araddr),
        .M_AXI_ARPROT                     (m_axi_arprot),
        .M_AXI_ARVALID                    (m_axi_arvalid),
        .M_AXI_ARREADY                    (m_axi_arready),
        .M_AXI_RDATA                      (m_axi_rdata),
        .M_AXI_RRESP                      (m_axi_rresp),
        .M_AXI_RVALID                     (m_axi_rvalid),
        .M_AXI_RREADY                     (m_axi_rready)
      );
    end
  end else if ((C_M_AXI_PROTOCOL == P_AXI3) && (C_S_AXI_PROTOCOL == P_AXI4)) begin : gen_axi4_axi3
    axi_protocol_converter_v2_1_13_axi3_conv #(
      .C_FAMILY                         (C_FAMILY),
      .C_AXI_ID_WIDTH                   (C_AXI_ID_WIDTH),
      .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
      .C_AXI_DATA_WIDTH                 (C_AXI_DATA_WIDTH),
      .C_AXI_SUPPORTS_USER_SIGNALS      (C_AXI_SUPPORTS_USER_SIGNALS),
      .C_AXI_AWUSER_WIDTH               (C_AXI_AWUSER_WIDTH),
      .C_AXI_ARUSER_WIDTH               (C_AXI_ARUSER_WIDTH),
      .C_AXI_WUSER_WIDTH                (C_AXI_WUSER_WIDTH),
      .C_AXI_RUSER_WIDTH                (C_AXI_RUSER_WIDTH),
      .C_AXI_BUSER_WIDTH                (C_AXI_BUSER_WIDTH),
      .C_AXI_SUPPORTS_WRITE             (C_AXI_SUPPORTS_WRITE),
      .C_AXI_SUPPORTS_READ              (C_AXI_SUPPORTS_READ),
      .C_SUPPORT_SPLITTING              ((C_TRANSLATION_MODE == P_CONVERSION) ? 1 : 0)
    ) axi3_conv_inst (
      .ARESETN                          (aresetn),
      .ACLK                             (aclk),
      .S_AXI_AWID                       (s_axi_awid),
      .S_AXI_AWADDR                     (s_axi_awaddr),
      .S_AXI_AWLEN                      (s_axi_awlen),
      .S_AXI_AWSIZE                     (s_axi_awsize),
      .S_AXI_AWBURST                    (s_axi_awburst),
      .S_AXI_AWLOCK                     (s_axi_awlock),
      .S_AXI_AWCACHE                    (s_axi_awcache),
      .S_AXI_AWPROT                     (s_axi_awprot),
      .S_AXI_AWQOS                      (s_axi_awqos),
      .S_AXI_AWUSER                     (s_axi_awuser),
      .S_AXI_AWVALID                    (s_awvalid_i),
      .S_AXI_AWREADY                    (s_awready_i),
      .S_AXI_WDATA                      (s_axi_wdata),
      .S_AXI_WSTRB                      (s_axi_wstrb),
      .S_AXI_WLAST                      (s_axi_wlast),
      .S_AXI_WUSER                      (s_axi_wuser),
      .S_AXI_WVALID                     (s_wvalid_i),
      .S_AXI_WREADY                     (s_wready_i),
      .S_AXI_BID                        (s_bid_i),
      .S_AXI_BRESP                      (s_bresp_i),
      .S_AXI_BUSER                      (s_buser_i),
      .S_AXI_BVALID                     (s_bvalid_i),
      .S_AXI_BREADY                     (s_bready_i),
      .S_AXI_ARID                       (s_axi_arid),
      .S_AXI_ARADDR                     (s_axi_araddr),
      .S_AXI_ARLEN                      (s_axi_arlen),
      .S_AXI_ARSIZE                     (s_axi_arsize),
      .S_AXI_ARBURST                    (s_axi_arburst),
      .S_AXI_ARLOCK                     (s_axi_arlock),
      .S_AXI_ARCACHE                    (s_axi_arcache),
      .S_AXI_ARPROT                     (s_axi_arprot),
      .S_AXI_ARQOS                      (s_axi_arqos),
      .S_AXI_ARUSER                     (s_axi_aruser),
      .S_AXI_ARVALID                    (s_arvalid_i),
      .S_AXI_ARREADY                    (s_arready_i),
      .S_AXI_RID                        (s_rid_i),
      .S_AXI_RDATA                      (s_rdata_i),
      .S_AXI_RRESP                      (s_rresp_i),
      .S_AXI_RLAST                      (s_rlast_i),
      .S_AXI_RUSER                      (s_ruser_i),
      .S_AXI_RVALID                     (s_rvalid_i),
      .S_AXI_RREADY                     (s_rready_i),
      .M_AXI_AWID                       (m_axi_awid),
      .M_AXI_AWADDR                     (m_axi_awaddr),
      .M_AXI_AWLEN                      (m_axi_awlen),
      .M_AXI_AWSIZE                     (m_axi_awsize),
      .M_AXI_AWBURST                    (m_axi_awburst),
      .M_AXI_AWLOCK                     (m_axi_awlock),
      .M_AXI_AWCACHE                    (m_axi_awcache),
      .M_AXI_AWPROT                     (m_axi_awprot),
      .M_AXI_AWQOS                      (m_axi_awqos),
      .M_AXI_AWUSER                     (m_axi_awuser),
      .M_AXI_AWVALID                    (m_axi_awvalid),
      .M_AXI_AWREADY                    (m_axi_awready),
      .M_AXI_WID                        (m_axi_wid),
      .M_AXI_WDATA                      (m_axi_wdata),
      .M_AXI_WSTRB                      (m_axi_wstrb),
      .M_AXI_WLAST                      (m_axi_wlast),
      .M_AXI_WUSER                      (m_axi_wuser),
      .M_AXI_WVALID                     (m_axi_wvalid),
      .M_AXI_WREADY                     (m_axi_wready),
      .M_AXI_BID                        (m_axi_bid),
      .M_AXI_BRESP                      (m_axi_bresp),
      .M_AXI_BUSER                      (m_axi_buser),
      .M_AXI_BVALID                     (m_axi_bvalid),
      .M_AXI_BREADY                     (m_axi_bready),
      .M_AXI_ARID                       (m_axi_arid),
      .M_AXI_ARADDR                     (m_axi_araddr),
      .M_AXI_ARLEN                      (m_axi_arlen),
      .M_AXI_ARSIZE                     (m_axi_arsize),
      .M_AXI_ARBURST                    (m_axi_arburst),
      .M_AXI_ARLOCK                     (m_axi_arlock),
      .M_AXI_ARCACHE                    (m_axi_arcache),
      .M_AXI_ARPROT                     (m_axi_arprot),
      .M_AXI_ARQOS                      (m_axi_arqos),
      .M_AXI_ARUSER                     (m_axi_aruser),
      .M_AXI_ARVALID                    (m_axi_arvalid),
      .M_AXI_ARREADY                    (m_axi_arready),
      .M_AXI_RID                        (m_axi_rid),
      .M_AXI_RDATA                      (m_axi_rdata),
      .M_AXI_RRESP                      (m_axi_rresp),
      .M_AXI_RLAST                      (m_axi_rlast),
      .M_AXI_RUSER                      (m_axi_ruser),
      .M_AXI_RVALID                     (m_axi_rvalid),
      .M_AXI_RREADY                     (m_axi_rready)
    );
    assign m_axi_awregion     = 0;
    assign m_axi_arregion     = 0;
  end else if ((C_S_AXI_PROTOCOL == P_AXI3) && (C_M_AXI_PROTOCOL == P_AXI4)) begin : gen_axi3_axi4
    assign m_axi_awid                = s_axi_awid;
    assign m_axi_awaddr              = s_axi_awaddr;
    assign m_axi_awlen               = {4'h0, s_axi_awlen[3:0]};
    assign m_axi_awsize              = s_axi_awsize;
    assign m_axi_awburst             = s_axi_awburst;
    assign m_axi_awlock              = s_axi_awlock[0];
    assign m_axi_awcache             = s_axi_awcache;
    assign m_axi_awprot              = s_axi_awprot;
    assign m_axi_awregion            = 4'h0;
    assign m_axi_awqos               = s_axi_awqos;
    assign m_axi_awuser              = s_axi_awuser;
    assign m_axi_awvalid             = s_awvalid_i;
    assign s_awready_i               = m_axi_awready;
    assign m_axi_wid                 = {C_AXI_ID_WIDTH{1'b0}} ;
    assign m_axi_wdata               = s_axi_wdata;
    assign m_axi_wstrb               = s_axi_wstrb;
    assign m_axi_wlast               = s_axi_wlast;
    assign m_axi_wuser               = s_axi_wuser;
    assign m_axi_wvalid              = s_wvalid_i;
    assign s_wready_i                = m_axi_wready;
    assign s_bid_i                   = m_axi_bid;
    assign s_bresp_i                 = m_axi_bresp;
    assign s_buser_i                 = m_axi_buser;
    assign s_bvalid_i                = m_axi_bvalid;
    assign m_axi_bready              = s_bready_i;
    assign m_axi_arid                = s_axi_arid;
    assign m_axi_araddr              = s_axi_araddr;
    assign m_axi_arlen               = {4'h0, s_axi_arlen[3:0]};
    assign m_axi_arsize              = s_axi_arsize;
    assign m_axi_arburst             = s_axi_arburst;
    assign m_axi_arlock              = s_axi_arlock[0];
    assign m_axi_arcache             = s_axi_arcache;
    assign m_axi_arprot              = s_axi_arprot;
    assign m_axi_arregion            = 4'h0;
    assign m_axi_arqos               = s_axi_arqos;
    assign m_axi_aruser              = s_axi_aruser;
    assign m_axi_arvalid             = s_arvalid_i;
    assign s_arready_i               = m_axi_arready;
    assign s_rid_i                   = m_axi_rid;
    assign s_rdata_i                 = m_axi_rdata;
    assign s_rresp_i                 = m_axi_rresp;
    assign s_rlast_i                 = m_axi_rlast;
    assign s_ruser_i                 = m_axi_ruser;
    assign s_rvalid_i                = m_axi_rvalid;
    assign m_axi_rready              = s_rready_i;
  end else begin :gen_no_conv
    assign m_axi_awid                = s_axi_awid;
    assign m_axi_awaddr              = s_axi_awaddr;
    assign m_axi_awlen               = s_axi_awlen;
    assign m_axi_awsize              = s_axi_awsize;
    assign m_axi_awburst             = s_axi_awburst;
    assign m_axi_awlock              = s_axi_awlock;
    assign m_axi_awcache             = s_axi_awcache;
    assign m_axi_awprot              = s_axi_awprot;
    assign m_axi_awregion            = s_axi_awregion;
    assign m_axi_awqos               = s_axi_awqos;
    assign m_axi_awuser              = s_axi_awuser;
    assign m_axi_awvalid             = s_awvalid_i;
    assign s_awready_i               = m_axi_awready;
    assign m_axi_wid                 = s_axi_wid;
    assign m_axi_wdata               = s_axi_wdata;
    assign m_axi_wstrb               = s_axi_wstrb;
    assign m_axi_wlast               = s_axi_wlast;
    assign m_axi_wuser               = s_axi_wuser;
    assign m_axi_wvalid              = s_wvalid_i;
    assign s_wready_i                = m_axi_wready;
    assign s_bid_i                   = m_axi_bid;
    assign s_bresp_i                 = m_axi_bresp;
    assign s_buser_i                 = m_axi_buser;
    assign s_bvalid_i                = m_axi_bvalid;
    assign m_axi_bready              = s_bready_i;
    assign m_axi_arid                = s_axi_arid;
    assign m_axi_araddr              = s_axi_araddr;
    assign m_axi_arlen               = s_axi_arlen;
    assign m_axi_arsize              = s_axi_arsize;
    assign m_axi_arburst             = s_axi_arburst;
    assign m_axi_arlock              = s_axi_arlock;
    assign m_axi_arcache             = s_axi_arcache;
    assign m_axi_arprot              = s_axi_arprot;
    assign m_axi_arregion            = s_axi_arregion;
    assign m_axi_arqos               = s_axi_arqos;
    assign m_axi_aruser              = s_axi_aruser;
    assign m_axi_arvalid             = s_arvalid_i;
    assign s_arready_i               = m_axi_arready;
    assign s_rid_i                   = m_axi_rid;
    assign s_rdata_i                 = m_axi_rdata;
    assign s_rresp_i                 = m_axi_rresp;
    assign s_rlast_i                 = m_axi_rlast;
    assign s_ruser_i                 = m_axi_ruser;
    assign s_rvalid_i                = m_axi_rvalid;
    assign m_axi_rready              = s_rready_i;
  end
    if ((C_TRANSLATION_MODE == P_PROTECTION) && 
        (((C_S_AXI_PROTOCOL != P_AXILITE) && (C_M_AXI_PROTOCOL == P_AXILITE)) ||
        ((C_S_AXI_PROTOCOL == P_AXI4) && (C_M_AXI_PROTOCOL == P_AXI3)))) begin : gen_err_detect
      wire                           e_awvalid;
      reg                            e_awvalid_r = 1'b0;
      wire                           e_arvalid;
      reg                            e_arvalid_r = 1'b0;
      wire                           e_wvalid;
      wire                           e_bvalid;
      wire                           e_rvalid;
      reg                            e_awready = 1'b0;
      reg                            e_arready = 1'b0;
      wire                           e_wready;
      reg  [C_AXI_ID_WIDTH-1:0]      e_awid;
      reg  [C_AXI_ID_WIDTH-1:0]      e_arid;
      reg  [8-1:0]                   e_arlen;
      wire [C_AXI_ID_WIDTH-1:0]      e_bid;
      wire [C_AXI_ID_WIDTH-1:0]      e_rid;
      wire                           e_rlast;
      wire                           w_err;
      wire                           r_err;
      wire                           busy_aw;
      wire                           busy_w;
      wire                           busy_ar;
      wire                           aw_push;
      wire                           aw_pop;
      wire                           w_pop;
      wire                           ar_push;
      wire                           ar_pop;
      reg                            s_awvalid_pending = 1'b0;
      reg                            s_awvalid_en = 1'b0;
      reg                            s_arvalid_en = 1'b0;
      reg                            s_awready_en = 1'b0;
      reg                            s_arready_en = 1'b0;
      reg  [4:0]                     aw_cnt = 1'b0;
      reg  [4:0]                     ar_cnt = 1'b0;
      reg  [4:0]                     w_cnt = 1'b0;
      reg                            w_borrow = 1'b0;
      reg                            err_busy_w = 1'b0;
      reg                            err_busy_r = 1'b0;
      assign w_err = (C_M_AXI_PROTOCOL == P_AXILITE) ? (s_axi_awlen != 0) : ((s_axi_awlen>>4) != 0);
      assign r_err = (C_M_AXI_PROTOCOL == P_AXILITE) ? (s_axi_arlen != 0) : ((s_axi_arlen>>4) != 0);
      assign s_awvalid_i = s_axi_awvalid & s_awvalid_en & ~w_err;
      assign e_awvalid   = e_awvalid_r & ~busy_aw & ~busy_w;
      assign s_arvalid_i = s_axi_arvalid & s_arvalid_en & ~r_err;
      assign e_arvalid   = e_arvalid_r & ~busy_ar ;
      assign s_wvalid_i = s_axi_wvalid & (busy_w | (s_awvalid_pending & ~w_borrow));
      assign e_wvalid   = s_axi_wvalid & err_busy_w;
      assign s_bready_i = s_axi_bready & busy_aw;
      assign s_rready_i = s_axi_rready & busy_ar;
      assign s_axi_awready = (s_awready_i & s_awready_en) | e_awready; 
      assign s_axi_wready = (s_wready_i & (busy_w | (s_awvalid_pending & ~w_borrow))) | e_wready;
      assign s_axi_bvalid = (s_bvalid_i & busy_aw) | e_bvalid;
      assign s_axi_bid = err_busy_w ? e_bid : s_bid_i;
      assign s_axi_bresp = err_busy_w ? P_SLVERR : s_bresp_i;
      assign s_axi_buser = err_busy_w ? {C_AXI_BUSER_WIDTH{1'b0}} : s_buser_i;
      assign s_axi_arready = (s_arready_i & s_arready_en) | e_arready; 
      assign s_axi_rvalid = (s_rvalid_i & busy_ar) | e_rvalid;
      assign s_axi_rid = err_busy_r ? e_rid : s_rid_i;
      assign s_axi_rresp = err_busy_r ? P_SLVERR : s_rresp_i;
      assign s_axi_ruser = err_busy_r ? {C_AXI_RUSER_WIDTH{1'b0}} : s_ruser_i;
      assign s_axi_rdata = err_busy_r ? {C_AXI_DATA_WIDTH{1'b0}} : s_rdata_i;
      assign s_axi_rlast = err_busy_r ? e_rlast : s_rlast_i;
      assign busy_aw = (aw_cnt != 0);
      assign busy_w  = (w_cnt != 0);
      assign busy_ar = (ar_cnt != 0);
      assign aw_push = s_awvalid_i & s_awready_i & s_awready_en;
      assign aw_pop  = s_bvalid_i & s_bready_i;
      assign w_pop   = s_wvalid_i & s_wready_i & s_axi_wlast;
      assign ar_push = s_arvalid_i & s_arready_i & s_arready_en;
      assign ar_pop  = s_rvalid_i & s_rready_i & s_rlast_i;
      always @(posedge aclk) begin
        if (~aresetn) begin
          s_awvalid_en <= 1'b0;
          s_arvalid_en <= 1'b0;
          s_awready_en <= 1'b0;
          s_arready_en <= 1'b0;
          e_awvalid_r <= 1'b0;
          e_arvalid_r <= 1'b0;
          e_awready <= 1'b0;
          e_arready <= 1'b0;
          aw_cnt <= 0;
          w_cnt <= 0;
          ar_cnt <= 0;
          err_busy_w <= 1'b0;
          err_busy_r <= 1'b0;
          w_borrow <= 1'b0;
          s_awvalid_pending <= 1'b0;
        end else begin
          e_awready <= 1'b0;  
          if (e_bvalid & s_axi_bready) begin
            s_awvalid_en <= 1'b1;
            s_awready_en <= 1'b1;
            err_busy_w <= 1'b0;
          end else if (e_awvalid) begin
            e_awvalid_r <= 1'b0;
            err_busy_w <= 1'b1;
          end else if (s_axi_awvalid & w_err & ~e_awvalid_r & ~err_busy_w) begin
            e_awvalid_r <= 1'b1;
            e_awready <= ~(s_awready_i & s_awvalid_en);  
            s_awvalid_en <= 1'b0;
            s_awready_en <= 1'b0;
          end else if ((&aw_cnt) | (&w_cnt) | aw_push) begin
            s_awvalid_en <= 1'b0;
            s_awready_en <= 1'b0;
          end else if (~err_busy_w & ~e_awvalid_r & ~(s_axi_awvalid & w_err)) begin
            s_awvalid_en <= 1'b1;
            s_awready_en <= 1'b1;
          end
          if (aw_push & ~aw_pop) begin
            aw_cnt <= aw_cnt + 1;
          end else if (~aw_push & aw_pop & (|aw_cnt)) begin
            aw_cnt <= aw_cnt - 1;
          end
          if (aw_push) begin
            if (~w_pop & ~w_borrow) begin
              w_cnt <= w_cnt + 1;
            end
            w_borrow <= 1'b0;
          end else if (~aw_push & w_pop) begin
            if (|w_cnt) begin
              w_cnt <= w_cnt - 1;
            end else begin
              w_borrow <= 1'b1;
            end
          end
          s_awvalid_pending <= s_awvalid_i & ~s_awready_i;
          e_arready <= 1'b0;  
          if (e_rvalid & s_axi_rready & e_rlast) begin
            s_arvalid_en <= 1'b1;
            s_arready_en <= 1'b1;
            err_busy_r <= 1'b0;
          end else if (e_arvalid) begin
            e_arvalid_r <= 1'b0;
            err_busy_r <= 1'b1;
          end else if (s_axi_arvalid & r_err & ~e_arvalid_r & ~err_busy_r) begin
            e_arvalid_r <= 1'b1;
            e_arready <= ~(s_arready_i & s_arvalid_en);  
            s_arvalid_en <= 1'b0;
            s_arready_en <= 1'b0;
          end else if ((&ar_cnt) | ar_push) begin
            s_arvalid_en <= 1'b0;
            s_arready_en <= 1'b0;
          end else if (~err_busy_r & ~e_arvalid_r & ~(s_axi_arvalid & r_err)) begin
            s_arvalid_en <= 1'b1;
            s_arready_en <= 1'b1;
          end
          if (ar_push & ~ar_pop) begin
            ar_cnt <= ar_cnt + 1;
          end else if (~ar_push & ar_pop & (|ar_cnt)) begin
            ar_cnt <= ar_cnt - 1;
          end
        end
      end
      always @(posedge aclk) begin
        if (s_axi_awvalid & ~err_busy_w & ~e_awvalid_r ) begin
          e_awid <= s_axi_awid;
        end
        if (s_axi_arvalid & ~err_busy_r & ~e_arvalid_r ) begin
          e_arid <= s_axi_arid;
          e_arlen <= s_axi_arlen;
        end
      end
      axi_protocol_converter_v2_1_13_decerr_slave #
        (
         .C_AXI_ID_WIDTH                 (C_AXI_ID_WIDTH),
         .C_AXI_DATA_WIDTH               (C_AXI_DATA_WIDTH),
         .C_AXI_RUSER_WIDTH              (C_AXI_RUSER_WIDTH),
         .C_AXI_BUSER_WIDTH              (C_AXI_BUSER_WIDTH),
         .C_AXI_PROTOCOL                 (C_S_AXI_PROTOCOL),
         .C_RESP                         (P_SLVERR),
         .C_IGNORE_ID                    (C_IGNORE_ID)
        )
        decerr_slave_inst
          (
           .ACLK (aclk),
           .ARESETN (aresetn),
           .S_AXI_AWID (e_awid),
           .S_AXI_AWVALID (e_awvalid),
           .S_AXI_AWREADY (),
           .S_AXI_WLAST (s_axi_wlast),
           .S_AXI_WVALID (e_wvalid),
           .S_AXI_WREADY (e_wready),
           .S_AXI_BID (e_bid),
           .S_AXI_BRESP (),
           .S_AXI_BUSER (),
           .S_AXI_BVALID (e_bvalid),
           .S_AXI_BREADY (s_axi_bready),
           .S_AXI_ARID (e_arid),
           .S_AXI_ARLEN (e_arlen),
           .S_AXI_ARVALID (e_arvalid),
           .S_AXI_ARREADY (),
           .S_AXI_RID (e_rid),
           .S_AXI_RDATA (),
           .S_AXI_RRESP (),
           .S_AXI_RUSER (),
           .S_AXI_RLAST (e_rlast),
           .S_AXI_RVALID (e_rvalid),
           .S_AXI_RREADY (s_axi_rready)
         );
    end else begin : gen_no_err_detect
      assign s_awvalid_i = s_axi_awvalid;
      assign s_arvalid_i = s_axi_arvalid;
      assign s_wvalid_i = s_axi_wvalid;
      assign s_bready_i = s_axi_bready;
      assign s_rready_i = s_axi_rready;
      assign s_axi_awready = s_awready_i; 
      assign s_axi_wready = s_wready_i;
      assign s_axi_bvalid = s_bvalid_i;
      assign s_axi_bid = s_bid_i;
      assign s_axi_bresp = s_bresp_i;
      assign s_axi_buser = s_buser_i;
      assign s_axi_arready = s_arready_i; 
      assign s_axi_rvalid = s_rvalid_i;
      assign s_axi_rid = s_rid_i;
      assign s_axi_rresp = s_rresp_i;
      assign s_axi_ruser = s_ruser_i;
      assign s_axi_rdata = s_rdata_i;
      assign s_axi_rlast = s_rlast_i;
    end  
endgenerate
endmodule
`default_nettype wire
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_a_axi3_conv #
  (
   parameter C_FAMILY                            = "none",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_AUSER_WIDTH           = 1,
   parameter integer C_AXI_CHANNEL                    = 0,
   parameter integer C_SUPPORT_SPLITTING              = 1,
   parameter integer C_SUPPORT_BURSTS                 = 1,
   parameter integer C_SINGLE_THREAD                  = 1
   )
  (
   input wire ACLK,
   input wire ARESET,
   output wire                              cmd_valid,
   output wire                              cmd_split,
   output wire [C_AXI_ID_WIDTH-1:0]         cmd_id,
   output wire [4-1:0]                      cmd_length,
   input  wire                              cmd_ready,
   output wire                              cmd_b_valid,
   output wire                              cmd_b_split,
   output wire [4-1:0]                      cmd_b_repeat,
   input  wire                              cmd_b_ready,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_AID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AADDR,
   input  wire [8-1:0]                  S_AXI_ALEN,
   input  wire [3-1:0]                  S_AXI_ASIZE,
   input  wire [2-1:0]                  S_AXI_ABURST,
   input  wire [1-1:0]                  S_AXI_ALOCK,
   input  wire [4-1:0]                  S_AXI_ACACHE,
   input  wire [3-1:0]                  S_AXI_APROT,
   input  wire [4-1:0]                  S_AXI_AQOS,
   input  wire [C_AXI_AUSER_WIDTH-1:0]  S_AXI_AUSER,
   input  wire                          S_AXI_AVALID,
   output wire                          S_AXI_AREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_AID,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_AADDR,
   output wire [4-1:0]                  M_AXI_ALEN,
   output wire [3-1:0]                  M_AXI_ASIZE,
   output wire [2-1:0]                  M_AXI_ABURST,
   output wire [2-1:0]                  M_AXI_ALOCK,
   output wire [4-1:0]                  M_AXI_ACACHE,
   output wire [3-1:0]                  M_AXI_APROT,
   output wire [4-1:0]                  M_AXI_AQOS,
   output wire [C_AXI_AUSER_WIDTH-1:0]  M_AXI_AUSER,
   output wire                          M_AXI_AVALID,
   input  wire                          M_AXI_AREADY
   );
  localparam [2-1:0] C_FIX_BURST         = 2'b00;
  localparam [2-1:0] C_INCR_BURST        = 2'b01;
  localparam [2-1:0] C_WRAP_BURST        = 2'b10;
  localparam integer C_FIFO_DEPTH_LOG    = 5;
  localparam [C_AXI_ADDR_WIDTH+8-1:0] C_SIZE_MASK = {{C_AXI_ADDR_WIDTH{1'b1}}, 8'b0000_0000};
  wire                                access_is_incr;
  wire [4-1:0]                        num_transactions;
  wire                                incr_need_to_split;
  reg  [C_AXI_ADDR_WIDTH-1:0]         next_mi_addr = {C_AXI_ADDR_WIDTH{1'b0}};
  reg                                 split_ongoing = 1'b0;
  reg  [4-1:0]                        pushed_commands = 4'b0;
  reg  [16-1:0]                       addr_step;
  reg  [16-1:0]                       first_step;
  wire [8-1:0]                        first_beats;
  reg  [C_AXI_ADDR_WIDTH-1:0]         size_mask;
  reg                                 access_is_incr_q = 1'b0;
  reg                                 incr_need_to_split_q = 1'b0;
  wire                                need_to_split_q;
  reg  [4-1:0]                        num_transactions_q = 4'b0;
  reg  [16-1:0]                       addr_step_q = 16'b0;
  reg  [16-1:0]                       first_step_q = 16'b0;
  reg  [C_AXI_ADDR_WIDTH-1:0]         size_mask_q = {C_AXI_ADDR_WIDTH{1'b0}};
  reg  [C_FIFO_DEPTH_LOG:0]           cmd_depth = {C_FIFO_DEPTH_LOG+1{1'b0}};
  reg                                 cmd_empty = 1'b1;
  reg  [C_AXI_ID_WIDTH-1:0]           queue_id = {C_AXI_ID_WIDTH{1'b0}};
  wire                                id_match;
  wire                                cmd_id_check;
  wire                                s_ready;
  wire                                cmd_full;
  wire                                allow_this_cmd;
  wire                                allow_new_cmd;
  wire                                cmd_push;
  reg                                 cmd_push_block = 1'b0;
  reg  [C_FIFO_DEPTH_LOG:0]           cmd_b_depth = {C_FIFO_DEPTH_LOG+1{1'b0}};
  reg                                 cmd_b_empty = 1'b1;
  wire                                cmd_b_full;
  wire                                cmd_b_push;
  reg                                 cmd_b_push_block = 1'b0;
  wire                                pushed_new_cmd;
  wire                                last_incr_split;
  wire                                last_split;
  wire                                first_split;
  wire                                no_cmd;
  wire                                allow_split_cmd;
  wire                                almost_empty;
  wire                                no_b_cmd;
  wire                                allow_non_split_cmd;
  wire                                almost_b_empty;
  reg                                 multiple_id_non_split = 1'b0;
  reg                                 split_in_progress = 1'b0;
  wire                                cmd_split_i;
  wire [C_AXI_ID_WIDTH-1:0]           cmd_id_i;
  reg  [4-1:0]                        cmd_length_i = 4'b0;
  wire                                cmd_b_split_i;
  wire [4-1:0]                        cmd_b_repeat_i;
  wire                                mi_stalling;
  reg                                 command_ongoing = 1'b0;
  reg  [C_AXI_ID_WIDTH-1:0]           S_AXI_AID_Q;
  reg  [C_AXI_ADDR_WIDTH-1:0]         S_AXI_AADDR_Q;
  reg  [8-1:0]                        S_AXI_ALEN_Q;
  reg  [3-1:0]                        S_AXI_ASIZE_Q;
  reg  [2-1:0]                        S_AXI_ABURST_Q;
  reg  [2-1:0]                        S_AXI_ALOCK_Q;
  reg  [4-1:0]                        S_AXI_ACACHE_Q;
  reg  [3-1:0]                        S_AXI_APROT_Q;
  reg  [4-1:0]                        S_AXI_AQOS_Q;
  reg  [C_AXI_AUSER_WIDTH-1:0]        S_AXI_AUSER_Q;
  reg                                 S_AXI_AREADY_I = 1'b0;
  wire [C_AXI_ID_WIDTH-1:0]           M_AXI_AID_I;
  reg  [C_AXI_ADDR_WIDTH-1:0]         M_AXI_AADDR_I;
  reg  [8-1:0]                        M_AXI_ALEN_I;
  wire [3-1:0]                        M_AXI_ASIZE_I;
  wire [2-1:0]                        M_AXI_ABURST_I;
  reg  [2-1:0]                        M_AXI_ALOCK_I;
  wire [4-1:0]                        M_AXI_ACACHE_I;
  wire [3-1:0]                        M_AXI_APROT_I;
  wire [4-1:0]                        M_AXI_AQOS_I;
  wire [C_AXI_AUSER_WIDTH-1:0]        M_AXI_AUSER_I;
  wire                                M_AXI_AVALID_I;
  wire                                M_AXI_AREADY_I;
  reg [1:0] areset_d = 2'b0; 
  always @(posedge ACLK) begin
    areset_d <= {areset_d[0], ARESET};
  end
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      S_AXI_AID_Q     <= {C_AXI_ID_WIDTH{1'b0}};
      S_AXI_AADDR_Q   <= {C_AXI_ADDR_WIDTH{1'b0}};
      S_AXI_ALEN_Q    <= 8'b0;
      S_AXI_ASIZE_Q   <= 3'b0;
      S_AXI_ABURST_Q  <= 2'b0;
      S_AXI_ALOCK_Q   <= 2'b0;
      S_AXI_ACACHE_Q  <= 4'b0;
      S_AXI_APROT_Q   <= 3'b0;
      S_AXI_AQOS_Q    <= 4'b0;
      S_AXI_AUSER_Q   <= {C_AXI_AUSER_WIDTH{1'b0}};
    end else begin
      if ( S_AXI_AREADY_I ) begin
        S_AXI_AID_Q     <= S_AXI_AID;
        S_AXI_AADDR_Q   <= S_AXI_AADDR;
        S_AXI_ALEN_Q    <= S_AXI_ALEN;
        S_AXI_ASIZE_Q   <= S_AXI_ASIZE;
        S_AXI_ABURST_Q  <= S_AXI_ABURST;
        S_AXI_ALOCK_Q   <= S_AXI_ALOCK;
        S_AXI_ACACHE_Q  <= S_AXI_ACACHE;
        S_AXI_APROT_Q   <= S_AXI_APROT;
        S_AXI_AQOS_Q    <= S_AXI_AQOS;
        S_AXI_AUSER_Q   <= S_AXI_AUSER;
      end
    end
  end
  assign access_is_incr   = ( S_AXI_ABURST == C_INCR_BURST );
  assign num_transactions = S_AXI_ALEN[4 +: 4];
  assign first_beats = {3'b0, S_AXI_ALEN[0 +: 4]} + 7'b01;
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: first_step = first_beats << 0;
      3'b001: first_step = first_beats << 1;
      3'b010: first_step = first_beats << 2;
      3'b011: first_step = first_beats << 3;
      3'b100: first_step = first_beats << 4;
      3'b101: first_step = first_beats << 5;
      3'b110: first_step = first_beats << 6;
      3'b111: first_step = first_beats << 7;
    endcase
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: addr_step = 16'h0010;
      3'b001: addr_step = 16'h0020;
      3'b010: addr_step = 16'h0040;
      3'b011: addr_step = 16'h0080;
      3'b100: addr_step = 16'h0100;
      3'b101: addr_step = 16'h0200;
      3'b110: addr_step = 16'h0400;
      3'b111: addr_step = 16'h0800;
    endcase
  end
  always @ *
  begin
    case (S_AXI_ASIZE)
      3'b000: size_mask = C_SIZE_MASK[8 +: C_AXI_ADDR_WIDTH];
      3'b001: size_mask = C_SIZE_MASK[7 +: C_AXI_ADDR_WIDTH];
      3'b010: size_mask = C_SIZE_MASK[6 +: C_AXI_ADDR_WIDTH];
      3'b011: size_mask = C_SIZE_MASK[5 +: C_AXI_ADDR_WIDTH];
      3'b100: size_mask = C_SIZE_MASK[4 +: C_AXI_ADDR_WIDTH];
      3'b101: size_mask = C_SIZE_MASK[3 +: C_AXI_ADDR_WIDTH];
      3'b110: size_mask = C_SIZE_MASK[2 +: C_AXI_ADDR_WIDTH];
      3'b111: size_mask = C_SIZE_MASK[1 +: C_AXI_ADDR_WIDTH];
    endcase
  end
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      access_is_incr_q      <= 1'b0;
      incr_need_to_split_q  <= 1'b0;
      num_transactions_q    <= 4'b0;
      addr_step_q           <= 16'b0;
      first_step_q           <= 16'b0;
      size_mask_q           <= {C_AXI_ADDR_WIDTH{1'b0}};
    end else begin
      if ( S_AXI_AREADY_I ) begin
        access_is_incr_q      <= access_is_incr;
        incr_need_to_split_q  <= incr_need_to_split;
        num_transactions_q    <= num_transactions;
        addr_step_q           <= addr_step;
        first_step_q          <= first_step;
        size_mask_q           <= size_mask;
      end
    end
  end
  assign incr_need_to_split = access_is_incr & ( num_transactions != 0 ) &
                              ( C_SUPPORT_SPLITTING == 1 ) &
                              ( C_SUPPORT_BURSTS == 1 );
  assign need_to_split_q    = incr_need_to_split_q;
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
      pushed_commands <= 4'b0;
    end else begin
      if ( S_AXI_AREADY_I ) begin
        pushed_commands <= 4'b0;
      end else if ( pushed_new_cmd ) begin
        pushed_commands <= pushed_commands + 4'b1;
      end
    end
  end
  assign last_incr_split    = access_is_incr_q & ( num_transactions_q   == pushed_commands );
  assign last_split         = last_incr_split | ~access_is_incr_q | 
                              ( C_SUPPORT_SPLITTING == 0 ) |
                              ( C_SUPPORT_BURSTS == 0 );
  assign first_split = (pushed_commands == 4'b0);
  always @ (posedge ACLK) begin
    if ( ARESET ) begin
      next_mi_addr  = {C_AXI_ADDR_WIDTH{1'b0}};
    end else if ( pushed_new_cmd ) begin
      next_mi_addr  = M_AXI_AADDR_I + (first_split ? first_step_q : addr_step_q);
    end
  end
  assign cmd_split_i        = need_to_split_q & ~last_split;
  assign cmd_b_split_i      = need_to_split_q & ~last_split;
  assign cmd_id_i           = S_AXI_AID_Q;
  assign cmd_b_repeat_i     = num_transactions_q;
  always @ *
  begin
    if ( split_ongoing & access_is_incr_q ) begin
      M_AXI_AADDR_I = next_mi_addr & size_mask_q;
    end else begin
      M_AXI_AADDR_I = S_AXI_AADDR_Q;
    end
  end
  always @ *
  begin
    if ( first_split | ~need_to_split_q ) begin
      M_AXI_ALEN_I = S_AXI_ALEN_Q[0 +: 4];
      cmd_length_i = S_AXI_ALEN_Q[0 +: 4];
    end else begin
      M_AXI_ALEN_I = 4'hF;
      cmd_length_i = 4'hF;
    end
  end
  always @ *
  begin
    if ( need_to_split_q ) begin
      M_AXI_ALOCK_I = 2'b00;
    end else begin
      M_AXI_ALOCK_I = {1'b0, S_AXI_ALOCK_Q};
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
  assign M_AXI_AID_I      = S_AXI_AID_Q;
  assign M_AXI_ASIZE_I    = S_AXI_ASIZE_Q;
  assign M_AXI_ABURST_I   = S_AXI_ABURST_Q;
  assign M_AXI_ACACHE_I   = S_AXI_ACACHE_Q;
  assign M_AXI_APROT_I    = S_AXI_APROT_Q;
  assign M_AXI_AQOS_I     = S_AXI_AQOS_Q;
  assign M_AXI_AUSER_I    = ( C_AXI_SUPPORTS_USER_SIGNALS ) ? S_AXI_AUSER_Q : {C_AXI_AUSER_WIDTH{1'b0}};
  always @ (posedge ACLK) begin
    if (ARESET) begin
      queue_id              <= {C_AXI_ID_WIDTH{1'b0}};
      multiple_id_non_split <= 1'b0;
      split_in_progress     <= 1'b0;
    end else begin
      if ( cmd_push ) begin
        queue_id              <= S_AXI_AID_Q;
      end
      if ( no_cmd & no_b_cmd ) begin
        multiple_id_non_split <= 1'b0;
      end else if ( cmd_push & allow_non_split_cmd & ~id_match ) begin
        multiple_id_non_split <= 1'b1;
      end
      if ( no_cmd & no_b_cmd ) begin
        split_in_progress     <= 1'b0;
      end else if ( cmd_push & allow_split_cmd ) begin
        split_in_progress     <= 1'b1;
      end
    end
  end
  assign no_cmd               = almost_empty   & cmd_ready   | cmd_empty;
  assign no_b_cmd             = almost_b_empty & cmd_b_ready | cmd_b_empty;
  assign id_match             = ( C_SINGLE_THREAD == 0 ) | ( queue_id == S_AXI_AID_Q);
  assign cmd_id_check         = (cmd_empty & cmd_b_empty) | ( id_match & (~cmd_empty | ~cmd_b_empty) );
  assign allow_split_cmd      = need_to_split_q & cmd_id_check & ~multiple_id_non_split;
  assign allow_non_split_cmd  = ~need_to_split_q & (cmd_id_check | ~split_in_progress);
  assign allow_this_cmd       = allow_split_cmd | allow_non_split_cmd | ( C_SINGLE_THREAD == 0 );
  assign allow_new_cmd        = (~cmd_full & ~cmd_b_full & allow_this_cmd) | 
                                cmd_push_block;
  assign cmd_push             = M_AXI_AVALID_I & ~cmd_push_block;
  assign cmd_b_push           = M_AXI_AVALID_I & ~cmd_b_push_block & (C_AXI_CHANNEL == 0);
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
  generate
    if ( C_AXI_CHANNEL == 1 && C_SUPPORT_SPLITTING == 1 && C_SUPPORT_BURSTS == 1 ) begin : USE_R_CHANNEL
      axi_data_fifo_v2_1_12_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(1),
       .C_FIFO_TYPE("lut")
       ) 
       cmd_queue
      (
       .ACLK(ACLK),
       .ARESET(ARESET),
       .S_MESG({cmd_split_i}),
       .S_VALID(cmd_push),
       .S_READY(s_ready),
       .M_MESG({cmd_split}),
       .M_VALID(cmd_valid),
       .M_READY(cmd_ready)
       );
       assign cmd_id            = {C_AXI_ID_WIDTH{1'b0}};
       assign cmd_length        = 4'b0;
    end else if (C_SUPPORT_BURSTS == 1) begin : USE_BURSTS
      axi_data_fifo_v2_1_12_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(C_AXI_ID_WIDTH+4),
       .C_FIFO_TYPE("lut")
       ) 
       cmd_queue
      (
       .ACLK(ACLK),
       .ARESET(ARESET),
       .S_MESG({cmd_id_i, cmd_length_i}),
       .S_VALID(cmd_push),
       .S_READY(s_ready),
       .M_MESG({cmd_id, cmd_length}),
       .M_VALID(cmd_valid),
       .M_READY(cmd_ready)
       );
       assign cmd_split         = 1'b0;
    end else begin : NO_BURSTS
      axi_data_fifo_v2_1_12_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(C_AXI_ID_WIDTH),
       .C_FIFO_TYPE("lut")
       ) 
       cmd_queue
      (
       .ACLK(ACLK),
       .ARESET(ARESET),
       .S_MESG({cmd_id_i}),
       .S_VALID(cmd_push),
       .S_READY(s_ready),
       .M_MESG({cmd_id}),
       .M_VALID(cmd_valid),
       .M_READY(cmd_ready)
       );
       assign cmd_split         = 1'b0;
       assign cmd_length        = 4'b0;
    end
  endgenerate
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
        cmd_empty <= almost_empty;
      end
    end
  end
  assign almost_empty = ( cmd_depth == 1 );
  generate
    if ( C_AXI_CHANNEL == 0 && C_SUPPORT_SPLITTING == 1 && C_SUPPORT_BURSTS == 1 ) begin : USE_B_CHANNEL
      wire                                cmd_b_valid_i;
      wire                                s_b_ready;
      axi_data_fifo_v2_1_12_axic_fifo #
      (
       .C_FAMILY(C_FAMILY),
       .C_FIFO_DEPTH_LOG(C_FIFO_DEPTH_LOG),
       .C_FIFO_WIDTH(1+4),
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
          cmd_b_empty <= 1'b1;
          cmd_b_depth <= {C_FIFO_DEPTH_LOG+1{1'b0}};
        end else begin
          if ( cmd_b_push & ~cmd_b_ready ) begin
            cmd_b_depth <= cmd_b_depth + 1'b1;
            cmd_b_empty <= 1'b0;
          end else if ( ~cmd_b_push & cmd_b_ready ) begin
            cmd_b_depth <= cmd_b_depth - 1'b1;
            cmd_b_empty <= ( cmd_b_depth == 1 );
          end
        end
      end
      assign almost_b_empty = ( cmd_b_depth == 1 );
      assign cmd_b_valid  = cmd_b_valid_i;
    end else begin : NO_B_CHANNEL
      assign cmd_b_valid    = 1'b0;
      assign cmd_b_split    = 1'b0;
      assign cmd_b_repeat   = 4'b0;
      assign cmd_b_full     = 1'b0;
      assign almost_b_empty = 1'b0;
      always @ (posedge ACLK) begin
        if (ARESET) begin
          cmd_b_empty <= 1'b1;
          cmd_b_depth <= {C_FIFO_DEPTH_LOG+1{1'b0}};
        end else begin
          cmd_b_empty <= 1'b1;
          cmd_b_depth <= {C_FIFO_DEPTH_LOG+1{1'b0}};
        end
      end
    end
  endgenerate
  assign M_AXI_AID      = M_AXI_AID_I;
  assign M_AXI_AADDR    = M_AXI_AADDR_I;
  assign M_AXI_ALEN     = M_AXI_ALEN_I;
  assign M_AXI_ASIZE    = M_AXI_ASIZE_I;
  assign M_AXI_ABURST   = M_AXI_ABURST_I;
  assign M_AXI_ALOCK    = M_AXI_ALOCK_I;
  assign M_AXI_ACACHE   = M_AXI_ACACHE_I;
  assign M_AXI_APROT    = M_AXI_APROT_I;
  assign M_AXI_AQOS     = M_AXI_AQOS_I;
  assign M_AXI_AUSER    = M_AXI_AUSER_I;
  assign M_AXI_AVALID   = M_AXI_AVALID_I;
  assign M_AXI_AREADY_I = M_AXI_AREADY;
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_axi3_conv #
  (
   parameter C_FAMILY                            = "none",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_AWUSER_WIDTH          = 1,
   parameter integer C_AXI_ARUSER_WIDTH          = 1,
   parameter integer C_AXI_WUSER_WIDTH           = 1,
   parameter integer C_AXI_RUSER_WIDTH           = 1,
   parameter integer C_AXI_BUSER_WIDTH           = 1,
   parameter integer C_AXI_SUPPORTS_WRITE             = 1,
   parameter integer C_AXI_SUPPORTS_READ              = 1,
   parameter integer C_SUPPORT_SPLITTING              = 1,
   parameter integer C_SUPPORT_BURSTS                 = 1,
   parameter integer C_SINGLE_THREAD                  = 1
   )
  (
   input wire ACLK,
   input wire ARESETN,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_AWID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
   input  wire [8-1:0]                  S_AXI_AWLEN,
   input  wire [3-1:0]                  S_AXI_AWSIZE,
   input  wire [2-1:0]                  S_AXI_AWBURST,
   input  wire [1-1:0]                  S_AXI_AWLOCK,
   input  wire [4-1:0]                  S_AXI_AWCACHE,
   input  wire [3-1:0]                  S_AXI_AWPROT,
   input  wire [4-1:0]                  S_AXI_AWQOS,
   input  wire [C_AXI_AWUSER_WIDTH-1:0] S_AXI_AWUSER,
   input  wire                          S_AXI_AWVALID,
   output wire                          S_AXI_AWREADY,
   input  wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
   input  wire                          S_AXI_WLAST,
   input  wire [C_AXI_WUSER_WIDTH-1:0]  S_AXI_WUSER,
   input  wire                          S_AXI_WVALID,
   output wire                          S_AXI_WREADY,
   output wire [C_AXI_ID_WIDTH-1:0]    S_AXI_BID,
   output wire [2-1:0]                 S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0] S_AXI_BUSER,
   output wire                         S_AXI_BVALID,
   input  wire                         S_AXI_BREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_ARID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
   input  wire [8-1:0]                  S_AXI_ARLEN,
   input  wire [3-1:0]                  S_AXI_ARSIZE,
   input  wire [2-1:0]                  S_AXI_ARBURST,
   input  wire [1-1:0]                  S_AXI_ARLOCK,
   input  wire [4-1:0]                  S_AXI_ARCACHE,
   input  wire [3-1:0]                  S_AXI_ARPROT,
   input  wire [4-1:0]                  S_AXI_ARQOS,
   input  wire [C_AXI_ARUSER_WIDTH-1:0] S_AXI_ARUSER,
   input  wire                          S_AXI_ARVALID,
   output wire                          S_AXI_ARREADY,
   output wire [C_AXI_ID_WIDTH-1:0]    S_AXI_RID,
   output wire [C_AXI_DATA_WIDTH-1:0]  S_AXI_RDATA,
   output wire [2-1:0]                 S_AXI_RRESP,
   output wire                         S_AXI_RLAST,
   output wire [C_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER,
   output wire                         S_AXI_RVALID,
   input  wire                         S_AXI_RREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_AWID,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_AWADDR,
   output wire [4-1:0]                  M_AXI_AWLEN,
   output wire [3-1:0]                  M_AXI_AWSIZE,
   output wire [2-1:0]                  M_AXI_AWBURST,
   output wire [2-1:0]                  M_AXI_AWLOCK,
   output wire [4-1:0]                  M_AXI_AWCACHE,
   output wire [3-1:0]                  M_AXI_AWPROT,
   output wire [4-1:0]                  M_AXI_AWQOS,
   output wire [C_AXI_AWUSER_WIDTH-1:0] M_AXI_AWUSER,
   output wire                          M_AXI_AWVALID,
   input  wire                          M_AXI_AWREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_WID,
   output wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
   output wire                          M_AXI_WLAST,
   output wire [C_AXI_WUSER_WIDTH-1:0]  M_AXI_WUSER,
   output wire                          M_AXI_WVALID,
   input  wire                          M_AXI_WREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]    M_AXI_BID,
   input  wire [2-1:0]                 M_AXI_BRESP,
   input  wire [C_AXI_BUSER_WIDTH-1:0] M_AXI_BUSER,
   input  wire                         M_AXI_BVALID,
   output wire                         M_AXI_BREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_ARID,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_ARADDR,
   output wire [4-1:0]                  M_AXI_ARLEN,
   output wire [3-1:0]                  M_AXI_ARSIZE,
   output wire [2-1:0]                  M_AXI_ARBURST,
   output wire [2-1:0]                  M_AXI_ARLOCK,
   output wire [4-1:0]                  M_AXI_ARCACHE,
   output wire [3-1:0]                  M_AXI_ARPROT,
   output wire [4-1:0]                  M_AXI_ARQOS,
   output wire [C_AXI_ARUSER_WIDTH-1:0] M_AXI_ARUSER,
   output wire                          M_AXI_ARVALID,
   input  wire                          M_AXI_ARREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]    M_AXI_RID,
   input  wire [C_AXI_DATA_WIDTH-1:0]  M_AXI_RDATA,
   input  wire [2-1:0]                 M_AXI_RRESP,
   input  wire                         M_AXI_RLAST,
   input  wire [C_AXI_RUSER_WIDTH-1:0] M_AXI_RUSER,
   input  wire                         M_AXI_RVALID,
   output wire                         M_AXI_RREADY
   );
  generate
    if (C_AXI_SUPPORTS_WRITE == 1) begin : USE_WRITE
      wire                              wr_cmd_valid;
      wire [C_AXI_ID_WIDTH-1:0]         wr_cmd_id;
      wire [4-1:0]                      wr_cmd_length;
      wire                              wr_cmd_ready;
      wire                              wr_cmd_b_valid;
      wire                              wr_cmd_b_split;
      wire [4-1:0]                      wr_cmd_b_repeat;
      wire                              wr_cmd_b_ready;
      axi_protocol_converter_v2_1_13_a_axi3_conv #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
       .C_AXI_ADDR_WIDTH            (C_AXI_ADDR_WIDTH),
       .C_AXI_DATA_WIDTH            (C_AXI_DATA_WIDTH),
       .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
       .C_AXI_AUSER_WIDTH           (C_AXI_AWUSER_WIDTH),
       .C_AXI_CHANNEL               (0),
       .C_SUPPORT_SPLITTING         (C_SUPPORT_SPLITTING),
       .C_SUPPORT_BURSTS            (C_SUPPORT_BURSTS),
       .C_SINGLE_THREAD             (C_SINGLE_THREAD)
        ) write_addr_inst
       (
        .ARESET                     (~ARESETN),
        .ACLK                       (ACLK),
        .cmd_valid                  (wr_cmd_valid),
        .cmd_split                  (),
        .cmd_id                     (wr_cmd_id),
        .cmd_length                 (wr_cmd_length),
        .cmd_ready                  (wr_cmd_ready),
        .cmd_b_valid                (wr_cmd_b_valid),
        .cmd_b_split                (wr_cmd_b_split),
        .cmd_b_repeat               (wr_cmd_b_repeat),
        .cmd_b_ready                (wr_cmd_b_ready),
        .S_AXI_AID                  (S_AXI_AWID),
        .S_AXI_AADDR                (S_AXI_AWADDR),
        .S_AXI_ALEN                 (S_AXI_AWLEN),
        .S_AXI_ASIZE                (S_AXI_AWSIZE),
        .S_AXI_ABURST               (S_AXI_AWBURST),
        .S_AXI_ALOCK                (S_AXI_AWLOCK),
        .S_AXI_ACACHE               (S_AXI_AWCACHE),
        .S_AXI_APROT                (S_AXI_AWPROT),
        .S_AXI_AQOS                 (S_AXI_AWQOS),
        .S_AXI_AUSER                (S_AXI_AWUSER),
        .S_AXI_AVALID               (S_AXI_AWVALID),
        .S_AXI_AREADY               (S_AXI_AWREADY),
        .M_AXI_AID                  (M_AXI_AWID),
        .M_AXI_AADDR                (M_AXI_AWADDR),
        .M_AXI_ALEN                 (M_AXI_AWLEN),
        .M_AXI_ASIZE                (M_AXI_AWSIZE),
        .M_AXI_ABURST               (M_AXI_AWBURST),
        .M_AXI_ALOCK                (M_AXI_AWLOCK),
        .M_AXI_ACACHE               (M_AXI_AWCACHE),
        .M_AXI_APROT                (M_AXI_AWPROT),
        .M_AXI_AQOS                 (M_AXI_AWQOS),
        .M_AXI_AUSER                (M_AXI_AWUSER),
        .M_AXI_AVALID               (M_AXI_AWVALID),
        .M_AXI_AREADY               (M_AXI_AWREADY)
       );
      axi_protocol_converter_v2_1_13_w_axi3_conv #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
       .C_AXI_DATA_WIDTH            (C_AXI_DATA_WIDTH),
       .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
       .C_AXI_WUSER_WIDTH           (C_AXI_WUSER_WIDTH),
       .C_SUPPORT_SPLITTING         (C_SUPPORT_SPLITTING),
       .C_SUPPORT_BURSTS            (C_SUPPORT_BURSTS)
        ) write_data_inst
       (
        .ARESET                     (~ARESETN),
        .ACLK                       (ACLK),
        .cmd_valid                  (wr_cmd_valid),
        .cmd_id                     (wr_cmd_id),
        .cmd_length                 (wr_cmd_length),
        .cmd_ready                  (wr_cmd_ready),
        .S_AXI_WDATA                (S_AXI_WDATA),
        .S_AXI_WSTRB                (S_AXI_WSTRB),
        .S_AXI_WLAST                (S_AXI_WLAST),
        .S_AXI_WUSER                (S_AXI_WUSER),
        .S_AXI_WVALID               (S_AXI_WVALID),
        .S_AXI_WREADY               (S_AXI_WREADY),
        .M_AXI_WID                  (M_AXI_WID),
        .M_AXI_WDATA                (M_AXI_WDATA),
        .M_AXI_WSTRB                (M_AXI_WSTRB),
        .M_AXI_WLAST                (M_AXI_WLAST),
        .M_AXI_WUSER                (M_AXI_WUSER),
        .M_AXI_WVALID               (M_AXI_WVALID),
        .M_AXI_WREADY               (M_AXI_WREADY)
       );
      if ( C_SUPPORT_SPLITTING == 1 && C_SUPPORT_BURSTS == 1 ) begin : USE_SPLIT_W
        axi_protocol_converter_v2_1_13_b_downsizer #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
         .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
         .C_AXI_BUSER_WIDTH           (C_AXI_BUSER_WIDTH)
          ) write_resp_inst
         (
          .ARESET                     (~ARESETN),
          .ACLK                       (ACLK),
          .cmd_valid                  (wr_cmd_b_valid),
          .cmd_split                  (wr_cmd_b_split),
          .cmd_repeat                 (wr_cmd_b_repeat),
          .cmd_ready                  (wr_cmd_b_ready),
          .S_AXI_BID                  (S_AXI_BID),
          .S_AXI_BRESP                (S_AXI_BRESP),
          .S_AXI_BUSER                (S_AXI_BUSER),
          .S_AXI_BVALID               (S_AXI_BVALID),
          .S_AXI_BREADY               (S_AXI_BREADY),
          .M_AXI_BID                  (M_AXI_BID),
          .M_AXI_BRESP                (M_AXI_BRESP),
          .M_AXI_BUSER                (M_AXI_BUSER),
          .M_AXI_BVALID               (M_AXI_BVALID),
          .M_AXI_BREADY               (M_AXI_BREADY)
         );
      end else begin : NO_SPLIT_W
        assign S_AXI_BID      = M_AXI_BID;
        assign S_AXI_BRESP    = M_AXI_BRESP;
        assign S_AXI_BUSER    = M_AXI_BUSER;
        assign S_AXI_BVALID   = M_AXI_BVALID;
        assign M_AXI_BREADY   = S_AXI_BREADY;
      end
    end else begin : NO_WRITE
      assign S_AXI_AWREADY = 1'b0;
      assign S_AXI_WREADY  = 1'b0;
      assign S_AXI_BID     = {C_AXI_ID_WIDTH{1'b0}};
      assign S_AXI_BRESP   = 2'b0;
      assign S_AXI_BUSER   = {C_AXI_BUSER_WIDTH{1'b0}};
      assign S_AXI_BVALID  = 1'b0;
      assign M_AXI_AWID    = {C_AXI_ID_WIDTH{1'b0}};
      assign M_AXI_AWADDR  = {C_AXI_ADDR_WIDTH{1'b0}};
      assign M_AXI_AWLEN   = 4'b0;
      assign M_AXI_AWSIZE  = 3'b0;
      assign M_AXI_AWBURST = 2'b0;
      assign M_AXI_AWLOCK  = 2'b0;
      assign M_AXI_AWCACHE = 4'b0;
      assign M_AXI_AWPROT  = 3'b0;
      assign M_AXI_AWQOS   = 4'b0;
      assign M_AXI_AWUSER  = {C_AXI_AWUSER_WIDTH{1'b0}};
      assign M_AXI_AWVALID = 1'b0;
      assign M_AXI_WDATA   = {C_AXI_DATA_WIDTH{1'b0}};
      assign M_AXI_WSTRB   = {C_AXI_DATA_WIDTH/8{1'b0}};
      assign M_AXI_WLAST   = 1'b0;
      assign M_AXI_WUSER   = {C_AXI_WUSER_WIDTH{1'b0}};
      assign M_AXI_WVALID  = 1'b0;
      assign M_AXI_BREADY  = 1'b0;
    end
  endgenerate
  generate
    if (C_AXI_SUPPORTS_READ == 1) begin : USE_READ
      if ( C_SUPPORT_SPLITTING == 1 && C_SUPPORT_BURSTS == 1 ) begin : USE_SPLIT_R
        wire                              rd_cmd_valid;
        wire                              rd_cmd_split;
        wire                              rd_cmd_ready;
        axi_protocol_converter_v2_1_13_a_axi3_conv #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
         .C_AXI_ADDR_WIDTH            (C_AXI_ADDR_WIDTH),
         .C_AXI_DATA_WIDTH            (C_AXI_DATA_WIDTH),
         .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
         .C_AXI_AUSER_WIDTH           (C_AXI_ARUSER_WIDTH),
         .C_AXI_CHANNEL               (1),
         .C_SUPPORT_SPLITTING         (C_SUPPORT_SPLITTING),
         .C_SUPPORT_BURSTS            (C_SUPPORT_BURSTS),
         .C_SINGLE_THREAD             (C_SINGLE_THREAD)
          ) read_addr_inst
         (
          .ARESET                     (~ARESETN),
          .ACLK                       (ACLK),
          .cmd_valid                  (rd_cmd_valid),
          .cmd_split                  (rd_cmd_split),
          .cmd_id                     (),
          .cmd_length                 (),
          .cmd_ready                  (rd_cmd_ready),
          .cmd_b_valid                (),
          .cmd_b_split                (),
          .cmd_b_repeat               (),
          .cmd_b_ready                (1'b0),
          .S_AXI_AID                  (S_AXI_ARID),
          .S_AXI_AADDR                (S_AXI_ARADDR),
          .S_AXI_ALEN                 (S_AXI_ARLEN),
          .S_AXI_ASIZE                (S_AXI_ARSIZE),
          .S_AXI_ABURST               (S_AXI_ARBURST),
          .S_AXI_ALOCK                (S_AXI_ARLOCK),
          .S_AXI_ACACHE               (S_AXI_ARCACHE),
          .S_AXI_APROT                (S_AXI_ARPROT),
          .S_AXI_AQOS                 (S_AXI_ARQOS),
          .S_AXI_AUSER                (S_AXI_ARUSER),
          .S_AXI_AVALID               (S_AXI_ARVALID),
          .S_AXI_AREADY               (S_AXI_ARREADY),
          .M_AXI_AID                  (M_AXI_ARID),
          .M_AXI_AADDR                (M_AXI_ARADDR),
          .M_AXI_ALEN                 (M_AXI_ARLEN),
          .M_AXI_ASIZE                (M_AXI_ARSIZE),
          .M_AXI_ABURST               (M_AXI_ARBURST),
          .M_AXI_ALOCK                (M_AXI_ARLOCK),
          .M_AXI_ACACHE               (M_AXI_ARCACHE),
          .M_AXI_APROT                (M_AXI_ARPROT),
          .M_AXI_AQOS                 (M_AXI_ARQOS),
          .M_AXI_AUSER                (M_AXI_ARUSER),
          .M_AXI_AVALID               (M_AXI_ARVALID),
          .M_AXI_AREADY               (M_AXI_ARREADY)
         );
        axi_protocol_converter_v2_1_13_r_axi3_conv #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_AXI_ID_WIDTH              (C_AXI_ID_WIDTH),
         .C_AXI_DATA_WIDTH            (C_AXI_DATA_WIDTH),
         .C_AXI_SUPPORTS_USER_SIGNALS (C_AXI_SUPPORTS_USER_SIGNALS),
         .C_AXI_RUSER_WIDTH           (C_AXI_RUSER_WIDTH),
         .C_SUPPORT_SPLITTING         (C_SUPPORT_SPLITTING),
         .C_SUPPORT_BURSTS            (C_SUPPORT_BURSTS)
          ) read_data_inst
         (
          .ARESET                     (~ARESETN),
          .ACLK                       (ACLK),
          .cmd_valid                  (rd_cmd_valid),
          .cmd_split                  (rd_cmd_split),
          .cmd_ready                  (rd_cmd_ready),
          .S_AXI_RID                  (S_AXI_RID),
          .S_AXI_RDATA                (S_AXI_RDATA),
          .S_AXI_RRESP                (S_AXI_RRESP),
          .S_AXI_RLAST                (S_AXI_RLAST),
          .S_AXI_RUSER                (S_AXI_RUSER),
          .S_AXI_RVALID               (S_AXI_RVALID),
          .S_AXI_RREADY               (S_AXI_RREADY),
          .M_AXI_RID                  (M_AXI_RID),
          .M_AXI_RDATA                (M_AXI_RDATA),
          .M_AXI_RRESP                (M_AXI_RRESP),
          .M_AXI_RLAST                (M_AXI_RLAST),
          .M_AXI_RUSER                (M_AXI_RUSER),
          .M_AXI_RVALID               (M_AXI_RVALID),
          .M_AXI_RREADY               (M_AXI_RREADY)
         );
      end else begin : NO_SPLIT_R
        assign M_AXI_ARID     = S_AXI_ARID;
        assign M_AXI_ARADDR   = S_AXI_ARADDR;
        assign M_AXI_ARLEN    = S_AXI_ARLEN;
        assign M_AXI_ARSIZE   = S_AXI_ARSIZE;
        assign M_AXI_ARBURST  = S_AXI_ARBURST;
        assign M_AXI_ARLOCK   = S_AXI_ARLOCK;
        assign M_AXI_ARCACHE  = S_AXI_ARCACHE;
        assign M_AXI_ARPROT   = S_AXI_ARPROT;
        assign M_AXI_ARQOS    = S_AXI_ARQOS;
        assign M_AXI_ARUSER   = S_AXI_ARUSER;
        assign M_AXI_ARVALID  = S_AXI_ARVALID;
        assign S_AXI_ARREADY  = M_AXI_ARREADY;
        assign S_AXI_RID      = M_AXI_RID;
        assign S_AXI_RDATA    = M_AXI_RDATA;
        assign S_AXI_RRESP    = M_AXI_RRESP;
        assign S_AXI_RLAST    = M_AXI_RLAST;
        assign S_AXI_RUSER    = M_AXI_RUSER;
        assign S_AXI_RVALID   = M_AXI_RVALID;
        assign M_AXI_RREADY   = S_AXI_RREADY;
      end
    end else begin : NO_READ
      assign S_AXI_ARREADY = 1'b0;
      assign S_AXI_RID     = {C_AXI_ID_WIDTH{1'b0}};
      assign S_AXI_RDATA   = {C_AXI_DATA_WIDTH{1'b0}};
      assign S_AXI_RRESP   = 2'b0;
      assign S_AXI_RLAST   = 1'b0;
      assign S_AXI_RUSER   = {C_AXI_RUSER_WIDTH{1'b0}};
      assign S_AXI_RVALID  = 1'b0;
      assign M_AXI_ARID    = {C_AXI_ID_WIDTH{1'b0}};
      assign M_AXI_ARADDR  = {C_AXI_ADDR_WIDTH{1'b0}};
      assign M_AXI_ARLEN   = 4'b0;
      assign M_AXI_ARSIZE  = 3'b0;
      assign M_AXI_ARBURST = 2'b0;
      assign M_AXI_ARLOCK  = 2'b0;
      assign M_AXI_ARCACHE = 4'b0;
      assign M_AXI_ARPROT  = 3'b0;
      assign M_AXI_ARQOS   = 4'b0;
      assign M_AXI_ARUSER  = {C_AXI_ARUSER_WIDTH{1'b0}};
      assign M_AXI_ARVALID = 1'b0;
      assign M_AXI_RREADY  = 1'b0;
    end
  endgenerate
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_axilite_conv #
  (
   parameter         C_FAMILY                    = "virtex6",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_WRITE        = 1,
   parameter integer C_AXI_SUPPORTS_READ         = 1,
   parameter integer C_AXI_RUSER_WIDTH                = 1,
   parameter integer C_AXI_BUSER_WIDTH                = 1
   )
  (
   input  wire                          ACLK,
   input  wire                          ARESETN,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_AWID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
   input  wire [3-1:0]                  S_AXI_AWPROT,
   input  wire                          S_AXI_AWVALID,
   output wire                          S_AXI_AWREADY,
   input  wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
   input  wire                          S_AXI_WVALID,
   output wire                          S_AXI_WREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     S_AXI_BID,
   output wire [2-1:0]                  S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0]  S_AXI_BUSER,    
   output wire                          S_AXI_BVALID,
   input  wire                          S_AXI_BREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_ARID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
   input  wire [3-1:0]                  S_AXI_ARPROT,
   input  wire                          S_AXI_ARVALID,
   output wire                          S_AXI_ARREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     S_AXI_RID,
   output wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA,
   output wire [2-1:0]                  S_AXI_RRESP,
   output wire                          S_AXI_RLAST,    
   output wire [C_AXI_RUSER_WIDTH-1:0]  S_AXI_RUSER,    
   output wire                          S_AXI_RVALID,
   input  wire                          S_AXI_RREADY,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_AWADDR,
   output wire [3-1:0]                  M_AXI_AWPROT,
   output wire                          M_AXI_AWVALID,
   input  wire                          M_AXI_AWREADY,
   output wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
   output wire                          M_AXI_WVALID,
   input  wire                          M_AXI_WREADY,
   input  wire [2-1:0]                  M_AXI_BRESP,
   input  wire                          M_AXI_BVALID,
   output wire                          M_AXI_BREADY,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_ARADDR,
   output wire [3-1:0]                  M_AXI_ARPROT,
   output wire                          M_AXI_ARVALID,
   input  wire                          M_AXI_ARREADY,
   input  wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_RDATA,
   input  wire [2-1:0]                  M_AXI_RRESP,
   input  wire                          M_AXI_RVALID,
   output wire                          M_AXI_RREADY
  );
  wire s_awvalid_i;
  wire s_arvalid_i;
  wire [C_AXI_ADDR_WIDTH-1:0] m_axaddr;
  reg read_active = 1'b0;
  reg write_active = 1'b0;
  reg busy = 1'b0;
  wire read_req;
  wire write_req;
  wire read_complete;
  wire write_complete;
  reg [1:0] areset_d = 2'b0; 
  always @(posedge ACLK) begin
    areset_d <= {areset_d[0], ~ARESETN};
  end
  assign s_awvalid_i = S_AXI_AWVALID & (C_AXI_SUPPORTS_WRITE != 0);
  assign s_arvalid_i = S_AXI_ARVALID & (C_AXI_SUPPORTS_READ != 0);
  assign read_req  = s_arvalid_i & ~busy & ~|areset_d & ~write_active;
  assign write_req = s_awvalid_i & ~busy & ~|areset_d & ((~read_active & ~s_arvalid_i) | write_active);
  assign read_complete  = M_AXI_RVALID & S_AXI_RREADY;
  assign write_complete = M_AXI_BVALID & S_AXI_BREADY;
  always @(posedge ACLK) begin : arbiter_read_ff
    if (|areset_d)
      read_active <= 1'b0;
    else if (read_complete)
      read_active <= 1'b0;
    else if (read_req)
      read_active <= 1'b1;
  end
  always @(posedge ACLK) begin : arbiter_write_ff
    if (|areset_d)
      write_active <= 1'b0;
    else if (write_complete)
      write_active <= 1'b0;
    else if (write_req)
      write_active <= 1'b1;
  end
  always @(posedge ACLK) begin : arbiter_busy_ff
    if (|areset_d)
      busy <= 1'b0;
    else if (read_complete | write_complete)
      busy <= 1'b0;
    else if ((write_req & M_AXI_AWREADY) | (read_req & M_AXI_ARREADY))
      busy <= 1'b1;
  end
  assign M_AXI_ARVALID = read_req;
  assign S_AXI_ARREADY = M_AXI_ARREADY & read_req;
  assign M_AXI_AWVALID = write_req;
  assign S_AXI_AWREADY = M_AXI_AWREADY & write_req;
  assign M_AXI_RREADY  = S_AXI_RREADY & read_active;
  assign S_AXI_RVALID  = M_AXI_RVALID & read_active;
  assign M_AXI_BREADY  = S_AXI_BREADY & write_active;
  assign S_AXI_BVALID  = M_AXI_BVALID & write_active;
  assign m_axaddr = (read_req | (C_AXI_SUPPORTS_WRITE == 0)) ? S_AXI_ARADDR : S_AXI_AWADDR;
  reg [C_AXI_ID_WIDTH-1:0] s_axid;
  always @(posedge ACLK) begin : axid
    if      (read_req)  s_axid <= S_AXI_ARID;
    else if (write_req) s_axid <= S_AXI_AWID;
  end
  assign S_AXI_BID = s_axid;
  assign S_AXI_RID = s_axid;
  assign M_AXI_AWADDR = m_axaddr;
  assign M_AXI_ARADDR = m_axaddr;
  assign S_AXI_WREADY   = M_AXI_WREADY & ~|areset_d;
  assign S_AXI_BRESP    = M_AXI_BRESP;
  assign S_AXI_RDATA    = M_AXI_RDATA;
  assign S_AXI_RRESP    = M_AXI_RRESP;
  assign S_AXI_RLAST    = 1'b1;
  assign S_AXI_BUSER    = {C_AXI_BUSER_WIDTH{1'b0}};
  assign S_AXI_RUSER    = {C_AXI_RUSER_WIDTH{1'b0}};
  assign M_AXI_AWPROT   = S_AXI_AWPROT;
  assign M_AXI_WVALID   = S_AXI_WVALID & ~|areset_d;
  assign M_AXI_WDATA    = S_AXI_WDATA;
  assign M_AXI_WSTRB    = S_AXI_WSTRB;
  assign M_AXI_ARPROT   = S_AXI_ARPROT;
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_r_axi3_conv #
  (
   parameter C_FAMILY                            = "none",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_RUSER_WIDTH           = 1,
   parameter integer C_SUPPORT_SPLITTING              = 1,
   parameter integer C_SUPPORT_BURSTS                 = 1
   )
  (
   input wire ACLK,
   input wire ARESET,
   input  wire                              cmd_valid,
   input  wire                              cmd_split,
   output wire                              cmd_ready,
   output wire [C_AXI_ID_WIDTH-1:0]    S_AXI_RID,
   output wire [C_AXI_DATA_WIDTH-1:0]  S_AXI_RDATA,
   output wire [2-1:0]                 S_AXI_RRESP,
   output wire                         S_AXI_RLAST,
   output wire [C_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER,
   output wire                         S_AXI_RVALID,
   input  wire                         S_AXI_RREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]    M_AXI_RID,
   input  wire [C_AXI_DATA_WIDTH-1:0]  M_AXI_RDATA,
   input  wire [2-1:0]                 M_AXI_RRESP,
   input  wire                         M_AXI_RLAST,
   input  wire [C_AXI_RUSER_WIDTH-1:0] M_AXI_RUSER,
   input  wire                         M_AXI_RVALID,
   output wire                         M_AXI_RREADY
   );
  localparam [2-1:0] C_RESP_OKAY        = 2'b00;
  localparam [2-1:0] C_RESP_EXOKAY      = 2'b01;
  localparam [2-1:0] C_RESP_SLVERROR    = 2'b10;
  localparam [2-1:0] C_RESP_DECERR      = 2'b11;
  wire                            cmd_ready_i;
  wire                            pop_si_data;
  wire                            si_stalling;
  wire                            M_AXI_RREADY_I;
  wire [C_AXI_ID_WIDTH-1:0]       S_AXI_RID_I;
  wire [C_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA_I;
  wire [2-1:0]                    S_AXI_RRESP_I;
  wire                            S_AXI_RLAST_I;
  wire [C_AXI_RUSER_WIDTH-1:0]    S_AXI_RUSER_I;
  wire                            S_AXI_RVALID_I;
  wire                            S_AXI_RREADY_I;
  assign M_AXI_RREADY_I = ~si_stalling & cmd_valid;
  assign M_AXI_RREADY   = M_AXI_RREADY_I;
  assign S_AXI_RVALID_I = M_AXI_RVALID & cmd_valid;
  assign pop_si_data    = S_AXI_RVALID_I & S_AXI_RREADY_I;
  assign cmd_ready_i    = cmd_valid & pop_si_data & M_AXI_RLAST;
  assign cmd_ready      = cmd_ready_i;
  assign si_stalling    = S_AXI_RVALID_I & ~S_AXI_RREADY_I;
  assign S_AXI_RLAST_I  = M_AXI_RLAST & 
                          ( ~cmd_split | ( C_SUPPORT_SPLITTING == 0 ) );
  assign S_AXI_RID_I    = M_AXI_RID;
  assign S_AXI_RUSER_I  = M_AXI_RUSER;
  assign S_AXI_RDATA_I  = M_AXI_RDATA;
  assign S_AXI_RRESP_I  = M_AXI_RRESP;
  assign S_AXI_RREADY_I = S_AXI_RREADY;
  assign S_AXI_RVALID   = S_AXI_RVALID_I;
  assign S_AXI_RID      = S_AXI_RID_I;
  assign S_AXI_RDATA    = S_AXI_RDATA_I;
  assign S_AXI_RRESP    = S_AXI_RRESP_I;
  assign S_AXI_RLAST    = S_AXI_RLAST_I;
  assign S_AXI_RUSER    = S_AXI_RUSER_I;
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_w_axi3_conv #
  (
   parameter C_FAMILY                            = "none",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
   parameter integer C_AXI_WUSER_WIDTH           = 1,
   parameter integer C_SUPPORT_SPLITTING              = 1,
   parameter integer C_SUPPORT_BURSTS                 = 1
   )
  (
   input wire ACLK,
   input wire ARESET,
   input  wire                              cmd_valid,
   input  wire [C_AXI_ID_WIDTH-1:0]         cmd_id,
   input  wire [4-1:0]                      cmd_length,
   output wire                              cmd_ready,
   input  wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
   input  wire                          S_AXI_WLAST,
   input  wire [C_AXI_WUSER_WIDTH-1:0]  S_AXI_WUSER,
   input  wire                          S_AXI_WVALID,
   output wire                          S_AXI_WREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     M_AXI_WID,
   output wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
   output wire                          M_AXI_WLAST,
   output wire [C_AXI_WUSER_WIDTH-1:0]  M_AXI_WUSER,
   output wire                          M_AXI_WVALID,
   input  wire                          M_AXI_WREADY
   );
  reg                             first_mi_word = 1'b0;
  reg  [8-1:0]                    length_counter_1;
  reg  [8-1:0]                    length_counter;
  wire [8-1:0]                    next_length_counter;
  wire                            last_beat;
  wire                            last_word;
  wire                            cmd_ready_i;
  wire                            pop_mi_data;
  wire                            mi_stalling;
  wire                            S_AXI_WREADY_I;
  wire [C_AXI_ID_WIDTH-1:0]       M_AXI_WID_I;
  wire [C_AXI_DATA_WIDTH-1:0]     M_AXI_WDATA_I;
  wire [C_AXI_DATA_WIDTH/8-1:0]   M_AXI_WSTRB_I;
  wire                            M_AXI_WLAST_I;
  wire [C_AXI_WUSER_WIDTH-1:0]    M_AXI_WUSER_I;
  wire                            M_AXI_WVALID_I;
  wire                            M_AXI_WREADY_I;
  assign S_AXI_WREADY_I = S_AXI_WVALID & cmd_valid & ~mi_stalling;
  assign S_AXI_WREADY   = S_AXI_WREADY_I;
  assign M_AXI_WVALID_I = S_AXI_WVALID & cmd_valid;
  assign pop_mi_data    = M_AXI_WVALID_I & M_AXI_WREADY_I;
  assign cmd_ready_i    = cmd_valid & pop_mi_data & last_word;
  assign cmd_ready      = cmd_ready_i;
  assign mi_stalling    = M_AXI_WVALID_I & ~M_AXI_WREADY_I;
  always @ *
  begin
    if ( first_mi_word )
      length_counter = cmd_length;
    else
      length_counter = length_counter_1;
  end
  assign next_length_counter = length_counter - 1'b1;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      first_mi_word    <= 1'b1;
      length_counter_1 <= 4'b0;
    end else begin
      if ( pop_mi_data ) begin
        if ( M_AXI_WLAST_I ) begin
          first_mi_word    <= 1'b1;
        end else begin
          first_mi_word    <= 1'b0;
        end
        length_counter_1 <= next_length_counter;
      end
    end
  end
  assign last_beat = ( length_counter == 4'b0 );
  assign last_word = ( last_beat ) |
                     ( C_SUPPORT_BURSTS == 0 );
  assign M_AXI_WUSER_I  = ( C_AXI_SUPPORTS_USER_SIGNALS ) ? S_AXI_WUSER : {C_AXI_WUSER_WIDTH{1'b0}};
  assign M_AXI_WDATA_I  = S_AXI_WDATA;
  assign M_AXI_WSTRB_I  = S_AXI_WSTRB;
  assign M_AXI_WID_I    = cmd_id;
  assign M_AXI_WLAST_I  = last_word;
  assign M_AXI_WID      = M_AXI_WID_I;
  assign M_AXI_WDATA    = M_AXI_WDATA_I;
  assign M_AXI_WSTRB    = M_AXI_WSTRB_I;
  assign M_AXI_WLAST    = M_AXI_WLAST_I;
  assign M_AXI_WUSER    = M_AXI_WUSER_I;
  assign M_AXI_WVALID   = M_AXI_WVALID_I;
  assign M_AXI_WREADY_I = M_AXI_WREADY;
endmodule
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_13_b_downsizer #
  (
   parameter         C_FAMILY                         = "none", 
   parameter integer C_AXI_ID_WIDTH                   = 4, 
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS      = 0,
   parameter integer C_AXI_BUSER_WIDTH                = 1
   )
  (
   input  wire                                                    ARESET,
   input  wire                                                    ACLK,
   input  wire                              cmd_valid,
   input  wire                              cmd_split,
   input  wire [4-1:0]                      cmd_repeat,
   output wire                              cmd_ready,
   output wire [C_AXI_ID_WIDTH-1:0]           S_AXI_BID,
   output wire [2-1:0]                          S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0]          S_AXI_BUSER,
   output wire                                                    S_AXI_BVALID,
   input  wire                                                    S_AXI_BREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]          M_AXI_BID,
   input  wire [2-1:0]                         M_AXI_BRESP,
   input  wire [C_AXI_BUSER_WIDTH-1:0]         M_AXI_BUSER,
   input  wire                                                   M_AXI_BVALID,
   output wire                                                   M_AXI_BREADY
   );
  localparam [2-1:0] C_RESP_OKAY        = 2'b00;
  localparam [2-1:0] C_RESP_EXOKAY      = 2'b01;
  localparam [2-1:0] C_RESP_SLVERROR    = 2'b10;
  localparam [2-1:0] C_RESP_DECERR      = 2'b11;
  wire                            cmd_ready_i;
  wire                            pop_mi_data;
  wire                            mi_stalling;
  reg  [4-1:0]                    repeat_cnt_pre;
  reg  [4-1:0]                    repeat_cnt;
  wire [4-1:0]                    next_repeat_cnt;
  reg                             first_mi_word = 1'b0;
  wire                            last_word;
  wire                            load_bresp;
  wire                            need_to_update_bresp;
  reg  [2-1:0]                    S_AXI_BRESP_ACC;
  wire                            M_AXI_BREADY_I;
  wire [C_AXI_ID_WIDTH-1:0]       S_AXI_BID_I;
  reg  [2-1:0]                    S_AXI_BRESP_I;
  wire [C_AXI_BUSER_WIDTH-1:0]    S_AXI_BUSER_I;
  wire                            S_AXI_BVALID_I;
  wire                            S_AXI_BREADY_I;
  assign M_AXI_BREADY_I = M_AXI_BVALID & ~mi_stalling;
  assign M_AXI_BREADY   = M_AXI_BREADY_I;
  assign S_AXI_BVALID_I = M_AXI_BVALID & last_word;
  assign pop_mi_data    = M_AXI_BVALID & M_AXI_BREADY_I;
  assign cmd_ready_i    = cmd_valid & pop_mi_data & last_word;
  assign cmd_ready      = cmd_ready_i;
  assign mi_stalling    = (~S_AXI_BREADY_I & last_word);
  assign load_bresp           = (cmd_split & first_mi_word);
  assign need_to_update_bresp = ( M_AXI_BRESP > S_AXI_BRESP_ACC );
  always @ *
  begin
    if ( cmd_split ) begin
      if ( load_bresp || need_to_update_bresp ) begin
        S_AXI_BRESP_I = M_AXI_BRESP;
      end else begin
        S_AXI_BRESP_I = S_AXI_BRESP_ACC;
      end
    end else begin
      S_AXI_BRESP_I = M_AXI_BRESP;
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      S_AXI_BRESP_ACC <= C_RESP_OKAY;
    end else begin
      if ( pop_mi_data ) begin
        S_AXI_BRESP_ACC <= S_AXI_BRESP_I;
      end
    end
  end
  assign last_word  = ( ( repeat_cnt == 4'b0 ) & ~first_mi_word ) | 
                      ~cmd_split;
  always @ *
  begin
    if ( first_mi_word ) begin
      repeat_cnt_pre  =  cmd_repeat;
    end else begin
      repeat_cnt_pre  =  repeat_cnt;
    end
  end
  assign next_repeat_cnt  = repeat_cnt_pre - 1'b1;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      repeat_cnt    <= 4'b0;
      first_mi_word <= 1'b1;
    end else begin
      if ( pop_mi_data ) begin
        repeat_cnt    <= next_repeat_cnt;
        first_mi_word <= last_word;
      end
    end
  end
  assign S_AXI_BID_I  = M_AXI_BID;
  assign S_AXI_BUSER_I = {C_AXI_BUSER_WIDTH{1'b0}};
  assign S_AXI_BID      = S_AXI_BID_I;
  assign S_AXI_BRESP    = S_AXI_BRESP_I;
  assign S_AXI_BUSER    = S_AXI_BUSER_I;
  assign S_AXI_BVALID   = S_AXI_BVALID_I;
  assign S_AXI_BREADY_I = S_AXI_BREADY;
endmodule
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_decerr_slave #
  (
   parameter integer C_AXI_ID_WIDTH           = 1,
   parameter integer C_AXI_DATA_WIDTH         = 32,
   parameter integer C_AXI_BUSER_WIDTH        = 1,
   parameter integer C_AXI_RUSER_WIDTH        = 1,
   parameter integer C_AXI_PROTOCOL           = 0,
   parameter integer C_RESP                   = 2'b11,
   parameter integer C_IGNORE_ID              = 0
   )
  (
   input   wire                                         ACLK,
   input   wire                                         ARESETN,
   input   wire [(C_AXI_ID_WIDTH-1):0]                  S_AXI_AWID,
   input   wire                                         S_AXI_AWVALID,
   output  wire                                         S_AXI_AWREADY,
   input   wire                                         S_AXI_WLAST,
   input   wire                                         S_AXI_WVALID,
   output  wire                                         S_AXI_WREADY,
   output  wire [(C_AXI_ID_WIDTH-1):0]                  S_AXI_BID,
   output  wire [1:0]                                   S_AXI_BRESP,
   output  wire [C_AXI_BUSER_WIDTH-1:0]                 S_AXI_BUSER,
   output  wire                                         S_AXI_BVALID,
   input   wire                                         S_AXI_BREADY,
   input   wire [(C_AXI_ID_WIDTH-1):0]                  S_AXI_ARID,
   input   wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]   S_AXI_ARLEN,
   input   wire                                         S_AXI_ARVALID,
   output  wire                                         S_AXI_ARREADY,
   output  wire [(C_AXI_ID_WIDTH-1):0]                  S_AXI_RID,
   output  wire [(C_AXI_DATA_WIDTH-1):0]                S_AXI_RDATA,
   output  wire [1:0]                                   S_AXI_RRESP,
   output  wire [C_AXI_RUSER_WIDTH-1:0]                 S_AXI_RUSER,
   output  wire                                         S_AXI_RLAST,
   output  wire                                         S_AXI_RVALID,
   input   wire                                         S_AXI_RREADY
   );
  reg s_axi_awready_i = 1'b0;
  reg s_axi_wready_i = 1'b0;
  reg s_axi_bvalid_i = 1'b0;
  reg s_axi_arready_i = 1'b0;
  reg s_axi_rvalid_i = 1'b0;
  localparam P_WRITE_IDLE = 2'b00;
  localparam P_WRITE_DATA = 2'b01;
  localparam P_WRITE_RESP = 2'b10;
  localparam P_READ_IDLE  = 2'b00;
  localparam P_READ_START = 2'b01;
  localparam P_READ_DATA  = 2'b10;
  localparam integer  P_AXI4 = 0;
  localparam integer  P_AXI3 = 1;
  localparam integer  P_AXILITE = 2;
  assign S_AXI_BRESP = C_RESP;
  assign S_AXI_RRESP = C_RESP;
  assign S_AXI_RDATA = {C_AXI_DATA_WIDTH{1'b0}};
  assign S_AXI_BUSER = {C_AXI_BUSER_WIDTH{1'b0}};
  assign S_AXI_RUSER = {C_AXI_RUSER_WIDTH{1'b0}};
  assign S_AXI_AWREADY = s_axi_awready_i;
  assign S_AXI_WREADY = s_axi_wready_i;
  assign S_AXI_BVALID = s_axi_bvalid_i;
  assign S_AXI_ARREADY = s_axi_arready_i;
  assign S_AXI_RVALID = s_axi_rvalid_i;
  generate
  if (C_AXI_PROTOCOL == P_AXILITE) begin : gen_axilite
    reg s_axi_rvalid_en;
    assign S_AXI_RLAST = 1'b1;
    assign S_AXI_BID = 0;
    assign S_AXI_RID = 0;
    always @(posedge ACLK) begin
      if (~ARESETN) begin
        s_axi_awready_i <= 1'b0;
        s_axi_wready_i <= 1'b0;
        s_axi_bvalid_i <= 1'b0;
      end else begin
        if (s_axi_bvalid_i) begin
          if (S_AXI_BREADY) begin
            s_axi_bvalid_i <= 1'b0;
            s_axi_awready_i <= 1'b1;
          end
        end else if (S_AXI_WVALID & s_axi_wready_i) begin
            s_axi_wready_i <= 1'b0;
            s_axi_bvalid_i <= 1'b1;
        end else if (S_AXI_AWVALID & s_axi_awready_i) begin
          s_axi_awready_i <= 1'b0;
          s_axi_wready_i <= 1'b1;
        end else begin
          s_axi_awready_i <= 1'b1;
        end
      end
    end
    always @(posedge ACLK) begin
      if (~ARESETN) begin
        s_axi_arready_i <= 1'b0;
        s_axi_rvalid_i <= 1'b0;
        s_axi_rvalid_en <= 1'b0;
      end else begin
        if (s_axi_rvalid_i) begin
          if (S_AXI_RREADY) begin
            s_axi_rvalid_i <= 1'b0;
            s_axi_arready_i <= 1'b1;
          end
        end else if (s_axi_rvalid_en) begin
          s_axi_rvalid_en <= 1'b0;
          s_axi_rvalid_i <= 1'b1;
        end else if (S_AXI_ARVALID & s_axi_arready_i) begin
          s_axi_arready_i <= 1'b0;
          s_axi_rvalid_en <= 1'b1;
        end else begin
          s_axi_arready_i <= 1'b1;
        end
      end
    end
  end else begin : gen_axi
    reg s_axi_rlast_i;
    reg [(C_AXI_ID_WIDTH-1):0] s_axi_bid_i;
    reg [(C_AXI_ID_WIDTH-1):0] s_axi_rid_i;
    reg [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] read_cnt;
    reg [1:0] write_cs = P_WRITE_IDLE;
    reg [1:0] read_cs = P_READ_IDLE;
    assign S_AXI_RLAST = s_axi_rlast_i;
    assign S_AXI_BID = C_IGNORE_ID ? 0 : s_axi_bid_i;
    assign S_AXI_RID = C_IGNORE_ID ? 0 : s_axi_rid_i;
    always @(posedge ACLK) begin
      if (~ARESETN) begin
        write_cs <= P_WRITE_IDLE;
        s_axi_awready_i <= 1'b0;
        s_axi_wready_i <= 1'b0;
        s_axi_bvalid_i <= 1'b0;
        s_axi_bid_i <= 0;
      end else begin
        case (write_cs) 
          P_WRITE_IDLE: 
            begin
              if (S_AXI_AWVALID & s_axi_awready_i) begin
                s_axi_awready_i <= 1'b0;
                if (C_IGNORE_ID == 0) s_axi_bid_i <= S_AXI_AWID;
                s_axi_wready_i <= 1'b1;
                write_cs <= P_WRITE_DATA;
              end else begin
                s_axi_awready_i <= 1'b1;
              end
            end
          P_WRITE_DATA:
            begin
              if (S_AXI_WVALID & S_AXI_WLAST) begin
                s_axi_wready_i <= 1'b0;
                s_axi_bvalid_i <= 1'b1;
                write_cs <= P_WRITE_RESP;
              end
            end
          P_WRITE_RESP:
            begin
              if (S_AXI_BREADY) begin
                s_axi_bvalid_i <= 1'b0;
                s_axi_awready_i <= 1'b1;
                write_cs <= P_WRITE_IDLE;
              end
            end
        endcase
      end
    end
    always @(posedge ACLK) begin
      if (~ARESETN) begin
        read_cs <= P_READ_IDLE;
        s_axi_arready_i <= 1'b0;
        s_axi_rvalid_i <= 1'b0;
        s_axi_rlast_i <= 1'b0;
        s_axi_rid_i <= 0;
        read_cnt <= 0;
      end else begin
        case (read_cs) 
          P_READ_IDLE: 
            begin
              if (S_AXI_ARVALID & s_axi_arready_i) begin
                s_axi_arready_i <= 1'b0;
                if (C_IGNORE_ID == 0) s_axi_rid_i <= S_AXI_ARID;
                read_cnt <= S_AXI_ARLEN;
                s_axi_rlast_i <= (S_AXI_ARLEN == 0);
                read_cs <= P_READ_START;
              end else begin
                s_axi_arready_i <= 1'b1;
              end
            end
          P_READ_START:
            begin
              s_axi_rvalid_i <= 1'b1;
              read_cs <= P_READ_DATA;
            end
          P_READ_DATA:
            begin
              if (S_AXI_RREADY) begin
                if (read_cnt == 0) begin
                  s_axi_rvalid_i <= 1'b0;
                  s_axi_rlast_i <= 1'b0;
                  s_axi_arready_i <= 1'b1;
                  read_cs <= P_READ_IDLE;
                end else begin
                  if (read_cnt == 1) begin
                    s_axi_rlast_i <= 1'b1;
                  end
                  read_cnt <= read_cnt - 1;
                end
              end
            end
        endcase
      end
    end
  end  
  endgenerate
endmodule
`default_nettype wire
`timescale 1ns / 100ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_simple_fifo #
(
  parameter C_WIDTH  = 8,
  parameter C_AWIDTH = 4,
  parameter C_DEPTH  = 16
)
(
  input  wire               clk,       
  input  wire               rst,       
  input  wire               wr_en,     
  input  wire               rd_en,     
  input  wire [C_WIDTH-1:0] din,       
  output wire [C_WIDTH-1:0] dout,      
  output wire               a_full,
  output wire               full,      
  output wire               a_empty,
  output wire               empty      
);
localparam [C_AWIDTH-1:0] C_EMPTY = ~(0);
localparam [C_AWIDTH-1:0] C_EMPTY_PRE =  (0);
localparam [C_AWIDTH-1:0] C_FULL  = C_EMPTY-1;
localparam [C_AWIDTH-1:0] C_FULL_PRE  = (C_DEPTH < 8) ? C_FULL-1 : C_FULL-(C_DEPTH/8);
reg [C_WIDTH-1:0]  memory [C_DEPTH-1:0];
reg [C_AWIDTH-1:0] cnt_read = C_EMPTY;
always @(posedge clk) begin : BLKSRL
integer i;
  if (wr_en) begin
    for (i = 0; i < C_DEPTH-1; i = i + 1) begin
      memory[i+1] <= memory[i];
    end
    memory[0] <= din;
  end
end
always @(posedge clk) begin
  if (rst) cnt_read <= C_EMPTY;
  else if ( wr_en & !rd_en) cnt_read <= cnt_read + 1'b1;
  else if (!wr_en &  rd_en) cnt_read <= cnt_read - 1'b1;
end
assign full  = (cnt_read == C_FULL);
assign empty = (cnt_read == C_EMPTY);
assign a_full  = ((cnt_read >= C_FULL_PRE) && (cnt_read != C_EMPTY));
assign a_empty = (cnt_read == C_EMPTY_PRE);
assign dout  = (C_DEPTH == 1) ? memory[0] : memory[cnt_read];
endmodule 
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_wrap_cmd #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32
)
(
  input  wire                                 clk           , 
  input  wire                                 reset         , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          axaddr        , 
  input  wire [7:0]                           axlen         , 
  input  wire [2:0]                           axsize        , 
  input  wire                                 axhandshake   , 
  output wire [C_AXI_ADDR_WIDTH-1:0]          cmd_byte_addr , 
  input  wire                                 next          , 
  output reg                                  next_pending 
);
reg                         sel_first;
wire [11:0]                 axaddr_i;
wire [3:0]                  axlen_i;
reg  [11:0]                 wrap_boundary_axaddr;
reg  [3:0]                  axaddr_offset;
reg  [3:0]                  wrap_second_len;
reg  [11:0]                 wrap_boundary_axaddr_r;
reg  [3:0]                  axaddr_offset_r;
reg  [3:0]                  wrap_second_len_r;
reg  [4:0]                  axlen_cnt;
reg  [4:0]                  wrap_cnt_r;
wire [4:0]                  wrap_cnt;
reg  [11:0]                 axaddr_wrap;
reg                         next_pending_r;
localparam    L_AXI_ADDR_LOW_BIT = (C_AXI_ADDR_WIDTH >= 12) ? 12 : 11;
generate
  if (C_AXI_ADDR_WIDTH > 12) begin : ADDR_GT_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : {axaddr[C_AXI_ADDR_WIDTH-1:L_AXI_ADDR_LOW_BIT],axaddr_wrap[11:0]};
  end else begin : ADDR_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : axaddr_wrap[11:0];
  end
endgenerate
assign axaddr_i = axaddr[11:0];
assign axlen_i = axlen[3:0];
always @( * ) begin
  if(axhandshake) begin
    wrap_boundary_axaddr = axaddr_i & ~(axlen_i << axsize[1:0]);
    axaddr_offset = axaddr_i[axsize[1:0] +: 4] & axlen_i;
  end else begin
    wrap_boundary_axaddr = wrap_boundary_axaddr_r;
    axaddr_offset = axaddr_offset_r; 
  end
end
always @( * ) begin
  if(axhandshake) begin
    wrap_second_len = (axaddr_offset >0) ? axaddr_offset - 1 : 0;
  end else begin
    wrap_second_len = wrap_second_len_r;
  end
end
always @(posedge clk) begin
  wrap_boundary_axaddr_r <= wrap_boundary_axaddr;
  axaddr_offset_r <= axaddr_offset;
  wrap_second_len_r <= wrap_second_len;
end
assign wrap_cnt = {1'b0, wrap_second_len + {3'b000, (|axaddr_offset)}}; 
always @(posedge clk)
  wrap_cnt_r <= wrap_cnt;
always @(posedge clk) begin
  if (axhandshake) begin
    axaddr_wrap <= axaddr[11:0];
  end if(next)begin
    if(axlen_cnt == wrap_cnt_r) begin
      axaddr_wrap <= wrap_boundary_axaddr_r;
    end else begin
      axaddr_wrap <= axaddr_wrap + (1 << axsize[1:0]);
    end
  end
end 
always @(posedge clk) begin
  if (axhandshake)begin
    axlen_cnt <= axlen_i;
    next_pending_r <= axlen_i >= 1;
  end else if (next) begin
    if (axlen_cnt > 1) begin
      axlen_cnt <= axlen_cnt - 1;
      next_pending_r <= (axlen_cnt - 1) >= 1;
    end else begin
      axlen_cnt <= 5'd0;
      next_pending_r <= 1'b0;
    end
  end  
end  
always @( * ) begin
  if (axhandshake)begin
    next_pending = axlen_i >= 1;
  end else if (next) begin
    if (axlen_cnt > 1) begin
      next_pending = (axlen_cnt - 1) >= 1;
    end else begin
      next_pending = 1'b0;
    end
  end else begin
    next_pending = next_pending_r;
  end 
end  
always @(posedge clk) begin
  if (reset | axhandshake) begin
    sel_first <= 1'b1;
  end else if (next) begin
    sel_first <= 1'b0;
  end
end
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_incr_cmd #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32
)
(
  input  wire                                 clk           ,
  input  wire                                 reset         ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]          axaddr        ,
  input  wire [7:0]                           axlen         ,
  input  wire [2:0]                           axsize        ,
  input  wire                                 axhandshake   ,
  output wire [C_AXI_ADDR_WIDTH-1:0]          cmd_byte_addr ,
  input  wire                                 next          ,
  output reg                                  next_pending
);
reg                           sel_first;
reg  [11:0]                   axaddr_incr;
reg  [8:0]                    axlen_cnt;
reg                           next_pending_r;
wire [3:0]                    axsize_shift;
wire [11:0]                   axsize_mask;
localparam    L_AXI_ADDR_LOW_BIT = (C_AXI_ADDR_WIDTH >= 12) ? 12 : 11;
generate
  if (C_AXI_ADDR_WIDTH > 12) begin : ADDR_GT_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : {axaddr[C_AXI_ADDR_WIDTH-1:L_AXI_ADDR_LOW_BIT],axaddr_incr[11:0]};
  end else begin : ADDR_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : axaddr_incr[11:0];
  end
endgenerate
assign axsize_shift = (1 << axsize[1:0]);
assign axsize_mask  = ~(axsize_shift - 1'b1);
always @(posedge clk) begin
  if (sel_first) begin
    if(~next) begin
      axaddr_incr <= axaddr[11:0] & axsize_mask;
    end else begin
      axaddr_incr <= (axaddr[11:0] & axsize_mask) + axsize_shift;
    end
  end else if (next) begin
    axaddr_incr <= axaddr_incr + axsize_shift;
  end
end
always @(posedge clk) begin
  if (axhandshake)begin
     axlen_cnt <= axlen;
     next_pending_r <= (axlen >= 1);
  end else if (next) begin
    if (axlen_cnt > 1) begin
      axlen_cnt <= axlen_cnt - 1;
      next_pending_r <= ((axlen_cnt - 1) >= 1);
    end else begin
      axlen_cnt <= 9'd0;
      next_pending_r <= 1'b0;
    end
  end
end
always @( * ) begin
  if (axhandshake)begin
     next_pending = (axlen >= 1);
  end else if (next) begin
    if (axlen_cnt > 1) begin
      next_pending = ((axlen_cnt - 1) >= 1);
    end else begin
      next_pending = 1'b0;
    end
  end else begin
    next_pending = next_pending_r;
  end
end
always @(posedge clk) begin
  if (reset | axhandshake) begin
    sel_first <= 1'b1;
  end else if (next) begin
    sel_first <= 1'b0;
  end
end
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_wr_cmd_fsm (
  input  wire                                 clk           ,
  input  wire                                 reset         ,
  output wire                                 s_awready       ,
  input  wire                                 s_awvalid       ,
  output wire                                 m_awvalid        ,
  input  wire                                 m_awready      ,
  output wire                                 next          ,
  input  wire                                 next_pending  ,
  output wire                                 b_push        ,
  input  wire                                 b_full        ,
  output wire                                 a_push
);
localparam SM_IDLE                = 2'b00;
localparam SM_CMD_EN              = 2'b01;
localparam SM_CMD_ACCEPTED        = 2'b10;
localparam SM_DONE_WAIT           = 2'b11;
reg [1:0]       state = SM_IDLE;
reg [1:0]       next_state;
always @(posedge clk) begin
  if (reset) begin
    state <= SM_IDLE;
  end else begin
    state <= next_state;
  end
end
always @( * )
begin
  next_state = state;
  case (state)
    SM_IDLE:
      if (s_awvalid) begin
        next_state = SM_CMD_EN;
      end else
        next_state = state;
    SM_CMD_EN:
      if (m_awready & next_pending)
        next_state = SM_CMD_ACCEPTED;
      else if (m_awready & ~next_pending & b_full)
        next_state = SM_DONE_WAIT;
      else if (m_awready & ~next_pending & ~b_full)
        next_state = SM_IDLE;
      else
        next_state = state;
    SM_CMD_ACCEPTED:
      next_state = SM_CMD_EN;
    SM_DONE_WAIT:
      if (!b_full)
        next_state = SM_IDLE;
      else
        next_state = state;
      default:
        next_state = SM_IDLE;
  endcase
end
assign m_awvalid  = (state == SM_CMD_EN);
assign next    = ((state == SM_CMD_ACCEPTED)
                 | (((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE))) ;
assign a_push  = (state == SM_IDLE);
assign s_awready = ((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE);
assign b_push  = ((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_rd_cmd_fsm (
  input  wire                                 clk           ,
  input  wire                                 reset         ,
  output wire                                 s_arready       ,
  input  wire                                 s_arvalid       ,
  input  wire [7:0]                           s_arlen         ,
  output wire                                 m_arvalid        ,
  input  wire                                 m_arready      ,
  output wire                                 next          ,
  input  wire                                 next_pending  ,
  input  wire                                 data_ready    ,
  output wire                                 a_push        ,
  output wire                                 r_push
);
localparam SM_IDLE                = 2'b00;
localparam SM_CMD_EN              = 2'b01;
localparam SM_CMD_ACCEPTED        = 2'b10;
localparam SM_DONE                = 2'b11;
reg [1:0]       state = SM_IDLE;
reg [1:0]       state_r1 = SM_IDLE;
reg [1:0]       next_state;
reg [7:0]       s_arlen_r;
always @(posedge clk) begin
  if (reset) begin
    state <= SM_IDLE;
    state_r1 <= SM_IDLE;
    s_arlen_r  <= 0;
  end else begin
    state <= next_state;
    state_r1 <= state;
    s_arlen_r  <= s_arlen;
  end
end
always @( * ) begin
  next_state = state;
  case (state)
    SM_IDLE:
      if (s_arvalid & data_ready) begin
        next_state = SM_CMD_EN;
      end else begin
        next_state = state;
      end
    SM_CMD_EN:
      if (~data_ready & m_arready & next_pending) begin
        next_state = SM_CMD_ACCEPTED;
      end else if (m_arready & ~next_pending)begin
         next_state = SM_DONE;
      end else if (m_arready & next_pending) begin
        next_state = SM_CMD_EN;
      end else begin
        next_state = state;
      end
    SM_CMD_ACCEPTED:
      if (data_ready) begin
        next_state = SM_CMD_EN;
      end else begin
        next_state = state;
      end
    SM_DONE:
        next_state = SM_IDLE;
      default:
        next_state = SM_IDLE;
  endcase
end
assign m_arvalid  = (state == SM_CMD_EN);
assign next    = m_arready && (state == SM_CMD_EN);
assign         r_push  = next;
assign a_push  = (state == SM_IDLE);
assign s_arready = ((state == SM_CMD_EN) || (state == SM_DONE))  && (next_state == SM_IDLE);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_cmd_translator #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32
)
(
  input  wire                                 clk           , 
  input  wire                                 reset         , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          s_axaddr        , 
  input  wire [7:0]                           s_axlen         , 
  input  wire [2:0]                           s_axsize        , 
  input  wire [1:0]                           s_axburst       , 
  input  wire                                 s_axhandshake   , 
  output wire [C_AXI_ADDR_WIDTH-1:0]          m_axaddr , 
  output wire                                 incr_burst    , 
  input  wire                                 next          , 
  output wire                                 next_pending
);
localparam P_AXBURST_FIXED = 2'b00;
localparam P_AXBURST_INCR  = 2'b01;
localparam P_AXBURST_WRAP  = 2'b10;
wire [C_AXI_ADDR_WIDTH-1:0]     incr_cmd_byte_addr;
wire                            incr_next_pending;
wire [C_AXI_ADDR_WIDTH-1:0]     wrap_cmd_byte_addr;
wire                            wrap_next_pending;
reg                             sel_first;
reg                             s_axburst_eq1;
reg                             s_axburst_eq0;
reg                             sel_first_i;   
assign m_axaddr         = (s_axburst == P_AXBURST_FIXED) ?  s_axaddr : 
                          (s_axburst == P_AXBURST_INCR)  ?  incr_cmd_byte_addr : 
                                                            wrap_cmd_byte_addr;
assign incr_burst       = (s_axburst[1]) ? 1'b0 : 1'b1;
always @(posedge clk) begin
  if (reset | s_axhandshake) begin
    sel_first <= 1'b1;
  end else if (next) begin
    sel_first <= 1'b0;
  end
end
always @( * ) begin
  if (reset | s_axhandshake) begin
    sel_first_i = 1'b1;
  end else if (next) begin
    sel_first_i = 1'b0;
  end else begin
    sel_first_i = sel_first;
  end
end
assign next_pending = s_axburst[1] ? s_axburst_eq1 : s_axburst_eq0;
always @(posedge clk) begin
  if (sel_first_i || s_axburst[1]) begin
    s_axburst_eq1 <= wrap_next_pending;
  end else begin
    s_axburst_eq1 <= incr_next_pending;
  end
  if (sel_first_i || !s_axburst[1]) begin
    s_axburst_eq0 <= incr_next_pending;
  end else begin
    s_axburst_eq0 <= wrap_next_pending;
  end
end
axi_protocol_converter_v2_1_13_b2s_incr_cmd #(
  .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH)
)
incr_cmd_0
(
  .clk           ( clk                ) ,
  .reset         ( reset              ) ,
  .axaddr        ( s_axaddr           ) ,
  .axlen         ( s_axlen            ) ,
  .axsize        ( s_axsize           ) ,
  .axhandshake   ( s_axhandshake      ) ,
  .cmd_byte_addr ( incr_cmd_byte_addr ) ,
  .next          ( next               ) ,
  .next_pending  ( incr_next_pending  ) 
);
axi_protocol_converter_v2_1_13_b2s_wrap_cmd #(
  .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH)
)
wrap_cmd_0
(
  .clk           ( clk                ) ,
  .reset         ( reset              ) ,
  .axaddr        ( s_axaddr           ) ,
  .axlen         ( s_axlen            ) ,
  .axsize        ( s_axsize           ) ,
  .axhandshake   ( s_axhandshake      ) ,
  .cmd_byte_addr ( wrap_cmd_byte_addr ) ,
  .next          ( next               ) ,
  .next_pending  ( wrap_next_pending  ) 
);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_b_channel #
(
  parameter integer C_ID_WIDTH                = 4
)
(
  input  wire                                 clk,
  input  wire                                 reset,
  output wire [C_ID_WIDTH-1:0]                s_bid,
  output wire [1:0]                           s_bresp,
  output wire                                 s_bvalid,
  input  wire                                 s_bready,
  input  wire [1:0]                           m_bresp,
  input  wire                                 m_bvalid,
  output wire                                 m_bready,
  input  wire                                 b_push,
  input  wire [C_ID_WIDTH-1:0]                b_awid,
  input  wire [7:0]                           b_awlen,
  input  wire                                 b_resp_rdy,
  output wire                                 b_full
);
localparam [1:0] LP_RESP_OKAY        = 2'b00;
localparam [1:0] LP_RESP_EXOKAY      = 2'b01;
localparam [1:0] LP_RESP_SLVERROR    = 2'b10;
localparam [1:0] LP_RESP_DECERR      = 2'b11;
localparam P_WIDTH  = C_ID_WIDTH + 8;
localparam P_DEPTH  = 4;
localparam P_AWIDTH = 2;
localparam P_RWIDTH  = 2;
localparam P_RDEPTH  = 4;
localparam P_RAWIDTH = 2;
reg                     bvalid_i = 1'b0;
wire [C_ID_WIDTH-1:0]   bid_i;
wire                    shandshake;
reg                     shandshake_r = 1'b0;
wire                    mhandshake;
reg                     mhandshake_r = 1'b0;
wire                    b_empty;
wire                    bresp_full;
wire                    bresp_empty;
wire [7:0]              b_awlen_i;
reg  [7:0]              bresp_cnt;
reg  [1:0]              s_bresp_acc;
wire [1:0]              s_bresp_acc_r;
reg  [1:0]              s_bresp_i;
wire                    need_to_update_bresp;
wire                    bresp_push;
assign s_bid      = bid_i;
assign s_bresp    = s_bresp_acc_r;
assign s_bvalid   = bvalid_i;
assign shandshake = s_bvalid & s_bready;
assign mhandshake = m_bvalid & m_bready;
always @(posedge clk) begin
  if (reset | shandshake) begin
    bvalid_i <= 1'b0;
  end else if (~b_empty & ~shandshake_r & ~bresp_empty) begin
    bvalid_i <= 1'b1;
  end
end
always @(posedge clk) begin
  if (reset) begin
    shandshake_r <= 1'b0;
    mhandshake_r <= 1'b0;
  end else begin
    shandshake_r <= shandshake;
    mhandshake_r <= mhandshake;
  end
end
axi_protocol_converter_v2_1_13_b2s_simple_fifo #(
  .C_WIDTH                  (P_WIDTH),
  .C_AWIDTH                 (P_AWIDTH),
  .C_DEPTH                  (P_DEPTH)
)
bid_fifo_0
(
  .clk     ( clk          ) ,
  .rst     ( reset        ) ,
  .wr_en   ( b_push       ) ,
  .rd_en   ( shandshake_r ) ,
  .din     ( {b_awid, b_awlen} ) ,
  .dout    ( {bid_i, b_awlen_i}) ,
  .a_full  (              ) ,
  .full    ( b_full       ) ,
  .a_empty (              ) ,
  .empty   ( b_empty        )
);
assign m_bready = ~mhandshake_r & bresp_empty;
assign need_to_update_bresp = ( m_bresp > s_bresp_acc );
always @( * ) begin
  if ( need_to_update_bresp ) begin
    s_bresp_i = m_bresp;
  end else begin
    s_bresp_i = s_bresp_acc;
  end
end
always @ (posedge clk) begin
  if (reset | bresp_push ) begin
    s_bresp_acc <= LP_RESP_OKAY;
  end else if ( mhandshake ) begin
    s_bresp_acc <= s_bresp_i;
  end
end
assign bresp_push = ( mhandshake_r ) & (bresp_cnt == b_awlen_i) & ~b_empty;
always @ (posedge clk) begin
  if (reset | bresp_push ) begin
    bresp_cnt <= 8'h00;
  end else if ( mhandshake_r ) begin
    bresp_cnt <= bresp_cnt + 1'b1;
  end
end
axi_protocol_converter_v2_1_13_b2s_simple_fifo #(
  .C_WIDTH                  (P_RWIDTH),
  .C_AWIDTH                 (P_RAWIDTH),
  .C_DEPTH                  (P_RDEPTH)
)
bresp_fifo_0
(
  .clk     ( clk          ) ,
  .rst     ( reset        ) ,
  .wr_en   ( bresp_push   ) ,
  .rd_en   ( shandshake_r ) ,
  .din     ( s_bresp_acc  ) ,
  .dout    ( s_bresp_acc_r) ,
  .a_full  (              ) ,
  .full    ( bresp_full   ) ,
  .a_empty (              ) ,
  .empty   ( bresp_empty  )
);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_r_channel #
(
  parameter integer C_ID_WIDTH                = 4,
  parameter integer C_DATA_WIDTH              = 32
)
(
  input  wire                                 clk              ,
  input  wire                                 reset            ,
  output wire  [C_ID_WIDTH-1:0]               s_rid              ,
  output wire  [C_DATA_WIDTH-1:0]             s_rdata            ,
  output wire [1:0]                           s_rresp            ,
  output wire                                 s_rlast            ,
  output wire                                 s_rvalid           ,
  input  wire                                 s_rready           ,
  input  wire [C_DATA_WIDTH-1:0]              m_rdata   ,
  input  wire [1:0]                           m_rresp   ,
  input  wire                                 m_rvalid  ,
  output wire                                 m_rready  ,
  input  wire                                 r_push           ,
  output wire                                 r_full           ,
  input  wire [C_ID_WIDTH-1:0]                r_arid           ,
  input  wire                                 r_rlast
);
localparam P_WIDTH = 1+C_ID_WIDTH;
localparam P_DEPTH = 32;
localparam P_AWIDTH = 5;
localparam P_D_WIDTH = C_DATA_WIDTH + 2;
localparam P_D_DEPTH  = 32;
localparam P_D_AWIDTH = 5;
wire [C_ID_WIDTH+1-1:0]    trans_in;
wire [C_ID_WIDTH+1-1:0]    trans_out;
wire                       tr_empty;
wire                       rhandshake;
wire                       r_valid_i;
wire [P_D_WIDTH-1:0]       rd_data_fifo_in;
wire [P_D_WIDTH-1:0]       rd_data_fifo_out;
wire                       rd_en;
wire                       rd_full;
wire                       rd_empty;
wire                       rd_a_full;
wire                       fifo_a_full;
reg [C_ID_WIDTH-1:0]       r_arid_r;
reg                        r_rlast_r;
reg                        r_push_r;
wire                       fifo_full;
assign s_rresp  = rd_data_fifo_out[P_D_WIDTH-1:C_DATA_WIDTH];
assign s_rid    = trans_out[1+:C_ID_WIDTH];
assign s_rdata  = rd_data_fifo_out[C_DATA_WIDTH-1:0];
assign s_rlast  = trans_out[0];
assign s_rvalid = ~rd_empty & ~tr_empty;
assign rd_en      = rhandshake & (~rd_empty);
assign rhandshake =(s_rvalid & s_rready);
always @(posedge clk) begin
  r_arid_r <= r_arid;
  r_rlast_r <= r_rlast;
  r_push_r <= r_push;
end
assign trans_in[0]  = r_rlast_r;
assign trans_in[1+:C_ID_WIDTH]  = r_arid_r;
axi_protocol_converter_v2_1_13_b2s_simple_fifo #(
  .C_WIDTH                (P_D_WIDTH),
  .C_AWIDTH               (P_D_AWIDTH),
  .C_DEPTH                (P_D_DEPTH)
)
rd_data_fifo_0
(
  .clk     ( clk              ) ,
  .rst     ( reset            ) ,
  .wr_en   ( m_rvalid & m_rready ) ,
  .rd_en   ( rd_en            ) ,
  .din     ( rd_data_fifo_in  ) ,
  .dout    ( rd_data_fifo_out ) ,
  .a_full  ( rd_a_full        ) ,
  .full    ( rd_full          ) ,
  .a_empty (                  ) ,
  .empty   ( rd_empty         )
);
assign rd_data_fifo_in = {m_rresp, m_rdata};
axi_protocol_converter_v2_1_13_b2s_simple_fifo #(
  .C_WIDTH                  (P_WIDTH),
  .C_AWIDTH                 (P_AWIDTH),
  .C_DEPTH                  (P_DEPTH)
)
transaction_fifo_0
(
  .clk     ( clk         ) ,
  .rst     ( reset       ) ,
  .wr_en   ( r_push_r    ) ,
  .rd_en   ( rd_en       ) ,
  .din     ( trans_in    ) ,
  .dout    ( trans_out   ) ,
  .a_full  ( fifo_a_full ) ,
  .full    (             ) ,
  .a_empty (             ) ,
  .empty   ( tr_empty    )
);
assign fifo_full = fifo_a_full | rd_a_full ;
assign r_full = fifo_full ;
assign m_rready = ~rd_a_full;
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_aw_channel #
(
  parameter integer C_ID_WIDTH          = 4,
  parameter integer C_AXI_ADDR_WIDTH    = 32
)
(
  input  wire                                 clk             ,
  input  wire                                 reset           ,
  input  wire [C_ID_WIDTH-1:0]                s_awid            ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]          s_awaddr          ,
  input  wire [7:0]                           s_awlen           ,
  input  wire [2:0]                           s_awsize          ,
  input  wire [1:0]                           s_awburst         ,
  input  wire                                 s_awvalid         ,
  output wire                                 s_awready         ,
  output wire                                 m_awvalid         ,
  output wire [C_AXI_ADDR_WIDTH-1:0]          m_awaddr          ,
  input  wire                                 m_awready         ,
  output wire                                 b_push           ,
  output wire [C_ID_WIDTH-1:0]                b_awid           ,
  output wire [7:0]                           b_awlen          ,
  input  wire                                 b_full
);
wire                        next         ;
wire                        next_pending ;
wire                        a_push;
wire                        incr_burst;
reg  [C_ID_WIDTH-1:0]       s_awid_r;
reg  [7:0]                  s_awlen_r;
axi_protocol_converter_v2_1_13_b2s_cmd_translator #
(
  .C_AXI_ADDR_WIDTH ( C_AXI_ADDR_WIDTH )
)
cmd_translator_0
(
  .clk           ( clk                   ) ,
  .reset         ( reset                 ) ,
  .s_axaddr      ( s_awaddr              ) ,
  .s_axlen       ( s_awlen               ) ,
  .s_axsize      ( s_awsize              ) ,
  .s_axburst     ( s_awburst             ) ,
  .s_axhandshake ( s_awvalid & a_push    ) ,
  .m_axaddr      ( m_awaddr              ) ,
  .incr_burst    ( incr_burst            ) ,
  .next          ( next                  ) ,
  .next_pending  ( next_pending          )
);
axi_protocol_converter_v2_1_13_b2s_wr_cmd_fsm aw_cmd_fsm_0
(
  .clk          ( clk            ) ,
  .reset        ( reset          ) ,
  .s_awready    ( s_awready      ) ,
  .s_awvalid    ( s_awvalid      ) ,
  .m_awvalid    ( m_awvalid      ) ,
  .m_awready    ( m_awready      ) ,
  .next         ( next           ) ,
  .next_pending ( next_pending   ) ,
  .b_push       ( b_push         ) ,
  .b_full       ( b_full         ) ,
  .a_push       ( a_push         )
);
assign b_awid = s_awid_r;
assign b_awlen = s_awlen_r;
always @(posedge clk) begin
  s_awid_r <= s_awid ;
  s_awlen_r <= s_awlen ;
end
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s_ar_channel #
(
  parameter integer C_ID_WIDTH          = 4,
  parameter integer C_AXI_ADDR_WIDTH    = 32
)
(
  input  wire                                 clk             ,
  input  wire                                 reset           ,
  input  wire [C_ID_WIDTH-1:0]                s_arid            ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]          s_araddr          ,
  input  wire [7:0]                           s_arlen           ,
  input  wire [2:0]                           s_arsize          ,
  input  wire [1:0]                           s_arburst         ,
  input  wire                                 s_arvalid         ,
  output wire                                 s_arready         ,
  output wire                                 m_arvalid         ,
  output wire [C_AXI_ADDR_WIDTH-1:0]          m_araddr          ,
  input  wire                                 m_arready         ,
  output wire [C_ID_WIDTH-1:0]                r_arid            ,
  output wire                                 r_push            ,
  output wire                                 r_rlast           ,
  input  wire                                 r_full
);
wire                        next      ;
wire                        next_pending ;
wire                        a_push;
wire                        incr_burst;
reg [C_ID_WIDTH-1:0]        s_arid_r;
axi_protocol_converter_v2_1_13_b2s_cmd_translator #
(
  .C_AXI_ADDR_WIDTH ( C_AXI_ADDR_WIDTH )
)
cmd_translator_0
(
  .clk           ( clk                   ) ,
  .reset         ( reset                 ) ,
  .s_axaddr      ( s_araddr              ) ,
  .s_axlen       ( s_arlen               ) ,
  .s_axsize      ( s_arsize              ) ,
  .s_axburst     ( s_arburst             ) ,
  .s_axhandshake ( s_arvalid & a_push    ) ,
  .incr_burst    ( incr_burst            ) ,
  .m_axaddr      ( m_araddr              ) ,
  .next          ( next                  ) ,
  .next_pending  ( next_pending          )
);
axi_protocol_converter_v2_1_13_b2s_rd_cmd_fsm ar_cmd_fsm_0
(
  .clk          ( clk            ) ,
  .reset        ( reset          ) ,
  .s_arready    ( s_arready      ) ,
  .s_arvalid    ( s_arvalid      ) ,
  .s_arlen      ( s_arlen        ) ,
  .m_arvalid    ( m_arvalid      ) ,
  .m_arready    ( m_arready      ) ,
  .next         ( next           ) ,
  .next_pending ( next_pending   ) ,
  .data_ready   ( ~r_full        ) ,
  .a_push       ( a_push         ) ,
  .r_push       ( r_push         )
);
assign r_arid  = s_arid_r;
assign r_rlast = ~next_pending;
always @(posedge clk) begin
  s_arid_r <= s_arid ;
end
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_b2s #(
  parameter C_S_AXI_PROTOCOL                      = 0,
  parameter integer C_AXI_ID_WIDTH                = 4,
  parameter integer C_AXI_ADDR_WIDTH              = 30,
  parameter integer C_AXI_DATA_WIDTH              = 32,
  parameter integer C_AXI_SUPPORTS_WRITE          = 1,
  parameter integer C_AXI_SUPPORTS_READ           = 1
)
(
  input  wire                               aclk              ,
  input  wire                               aresetn           ,
  input  wire [C_AXI_ID_WIDTH-1:0]          s_axi_awid        ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]        s_axi_awaddr      ,
  input  wire [((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_awlen,
  input  wire [2:0]                         s_axi_awsize      ,
  input  wire [1:0]                         s_axi_awburst     ,
  input  wire [2:0]                         s_axi_awprot      ,
  input  wire                               s_axi_awvalid     ,
  output wire                               s_axi_awready     ,
  input  wire [C_AXI_DATA_WIDTH-1:0]        s_axi_wdata       ,
  input  wire [C_AXI_DATA_WIDTH/8-1:0]      s_axi_wstrb       ,
  input  wire                               s_axi_wlast       ,
  input  wire                               s_axi_wvalid      ,
  output wire                               s_axi_wready      ,
  output wire [C_AXI_ID_WIDTH-1:0]          s_axi_bid         ,
  output wire [1:0]                         s_axi_bresp       ,
  output wire                               s_axi_bvalid      ,
  input  wire                               s_axi_bready      ,
  input  wire [C_AXI_ID_WIDTH-1:0]          s_axi_arid        ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]        s_axi_araddr      ,
  input  wire [((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_arlen,
  input  wire [2:0]                         s_axi_arsize      ,
  input  wire [1:0]                         s_axi_arburst     ,
  input  wire [2:0]                         s_axi_arprot      ,
  input  wire                               s_axi_arvalid     ,
  output wire                               s_axi_arready     ,
  output wire [C_AXI_ID_WIDTH-1:0]          s_axi_rid         ,
  output wire [C_AXI_DATA_WIDTH-1:0]        s_axi_rdata       ,
  output wire [1:0]                         s_axi_rresp       ,
  output wire                               s_axi_rlast       ,
  output wire                               s_axi_rvalid      ,
  input  wire                               s_axi_rready      ,
  output wire [C_AXI_ADDR_WIDTH-1:0]        m_axi_awaddr      ,
  output wire [2:0]                         m_axi_awprot      ,
  output wire                               m_axi_awvalid     ,
  input  wire                               m_axi_awready     ,
  output wire [C_AXI_DATA_WIDTH-1:0]        m_axi_wdata       ,
  output wire [C_AXI_DATA_WIDTH/8-1:0]      m_axi_wstrb       ,
  output wire                               m_axi_wvalid      ,
  input  wire                               m_axi_wready      ,
  input  wire [1:0]                         m_axi_bresp       ,
  input  wire                               m_axi_bvalid      ,
  output wire                               m_axi_bready      ,
  output wire [C_AXI_ADDR_WIDTH-1:0]        m_axi_araddr      ,
  output wire [2:0]                         m_axi_arprot      ,
  output wire                               m_axi_arvalid     ,
  input  wire                               m_axi_arready     ,
  input  wire [C_AXI_DATA_WIDTH-1:0]        m_axi_rdata       ,
  input  wire [1:0]                         m_axi_rresp       ,
  input  wire                               m_axi_rvalid      ,
  output wire                               m_axi_rready
);
reg                            areset_d1 = 1'b0;
always @(posedge aclk)
  areset_d1 <= ~aresetn;
wire                                b_push;
wire [C_AXI_ID_WIDTH-1:0]           b_awid;
wire [7:0]                          b_awlen;
wire                                b_full;
wire [C_AXI_ID_WIDTH-1:0]                   si_rs_awid;
wire [C_AXI_ADDR_WIDTH-1:0]                 si_rs_awaddr;
wire [8-1:0]                                si_rs_awlen;
wire [3-1:0]                                si_rs_awsize;
wire [2-1:0]                                si_rs_awburst;
wire [3-1:0]                                si_rs_awprot;
wire                                        si_rs_awvalid;
wire                                        si_rs_awready;
wire [C_AXI_DATA_WIDTH-1:0]                 si_rs_wdata;
wire [C_AXI_DATA_WIDTH/8-1:0]               si_rs_wstrb;
wire                                        si_rs_wlast;
wire                                        si_rs_wvalid;
wire                                        si_rs_wready;
wire [C_AXI_ID_WIDTH-1:0]                   si_rs_bid;
wire [2-1:0]                                si_rs_bresp;
wire                                        si_rs_bvalid;
wire                                        si_rs_bready;
wire [C_AXI_ID_WIDTH-1:0]                   si_rs_arid;
wire [C_AXI_ADDR_WIDTH-1:0]                 si_rs_araddr;
wire [8-1:0]                                si_rs_arlen;
wire [3-1:0]                                si_rs_arsize;
wire [2-1:0]                                si_rs_arburst;
wire [3-1:0]                                si_rs_arprot;
wire                                        si_rs_arvalid;
wire                                        si_rs_arready;
wire [C_AXI_ID_WIDTH-1:0]                   si_rs_rid;
wire [C_AXI_DATA_WIDTH-1:0]                 si_rs_rdata;
wire [2-1:0]                                si_rs_rresp;
wire                                        si_rs_rlast;
wire                                        si_rs_rvalid;
wire                                        si_rs_rready;
wire [C_AXI_ADDR_WIDTH-1:0]                 rs_mi_awaddr;
wire                                        rs_mi_awvalid;
wire                                        rs_mi_awready;
wire [C_AXI_DATA_WIDTH-1:0]                 rs_mi_wdata;
wire [C_AXI_DATA_WIDTH/8-1:0]               rs_mi_wstrb;
wire                                        rs_mi_wvalid;
wire                                        rs_mi_wready;
wire [2-1:0]                                rs_mi_bresp;
wire                                        rs_mi_bvalid;
wire                                        rs_mi_bready;
wire [C_AXI_ADDR_WIDTH-1:0]                 rs_mi_araddr;
wire                                        rs_mi_arvalid;
wire                                        rs_mi_arready;
wire [C_AXI_DATA_WIDTH-1:0]                 rs_mi_rdata;
wire [2-1:0]                                rs_mi_rresp;
wire                                        rs_mi_rvalid;
wire                                        rs_mi_rready;
axi_register_slice_v2_1_13_axi_register_slice #(
  .C_AXI_PROTOCOL              ( C_S_AXI_PROTOCOL            ) ,
  .C_AXI_ID_WIDTH              ( C_AXI_ID_WIDTH              ) ,
  .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
  .C_AXI_DATA_WIDTH            ( C_AXI_DATA_WIDTH            ) ,
  .C_AXI_SUPPORTS_USER_SIGNALS ( 0 ) ,
  .C_AXI_AWUSER_WIDTH          ( 1 ) ,
  .C_AXI_ARUSER_WIDTH          ( 1 ) ,
  .C_AXI_WUSER_WIDTH           ( 1 ) ,
  .C_AXI_RUSER_WIDTH           ( 1 ) ,
  .C_AXI_BUSER_WIDTH           ( 1 ) ,
  .C_REG_CONFIG_AW             ( 1 ) ,
  .C_REG_CONFIG_AR             ( 1 ) ,
  .C_REG_CONFIG_W              ( 0 ) ,
  .C_REG_CONFIG_R              ( 1 ) ,
  .C_REG_CONFIG_B              ( 1 )
) SI_REG (
  .aresetn                    ( aresetn     ) ,
  .aclk                       ( aclk          ) ,
  .s_axi_awid                 ( s_axi_awid    ) ,
  .s_axi_awaddr               ( s_axi_awaddr  ) ,
  .s_axi_awlen                ( s_axi_awlen   ) ,
  .s_axi_awsize               ( s_axi_awsize  ) ,
  .s_axi_awburst              ( s_axi_awburst ) ,
  .s_axi_awlock               ( {((C_S_AXI_PROTOCOL == 1) ? 2 : 1){1'b0}}  ) ,
  .s_axi_awcache              ( 4'h0 ) ,
  .s_axi_awprot               ( s_axi_awprot  ) ,
  .s_axi_awqos                ( 4'h0 ) ,
  .s_axi_awuser               ( 1'b0  ) ,
  .s_axi_awvalid              ( s_axi_awvalid ) ,
  .s_axi_awready              ( s_axi_awready ) ,
  .s_axi_awregion             ( 4'h0 ) ,
  .s_axi_wid                  ( {C_AXI_ID_WIDTH{1'b0}} ) ,
  .s_axi_wdata                ( s_axi_wdata   ) ,
  .s_axi_wstrb                ( s_axi_wstrb   ) ,
  .s_axi_wlast                ( s_axi_wlast   ) ,
  .s_axi_wuser                ( 1'b0  ) ,
  .s_axi_wvalid               ( s_axi_wvalid  ) ,
  .s_axi_wready               ( s_axi_wready  ) ,
  .s_axi_bid                  ( s_axi_bid     ) ,
  .s_axi_bresp                ( s_axi_bresp   ) ,
  .s_axi_buser                ( ) ,
  .s_axi_bvalid               ( s_axi_bvalid  ) ,
  .s_axi_bready               ( s_axi_bready  ) ,
  .s_axi_arid                 ( s_axi_arid    ) ,
  .s_axi_araddr               ( s_axi_araddr  ) ,
  .s_axi_arlen                ( s_axi_arlen   ) ,
  .s_axi_arsize               ( s_axi_arsize  ) ,
  .s_axi_arburst              ( s_axi_arburst ) ,
  .s_axi_arlock               ( {((C_S_AXI_PROTOCOL == 1) ? 2 : 1){1'b0}}  ) ,
  .s_axi_arcache              ( 4'h0 ) ,
  .s_axi_arprot               ( s_axi_arprot  ) ,
  .s_axi_arqos                ( 4'h0 ) ,
  .s_axi_aruser               ( 1'b0  ) ,
  .s_axi_arvalid              ( s_axi_arvalid ) ,
  .s_axi_arready              ( s_axi_arready ) ,
  .s_axi_arregion             ( 4'h0 ) ,
  .s_axi_rid                  ( s_axi_rid     ) ,
  .s_axi_rdata                ( s_axi_rdata   ) ,
  .s_axi_rresp                ( s_axi_rresp   ) ,
  .s_axi_rlast                ( s_axi_rlast   ) ,
  .s_axi_ruser                ( ) ,
  .s_axi_rvalid               ( s_axi_rvalid  ) ,
  .s_axi_rready               ( s_axi_rready  ) ,
  .m_axi_awid                 ( si_rs_awid    ) ,
  .m_axi_awaddr               ( si_rs_awaddr  ) ,
  .m_axi_awlen                ( si_rs_awlen[((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] ) ,
  .m_axi_awsize               ( si_rs_awsize  ) ,
  .m_axi_awburst              ( si_rs_awburst ) ,
  .m_axi_awlock               ( ) ,
  .m_axi_awcache              ( ) ,
  .m_axi_awprot               ( si_rs_awprot  ) ,
  .m_axi_awqos                ( ) ,
  .m_axi_awuser               ( ) ,
  .m_axi_awvalid              ( si_rs_awvalid ) ,
  .m_axi_awready              ( si_rs_awready ) ,
  .m_axi_awregion             ( ) ,
  .m_axi_wid                  ( ) ,
  .m_axi_wdata                ( si_rs_wdata   ) ,
  .m_axi_wstrb                ( si_rs_wstrb   ) ,
  .m_axi_wlast                ( si_rs_wlast   ) ,
  .m_axi_wuser                ( ) ,
  .m_axi_wvalid               ( si_rs_wvalid  ) ,
  .m_axi_wready               ( si_rs_wready  ) ,
  .m_axi_bid                  ( si_rs_bid     ) ,
  .m_axi_bresp                ( si_rs_bresp   ) ,
  .m_axi_buser                ( 1'b0 ) ,
  .m_axi_bvalid               ( si_rs_bvalid  ) ,
  .m_axi_bready               ( si_rs_bready  ) ,
  .m_axi_arid                 ( si_rs_arid    ) ,
  .m_axi_araddr               ( si_rs_araddr  ) ,
  .m_axi_arlen                ( si_rs_arlen[((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] ) ,
  .m_axi_arsize               ( si_rs_arsize  ) ,
  .m_axi_arburst              ( si_rs_arburst ) ,
  .m_axi_arlock               ( ) ,
  .m_axi_arcache              ( ) ,
  .m_axi_arprot               ( si_rs_arprot  ) ,
  .m_axi_arqos                ( ) ,
  .m_axi_aruser               ( ) ,
  .m_axi_arvalid              ( si_rs_arvalid ) ,
  .m_axi_arready              ( si_rs_arready ) ,
  .m_axi_arregion             ( ) ,
  .m_axi_rid                  ( si_rs_rid     ) ,
  .m_axi_rdata                ( si_rs_rdata   ) ,
  .m_axi_rresp                ( si_rs_rresp   ) ,
  .m_axi_rlast                ( si_rs_rlast   ) ,
  .m_axi_ruser                ( 1'b0 ) ,
  .m_axi_rvalid               ( si_rs_rvalid  ) ,
  .m_axi_rready               ( si_rs_rready  )
);
generate
  if (C_AXI_SUPPORTS_WRITE == 1) begin : WR
    axi_protocol_converter_v2_1_13_b2s_aw_channel #
    (
      .C_ID_WIDTH                       ( C_AXI_ID_WIDTH   ),
      .C_AXI_ADDR_WIDTH                 ( C_AXI_ADDR_WIDTH )
    )
    aw_channel_0
    (
      .clk                              ( aclk              ) ,
      .reset                            ( areset_d1         ) ,
      .s_awid                           ( si_rs_awid        ) ,
      .s_awaddr                         ( si_rs_awaddr      ) ,
      .s_awlen                          ( (C_S_AXI_PROTOCOL == 1) ? {4'h0,si_rs_awlen[3:0]} : si_rs_awlen),
      .s_awsize                         ( si_rs_awsize      ) ,
      .s_awburst                        ( si_rs_awburst     ) ,
      .s_awvalid                        ( si_rs_awvalid     ) ,
      .s_awready                        ( si_rs_awready     ) ,
      .m_awvalid                        ( rs_mi_awvalid     ) ,
      .m_awaddr                         ( rs_mi_awaddr      ) ,
      .m_awready                        ( rs_mi_awready     ) ,
      .b_push                           ( b_push            ) ,
      .b_awid                           ( b_awid            ) ,
      .b_awlen                          ( b_awlen           ) ,
      .b_full                           ( b_full            )
    );
    axi_protocol_converter_v2_1_13_b2s_b_channel #
    (
      .C_ID_WIDTH                       ( C_AXI_ID_WIDTH   )
    )
    b_channel_0
    (
      .clk                              ( aclk            ) ,
      .reset                            ( areset_d1       ) ,
      .s_bid                            ( si_rs_bid       ) ,
      .s_bresp                          ( si_rs_bresp     ) ,
      .s_bvalid                         ( si_rs_bvalid    ) ,
      .s_bready                         ( si_rs_bready    ) ,
      .m_bready                         ( rs_mi_bready    ) ,
      .m_bvalid                         ( rs_mi_bvalid    ) ,
      .m_bresp                          ( rs_mi_bresp     ) ,
      .b_push                           ( b_push          ) ,
      .b_awid                           ( b_awid          ) ,
      .b_awlen                          ( b_awlen         ) ,
      .b_full                           ( b_full          ) ,
      .b_resp_rdy                       ( si_rs_awready   )
    );
    assign rs_mi_wdata        = si_rs_wdata;
    assign rs_mi_wstrb        = si_rs_wstrb;
    assign rs_mi_wvalid       = si_rs_wvalid;
    assign si_rs_wready       = rs_mi_wready;
  end else begin : NO_WR
    assign rs_mi_awaddr       = {C_AXI_ADDR_WIDTH{1'b0}};
    assign rs_mi_awvalid      = 1'b0;
    assign si_rs_awready      = 1'b0;
    assign rs_mi_wdata        = {C_AXI_DATA_WIDTH{1'b0}};
    assign rs_mi_wstrb        = {C_AXI_DATA_WIDTH/8{1'b0}};
    assign rs_mi_wvalid       = 1'b0;
    assign si_rs_wready       = 1'b0;
    assign rs_mi_bready    = 1'b0;
    assign si_rs_bvalid       = 1'b0;
    assign si_rs_bresp        = 2'b00;
    assign si_rs_bid          = {C_AXI_ID_WIDTH{1'b0}};
  end
endgenerate
wire                                r_push        ;
wire [C_AXI_ID_WIDTH-1:0]           r_arid        ;
wire                                r_rlast       ;
wire                                r_full        ;
generate
  if (C_AXI_SUPPORTS_READ == 1) begin : RD
    axi_protocol_converter_v2_1_13_b2s_ar_channel #
    (
      .C_ID_WIDTH                       ( C_AXI_ID_WIDTH   ),
      .C_AXI_ADDR_WIDTH                 ( C_AXI_ADDR_WIDTH )
    )
    ar_channel_0
    (
      .clk                              ( aclk              ) ,
      .reset                            ( areset_d1         ) ,
      .s_arid                           ( si_rs_arid        ) ,
      .s_araddr                         ( si_rs_araddr      ) ,
      .s_arlen                          ( (C_S_AXI_PROTOCOL == 1) ? {4'h0,si_rs_arlen[3:0]} : si_rs_arlen),
      .s_arsize                         ( si_rs_arsize      ) ,
      .s_arburst                        ( si_rs_arburst     ) ,
      .s_arvalid                        ( si_rs_arvalid     ) ,
      .s_arready                        ( si_rs_arready     ) ,
      .m_arvalid                        ( rs_mi_arvalid     ) ,
      .m_araddr                         ( rs_mi_araddr      ) ,
      .m_arready                        ( rs_mi_arready     ) ,
      .r_push                           ( r_push            ) ,
      .r_arid                           ( r_arid            ) ,
      .r_rlast                          ( r_rlast           ) ,
      .r_full                           ( r_full            )
    );
    axi_protocol_converter_v2_1_13_b2s_r_channel #
    (
      .C_ID_WIDTH                       ( C_AXI_ID_WIDTH   ),
      .C_DATA_WIDTH                     ( C_AXI_DATA_WIDTH )
    )
    r_channel_0
    (
      .clk                              ( aclk            ) ,
      .reset                            ( areset_d1       ) ,
      .s_rid                            ( si_rs_rid       ) ,
      .s_rdata                          ( si_rs_rdata     ) ,
      .s_rresp                          ( si_rs_rresp     ) ,
      .s_rlast                          ( si_rs_rlast     ) ,
      .s_rvalid                         ( si_rs_rvalid    ) ,
      .s_rready                         ( si_rs_rready    ) ,
      .m_rvalid                         ( rs_mi_rvalid    ) ,
      .m_rready                         ( rs_mi_rready    ) ,
      .m_rdata                          ( rs_mi_rdata     ) ,
      .m_rresp                          ( rs_mi_rresp     ) ,
      .r_push                           ( r_push          ) ,
      .r_full                           ( r_full          ) ,
      .r_arid                           ( r_arid          ) ,
      .r_rlast                          ( r_rlast         )
    );
  end else begin : NO_RD
    assign rs_mi_araddr       = {C_AXI_ADDR_WIDTH{1'b0}};
    assign rs_mi_arvalid      = 1'b0;
    assign si_rs_arready      = 1'b0;
    assign si_rs_rlast        = 1'b1;
    assign si_rs_rdata        = {C_AXI_DATA_WIDTH{1'b0}};
    assign si_rs_rvalid       = 1'b0;
    assign si_rs_rresp        = 2'b00;
    assign si_rs_rid          = {C_AXI_ID_WIDTH{1'b0}};
    assign rs_mi_rready       = 1'b0;
  end
endgenerate
axi_register_slice_v2_1_13_axi_register_slice #(
  .C_AXI_PROTOCOL              ( 2 ) ,
  .C_AXI_ID_WIDTH              ( 1 ) ,
  .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
  .C_AXI_DATA_WIDTH            ( C_AXI_DATA_WIDTH            ) ,
  .C_AXI_SUPPORTS_USER_SIGNALS ( 0 ) ,
  .C_AXI_AWUSER_WIDTH          ( 1 ) ,
  .C_AXI_ARUSER_WIDTH          ( 1 ) ,
  .C_AXI_WUSER_WIDTH           ( 1 ) ,
  .C_AXI_RUSER_WIDTH           ( 1 ) ,
  .C_AXI_BUSER_WIDTH           ( 1 ) ,
  .C_REG_CONFIG_AW             ( 0 ) ,
  .C_REG_CONFIG_AR             ( 0 ) ,
  .C_REG_CONFIG_W              ( 0 ) ,
  .C_REG_CONFIG_R              ( 0 ) ,
  .C_REG_CONFIG_B              ( 0 )
) MI_REG (
  .aresetn                    ( aresetn       ) ,
  .aclk                       ( aclk          ) ,
  .s_axi_awid                 ( 1'b0          ) ,
  .s_axi_awaddr               ( rs_mi_awaddr  ) ,
  .s_axi_awlen                ( 8'h00         ) ,
  .s_axi_awsize               ( 3'b000        ) ,
  .s_axi_awburst              ( 2'b01         ) ,
  .s_axi_awlock               ( 1'b0          ) ,
  .s_axi_awcache              ( 4'h0          ) ,
  .s_axi_awprot               ( si_rs_awprot  ) ,
  .s_axi_awqos                ( 4'h0          ) ,
  .s_axi_awuser               ( 1'b0          ) ,
  .s_axi_awvalid              ( rs_mi_awvalid ) ,
  .s_axi_awready              ( rs_mi_awready ) ,
  .s_axi_awregion             ( 4'h0          ) ,
  .s_axi_wid                  ( 1'b0          ) ,
  .s_axi_wdata                ( rs_mi_wdata   ) ,
  .s_axi_wstrb                ( rs_mi_wstrb   ) ,
  .s_axi_wlast                ( 1'b1          ) ,
  .s_axi_wuser                ( 1'b0          ) ,
  .s_axi_wvalid               ( rs_mi_wvalid  ) ,
  .s_axi_wready               ( rs_mi_wready  ) ,
  .s_axi_bid                  (               ) ,
  .s_axi_bresp                ( rs_mi_bresp   ) ,
  .s_axi_buser                (               ) ,
  .s_axi_bvalid               ( rs_mi_bvalid  ) ,
  .s_axi_bready               ( rs_mi_bready  ) ,
  .s_axi_arid                 ( 1'b0          ) ,
  .s_axi_araddr               ( rs_mi_araddr  ) ,
  .s_axi_arlen                ( 8'h00         ) ,
  .s_axi_arsize               ( 3'b000        ) ,
  .s_axi_arburst              ( 2'b01         ) ,
  .s_axi_arlock               ( 1'b0          ) ,
  .s_axi_arcache              ( 4'h0          ) ,
  .s_axi_arprot               ( si_rs_arprot  ) ,
  .s_axi_arqos                ( 4'h0          ) ,
  .s_axi_aruser               ( 1'b0          ) ,
  .s_axi_arvalid              ( rs_mi_arvalid ) ,
  .s_axi_arready              ( rs_mi_arready ) ,
  .s_axi_arregion             ( 4'h0          ) ,
  .s_axi_rid                  (               ) ,
  .s_axi_rdata                ( rs_mi_rdata   ) ,
  .s_axi_rresp                ( rs_mi_rresp   ) ,
  .s_axi_rlast                (               ) ,
  .s_axi_ruser                (               ) ,
  .s_axi_rvalid               ( rs_mi_rvalid  ) ,
  .s_axi_rready               ( rs_mi_rready  ) ,
  .m_axi_awid                 (               ) ,
  .m_axi_awaddr               ( m_axi_awaddr  ) ,
  .m_axi_awlen                (               ) ,
  .m_axi_awsize               (               ) ,
  .m_axi_awburst              (               ) ,
  .m_axi_awlock               (               ) ,
  .m_axi_awcache              (               ) ,
  .m_axi_awprot               ( m_axi_awprot  ) ,
  .m_axi_awqos                (               ) ,
  .m_axi_awuser               (               ) ,
  .m_axi_awvalid              ( m_axi_awvalid ) ,
  .m_axi_awready              ( m_axi_awready ) ,
  .m_axi_awregion             (               ) ,
  .m_axi_wid                  (               ) ,
  .m_axi_wdata                ( m_axi_wdata   ) ,
  .m_axi_wstrb                ( m_axi_wstrb   ) ,
  .m_axi_wlast                (               ) ,
  .m_axi_wuser                (               ) ,
  .m_axi_wvalid               ( m_axi_wvalid  ) ,
  .m_axi_wready               ( m_axi_wready  ) ,
  .m_axi_bid                  ( 1'b0          ) ,
  .m_axi_bresp                ( m_axi_bresp   ) ,
  .m_axi_buser                ( 1'b0          ) ,
  .m_axi_bvalid               ( m_axi_bvalid  ) ,
  .m_axi_bready               ( m_axi_bready  ) ,
  .m_axi_arid                 (               ) ,
  .m_axi_araddr               ( m_axi_araddr  ) ,
  .m_axi_arlen                (               ) ,
  .m_axi_arsize               (               ) ,
  .m_axi_arburst              (               ) ,
  .m_axi_arlock               (               ) ,
  .m_axi_arcache              (               ) ,
  .m_axi_arprot               ( m_axi_arprot  ) ,
  .m_axi_arqos                (               ) ,
  .m_axi_aruser               (               ) ,
  .m_axi_arvalid              ( m_axi_arvalid ) ,
  .m_axi_arready              ( m_axi_arready ) ,
  .m_axi_arregion             (               ) ,
  .m_axi_rid                  ( 1'b0          ) ,
  .m_axi_rdata                ( m_axi_rdata   ) ,
  .m_axi_rresp                ( m_axi_rresp   ) ,
  .m_axi_rlast                ( 1'b1          ) ,
  .m_axi_ruser                ( 1'b0          ) ,
  .m_axi_rvalid               ( m_axi_rvalid  ) ,
  .m_axi_rready               ( m_axi_rready  )
);
endmodule
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_13_axi_protocol_converter #(
  parameter         C_FAMILY                    = "virtex6",
  parameter integer C_M_AXI_PROTOCOL            = 0, 
  parameter integer C_S_AXI_PROTOCOL            = 0, 
  parameter integer C_IGNORE_ID                = 0,
  parameter integer C_AXI_ID_WIDTH              = 4,
  parameter integer C_AXI_ADDR_WIDTH            = 32,
  parameter integer C_AXI_DATA_WIDTH            = 32,
  parameter integer C_AXI_SUPPORTS_WRITE        = 1,
  parameter integer C_AXI_SUPPORTS_READ         = 1,
  parameter integer C_AXI_SUPPORTS_USER_SIGNALS = 0,
  parameter integer C_AXI_AWUSER_WIDTH          = 1,
  parameter integer C_AXI_ARUSER_WIDTH          = 1,
  parameter integer C_AXI_WUSER_WIDTH           = 1,
  parameter integer C_AXI_RUSER_WIDTH           = 1,
  parameter integer C_AXI_BUSER_WIDTH           = 1,
  parameter integer C_TRANSLATION_MODE                  = 1
) (
   input wire aclk,
   input wire aresetn,
   input  wire [C_AXI_ID_WIDTH-1:0]     s_axi_awid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,
   input  wire [((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_awlen,
   input  wire [3-1:0]                  s_axi_awsize,
   input  wire [2-1:0]                  s_axi_awburst,
   input  wire [((C_S_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  s_axi_awlock,
   input  wire [4-1:0]                  s_axi_awcache,
   input  wire [3-1:0]                  s_axi_awprot,
   input  wire [4-1:0]                  s_axi_awregion,
   input  wire [4-1:0]                  s_axi_awqos,
   input  wire [C_AXI_AWUSER_WIDTH-1:0] s_axi_awuser,
   input  wire                          s_axi_awvalid,
   output wire                          s_axi_awready,
   input wire [C_AXI_ID_WIDTH-1:0]      s_axi_wid,
   input  wire [C_AXI_DATA_WIDTH-1:0]   s_axi_wdata,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
   input  wire                          s_axi_wlast,
   input  wire [C_AXI_WUSER_WIDTH-1:0]  s_axi_wuser,
   input  wire                          s_axi_wvalid,
   output wire                          s_axi_wready,
   output wire [C_AXI_ID_WIDTH-1:0]    s_axi_bid,
   output wire [2-1:0]                 s_axi_bresp,
   output wire [C_AXI_BUSER_WIDTH-1:0] s_axi_buser,
   output wire                         s_axi_bvalid,
   input  wire                         s_axi_bready,
   input  wire [C_AXI_ID_WIDTH-1:0]     s_axi_arid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   s_axi_araddr,
   input  wire [((C_S_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  s_axi_arlen,
   input  wire [3-1:0]                  s_axi_arsize,
   input  wire [2-1:0]                  s_axi_arburst,
   input  wire [((C_S_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  s_axi_arlock,
   input  wire [4-1:0]                  s_axi_arcache,
   input  wire [3-1:0]                  s_axi_arprot,
   input  wire [4-1:0]                  s_axi_arregion,
   input  wire [4-1:0]                  s_axi_arqos,
   input  wire [C_AXI_ARUSER_WIDTH-1:0] s_axi_aruser,
   input  wire                          s_axi_arvalid,
   output wire                          s_axi_arready,
   output wire [C_AXI_ID_WIDTH-1:0]    s_axi_rid,
   output wire [C_AXI_DATA_WIDTH-1:0]  s_axi_rdata,
   output wire [2-1:0]                 s_axi_rresp,
   output wire                         s_axi_rlast,
   output wire [C_AXI_RUSER_WIDTH-1:0] s_axi_ruser,
   output wire                         s_axi_rvalid,
   input  wire                         s_axi_rready,
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_awid,
   output wire [C_AXI_ADDR_WIDTH-1:0]   m_axi_awaddr,
   output wire [((C_M_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_awlen,
   output wire [3-1:0]                  m_axi_awsize,
   output wire [2-1:0]                  m_axi_awburst,
   output wire [((C_M_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_awlock,
   output wire [4-1:0]                  m_axi_awcache,
   output wire [3-1:0]                  m_axi_awprot,
   output wire [4-1:0]                  m_axi_awregion,
   output wire [4-1:0]                  m_axi_awqos,
   output wire [C_AXI_AWUSER_WIDTH-1:0] m_axi_awuser,
   output wire                          m_axi_awvalid,
   input  wire                          m_axi_awready,
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_wid,
   output wire [C_AXI_DATA_WIDTH-1:0]   m_axi_wdata,
   output wire [C_AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,
   output wire                          m_axi_wlast,
   output wire [C_AXI_WUSER_WIDTH-1:0]  m_axi_wuser,
   output wire                          m_axi_wvalid,
   input  wire                          m_axi_wready,
   input  wire [C_AXI_ID_WIDTH-1:0]    m_axi_bid,
   input  wire [2-1:0]                 m_axi_bresp,
   input  wire [C_AXI_BUSER_WIDTH-1:0] m_axi_buser,
   input  wire                         m_axi_bvalid,
   output wire                         m_axi_bready,
   output wire [C_AXI_ID_WIDTH-1:0]     m_axi_arid,
   output wire [C_AXI_ADDR_WIDTH-1:0]   m_axi_araddr,
   output wire [((C_M_AXI_PROTOCOL == 1) ? 4 : 8)-1:0]  m_axi_arlen,
   output wire [3-1:0]                  m_axi_arsize,
   output wire [2-1:0]                  m_axi_arburst,
   output wire [((C_M_AXI_PROTOCOL == 1) ? 2 : 1)-1:0]  m_axi_arlock,
   output wire [4-1:0]                  m_axi_arcache,
   output wire [3-1:0]                  m_axi_arprot,
   output wire [4-1:0]                  m_axi_arregion,
   output wire [4-1:0]                  m_axi_arqos,
   output wire [C_AXI_ARUSER_WIDTH-1:0] m_axi_aruser,
   output wire                          m_axi_arvalid,
   input  wire                          m_axi_arready,
   input  wire [C_AXI_ID_WIDTH-1:0]    m_axi_rid,
   input  wire [C_AXI_DATA_WIDTH-1:0]  m_axi_rdata,
   input  wire [2-1:0]                 m_axi_rresp,
   input  wire                         m_axi_rlast,
   input  wire [C_AXI_RUSER_WIDTH-1:0] m_axi_ruser,
   input  wire                         m_axi_rvalid,
   output wire                         m_axi_rready
);
localparam P_AXI4 = 32'h0;
localparam P_AXI3 = 32'h1;
localparam P_AXILITE = 32'h2;
localparam P_AXILITE_SIZE = (C_AXI_DATA_WIDTH == 32) ? 3'b010 : 3'b011;
localparam P_INCR = 2'b01;
localparam P_DECERR = 2'b11;
localparam P_SLVERR = 2'b10;
localparam integer P_PROTECTION = 1;
localparam integer P_CONVERSION = 2;
wire                          s_awvalid_i;
wire                          s_arvalid_i;
wire                          s_wvalid_i ;
wire                          s_bready_i ;
wire                          s_rready_i ;
wire                          s_awready_i; 
wire                          s_wready_i;
wire                          s_bvalid_i;
wire [C_AXI_ID_WIDTH-1:0]     s_bid_i;
wire [1:0]                    s_bresp_i;
wire [C_AXI_BUSER_WIDTH-1:0]  s_buser_i;
wire                          s_arready_i; 
wire                          s_rvalid_i;
wire [C_AXI_ID_WIDTH-1:0]     s_rid_i;
wire [1:0]                    s_rresp_i;
wire [C_AXI_RUSER_WIDTH-1:0]  s_ruser_i;
wire [C_AXI_DATA_WIDTH-1:0]   s_rdata_i;
wire                          s_rlast_i;
generate
  if ((C_M_AXI_PROTOCOL == P_AXILITE)  || (C_S_AXI_PROTOCOL == P_AXILITE)) begin : gen_axilite
    assign m_axi_awid         = 0;
    assign m_axi_awlen        = 0;
    assign m_axi_awsize       = P_AXILITE_SIZE;
    assign m_axi_awburst      = P_INCR;
    assign m_axi_awlock       = 0;
    assign m_axi_awcache      = 0;
    assign m_axi_awregion     = 0;
    assign m_axi_awqos        = 0;
    assign m_axi_awuser       = 0;
    assign m_axi_wid          = 0;
    assign m_axi_wlast        = 1'b1;
    assign m_axi_wuser        = 0;
    assign m_axi_arid         = 0;
    assign m_axi_arlen        = 0;
    assign m_axi_arsize       = P_AXILITE_SIZE;
    assign m_axi_arburst      = P_INCR;
    assign m_axi_arlock       = 0;
    assign m_axi_arcache      = 0;
    assign m_axi_arregion     = 0;
    assign m_axi_arqos        = 0;
    assign m_axi_aruser       = 0;
    if (((C_IGNORE_ID == 1) && (C_TRANSLATION_MODE != P_CONVERSION)) || (C_S_AXI_PROTOCOL == P_AXILITE)) begin : gen_axilite_passthru
      assign m_axi_awaddr       = s_axi_awaddr;
      assign m_axi_awprot       = s_axi_awprot;
      assign m_axi_awvalid      = s_awvalid_i;
      assign s_awready_i        = m_axi_awready;
      assign m_axi_wdata        = s_axi_wdata;
      assign m_axi_wstrb        = s_axi_wstrb;
      assign m_axi_wvalid       = s_wvalid_i;
      assign s_wready_i         = m_axi_wready;
      assign s_bid_i            = 0;
      assign s_bresp_i          = m_axi_bresp;
      assign s_buser_i          = 0;
      assign s_bvalid_i         = m_axi_bvalid;
      assign m_axi_bready       = s_bready_i;
      assign m_axi_araddr       = s_axi_araddr;
      assign m_axi_arprot       = s_axi_arprot;
      assign m_axi_arvalid      = s_arvalid_i;
      assign s_arready_i        = m_axi_arready;
      assign s_rid_i            = 0;
      assign s_rdata_i          = m_axi_rdata;
      assign s_rresp_i          = m_axi_rresp;
      assign s_rlast_i          = 1'b1;
      assign s_ruser_i          = 0;
      assign s_rvalid_i         = m_axi_rvalid;
      assign m_axi_rready       = s_rready_i;
    end else if (C_TRANSLATION_MODE == P_CONVERSION) begin : gen_b2s_conv
      assign s_buser_i = {C_AXI_BUSER_WIDTH{1'b0}};
      assign s_ruser_i = {C_AXI_RUSER_WIDTH{1'b0}};
      axi_protocol_converter_v2_1_13_b2s #(
        .C_S_AXI_PROTOCOL                 (C_S_AXI_PROTOCOL),
        .C_AXI_ID_WIDTH                   (C_AXI_ID_WIDTH),
        .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
        .C_AXI_DATA_WIDTH                 (C_AXI_DATA_WIDTH),
        .C_AXI_SUPPORTS_WRITE             (C_AXI_SUPPORTS_WRITE),
        .C_AXI_SUPPORTS_READ              (C_AXI_SUPPORTS_READ)
      ) axilite_b2s (
        .aresetn                          (aresetn),
        .aclk                             (aclk),
        .s_axi_awid                       (s_axi_awid),
        .s_axi_awaddr                     (s_axi_awaddr),
        .s_axi_awlen                      (s_axi_awlen),
        .s_axi_awsize                     (s_axi_awsize),
        .s_axi_awburst                    (s_axi_awburst),
        .s_axi_awprot                     (s_axi_awprot),
        .s_axi_awvalid                    (s_awvalid_i),
        .s_axi_awready                    (s_awready_i),
        .s_axi_wdata                      (s_axi_wdata),
        .s_axi_wstrb                      (s_axi_wstrb),
        .s_axi_wlast                      (s_axi_wlast),
        .s_axi_wvalid                     (s_wvalid_i),
        .s_axi_wready                     (s_wready_i),
        .s_axi_bid                        (s_bid_i),
        .s_axi_bresp                      (s_bresp_i),
        .s_axi_bvalid                     (s_bvalid_i),
        .s_axi_bready                     (s_bready_i),
        .s_axi_arid                       (s_axi_arid),
        .s_axi_araddr                     (s_axi_araddr),
        .s_axi_arlen                      (s_axi_arlen),
        .s_axi_arsize                     (s_axi_arsize),
        .s_axi_arburst                    (s_axi_arburst),
        .s_axi_arprot                     (s_axi_arprot),
        .s_axi_arvalid                    (s_arvalid_i),
        .s_axi_arready                    (s_arready_i),
        .s_axi_rid                        (s_rid_i),
        .s_axi_rdata                      (s_rdata_i),
        .s_axi_rresp                      (s_rresp_i),
        .s_axi_rlast                      (s_rlast_i),
        .s_axi_rvalid                     (s_rvalid_i),
        .s_axi_rready                     (s_rready_i),
        .m_axi_awaddr                     (m_axi_awaddr),
        .m_axi_awprot                     (m_axi_awprot),
        .m_axi_awvalid                    (m_axi_awvalid),
        .m_axi_awready                    (m_axi_awready),
        .m_axi_wdata                      (m_axi_wdata),
        .m_axi_wstrb                      (m_axi_wstrb),
        .m_axi_wvalid                     (m_axi_wvalid),
        .m_axi_wready                     (m_axi_wready),
        .m_axi_bresp                      (m_axi_bresp),
        .m_axi_bvalid                     (m_axi_bvalid),
        .m_axi_bready                     (m_axi_bready),
        .m_axi_araddr                     (m_axi_araddr),
        .m_axi_arprot                     (m_axi_arprot),
        .m_axi_arvalid                    (m_axi_arvalid),
        .m_axi_arready                    (m_axi_arready),
        .m_axi_rdata                      (m_axi_rdata),
        .m_axi_rresp                      (m_axi_rresp),
        .m_axi_rvalid                     (m_axi_rvalid),
        .m_axi_rready                     (m_axi_rready)
      );
    end else begin : gen_axilite_conv
      axi_protocol_converter_v2_1_13_axilite_conv #(
        .C_FAMILY                         (C_FAMILY),
        .C_AXI_ID_WIDTH                   (C_AXI_ID_WIDTH),
        .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
        .C_AXI_DATA_WIDTH                 (C_AXI_DATA_WIDTH),
        .C_AXI_SUPPORTS_WRITE             (C_AXI_SUPPORTS_WRITE),
        .C_AXI_SUPPORTS_READ              (C_AXI_SUPPORTS_READ),
        .C_AXI_RUSER_WIDTH                (C_AXI_RUSER_WIDTH),
        .C_AXI_BUSER_WIDTH                (C_AXI_BUSER_WIDTH)
      ) axilite_conv_inst (
        .ARESETN                          (aresetn),
        .ACLK                             (aclk),
        .S_AXI_AWID                       (s_axi_awid),
        .S_AXI_AWADDR                     (s_axi_awaddr),
        .S_AXI_AWPROT                     (s_axi_awprot),
        .S_AXI_AWVALID                    (s_awvalid_i),
        .S_AXI_AWREADY                    (s_awready_i),
        .S_AXI_WDATA                      (s_axi_wdata),
        .S_AXI_WSTRB                      (s_axi_wstrb),
        .S_AXI_WVALID                     (s_wvalid_i),
        .S_AXI_WREADY                     (s_wready_i),
        .S_AXI_BID                        (s_bid_i),
        .S_AXI_BRESP                      (s_bresp_i),
        .S_AXI_BUSER                      (s_buser_i),
        .S_AXI_BVALID                     (s_bvalid_i),
        .S_AXI_BREADY                     (s_bready_i),
        .S_AXI_ARID                       (s_axi_arid),
        .S_AXI_ARADDR                     (s_axi_araddr),
        .S_AXI_ARPROT                     (s_axi_arprot),
        .S_AXI_ARVALID                    (s_arvalid_i),
        .S_AXI_ARREADY                    (s_arready_i),
        .S_AXI_RID                        (s_rid_i),
        .S_AXI_RDATA                      (s_rdata_i),
        .S_AXI_RRESP                      (s_rresp_i),
        .S_AXI_RLAST                      (s_rlast_i),
        .S_AXI_RUSER                      (s_ruser_i),
        .S_AXI_RVALID                     (s_rvalid_i),
        .S_AXI_RREADY                     (s_rready_i),
        .M_AXI_AWADDR                     (m_axi_awaddr),
        .M_AXI_AWPROT                     (m_axi_awprot),
        .M_AXI_AWVALID                    (m_axi_awvalid),
        .M_AXI_AWREADY                    (m_axi_awready),
        .M_AXI_WDATA                      (m_axi_wdata),
        .M_AXI_WSTRB                      (m_axi_wstrb),
        .M_AXI_WVALID                     (m_axi_wvalid),
        .M_AXI_WREADY                     (m_axi_wready),
        .M_AXI_BRESP                      (m_axi_bresp),
        .M_AXI_BVALID                     (m_axi_bvalid),
        .M_AXI_BREADY                     (m_axi_bready),
        .M_AXI_ARADDR                     (m_axi_araddr),
        .M_AXI_ARPROT                     (m_axi_arprot),
        .M_AXI_ARVALID                    (m_axi_arvalid),
        .M_AXI_ARREADY                    (m_axi_arready),
        .M_AXI_RDATA                      (m_axi_rdata),
        .M_AXI_RRESP                      (m_axi_rresp),
        .M_AXI_RVALID                     (m_axi_rvalid),
        .M_AXI_RREADY                     (m_axi_rready)
      );
    end
  end else if ((C_M_AXI_PROTOCOL == P_AXI3) && (C_S_AXI_PROTOCOL == P_AXI4)) begin : gen_axi4_axi3
    axi_protocol_converter_v2_1_13_axi3_conv #(
      .C_FAMILY                         (C_FAMILY),
      .C_AXI_ID_WIDTH                   (C_AXI_ID_WIDTH),
      .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
      .C_AXI_DATA_WIDTH                 (C_AXI_DATA_WIDTH),
      .C_AXI_SUPPORTS_USER_SIGNALS      (C_AXI_SUPPORTS_USER_SIGNALS),
      .C_AXI_AWUSER_WIDTH               (C_AXI_AWUSER_WIDTH),
      .C_AXI_ARUSER_WIDTH               (C_AXI_ARUSER_WIDTH),
      .C_AXI_WUSER_WIDTH                (C_AXI_WUSER_WIDTH),
      .C_AXI_RUSER_WIDTH                (C_AXI_RUSER_WIDTH),
      .C_AXI_BUSER_WIDTH                (C_AXI_BUSER_WIDTH),
      .C_AXI_SUPPORTS_WRITE             (C_AXI_SUPPORTS_WRITE),
      .C_AXI_SUPPORTS_READ              (C_AXI_SUPPORTS_READ),
      .C_SUPPORT_SPLITTING              ((C_TRANSLATION_MODE == P_CONVERSION) ? 1 : 0)
    ) axi3_conv_inst (
      .ARESETN                          (aresetn),
      .ACLK                             (aclk),
      .S_AXI_AWID                       (s_axi_awid),
      .S_AXI_AWADDR                     (s_axi_awaddr),
      .S_AXI_AWLEN                      (s_axi_awlen),
      .S_AXI_AWSIZE                     (s_axi_awsize),
      .S_AXI_AWBURST                    (s_axi_awburst),
      .S_AXI_AWLOCK                     (s_axi_awlock),
      .S_AXI_AWCACHE                    (s_axi_awcache),
      .S_AXI_AWPROT                     (s_axi_awprot),
      .S_AXI_AWQOS                      (s_axi_awqos),
      .S_AXI_AWUSER                     (s_axi_awuser),
      .S_AXI_AWVALID                    (s_awvalid_i),
      .S_AXI_AWREADY                    (s_awready_i),
      .S_AXI_WDATA                      (s_axi_wdata),
      .S_AXI_WSTRB                      (s_axi_wstrb),
      .S_AXI_WLAST                      (s_axi_wlast),
      .S_AXI_WUSER                      (s_axi_wuser),
      .S_AXI_WVALID                     (s_wvalid_i),
      .S_AXI_WREADY                     (s_wready_i),
      .S_AXI_BID                        (s_bid_i),
      .S_AXI_BRESP                      (s_bresp_i),
      .S_AXI_BUSER                      (s_buser_i),
      .S_AXI_BVALID                     (s_bvalid_i),
      .S_AXI_BREADY                     (s_bready_i),
      .S_AXI_ARID                       (s_axi_arid),
      .S_AXI_ARADDR                     (s_axi_araddr),
      .S_AXI_ARLEN                      (s_axi_arlen),
      .S_AXI_ARSIZE                     (s_axi_arsize),
      .S_AXI_ARBURST                    (s_axi_arburst),
      .S_AXI_ARLOCK                     (s_axi_arlock),
      .S_AXI_ARCACHE                    (s_axi_arcache),
      .S_AXI_ARPROT                     (s_axi_arprot),
      .S_AXI_ARQOS                      (s_axi_arqos),
      .S_AXI_ARUSER                     (s_axi_aruser),
      .S_AXI_ARVALID                    (s_arvalid_i),
      .S_AXI_ARREADY                    (s_arready_i),
      .S_AXI_RID                        (s_rid_i),
      .S_AXI_RDATA                      (s_rdata_i),
      .S_AXI_RRESP                      (s_rresp_i),
      .S_AXI_RLAST                      (s_rlast_i),
      .S_AXI_RUSER                      (s_ruser_i),
      .S_AXI_RVALID                     (s_rvalid_i),
      .S_AXI_RREADY                     (s_rready_i),
      .M_AXI_AWID                       (m_axi_awid),
      .M_AXI_AWADDR                     (m_axi_awaddr),
      .M_AXI_AWLEN                      (m_axi_awlen),
      .M_AXI_AWSIZE                     (m_axi_awsize),
      .M_AXI_AWBURST                    (m_axi_awburst),
      .M_AXI_AWLOCK                     (m_axi_awlock),
      .M_AXI_AWCACHE                    (m_axi_awcache),
      .M_AXI_AWPROT                     (m_axi_awprot),
      .M_AXI_AWQOS                      (m_axi_awqos),
      .M_AXI_AWUSER                     (m_axi_awuser),
      .M_AXI_AWVALID                    (m_axi_awvalid),
      .M_AXI_AWREADY                    (m_axi_awready),
      .M_AXI_WID                        (m_axi_wid),
      .M_AXI_WDATA                      (m_axi_wdata),
      .M_AXI_WSTRB                      (m_axi_wstrb),
      .M_AXI_WLAST                      (m_axi_wlast),
      .M_AXI_WUSER                      (m_axi_wuser),
      .M_AXI_WVALID                     (m_axi_wvalid),
      .M_AXI_WREADY                     (m_axi_wready),
      .M_AXI_BID                        (m_axi_bid),
      .M_AXI_BRESP                      (m_axi_bresp),
      .M_AXI_BUSER                      (m_axi_buser),
      .M_AXI_BVALID                     (m_axi_bvalid),
      .M_AXI_BREADY                     (m_axi_bready),
      .M_AXI_ARID                       (m_axi_arid),
      .M_AXI_ARADDR                     (m_axi_araddr),
      .M_AXI_ARLEN                      (m_axi_arlen),
      .M_AXI_ARSIZE                     (m_axi_arsize),
      .M_AXI_ARBURST                    (m_axi_arburst),
      .M_AXI_ARLOCK                     (m_axi_arlock),
      .M_AXI_ARCACHE                    (m_axi_arcache),
      .M_AXI_ARPROT                     (m_axi_arprot),
      .M_AXI_ARQOS                      (m_axi_arqos),
      .M_AXI_ARUSER                     (m_axi_aruser),
      .M_AXI_ARVALID                    (m_axi_arvalid),
      .M_AXI_ARREADY                    (m_axi_arready),
      .M_AXI_RID                        (m_axi_rid),
      .M_AXI_RDATA                      (m_axi_rdata),
      .M_AXI_RRESP                      (m_axi_rresp),
      .M_AXI_RLAST                      (m_axi_rlast),
      .M_AXI_RUSER                      (m_axi_ruser),
      .M_AXI_RVALID                     (m_axi_rvalid),
      .M_AXI_RREADY                     (m_axi_rready)
    );
    assign m_axi_awregion     = 0;
    assign m_axi_arregion     = 0;
  end else if ((C_S_AXI_PROTOCOL == P_AXI3) && (C_M_AXI_PROTOCOL == P_AXI4)) begin : gen_axi3_axi4
    assign m_axi_awid                = s_axi_awid;
    assign m_axi_awaddr              = s_axi_awaddr;
    assign m_axi_awlen               = {4'h0, s_axi_awlen[3:0]};
    assign m_axi_awsize              = s_axi_awsize;
    assign m_axi_awburst             = s_axi_awburst;
    assign m_axi_awlock              = s_axi_awlock[0];
    assign m_axi_awcache             = s_axi_awcache;
    assign m_axi_awprot              = s_axi_awprot;
    assign m_axi_awregion            = 4'h0;
    assign m_axi_awqos               = s_axi_awqos;
    assign m_axi_awuser              = s_axi_awuser;
    assign m_axi_awvalid             = s_awvalid_i;
    assign s_awready_i               = m_axi_awready;
    assign m_axi_wid                 = {C_AXI_ID_WIDTH{1'b0}} ;
    assign m_axi_wdata               = s_axi_wdata;
    assign m_axi_wstrb               = s_axi_wstrb;
    assign m_axi_wlast               = s_axi_wlast;
    assign m_axi_wuser               = s_axi_wuser;
    assign m_axi_wvalid              = s_wvalid_i;
    assign s_wready_i                = m_axi_wready;
    assign s_bid_i                   = m_axi_bid;
    assign s_bresp_i                 = m_axi_bresp;
    assign s_buser_i                 = m_axi_buser;
    assign s_bvalid_i                = m_axi_bvalid;
    assign m_axi_bready              = s_bready_i;
    assign m_axi_arid                = s_axi_arid;
    assign m_axi_araddr              = s_axi_araddr;
    assign m_axi_arlen               = {4'h0, s_axi_arlen[3:0]};
    assign m_axi_arsize              = s_axi_arsize;
    assign m_axi_arburst             = s_axi_arburst;
    assign m_axi_arlock              = s_axi_arlock[0];
    assign m_axi_arcache             = s_axi_arcache;
    assign m_axi_arprot              = s_axi_arprot;
    assign m_axi_arregion            = 4'h0;
    assign m_axi_arqos               = s_axi_arqos;
    assign m_axi_aruser              = s_axi_aruser;
    assign m_axi_arvalid             = s_arvalid_i;
    assign s_arready_i               = m_axi_arready;
    assign s_rid_i                   = m_axi_rid;
    assign s_rdata_i                 = m_axi_rdata;
    assign s_rresp_i                 = m_axi_rresp;
    assign s_rlast_i                 = m_axi_rlast;
    assign s_ruser_i                 = m_axi_ruser;
    assign s_rvalid_i                = m_axi_rvalid;
    assign m_axi_rready              = s_rready_i;
  end else begin :gen_no_conv
    assign m_axi_awid                = s_axi_awid;
    assign m_axi_awaddr              = s_axi_awaddr;
    assign m_axi_awlen               = s_axi_awlen;
    assign m_axi_awsize              = s_axi_awsize;
    assign m_axi_awburst             = s_axi_awburst;
    assign m_axi_awlock              = s_axi_awlock;
    assign m_axi_awcache             = s_axi_awcache;
    assign m_axi_awprot              = s_axi_awprot;
    assign m_axi_awregion            = s_axi_awregion;
    assign m_axi_awqos               = s_axi_awqos;
    assign m_axi_awuser              = s_axi_awuser;
    assign m_axi_awvalid             = s_awvalid_i;
    assign s_awready_i               = m_axi_awready;
    assign m_axi_wid                 = s_axi_wid;
    assign m_axi_wdata               = s_axi_wdata;
    assign m_axi_wstrb               = s_axi_wstrb;
    assign m_axi_wlast               = s_axi_wlast;
    assign m_axi_wuser               = s_axi_wuser;
    assign m_axi_wvalid              = s_wvalid_i;
    assign s_wready_i                = m_axi_wready;
    assign s_bid_i                   = m_axi_bid;
    assign s_bresp_i                 = m_axi_bresp;
    assign s_buser_i                 = m_axi_buser;
    assign s_bvalid_i                = m_axi_bvalid;
    assign m_axi_bready              = s_bready_i;
    assign m_axi_arid                = s_axi_arid;
    assign m_axi_araddr              = s_axi_araddr;
    assign m_axi_arlen               = s_axi_arlen;
    assign m_axi_arsize              = s_axi_arsize;
    assign m_axi_arburst             = s_axi_arburst;
    assign m_axi_arlock              = s_axi_arlock;
    assign m_axi_arcache             = s_axi_arcache;
    assign m_axi_arprot              = s_axi_arprot;
    assign m_axi_arregion            = s_axi_arregion;
    assign m_axi_arqos               = s_axi_arqos;
    assign m_axi_aruser              = s_axi_aruser;
    assign m_axi_arvalid             = s_arvalid_i;
    assign s_arready_i               = m_axi_arready;
    assign s_rid_i                   = m_axi_rid;
    assign s_rdata_i                 = m_axi_rdata;
    assign s_rresp_i                 = m_axi_rresp;
    assign s_rlast_i                 = m_axi_rlast;
    assign s_ruser_i                 = m_axi_ruser;
    assign s_rvalid_i                = m_axi_rvalid;
    assign m_axi_rready              = s_rready_i;
  end
    if ((C_TRANSLATION_MODE == P_PROTECTION) && 
        (((C_S_AXI_PROTOCOL != P_AXILITE) && (C_M_AXI_PROTOCOL == P_AXILITE)) ||
        ((C_S_AXI_PROTOCOL == P_AXI4) && (C_M_AXI_PROTOCOL == P_AXI3)))) begin : gen_err_detect
      wire                           e_awvalid;
      reg                            e_awvalid_r = 1'b0;
      wire                           e_arvalid;
      reg                            e_arvalid_r = 1'b0;
      wire                           e_wvalid;
      wire                           e_bvalid;
      wire                           e_rvalid;
      reg                            e_awready = 1'b0;
      reg                            e_arready = 1'b0;
      wire                           e_wready;
      reg  [C_AXI_ID_WIDTH-1:0]      e_awid;
      reg  [C_AXI_ID_WIDTH-1:0]      e_arid;
      reg  [8-1:0]                   e_arlen;
      wire [C_AXI_ID_WIDTH-1:0]      e_bid;
      wire [C_AXI_ID_WIDTH-1:0]      e_rid;
      wire                           e_rlast;
      wire                           w_err;
      wire                           r_err;
      wire                           busy_aw;
      wire                           busy_w;
      wire                           busy_ar;
      wire                           aw_push;
      wire                           aw_pop;
      wire                           w_pop;
      wire                           ar_push;
      wire                           ar_pop;
      reg                            s_awvalid_pending = 1'b0;
      reg                            s_awvalid_en = 1'b0;
      reg                            s_arvalid_en = 1'b0;
      reg                            s_awready_en = 1'b0;
      reg                            s_arready_en = 1'b0;
      reg  [4:0]                     aw_cnt = 1'b0;
      reg  [4:0]                     ar_cnt = 1'b0;
      reg  [4:0]                     w_cnt = 1'b0;
      reg                            w_borrow = 1'b0;
      reg                            err_busy_w = 1'b0;
      reg                            err_busy_r = 1'b0;
      assign w_err = (C_M_AXI_PROTOCOL == P_AXILITE) ? (s_axi_awlen != 0) : ((s_axi_awlen>>4) != 0);
      assign r_err = (C_M_AXI_PROTOCOL == P_AXILITE) ? (s_axi_arlen != 0) : ((s_axi_arlen>>4) != 0);
      assign s_awvalid_i = s_axi_awvalid & s_awvalid_en & ~w_err;
      assign e_awvalid   = e_awvalid_r & ~busy_aw & ~busy_w;
      assign s_arvalid_i = s_axi_arvalid & s_arvalid_en & ~r_err;
      assign e_arvalid   = e_arvalid_r & ~busy_ar ;
      assign s_wvalid_i = s_axi_wvalid & (busy_w | (s_awvalid_pending & ~w_borrow));
      assign e_wvalid   = s_axi_wvalid & err_busy_w;
      assign s_bready_i = s_axi_bready & busy_aw;
      assign s_rready_i = s_axi_rready & busy_ar;
      assign s_axi_awready = (s_awready_i & s_awready_en) | e_awready; 
      assign s_axi_wready = (s_wready_i & (busy_w | (s_awvalid_pending & ~w_borrow))) | e_wready;
      assign s_axi_bvalid = (s_bvalid_i & busy_aw) | e_bvalid;
      assign s_axi_bid = err_busy_w ? e_bid : s_bid_i;
      assign s_axi_bresp = err_busy_w ? P_SLVERR : s_bresp_i;
      assign s_axi_buser = err_busy_w ? {C_AXI_BUSER_WIDTH{1'b0}} : s_buser_i;
      assign s_axi_arready = (s_arready_i & s_arready_en) | e_arready; 
      assign s_axi_rvalid = (s_rvalid_i & busy_ar) | e_rvalid;
      assign s_axi_rid = err_busy_r ? e_rid : s_rid_i;
      assign s_axi_rresp = err_busy_r ? P_SLVERR : s_rresp_i;
      assign s_axi_ruser = err_busy_r ? {C_AXI_RUSER_WIDTH{1'b0}} : s_ruser_i;
      assign s_axi_rdata = err_busy_r ? {C_AXI_DATA_WIDTH{1'b0}} : s_rdata_i;
      assign s_axi_rlast = err_busy_r ? e_rlast : s_rlast_i;
      assign busy_aw = (aw_cnt != 0);
      assign busy_w  = (w_cnt != 0);
      assign busy_ar = (ar_cnt != 0);
      assign aw_push = s_awvalid_i & s_awready_i & s_awready_en;
      assign aw_pop  = s_bvalid_i & s_bready_i;
      assign w_pop   = s_wvalid_i & s_wready_i & s_axi_wlast;
      assign ar_push = s_arvalid_i & s_arready_i & s_arready_en;
      assign ar_pop  = s_rvalid_i & s_rready_i & s_rlast_i;
      always @(posedge aclk) begin
        if (~aresetn) begin
          s_awvalid_en <= 1'b0;
          s_arvalid_en <= 1'b0;
          s_awready_en <= 1'b0;
          s_arready_en <= 1'b0;
          e_awvalid_r <= 1'b0;
          e_arvalid_r <= 1'b0;
          e_awready <= 1'b0;
          e_arready <= 1'b0;
          aw_cnt <= 0;
          w_cnt <= 0;
          ar_cnt <= 0;
          err_busy_w <= 1'b0;
          err_busy_r <= 1'b0;
          w_borrow <= 1'b0;
          s_awvalid_pending <= 1'b0;
        end else begin
          e_awready <= 1'b0;  
          if (e_bvalid & s_axi_bready) begin
            s_awvalid_en <= 1'b1;
            s_awready_en <= 1'b1;
            err_busy_w <= 1'b0;
          end else if (e_awvalid) begin
            e_awvalid_r <= 1'b0;
            err_busy_w <= 1'b1;
          end else if (s_axi_awvalid & w_err & ~e_awvalid_r & ~err_busy_w) begin
            e_awvalid_r <= 1'b1;
            e_awready <= ~(s_awready_i & s_awvalid_en);  
            s_awvalid_en <= 1'b0;
            s_awready_en <= 1'b0;
          end else if ((&aw_cnt) | (&w_cnt) | aw_push) begin
            s_awvalid_en <= 1'b0;
            s_awready_en <= 1'b0;
          end else if (~err_busy_w & ~e_awvalid_r & ~(s_axi_awvalid & w_err)) begin
            s_awvalid_en <= 1'b1;
            s_awready_en <= 1'b1;
          end
          if (aw_push & ~aw_pop) begin
            aw_cnt <= aw_cnt + 1;
          end else if (~aw_push & aw_pop & (|aw_cnt)) begin
            aw_cnt <= aw_cnt - 1;
          end
          if (aw_push) begin
            if (~w_pop & ~w_borrow) begin
              w_cnt <= w_cnt + 1;
            end
            w_borrow <= 1'b0;
          end else if (~aw_push & w_pop) begin
            if (|w_cnt) begin
              w_cnt <= w_cnt - 1;
            end else begin
              w_borrow <= 1'b1;
            end
          end
          s_awvalid_pending <= s_awvalid_i & ~s_awready_i;
          e_arready <= 1'b0;  
          if (e_rvalid & s_axi_rready & e_rlast) begin
            s_arvalid_en <= 1'b1;
            s_arready_en <= 1'b1;
            err_busy_r <= 1'b0;
          end else if (e_arvalid) begin
            e_arvalid_r <= 1'b0;
            err_busy_r <= 1'b1;
          end else if (s_axi_arvalid & r_err & ~e_arvalid_r & ~err_busy_r) begin
            e_arvalid_r <= 1'b1;
            e_arready <= ~(s_arready_i & s_arvalid_en);  
            s_arvalid_en <= 1'b0;
            s_arready_en <= 1'b0;
          end else if ((&ar_cnt) | ar_push) begin
            s_arvalid_en <= 1'b0;
            s_arready_en <= 1'b0;
          end else if (~err_busy_r & ~e_arvalid_r & ~(s_axi_arvalid & r_err)) begin
            s_arvalid_en <= 1'b1;
            s_arready_en <= 1'b1;
          end
          if (ar_push & ~ar_pop) begin
            ar_cnt <= ar_cnt + 1;
          end else if (~ar_push & ar_pop & (|ar_cnt)) begin
            ar_cnt <= ar_cnt - 1;
          end
        end
      end
      always @(posedge aclk) begin
        if (s_axi_awvalid & ~err_busy_w & ~e_awvalid_r ) begin
          e_awid <= s_axi_awid;
        end
        if (s_axi_arvalid & ~err_busy_r & ~e_arvalid_r ) begin
          e_arid <= s_axi_arid;
          e_arlen <= s_axi_arlen;
        end
      end
      axi_protocol_converter_v2_1_13_decerr_slave #
        (
         .C_AXI_ID_WIDTH                 (C_AXI_ID_WIDTH),
         .C_AXI_DATA_WIDTH               (C_AXI_DATA_WIDTH),
         .C_AXI_RUSER_WIDTH              (C_AXI_RUSER_WIDTH),
         .C_AXI_BUSER_WIDTH              (C_AXI_BUSER_WIDTH),
         .C_AXI_PROTOCOL                 (C_S_AXI_PROTOCOL),
         .C_RESP                         (P_SLVERR),
         .C_IGNORE_ID                    (C_IGNORE_ID)
        )
        decerr_slave_inst
          (
           .ACLK (aclk),
           .ARESETN (aresetn),
           .S_AXI_AWID (e_awid),
           .S_AXI_AWVALID (e_awvalid),
           .S_AXI_AWREADY (),
           .S_AXI_WLAST (s_axi_wlast),
           .S_AXI_WVALID (e_wvalid),
           .S_AXI_WREADY (e_wready),
           .S_AXI_BID (e_bid),
           .S_AXI_BRESP (),
           .S_AXI_BUSER (),
           .S_AXI_BVALID (e_bvalid),
           .S_AXI_BREADY (s_axi_bready),
           .S_AXI_ARID (e_arid),
           .S_AXI_ARLEN (e_arlen),
           .S_AXI_ARVALID (e_arvalid),
           .S_AXI_ARREADY (),
           .S_AXI_RID (e_rid),
           .S_AXI_RDATA (),
           .S_AXI_RRESP (),
           .S_AXI_RUSER (),
           .S_AXI_RLAST (e_rlast),
           .S_AXI_RVALID (e_rvalid),
           .S_AXI_RREADY (s_axi_rready)
         );
    end else begin : gen_no_err_detect
      assign s_awvalid_i = s_axi_awvalid;
      assign s_arvalid_i = s_axi_arvalid;
      assign s_wvalid_i = s_axi_wvalid;
      assign s_bready_i = s_axi_bready;
      assign s_rready_i = s_axi_rready;
      assign s_axi_awready = s_awready_i; 
      assign s_axi_wready = s_wready_i;
      assign s_axi_bvalid = s_bvalid_i;
      assign s_axi_bid = s_bid_i;
      assign s_axi_bresp = s_bresp_i;
      assign s_axi_buser = s_buser_i;
      assign s_axi_arready = s_arready_i; 
      assign s_axi_rvalid = s_rvalid_i;
      assign s_axi_rid = s_rid_i;
      assign s_axi_rresp = s_rresp_i;
      assign s_axi_ruser = s_ruser_i;
      assign s_axi_rdata = s_rdata_i;
      assign s_axi_rlast = s_rlast_i;
    end  
endgenerate
endmodule
`default_nettype wire
