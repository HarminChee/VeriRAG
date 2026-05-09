module parallella_7020_top (
   test_i,
   processing_system7_0_DDR_WEB_pin, GPIO12_P, GPIO12_N, GPIO13_P,
   GPIO13_N, GPIO14_P, GPIO14_N, GPIO15_P, GPIO15_N, GPIO16_P,
   GPIO16_N, GPIO17_P, GPIO17_N, GPIO18_P, GPIO18_N, GPIO19_P,
   GPIO19_N, GPIO20_P, GPIO20_N, GPIO21_P, GPIO21_N, GPIO22_P,
   GPIO22_N, GPIO23_P, GPIO23_N, RXI_DATA0_P, RXI_DATA1_P,
   RXI_DATA2_P, RXI_DATA3_P, RXI_DATA4_P, RXI_DATA5_P, RXI_DATA6_P,
   RXI_DATA7_P, RXI_DATA0_N, RXI_DATA1_N, RXI_DATA2_N, RXI_DATA3_N,
   RXI_DATA4_N, RXI_DATA5_N, RXI_DATA6_N, RXI_DATA7_N, RXI_FRAME_P,
   RXI_FRAME_N, RXI_LCLK_P, RXI_LCLK_N, TXI_WR_WAIT_P, TXI_WR_WAIT_N,
   TXI_RD_WAIT_P, TXI_RD_WAIT_N, RXI_CCLK_P, RXI_CCLK_N, DSP_RESET_N,
   processing_system7_0_MIO, processing_system7_0_DDR_Clk,
   processing_system7_0_DDR_Clk_n, processing_system7_0_DDR_CKE,
   processing_system7_0_DDR_CS_n, processing_system7_0_DDR_RAS_n,
   processing_system7_0_DDR_CAS_n, processing_system7_0_DDR_BankAddr,
   processing_system7_0_DDR_Addr, processing_system7_0_DDR_ODT,
   processing_system7_0_DDR_DRSTB, processing_system7_0_DDR_DQ,
   processing_system7_0_DDR_DM, processing_system7_0_DDR_DQS,
   processing_system7_0_DDR_DQS_n, processing_system7_0_DDR_VRN,
   processing_system7_0_DDR_VRP,
   processing_system7_0_PS_SRSTB_pin, processing_system7_0_PS_CLK_pin,
   processing_system7_0_PS_PORB_pin, GPIO0_P, GPIO0_N, GPIO1_P,
   GPIO1_N, GPIO2_P, GPIO2_N, GPIO3_P, GPIO3_N, GPIO4_P, GPIO4_N,
   GPIO5_P, GPIO5_N, GPIO6_P, GPIO6_N, GPIO7_P, GPIO7_N, GPIO8_P,
   GPIO8_N, GPIO9_P, GPIO9_N, GPIO10_P, GPIO10_N, GPIO11_P, GPIO11_N,
   TXO_DATA0_P, TXO_DATA1_P, TXO_DATA2_P, TXO_DATA3_P, TXO_DATA4_P,
   TXO_DATA5_P, TXO_DATA6_P, TXO_DATA7_P, TXO_DATA0_N, TXO_DATA1_N,
   TXO_DATA2_N, TXO_DATA3_N, TXO_DATA4_N, TXO_DATA5_N, TXO_DATA6_N,
   TXO_DATA7_N, TXO_FRAME_P, TXO_FRAME_N, TXO_LCLK_P, TXO_LCLK_N,
   RXO_WR_WAIT_P, RXO_WR_WAIT_N, RXO_RD_WAIT_P, RXO_RD_WAIT_N,
   DSP_FLAG,
   HDMI_D23, HDMI_D22, HDMI_D21, HDMI_D20, HDMI_D19, HDMI_D18, HDMI_D17,
   HDMI_D16, HDMI_D15, HDMI_D14, HDMI_D13, HDMI_D12, HDMI_D11, HDMI_D10,
   HDMI_D9, HDMI_D8, HDMI_CLK, HDMI_HSYNC, HDMI_VSYNC, HDMI_DE, PS_I2C_SCL,
   PS_I2C_SDA,
   processing_system7_0_FCLK_CLK3_pin,
   sys_clk,
   iRST_N
   );

