`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_9_w_axi3_conv #
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
  reg                             first_mi_word;
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
