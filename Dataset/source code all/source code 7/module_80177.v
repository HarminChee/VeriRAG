`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_dwidth_converter_v2_1_w_downsizer #
  (
   parameter         C_FAMILY                         = "none", 
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
   input  wire                              cmd_mirror,
   input  wire                              cmd_fix,
   input  wire [C_S_AXI_BYTES_LOG-1:0]      cmd_first_word, 
   input  wire [C_S_AXI_BYTES_LOG-1:0]      cmd_offset,
   input  wire [C_S_AXI_BYTES_LOG-1:0]      cmd_mask,
   input  wire [C_M_AXI_BYTES_LOG:0]        cmd_step,
   input  wire [3-1:0]                      cmd_size,
   input  wire [8-1:0]                      cmd_length,
   output wire                              cmd_ready,
   input  wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
   input  wire [C_S_AXI_DATA_WIDTH/8-1:0]   S_AXI_WSTRB,
   input  wire                                                    S_AXI_WLAST,
   input  wire                                                    S_AXI_WVALID,
   output wire                                                    S_AXI_WREADY,
   output wire [C_M_AXI_DATA_WIDTH-1:0]    M_AXI_WDATA,
   output wire [C_M_AXI_DATA_WIDTH/8-1:0]  M_AXI_WSTRB,
   output wire                                                   M_AXI_WLAST,
   output wire                                                   M_AXI_WVALID,
   input  wire                                                   M_AXI_WREADY
   );
  localparam [24-1:0] C_DOUBLE_LEN       = 24'b0000_0000_0000_0000_1111_1111;
  reg                             first_word;
  reg  [C_S_AXI_BYTES_LOG-1:0]    current_word_1;
  reg  [C_S_AXI_BYTES_LOG-1:0]    current_word;
  wire [C_S_AXI_BYTES_LOG-1:0]    current_word_adjusted;
  wire [C_RATIO_LOG-1:0]          current_index;
  wire                            last_beat;
  wire                            last_word;
  reg  [C_S_AXI_BYTES_LOG-1:0]    size_mask;
  wire [C_S_AXI_BYTES_LOG-1:0]    next_word;
  reg                             first_mi_word;
  reg  [8-1:0]                    length_counter_1;
  reg  [8-1:0]                    length_counter;
  wire [8-1:0]                    next_length_counter;
  wire                            word_completed;
  wire                            cmd_ready_i;
  wire                            pop_mi_data;
  wire                            mi_stalling;
  wire                            S_AXI_WREADY_I;
  wire [C_M_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA_I;
  wire [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB_I;
  wire                            M_AXI_WLAST_I;
  wire                            M_AXI_WVALID_I;
  wire                            M_AXI_WREADY_I;
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
  assign S_AXI_WREADY_I = cmd_valid & word_completed & M_AXI_WREADY_I;
  assign S_AXI_WREADY   = S_AXI_WREADY_I;
  assign M_AXI_WVALID_I = S_AXI_WVALID & cmd_valid;
  assign pop_mi_data    = M_AXI_WVALID_I & M_AXI_WREADY_I;
  assign cmd_ready_i    = cmd_valid & pop_mi_data & last_word;
  assign cmd_ready      = cmd_ready_i;
  assign mi_stalling    = M_AXI_WVALID_I & ~M_AXI_WREADY_I;
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
        if ( M_AXI_WLAST_I ) begin
          first_word      <=  1'b1;
        end else begin
          first_word      <=  1'b0;
        end
        current_word_1  <= next_word;
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
        if ( M_AXI_WLAST_I ) begin
          first_mi_word    <= 1'b1;
        end else begin
          first_mi_word    <= 1'b0;
        end
        length_counter_1 <= next_length_counter;
      end
    end
  end
  assign last_beat = ( length_counter == 8'b0 );
  assign last_word = ( last_beat );
  assign M_AXI_WDATA_I  = S_AXI_WDATA[current_index * C_M_AXI_DATA_WIDTH   +: C_M_AXI_DATA_WIDTH];
  assign M_AXI_WSTRB_I  = S_AXI_WSTRB[current_index * C_M_AXI_DATA_WIDTH/8 +: C_M_AXI_DATA_WIDTH/8];
  assign M_AXI_WLAST_I  = last_word;
  assign M_AXI_WDATA    = M_AXI_WDATA_I;
  assign M_AXI_WSTRB    = M_AXI_WSTRB_I;
  assign M_AXI_WLAST    = M_AXI_WLAST_I;
  assign M_AXI_WVALID   = M_AXI_WVALID_I;
  assign M_AXI_WREADY_I = M_AXI_WREADY;
endmodule