input test_i;
input processing_system7_0_FCLK_CLK3_pin;
input sys_clk;
input iRST_N;
input processing_system7_0_DDR_WEB_pin;
input GPIO12_P, GPIO12_N, GPIO13_P, GPIO13_N, GPIO14_P, GPIO14_N;
input GPIO15_P, GPIO15_N, GPIO16_P, GPIO16_N, GPIO17_P, GPIO17_N;
input GPIO18_P, GPIO18_N, GPIO19_P, GPIO19_N, GPIO20_P, GPIO20_N;
input GPIO21_P, GPIO21_N, GPIO22_P, GPIO22_N, GPIO23_P, GPIO23_N;
input RXI_DATA0_P, RXI_DATA1_P, RXI_DATA2_P, RXI_DATA3_P;
input RXI_DATA4_P, RXI_DATA5_P, RXI_DATA6_P, RXI_DATA7_P;
input RXI_DATA0_N, RXI_DATA1_N, RXI_DATA2_N, RXI_DATA3_N;
input RXI_DATA4_N, RXI_DATA5_N, RXI_DATA6_N, RXI_DATA7_N;
input RXI_FRAME_P, RXI_FRAME_N, RXI_LCLK_P, RXI_LCLK_N;
input TXI_WR_WAIT_P, TXI_WR_WAIT_N, TXI_RD_WAIT_P, TXI_RD_WAIT_N;
input RXI_CCLK_P, RXI_CCLK_N, DSP_RESET_N;
input [53:0] processing_system7_0_MIO;
input processing_system7_0_DDR_Clk;
input processing_system7_0_DDR_Clk_n;
input processing_system7_0_DDR_CKE;
input processing_system7_0_DDR_CS_n;
input processing_system7_0_DDR_RAS_n;
input processing_system7_0_DDR_CAS_n;
input [2:0] processing_system7_0_DDR_BankAddr;
input [14:0] processing_system7_0_DDR_Addr;
input processing_system7_0_DDR_ODT;
input processing_system7_0_DDR_DRSTB;
input [31:0] processing_system7_0_DDR_DQ;
input [3:0] processing_system7_0_DDR_DM;
input [3:0] processing_system7_0_DDR_DQS;
input [3:0] processing_system7_0_DDR_DQS_n;
input processing_system7_0_DDR_VRN;
input processing_system7_0_DDR_VRP;
input processing_system7_0_PS_SRSTB_pin;
input processing_system7_0_PS_CLK_pin;
input processing_system7_0_PS_PORB_pin;
input GPIO0_P, GPIO0_N, GPIO1_P, GPIO1_N, GPIO2_P, GPIO2_N;
input GPIO3_P, GPIO3_N, GPIO4_P, GPIO4_N, GPIO5_P, GPIO5_N;
input GPIO6_P, GPIO6_N, GPIO7_P, GPIO7_N, GPIO8_P, GPIO8_N;
input GPIO9_P, GPIO9_N, GPIO10_P, GPIO10_N, GPIO11_P, GPIO11_N;
output TXO_DATA0_P, TXO_DATA1_P, TXO_DATA2_P, TXO_DATA3_P;
output TXO_DATA4_P, TXO_DATA5_P, TXO_DATA6_P, TXO_DATA7_P;
output TXO_DATA0_N, TXO_DATA1_N, TXO_DATA2_N, TXO_DATA3_N;
output TXO_DATA4_N, TXO_DATA5_N, TXO_DATA6_N, TXO_DATA7_N;
output TXO_FRAME_P, TXO_FRAME_N, TXO_LCLK_P, TXO_LCLK_N;
output RXO_WR_WAIT_P, RXO_WR_WAIT_N, RXO_RD_WAIT_P, RXO_RD_WAIT_N;
output [3:0] DSP_FLAG;
output HDMI_D23, HDMI_D22, HDMI_D21, HDMI_D20, HDMI_D19, HDMI_D18;
output HDMI_D17, HDMI_D16, HDMI_D15, HDMI_D14, HDMI_D13, HDMI_D12;
output HDMI_D11, HDMI_D10, HDMI_D9, HDMI_D8, HDMI_CLK, HDMI_HSYNC;
output HDMI_VSYNC, HDMI_DE;
inout PS_I2C_SCL, PS_I2C_SDA;

wire dft_clk;
assign dft_clk = test_i ? processing_system7_0_FCLK_CLK3_pin : sys_clk;

reg [19:0] por_cnt;
reg por_reset;

always @ (posedge dft_clk or negedge iRST_N)
begin
   if(!iRST_N)
   begin
      por_cnt[19:0] <= 20'h0;
      por_reset <= 1'b1;
   end
   else
   begin
      if (por_cnt[19:0] == 20'hff13f)
      begin   
         por_reset <= 1'b0;
         por_cnt[19:0] <= por_cnt[19:0]; 
      end
      else                          
      begin
         por_reset <= 1'b1;
         por_cnt[19:0] <= por_cnt[19:0] + {{19{1'b0}},1'b1};
      end
   end
end

endmodule