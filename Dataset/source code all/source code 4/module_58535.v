`timescale 1ns/1ps
`ifndef TCQ
 `define TCQ 1
`endif
`ifndef PCIE
 `ifndef AS
  `define PCIE
 `endif
`endif
`timescale 1ns/1ps
`ifndef TCQ
 `define TCQ 1
`endif
`ifndef PCIE
 `ifndef AS
  `define PCIE
 `endif
`endif
module tlm_rx_data_snk #(parameter DW              = 32,
                         parameter FCW             = 6, 
                         `ifdef PCIE
                         parameter BARW            = 7, 
                         parameter DOWNSTREAM_PORT = 0, 
                         `else 
                         parameter OVC             = 0, 
                         parameter MVC             = 0, 
                         `endif
                         parameter MPS             = 512,
                         parameter TYPE1_UR        = 0) 
  (
   input                 clk_i,
   input                 reset_i,
   output reg [DW-1:0]   d_o,               
   output reg            sof_o,             
   output reg            eof_o,             
   output reg            preeof_o,          
   output reg            src_rdy_o,         
   output reg            rem_o,             
   output reg            dsc_o,             
   output reg            cfg_o,             
   `ifdef PCIE
   output reg            np_o,              
   output reg            cpl_o,             
   output reg            locked_o,          
   output reg [BARW-1:0] bar_o,             
   output reg            rid_o,             
   output reg            vend_msg_o,        
   output reg            bar_src_rdy_o,     
   `endif
   output reg            fc_use_p_o,        
   output reg            fc_use_np_o,       
   `ifdef PCIE
   output reg            fc_use_cpl_o,      
   `endif
   output reg [FCW-1:0]  fc_use_data_o,     
   output reg            fc_unuse_o,        
   input [DW-1:0]        d_i,               
   input                 sof_i,             
   input                 eof_i,             
   input                 rem_i,             
   input                 src_rdy_i,         
   input                 src_dsc_i,         
   output reg            vc_hit_o,          
   `ifdef PCIE
   output                pm_as_nak_l1_o,    
   output                pm_turn_off_o,     
   output                pm_set_slot_pwr_o, 
   output [9:0]          pm_set_slot_pwr_data_o, 
   input                 pm_suspend_req_i,  
   `else 
   input [1:0]           lnk_state_i,       
   input                 lnk_state_src_rdy_i,   
   `endif
   `ifdef PCIE
   output reg [47:0]     err_tlp_cpl_header_o, 
   output reg            err_tlp_p_o,       
   output reg            err_tlp_ur_o,      
   output reg            err_tlp_ur_lock_o, 
   output reg            err_tlp_uc_o,      
   output reg            err_tlp_malformed_o, 
   output reg            stat_tlp_cpl_ep_o,   
   output reg            stat_tlp_cpl_abort_o, 
   output reg            stat_tlp_cpl_ur_o, 
   output reg            stat_tlp_ep_o,     
   output [63:0]         check_raddr_o,     
   output                check_mem32_o,
   output                check_mem64_o,
   output                check_rio_o,       
   output                check_rdev_o,      
   output                check_rbus_o,      
   output                check_rfun_o,      
   input                 check_rhit_i,      
   input [BARW-1:0]      check_rhit_bar_i,  
   `else 
   output reg            err_tlp_bad_header_crc_o,          
   output reg            err_tlp_bad_pi_chain_o,            
   output reg            err_tlp_bad_credit_length_o,       
   output reg            err_tlp_invalid_credit_length_o,   
   output reg            err_tlp_non_zero_turn_pointer_o,   
   output reg            err_tlp_unsup_mvc_o,               
   output reg            err_tlp_unsup_ovc_o,               
   output reg [159:0]    err_tlp_type_b_header_o,           
   input                 err_tlp_type_b_ack_i,              
   `endif
   `ifdef PCIE
   input [2:0]           max_payload_i,     
   input                 rhit_bar_lat3_i,   
   input                 legacy_mode_i,     
   input                 legacy_cfg_access_i,
   input                 ext_cfg_access_i,  
   input                 hotplug_msg_enable_i,
   `else 
   input [3:0]           max_payload_i,     
   input                 switch_mode_i,         
   input                 fabric_manager_mode_i, 
   input [31:0]          cfg_ap0_space_end_i,   
   input [31:0]          cfg_ap1_space_start_i, 
   input [31:0]          cfg_ap1_space_end_i,   
   `endif
   input                 td_ecrc_trim_i     
   );
  `ifdef PCIE
  localparam             MRD32   = 7'b00_00000;
  localparam             MRD64   = 7'b01_00000;
  localparam             MRD32LK = 7'b00_00001;
  localparam             MRD64LK = 7'b01_00001;
  localparam             MWR32   = 7'b10_00000;
  localparam             MWR64   = 7'b11_00000;
  localparam             IORD    = 7'b00_00010;
  localparam             IOWR    = 7'b10_00010;
  localparam             CFGRD0  = 7'b00_00100;
  localparam             CFGWR0  = 7'b10_00100;
  localparam             CFGRD1  = 7'b00_00101;
  localparam             CFGWR1  = 7'b10_00101;
  localparam             MSG     = 7'b01_10xxx;
  localparam             MSGD    = 7'b11_10xxx;
  localparam             MSGAS   = 7'b01_11xxx;
  localparam             MSGASD  = 7'b11_11xxx;
  localparam             CPL     = 7'b00_01010;
  localparam             CPLD    = 7'b10_01010;
  localparam             CPLLK   = 7'b00_01011;
  localparam             CPLDLK  = 7'b10_01011;
  localparam             MEM_BIT   = 8;
  localparam             ADR_BIT   = 7;
  localparam             MRD_BIT   = 6;
  localparam             MWR_BIT   = 5;
  localparam             MLK_BIT   = 4;
  localparam             IO_BIT    = 3;
  localparam             CFG_BIT   = 2;
  localparam             MSG_BIT   = 1;
  localparam             CPL_BIT   = 0;
  localparam [8:0]       OTHERTYPE =  9'b0;
  localparam [8:0]       MEMANY    =  9'b1 << MEM_BIT;
  localparam [8:0]       ADRANY    =  9'b1 << ADR_BIT;
  localparam [8:0]       MRDANY    = (9'b1 << MRD_BIT) | ADRANY | MEMANY;
  localparam [8:0]       MWRANY    = (9'b1 << MWR_BIT) | ADRANY | MEMANY;
  localparam [8:0]       MLKANY    = (9'b1 << MLK_BIT) | ADRANY | MEMANY;
  localparam [8:0]       IOANY     = (9'b1 << IO_BIT)  | ADRANY;
  localparam [8:0]       CFGANY    =  9'b1 << CFG_BIT;
  localparam [8:0]       MSGANY    =  9'b1 << MSG_BIT;
  localparam [8:0]       CPLANY    =  9'b1 << CPL_BIT;
  localparam             UNLOCK                    = 8'b0000_0000;
  localparam             PM_ACTIVE_STATE_NAK       = 8'b0001_0100;
  localparam             PM_PME                    = 8'b0001_1000;
  localparam             PME_TURN_OFF              = 8'b0001_1001;
  localparam             PME_TO_ACK                = 8'b0001_1011;
  localparam             ATTENTION_INDICATOR_OFF   = 8'b0100_0000;
  localparam             ATTENTION_INDICATOR_ON    = 8'b0100_0001;
  localparam             ATTENTION_INDICATOR_BLINK = 8'b0100_0011;
  localparam             POWER_INDICATOR_ON        = 8'b0100_0101;
  localparam             POWER_INDICATOR_BLINK     = 8'b0100_0111;
  localparam             POWER_INDICATOR_OFF       = 8'b0100_0100;
  localparam             ATTENTION_BUTTON_PRESSED  = 8'b0100_1000;
  localparam             SET_SLOT_POWER_LIMIT      = 8'b0101_0000;
  localparam             VENDOR_DEFINED_TYPE_0     = 8'b0111_1110;
  localparam             VENDOR_DEFINED_TYPE_1     = 8'b0111_1111;
  localparam             ROUTE_BY_ID = 3'b010;
  localparam             FMT_3DW_NODATA = 2'b00;
  localparam             FMT_4DW_NODATA = 2'b01;
  localparam             FMT_3DW_WDATA  = 2'b10;
  localparam             FMT_4DW_WDATA  = 2'b11;
  localparam             CPL_STAT_SC  = 3'b000;
  localparam             CPL_STAT_UR  = 3'b001;
  localparam             CPL_STAT_CRS = 3'b010;
  localparam             CPL_STAT_CA  = 3'b100;
  `endif 
  `ifdef PCIE
  localparam             FULLTYPE_HI_IND = DW-2;
  localparam             FULLTYPE_LO_IND = DW-8;
  localparam             TC_HI_IND       = DW-10;
  localparam             TC_LO_IND       = DW-12;
  localparam             TD_IND          = DW-17;
  localparam             EP_IND          = DW-18;
  localparam             ATTR_HI_IND     = DW-19;
  localparam             ATTR_LO_IND     = DW-20;
  localparam             LENGTH_HI_IND   = DW-23;
  localparam             LENGTH_LO_IND   = DW-32;
  localparam             REQ_ID_HI_IND   = 31;
  localparam             REQ_ID_LO_IND   = 16;
  localparam             TAG_HI_IND      = 15;
  localparam             TAG_LO_IND      = 8;
  localparam             CPL_STAT_HI_IND = 15;
  localparam             CPL_STAT_LO_IND = 13;
  localparam             REQ_ID_CPL_HI_IND   = DW-1;
  localparam             REQ_ID_CPL_LO_IND   = DW-16;
  localparam             LOWER_ADDR32_HI_IND = DW-26;
  localparam             LOWER_ADDR32_LO_IND = DW-30;
  localparam             APERTURE_HI_IND     = DW-21;
  localparam             APERTURE_LO_IND     = DW-24;
  localparam             OFFSET_HI_IND       = DW-25;
  localparam             OFFSET_LO_IND       = DW-30;
  localparam             LOWER_ADDR64_HI_IND = 6;
  localparam             LOWER_ADDR64_LO_IND = 2;
  localparam             SET_SLOT_PWRVAL_HI_IND = DW-1;
  localparam             SET_SLOT_PWRVAL_LO_IND = DW-8;
  localparam             SET_SLOT_PWRSCL_HI_IND = DW-15;
  localparam             SET_SLOT_PWRSCL_LO_IND = DW-16;
  `else 
  localparam             PI_1ST_HI_IND   = DW-26;
  localparam             PI_1ST_LO_IND   = DW-32;
  localparam             TC_HI_IND       = DW-21;
  localparam             TC_LO_IND       = DW-23;
  localparam             TD_IND          = DW-24;
  localparam             OO_IND          = DW-20;
  localparam             TS_IND          = DW-19;
  localparam             LENGTH_HI_IND   = DW-14;
  localparam             LENGTH_LO_IND   = DW-18;
  localparam             TURN_PTR_HI_IND = DW-8;
  localparam             TURN_PTR_LO_IND = DW-12;
  localparam             HCRC_HI_IND     = DW-1;
  localparam             HCRC_LO_IND     = DW-7;
  localparam             TURN_POOL_HI_IND= 30;
  localparam             TURN_POOL_LO_IND= 0;
  localparam             DIR_IND         = 31;
  localparam             PI_2ND_HI_IND   = DW-26;
  localparam             PI_2ND_LO_IND   = DW-32;
  localparam             APERTURE_HI_IND = DW-29;
  localparam             APERTURE_LO_IND = DW-32;
  localparam             PI_3RD_HI_IND   = 6;
  localparam             PI_3RD_LO_IND   = 0;
  localparam             OFFSET_HI_IND   = 31;
  localparam             OFFSET_LO_IND   = 2;
  localparam             PI_4TH_HI_IND   = DW-26;
  localparam             PI_4TH_LO_IND   = DW-32;
  `endif
  reg [6:1]              sof_q;
  reg [6:1]              eof_q;
  reg [6:1]              eof_nd_q;
  reg [6:1]              src_rdy_q;
  reg [6:1]              dsc_q;
  reg [6:1]              rem_q;
  reg                    cur_rem; 
  reg                    packet_ip;
  wire [DW-1:0]          d_mux;
  reg [DW-1:0]           d_q1, d_q2, d_q3, d_q4, d_q5, d_q6;
  wire                   latch_1st_dword = sof_i && src_rdy_i;
  reg                    latch_1st_dword_q1, latch_1st_dword_q2,
                         latch_1st_dword_q3, latch_1st_dword_q4;
  wire                   latch_2nd_dword = (DW == 32) ? sof_q[1]:
                                                        sof_i  && src_rdy_i;
  reg                    latch_2nd_dword_q1, latch_2nd_dword_q2;
  wire                   latch_3rd_dword = (DW == 32) ? sof_q[2] : sof_q[1];
  reg                    latch_3rd_dword_q1;
  wire                   latch_4th_dword = (DW == 32) ? sof_q[3] : sof_q[1];
  reg                    latch_4th_dword_q1;
  `ifdef AS
  wire                   latch_5th_dword = (DW == 32) ? sof_q[4] : sof_q[2];
  `endif
  `ifdef PCIE
  wire [6:0]             fulltype_in   = d_i[FULLTYPE_HI_IND:FULLTYPE_LO_IND];
  reg [6:0]              cur_fulltype;
  reg                    cur_fulltype_64, cur_fulltype_mem;
  wire                   cur_has_data = cur_fulltype[6];
  wire [2:0]             cur_routing = cur_fulltype[2:0];
  reg [8:0]              cur_fulltype_oh;
  reg                    cur_locked, cur_locked_q;
  reg                    cur_cpl;
  wire [2:0]             tc_in         = d_i[TC_HI_IND:TC_LO_IND];
  reg [2:0]              cur_tc;
  reg                    cur_tc0;
  wire                   ep_in         = d_i[EP_IND];
  reg                    cur_ep, cur_ep_q;
  wire [1:0]             attr_in       = d_i[ATTR_HI_IND:ATTR_LO_IND];
  reg [1:0]              cur_attr;
  `else 
  wire [6:0]             pi_1st        = d_i[PI_1ST_HI_IND:PI_1ST_LO_IND];
  reg [6:0]              cur_hcrc;
  reg [4:0]              cur_turn_pointer;
  reg                    cur_oo, cur_ts;
  `endif
  wire                   td_in         = d_i[TD_IND];
  reg                    cur_td, cur_td_q;
  localparam             LENW = LENGTH_HI_IND - LENGTH_LO_IND + 1;
  wire [9:0]             length_in     = d_i[LENGTH_HI_IND:LENGTH_LO_IND];
  reg  [9:0]             cur_length;
  `ifdef PCIE
  reg                    cur_length1;
  `else 
  reg                    np_o;  
  `endif
  reg                    cur_np;
  wire                   cur_cfg;
  `ifdef PCIE
  wire [15:0]            req_id_in     = d_i[REQ_ID_HI_IND:REQ_ID_LO_IND];
  reg [15:0]             cur_req_id;
  wire [7:0]             tag_in        = d_i[TAG_HI_IND:TAG_LO_IND];
  reg [7:0]              cur_tag;
  wire [3:0]             last_be_in    = d_i[7:4];
  reg [1:0]              last_be_missing;
  wire [3:0]             first_be_in   = d_i[3:0];
  reg [1:0]              cur_first_be_adj;
  reg [1:0]              first_be_missing;
  reg [2:0]              cur_bytes_missing;
  reg [2:0]              cur_byte_ct_1dw;
  reg [2:0]              byte_ct_1dw;
  wire [7:0]             msgcode_in    = d_i[7:0];
  reg [7:0]              cur_msgcode;
  reg                    cur_vend_msg;
  `else 
  reg [30:0]             cur_turn_pool;
  reg                    cur_dir;
  reg [50:0]             cur_route_header;
  `endif
  `ifdef PCIE
  wire [15:0]            req_id_cpl_in = d_i[REQ_ID_CPL_HI_IND:
                                             REQ_ID_CPL_LO_IND];
  wire [31:0]            addr_hi_in    = d_i[DW-1:DW-32];
  reg [31:0]             cur_addr_hi;
  wire [6:2]             lower_addr32_in = d_i[LOWER_ADDR32_HI_IND:
                                               LOWER_ADDR32_LO_IND];
  wire [6:2]             lower_addr64_in = d_i[LOWER_ADDR64_HI_IND:
                                               LOWER_ADDR64_LO_IND];
  reg  [6:2]             lower_addr32_in_q, lower_addr64_in_q;
  wire [2:0]             cpl_stat_in = d_i[CPL_STAT_HI_IND:
                                           CPL_STAT_LO_IND];
  reg [2:0]              cur_cpl_stat;
  `else 
  wire [6:0]             pi_2nd        = d_i[PI_2ND_HI_IND:PI_2ND_LO_IND];
  `endif
  wire [3:0]             aperture      = d_i[APERTURE_HI_IND:APERTURE_LO_IND];
  wire [OFFSET_HI_IND-OFFSET_LO_IND+2:0] offset;
  assign offset = {d_i[OFFSET_HI_IND:OFFSET_LO_IND],2'b00};
  `ifdef PCIE
  wire   [31:0]          addr_lo_i     = d_i[31:0];
  `else 
  wire [6:0]             pi_3rd        = d_i[PI_3RD_HI_IND:PI_3RD_LO_IND];
  `endif
  `ifdef AS
  wire [6:0]             pi_4th        = d_i[PI_4TH_HI_IND:PI_4TH_LO_IND];
  `endif
  `ifdef PCIE
  wire [9:0]             pwr_data_i = {d_i[SET_SLOT_PWRSCL_HI_IND:
                                           SET_SLOT_PWRSCL_LO_IND],
                                       d_i[SET_SLOT_PWRVAL_HI_IND:
                                           SET_SLOT_PWRVAL_LO_IND]};
  `endif
  wire [FCW-1:0]         cur_data_credits;
  wire                   cur_data_credits_vld;
  reg [FCW-1:0]          fc_use_data_d;
  reg                    remove_lastword;
  `ifdef PCIE
  wire                   malformed;
  wire                   tlp_ur;
  wire                   tlp_ur_lock;
  wire                   tlp_uc;
  wire                   tlp_filt;
  reg [6:0]              cur_lower_addr; 
  reg [11:0]             cur_byte_ct;    
  `else 
  wire                   bad_header_crc;
  wire                   bad_pi_chain;
  wire                   bad_credit_length;
  wire                   invalid_credit_length;
  wire                   non_zero_turn_pointer;
  wire                   unsup_mvc;
  wire                   unsup_ovc;
  wire                   filter_drop;
  `endif
  reg                    cur_drop, next_cur_drop;
  `ifdef PCIE
  reg                    pwr_mgmt_mode_on;
  wire                   cur_pm_msg_detect;
  reg                    np_d, cpl_d, cfg_d, locked_d, vend_msg_d;
  wire [BARW-1:0]        rhit_bar_d;
  wire                   rhit_src_rdy;
  wire                   rhit_ack;
  wire                   rhit_lock;
  reg                    cur_cpl_ep, cur_cpl_abort, cur_cpl_ur;
  reg [28:0]             cur_cpl_header_fmt;
  reg [47:0]             err_tlp_cpl_header_d;
  wire                   cur_hp_msg_detect;
  `else 
  reg [5:0]              load_type_b;
  reg                    type_b_pending;
  wire                   wr_hdr;
  wire                   rd_hdr;
  wire                   sof_hdr;
  wire [DW-1:0]          hdr;
  `endif
  wire [2:0]             out_d1;
  wire [2:0]             out_d2;
  wire [2:0]             out_d3;
  `ifdef PCIE
  assign                 out_d1 = rhit_bar_lat3_i ? 6 : 5;
  `else 
  assign                 out_d1 = 4;
  `endif
  assign                 out_d2 = out_d1 - 1;
  assign                 out_d3 = out_d1 - 2;
  always @(posedge clk_i) begin
    if (reset_i) begin
      fc_use_p_o   <= #`TCQ 0;
      fc_use_np_o  <= #`TCQ 0;
      `ifdef PCIE
      fc_use_cpl_o <= #`TCQ 0;
      `endif
      fc_unuse_o   <= #`TCQ 0;
    end else if (eof_q[out_d2] && !dsc_q[out_d2]) begin
      fc_use_np_o  <= #`TCQ np_o;
      `ifdef PCIE
      fc_use_p_o   <= #`TCQ !np_o && !cpl_o;
      fc_use_cpl_o <= #`TCQ cpl_o;
      `else 
      fc_use_p_o   <= #`TCQ !np_o;
      `endif
      fc_unuse_o   <= #`TCQ next_cur_drop;
    end else begin
      fc_use_p_o   <= #`TCQ 0;
      fc_use_np_o  <= #`TCQ 0;
      `ifdef PCIE
      fc_use_cpl_o <= #`TCQ 0;
      `endif
      fc_unuse_o   <= #`TCQ 0;
    end
  end
  always @(posedge clk_i) begin
    `ifdef PCIE
    if (!rhit_bar_lat3_i || (DW == 32))
    `endif
    begin
      if (cur_data_credits_vld) begin
        fc_use_data_o   <= #`TCQ cur_data_credits;
      end
      fc_use_data_d     <= #`TCQ 0;
    `ifdef PCIE
    end else begin
      if (cur_data_credits_vld) begin
        fc_use_data_d   <= #`TCQ cur_data_credits;
      end
      fc_use_data_o     <= #`TCQ fc_use_data_d;
    `endif
    end
  end
  `ifdef PCIE
  always @(posedge clk_i) begin
    if (reset_i) begin
      stat_tlp_ep_o        <= #`TCQ 0;
      stat_tlp_cpl_ep_o    <= #`TCQ 0;
      stat_tlp_cpl_abort_o <= #`TCQ 0;
      stat_tlp_cpl_ur_o    <= #`TCQ 0;
    end else if (eof_q[out_d2] && !dsc_q[out_d2] && !next_cur_drop) begin
      stat_tlp_ep_o        <= #`TCQ cur_ep_q;
      stat_tlp_cpl_ep_o    <= #`TCQ cur_cpl_ep;
      stat_tlp_cpl_abort_o <= #`TCQ cur_cpl_abort;
      stat_tlp_cpl_ur_o    <= #`TCQ cur_cpl_ur;
    end else begin
      stat_tlp_ep_o        <= #`TCQ 0;
      stat_tlp_cpl_ep_o    <= #`TCQ 0;
      stat_tlp_cpl_abort_o <= #`TCQ 0;
      stat_tlp_cpl_ur_o    <= #`TCQ 0;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_cpl_ep    <= #`TCQ 0;
      cur_cpl_abort <= #`TCQ 0;
      cur_cpl_ur    <= #`TCQ 0;
    end else if (latch_2nd_dword_q2) begin
      if (cur_fulltype_oh[CPL_BIT]) begin
        cur_cpl_ep    <= #`TCQ cur_ep;
        cur_cpl_abort <= #`TCQ cur_cpl_stat == CPL_STAT_CA;
        cur_cpl_ur    <= #`TCQ cur_cpl_stat == CPL_STAT_UR;
      end else begin
        cur_cpl_ep    <= #`TCQ 0;
        cur_cpl_abort <= #`TCQ 0;
        cur_cpl_ur    <= #`TCQ 0;
      end
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      err_tlp_malformed_o <= #`TCQ 0;
      err_tlp_ur_o        <= #`TCQ 0;
      err_tlp_ur_lock_o   <= #`TCQ 0;
      err_tlp_uc_o        <= #`TCQ 0;
      err_tlp_p_o         <= #`TCQ 0;
    end else begin
      err_tlp_malformed_o <= #`TCQ  eof_nd_q[out_d2] &&  malformed;
      err_tlp_ur_o        <= #`TCQ (eof_nd_q[out_d2] && !malformed) && tlp_ur;
      err_tlp_ur_lock_o   <= #`TCQ (eof_nd_q[out_d2] && !malformed) && tlp_ur_lock;
      err_tlp_uc_o        <= #`TCQ (eof_nd_q[out_d2] && !malformed) && tlp_uc;
      err_tlp_p_o         <= #`TCQ !np_o;
    end
  end
  always @(posedge clk_i) begin
    if (!rhit_bar_lat3_i || (DW == 32)) begin
      if (eof_q[3]) begin
        err_tlp_cpl_header_o <= #`TCQ {cur_lower_addr, cur_byte_ct,
                                       cur_cpl_header_fmt};
      end
    end else begin
      if (eof_q[3]) begin
        err_tlp_cpl_header_d <= #`TCQ {cur_lower_addr, cur_byte_ct,
                                       cur_cpl_header_fmt};
      end
      err_tlp_cpl_header_o   <= #`TCQ err_tlp_cpl_header_d;
    end
  end
  always @(posedge clk_i) begin
    if (latch_2nd_dword_q2) begin
      cur_cpl_header_fmt <= #`TCQ {cur_tc, cur_attr, cur_req_id, cur_tag};
    end
  end
  `endif
  always @* begin
    if (eof_q[out_d2]) begin
      `ifdef PCIE
      next_cur_drop = malformed || tlp_ur || tlp_uc || cur_pm_msg_detect ||
                      tlp_filt || (!hotplug_msg_enable_i && cur_hp_msg_detect);
      `else 
      next_cur_drop = bad_header_crc || bad_pi_chain || bad_credit_length ||
                      invalid_credit_length || non_zero_turn_pointer ||
                      unsup_ovc || unsup_mvc || filter_drop;
      `endif
    end else begin
      next_cur_drop = 0;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_drop      <= #`TCQ 0;
    end else begin
      cur_drop      <= #`TCQ next_cur_drop;
    end
  end
  tlm_rx_data_snk_mal #(
    .DW                         (DW),
    .FCW                        (FCW),
    `ifdef PCIE
    .DOWNSTREAM_PORT            (DOWNSTREAM_PORT),
    `else 
    .OVC                        (OVC),
    .MVC                        (MVC),
    `endif
    .MPS                        (MPS),
    .TYPE1_UR                   (TYPE1_UR))
  malformed_checks
   (.clk_i                      (clk_i),
    .reset_i                    (reset_i),
    .sof_i                      (sof_i && src_rdy_i && !packet_ip),
    .eof_i                      (eof_i && src_rdy_i &&  packet_ip),
    `ifdef PCIE
    .rem_i                      (rem_i),
    `endif
    .eval_formats_i             (latch_2nd_dword_q1),
    .length_i                   (cur_length),
    `ifdef PCIE
    .length_1dw_i               (cur_length1),
    `endif
    .aperture_i                 (aperture),
    .load_aperture_i            (latch_3rd_dword),
    .offset_i                   (offset),
    `ifdef PCIE
    .eval_fulltype_i            (latch_1st_dword),
    .fulltype_i                 (fulltype_in),
    .eval_msgcode_i             (latch_2nd_dword),
    .msgcode_i                  (msgcode_in),
    .tc0_i                      (cur_tc0),
    .td_i                       (cur_td),
    .hit_src_rdy_i              (rhit_src_rdy),
    .hit_ack_i                  (rhit_ack),
    .hit_lock_i                 (rhit_lock),
    .hit_i                      (rhit_d),
    `else 
    .oo_i                       (cur_oo),
    .ts_i                       (cur_ts),
    .pi_1st_i                   (pi_1st),
    .pi_2nd_i                   (pi_2nd),
    .pi_3rd_i                   (pi_3rd),
    .pi_4th_i                   (pi_4th),
    .load_pi_1st_i              (latch_1st_dword),
    .load_pi_2nd_i              (latch_3rd_dword),
    .load_pi_3rd_i              (latch_4th_dword),
    .load_pi_4th_i              (latch_5th_dword),
    .load_offset_i              (latch_4th_dword),
    .hcrc_i                     (cur_hcrc),
    .route_header_i             (cur_route_header),
    .turn_pointer_i             (cur_turn_pointer),
    .dir_i                      (cur_dir),
    `endif
    .data_credits_o             (cur_data_credits),
    .data_credits_vld_o         (cur_data_credits_vld),
    .cfg_o                      (cur_cfg),
    .hp_msg_detect_o            (cur_hp_msg_detect),
    `ifdef PCIE
    .malformed_o                (malformed),
    .tlp_ur_o                   (tlp_ur),
    .tlp_ur_lock_o              (tlp_ur_lock),
    .tlp_uc_o                   (tlp_uc),
    .tlp_filt_o                 (tlp_filt),
    `else 
    .bad_header_crc_o           (bad_header_crc),
    .bad_pi_chain_o             (bad_pi_chain),
    .bad_credit_length_o        (bad_credit_length),
    .invalid_credit_length_o    (invalid_credit_length),
    .non_zero_turn_pointer_o    (non_zero_turn_pointer),
    .unsup_mvc_o                (unsup_mvc),
    .unsup_ovc_o                (unsup_ovc),
    .filter_drop_o              (filter_drop),
    `endif
    .max_payload_i              (max_payload_i),
    `ifdef PCIE
    .legacy_mode_i              (legacy_mode_i),
    .legacy_cfg_access_i        (legacy_cfg_access_i),
    .ext_cfg_access_i           (ext_cfg_access_i),
    .hit_lat3_i                 (rhit_bar_lat3_i),
    .pwr_mgmt_on_i              (pwr_mgmt_mode_on)
    `else 
    .switch_mode_i              (switch_mode_i),
    .fabric_manager_mode_i      (fabric_manager_mode_i),
    .cmm_ap0_space_end_i        (cfg_ap0_space_end_i),
    .cmm_ap1_space_start_i      (cfg_ap1_space_start_i),
    .cmm_ap1_space_end_i        (cfg_ap1_space_end_i),
    .lnk_state_i                (lnk_state_i),
    .lnk_state_src_rdy_i        (lnk_state_src_rdy_i)
    `endif
    );
  `ifdef PCIE
  tlm_rx_data_snk_pwr_mgmt
  pwr_mgmt
   (.clk_i                      (clk_i),
    .reset_i                    (reset_i),
    .pm_as_nak_l1_o             (pm_as_nak_l1_o),
    .pm_turn_off_o              (pm_turn_off_o),
    .pm_set_slot_pwr_o          (pm_set_slot_pwr_o),
    .pm_set_slot_pwr_data_o     (pm_set_slot_pwr_data_o),
    .pm_msg_detect_o            (cur_pm_msg_detect),
    .ismsg_i                    (cur_fulltype_oh[MSG_BIT]),
    .msgcode_i                  (cur_msgcode),
    .pwr_data_i                 (pwr_data_i),
    .eval_pwr_mgmt_i            (latch_2nd_dword_q2),
    .eval_pwr_mgmt_data_i       (latch_4th_dword_q1),
    .act_pwr_mgmt_i             (eof_q[out_d3] && !(malformed || tlp_ur))
    );
  tlm_rx_data_snk_bar #(
    .BARW (BARW))
  bar_hit
   (.clk_i                      (clk_i),
    .reset_i                    (reset_i),
    .check_raddr_o              (check_raddr_o),
    .check_rmem64_o             (check_mem64_o),
    .check_rmem32_o             (check_mem32_o),
    .check_rio_o                (check_rio_o),
    .check_rdev_id_o            (check_rdev_o),
    .check_rbus_id_o            (check_rbus_o),
    .check_rfun_id_o            (check_rfun_o),
    .check_rhit_bar_i           (check_rhit_bar_i),
    .check_rhit_i               (check_rhit_i),
    .check_rhit_bar_o           (rhit_bar_d),
    .check_rhit_o               (rhit_d),
    .check_rhit_src_rdy_o       (rhit_src_rdy),
    .check_rhit_ack_o           (rhit_ack),
    .check_rhit_lock_o          (rhit_lock),
    .addr_lo_i                  (addr_lo_i),
    .addr_hi_i                  (((DW == 32) && cur_fulltype_64) ?
                                 cur_addr_hi : addr_hi_in),
    .fulltype_oh_i              (cur_fulltype_oh),
    .mem64_i                    (cur_fulltype_64),
    .routing_i                  (cur_routing),
    .req_id_i                   (cur_req_id),
    .req_id_cpl_i               (req_id_cpl_in), 
    .eval_check_i               (cur_fulltype_64 ? latch_4th_dword:
                                                   latch_3rd_dword),
    .rhit_lat3_i                (rhit_bar_lat3_i),
    .legacy_mode_i              (legacy_mode_i)
    );
  `endif
  `ifdef PCIE
  always @* begin
    casex (last_be_in)
      4'b1xxx: last_be_missing = 0;  
      4'b01xx: last_be_missing = 1;
      4'b001x: last_be_missing = 2;
      4'b0001: last_be_missing = 3;  
      default: last_be_missing = 0;
    endcase
    casex (first_be_in)
      4'bxxx1: first_be_missing = 0; 
      4'bxx10: first_be_missing = 1; 
      4'bx100: first_be_missing = 2; 
      4'b1000: first_be_missing = 3; 
      default: first_be_missing = 0; 
    endcase
    casex (first_be_in) 
      4'b1xx1: byte_ct_1dw      = 4;
      4'b01x1: byte_ct_1dw      = 3;
      4'b1x10: byte_ct_1dw      = 3;
      4'b0011: byte_ct_1dw      = 2;
      4'b0110: byte_ct_1dw      = 2;
      4'b1100: byte_ct_1dw      = 2;
      4'b0001: byte_ct_1dw      = 1;
      4'b0010: byte_ct_1dw      = 1;
      4'b0100: byte_ct_1dw      = 1;
      4'bx000: byte_ct_1dw      = 1;
    endcase
  end
  always @(posedge clk_i) begin
    if (latch_2nd_dword) begin
      cur_bytes_missing <= #`TCQ first_be_missing + last_be_missing;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_byte_ct_1dw   <= #`TCQ 0;
    end else if (latch_2nd_dword) begin
      cur_byte_ct_1dw   <= #`TCQ byte_ct_1dw;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cur_first_be_adj            <= #`TCQ 0;
    end else if (latch_2nd_dword) begin
      cur_first_be_adj            <= #`TCQ first_be_missing;
    end
  end
  always @(posedge clk_i) begin
    if (latch_2nd_dword_q2) begin
      casex (cur_fulltype)
        MRD32, MRD64, MRD32LK, MRD64LK:
          if (cur_length1) begin
            cur_byte_ct       <= #`TCQ cur_byte_ct_1dw;
          end else begin
            cur_byte_ct       <= #`TCQ {cur_length,2'b00} - cur_bytes_missing;
          end
        default:
          cur_byte_ct         <= #`TCQ 4;
      endcase
    end
  end
  always @(posedge clk_i) begin
    if (cur_fulltype_64) begin
      if (latch_4th_dword_q1) begin
        if (cur_fulltype_mem) begin
          cur_lower_addr[6:2]   <= #`TCQ lower_addr64_in_q;
        end else begin
          cur_lower_addr[6:2]   <= #`TCQ 0;
        end
      end
    end else begin
      if (latch_3rd_dword_q1) begin
        if (cur_fulltype_mem) begin
          cur_lower_addr[6:2]   <= #`TCQ lower_addr32_in_q;
        end else begin
          cur_lower_addr[6:2]   <= #`TCQ 0;
        end
      end
    end
  end
  always @(posedge clk_i) begin
    if (latch_3rd_dword_q1) begin
      if (cur_fulltype_mem) begin
        cur_lower_addr[1:0]     <= #`TCQ cur_first_be_adj;
      end else begin
        cur_lower_addr[1:0]     <= #`TCQ 0;
      end
    end
  end
  always @(posedge clk_i) begin
    lower_addr32_in_q           <= #`TCQ lower_addr32_in;
    lower_addr64_in_q           <= #`TCQ lower_addr64_in;
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      pwr_mgmt_mode_on            <= #`TCQ 0;
    end else if (sof_i) begin
      pwr_mgmt_mode_on            <= #`TCQ pm_suspend_req_i;
    end
  end
  `endif 
  always @(posedge clk_i) begin
    if (reset_i) begin
      packet_ip                   <= #`TCQ 0;
    end else if (src_rdy_i) begin
      packet_ip                   <= #`TCQ (sof_i || packet_ip) && !eof_i;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      remove_lastword         <= #`TCQ 0;
    end else begin
      if (eof_q[3]) begin
        if (DW == 64) begin
          remove_lastword   <= #`TCQ !cur_rem && (cur_td_q && td_ecrc_trim_i);
        end else begin
          remove_lastword   <= #`TCQ cur_td_q && td_ecrc_trim_i;
        end
      end else if (eof_o) begin
        remove_lastword     <= #`TCQ 0;
      end
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      sof_q[1]             <= #`TCQ 0;
      eof_q[1]             <= #`TCQ 0;
      src_rdy_q[1]         <= #`TCQ 0;
      rem_q[1]             <= #`TCQ 1;
      dsc_q[1]             <= #`TCQ 0;
      eof_nd_q[1]          <= #`TCQ 0;
      sof_o                <= #`TCQ 0;
    end else begin
      sof_q[1]             <= #`TCQ sof_i && src_rdy_i && !packet_ip;
      eof_q[1]             <= #`TCQ eof_i && src_rdy_i && packet_ip;
      src_rdy_q[1]         <= #`TCQ src_rdy_i && (packet_ip || sof_i);
      dsc_q[1]             <= #`TCQ eof_i && src_rdy_i && packet_ip
                                    && src_dsc_i;
      eof_nd_q[1]          <= #`TCQ eof_i && src_rdy_i && packet_ip
                                    && !src_dsc_i;
      if (DW == 64) begin
        if (eof_i) begin
          rem_q[1]         <= #`TCQ rem_i ^ (cur_td && td_ecrc_trim_i);
          cur_rem          <= #`TCQ rem_i;
        end else begin
          rem_q[1]         <= #`TCQ 1;
        end
      end else begin
        rem_q[1]           <= #`TCQ 1;
        cur_rem            <= #`TCQ 1;
      end
      sof_o                <= #`TCQ sof_q[out_d1];
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      src_rdy_o          <= #`TCQ 0;
      dsc_o              <= #`TCQ 0;
      rem_o              <= #`TCQ 1;
      eof_o              <= #`TCQ 0;
      preeof_o           <= #`TCQ 0;
    end else if (remove_lastword) begin
      if (!eof_o) begin
        src_rdy_o        <= #`TCQ src_rdy_q[out_d2];
      end else if ((DW == 64) && !rem_q[out_d2]) begin
        src_rdy_o        <= #`TCQ src_rdy_q[out_d2];
      end else begin
        src_rdy_o        <= #`TCQ 1'b0;
      end
      dsc_o              <= #`TCQ dsc_q[out_d2] ||
                                 (eof_q[out_d2] && next_cur_drop);
      rem_o              <= #`TCQ (DW == 64) ? rem_q[out_d2] : 1'b1;
      eof_o              <= #`TCQ eof_q[out_d2];
      preeof_o           <= #`TCQ eof_q[out_d3];
    end else begin
      src_rdy_o          <= #`TCQ src_rdy_q[out_d1] &&
                                  !(eof_o && !sof_q[out_d1]);
      dsc_o              <= #`TCQ dsc_q[out_d1] || (eof_q[out_d1] && cur_drop);
      rem_o              <= #`TCQ (DW == 64) ?  rem_q[out_d1] : 1'b1;
      eof_o              <= #`TCQ eof_q[out_d1];
      preeof_o           <= #`TCQ eof_q[out_d2];
    end
  end
  always @(posedge clk_i) begin
    sof_q[6:2]         <= #`TCQ sof_q[5:1];
    eof_q[6:2]         <= #`TCQ eof_q[5:1];
    src_rdy_q[6:2]     <= #`TCQ src_rdy_q[5:1];
    dsc_q[6:2]         <= #`TCQ dsc_q[5:1];
    rem_q[6:2]         <= #`TCQ (DW == 64) ? rem_q[5:1] : 5'h1f;
    eof_nd_q[6:2]      <= #`TCQ eof_nd_q[5:1];
  end
  `ifdef PCIE
  assign d_mux = (sof_i && td_ecrc_trim_i) ?
                 {d_i[DW-1:TD_IND+1], 1'b0, d_i[TD_IND-1:0]} : d_i;
  `else 
  assign d_mux = d_i;
  `endif
  always @(posedge clk_i) begin
    d_q1                 <= #`TCQ d_mux;
    d_q2                 <= #`TCQ d_q1;
    d_q3                 <= #`TCQ d_q2;
    d_q4                 <= #`TCQ d_q3;
    d_q5                 <= #`TCQ d_q4;
    d_q6                 <= #`TCQ d_q5;
    case (out_d1)
      5:       d_o       <= #`TCQ d_q5;
      6:       d_o       <= #`TCQ d_q6;
      default: d_o       <= #`TCQ d_q4;
    endcase
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      vc_hit_o           <= #`TCQ 1'b0;
    end else if (src_rdy_o && eof_o && !dsc_o) begin
      vc_hit_o           <= #`TCQ 1'b1;
    end
  end
  always @(posedge clk_i) begin
    `ifdef PCIE
    if (!rhit_bar_lat3_i || (DW == 32))
    `endif
    begin
      if (latch_1st_dword_q4) begin
        `ifdef PCIE
        cpl_o           <= #`TCQ cur_cpl;
        locked_o        <= #`TCQ cur_locked_q;
        vend_msg_o      <= #`TCQ cur_vend_msg;
        `endif
        np_o            <= #`TCQ cur_np;
        cfg_o           <= #`TCQ cur_cfg;
      end
    end
    `ifdef PCIE
    else begin
      if (latch_1st_dword_q4) begin
        np_d            <= #`TCQ cur_np;
        cpl_d           <= #`TCQ cur_cpl;
        locked_d        <= #`TCQ cur_locked_q;
        cfg_d           <= #`TCQ cur_cfg;
        vend_msg_d      <= #`TCQ vend_msg_d;
      end
      np_o              <= #`TCQ np_d;
      cpl_o             <= #`TCQ cpl_d;
      locked_o          <= #`TCQ locked_d;
      cfg_o             <= #`TCQ cfg_d;
      vend_msg_o        <= #`TCQ vend_msg_d;
    end
    `endif
  end
  always @(posedge clk_i) begin
    if (latch_1st_dword_q2) begin
      `ifdef PCIE
      cur_ep_q          <= #`TCQ cur_ep;
      cur_cpl           <= #`TCQ cur_fulltype_oh[CPL_BIT];
      cur_locked_q      <= #`TCQ cur_locked;
      cur_np            <= #`TCQ !cur_fulltype_oh[MWR_BIT] &&
                                 !cur_fulltype_oh[MSG_BIT] &&
                                 !cur_fulltype_oh[CPL_BIT];
      `else 
      cur_np            <= #`TCQ !cur_oo && cur_ts;
      `endif
      cur_td_q          <= #`TCQ cur_td;
    end
  end
  `ifdef PCIE
  always @(posedge clk_i) begin
    if (latch_2nd_dword_q2) begin
      cur_vend_msg      <= #`TCQ ((cur_msgcode == VENDOR_DEFINED_TYPE_0) ||
                                  (cur_msgcode == VENDOR_DEFINED_TYPE_1)) &&
                                 cur_fulltype_oh[MSG_BIT];
    end
  end
  `endif
  `ifdef PCIE
  always @(posedge clk_i) begin
    if (rhit_src_rdy) begin
      bar_o                     <= #`TCQ rhit_bar_d;
      rid_o                     <= #`TCQ rhit_d;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      bar_src_rdy_o             <= #`TCQ 0;
    end else if (rhit_src_rdy) begin
      bar_src_rdy_o             <= #`TCQ 1;
    end else begin
      bar_src_rdy_o             <= #`TCQ 0;
    end
  end
  `else 
  always @(posedge clk_i) begin
    if (latch_1st_dword) begin
      cur_oo               <= #`TCQ d_i[OO_IND];
      cur_ts               <= #`TCQ d_i[TS_IND];
    end
  end
  `endif
  always @(posedge clk_i) begin
    if (reset_i) begin
      latch_1st_dword_q1 <= #`TCQ 0;
      latch_1st_dword_q2 <= #`TCQ 0;
      latch_1st_dword_q3 <= #`TCQ 0;
      latch_1st_dword_q4 <= #`TCQ 0;
      latch_2nd_dword_q1 <= #`TCQ 0;
      latch_2nd_dword_q2 <= #`TCQ 0;
      latch_3rd_dword_q1 <= #`TCQ 0;
      latch_4th_dword_q1 <= #`TCQ 0;
    end else begin
      latch_1st_dword_q1 <= #`TCQ latch_1st_dword;
      latch_1st_dword_q2 <= #`TCQ latch_1st_dword_q1;
      latch_1st_dword_q3 <= #`TCQ latch_1st_dword_q2;
      latch_1st_dword_q4 <= #`TCQ latch_1st_dword_q3;
      latch_2nd_dword_q1 <= #`TCQ latch_2nd_dword;
      latch_2nd_dword_q2 <= #`TCQ latch_2nd_dword_q1;
      latch_3rd_dword_q1 <= #`TCQ latch_3rd_dword;
      latch_4th_dword_q1 <= #`TCQ latch_4th_dword;
    end
  end
  always @(posedge clk_i) begin
    if (latch_1st_dword) begin
      cur_td                    <= #`TCQ td_in;
      cur_length                <= #`TCQ length_in;
      `ifdef PCIE
      cur_tc                    <= #`TCQ tc_in;
      cur_tc0                   <= #`TCQ tc_in == 0;
      cur_ep                    <= #`TCQ ep_in;
      cur_attr                  <= #`TCQ attr_in;
      cur_length1               <= #`TCQ length_in == 1;
      cur_fulltype              <= #`TCQ fulltype_in;
      casex (fulltype_in)
        MRD32, MRD32LK, MWR32, MRD64, MRD64LK, MWR64:
          cur_fulltype_mem      <= #`TCQ 1;
        default:
          cur_fulltype_mem      <= #`TCQ 0;
      endcase
      casex (fulltype_in)
        MRD64, MRD64LK, MWR64:
          cur_fulltype_64       <= #`TCQ 1;
        default:
          cur_fulltype_64       <= #`TCQ 0;
      endcase
      casex (fulltype_in)
        MRD32, MRD64:
          cur_fulltype_oh       <= #`TCQ MRDANY;
        MWR32, MWR64:
          cur_fulltype_oh       <= #`TCQ MWRANY;
        MRD32LK, MRD64LK:
          cur_fulltype_oh       <= #`TCQ MLKANY;
        IORD, IOWR:
          cur_fulltype_oh       <= #`TCQ IOANY;
        CFGRD0, CFGWR0, CFGRD1, CFGWR1:
          cur_fulltype_oh       <= #`TCQ CFGANY;
        MSG, MSGD:
          cur_fulltype_oh       <= #`TCQ MSGANY;
        CPL, CPLD, CPLLK, CPLDLK:
          cur_fulltype_oh       <= #`TCQ CPLANY;
        default: 
          cur_fulltype_oh       <= #`TCQ OTHERTYPE;
      endcase
      casex (fulltype_in)
        MRD32LK, MRD64LK, CPLLK, CPLDLK:
          cur_locked            <= #`TCQ 1;
        default:
          cur_locked            <= #`TCQ 0;
      endcase
      `else 
      cur_hcrc          <= #`TCQ d_i[HCRC_HI_IND:HCRC_LO_IND];
      cur_turn_pointer  <= #`TCQ d_i[TURN_PTR_HI_IND:TURN_PTR_LO_IND];
      `endif
    end
  end
  `ifdef PCIE
  always @(posedge clk_i) begin
    if (latch_2nd_dword) begin
      cur_req_id                <= #`TCQ req_id_in;
      cur_tag                   <= #`TCQ tag_in;
      cur_msgcode               <= #`TCQ msgcode_in;
      cur_cpl_stat              <= #`TCQ cpl_stat_in;
    end
  end
  always @(posedge clk_i) begin
    if (latch_3rd_dword) begin
      cur_addr_hi               <= #`TCQ addr_hi_in;
    end
  end
  `else 
  always @(posedge clk_i) begin
    if (latch_2nd_dword) begin
      cur_dir                   <= #`TCQ d_i[DIR_IND];
    end
  end
  always @(posedge clk_i) begin
    if (latch_1st_dword) begin
      cur_route_header[50:32]   <= #`TCQ d_i[DW-14:DW-32];
    end
    if (latch_2nd_dword) begin
      cur_route_header[31:0]    <= #`TCQ d_i[31:0];
    end
  end
  `endif
  `ifdef AS
  tlm_srl_fifo
    #(.DW       (DW),
      .DMW      (DW+1), 
      .DEPTH    (7),
      .CT_OUT   (0))
  buf_fifo
     (.clk_i    (clk_i),
      .reset_i  (reset_i),
      .wen_i    (wr_hdr),
      .d_i      ({sof_i,d_i}),
      .ren_i    (rd_hdr),
      .d_o      ({hdr_sof,hdr}),
      .vld_o    (),
      .nxt_vld_o(),
      .ct_o     (),
      .chkpt_i  (1'b1),
      .bkp_i    (1'b0)
      );
  assign wr_hdr = (latch_1st_dword && !packet_ip) ||
                   latch_2nd_dword || latch_3rd_dword ||
                   latch_4th_dword || latch_5th_dword;
  generate
    if (DW == 64) begin : rd_hdr_64
      assign rd_hdr = eof_q[1] || (|eof_q[3:2] || !sof_hdr);
    end else begin : rd_hdr_32
      assign rd_hdr = eof_o    || (|eof_q[4:1] || !sof_hdr);
    end
  endgenerate
  always @* load_type_b[0] = !type_b_pending &&
                             ((DW == 64) ? eof_q[1] :
                                          (eof_i && src_rdy_i && packet_ip));
  always @(posedge clk_i) begin
    load_type_b[5:1] <= #`TCQ load_type_b[4:0];
  end
  wire latch_1st_hdr_dword = load_type_b[0];
  wire latch_2nd_hdr_dword = (DW == 64) ? load_type_b[0] : load_type_b[1];
  wire latch_3rd_hdr_dword = (DW == 64) ? load_type_b[1] : load_type_b[2];
  wire latch_4th_hdr_dword = (DW == 64) ? load_type_b[1] :
                                         (load_type_b[3] && !sof_hdr);
  wire latch_5th_hdr_dword = (DW == 64) ?(load_type_b[2] && !sof_hdr) :
                                         (load_type_b[4] && !sof_hdr);
  localparam UPPER_HI_IND = DW-1;
  localparam UPPER_LO_IND = DW-32;
  localparam LOWER_HI_IND = 31;
  localparam LOWER_LO_IND = 0;
  always @(posedge clk_i) begin
    if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[159:128]<= #`TCQ hdr[UPPER_HI_IND:UPPER_LO_IND];
    end
    if (latch_2nd_hdr_dword) begin
      err_tlp_type_b_header_o[127:96] <= #`TCQ hdr[LOWER_HI_IND:LOWER_LO_IND];
    end else if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[127:96] <= #`TCQ 0;
    end
    if (latch_3rd_hdr_dword) begin
      err_tlp_type_b_header_o[95:64]  <= #`TCQ hdr[UPPER_HI_IND:UPPER_LO_IND];
    end else if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[95:64]  <= #`TCQ 0;
    end
    if (latch_4th_hdr_dword) begin
      err_tlp_type_b_header_o[63:32]  <= #`TCQ hdr[LOWER_HI_IND:LOWER_LO_IND];
    end else if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[63:32]  <= #`TCQ 0;
    end
    if (latch_5th_hdr_dword) begin
      err_tlp_type_b_header_o[31:0]   <= #`TCQ hdr[UPPER_HI_IND:UPPER_LO_IND];
    end else if (latch_1st_hdr_dword) begin
      err_tlp_type_b_header_o[31:0]   <= #`TCQ 0;
    end
  end
  localparam Q2HDR   = (DW == 64) ? 3 : 5;
  localparam EOF2HDR = (DW == 64) ? 3 : 4;
  always @(posedge clk_i) begin
    if (reset_i) begin
      err_tlp_bad_header_crc_o        <= #`TCQ 0;
      err_tlp_bad_pi_chain_o          <= #`TCQ 0;
      err_tlp_invalid_credit_length_o <= #`TCQ 0;
      err_tlp_bad_credit_length_o     <= #`TCQ 0;
      err_tlp_non_zero_turn_pointer_o <= #`TCQ 0;
      err_tlp_unsup_ovc_o             <= #`TCQ 0;
      err_tlp_unsup_mvc_o             <= #`TCQ 0;
    end else if (load_type_b[Q2HDR] && eof_nd_q[EOF2HDR]) begin
      err_tlp_bad_header_crc_o        <= #`TCQ bad_header_crc;
      err_tlp_bad_pi_chain_o          <= #`TCQ bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_invalid_credit_length_o <= #`TCQ invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_bad_credit_length_o     <= #`TCQ bad_credit_length &&
                                              !invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_non_zero_turn_pointer_o <= #`TCQ non_zero_turn_pointer &&
                                              !bad_credit_length &&
                                              !invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_unsup_mvc_o             <= #`TCQ unsup_mvc &&
                                              !non_zero_turn_pointer &&
                                              !bad_credit_length &&
                                              !invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
      err_tlp_unsup_ovc_o             <= #`TCQ unsup_ovc &&
                                              !unsup_mvc &&
                                              !non_zero_turn_pointer &&
                                              !bad_credit_length &&
                                              !invalid_credit_length &&
                                              !bad_pi_chain &&
                                              !bad_header_crc;
    end else begin
      err_tlp_bad_header_crc_o        <= #`TCQ 0;
      err_tlp_bad_pi_chain_o          <= #`TCQ 0;
      err_tlp_invalid_credit_length_o <= #`TCQ 0;
      err_tlp_bad_credit_length_o     <= #`TCQ 0;
      err_tlp_non_zero_turn_pointer_o <= #`TCQ 0;
      err_tlp_unsup_mvc_o             <= #`TCQ 0;
      err_tlp_unsup_ovc_o             <= #`TCQ 0;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      type_b_pending <= #`TCQ 0;
    end else if (eof_nd_q[EOF2HDR] && load_type_b[Q2HDR]) begin
      type_b_pending <= #`TCQ bad_header_crc || bad_pi_chain ||
                              invalid_credit_length || bad_credit_length ||
                              non_zero_turn_pointer || unsup_mvc || unsup_ovc;
    end else if (err_tlp_type_b_ack_i) begin
      type_b_pending <= #`TCQ 0;
    end
  end
  `endif
  `ifdef PCIE
  reg [10*8:0] cur_type_str;
  always @* begin
    casex (cur_fulltype)
      MRD32   :  begin cur_type_str = "MRD32";  end
      MRD64   :  begin cur_type_str = "MRD64";  end
      MRD32LK :  begin cur_type_str = "MRD32LK";end
      MRD64LK :  begin cur_type_str = "MRD64LK";end
      MWR32   :  begin cur_type_str = "MWR32";  end
      MWR64   :  begin cur_type_str = "MWR64";  end
      IORD    :  begin cur_type_str = "IORD";   end
      IOWR    :  begin cur_type_str = "IOWR";   end
      CFGRD0  :  begin cur_type_str = "CFGRD0"; end
      CFGWR0  :  begin cur_type_str = "CFGWR0"; end
      CFGRD1  :  begin cur_type_str = "CFGRD1"; end
      CFGWR1  :  begin cur_type_str = "CFGWR1"; end
      MSG     :  begin cur_type_str = "MSG";    end
      MSGD    :  begin cur_type_str = "MSGD";   end
      MSGAS   :  begin cur_type_str = "MSGAS";  end
      MSGASD  :  begin cur_type_str = "MSGASD"; end
      CPL     :  begin cur_type_str = "CPL";    end
      CPLD    :  begin cur_type_str = "CPLD";   end
      CPLLK   :  begin cur_type_str = "CPLLK";  end
      CPLDLK  :  begin cur_type_str = "CPLDLK"; end
      default :  begin cur_type_str = "undef";  end
    endcase
  end
  reg [30*8:0] cur_msgstr;
  always @* begin
    case (cur_msgcode)
      UNLOCK                    : cur_msgstr = "UNLOCK";
      PM_ACTIVE_STATE_NAK       : cur_msgstr = "PM_ACTIVE_STATE_NAK";
      PM_PME                    : cur_msgstr = "PM_PME";
      PME_TURN_OFF              : cur_msgstr = "PME_TURN_OFF";
      PME_TO_ACK                : cur_msgstr = "PME_TO_ACK";
      ATTENTION_INDICATOR_OFF   : cur_msgstr = "ATTENTION_INDICATOR_OFF";
      ATTENTION_INDICATOR_ON    : cur_msgstr = "ATTENTION_INDICATOR_ON";
      ATTENTION_INDICATOR_BLINK : cur_msgstr = "ATTENTION_INDICATOR_BLINK";
      POWER_INDICATOR_ON        : cur_msgstr = "POWER_INDICATOR_ON";
      POWER_INDICATOR_BLINK     : cur_msgstr = "POWER_INDICATOR_BLINK";
      POWER_INDICATOR_OFF       : cur_msgstr = "POWER_INDICATOR_OFF";
      ATTENTION_BUTTON_PRESSED  : cur_msgstr = "ATTENTION_BUTTON_PRESSED";
      SET_SLOT_POWER_LIMIT      : cur_msgstr = "SET_SLOT_POWER_LIMIT";
      VENDOR_DEFINED_TYPE_0     : cur_msgstr = "VENDOR_DEFINED_TYPE_0";
      VENDOR_DEFINED_TYPE_1     : cur_msgstr = "VENDOR_DEFINED_TYPE_1";
      default                   : cur_msgstr = "undef";
    endcase
  end
  `endif
endmodule
