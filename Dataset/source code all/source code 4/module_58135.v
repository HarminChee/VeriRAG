module reset_logic
(
   L0DLUPDOWN,
   GSR,
   CRMCORECLK,
   USERCLK,
   L0LTSSMSTATE,
   L0STATSCFGTRANSMITTED,
   CRMDOHOTRESETN,
   CRMPWRSOFTRESETN,
   CRMMGMTRSTN,
   CRMNVRSTN,
   CRMMACRSTN,
   CRMLINKRSTN,
   CRMURSTN,
   CRMUSERCFGRSTN,
   user_master_reset_n,
   clock_ready
);
input L0DLUPDOWN;
input GSR;
input CRMCORECLK;
input USERCLK;
input [3:0] L0LTSSMSTATE;
input L0STATSCFGTRANSMITTED;
input CRMDOHOTRESETN;
input CRMPWRSOFTRESETN;
output CRMMGMTRSTN;
output CRMNVRSTN;
output CRMMACRSTN;
output CRMLINKRSTN;
output CRMURSTN;
output CRMUSERCFGRSTN;
input user_master_reset_n;
input clock_ready;
parameter G_RESETMODE = "FALSE";
parameter G_RESETSUBMODE = 1;
parameter G_USE_EXTRA_REG = 1;
wire fpga_logic_reset_n;
assign fpga_logic_reset_n = ~GSR && user_master_reset_n;
reg dl_down_1, dl_down_2;
reg dl_down_reset_1_n, dl_down_reset_2_n;
reg dl_down_reset_n;
reg crm_pwr_soft_reset_n_aftersentcpl;
reg softreset_wait_for_cpl;
reg crmpwrsoftresetn_d;
reg l0statscfgtransmitted_d;
wire crmpwrsoftresetn_fell;
always @ (posedge CRMCORECLK, negedge fpga_logic_reset_n)
   if (!fpga_logic_reset_n) begin
        dl_down_1 <= 1'b1;
        dl_down_2 <= 1'b1;
   end else begin
        dl_down_1 <= L0DLUPDOWN;
        dl_down_2 <= dl_down_1;
   end
always @ (posedge CRMCORECLK, negedge fpga_logic_reset_n)
   if (!fpga_logic_reset_n) begin
        dl_down_reset_1_n <= 1'b1;
        dl_down_reset_2_n <= 1'b1;
        dl_down_reset_n <= 1'b1;
   end else begin
        dl_down_reset_1_n <= ~(~dl_down_1 & dl_down_2);
        dl_down_reset_2_n <= dl_down_reset_1_n;
        dl_down_reset_n <= dl_down_reset_1_n && dl_down_reset_2_n;
   end
always @ (posedge USERCLK, negedge fpga_logic_reset_n)
   if      (!fpga_logic_reset_n)
        softreset_wait_for_cpl <= 1'b0;
   else if (crmpwrsoftresetn_fell && !L0STATSCFGTRANSMITTED && !l0statscfgtransmitted_d)
        softreset_wait_for_cpl <= 1'b1;
   else if (L0STATSCFGTRANSMITTED)
        softreset_wait_for_cpl <= 1'b0;
always @ (posedge USERCLK, negedge fpga_logic_reset_n)
   if      (!fpga_logic_reset_n) begin
        crm_pwr_soft_reset_n_aftersentcpl <= 1'b1;
        crmpwrsoftresetn_d                <= 1'b1;
        l0statscfgtransmitted_d           <= 1'b0;
   end else begin
        crm_pwr_soft_reset_n_aftersentcpl <= !((softreset_wait_for_cpl && L0STATSCFGTRANSMITTED) || 
                                               (!CRMPWRSOFTRESETN      && L0STATSCFGTRANSMITTED) ||
                                               (!CRMPWRSOFTRESETN      && l0statscfgtransmitted_d));
        crmpwrsoftresetn_d                <= CRMPWRSOFTRESETN;
        l0statscfgtransmitted_d           <= L0STATSCFGTRANSMITTED;
   end
