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
module tlm_rx_data_snk_pwr_mgmt
  (
   input                 clk_i,
   input                 reset_i,
   output reg            pm_as_nak_l1_o,    
   output reg            pm_turn_off_o,     
   output reg            pm_set_slot_pwr_o, 
   output reg [9:0]      pm_set_slot_pwr_data_o, 
   output reg            pm_msg_detect_o,   
   input                 ismsg_i,           
   input [7:0]           msgcode_i,         
   input [9:0]           pwr_data_i,        
   input                 eval_pwr_mgmt_i,   
   input                 eval_pwr_mgmt_data_i, 
   input                 act_pwr_mgmt_i     
   );
  localparam             PM_ACTIVE_STATE_NAK       = 8'b0001_0100;
  localparam             PME_TURN_OFF              = 8'b0001_1001;
  localparam             SET_SLOT_POWER_LIMIT      = 8'b0101_0000;
  reg                    cur_pm_as_nak_l1;
  reg                    cur_pm_turn_off;
  reg                    cur_pm_set_slot_pwr;
  reg                    eval_pwr_mgmt_q1;
  reg                    eval_pwr_mgmt_data_q1;
  reg                    act_pwr_mgmt_q1;
  reg [9:0]              pm_set_slot_pwr_data_d1;
  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_pm_as_nak_l1           <= #`TCQ 0;
      cur_pm_turn_off            <= #`TCQ 0;
      cur_pm_set_slot_pwr        <= #`TCQ 0;
    end else if (eval_pwr_mgmt_i) begin
      if (ismsg_i) begin
        cur_pm_as_nak_l1         <= #`TCQ (msgcode_i == PM_ACTIVE_STATE_NAK);
        cur_pm_turn_off          <= #`TCQ (msgcode_i == PME_TURN_OFF);
        cur_pm_set_slot_pwr      <= #`TCQ (msgcode_i == SET_SLOT_POWER_LIMIT);
      end else begin
        cur_pm_as_nak_l1         <= #`TCQ 0;
        cur_pm_turn_off          <= #`TCQ 0;
        cur_pm_set_slot_pwr      <= #`TCQ 0;
      end
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      pm_msg_detect_o            <= #`TCQ 0;
    end else if (eval_pwr_mgmt_q1) begin
      pm_msg_detect_o            <= #`TCQ cur_pm_as_nak_l1 ||
                                          cur_pm_turn_off  ||
                                          cur_pm_set_slot_pwr;
    end
  end
  always @(posedge clk_i) begin
    if (eval_pwr_mgmt_data_i) begin
      pm_set_slot_pwr_data_d1 <= #`TCQ pwr_data_i;
    end
    if (eval_pwr_mgmt_data_q1) begin
      pm_set_slot_pwr_data_o  <= #`TCQ pm_set_slot_pwr_data_d1;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      pm_as_nak_l1_o         <= #`TCQ 0;
      pm_turn_off_o          <= #`TCQ 0;
      pm_set_slot_pwr_o      <= #`TCQ 0;
    end else if (act_pwr_mgmt_i) begin
      pm_as_nak_l1_o         <= #`TCQ cur_pm_as_nak_l1;
      pm_turn_off_o          <= #`TCQ cur_pm_turn_off;
      pm_set_slot_pwr_o      <= #`TCQ cur_pm_set_slot_pwr;
    end else if (act_pwr_mgmt_q1) begin
      pm_as_nak_l1_o         <= #`TCQ 0;
      pm_turn_off_o          <= #`TCQ 0;
      pm_set_slot_pwr_o      <= #`TCQ 0;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      eval_pwr_mgmt_q1           <= #`TCQ 0;
      eval_pwr_mgmt_data_q1      <= #`TCQ 0;
      act_pwr_mgmt_q1            <= #`TCQ 0;
    end else begin
      eval_pwr_mgmt_q1           <= #`TCQ eval_pwr_mgmt_i;
      eval_pwr_mgmt_data_q1      <= #`TCQ eval_pwr_mgmt_data_i;
      act_pwr_mgmt_q1            <= #`TCQ act_pwr_mgmt_i;
    end
  end
endmodule
`endif
