`timescale 1ns/1ns
`ifndef Tcq
  `define Tcq 1 
`endif
`timescale 1ns/1ns
`ifndef Tcq
  `define Tcq 1 
`endif
module pcie_blk_cf_arb
(
       input wire         clk,
       input wire         rst_n,
       input        [7:0] cfg_bus_number,
       input        [4:0] cfg_device_number,
       input        [2:0] cfg_function_number,
       input       [15:0] msi_data,
       input       [31:0] msi_laddr,
       input       [31:0] msi_haddr,
       input              send_cor,
       input              send_nfl,
       input              send_ftl,
       input              send_cplt,
       input              send_cplu,
       input       [49:0] cmt_rd_hdr,
       input       [49:0] cfg_rd_hdr,
       output reg  [49:0] request_data = 0,
       output reg         grant        = 0,
       output reg         cs_is_cplu   = 0,
       output reg         cs_is_cplt   = 0,
       output reg         cs_is_cor    = 0,
       output reg         cs_is_nfl    = 0,
       output reg         cs_is_ftl    = 0,
       output reg         cs_is_pm     = 0,
       input              send_pmeack,
       output reg         cs_is_intr   = 0,
       input        [7:0] intr_vector,
       input        [1:0] intr_req_type,
       input              intr_req_valid,
       output reg  [63:0] cfg_arb_td   = 0,
       output reg   [7:0] cfg_arb_trem_n = 1,
       output reg         cfg_arb_tsof_n = 1,
       output reg         cfg_arb_teof_n = 1,
       output reg         cfg_arb_tsrc_rdy_n = 1,
       input              cfg_arb_tdst_rdy_n
); 
  reg     [3:0] cs_fsm;  
  reg     [1:0] state;
parameter [3:0] st_reset       = 0,
                st_clear_count = 9,  
                st_clear_send  = 10, 
                st_cleared_all = 11, 
                st_cplu_req    = 1,
                st_cplt_req    = 2,
                st_ftl_req     = 3,
                st_nfl_req     = 4,
                st_cor_req     = 5,
                st_send_pm     = 6,
                st_send_msi_32 = 7,
                st_send_msi_64 = 8,
                st_code_send_asrt = 12,
                st_code_send_d_asrt = 13;
parameter type_msg_intr = 5'b10100;
parameter           UR                                      = 1'b0;
parameter           CA                                      = 1'b1;
parameter           LOCK                                    = 1'b0;
parameter           rsvd_BYTE0                              = 1'b0;
parameter           fmt_mwr_3dwhdr_data                     = 2'b10;
parameter           fmt_mwr_4dwhdr_data                     = 2'b11; 
parameter           fmt_msg                                 = 2'b01;        
parameter           fmt_cpl                                 = 2'b00;        
parameter           type_mwr                                = 5'b0_0000;  
parameter           type_msg                                = 5'b1_0000;    
parameter           type_cpl                                = 5'b0_1010;    
parameter           type_cpllock                            = 5'b0_1011;
parameter           rsvd_msb_BYTE1                          = 1'b0;
parameter           tc_param                                = 3'b000;
parameter           rsvd_BYTE1                              = 4'b0000;
parameter           td                                      = 1'b0;
parameter           ep                                      = 1'b0;
parameter           attr_param                              = 2'b00;
parameter           rsvd_BYTE2                              = 2'b00;
parameter           len_98                                  = 2'b00;
parameter           len_70_BYTE3                            = 8'b0000_0000;
parameter           len_70_mwrd_BYTE3                       = 8'b0000_0001;
wire      [7:0]     completer_id_BYTE4                      = cfg_bus_number[7:0];
wire      [7:0]     completer_id_BYTE5                      = {cfg_device_number[4:0],cfg_function_number[2:0]};
parameter           compl_status_sc                         = 3'b000;
parameter           compl_status_ur                         = 3'b001;
parameter           compl_status_ca                         = 3'b100;
parameter           bcm                                     = 1'b0;
parameter           msg_code_err_cor_BYTE7                  = 8'b0011_0000; 
parameter           msg_code_err_nfl_BYTE7                  = 8'b0011_0001; 
parameter           msg_code_err_ftl_BYTE7                  = 8'b0011_0011; 
parameter           rsvd_BYTE11                             = 1'b0;
parameter           msg_code_pm_pme_BYTE7                   = 8'b0001_1000; 
parameter           msg_code_pme_to_ack_BYTE7               = 8'b0001_1011; 
parameter           type_msg_pme_to_ack                     = 5'b1_0101; 
parameter           last_dw_byte_enable_BYTE7               = 4'b0000;
parameter           first_dw_byte_enable_BYTE7              = 4'b1111;
parameter           msg_code_asrt_inta_BYTE7                = 8'b0010_0000;
parameter           msg_code_asrt_intb_BYTE7                = 8'b0010_0001;
parameter           msg_code_asrt_intc_BYTE7                = 8'b0010_0010;
parameter           msg_code_asrt_intd_BYTE7                = 8'b0010_0011;
parameter           msg_code_d_asrt_inta_BYTE7              = 8'b0010_0100;
parameter           msg_code_d_asrt_intb_BYTE7              = 8'b0010_0101;
parameter           msg_code_d_asrt_intc_BYTE7              = 8'b0010_0110;
parameter           msg_code_d_asrt_intd_BYTE7              = 8'b0010_0111;
wire     [31:0]     swizzle_msi_data                        = { intr_vector[7:0]    
                                                               ,msi_data[15:8]   
                                                               ,8'h0             
                                                               ,8'h0             
                                                               };
