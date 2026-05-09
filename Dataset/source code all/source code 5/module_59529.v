`timescale 1ns/1ps
`ifndef TCQ
 `define TCQ 1
`endif
`ifndef AS
`endif
`timescale 1ns/1ps
`ifndef TCQ
 `define TCQ 1
`endif
`ifndef AS
module tlm_rx_data_snk_bar #(
  parameter             DW = 32,        
  parameter             BARW = 7)       
 (
  input                 clk_i,
  input                 reset_i,
  output reg [63:0]     check_raddr_o,
  output reg            check_rmem32_o,
  output reg            check_rmem64_o,
  output reg            check_rio_o,
  output reg            check_rdev_id_o,
  output reg            check_rbus_id_o,
  output reg            check_rfun_id_o,
  input  [BARW-1:0]     check_rhit_bar_i,
  input                 check_rhit_i,
  output [BARW-1:0]     check_rhit_bar_o,
  output                check_rhit_o,
  output                check_rhit_src_rdy_o,
  output                check_rhit_ack_o,
  output                check_rhit_lock_o,
  input [31:0]          addr_lo_i,      
  input [31:0]          addr_hi_i,      
  input [8:0]           fulltype_oh_i,  
  input [2:0]           routing_i,      
  input                 mem64_i,        
  input [15:0]          req_id_i,       
  input [15:0]          req_id_cpl_i,   
  input                 eval_check_i,   
  input                 rhit_lat3_i,    
  input                 legacy_mode_i
  );
  localparam            CHECK_IO_BAR_HIT_EN = 1'b1;
  localparam    MEM_BIT   = 8;
  localparam    ADR_BIT   = 7;
  localparam    MRD_BIT   = 6;
  localparam    MWR_BIT   = 5;
  localparam    MLK_BIT   = 4;
  localparam    IO_BIT    = 3;
  localparam    CFG_BIT   = 2;
  localparam    MSG_BIT   = 1;
  localparam    CPL_BIT   = 0;
  localparam    ROUTE_BY_ID = 3'b010;
  wire [63:0]   addr_64b = {addr_hi_i, addr_lo_i};
  reg [63:0]    check_raddr_d;
  reg           check_rmem32_d;
  reg           check_rmem64_d;
  reg           check_rmemlock_d;
  reg           check_rmemlock_d1a;
  reg           check_rio_d;
  reg           check_rdev_id_d;
  reg           check_rbus_id_d;
  reg           check_rfun_id_d;
  reg           eval_check_q1, eval_check_q2, eval_check_q3, eval_check_q4;
  reg                          sent_check_q2, sent_check_q3, sent_check_q4;
  reg           lock_check_q2, lock_check_q3, lock_check_q4;
  always @* begin
    check_raddr_d   = (fulltype_oh_i[MSG_BIT] ? {req_id_i,48'h0}     : 0) |
                      (fulltype_oh_i[CPL_BIT] ? {req_id_cpl_i,48'h0} : 0) |
                      (fulltype_oh_i[ADR_BIT] ? addr_64b             : 0);
    check_rbus_id_d = (fulltype_oh_i[MSG_BIT] && (routing_i == ROUTE_BY_ID)) ||
                       fulltype_oh_i[CPL_BIT];
    check_rdev_id_d = (fulltype_oh_i[MSG_BIT] && (routing_i == ROUTE_BY_ID)) ||
                       fulltype_oh_i[CPL_BIT];
    check_rfun_id_d = (fulltype_oh_i[MSG_BIT] && (routing_i == ROUTE_BY_ID)) ||
                       fulltype_oh_i[CPL_BIT];
    check_rmem32_d  =  fulltype_oh_i[MEM_BIT] && !mem64_i;
    check_rmem64_d  =  fulltype_oh_i[MEM_BIT] &&  mem64_i;
    check_rmemlock_d=  fulltype_oh_i[MLK_BIT];
    check_rio_d     =  fulltype_oh_i[IO_BIT] && CHECK_IO_BAR_HIT_EN;
  end
  always @(posedge clk_i) begin
    if (eval_check_i) begin
      check_raddr_o     <= #`TCQ check_raddr_d;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      check_rmem32_o    <= #`TCQ 0;
      check_rmem64_o    <= #`TCQ 0;
      check_rmemlock_d1a <= #`TCQ 0;
      check_rio_o       <= #`TCQ 0;
      check_rbus_id_o   <= #`TCQ 0;
      check_rdev_id_o   <= #`TCQ 0;
      check_rfun_id_o   <= #`TCQ 0;
    end else if (eval_check_i) begin
      check_rmem32_o    <= #`TCQ check_rmem32_d;
      check_rmem64_o    <= #`TCQ check_rmem64_d;
      check_rmemlock_d1a <= #`TCQ check_rmemlock_d;
      check_rio_o       <= #`TCQ check_rio_d;
      check_rbus_id_o   <= #`TCQ check_rbus_id_d;
      check_rdev_id_o   <= #`TCQ check_rdev_id_d;
      check_rfun_id_o   <= #`TCQ check_rfun_id_d;
    end else begin
      check_rmem32_o    <= #`TCQ 0;
      check_rmem64_o    <= #`TCQ 0;
      check_rmemlock_d1a <= #`TCQ 0;
      check_rio_o       <= #`TCQ 0;
      check_rbus_id_o   <= #`TCQ 0;
      check_rdev_id_o   <= #`TCQ 0;
      check_rfun_id_o   <= #`TCQ 0;
    end
  end
  always @(posedge clk_i) begin
    eval_check_q1       <= #`TCQ eval_check_i;
    eval_check_q2       <= #`TCQ eval_check_q1;
    eval_check_q3       <= #`TCQ eval_check_q2;
    eval_check_q4       <= #`TCQ eval_check_q3;
    sent_check_q2       <= #`TCQ eval_check_q1 &&
                           (check_rmem32_o  ||
                            check_rmem64_o  ||
                            check_rio_o     ||
                            check_rbus_id_o ||
                            check_rdev_id_o ||
                            check_rfun_id_o);
    sent_check_q3       <= #`TCQ sent_check_q2;
    sent_check_q4       <= #`TCQ sent_check_q3;
    lock_check_q2       <= #`TCQ check_rmemlock_d1a;
    lock_check_q3       <= #`TCQ lock_check_q2;
    lock_check_q4       <= #`TCQ lock_check_q3;
  end
  assign check_rhit_bar_o     = check_rhit_bar_i;
  assign check_rhit_o         = check_rhit_i;
  assign check_rhit_src_rdy_o = rhit_lat3_i ? eval_check_q4 : eval_check_q3;
  assign check_rhit_ack_o     = rhit_lat3_i ? sent_check_q4 : sent_check_q3;
  assign check_rhit_lock_o    = rhit_lat3_i ? lock_check_q4 : lock_check_q3;
endmodule
`endif
