`timescale 1ns / 1ps
`timescale 1ns / 1ps
module u2plus
  (
   input test_i,
   input CLK_FPGA_P, input CLK_FPGA_N,  
   input ADC_clkout_p, input ADC_clkout_n,
   input ADCA_12_p, input ADCA_12_n,
   input ADCA_10_p, input ADCA_10_n,
   input ADCA_8_p, input ADCA_8_n,
   input ADCA_6_p, input ADCA_6_n,
   input ADCA_4_p, input ADCA_4_n,
   input ADCA_2_p, input ADCA_2_n,
   input ADCA_0_p, input ADCA_0_n,
   input ADCB_12_p, input ADCB_12_n,
   input ADCB_10_p, input ADCB_10_n,
   input ADCB_8_p, input ADCB_8_n,
   input ADCB_6_p, input ADCB_6_n,
   input ADCB_4_p, input ADCB_4_n,
   input ADCB_2_p, input ADCB_2_n,
   input ADCB_0_p, input ADCB_0_n,
   output reg [15:0] DACA,
   output reg [15:0] DACB,
   input DAC_LOCK,     
   inout [15:0] io_tx,
   inout [15:0] io_rx,
   output [5:1] leds,  
   input FPGA_RESET,
   output [1:0] debug_clk,
   output [31:0] debug,
   output [3:1] TXD, input [3:1] RXD, 
   output [1:0] clk_en,
   output [1:0] clk_sel,
   input CLK_FUNC,        
   input clk_status,
   inout SCL, inout SDA,   
   input PPS_IN, input PPS2_IN,
   output SEN_CLK, output SCLK_CLK, output MOSI_CLK, input MISO_CLK,
   output SEN_DAC, output SCLK_DAC, output MOSI_DAC, input MISO_DAC,
   output SEN_ADC, output SCLK_ADC, output MOSI_ADC,
   output SEN_TX_DB, output SCLK_TX_DB, output MOSI_TX_DB, input MISO_TX_DB,
   output SEN_TX_DAC, output SCLK_TX_DAC, output MOSI_TX_DAC,
   output SEN_TX_ADC, output SCLK_TX_ADC, output MOSI_TX_ADC, input MISO_TX_ADC,
   output SEN_RX_DB, output SCLK_RX_DB, output MOSI_RX_DB, input MISO_RX_DB,
   output SEN_RX_DAC, output SCLK_RX_DAC, output MOSI_RX_DAC,
   output SEN_RX_ADC, output SCLK_RX_ADC, output MOSI_RX_ADC, input MISO_RX_ADC,
   input CLK_TO_MAC,
   output reg [7:0] GMII_TXD,
   output reg GMII_TX_EN,
   output reg GMII_TX_ER,
   output GMII_GTX_CLK,
   input GMII_TX_CLK,  
   input GMII_RX_CLK,
   input [7:0] GMII_RXD,
   input GMII_RX_DV,
   input GMII_RX_ER,
   input GMII_COL,
   input GMII_CRS,
   input PHY_INTn,   
   inout MDIO,
   output MDC,
   output PHY_RESETn,
   output ETH_LED,
   input exp_time_in_p, input exp_time_in_n, 
   output exp_time_out_p, output exp_time_out_n, 
   input exp_user_in_p, input exp_user_in_n, 
   output exp_user_out_p, output exp_user_out_n, 
   output ser_enable,
   output ser_prbsen,
   output ser_loopen,
   output ser_rx_en,
   output ser_tx_clk,
   output reg [15:0] ser_t,
   output reg ser_tklsb,
   output reg ser_tkmsb,
   input ser_rx_clk,
   input [15:0] ser_r,
   input ser_rklsb,
   input ser_rkmsb,
   inout [35:0] RAM_D,
   output [20:0] RAM_A,
   output [3:0] RAM_BWn,
   output RAM_ZZ,
   output RAM_LDn,
   output RAM_OEn,
   output RAM_WEn,
   output RAM_CENn,
   output RAM_CLK,
   output flash_cs,
   output flash_clk,
   output flash_mosi,
   input flash_miso
   );

   wire clk_fpga_int;
   IBUFGDS clk_fpga_pin (.O(clk_fpga_int),.I(CLK_FPGA_P),.IB(CLK_FPGA_N));
   defparam clk_fpga_pin.IOSTANDARD = "LVPECL_25";

   wire clk_fpga;
   assign clk_fpga = test_i ? CLK_TO_MAC : clk_fpga_int;

   // ... existing code ...

   wire CLK_TO_MAC_int, CLK_TO_MAC_int2;
   IBUFG phyclk (.O(CLK_TO_MAC_int), .I(CLK_TO_MAC));
   BUFG phyclk2 (.O(CLK_TO_MAC_int2), .I(CLK_TO_MAC_int));

   // ... rest of existing code ...

endmodule