reg   [7:0] byte_00, byte_01, byte_02, byte_03, 
            byte_04, byte_05, byte_06, byte_07,
            byte_08, byte_09, byte_10, byte_11;
reg  [31:0] bytes_12_to_15 = 0;
reg         reg_req_pkt_tx = 0;
reg   [1:0] wait_cntr      = 0;
  always @(posedge clk) begin
    if (~rst_n) begin
      cs_fsm            <= #`Tcq 4'b0000;
      request_data      <= #`Tcq 0;
      cs_is_cplu        <= #`Tcq 1'b0;
      cs_is_cplt        <= #`Tcq 1'b0;
      cs_is_cor         <= #`Tcq 1'b0;
      cs_is_nfl         <= #`Tcq 1'b0;
      cs_is_ftl         <= #`Tcq 1'b0;
      cs_is_pm          <= #`Tcq 1'b0;
      cs_is_intr        <= #`Tcq 1'b0;
      byte_00           <= #`Tcq 0;
      byte_01           <= #`Tcq 0;
      byte_02           <= #`Tcq 0;
      byte_03           <= #`Tcq 0;
      byte_04           <= #`Tcq 0;
      byte_05           <= #`Tcq 0;
      byte_06           <= #`Tcq 0;
      byte_07           <= #`Tcq 0;
      byte_08           <= #`Tcq 0;
      byte_09           <= #`Tcq 0;
      byte_10           <= #`Tcq 0;
      byte_11           <= #`Tcq 0;
      bytes_12_to_15    <= #`Tcq 0;
      reg_req_pkt_tx    <= #`Tcq 1'b0;
    end
    else begin
      case (cs_fsm) 
        st_reset: begin
            if (send_cplu)
              cs_fsm            <= #`Tcq st_cplu_req;
            else if (send_cplt)
              cs_fsm            <= #`Tcq st_cplt_req;
            else if (send_ftl)
              cs_fsm            <= #`Tcq st_ftl_req;
            else if (send_nfl)
              cs_fsm            <= #`Tcq st_nfl_req;
            else if (send_cor)
              cs_fsm            <= #`Tcq st_cor_req;
            else if (send_pmeack)
              cs_fsm            <= #`Tcq st_send_pm;
            else if (intr_req_valid)
            begin
               if (intr_req_type == 2'b00) 
                  cs_fsm            <= #`Tcq st_code_send_asrt;
               else if (intr_req_type == 2'b01)
                  cs_fsm            <= #`Tcq st_code_send_d_asrt;
               else if (intr_req_type == 2'b10)
                  cs_fsm            <= #`Tcq st_send_msi_32;
               else if (intr_req_type == 2'b11)
                  cs_fsm            <= #`Tcq st_send_msi_64;
            end
            else
              cs_fsm            <= #`Tcq st_reset;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
        st_cplu_req: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_cplu_req;
            request_data      <= #`Tcq cfg_rd_hdr;
            cs_is_cplu        <= #`Tcq 1'b1;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            if (cfg_rd_hdr[49] == LOCK) begin
              byte_00           <= #`Tcq {rsvd_BYTE0,fmt_cpl,type_cpllock};
            end else begin
              byte_00           <= #`Tcq {rsvd_BYTE0,fmt_cpl,type_cpl};
            end
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_07           <= #`Tcq {cfg_rd_hdr[36:29]};
            byte_08           <= #`Tcq {cfg_rd_hdr[23:16]};
            byte_09           <= #`Tcq {cfg_rd_hdr[15:8]};
            byte_10           <= #`Tcq cfg_rd_hdr[7:0];
            byte_11           <= #`Tcq {rsvd_BYTE11,cfg_rd_hdr[47:41]};
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
            if (cfg_rd_hdr[48] == UR) begin
              byte_01           <= #`Tcq {rsvd_msb_BYTE1,cfg_rd_hdr[28:26],rsvd_BYTE1};
              byte_02           <= #`Tcq {td,ep,cfg_rd_hdr[25:24],rsvd_BYTE2,len_98};
              byte_06           <= #`Tcq {compl_status_ur,bcm,cfg_rd_hdr[40:37]}; 
            end else begin     
              byte_01           <= #`Tcq {rsvd_msb_BYTE1,cfg_rd_hdr[28:26],rsvd_BYTE1};
              byte_02           <= #`Tcq {td,ep,cfg_rd_hdr[25:24],rsvd_BYTE2,len_98};
              byte_06           <= #`Tcq {compl_status_ca,bcm,cfg_rd_hdr[40:37]}; 
            end
        end
        st_cplt_req: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_cplt_req;
            request_data      <= #`Tcq cmt_rd_hdr;
            cs_is_cplt        <= #`Tcq 1'b1;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            if (cmt_rd_hdr[49] == LOCK) begin
              byte_00           <= #`Tcq {rsvd_BYTE0,fmt_cpl,type_cpllock};
            end else begin
              byte_00           <= #`Tcq {rsvd_BYTE0,fmt_cpl,type_cpl};
            end
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_07           <= #`Tcq {cmt_rd_hdr[36:29]};
            byte_08           <= #`Tcq {cmt_rd_hdr[23:16]};
            byte_09           <= #`Tcq {cmt_rd_hdr[15:8]};
            byte_10           <= #`Tcq cmt_rd_hdr[7:0];
            byte_11           <= #`Tcq {rsvd_BYTE11,cmt_rd_hdr[47:41]};
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
            if (cmt_rd_hdr[48] == UR) begin
              byte_01           <= #`Tcq {rsvd_msb_BYTE1,cmt_rd_hdr[28:26],rsvd_BYTE1};
              byte_02           <= #`Tcq {td,ep,cmt_rd_hdr[25:24],rsvd_BYTE2,len_98};
              byte_06           <= #`Tcq {compl_status_ur,bcm,cmt_rd_hdr[40:37]}; 
            end else begin     
              byte_01           <= #`Tcq {rsvd_msb_BYTE1,cmt_rd_hdr[28:26],rsvd_BYTE1};
              byte_02           <= #`Tcq {td,ep,cmt_rd_hdr[25:24],rsvd_BYTE2,len_98};
              byte_06           <= #`Tcq {compl_status_ca,bcm,cmt_rd_hdr[40:37]}; 
            end
        end
        st_ftl_req:  begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_ftl_req;
            request_data      <= #`Tcq 0;
            cs_is_ftl         <= #`Tcq 1'b1;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {msg_code_err_ftl_BYTE7};
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end
        st_nfl_req:  begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_nfl_req;
            request_data      <= #`Tcq 0;
            cs_is_nfl         <= #`Tcq 1'b1;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {msg_code_err_nfl_BYTE7};
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end
        st_cor_req:  begin   
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_cor_req;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b1;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {msg_code_err_cor_BYTE7};
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end
        st_send_pm: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_send_pm;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b1;
            cs_is_intr        <= #`Tcq 1'b0;
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            byte_07           <= #`Tcq {msg_code_pme_to_ack_BYTE7};
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg_pme_to_ack};
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end
        st_code_send_asrt: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_code_send_asrt;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b1;
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg_intr};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
          case (intr_vector[1:0])  
            2'b00: byte_07          <= #`Tcq {msg_code_asrt_inta_BYTE7};
            2'b01: byte_07          <= #`Tcq {msg_code_asrt_intb_BYTE7};
            2'b10: byte_07          <= #`Tcq {msg_code_asrt_intc_BYTE7};
            2'b11: byte_07          <= #`Tcq {msg_code_asrt_intd_BYTE7};
          endcase
        end
        st_code_send_d_asrt: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_code_send_d_asrt;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b1;
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_msg,type_msg_intr};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_08           <= #`Tcq 0;
            byte_09           <= #`Tcq 0;
            byte_10           <= #`Tcq 0;
            byte_11           <= #`Tcq 0;
            bytes_12_to_15    <= #`Tcq 0;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
          case (intr_vector[1:0])  
            2'b00: byte_07          <= #`Tcq {msg_code_d_asrt_inta_BYTE7};
            2'b01: byte_07          <= #`Tcq {msg_code_d_asrt_intb_BYTE7};
            2'b10: byte_07          <= #`Tcq {msg_code_d_asrt_intc_BYTE7};
            2'b11: byte_07          <= #`Tcq {msg_code_d_asrt_intd_BYTE7};
          endcase
        end
        st_send_msi_32: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_send_msi_32;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b1;
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_mwr_3dwhdr_data,type_mwr};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_mwrd_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {last_dw_byte_enable_BYTE7,first_dw_byte_enable_BYTE7};
            byte_08           <= #`Tcq msi_laddr[31:24];
            byte_09           <= #`Tcq msi_laddr[23:16];
            byte_10           <= #`Tcq msi_laddr[15:08];
            byte_11           <= #`Tcq {msi_laddr[07:02],2'b00};
            bytes_12_to_15    <= #`Tcq swizzle_msi_data;
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end      
        st_send_msi_64: begin
            if (grant)
              cs_fsm            <= #`Tcq st_clear_count;
            else
              cs_fsm            <= #`Tcq st_send_msi_64;
            request_data      <= #`Tcq 0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b1;
            byte_00           <= #`Tcq {rsvd_BYTE0,fmt_mwr_4dwhdr_data,type_mwr};
            byte_01           <= #`Tcq {rsvd_msb_BYTE1,tc_param,rsvd_BYTE1};
            byte_02           <= #`Tcq {td,ep,attr_param,rsvd_BYTE2,len_98};
            byte_03           <= #`Tcq {len_70_mwrd_BYTE3};
            byte_04           <= #`Tcq {completer_id_BYTE4};
            byte_05           <= #`Tcq {completer_id_BYTE5};
            byte_06           <= #`Tcq 8'h0;
            byte_07           <= #`Tcq {last_dw_byte_enable_BYTE7,first_dw_byte_enable_BYTE7};
            byte_08           <= #`Tcq msi_haddr[31:24];
            byte_09           <= #`Tcq msi_haddr[23:16];
            byte_10           <= #`Tcq msi_haddr[15:08];
            byte_11           <= #`Tcq msi_haddr[07:00];
            bytes_12_to_15    <= #`Tcq {msi_laddr[31:2],2'b00};
            reg_req_pkt_tx    <= #`Tcq 1'b1;
        end      
        st_clear_count: begin
            cs_fsm            <= #`Tcq st_clear_send;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
        st_clear_send: begin
            cs_fsm            <= #`Tcq st_cleared_all;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
        st_cleared_all: begin
            cs_fsm            <= #`Tcq st_reset;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
        default: begin
            cs_fsm            <= #`Tcq st_reset;
            request_data      <= #`Tcq 0;
            cs_is_cplu        <= #`Tcq 1'b0;
            cs_is_cplt        <= #`Tcq 1'b0;
            cs_is_cor         <= #`Tcq 1'b0;
            cs_is_nfl         <= #`Tcq 1'b0;
            cs_is_ftl         <= #`Tcq 1'b0;
            cs_is_pm          <= #`Tcq 1'b0;
            cs_is_intr        <= #`Tcq 1'b0;
            reg_req_pkt_tx    <= #`Tcq 1'b0;
        end
      endcase
    end
  end
  wire [159:0] tlp_data= {swizzle_msi_data,
                          bytes_12_to_15,
                          byte_08,byte_09,byte_10,byte_11,
                          byte_04,byte_05,byte_06,byte_07,
                          byte_00,byte_01,byte_02,byte_03};
  wire pkt_3dw = (tlp_data[30:29]==2'b00);  
  wire pkt_5dw = (tlp_data[30:29]==2'b11);  
  parameter TX_IDLE     = 2'b00;
  parameter TX_DW1      = 2'b01;
  parameter TX_DW3      = 2'b10;
  parameter SEND_GRANT  = 2'b11;
  always @(posedge clk)
  begin
     if (~rst_n) begin
        cfg_arb_tsof_n  <= #`Tcq 1;
        cfg_arb_teof_n  <= #`Tcq 1;
        cfg_arb_td      <= #`Tcq 64'h0000_0000;
        cfg_arb_trem_n  <= #`Tcq 8'hff;
        cfg_arb_tsrc_rdy_n <= #`Tcq 1;
        grant           <= #`Tcq 0; 
        state           <= #`Tcq TX_IDLE;
     end
     else
     case (state) 
        TX_IDLE : begin
                     grant             <= #`Tcq 0; 
                     cfg_arb_td[31:0]  <= #`Tcq tlp_data[63:32]; 
                     cfg_arb_td[63:32] <= #`Tcq tlp_data[31:0]; 
                     cfg_arb_teof_n    <= #`Tcq 1;
                     cfg_arb_trem_n    <= #`Tcq 8'h00;
                     if (reg_req_pkt_tx && (~|wait_cntr)) begin
                        cfg_arb_tsrc_rdy_n   <= #`Tcq 0;  
                        cfg_arb_tsof_n    <= #`Tcq 0;
                     end
                     else begin
                        cfg_arb_tsrc_rdy_n   <= #`Tcq 1;  
                        cfg_arb_tsof_n    <= #`Tcq 1;
                     end
                     if (reg_req_pkt_tx && (~|wait_cntr)) begin
                        state        <= #`Tcq TX_DW1;
                     end 
                  end
        TX_DW1  : begin
                     cfg_arb_tsrc_rdy_n <= #`Tcq 0;  
                     cfg_arb_trem_n     <= #`Tcq pkt_3dw ? 8'h0f : 8'h00 ;
                     if (!cfg_arb_tdst_rdy_n) begin
                        cfg_arb_td[31:0]  <= #`Tcq tlp_data[127:96]; 
                        cfg_arb_td[63:32] <= #`Tcq tlp_data[95:64]; 
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq pkt_5dw;
                        state             <= #`Tcq pkt_5dw ? TX_DW3 : SEND_GRANT;
                        grant             <= #`Tcq 0;
                     end
                     else begin
                        cfg_arb_td[31:0]  <= #`Tcq tlp_data[63:32]; 
                        cfg_arb_td[63:32] <= #`Tcq tlp_data[31:0]; 
                        cfg_arb_tsof_n    <= #`Tcq 0;
                        cfg_arb_teof_n    <= #`Tcq 1;
                        state             <= #`Tcq TX_DW1;
                        grant             <= #`Tcq 0;
                     end
                  end
        TX_DW3  : begin
                     cfg_arb_tsrc_rdy_n <= #`Tcq 0;  
                     cfg_arb_trem_n     <= #`Tcq 8'h0f;
                     if (!cfg_arb_tdst_rdy_n) begin
                        cfg_arb_td[31:0]  <= #`Tcq 32'h0; 
                        cfg_arb_td[63:32] <= #`Tcq tlp_data[159:128]; 
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq 0;
                        state             <= #`Tcq SEND_GRANT;
                        grant             <= #`Tcq 0;
                     end
                     else begin
                        cfg_arb_td[31:0]  <= #`Tcq tlp_data[127:96]; 
                        cfg_arb_td[63:32] <= #`Tcq tlp_data[95:64]; 
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq 1;
                        state             <= #`Tcq TX_DW3;
                        grant             <= #`Tcq 0;
                     end
                  end
    SEND_GRANT  : begin
                     if (!cfg_arb_tdst_rdy_n) begin
                        cfg_arb_tsrc_rdy_n<= #`Tcq 1;  
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq 1;
                        state             <= #`Tcq TX_IDLE;
                        grant             <= #`Tcq 1;
                     end
                     else begin
                        cfg_arb_tsrc_rdy_n<= #`Tcq 0;  
                        cfg_arb_tsof_n    <= #`Tcq 1;
                        cfg_arb_teof_n    <= #`Tcq 0;
                        state             <= #`Tcq SEND_GRANT;
                        grant             <= #`Tcq 0;
                     end
                  end
     endcase
  end 
  always @(posedge clk)
  begin
     if (~rst_n) begin
       wait_cntr <= #`Tcq 0;
     end else if (state == SEND_GRANT) begin
       wait_cntr <= #`Tcq 2'b10;
     end else if (|wait_cntr) begin
       wait_cntr <= #`Tcq wait_cntr - 1;
     end
  end
endmodule 
