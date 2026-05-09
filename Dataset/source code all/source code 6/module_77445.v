`timescale 1ps/1ps
`timescale 1ps/1ps
module processing_system7_v5_3_b_atc #
  (
   parameter         C_FAMILY                         = "rtl", 
   parameter integer C_AXI_ID_WIDTH                   = 4, 
   parameter integer C_AXI_BUSER_WIDTH                = 1,
   parameter integer C_FIFO_DEPTH_LOG                 = 4
   )
  (
   input  wire                                  ARESET,
   input  wire                                  ACLK,
   input  wire                                  cmd_b_push,
   input  wire                                  cmd_b_error,
   input  wire [C_AXI_ID_WIDTH-1:0]             cmd_b_id,
   output wire                                  cmd_b_ready,
   output wire [C_FIFO_DEPTH_LOG-1:0]           cmd_b_addr,
   output reg                                   cmd_b_full,
   output wire [C_AXI_ID_WIDTH-1:0]             S_AXI_BID,
   output reg  [2-1:0]                          S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0]          S_AXI_BUSER,
   output wire                                  S_AXI_BVALID,
   input  wire                                  S_AXI_BREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]             M_AXI_BID,
   input  wire [2-1:0]                          M_AXI_BRESP,
   input  wire [C_AXI_BUSER_WIDTH-1:0]          M_AXI_BUSER,
   input  wire                                  M_AXI_BVALID,
   output wire                                  M_AXI_BREADY,
   output reg                                   ERROR_TRIGGER,
   output reg  [C_AXI_ID_WIDTH-1:0]             ERROR_TRANSACTION_ID
   );
  localparam [2-1:0] C_RESP_OKAY         = 2'b00;
  localparam [2-1:0] C_RESP_EXOKAY       = 2'b01;
  localparam [2-1:0] C_RESP_SLVERROR     = 2'b10;
  localparam [2-1:0] C_RESP_DECERR       = 2'b11;
  localparam C_FIFO_WIDTH                = C_AXI_ID_WIDTH + 1;
  localparam C_FIFO_DEPTH                = 2 ** C_FIFO_DEPTH_LOG;
  integer index;
  reg  [C_FIFO_DEPTH_LOG-1:0]         addr_ptr;
  reg  [C_FIFO_WIDTH-1:0]             data_srl[C_FIFO_DEPTH-1:0];
  reg                                 cmd_b_valid;
  wire                                cmd_b_ready_i;
  wire                                inject_error;
  wire [C_AXI_ID_WIDTH-1:0]           current_id;
  wire                                found_match;
  wire                                use_match;
  wire                                matching_id;
  wire                                write_valid_cmd;
  reg  [C_FIFO_DEPTH-2:0]             valid_cmd;
  reg  [C_FIFO_DEPTH-2:0]             updated_valid_cmd;
  reg  [C_FIFO_DEPTH-2:0]             next_valid_cmd;
  reg  [C_FIFO_DEPTH_LOG-1:0]         search_addr_ptr;
  reg  [C_FIFO_DEPTH_LOG-1:0]         collapsed_addr_ptr;
  reg  [C_AXI_ID_WIDTH-1:0]           M_AXI_BID_I;
  reg  [2-1:0]                        M_AXI_BRESP_I;
  reg  [C_AXI_BUSER_WIDTH-1:0]        M_AXI_BUSER_I;
  reg                                 M_AXI_BVALID_I;
  wire                                M_AXI_BREADY_I;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      addr_ptr <= {C_FIFO_DEPTH_LOG{1'b1}};
    end else begin
      if ( cmd_b_push & ~cmd_b_ready_i ) begin
        addr_ptr <= addr_ptr + 1;
      end else if ( cmd_b_ready_i ) begin
        addr_ptr <= collapsed_addr_ptr;
      end
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      cmd_b_full  <= 1'b0;
      cmd_b_valid <= 1'b0;
    end else begin
      if ( cmd_b_push & ~cmd_b_ready_i ) begin
        cmd_b_full  <= ( addr_ptr == C_FIFO_DEPTH-3 );
        cmd_b_valid <= 1'b1;
      end else if ( ~cmd_b_push & cmd_b_ready_i ) begin
        cmd_b_full  <= 1'b0;
        cmd_b_valid <= ( collapsed_addr_ptr != C_FIFO_DEPTH-1 );
      end
    end
  end
  always @ (posedge ACLK) begin
    if ( cmd_b_push ) begin
      for (index = 0; index < C_FIFO_DEPTH-1 ; index = index + 1) begin
        data_srl[index+1] <= data_srl[index];
      end
      data_srl[0]   <= {cmd_b_error, cmd_b_id};
    end
  end
  assign {inject_error, current_id} = data_srl[search_addr_ptr];
  assign cmd_b_addr = collapsed_addr_ptr;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      search_addr_ptr <= {C_FIFO_DEPTH_LOG{1'b1}};
    end else begin
      if ( cmd_b_ready_i ) begin
        search_addr_ptr <= collapsed_addr_ptr;
      end else if ( M_AXI_BVALID_I & cmd_b_valid & ~found_match & ~cmd_b_push ) begin
        search_addr_ptr <= search_addr_ptr - 1;
      end else if ( cmd_b_push ) begin
        search_addr_ptr <= search_addr_ptr + 1;
      end
    end
  end
  assign matching_id  = ( M_AXI_BID_I == current_id );
  assign found_match  = valid_cmd[search_addr_ptr] & matching_id & M_AXI_BVALID_I;
  assign use_match    = found_match & S_AXI_BREADY;
  assign write_valid_cmd  = cmd_b_push | cmd_b_ready_i;
  always @ *
  begin
    updated_valid_cmd                   = valid_cmd;
    updated_valid_cmd[search_addr_ptr]  = ~use_match;
  end
  always @ *
  begin
    if ( cmd_b_push ) begin
      next_valid_cmd = {updated_valid_cmd[C_FIFO_DEPTH-3:0], 1'b1};
    end else begin
      next_valid_cmd = updated_valid_cmd;
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      valid_cmd <= {C_FIFO_WIDTH{1'b0}};
    end else if ( write_valid_cmd ) begin
      valid_cmd <= next_valid_cmd;
    end
  end
  always @ *
  begin
    collapsed_addr_ptr = {C_FIFO_DEPTH_LOG{1'b1}};
    for (index = 0; index < C_FIFO_DEPTH-2 ; index = index + 1) begin
      if ( next_valid_cmd[index] ) begin
        collapsed_addr_ptr = index;
      end
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      M_AXI_BID_I     <= {C_AXI_ID_WIDTH{1'b0}};
      M_AXI_BRESP_I   <= 2'b00;
      M_AXI_BUSER_I   <= {C_AXI_BUSER_WIDTH{1'b0}};
      M_AXI_BVALID_I  <= 1'b0;
    end else begin
      if ( M_AXI_BREADY_I | ~M_AXI_BVALID_I ) begin
        M_AXI_BVALID_I  <= 1'b0;
      end
      if (M_AXI_BVALID & ( M_AXI_BREADY_I | ~M_AXI_BVALID_I) ) begin
        M_AXI_BID_I     <= M_AXI_BID;
        M_AXI_BRESP_I   <= M_AXI_BRESP;
        M_AXI_BUSER_I   <= M_AXI_BUSER;
        M_AXI_BVALID_I  <= 1'b1;
      end
    end
  end
  assign M_AXI_BREADY = M_AXI_BREADY_I | ~M_AXI_BVALID_I;
  always @ *
  begin
    if ( inject_error ) begin
      S_AXI_BRESP = C_RESP_SLVERROR;
    end else begin
      S_AXI_BRESP = M_AXI_BRESP_I;
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      ERROR_TRIGGER        <= 1'b0;
      ERROR_TRANSACTION_ID <= {C_AXI_ID_WIDTH{1'b0}};
    end else begin
      if ( inject_error & cmd_b_ready_i ) begin
        ERROR_TRIGGER        <= 1'b1;
        ERROR_TRANSACTION_ID <= M_AXI_BID_I;
      end else begin
        ERROR_TRIGGER        <= 1'b0;
      end
    end
  end
  assign S_AXI_BVALID   = M_AXI_BVALID_I & cmd_b_valid & found_match;
  assign M_AXI_BREADY_I = cmd_b_valid & use_match;
  assign cmd_b_ready_i  = M_AXI_BVALID_I & cmd_b_valid & use_match;
  assign cmd_b_ready    = cmd_b_ready_i;
  assign S_AXI_BID    = M_AXI_BID_I;
  assign S_AXI_BUSER  = M_AXI_BUSER_I;
endmodule
