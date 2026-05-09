`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_crossbar_v2_1_9_addr_arbiter #
  (
   parameter         C_FAMILY                         = "none", 
   parameter integer C_NUM_S                = 1, 
   parameter integer C_NUM_S_LOG                = 1, 
   parameter integer C_NUM_M               = 1, 
   parameter integer C_MESG_WIDTH                 = 1, 
   parameter [C_NUM_S*32-1:0] C_ARB_PRIORITY             = {C_NUM_S{32'h00000000}}
   )
  (
   input  wire                                      ACLK,
   input  wire                                      ARESET,
   input  wire [C_NUM_S*C_MESG_WIDTH-1:0]  S_MESG,
   input  wire [C_NUM_S*C_NUM_M-1:0]                S_TARGET_HOT,
   input  wire [C_NUM_S-1:0]                S_VALID,
   input  wire [C_NUM_S-1:0]                S_VALID_QUAL,
   output wire [C_NUM_S-1:0]                S_READY,
   output wire [C_MESG_WIDTH-1:0]                    M_MESG,
   output wire [C_NUM_M-1:0]                           M_TARGET_HOT,
   output wire [C_NUM_S_LOG-1:0]                      M_GRANT_ENC,
   output wire                                        M_VALID,
   input  wire                                        M_READY,
   input  wire [C_NUM_M-1:0]                ISSUING_LIMIT
   );
  function [C_NUM_S-1:0] f_prio_mask
    (
      input integer null_arg
    );
    reg   [C_NUM_S-1:0]            mask;
    integer                        i;    
    begin
      mask = 0;    
      for (i=0; i < C_NUM_S; i=i+1) begin
        mask[i] = (C_ARB_PRIORITY[i*32+:32] != 0);
      end 
      f_prio_mask = mask;
    end   
  endfunction
  function [3:0] f_hot2enc
    (
      input [15:0]  one_hot
    );
    begin
      f_hot2enc[0] = |(one_hot & 16'b1010101010101010);
      f_hot2enc[1] = |(one_hot & 16'b1100110011001100);
      f_hot2enc[2] = |(one_hot & 16'b1111000011110000);
      f_hot2enc[3] = |(one_hot & 16'b1111111100000000);
    end
  endfunction
  localparam [C_NUM_S-1:0] P_PRIO_MASK = f_prio_mask(0);
  reg                     m_valid_i;
  reg [C_NUM_S-1:0]       s_ready_i;
  reg [C_NUM_S-1:0]       qual_reg;
  reg [C_NUM_S-1:0]       grant_hot; 
  reg [C_NUM_S-1:0]       last_rr_hot;
  reg                     any_grant;
  reg                     any_prio;
  reg                     found_prio;
  reg [C_NUM_S-1:0]       which_prio_hot;
  reg [C_NUM_S-1:0]       next_prio_hot;
  reg [C_NUM_S_LOG-1:0]   which_prio_enc;          
  reg [C_NUM_S_LOG-1:0]   next_prio_enc;    
  reg [4:0]               current_highest;
  wire [C_NUM_S-1:0]      valid_rr;
  reg [15:0]              next_rr_hot;
  reg [C_NUM_S_LOG-1:0]   next_rr_enc;    
  reg [C_NUM_S*C_NUM_S-1:0] carry_rr;
  reg [C_NUM_S*C_NUM_S-1:0] mask_rr;
  reg                     found_rr;
  wire [C_NUM_S-1:0]      next_hot;
  wire [C_NUM_S_LOG-1:0]  next_enc;    
  reg                     prio_stall;
  integer                 i;
  wire [C_NUM_S-1:0]      valid_qual_i;
  reg  [C_NUM_S_LOG-1:0]  m_grant_enc_i;
  reg  [C_NUM_M-1:0]      m_target_hot_i;
  wire [C_NUM_M-1:0]      m_target_hot_mux;
  reg  [C_MESG_WIDTH-1:0] m_mesg_i;
  wire [C_MESG_WIDTH-1:0] m_mesg_mux;
  genvar                  gen_si;
  assign M_VALID = m_valid_i;
  assign S_READY = s_ready_i;
  assign M_GRANT_ENC = m_grant_enc_i;
  assign M_MESG = m_mesg_i;
  assign M_TARGET_HOT = m_target_hot_i;
  generate
    if (C_NUM_S>1) begin : gen_arbiter
      always @(posedge ACLK) begin
        if (ARESET) begin
          qual_reg <= 0;
        end else begin 
          qual_reg <= valid_qual_i | ~S_VALID; 
        end
      end
      for (gen_si=0; gen_si<C_NUM_S; gen_si=gen_si+1) begin : gen_req_qual
        assign valid_qual_i[gen_si] = S_VALID_QUAL[gen_si] & (|(S_TARGET_HOT[gen_si*C_NUM_M+:C_NUM_M] & ~ISSUING_LIMIT));
      end
      assign next_hot = found_prio ? next_prio_hot : next_rr_hot;
      assign next_enc = found_prio ? next_prio_enc : next_rr_enc;
      always @(posedge ACLK) begin
        if (ARESET) begin
          m_valid_i <= 0;
          s_ready_i <= 0;
          grant_hot <= 0;
          any_grant <= 1'b0;
          m_grant_enc_i <= 0;
          last_rr_hot <= {1'b1, {C_NUM_S-1{1'b0}}};
          m_target_hot_i <= 0;
        end else begin
          s_ready_i <= 0;
          if (m_valid_i) begin
            if (M_READY) begin  
              m_valid_i <= 1'b0;
              grant_hot <= 0;
              any_grant <= 1'b0;
            end
          end else if (any_grant) begin
            m_valid_i <= 1'b1;
            s_ready_i <= grant_hot;  
          end else begin
            if ((found_prio | found_rr) & ~prio_stall) begin
              if (|(next_hot & valid_qual_i)) begin  
                grant_hot <= next_hot;
                m_grant_enc_i <= next_enc;
                any_grant <= 1'b1;
                if (~found_prio) begin
                  last_rr_hot <= next_rr_hot;
                end
                m_target_hot_i <= m_target_hot_mux;
              end
            end
          end
        end
      end
      always @ * begin : ALG_PRIO
        integer ip;
        any_prio = 1'b0;
        prio_stall = 1'b0;
        which_prio_hot = 0;        
        which_prio_enc = 0;    
        current_highest = 0;    
        for (ip=0; ip < C_NUM_S; ip=ip+1) begin
          if (P_PRIO_MASK[ip] & S_VALID[ip] & qual_reg[ip]) begin
            if ({1'b0, C_ARB_PRIORITY[ip*32+:4]} > current_highest) begin
              current_highest[0+:4] = C_ARB_PRIORITY[ip*32+:4];
              if (s_ready_i[ip]) begin
                any_prio = 1'b0;
                prio_stall = 1'b1;
                which_prio_hot = 0;
                which_prio_enc = 0;
              end else begin
                any_prio = 1'b1;
                which_prio_hot = 1'b1 << ip;
                which_prio_enc = ip;
              end
            end
          end   
        end
        found_prio = any_prio;
        next_prio_hot = which_prio_hot;
        next_prio_enc = which_prio_enc;
      end
      assign valid_rr = ~P_PRIO_MASK & S_VALID & ~s_ready_i & qual_reg;
      always @ * begin : ALG_RR
        integer ir, jr, nr;
        next_rr_hot = 0;
        for (ir=0;ir<C_NUM_S;ir=ir+1) begin
          nr = (ir>0) ? (ir-1) : (C_NUM_S-1);
          carry_rr[ir*C_NUM_S] = last_rr_hot[nr];
          mask_rr[ir*C_NUM_S] = ~valid_rr[nr];
          for (jr=1;jr<C_NUM_S;jr=jr+1) begin
            nr = (ir-jr > 0) ? (ir-jr-1) : (C_NUM_S+ir-jr-1);
            carry_rr[ir*C_NUM_S+jr] = carry_rr[ir*C_NUM_S+jr-1] | (last_rr_hot[nr] & mask_rr[ir*C_NUM_S+jr-1]);
            if (jr < C_NUM_S-1) begin
              mask_rr[ir*C_NUM_S+jr] = mask_rr[ir*C_NUM_S+jr-1] & ~valid_rr[nr];
            end
          end   
          next_rr_hot[ir] = valid_rr[ir] & carry_rr[(ir+1)*C_NUM_S-1];
        end
        next_rr_enc = f_hot2enc(next_rr_hot);
        found_rr = |(next_rr_hot);
      end
      generic_baseblocks_v2_1_0_mux_enc # 
        (
         .C_FAMILY      ("rtl"),
         .C_RATIO       (C_NUM_S),
         .C_SEL_WIDTH   (C_NUM_S_LOG),
         .C_DATA_WIDTH  (C_MESG_WIDTH)
        ) mux_mesg 
        (
         .S   (m_grant_enc_i),
         .A   (S_MESG),
         .O   (m_mesg_mux),
         .OE  (1'b1)
        ); 
      generic_baseblocks_v2_1_0_mux_enc # 
        (
         .C_FAMILY      ("rtl"),
         .C_RATIO       (C_NUM_S),
         .C_SEL_WIDTH   (C_NUM_S_LOG),
         .C_DATA_WIDTH  (C_NUM_M)
        ) si_amesg_mux_inst 
        (
         .S   (next_enc),
         .A   (S_TARGET_HOT),
         .O   (m_target_hot_mux),
         .OE  (1'b1)
        ); 
      always @(posedge ACLK) begin
        if (ARESET) begin
          m_mesg_i <= 0;
        end else if (~m_valid_i) begin
          m_mesg_i <= m_mesg_mux;
        end
      end
    end else begin : gen_no_arbiter
      assign valid_qual_i = S_VALID_QUAL & |(S_TARGET_HOT & ~ISSUING_LIMIT);
      always @ (posedge ACLK) begin
        if (ARESET) begin
          m_valid_i <= 1'b0;
          s_ready_i <= 1'b0;
          m_grant_enc_i <= 0;
        end else begin
          s_ready_i <= 1'b0;
          if (m_valid_i) begin
            if (M_READY) begin
              m_valid_i <= 1'b0;
            end
          end else if (S_VALID[0] & valid_qual_i[0] & ~s_ready_i) begin
            m_valid_i <= 1'b1;
            s_ready_i <= 1'b1;
            m_target_hot_i <= S_TARGET_HOT;
          end
        end
      end
      always @(posedge ACLK) begin
        if (ARESET) begin
          m_mesg_i <= 0;
        end else if (~m_valid_i) begin
          m_mesg_i <= S_MESG;
        end
      end
    end  
  endgenerate
endmodule
`default_nettype wire
