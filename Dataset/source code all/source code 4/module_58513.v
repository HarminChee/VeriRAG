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
module tlm_rx_data_snk_mal #(parameter DW = 32,
                             parameter FCW = 6,
                             parameter LENW = 10,
                             `ifdef PCIE
                             parameter DOWNSTREAM_PORT = 0,
                             `else 
                             parameter OVC = 0,
                             parameter MVC = 0,
                             `endif
                             parameter MPS = 512,
                             parameter TYPE1_UR = 0)
  (
   input                 clk_i,
   input                 reset_i,
   output reg [FCW-1:0]  data_credits_o,    
   output                data_credits_vld_o,
   output reg            cfg_o,             
   `ifdef AS
   input                 oo_i,              
   input                 ts_i,              
   `endif
   `ifdef PCIE
   output reg            malformed_o,       
   output reg            tlp_ur_o,          
   output reg            tlp_ur_lock_o,     
   output reg            tlp_uc_o,          
   output reg            tlp_filt_o,        
   `else 
   output reg            bad_header_crc_o,
   output reg            bad_pi_chain_o,
   output reg            bad_credit_length_o,
   output reg            invalid_credit_length_o,
   output reg            non_zero_turn_pointer_o,
   output reg            unsup_mvc_o,
   output reg            unsup_ovc_o,
   `endif
   input [3:0]           aperture_i,        
   input                 load_aperture_i,
   `ifdef PCIE
   input                 eval_fulltype_i,   
   input [6:0]           fulltype_i,        
   input                 eval_msgcode_i,    
   input [7:0]           msgcode_i,         
   input                 tc0_i,             
   input                 hit_src_rdy_i,     
   input                 hit_ack_i,         
   input                 hit_lock_i,        
   input                 hit_i,             
   input                 hit_lat3_i,        
   input                 pwr_mgmt_on_i,     
   input                 legacy_mode_i,     
   input                 legacy_cfg_access_i,
   input                 ext_cfg_access_i,  
   input [7:0]           offset_i,          
   output reg            hp_msg_detect_o,   
   `else 
   input [6:0]           pi_1st_i,
   input [6:0]           pi_2nd_i,
   input [6:0]           pi_3rd_i,
   input [6:0]           pi_4th_i,
   input                 load_pi_1st_i,
   input                 load_pi_2nd_i,
   input                 load_pi_3rd_i,
   input                 load_pi_4th_i,
   input [6:0]           hcrc_i,            
   input [50:0]          route_header_i,    
   input [4:0]           turn_pointer_i,    
   input                 dir_i,             
   input                 switch_mode_i,     
   input [31:0]          offset_i,          
   input                 load_offset_i,
   input                 fabric_manager_mode_i, 
   input [31:0]          cmm_ap0_space_end_i,   
   input [31:0]          cmm_ap1_space_start_i, 
   input [31:0]          cmm_ap1_space_end_i,   
   input [1:0]           lnk_state_i,      
   input                 lnk_state_src_rdy_i,   
   output                filter_drop_o,
   `endif
   input                 eval_formats_i,    
   input [9:0]           length_i,          
   `ifdef PCIE
   input                 length_1dw_i,      
   `endif
   input                 sof_i,             
   input                 eof_i,             
   `ifdef PCIE
   input                 rem_i,             
   input                 td_i,              
   input [2:0]           max_payload_i      
   `else 
   input [3:0]           max_payload_i      
   `endif
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
  localparam             CFGANY  = 7'bx0_0010x;
  localparam             CFGANY0 = 7'bx0_00100;
  localparam             CFGANY1 = 7'bx0_00101;
  localparam             MSG     = 7'b01_10xxx;
  localparam             MSGD    = 7'b11_10xxx;
  localparam             CPL     = 7'b00_01010;
  localparam             CPLD    = 7'b10_01010;
  localparam             CPLLK   = 7'b00_01011;
  localparam             CPLDLK  = 7'b10_01011;
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
  localparam             ASSERT_INTA               = 8'b0010_0000;
  localparam             ASSERT_INTB               = 8'b0010_0001;
  localparam             ASSERT_INTC               = 8'b0010_0010;
  localparam             ASSERT_INTD               = 8'b0010_0011;
  localparam             DEASSERT_INTA             = 8'b0010_0100;
  localparam             DEASSERT_INTB             = 8'b0010_0101;
  localparam             DEASSERT_INTC             = 8'b0010_0110;
  localparam             DEASSERT_INTD             = 8'b0010_0111;
  localparam             ERR_COR                   = 8'b0011_0000;
  localparam             ERR_NONFATAL              = 8'b0011_0001;
  localparam             ERR_FATAL                 = 8'b0011_0011;
  localparam             VENDOR_DEFINED_TYPE_0     = 8'b0111_1110;
  localparam             VENDOR_DEFINED_TYPE_1     = 8'b0111_1111;
  localparam             ROUTE_TO_RC = 3'b000;
  localparam             ROUTE_BY_AD = 3'b001;
  localparam             ROUTE_BY_ID = 3'b010;
  localparam             ROUTE_BROAD = 3'b011;
  localparam             ROUTE_LOCAL = 3'b100;
  localparam             ROUTE_GATHR = 3'b101;
  localparam             ROUTE_RSRV0 = 3'b110;
  localparam             ROUTE_RSRV1 = 3'b111;
  `endif 
  `ifdef PCIE
  localparam             DCW = FCW + ((DW == 64) ? 1 : 2);  
  localparam             PLW = (FCW == 9) ? 10 : (FCW + 2);
  `else 
  localparam             DCW = FCW + ((DW == 64) ? 3 : 4);  
  localparam             PLW = (FCW == 6) ? 5 : FCW;
  `endif
  localparam UPSTREAM_PORT = !DOWNSTREAM_PORT;
  reg                    eof_q1;
  `ifdef PCIE
  reg                    sof_q1, sof_q2, sof_q3, sof_q4;
  reg                    eof_q2, eof_q3;
  reg                    eval_formats_q, eval_formats_q2;
  wire                   eof_sync, bar_sync;
  reg                    load_aperture_q;
  `else 
  reg                    load_offset_q;
  `endif
  reg [DCW-1:0]          word_ct;
  reg [DCW-1:0]          word_ct_d;
  reg                    malformed_maxsize;
  reg                    malformed_over;
  `ifdef AS
  reg                    malformed_byp_not_1;
  reg                    malformed_pi4_or_5_not_1;
  `endif
  reg [LENW-1:0]         max_length;
  `ifdef PCIE
  reg [6:0]              fulltype_in;
  reg [7:0]              msgcode_in;
  wire                   has_data   = fulltype_in[6];
  wire                   header_4dw = fulltype_in[5];
  wire                   length_odd = length_i[0] && has_data;
  reg                    type_1dw;
  reg                    malformed_eof;
  reg                    malformed_rem;
  reg                    malformed_len;
  reg                    malformed_min;
  wire                   malformed_1dw;
  wire                   word_ct_zero;
  wire                   word_ct_neg1;
  wire                   expected_rem;
  reg                    delay_ct;
  reg                    delay_ct_d;
  `endif
  `ifdef PCIE
  reg                    malformed_fulltype;
  reg                    malformed_tc;
  reg                    malformed_message;
  reg                    malformed_fmt;
  reg                    ismsg, ismsgd, ismsgany;
  reg                    fulltype_tc0;
  wire                   msgcode_tc0;
  reg                    msgcode_legacy;
  reg                    msgcode_hotplug;
  reg                    msgcode_sigdef;
  reg                    msgcode_vendef;
  reg                    msgcode_dmatch;
  reg [2:0]              msgcode_routing;
  wire [2:0]             routing    = fulltype_i[2:0];
  wire [2:0]             routing_in = fulltype_in[2:0];
  reg                    routing_vendef;
  reg                    cpl_ip;
  reg                    filter_msgcode;
  reg                    filter_msgcode_q;
  reg                    ur_pwr_mgmt, uc_pwr_mgmt;
  reg                    ur_type1_cfg = 0;
  reg                    ur_mem_lk, uc_cpl_lk;
  reg                    ur_format, uc_format;
  reg                    ur_format_lock;
  reg                    cfg0_ip, cfg1_ip;
  reg                    is_usr_leg_ap, is_usr_ext_ap;
  `else 
  reg  [7:0]             pi_1st;
  reg  [7:0]             pi_2nd;
  reg  [7:0]             pi_3rd;
  reg  [7:0]             pi_4th;
  wire                   load_pi_1st;
  wire                   load_pi_2nd;
  wire                   load_pi_3rd;
  wire                   load_pi_4th;
  reg                    pi_1st_vld;
  reg                    pi_2nd_vld;
  reg                    pi_3rd_vld;
  reg                    pi_4th_vld;
  reg                    pi_2nd_seq_vld;
  reg                    pi_3rd_seq_vld;
  reg                    pi_4th_seq_vld;
  reg                    primary_pi0;
  reg                    primary_pi4;
  reg                    primary_pi5;
  reg                    pi4_ap0;
  reg                    pi4_ap1;
  reg                    in_ap0_range;
  reg                    in_ap1_range;
  reg                    secondary_pi0;
  reg  [1:0]             lnk_state_d;
  reg  [1:0]             lnk_state;
  reg                    packet_ip;
  reg                    packet_keep;
  wire [6:0]             header_crc_d;
  wire [6:0]             header_crc_pb_d;
  reg  [6:0]             header_crc;
  reg  [6:0]             header_crc_pb;
  reg                    path_build;
  `endif
  `ifdef PCIE
  assign eof_sync = hit_lat3_i ? eof_q3 : eof_q2;
  assign bar_sync = hit_lat3_i ? eval_formats_q2 : eval_formats_q;
  `endif
  `ifdef PCIE
  always @(posedge clk_i) begin
    if (sof_q2) begin
      data_credits_o[PLW-3:0] <= #`TCQ has_data ?
                                       (length_i[PLW-1:2] + |length_i[1:0]): 0;
    end
  end
  generate
    if (FCW == 9) begin : max_data_credits
      always @(posedge clk_i) begin
        if (sof_q2) begin
          data_credits_o[FCW-1] <= #`TCQ ~|length_i && has_data;
        end
      end
    end
  endgenerate
  assign data_credits_vld_o = sof_q4;
  `else 
  localparam WPC  = 512/DW;      
  localparam WPCW = (DW == 64) ? 3 : 4;  
  always @* data_credits_o     = word_ct[DCW-1:WPCW];
  assign    data_credits_vld_o = eof_q1;
  `endif
  `ifdef PCIE
  localparam MAX_128  =                 32;             
  localparam MAX_256  = (MPS >= 256)  ? 64  : MAX_128;  
  localparam MAX_512  = (MPS >= 512)  ? 128 : MAX_256;  
  localparam MAX_1024 = (MPS >= 1024) ? 256 : MAX_512;  
  localparam MAX_2048 = (MPS >= 2048) ? 512 : MAX_1024; 
  localparam MAX_4096 = (MPS >= 4096) ? 0   : MAX_2048; 
  always @(posedge clk_i) begin
    if (reset_i) begin
      max_length            <= #`TCQ MAX_128;
    end else begin
      case (max_payload_i)
        3'b000:  max_length <= #`TCQ MAX_128;
        3'b001:  max_length <= #`TCQ MAX_256;
        3'b010:  max_length <= #`TCQ MAX_512;
        3'b011:  max_length <= #`TCQ MAX_1024;
        3'b100:  max_length <= #`TCQ MAX_2048;
        default: max_length <= #`TCQ MAX_4096;
      endcase
    end
  end
  `else 
  localparam BVC = !OVC && !MVC;
  localparam MAX_64   =  !BVC                  ? 1 : 3;
  localparam MAX_96   = (!BVC && (MPS >= 96))  ? 2 : 3;
  localparam MAX_128  = (!BVC && (MPS >= 128)) ? 2 : 3;
  localparam MAX_192  =          (MPS >= 192)  ? 3 : MAX_128;
  localparam MAX_320  =          (MPS >= 320)  ? 5 : MAX_192;
  localparam MAX_576  =          (MPS >= 576)  ? 9 : MAX_320;
  localparam MAX_1088 =          (MPS >= 1088) ? 17: MAX_576;
  localparam MAX_2176 =          (MPS >= 2176) ? 0 : MAX_1088;
  always @(posedge clk_i) begin
    if (reset_i) begin
      max_length            <= #`TCQ MAX_192;
    end else begin
      casex (max_payload_i)
        4'b000x: max_length <= #`TCQ MAX_64;
        4'b0010: max_length <= #`TCQ MAX_96;
        4'b0011: max_length <= #`TCQ MAX_128;
        4'b0100: max_length <= #`TCQ MAX_192;
        4'b0101: max_length <= #`TCQ MAX_320;
        4'b0110: max_length <= #`TCQ MAX_576;
        4'b0111: max_length <= #`TCQ MAX_1088;
        default: max_length <= #`TCQ MAX_2176;
      endcase
    end
  end
  `endif
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_maxsize <= #`TCQ 0;
    end else if (eval_formats_i) begin
      `ifdef PCIE
      if ((max_payload_i < 3'b101) || (MPS < 4096)) begin
        malformed_maxsize <= #`TCQ ((length_i > max_length) || ~|length_i) &&
                                    has_data;
      end else begin
        malformed_maxsize <= #`TCQ 0;
      end
      `else 
      if ((!oo_i && ts_i) || (primary_pi0 && (pi_2nd_i == 0)) ||
          primary_pi4 || primary_pi5) begin
        malformed_maxsize <= #`TCQ (length_i != 1);
      end else if ((max_payload_i < 4'b1000) || (MPS < 2176)) begin
        malformed_maxsize <= #`TCQ (length_i > max_length) || ~|length_i;
      end else begin
        malformed_maxsize <= #`TCQ 0;
      end
      `endif
    end
  end
  `ifdef PCIE
  generate
    if (DW == 64) begin : word_ct_load_64
      always @* begin
        if (!eval_formats_i) begin
          word_ct_d[PLW-2:0] = word_ct[PLW-2:0];
        end else if (has_data) begin
          word_ct_d[PLW-2:0] = length_i[PLW-1:1];
        end else begin
          word_ct_d[PLW-2:0] = 0;
        end
      end
    end else begin : word_ct_load_32
      always @* begin
        if (!eval_formats_i) begin
          word_ct_d[PLW-1:0] = word_ct[PLW-1:0];
        end else if (has_data) begin
          word_ct_d[PLW-1:0] = length_i[PLW-1:0];
        end else begin
          word_ct_d[PLW-1:0] = 0;
        end
      end
    end
  endgenerate
  generate
    if (FCW == 9) begin : word_ct_max_load
      always @* begin
        if (!eval_formats_i) begin
          word_ct_d[DCW-1] = word_ct[DCW-1];
        end else begin
          word_ct_d[DCW-1] = ~|length_i && has_data;
        end
      end
    end
  endgenerate
  always @(posedge clk_i) begin
    if (reset_i) begin
      word_ct   <= #`TCQ 0;
    end else if (!delay_ct && !delay_ct_d) begin
      word_ct   <= #`TCQ word_ct_d - 1;
    end
  end
  `else 
  always @* begin
    if (sof_i) begin
      word_ct_d = WPC - 1;
    end else begin
      word_ct_d = word_ct;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      word_ct   <= #`TCQ 0;
    end else begin
      word_ct   <= #`TCQ word_ct_d + 1;
    end
  end
  `endif
  `ifdef PCIE
  always @(posedge clk_i) begin
    if (reset_i) begin
      delay_ct   <= #`TCQ 0;
      delay_ct_d <= #`TCQ 0;
    end else if (!eval_formats_i) begin
      delay_ct   <= #`TCQ delay_ct_d;
      delay_ct_d <= #`TCQ 0;
    end else if (DW == 64) begin
      case ({header_4dw,td_i,length_odd})
        3'b000:  delay_ct <= #`TCQ 0;
        3'b001:  delay_ct <= #`TCQ 0;
        3'b010:  delay_ct <= #`TCQ 0;
        3'b011:  delay_ct <= #`TCQ 1;
        3'b100:  delay_ct <= #`TCQ 0;
        3'b101:  delay_ct <= #`TCQ 1;
        3'b110:  delay_ct <= #`TCQ 1;
        default: delay_ct <= #`TCQ 1;
      endcase
      delay_ct_d <= #`TCQ 0;    
    end else begin
      case ({header_4dw,td_i})
        2'b11:   {delay_ct_d,delay_ct} <= #`TCQ 2'b10;  
        2'b00:   {delay_ct_d,delay_ct} <= #`TCQ 2'b00;  
        default: {delay_ct_d,delay_ct} <= #`TCQ 2'b01;  
      endcase
    end
  end
  assign word_ct_zero = (delay_ct ? &word_ct : ~|word_ct) && !delay_ct_d;
  assign word_ct_neg1 = &word_ct && !delay_ct && !delay_ct_d;
reg [4:0] test_temp;
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_min     <= #`TCQ 0;
    end else begin
      if (DW == 64) begin
        if (sof_i && eof_i) begin
          malformed_min <= #`TCQ 1;
        end else if (sof_q1 && eof_i) begin
          casex ({header_4dw, rem_i, td_i, has_data, length_1dw_i})
            5'b0010x:  malformed_min  <= #`TCQ 1;
            5'b10x0x:  malformed_min  <= #`TCQ 1;
            5'b1110x:  malformed_min  <= #`TCQ 1;
            5'b00x1x:  malformed_min  <= #`TCQ 1;
            5'b0xx10:  malformed_min  <= #`TCQ 1;
            5'b0x11x:  malformed_min  <= #`TCQ 1;
            5'b1xx1x:  malformed_min  <= #`TCQ 1;
            default: malformed_min  <= #`TCQ 0;
          endcase
        end else begin
          malformed_min <= #`TCQ 0;
        end
      end else begin
        if ((sof_i || sof_q1) && eof_i) begin
          malformed_min <= #`TCQ 1;
        end else if (sof_q2 && eof_i && (td_i || header_4dw || has_data)) begin
          malformed_min <= #`TCQ 1;
        end else if (sof_q3 && eof_i && td_i && header_4dw) begin
          malformed_min <= #`TCQ 1;
        end else begin
          malformed_min <= #`TCQ 0;
        end
      end
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      type_1dw      <= #`TCQ 0;
    end else if (eval_formats_i) begin
      casex (fulltype_in)
        CFGRD0, CFGWR0, CFGRD1, CFGWR1, IORD, IOWR:
          type_1dw  <= #`TCQ 1;
        default:
          type_1dw  <= #`TCQ 0;
      endcase
    end
  end
  assign malformed_1dw = type_1dw && !length_1dw_i;
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_eof <= #`TCQ 0;
    end else begin
      malformed_eof <= #`TCQ !eval_formats_i && !word_ct_zero;
    end
  end
  `endif
  `ifdef PCIE
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_over   <= #`TCQ 0;
    end else begin
      malformed_over   <= #`TCQ (word_ct_neg1 || malformed_over) &&
                                !eval_formats_i;
    end
  end
  assign expected_rem = header_4dw ^ length_odd ^ td_i;
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_rem <= #`TCQ 0;
    end else if (DW == 32) begin
      malformed_rem <= #`TCQ 0;
    end else begin
      malformed_rem <= #`TCQ rem_i ^ expected_rem;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_len <= #`TCQ 0;
    end else if (eof_q1) begin
      malformed_len <= #`TCQ malformed_eof || malformed_over ||
                             malformed_rem || malformed_min;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_o <= #`TCQ 0;
    end else if (eof_sync) begin
      malformed_o <= #`TCQ malformed_len || malformed_fmt;
    end
  end
  `else 
  reg  [WPCW-1:0] word_ct_lo_limit;
  reg  [FCW-1:0]  word_ct_hi_limit;
  wire [DCW-1:0]  word_ct_limit;
  reg  [FCW-1:0]  true_length;
  always @(posedge clk_i) begin
    if (reset_i) begin
      word_ct_lo_limit <= #`TCQ 0;
    end else if ((max_payload_i == 4'b0010) && !BVC && (MPS >= 96) &&
                 (length_i == 2)) begin
      word_ct_lo_limit <= #`TCQ WPC/2;
    end else begin
      word_ct_lo_limit <= #`TCQ 0;
    end
  end
  generate
    if (FCW == 6) begin : word_ct_limit_2176
      always @* begin
        if (~|length_i) begin   
          true_length = 34;
        end else begin
          true_length = {1'b0,length_i};
        end
      end
    end else begin : word_ct_limit_below_2176
      always @* true_length = length_i[FCW-1:0];
    end
  endgenerate
  always @(posedge clk_i) begin
    if (reset_i) begin
      word_ct_hi_limit <= #`TCQ 1;
    end else begin
      word_ct_hi_limit <= #`TCQ true_length + 1;
    end
  end
  assign word_ct_limit = {word_ct_hi_limit,word_ct_lo_limit};
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_over <= #`TCQ 0;
    end else if (eval_formats_i) begin
      malformed_over <= #`TCQ 0;
    end else begin
      malformed_over <= #`TCQ (word_ct == word_ct_limit) || malformed_over;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_byp_not_1 <= #`TCQ 0;
    end else if (eval_formats_i) begin
      malformed_byp_not_1 <= #`TCQ BVC && !oo_i && ts_i && (length_i != 1);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_pi4_or_5_not_1 <= #`TCQ 0;
    end else if (eval_formats_i) begin
      malformed_pi4_or_5_not_1 <= #`TCQ (primary_pi4 || primary_pi5) &&
                                        (length_i != 1);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      bad_credit_length_o <= #`TCQ 0;
    end else if (eof_q1) begin
      bad_credit_length_o <= #`TCQ malformed_over;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      invalid_credit_length_o <= #`TCQ 0;
    end else if (eof_q1) begin
      invalid_credit_length_o <= #`TCQ malformed_maxsize ||
                                       malformed_byp_not_1 ||
                                       malformed_pi4_or_5_not_1;
    end
  end
  `endif
  `ifdef PCIE
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_fmt <= #`TCQ 0;
    end else if (bar_sync) begin
      malformed_fmt <= #`TCQ malformed_tc ||
                             malformed_fulltype ||
                            (malformed_message && ismsgany) ||
                             malformed_maxsize ||
                             malformed_1dw;
    end
  end
  always @(posedge clk_i) begin
    if (eval_fulltype_i) begin
      fulltype_in       <= #`TCQ fulltype_i;
    end
  end
  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      msgcode_in        <= #`TCQ msgcode_i;
    end
  end
  always @(posedge clk_i) begin
    if (eval_fulltype_i) begin
      casex (fulltype_i)
        MSG: begin
          ismsg         <= #`TCQ 1;
          ismsgd        <= #`TCQ 0;
          ismsgany      <= #`TCQ 1;
        end
        MSGD: begin
          ismsg         <= #`TCQ 0;
          ismsgd        <= #`TCQ 1;
          ismsgany      <= #`TCQ 1;
        end
        default: begin
          ismsg         <= #`TCQ 0;
          ismsgd        <= #`TCQ 0;
          ismsgany      <= #`TCQ 0;
        end
      endcase
    end
  end
  always @(posedge clk_i) begin
    if (eval_fulltype_i) begin
      casex (fulltype_i)
        CFGANY, IORD, IOWR, CPLLK, CPLDLK,
        MRD32LK, MRD64LK: begin
          fulltype_tc0  <= #`TCQ 1;
        end
        default: begin
          fulltype_tc0  <= #`TCQ 0;
        end
      endcase
    end
  end
  assign msgcode_tc0 = msgcode_sigdef;
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_tc      <= #`TCQ 0;
    end else if (eval_formats_i) begin
      if (!tc0_i) begin
        malformed_tc    <= #`TCQ fulltype_tc0 || (ismsgany && msgcode_tc0);
      end else begin
        malformed_tc    <= #`TCQ 0;
      end
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_fulltype        <= #`TCQ 0;
    end else if (eval_formats_i) begin
      casex (fulltype_in)
        MWR32, MWR64, MRD32, MRD64, MRD32LK, MRD64LK,
        CFGRD0, CFGWR0, CFGRD1, CFGWR1,
        CPL, CPLD, CPLLK, CPLDLK,
        MSG, MSGD, IORD, IOWR:
          malformed_fulltype    <= #`TCQ 0;
        default:
          malformed_fulltype    <= #`TCQ 1;
      endcase
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cpl_ip            <= #`TCQ 0;
    end else if (eval_formats_i) begin
      casex (fulltype_in)
        CPL, CPLD, CPLLK, CPLDLK: begin
          cpl_ip        <= #`TCQ 1;
        end
        default: begin
          cpl_ip        <= #`TCQ 0;
        end
      endcase
    end
  end
  wire allow_legacy = legacy_mode_i || DOWNSTREAM_PORT;
  always @(posedge clk_i) begin
    if (reset_i) begin
      ur_mem_lk           <= #`TCQ 0;
      uc_cpl_lk           <= #`TCQ 0;
      ur_pwr_mgmt         <= #`TCQ 0;
      uc_pwr_mgmt         <= #`TCQ 0;
      ur_type1_cfg        <= #`TCQ 0;
    end else if (eval_formats_i) begin
      if (!allow_legacy) begin
        ur_mem_lk         <= #`TCQ (fulltype_in == MRD32LK) ||
                                   (fulltype_in == MRD64LK);
        uc_cpl_lk         <= #`TCQ (fulltype_in == CPLLK) ||
                                   (fulltype_in == CPLDLK);
      end else begin
        ur_mem_lk         <= #`TCQ 0;
        uc_cpl_lk         <= #`TCQ 0;
      end
      if (TYPE1_UR && (fulltype_in == CFGWR1 || fulltype_in == CFGRD1 ||
                       fulltype_in == CFGWR1)) begin
        ur_type1_cfg    <= #`TCQ 1'b1;
      end else begin
        ur_type1_cfg    <= #`TCQ 1'b0;
      end
      casex (fulltype_in)
        CPL, CPLD, CPLLK, CPLDLK: begin
          uc_pwr_mgmt     <= #`TCQ pwr_mgmt_on_i;
          ur_pwr_mgmt     <= #`TCQ 0;
        end
        MRD32, MRD64, MRD32LK, MRD64LK, MWR32, MWR64, IORD, IOWR: begin
          uc_pwr_mgmt     <= #`TCQ 0;
          ur_pwr_mgmt     <= #`TCQ pwr_mgmt_on_i;
        end
        CFGWR1, CFGRD1, CFGANY1: begin
          uc_pwr_mgmt     <= #`TCQ 0;
          ur_pwr_mgmt     <= #`TCQ 0;
        end
        default: begin
          uc_pwr_mgmt     <= #`TCQ 0;
          ur_pwr_mgmt     <= #`TCQ 0;
        end
     endcase
   end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      ur_format        <= #`TCQ 0;
      ur_format_lock   <= #`TCQ 0;
      uc_format        <= #`TCQ 0;
      filter_msgcode_q <= #`TCQ 0;
    end else if (bar_sync) begin
      ur_format        <= #`TCQ ur_pwr_mgmt || ur_mem_lk || ur_type1_cfg;
      ur_format_lock   <= #`TCQ ur_mem_lk; 
      uc_format        <= #`TCQ uc_pwr_mgmt || uc_cpl_lk;
      filter_msgcode_q <= #`TCQ filter_msgcode;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      tlp_ur_o            <= #`TCQ 0;
      tlp_ur_lock_o       <= #`TCQ 0;
      tlp_uc_o            <= #`TCQ 0;
      tlp_filt_o          <= #`TCQ 0;
    end else if (hit_src_rdy_i) begin
      if (ur_format) begin
        tlp_ur_o          <= #`TCQ 1;
        tlp_ur_lock_o     <= #`TCQ ur_format_lock;
      end else if (!cpl_ip && hit_ack_i && !hit_i && UPSTREAM_PORT) begin
        tlp_ur_o          <= #`TCQ 1;
        tlp_ur_lock_o     <= #`TCQ hit_lock_i;
      end else begin
        tlp_ur_o          <= #`TCQ 0;
        tlp_ur_lock_o     <= #`TCQ 0;
      end
      if (uc_format) begin
        tlp_uc_o          <= #`TCQ 1;
      end else if (cpl_ip && hit_ack_i && !hit_i && UPSTREAM_PORT) begin
        tlp_uc_o          <= #`TCQ 1;
      end else begin
        tlp_uc_o          <= #`TCQ 0;
      end
      if (filter_msgcode_q) begin
        tlp_filt_o        <= #`TCQ 1;
      end else begin
        tlp_filt_o        <= #`TCQ 0;
      end
    end
  end
  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      casex (msgcode_i)
        UNLOCK, PME_TURN_OFF, PM_ACTIVE_STATE_NAK,
        SET_SLOT_POWER_LIMIT, ATTENTION_BUTTON_PRESSED,
        ATTENTION_INDICATOR_ON, ATTENTION_INDICATOR_OFF,
        ATTENTION_INDICATOR_BLINK, POWER_INDICATOR_ON,
        POWER_INDICATOR_OFF, POWER_INDICATOR_BLINK:
          msgcode_sigdef <= #`TCQ UPSTREAM_PORT;
        ASSERT_INTA, DEASSERT_INTA, ASSERT_INTB, DEASSERT_INTB,
        ASSERT_INTC, DEASSERT_INTC, ASSERT_INTD, DEASSERT_INTD,
        ERR_COR, ERR_NONFATAL, ERR_FATAL, PME_TO_ACK:
          msgcode_sigdef <= #`TCQ DOWNSTREAM_PORT;
        default:
          msgcode_sigdef <= #`TCQ 0;
      endcase
    end
  end
  generate
    if (DW == 32) begin : msgd_check_32
      always @(posedge clk_i) begin
        if (eval_msgcode_i) begin
          casex (msgcode_i)
            SET_SLOT_POWER_LIMIT:
              msgcode_dmatch <= #`TCQ ismsgd;
            default:
              msgcode_dmatch <= #`TCQ ismsg;
          endcase
        end
      end
    end else begin : msgd_check_64
      always @(posedge clk_i) begin
        if (eval_msgcode_i) begin
          casex (fulltype_i)
            MSG:
              msgcode_dmatch <= #`TCQ (msgcode_i != SET_SLOT_POWER_LIMIT);
            default:
              msgcode_dmatch <= #`TCQ (msgcode_i == SET_SLOT_POWER_LIMIT);
          endcase
        end
      end
    end
  endgenerate
  always @(posedge clk_i) begin
    if (eval_fulltype_i) begin
      routing_vendef <= #`TCQ (routing == ROUTE_LOCAL) ||
                              (routing == ROUTE_BROAD) ||
                              (routing == ROUTE_BY_ID);
    end
  end
  generate
    if (DOWNSTREAM_PORT == 0) begin : dont_check_int
      always @(posedge clk_i) begin
        if (eval_msgcode_i) begin
          casex (msgcode_i)
            UNLOCK, PME_TURN_OFF:
              msgcode_routing <= #`TCQ ROUTE_BROAD;
            PME_TO_ACK:
              msgcode_routing <= #`TCQ ROUTE_GATHR;
            PM_ACTIVE_STATE_NAK, ATTENTION_BUTTON_PRESSED,
            ATTENTION_INDICATOR_ON, ATTENTION_INDICATOR_OFF,
            ATTENTION_INDICATOR_BLINK, POWER_INDICATOR_ON,
            POWER_INDICATOR_OFF, POWER_INDICATOR_BLINK,
            SET_SLOT_POWER_LIMIT:
              msgcode_routing <= #`TCQ ROUTE_LOCAL;
            default:
              msgcode_routing <= #`TCQ ROUTE_TO_RC;
          endcase
        end
      end
    end else begin : check_int
      always @(posedge clk_i) begin
        if (eval_msgcode_i) begin
          casex (msgcode_i)
            UNLOCK, PME_TURN_OFF:
              msgcode_routing <= #`TCQ ROUTE_BROAD;
            PME_TO_ACK:
              msgcode_routing <= #`TCQ ROUTE_GATHR;
            PM_ACTIVE_STATE_NAK, ATTENTION_BUTTON_PRESSED,
            ATTENTION_INDICATOR_ON, ATTENTION_INDICATOR_OFF,
            ATTENTION_INDICATOR_BLINK, POWER_INDICATOR_ON,
            POWER_INDICATOR_OFF, POWER_INDICATOR_BLINK,
            ASSERT_INTA, ASSERT_INTB, ASSERT_INTC, ASSERT_INTD,
            DEASSERT_INTA, DEASSERT_INTB, DEASSERT_INTC, DEASSERT_INTD,
            SET_SLOT_POWER_LIMIT:
              msgcode_routing <= #`TCQ ROUTE_LOCAL;
            default:
              msgcode_routing <= #`TCQ ROUTE_TO_RC;
          endcase
        end
      end
    end
  endgenerate
  always @(posedge clk_i) begin
    if (reset_i) begin
      malformed_message   <= #`TCQ 0;
    end else if (eval_formats_i) begin
      if (!msgcode_vendef) begin
        malformed_message <= #`TCQ !msgcode_sigdef ||                     
                                   !msgcode_dmatch ||                     
                                   (routing_in != msgcode_routing);       
      end else begin
        malformed_message <= #`TCQ !routing_vendef &&                     
                                   !(DOWNSTREAM_PORT &&
                                     (routing_in == ROUTE_TO_RC));
      end
    end
  end
  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      casex (msgcode_i)
        UNLOCK:
          msgcode_legacy        <= #`TCQ 1;
        default:
          msgcode_legacy        <= #`TCQ 0;
      endcase
    end
  end
  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      casex (msgcode_i)
        POWER_INDICATOR_ON, POWER_INDICATOR_OFF,
        POWER_INDICATOR_BLINK, ATTENTION_INDICATOR_ON,
        ATTENTION_INDICATOR_OFF, ATTENTION_INDICATOR_BLINK,
        ATTENTION_BUTTON_PRESSED:
          msgcode_hotplug       <= #`TCQ 1;
        default:
          msgcode_hotplug       <= #`TCQ 0;
      endcase
    end
  end
  always @(posedge clk_i) begin
    if (eval_msgcode_i) begin
      casex (msgcode_i)
        VENDOR_DEFINED_TYPE_0, VENDOR_DEFINED_TYPE_1:
          msgcode_vendef        <= #`TCQ 1;
        default:
          msgcode_vendef        <= #`TCQ 0;
      endcase
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      filter_msgcode            <= #`TCQ 0;
    end else if (eval_formats_i) begin
      if (ismsgany) begin
        filter_msgcode          <= #`TCQ !allow_legacy && msgcode_legacy;
      end else begin    
        filter_msgcode          <= #`TCQ 0;
      end
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cfg0_ip <= #`TCQ 0;
      cfg1_ip <= #`TCQ 0;
    end else if (eval_formats_i) begin
      casex (fulltype_in)
        CFGANY0: cfg0_ip <= #`TCQ 1;
        default: cfg0_ip <= #`TCQ 0;
      endcase
      casex (fulltype_in)
        CFGANY1: cfg1_ip <= #`TCQ 1;
        default: cfg1_ip <= #`TCQ 0;
      endcase
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      is_usr_leg_ap <= #`TCQ 0;
    end else if (load_aperture_i) begin
      is_usr_leg_ap <= #`TCQ (aperture_i == 0) && (offset_i[7:6] == 3) &&
                             legacy_cfg_access_i;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      is_usr_ext_ap <= #`TCQ 0;
    end else if (load_aperture_i) begin
      is_usr_ext_ap <= #`TCQ |aperture_i[3:2] && ext_cfg_access_i;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      load_aperture_q <= #`TCQ 0;
    end else begin
      load_aperture_q <= #`TCQ load_aperture_i;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cfg_o <= #`TCQ 0;
    end else if (load_aperture_q) begin
      cfg_o <= #`TCQ cfg1_ip || (cfg0_ip && !is_usr_leg_ap && !is_usr_ext_ap);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      hp_msg_detect_o <= #`TCQ 0;
    end else if (eval_formats_q) begin
      hp_msg_detect_o <= #`TCQ ismsgany && msgcode_hotplug;
    end
  end
  `else 
  assign load_pi_1st = load_pi_1st_i;
  assign load_pi_2nd = load_pi_2nd_i && (pi_1st <= 2);
  assign load_pi_3rd = load_pi_3rd_i && ((DW == 64) ?
                                         ((pi_2nd_i == 1) || (pi_2nd_i == 2)) :
                                         ((pi_2nd   == 1) || (pi_2nd   == 2)));
  assign load_pi_4th = load_pi_4th_i && (pi_3rd_i <= 2);
  always @(posedge clk_i) begin
    if (sof_i) begin
      pi_1st <= #`TCQ load_pi_1st ? pi_1st_i : 0;
      pi_2nd <= #`TCQ 128;
      pi_3rd <= #`TCQ 129;
      pi_4th <= #`TCQ 130;
    end else begin
      if (load_pi_2nd) begin
        pi_2nd[7]   <= #`TCQ 0;
        pi_2nd[6:0] <= #`TCQ pi_2nd_i;
      end
      if (load_pi_3rd) begin
        pi_3rd[7]   <= #`TCQ 0;
        pi_3rd[6:0] <= #`TCQ pi_3rd_i;
      end
      if (load_pi_4th) begin
        pi_4th[7]   <= #`TCQ 0;
        pi_4th[6:0] <= #`TCQ pi_4th_i;
      end
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      primary_pi0   <= #`TCQ 0;
      primary_pi4   <= #`TCQ 0;
      primary_pi5   <= #`TCQ 0;
    end else if (load_pi_1st) begin
      primary_pi0   <= #`TCQ (pi_1st_i == 0);
      primary_pi4   <= #`TCQ (pi_1st_i == 4);
      primary_pi5   <= #`TCQ (pi_1st_i == 5);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      secondary_pi0 <= #`TCQ 0;
    end else if (load_pi_2nd) begin
      secondary_pi0 <= #`TCQ (pi_2nd_i == 0);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      pi_1st_vld <= #`TCQ 1;
      pi_2nd_vld <= #`TCQ 1;
      pi_3rd_vld <= #`TCQ 1;
      pi_4th_vld <= #`TCQ 1;
    end else begin
      pi_1st_vld <= #`TCQ (pi_1st != 3) && (pi_1st != 6) && (pi_1st != 7) &&
                          (pi_1st != 127);
      pi_2nd_vld <= #`TCQ ((pi_2nd <= 2) || (pi_2nd >= 8)) && (pi_2nd != 127);
      pi_3rd_vld <= #`TCQ ((pi_2nd == 2) || (pi_2nd >= 8)) && (pi_3rd != 127);
      pi_4th_vld <= #`TCQ (pi_4th >= 8) && (pi_4th != 127);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      pi_2nd_seq_vld <= #`TCQ 1;
      pi_3rd_seq_vld <= #`TCQ 1;
      pi_4th_seq_vld <= #`TCQ 1;
    end else begin
      pi_2nd_seq_vld <= #`TCQ !((pi_1st < 4) && pi_2nd[7]) &&
                                (pi_2nd > pi_1st);
      pi_3rd_seq_vld <= #`TCQ !(((pi_2nd > 0) || (pi_2nd < 4)) && pi_3rd[7]) &&
                                 (pi_3rd > pi_2nd);
      pi_4th_seq_vld <= #`TCQ !(((pi_3rd > 0) || (pi_3rd < 4)) && pi_4th[7]) &&
                                 (pi_4th > pi_3rd);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      bad_pi_chain_o <= #`TCQ 1;
    end else if (eof_q1) begin
      bad_pi_chain_o <= #`TCQ !pi_1st_vld || !pi_2nd_vld ||
                              !pi_3rd_vld || !pi_4th_vld ||
                              !pi_2nd_seq_vld || !pi_3rd_seq_vld ||
                              !pi_4th_seq_vld;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      non_zero_turn_pointer_o <= #`TCQ 0;
    end else if (eval_formats_i) begin
      non_zero_turn_pointer_o <= #`TCQ !dir_i && !switch_mode_i &&
                                       (pi_1st != 0) && (turn_pointer_i != 0);
    end
  end
  tlm_hcrc hcrc
   (.d_i        (route_header_i[50:0]),
    .hcrc_o     (header_crc_d));
  tlm_hcrc hcrc_pb
   (.d_i        ({route_header_i[50:32],32'b0}),
    .hcrc_o     (header_crc_pb_d));
  always @(posedge clk_i) begin
    if (reset_i) begin
      path_build    <= #`TCQ 0;
    end else if (eval_formats_i) begin
      path_build    <= #`TCQ (pi_1st == 0);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      header_crc    <= #`TCQ 0;
      header_crc_pb <= #`TCQ 0;
    end else if (eval_formats_i) begin
      header_crc    <= #`TCQ header_crc_d;
      header_crc_pb <= #`TCQ header_crc_pb_d;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      bad_header_crc_o <= #`TCQ 0;
    end else if (eof_q1) begin
      bad_header_crc_o <= #`TCQ (hcrc_i !=
                                 (path_build ? header_crc_pb : header_crc));
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      unsup_ovc_o <= #`TCQ 0;
    end else if (eval_formats_i) begin
      unsup_ovc_o <= #`TCQ oo_i && BVC;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      unsup_mvc_o <= #`TCQ 0;
    end else if (eof_q1) begin
      unsup_mvc_o <= #`TCQ primary_pi0 && (pi_2nd != 0) && !MVC;
    end
  end
  localparam [1:0] DL_INACTIVE  = 2'b00;
  localparam [1:0] DL_INIT      = 2'b01;
  localparam [1:0] DL_PROTECTED = 2'b10;
  localparam [1:0] DL_ACTIVE    = 2'b11;
  always @(posedge clk_i) begin
    if (reset_i) begin
      packet_ip <= #`TCQ 0;
    end else if (sof_i) begin
      packet_ip <= #`TCQ 1;
    end else if (eof_i) begin
      packet_ip <= #`TCQ 0;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      lnk_state_d <= #`TCQ DL_INACTIVE;
    end else if (lnk_state_src_rdy_i) begin
      lnk_state_d <= #`TCQ lnk_state_i;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      lnk_state <= #`TCQ DL_INACTIVE;
    end else if (!packet_ip) begin
      lnk_state <= #`TCQ lnk_state_d;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      packet_keep <= #`TCQ 1'b1;
    end else if (eof_q1) begin
      case (lnk_state)
        DL_INACTIVE:  packet_keep <= #`TCQ  (pi_1st == 0) && (pi_2nd == 0);
        DL_INIT:      packet_keep <= #`TCQ  (pi_1st == 0) && (pi_2nd == 0);
        DL_PROTECTED: packet_keep <= #`TCQ ((pi_1st == 0) && (pi_2nd == 0)) ||
                                            (pi_1st == 4) || (pi_1st == 5);
        DL_ACTIVE:    packet_keep <= #`TCQ  1'b1;
      endcase
    end
  end
  assign filter_drop_o = !packet_keep;
  always @(posedge clk_i) begin
    if (reset_i) begin
      pi4_ap0   <= #`TCQ 1'b0;
      pi4_ap1   <= #`TCQ 1'b0;
    end else if (load_aperture_i) begin
      pi4_ap0   <= #`TCQ primary_pi4 && (aperture_i == 0);
      pi4_ap1   <= #`TCQ primary_pi4 && (aperture_i == 1);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      in_ap0_range  <= #`TCQ 0;
      in_ap1_range  <= #`TCQ 0;
    end else if (load_offset_i) begin
      in_ap0_range  <= #`TCQ (offset_i <  cmm_ap0_space_end_i);
      in_ap1_range  <= #`TCQ (offset_i >= cmm_ap1_space_start_i) &&
                             (offset_i <  cmm_ap1_space_end_i);
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      load_offset_q <= #`TCQ 0;
    end else begin
      load_offset_q <= #`TCQ load_offset_i;
    end
  end
  always @(posedge clk_i) begin
    if (reset_i) begin
      cfg_o <= #`TCQ 0;
    end else if (load_offset_q) begin
      cfg_o <= #`TCQ (primary_pi0 && secondary_pi0 &&
                      !fabric_manager_mode_i) ||
                     (pi4_ap0 && in_ap0_range) ||
                     (pi4_ap1 && in_ap1_range);
    end
  end
  `endif
  always @(posedge clk_i) begin
    if (reset_i) begin
      `ifdef PCIE
      sof_q1          <= #`TCQ 0;
      sof_q2          <= #`TCQ 0;
      sof_q3          <= #`TCQ 0;
      sof_q4          <= #`TCQ 0;
      eof_q2          <= #`TCQ 0;
      eof_q3          <= #`TCQ 0;
      eval_formats_q  <= #`TCQ 0;
      eval_formats_q2 <= #`TCQ 0;
      `endif
      eof_q1          <= #`TCQ 0;
    end else begin
      `ifdef PCIE
      sof_q1          <= #`TCQ sof_i;
      sof_q2          <= #`TCQ sof_q1;
      sof_q3          <= #`TCQ sof_q2;
      sof_q4          <= #`TCQ sof_q3;
      eof_q2          <= #`TCQ eof_q1;
      eof_q3          <= #`TCQ eof_q2;
      eval_formats_q  <= #`TCQ eval_formats_i;
      eval_formats_q2 <= #`TCQ eval_formats_q;
      `endif
      eof_q1          <= #`TCQ eof_i;
    end
  end
endmodule
