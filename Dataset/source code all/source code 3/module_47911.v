module red_pitaya_ams
(
   input                 clk_i           ,  
   input                 rstn_i          ,  
   input      [  5-1: 0] vinp_i          ,  
   input      [  5-1: 0] vinn_i          ,  
   output     [ 24-1: 0] dac_a_o         ,  
   output     [ 24-1: 0] dac_b_o         ,  
   output     [ 24-1: 0] dac_c_o         ,  
   output     [ 24-1: 0] dac_d_o         ,  
   input                 sys_clk_i       ,  
   input                 sys_rstn_i      ,  
   input      [ 32-1: 0] sys_addr_i      ,  
   input      [ 32-1: 0] sys_wdata_i     ,  
   input      [  4-1: 0] sys_sel_i       ,  
   input                 sys_wen_i       ,  
   input                 sys_ren_i       ,  
   output     [ 32-1: 0] sys_rdata_o     ,  
   output                sys_err_o       ,  
   output                sys_ack_o          
);
wire  [ 32-1: 0] addr         ;
wire  [ 32-1: 0] wdata        ;
wire             wen          ;
wire             ren          ;
reg   [ 32-1: 0] rdata        ;
reg              err          ;
reg              ack          ;
reg   [ 12-1: 0] adc_a_r      ;
reg   [ 12-1: 0] adc_b_r      ;
reg   [ 12-1: 0] adc_c_r      ;
reg   [ 12-1: 0] adc_d_r      ;
reg   [ 12-1: 0] adc_v_r      ;
reg   [ 12-1: 0] adc_temp_r   ;
reg   [ 12-1: 0] adc_pint_r   ;
reg   [ 12-1: 0] adc_paux_r   ;
reg   [ 12-1: 0] adc_bram_r   ;
reg   [ 12-1: 0] adc_int_r    ;
reg   [ 12-1: 0] adc_aux_r    ;
reg   [ 12-1: 0] adc_ddr_r    ;
reg   [ 24-1: 0] dac_a_r      ;
reg   [ 24-1: 0] dac_b_r      ;
reg   [ 24-1: 0] dac_c_r      ;
reg   [ 24-1: 0] dac_d_r      ;
always @(posedge clk_i) begin
   if (rstn_i == 1'b0) begin
      dac_a_r     <= 24'h0F_0000 ;
      dac_b_r     <= 24'h4E_0000 ;
      dac_c_r     <= 24'h75_0000 ;
      dac_d_r     <= 24'h9C_0000 ;
   end
   else begin
      if (wen) begin
         if (addr[19:0]==16'h20)   dac_a_r <= wdata[24-1: 0] ;
         if (addr[19:0]==16'h24)   dac_b_r <= wdata[24-1: 0] ;
         if (addr[19:0]==16'h28)   dac_c_r <= wdata[24-1: 0] ;
         if (addr[19:0]==16'h2C)   dac_d_r <= wdata[24-1: 0] ;
      end
   end
end
always @(posedge clk_i) begin
   err <= 1'b0 ;
   casez (addr[19:0])
     20'h00000 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_a_r}          ; end
     20'h00004 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_b_r}          ; end
     20'h00008 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_c_r}          ; end
     20'h0000C : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_d_r}          ; end
     20'h00010 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_v_r}          ; end
     20'h00020 : begin ack <= 1'b1;         rdata <= {{32-24{1'b0}}, dac_a_r}          ; end
     20'h00024 : begin ack <= 1'b1;         rdata <= {{32-24{1'b0}}, dac_b_r}          ; end
     20'h00028 : begin ack <= 1'b1;         rdata <= {{32-24{1'b0}}, dac_c_r}          ; end
     20'h0002C : begin ack <= 1'b1;         rdata <= {{32-24{1'b0}}, dac_d_r}          ; end
     20'h00030 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_temp_r}       ; end
     20'h00034 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_pint_r}       ; end
     20'h00038 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_paux_r}       ; end
     20'h0003C : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_bram_r}       ; end
     20'h00040 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_int_r}        ; end
     20'h00044 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_aux_r}        ; end
     20'h00048 : begin ack <= 1'b1;         rdata <= {{32-12{1'b0}}, adc_ddr_r}        ; end
       default : begin ack <= 1'b1;         rdata <=   32'h0                           ; end
   endcase
end
assign dac_a_o = dac_a_r ;
assign dac_b_o = dac_b_r ;
assign dac_c_o = dac_c_r ;
assign dac_d_o = dac_d_r ;
wire [ 8-1: 0] xadc_alarm     ;
wire           xadc_busy      ;
wire [ 5-1: 0] xadc_channel   ;
wire           xadc_eoc       ;
wire           xadc_eos       ;
wire [17-1: 0] xadc_vinn      ;
wire [17-1: 0] xadc_vinp      ;
wire           xadc_reset     = rstn_i ;
wire [16-1: 0] xadc_drp_dato  ;
wire           xadc_drp_drdy  ;
wire [ 7-1: 0] xadc_drp_addr  = {2'h0, xadc_channel};
wire           xadc_drp_clk   = clk_i     ;
wire           xadc_drp_en    = xadc_eoc  ;
wire [16-1: 0] xadc_drp_dati  = 16'h0     ;
wire           xadc_drp_we    =  1'b0     ;
assign xadc_vinn = {vinn_i[4], 6'h0, vinn_i[3:2], 6'h0, vinn_i[1:0]}; 
assign xadc_vinp = {vinp_i[4], 6'h0, vinp_i[3:2], 6'h0, vinp_i[1:0]}; 
XADC #(
  .INIT_40(16'h0000), 
  .INIT_41(16'h2f0f), 
  .INIT_42(16'h0400), 
  .INIT_48(16'h4fe0), 
  .INIT_49(16'h0303), 
  .INIT_4A(16'h47e0), 
  .INIT_4B(16'h0000), 
  .INIT_4C(16'h0800), 
  .INIT_4D(16'h0303), 
  .INIT_4E(16'h0000), 
  .INIT_4F(16'h0000), 
  .INIT_50(16'hb5ed), 
  .INIT_51(16'h57e4), 
  .INIT_52(16'ha147), 
  .INIT_53(16'hca33), 
  .INIT_54(16'ha93a), 
  .INIT_55(16'h52c6), 
  .INIT_56(16'h9555), 
  .INIT_57(16'hae4e), 
  .INIT_58(16'h5999), 
  .INIT_5C(16'h5111), 
  .INIT_59(16'h5555), 
  .INIT_5D(16'h5111), 
  .INIT_5A(16'h9999), 
  .INIT_5E(16'h91eb), 
  .INIT_5B(16'h6aaa), 
  .INIT_5F(16'h6666), 
  .SIM_DEVICE("7SERIES"),            
  .SIM_MONITOR_FILE("../../../../code/bench/xadc_sim_values.txt")  
)
XADC_inst
(
  .ALM        (  xadc_alarm           ),  
  .OT         (                       ),  
  .BUSY       (  xadc_busy            ),  
  .CHANNEL    (  xadc_channel         ),  
  .EOC        (  xadc_eoc             ),  
  .EOS        (  xadc_eos             ),  
  .VAUXN      (  xadc_vinn[15:0]      ),  
  .VAUXP      (  xadc_vinp[15:0]      ),  
  .VN         (  xadc_vinn[16]        ),  
  .VP         (  xadc_vinp[16]        ),  
  .CONVST     (  1'b0                 ),  
  .CONVSTCLK  (  1'b0                 ),  
  .RESET      ( !xadc_reset           ),  
  .DO         (  xadc_drp_dato        ),  
  .DRDY       (  xadc_drp_drdy        ),  
  .DADDR      (  xadc_drp_addr        ),  
  .DCLK       (  xadc_drp_clk         ),  
  .DEN        (  xadc_drp_en          ),  
  .DI         (  xadc_drp_dati        ),  
  .DWE        (  xadc_drp_we          ),  
  .JTAGBUSY     (   ), 
  .JTAGLOCKED   (   ), 
  .JTAGMODIFIED (   ), 
  .MUXADDR      (   )  
);
always @(posedge clk_i) begin
   if (xadc_drp_drdy) begin
      if (xadc_drp_addr == 7'd0 )   adc_temp_r <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd13)   adc_pint_r <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd14)   adc_paux_r <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd6 )   adc_bram_r <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd1 )   adc_int_r  <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd2 )   adc_aux_r  <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd15)   adc_ddr_r  <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'h03)   adc_v_r <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd16)   adc_b_r <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd17)   adc_c_r <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd24)   adc_a_r <= xadc_drp_dato[15:4]; 
      if (xadc_drp_addr == 7'd25)   adc_d_r <= xadc_drp_dato[15:4]; 
   end
end
bus_clk_bridge i_bridge
(
   .sys_clk_i     (  sys_clk_i      ),
   .sys_rstn_i    (  sys_rstn_i     ),
   .sys_addr_i    (  sys_addr_i     ),
   .sys_wdata_i   (  sys_wdata_i    ),
   .sys_sel_i     (  sys_sel_i      ),
   .sys_wen_i     (  sys_wen_i      ),
   .sys_ren_i     (  sys_ren_i      ),
   .sys_rdata_o   (  sys_rdata_o    ),
   .sys_err_o     (  sys_err_o      ),
   .sys_ack_o     (  sys_ack_o      ),
   .clk_i         (  clk_i          ),
   .rstn_i        (  rstn_i         ),
   .addr_o        (  addr           ),
   .wdata_o       (  wdata          ),
   .wen_o         (  wen            ),
   .ren_o         (  ren            ),
   .rdata_i       (  rdata          ),
   .err_i         (  err            ),
   .ack_i         (  ack            )
);
endmodule
