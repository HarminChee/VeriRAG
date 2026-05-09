module parallella_7020_top (
   input processing_system7_0_FCLK_CLK0_pin, // Primary input clock
   input processing_system7_0_FCLK_CLK3_pin, // Primary input clock
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
   PS_I2C_SDA
   );

// ... existing code ...

   // Remove internally generated clock
   wire sys_clk;
   assign sys_clk = processing_system7_0_FCLK_CLK3_pin;

// ... existing code ...

   // Use primary input clock for debouncer
   generate
      for(k=0;k<2;k=k+1) begin : gen_debounce
         debouncer #(DPW) debouncer (.clean_out   (user_pb_clean[k]),
                                     .clk         (processing_system7_0_FCLK_CLK3_pin),
                                     .noisy_in    (user_pb[k]));
      end
   endgenerate

   // Use primary input clock for registers
   always @(posedge processing_system7_0_FCLK_CLK3_pin)    
      user_pb_clean_reg[1:0] <= user_pb_clean[1:0];

   always @ (posedge processing_system7_0_FCLK_CLK3_pin)
     begin
        if (por_cnt[19:0] == 20'hff13f)
          begin   
             por_reset     <= 1'b0;
             por_cnt[19:0] <= por_cnt[19:0]; 
          end
        else                          
          begin
             por_reset     <= 1'b1;
             por_cnt[19:0] <= por_cnt[19:0] + {{(19){1'b0}},1'b1};
          end
     end 

   always @ (posedge processing_system7_0_FCLK_CLK3_pin or posedge fpga_reset) 
     if(fpga_reset)
       counter_reg[31:0] <= 32'b0;   
     else
       counter_reg[31:0] <= counter_reg[31:0] + 1'b1;   

// ... rest of existing code ...

endmodule