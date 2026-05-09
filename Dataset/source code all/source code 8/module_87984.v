`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_9_b_downsizer #
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
  reg                             first_mi_word;
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
