`define EP16          1
`define IOSTND        "LVDS_25"
`define CLKEDGE       "SAME_EDGE_PIPELINED"
`define PHYS_EXT_MEM  4'h1

module top_parallella16_prototype (
   input wire clk_in, // Primary input clock
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
   aafm_i2c_sda, user_pb
   );
   parameter SIDW = 12; 
   parameter SAW  = 32; 
   parameter SDW  = 32; 
   parameter MIDW = 6;  
   parameter MAW  = 32; 
   parameter MDW  = 64; 
   parameter STW  = 8;  
   parameter DPW  = 20; 

   // ... existing code ...

   // Replace internally generated clock with primary input clock
   assign sys_clk = clk_in;

   // ... existing code ...

   always @ (posedge clk_in or posedge fpga_reset) 
     if(fpga_reset)
       counter_reg[31:0] <= 32'b0;   
     else
       counter_reg[31:0] <= counter_reg[31:0] + 1'b1;   

   // ... rest of existing code ...

endmodule