assign crmpwrsoftresetn_fell = !CRMPWRSOFTRESETN && crmpwrsoftresetn_d;
generate 
  if (G_RESETMODE == "TRUE") begin : resetmode_true
     if (G_RESETSUBMODE == 0) begin : sub_0_mode_true
       assign CRMMGMTRSTN = clock_ready && user_master_reset_n;
       assign CRMNVRSTN = 1'b1;
       assign CRMMACRSTN = 1'b1;
       assign CRMLINKRSTN = dl_down_reset_n && CRMDOHOTRESETN;
       assign CRMURSTN = dl_down_reset_n && CRMDOHOTRESETN;
       assign CRMUSERCFGRSTN = dl_down_reset_n && CRMDOHOTRESETN && crm_pwr_soft_reset_n_aftersentcpl;
     end
     else begin : sub_1_mode_true
       assign CRMMGMTRSTN = clock_ready;
       assign CRMNVRSTN = user_master_reset_n;
       assign CRMMACRSTN = user_master_reset_n;
       assign CRMLINKRSTN = user_master_reset_n && dl_down_reset_n && CRMDOHOTRESETN;
       assign CRMURSTN = user_master_reset_n && dl_down_reset_n && CRMDOHOTRESETN;
       assign CRMUSERCFGRSTN = user_master_reset_n && dl_down_reset_n && CRMDOHOTRESETN && crm_pwr_soft_reset_n_aftersentcpl;
     end
  end
endgenerate
generate 
  if (G_RESETMODE == "FALSE") begin : resetmode_false
    wire ltssm_linkdown_hot_reset_n;
    reg ltssm_dl_down_last_state;
    reg [3:0] ltssm_capture;
    reg crmpwrsoftresetn_capture;
    reg ltssm_linkdown_hot_reset_reg_n;
    always @ (posedge CRMCORECLK) begin
       ltssm_capture <= L0LTSSMSTATE;
       crmpwrsoftresetn_capture <= crm_pwr_soft_reset_n_aftersentcpl;
       ltssm_linkdown_hot_reset_reg_n <= ltssm_linkdown_hot_reset_n;
    end
    always @ (posedge CRMCORECLK, negedge fpga_logic_reset_n) begin
       if (G_USE_EXTRA_REG == 1) begin
          if (!fpga_logic_reset_n) begin
               ltssm_dl_down_last_state <= 1'b0;
          end else if ((ltssm_capture == 4'b1010) || (ltssm_capture == 4'b1001) || (ltssm_capture == 4'b1011) ||
                       (ltssm_capture == 4'b1100) || (ltssm_capture == 4'b0011)) begin
               ltssm_dl_down_last_state <= 1'b1;
          end else begin
               ltssm_dl_down_last_state <= 1'b0;
          end
       end else begin
          if (!fpga_logic_reset_n) begin
               ltssm_dl_down_last_state <= 1'b0;
          end else if ((L0LTSSMSTATE == 4'b1010) || (L0LTSSMSTATE == 4'b1001) || (L0LTSSMSTATE == 4'b1011) ||
                       (L0LTSSMSTATE == 4'b1100) || (L0LTSSMSTATE == 4'b0011)) begin
               ltssm_dl_down_last_state <= 1'b1;
          end else begin
               ltssm_dl_down_last_state <= 1'b0;
          end
       end
    end
    assign ltssm_linkdown_hot_reset_n = (G_USE_EXTRA_REG == 1) ? 
         ~(ltssm_dl_down_last_state && (ltssm_capture[3:1] == 3'b000)) :
         ~(ltssm_dl_down_last_state && (L0LTSSMSTATE[3:1] == 3'b000));
      if (G_RESETSUBMODE == 0) begin : sub_0_mode_false
         assign CRMMGMTRSTN = clock_ready && user_master_reset_n;
         assign CRMNVRSTN = 1'b1;
         assign CRMURSTN = (G_USE_EXTRA_REG == 1) ? ltssm_linkdown_hot_reset_reg_n : ltssm_linkdown_hot_reset_n;
         assign CRMUSERCFGRSTN = (G_USE_EXTRA_REG == 1) ? crmpwrsoftresetn_capture : crm_pwr_soft_reset_n_aftersentcpl;
         assign CRMMACRSTN = 1'b1;  
         assign CRMLINKRSTN = 1'b1; 
      end
      else begin : sub_1_mode_false
         assign CRMMGMTRSTN = clock_ready;
         assign CRMNVRSTN = user_master_reset_n;
         assign CRMURSTN = (G_USE_EXTRA_REG == 1) ? ltssm_linkdown_hot_reset_reg_n : ltssm_linkdown_hot_reset_n;
         assign CRMUSERCFGRSTN = (G_USE_EXTRA_REG == 1) ? crmpwrsoftresetn_capture : crm_pwr_soft_reset_n_aftersentcpl;
         assign CRMMACRSTN = 1'b1;  
         assign CRMLINKRSTN = 1'b1; 
      end
  end
endgenerate
endmodule
