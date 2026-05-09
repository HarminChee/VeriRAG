`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_crossbar_v2_1_9_arbiter_resp #
  (
   parameter         C_FAMILY       = "none",
   parameter integer C_NUM_S        = 4,      
   parameter integer C_NUM_S_LOG    = 2,      
   parameter integer C_GRANT_ENC    = 0,      
   parameter integer C_GRANT_HOT    = 1       
   )
  (
   input  wire                     ACLK,
   input  wire                     ARESET,
   input  wire [C_NUM_S-1:0]       S_VALID,      
   output wire [C_NUM_S-1:0]       S_READY,      
   output wire [C_NUM_S_LOG-1:0]   M_GRANT_ENC,  
   output wire [C_NUM_S-1:0]       M_GRANT_HOT,  
   output wire                     M_VALID,      
   input  wire                     M_READY
   );
  function [4:0] f_hot2enc
    (
      input [16:0]  one_hot
    );
    begin
      f_hot2enc[0] = |(one_hot & 17'b01010101010101010);
      f_hot2enc[1] = |(one_hot & 17'b01100110011001100);
      f_hot2enc[2] = |(one_hot & 17'b01111000011110000);
      f_hot2enc[3] = |(one_hot & 17'b01111111100000000);
      f_hot2enc[4] = |(one_hot & 17'b10000000000000000);
    end
  endfunction
  reg [C_NUM_S-1:0]      chosen;
  wire [C_NUM_S-1:0]     grant_hot; 
  wire                   master_selected; 
  wire                   active_master;
  wire                   need_arbitration;
  wire                   m_valid_i;
  wire [C_NUM_S-1:0]     s_ready_i;
  wire                   access_done;
  reg [C_NUM_S-1:0]      last_rr_hot;
  wire [C_NUM_S-1:0]     valid_rr;
  reg [C_NUM_S-1:0]      next_rr_hot;
  reg [C_NUM_S*C_NUM_S-1:0] carry_rr;
  reg [C_NUM_S*C_NUM_S-1:0] mask_rr;
  integer                 i;
  integer                 j;
  integer                 n;
  assign grant_hot        = chosen & S_VALID;
  assign master_selected  = |grant_hot[0+:C_NUM_S];
  assign active_master    = |S_VALID;
  assign access_done = m_valid_i & M_READY;
  assign s_ready_i = {C_NUM_S{M_READY}} & grant_hot[0+:C_NUM_S];
  assign m_valid_i = master_selected;
  assign need_arbitration = (active_master & ~master_selected) | access_done;
  assign M_VALID = m_valid_i;
  assign S_READY = s_ready_i;
  assign M_GRANT_HOT = (C_GRANT_HOT == 1) ? grant_hot[0+:C_NUM_S] : {C_NUM_S{1'b0}};
  assign M_GRANT_ENC = (C_GRANT_ENC == 1) ? f_hot2enc(grant_hot) : {C_NUM_S_LOG{1'b0}};
  always @(posedge ACLK)
    begin
      if (ARESET) begin
        chosen <= {C_NUM_S{1'b0}};
        last_rr_hot <= {1'b1, {C_NUM_S-1{1'b0}}};
      end else if (need_arbitration) begin
        chosen <= next_rr_hot;   
        if (|next_rr_hot) last_rr_hot <= next_rr_hot;
      end
    end
  assign valid_rr =  S_VALID;
  always @ * begin
    next_rr_hot = 0;
    for (i=0;i<C_NUM_S;i=i+1) begin
      n = (i>0) ? (i-1) : (C_NUM_S-1);
      carry_rr[i*C_NUM_S] = last_rr_hot[n];
      mask_rr[i*C_NUM_S] = ~valid_rr[n];
      for (j=1;j<C_NUM_S;j=j+1) begin
        n = (i-j > 0) ? (i-j-1) : (C_NUM_S+i-j-1);
        carry_rr[i*C_NUM_S+j] = carry_rr[i*C_NUM_S+j-1] | (last_rr_hot[n] & mask_rr[i*C_NUM_S+j-1]);
        if (j < C_NUM_S-1) begin
          mask_rr[i*C_NUM_S+j] = mask_rr[i*C_NUM_S+j-1] & ~valid_rr[n];
        end
      end   
      next_rr_hot[i] = valid_rr[i] & carry_rr[(i+1)*C_NUM_S-1];
    end
  end
endmodule
