module top_parallella16_prototype (
   processing_system7_0_DDR_WEB_pin, txo_data_p, txo_data_n,
   txo_frame_p, txo_frame_n, txo_lclk_p, txo_lclk_n, rxi_wr_wait_p,
   rxi_wr_wait_n, rxi_rd_wait_p, rxi_rd_wait_n, aafm_resetn,
   aafm_ctrl, aafm_xid0, aafm_xid1, aafm_xid2, aafm_i2c_scl, user_led,
   processing_system7_0_MIO, processing_system7_0_DDR_Clk,
   processing_system7_0_DDR_Clk_n, processing_system7_0_DDR_CKE,
   processing_system7_0_DDR_CS_n, processing_system7_0_DDR_RAS_n,
   processing_system7_0_DDR_CAS_n, processing_system7_0_DDR_BankAddr,
   processing_system7_0_DDR_Addr, processing_system7_0_DDR_ODT,
   processing_system7_0_DDR_DRSTB, processing_system7_0_DDR_DQ,
   processing_system7_0_DDR_DM, processing_system7_0_DDR_DQS,
   processing_system7_0_DDR_DQS_n, processing_system7_0_DDR_VRN,
   processing_system7_0_DDR_VRP,
   processing_system7_0_PS_SRSTB, processing_system7_0_PS_CLK,
   processing_system7_0_PS_PORB, rxi_data_p, rxi_data_n, rxi_frame_p,
   rxi_frame_n, rxi_lclk_p, rxi_lclk_n, txo_wr_wait_p, txo_wr_wait_n,
   txo_rd_wait_p, txo_rd_wait_n, aafm_flag0, aafm_flag1, aafm_flag2,
   aafm_flag3, aafm_yid0, aafm_yid1, aafm_yid2, aafm_misc,
   aafm_i2c_sda, user_pb, test_mode_i, processing_system7_0_FCLK_CLK3_pin,
   processing_system7_0_FCLK_CLK0_pin, processing_system7_0_M_AXI_GP1_ARESETN_pin
   );
   parameter SIDW = 12; 
   parameter SAW  = 32; 
   parameter SDW  = 32; 
   parameter MIDW = 6;  
   parameter MAW  = 32; 
   parameter MDW  = 64; 
   parameter STW  = 8;  
   parameter DPW  = 20; 

   input test_mode_i;
   input processing_system7_0_FCLK_CLK3_pin;
   input processing_system7_0_FCLK_CLK0_pin;
   input processing_system7_0_M_AXI_GP1_ARESETN_pin;
   input processing_system7_0_PS_SRSTB;
   
   reg [19:0] por_cnt;
   reg por_reset;
   reg [1:0] user_pb_clean_reg;
   reg [31:0] counter_reg;
   wire sys_clk;
   wire esaxi_areset;
   wire fpga_reset;
   wire pbr_reset;
   wire [1:0] user_pb_clean;
   wire test_clk;
   
   assign sys_clk = processing_system7_0_FCLK_CLK3_pin;
   assign test_clk = test_mode_i ? processing_system7_0_FCLK_CLK0_pin : sys_clk;
   assign esaxi_areset = ~processing_system7_0_M_AXI_GP1_ARESETN_pin;
   
   always @(posedge processing_system7_0_FCLK_CLK3_pin or negedge processing_system7_0_PS_SRSTB)    
     begin
        if (!processing_system7_0_PS_SRSTB)
          begin   
             por_cnt <= 20'h0;
             por_reset <= 1'b1;
          end
        else                          
          begin
             if (por_cnt == 20'hff13f)
               begin
                  por_reset <= 1'b0;
                  por_cnt <= por_cnt;
               end
             else
               begin
                  por_reset <= 1'b1;
                  por_cnt <= por_cnt + 1'b1;
               end
          end
     end
endmodule