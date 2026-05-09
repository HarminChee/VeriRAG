`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_9_a_axi3_conv #
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
  reg  [C_AXI_ADDR_WIDTH-1:0]         next_mi_addr;
  reg                                 split_ongoing;
  reg  [4-1:0]                        pushed_commands;
  reg  [16-1:0]                       addr_step;
  reg  [16-1:0]                       first_step;
  wire [8-1:0]                        first_beats;
  reg  [C_AXI_ADDR_WIDTH-1:0]         size_mask;
  reg                                 access_is_incr_q;
  reg                                 incr_need_to_split_q;
  wire                                need_to_split_q;
  reg  [4-1:0]                        num_transactions_q;
  reg  [16-1:0]                       addr_step_q;
  reg  [16-1:0]                       first_step_q;
  reg  [C_AXI_ADDR_WIDTH-1:0]         size_mask_q;
  reg  [C_FIFO_DEPTH_LOG:0]           cmd_depth;
  reg                                 cmd_empty;
  reg  [C_AXI_ID_WIDTH-1:0]           queue_id;
  wire                                id_match;
  wire                                cmd_id_check;
  wire                                s_ready;
  wire                                cmd_full;
  wire                                allow_this_cmd;
  wire                                allow_new_cmd;
  wire                                cmd_push;
  reg                                 cmd_push_block;
  reg  [C_FIFO_DEPTH_LOG:0]           cmd_b_depth;
  reg                                 cmd_b_empty;
  wire                                cmd_b_full;
  wire                                cmd_b_push;
  reg                                 cmd_b_push_block;
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
  reg                                 multiple_id_non_split;
  reg                                 split_in_progress;
  wire                                cmd_split_i;
  wire [C_AXI_ID_WIDTH-1:0]           cmd_id_i;
  reg  [4-1:0]                        cmd_length_i;
  wire                                cmd_b_split_i;
  wire [4-1:0]                        cmd_b_repeat_i;
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
  reg  [4-1:0]                        S_AXI_AQOS_Q;
  reg  [C_AXI_AUSER_WIDTH-1:0]        S_AXI_AUSER_Q;
  reg                                 S_AXI_AREADY_I;
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
  reg [1:0] areset_d; 
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
      axi_data_fifo_v2_1_8_axic_fifo #
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
      axi_data_fifo_v2_1_8_axic_fifo #
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
      axi_data_fifo_v2_1_8_axic_fifo #
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
      axi_data_fifo_v2_1_8_axic_fifo #
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
