`timescale 1ps/1ps
`timescale 1ps/1ps
module processing_system7_v5_3_w_atc #
  (
   parameter         C_FAMILY                         = "rtl",
   parameter integer C_AXI_ID_WIDTH                   = 4,
   parameter integer C_AXI_DATA_WIDTH                 = 64,
   parameter integer C_AXI_WUSER_WIDTH                = 1
   )
  (
   input  wire                                  ARESET,
   input  wire                                  ACLK,
   input  wire                                  cmd_w_valid,
   input  wire                                  cmd_w_check,
   input  wire [C_AXI_ID_WIDTH-1:0]             cmd_w_id,
   output wire                                  cmd_w_ready,
   output wire                                  cmd_b_push,
   output wire                                  cmd_b_error,
   output reg  [C_AXI_ID_WIDTH-1:0]             cmd_b_id,
   input  wire                                  cmd_b_full,
   input  wire [C_AXI_ID_WIDTH-1:0]             S_AXI_WID,
   input  wire [C_AXI_DATA_WIDTH-1:0]           S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0]         S_AXI_WSTRB,
   input  wire                                  S_AXI_WLAST,
   input  wire [C_AXI_WUSER_WIDTH-1:0]          S_AXI_WUSER,
   input  wire                                  S_AXI_WVALID,
   output wire                                  S_AXI_WREADY,
   output wire [C_AXI_ID_WIDTH-1:0]             M_AXI_WID,
   output wire [C_AXI_DATA_WIDTH-1:0]           M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0]         M_AXI_WSTRB,
   output wire                                  M_AXI_WLAST,
   output wire [C_AXI_WUSER_WIDTH-1:0]          M_AXI_WUSER,
   output wire                                  M_AXI_WVALID,
   input  wire                                  M_AXI_WREADY
   );
  wire                                any_strb_deasserted;
  wire                                incoming_strb_issue;
  reg                                 first_word;
  reg                                 strb_issue;
  wire                                data_pop;
  wire                                cmd_b_push_blocked;
  reg                                 cmd_b_push_i;
  assign any_strb_deasserted  = ( S_AXI_WSTRB != {C_AXI_DATA_WIDTH/8{1'b1}} );
  assign incoming_strb_issue  = cmd_w_valid & S_AXI_WVALID & cmd_w_check & any_strb_deasserted;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      first_word  <= 1'b1;
    end else if ( data_pop ) begin
      first_word  <= S_AXI_WLAST;
    end
  end
  always @ (posedge ACLK) begin
    if (ARESET) begin
      strb_issue  <= 1'b0;
      cmd_b_id    <= {C_AXI_ID_WIDTH{1'b0}};
    end else if ( data_pop ) begin
      if ( first_word ) begin
        strb_issue  <= incoming_strb_issue;
      end else begin
        strb_issue  <= incoming_strb_issue | strb_issue;
      end
      cmd_b_id    <= cmd_w_id;
    end
  end
  assign cmd_b_error  = strb_issue;
  assign data_pop   = S_AXI_WVALID & M_AXI_WREADY & cmd_w_valid & ~cmd_b_full & ~cmd_b_push_blocked; 
  always @ (posedge ACLK) begin
    if (ARESET) begin
      cmd_b_push_i  <= 1'b0;
    end else begin
      cmd_b_push_i  <= ( S_AXI_WLAST & data_pop ) | cmd_b_push_blocked;
    end
  end
  assign cmd_b_push_blocked = cmd_b_push_i & cmd_b_full;
  assign cmd_b_push = cmd_b_push_i & ~cmd_b_full;
  assign M_AXI_WVALID   = S_AXI_WVALID & cmd_w_valid & ~cmd_b_full & ~cmd_b_push_blocked;
  assign S_AXI_WREADY   = M_AXI_WREADY & cmd_w_valid & ~cmd_b_full & ~cmd_b_push_blocked;
  assign cmd_w_ready    = S_AXI_WVALID & M_AXI_WREADY & cmd_w_valid & ~cmd_b_full & ~cmd_b_push_blocked & S_AXI_WLAST;
  assign M_AXI_WID      = S_AXI_WID;
  assign M_AXI_WDATA    = S_AXI_WDATA;
  assign M_AXI_WSTRB    = S_AXI_WSTRB;
  assign M_AXI_WLAST    = S_AXI_WLAST;
  assign M_AXI_WUSER    = S_AXI_WUSER;
endmodule
