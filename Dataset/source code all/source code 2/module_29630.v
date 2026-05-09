`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_dwidth_converter_v2_1_9_r_downsizer #
  (
   parameter         C_FAMILY                         = "none", 
   parameter integer C_AXI_ID_WIDTH                   = 1, 
   parameter integer C_S_AXI_DATA_WIDTH               = 64,
   parameter integer C_M_AXI_DATA_WIDTH               = 32,
   parameter integer C_S_AXI_BYTES_LOG                = 3,
   parameter integer C_M_AXI_BYTES_LOG                = 2,
   parameter integer C_RATIO_LOG                      = 1
   )
  (
   input  wire                                                    ARESET,
   input  wire                                                    ACLK,
   input  wire                              cmd_valid,
   input  wire                              cmd_split,
   input  wire                              cmd_mirror,
   input  wire                              cmd_fix,
   input  wire [C_S_AXI_BYTES_LOG-1:0]      cmd_first_word, 
   input  wire [C_S_AXI_BYTES_LOG-1:0]      cmd_offset,
   input  wire [C_S_AXI_BYTES_LOG-1:0]      cmd_mask,
   input  wire [C_M_AXI_BYTES_LOG:0]        cmd_step,
   input  wire [3-1:0]                      cmd_size,
   input  wire [8-1:0]                      cmd_length,
   output wire                              cmd_ready,
   input  wire [C_AXI_ID_WIDTH-1:0]         cmd_id,
   output wire [C_AXI_ID_WIDTH-1:0]           S_AXI_RID,
   output wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA,
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
  genvar word_cnt;
  localparam [2-1:0] C_RESP_OKAY        = 2'b00;
  localparam [2-1:0] C_RESP_EXOKAY      = 2'b01;
  localparam [2-1:0] C_RESP_SLVERROR    = 2'b10;
  localparam [2-1:0] C_RESP_DECERR      = 2'b11;
  localparam [24-1:0] C_DOUBLE_LEN       = 24'b0000_0000_0000_0000_1111_1111;
  reg                             first_word;
  reg  [C_S_AXI_BYTES_LOG-1:0]    current_word_1;
  reg  [C_S_AXI_BYTES_LOG-1:0]    current_word;
  wire [C_S_AXI_BYTES_LOG-1:0]    current_word_adjusted;
  wire [C_RATIO_LOG-1:0]          current_index;
  wire                            last_beat;
  wire                            last_word;
  wire                            new_si_word;
  reg  [C_S_AXI_BYTES_LOG-1:0]    size_mask;
  wire [C_S_AXI_BYTES_LOG-1:0]    next_word;
  reg                             first_mi_word;
  reg  [8-1:0]                    length_counter_1;
  reg  [8-1:0]                    length_counter;
  wire [8-1:0]                    next_length_counter;
  wire                            load_rresp;
  reg                             need_to_update_rresp;
  reg  [2-1:0]                    S_AXI_RRESP_ACC;
  wire                            first_si_in_mi;
  wire                            first_mi_in_si;
  wire                            word_completed;
  wire                            cmd_ready_i;
  wire                            pop_si_data;
  wire                            pop_mi_data;
  wire                            si_stalling;
  wire                            M_AXI_RREADY_I;
  reg  [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA_II;
  wire [C_AXI_ID_WIDTH-1:0]       S_AXI_RID_I;
  reg  [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA_I;
  reg  [2-1:0]                    S_AXI_RRESP_I;
  wire                            S_AXI_RLAST_I;
  wire                            S_AXI_RVALID_I;
  wire                            S_AXI_RREADY_I;
  always @ *
  begin
    case (cmd_size)
      3'b000: size_mask = C_DOUBLE_LEN[8 +: C_S_AXI_BYTES_LOG];
      3'b001: size_mask = C_DOUBLE_LEN[7 +: C_S_AXI_BYTES_LOG];
      3'b010: size_mask = C_DOUBLE_LEN[6 +: C_S_AXI_BYTES_LOG];
      3'b011: size_mask = C_DOUBLE_LEN[5 +: C_S_AXI_BYTES_LOG];
      3'b100: size_mask = C_DOUBLE_LEN[4 +: C_S_AXI_BYTES_LOG];
      3'b101: size_mask = C_DOUBLE_LEN[3 +: C_S_AXI_BYTES_LOG];
      3'b110: size_mask = C_DOUBLE_LEN[2 +: C_S_AXI_BYTES_LOG];
      3'b111: size_mask = C_DOUBLE_LEN[1 +: C_S_AXI_BYTES_LOG];  
    endcase
  end
  assign word_completed = ( cmd_fix ) |
                          ( cmd_mirror ) |
                          ( ~cmd_fix & ( ( next_word & size_mask ) == {C_S_AXI_BYTES_LOG{1'b0}} ) ) | 
                          ( ~cmd_fix & last_word );
  assign M_AXI_RREADY_I =  cmd_valid & (S_AXI_RREADY_I | ~word_completed);
  assign M_AXI_RREADY   = M_AXI_RREADY_I;
  assign S_AXI_RVALID_I = M_AXI_RVALID & word_completed & cmd_valid;
  assign pop_mi_data    = M_AXI_RVALID & M_AXI_RREADY_I;
  assign pop_si_data    = S_AXI_RVALID_I & S_AXI_RREADY_I;
  assign cmd_ready_i    = cmd_valid & pop_si_data & last_word;
  assign cmd_ready      = cmd_ready_i;
  assign si_stalling    = S_AXI_RVALID_I & ~S_AXI_RREADY_I;
  always @ *
  begin
    if ( first_word | cmd_fix )
      current_word = cmd_first_word;
    else
      current_word = current_word_1;
  end
  assign next_word              = ( current_word + cmd_step ) & cmd_mask;
  assign current_word_adjusted  = current_word + cmd_offset;
  assign current_index          = current_word_adjusted[C_S_AXI_BYTES_LOG-C_RATIO_LOG +: C_RATIO_LOG];
  always @ (posedge ACLK) begin
    if (ARESET) begin
      first_word      <= 1'b1;
      current_word_1  <= 'b0;
    end else begin
      if ( pop_mi_data ) begin
        if ( M_AXI_RLAST ) begin
          first_word <=  1'b1;
        end else begin
          first_word <=  1'b0;
        end
        current_word_1 <= next_word;
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
  always @ (posedge ACLK) begin
    if (ARESET) begin
      first_mi_word    <= 1'b1;
      length_counter_1 <= 8'b0;
    end else begin
      if ( pop_mi_data ) begin
        if ( M_AXI_RLAST ) begin
          first_mi_word    <= 1'b1;
        end else begin
          first_mi_word    <= 1'b0;
        end
        length_counter_1 <= next_length_counter;
      end
    end
  end
  assign last_beat    = ( length_counter == 8'b0 );
  assign last_word    = ( last_beat );
  assign new_si_word  = ( current_word == {C_S_AXI_BYTES_LOG{1'b0}} );
  assign S_AXI_RID_I    = cmd_id;
  assign S_AXI_RLAST_I  = M_AXI_RLAST & ~cmd_split;
  assign first_si_in_mi = cmd_mirror | 
                          first_mi_word |
                          ( ~cmd_mirror & ( ( current_word & size_mask ) == {C_S_AXI_BYTES_LOG{1'b0}} ) );
  assign load_rresp     = first_si_in_mi;
  always @ *
  begin
    case (S_AXI_RRESP_ACC)
      C_RESP_EXOKAY:    need_to_update_rresp = ( M_AXI_RRESP == C_RESP_OKAY     |
                                                 M_AXI_RRESP == C_RESP_SLVERROR |
                                                 M_AXI_RRESP == C_RESP_DECERR );
      C_RESP_OKAY:      need_to_update_rresp = ( M_AXI_RRESP == C_RESP_SLVERROR |
                                                 M_AXI_RRESP == C_RESP_DECERR );
      C_RESP_SLVERROR:  need_to_update_rresp = ( M_AXI_RRESP == C_RESP_DECERR );
      C_RESP_DECERR:    need_to_update_rresp = 1'b0;
    endcase
  end
  always @ *
  begin
    if ( load_rresp || need_to_update_rresp ) begin
      S_AXI_RRESP_I = M_AXI_RRESP;
    end else begin
      S_AXI_RRESP_I = S_AXI_RRESP_ACC;
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      S_AXI_RRESP_ACC <= C_RESP_OKAY;
    end else begin
      if ( pop_mi_data ) begin
        S_AXI_RRESP_ACC <= S_AXI_RRESP_I;
      end
    end
  end
  generate
    for (word_cnt = 0; word_cnt < (2 ** C_RATIO_LOG) ; word_cnt = word_cnt + 1) begin : WORD_LANE
      always @ (posedge ACLK) begin
        if (ARESET) begin
          S_AXI_RDATA_II[word_cnt*C_M_AXI_DATA_WIDTH   +: C_M_AXI_DATA_WIDTH]   <= {C_M_AXI_DATA_WIDTH{1'b0}};
        end else begin
          if ( pop_si_data ) begin
            S_AXI_RDATA_II[word_cnt*C_M_AXI_DATA_WIDTH   +: C_M_AXI_DATA_WIDTH]   <= {C_M_AXI_DATA_WIDTH{1'b0}};
          end else if ( current_index == word_cnt & pop_mi_data ) begin
            S_AXI_RDATA_II[word_cnt*C_M_AXI_DATA_WIDTH   +: C_M_AXI_DATA_WIDTH]   <= M_AXI_RDATA;
          end
        end
      end
      always @ *
      begin
        if ( ( current_index == word_cnt ) | cmd_mirror ) begin
          S_AXI_RDATA_I[word_cnt*C_M_AXI_DATA_WIDTH +: C_M_AXI_DATA_WIDTH] = M_AXI_RDATA;
        end else begin
          S_AXI_RDATA_I[word_cnt*C_M_AXI_DATA_WIDTH +: C_M_AXI_DATA_WIDTH] = 
                        S_AXI_RDATA_II[word_cnt*C_M_AXI_DATA_WIDTH +: C_M_AXI_DATA_WIDTH];
        end
      end
    end 
  endgenerate
  assign S_AXI_RREADY_I = S_AXI_RREADY;
  assign S_AXI_RVALID   = S_AXI_RVALID_I;
  assign S_AXI_RID      = S_AXI_RID_I;
  assign S_AXI_RDATA    = S_AXI_RDATA_I;
  assign S_AXI_RRESP    = S_AXI_RRESP_I;
  assign S_AXI_RLAST    = S_AXI_RLAST_I;
endmodule
