module rxtx( 
   input   wire            A2D_CLKn, 
   input   wire            A2D_CLKp, 
   input   wire            ADC_SYNC_INn, 
   input   wire            ADC_SYNC_INp, 
   input   wire            CH1_A2D_CLKn, 
   input   wire            CH1_A2D_CLKp, 
   input   wire    [6:0]   CH1_A2D_DATAn, 
   input   wire    [6:0]   CH1_A2D_DATAp, 
   input   wire            CH1_HV_OF, 
   input   wire            CH1_LV_OF, 
   input   wire            CH2_A2D_CLKn, 
   input   wire            CH2_A2D_CLKp, 
   input   wire    [6:0]   CH2_A2D_DATAn, 
   input   wire    [6:0]   CH2_A2D_DATAp, 
   input   wire            CH2_HV_OF, 
   input   wire            CH2_LV_OF, 
   input   wire            DAC_GDATACLKn, 
   input   wire            DAC_GDATACLKp, 
   input   wire            DAC_SYNC_INn, 
   input   wire            DAC_SYNC_INp, 
   input   wire            EXT_CLK_SDI, 
   input   wire            EXT_CLK_STATUS, 
   input   wire            LVCLK_200n, 
   input   wire            LVCLK_200p, 
   input   wire            MGT_REFCLK_n, 
   input   wire            MGT_REFCLK_p, 
   input   wire            PCIE_REFCLK_n, 
   input   wire            PCIE_REFCLK_p, 
   input   wire            PCIE_RESETn, 
   input   wire            TEMP_ALERTn, 
   input   wire            TEMP_THERMn, 
   output  wire            ADC_SYNC_DISABLEn, 
   output  wire            ADC_SYNC_DISABLEp, 
   output  wire            ADC_SYNC_OUTn, 
   output  wire            ADC_SYNC_OUTp, 
   output  wire            CH1_A2D_OE, 
   output  wire            CH1_A2D_RESET, 
   output  wire            CH1_A2D_SCLK, 
   output  wire            CH1_A2D_SDATA, 
   output  wire            CH1_A2D_SEN, 
   output  wire            CH2_A2D_OE, 
   output  wire            CH2_A2D_RESET, 
   output  wire            CH2_A2D_SCLK, 
   output  wire            CH2_A2D_SDATA, 
   output  wire            CH2_A2D_SEN, 
   output  wire            CPLD_CSn, 
   output  wire            CPLD_RSTn, 
   output  wire            DAC_CAL, 
   output  wire            DAC_CLKDIV, 
   output  wire    [11:0]  DAC_DAn, 
   output  wire    [11:0]  DAC_DAp, 
   output  wire    [11:0]  DAC_DBn, 
   output  wire    [11:0]  DAC_DBp, 
   output  wire    [11:0]  DAC_DCn, 
   output  wire    [11:0]  DAC_DCp, 
   output  wire    [11:0]  DAC_DDn, 
   output  wire    [11:0]  DAC_DDp, 
   output  wire            DAC_DELAY, 
   output  wire            DAC_RF, 
   output  wire            DAC_RZ, 
   output  wire            DAC_SYNC_DISABLEn, 
   output  wire            DAC_SYNC_DISABLEp, 
   output  wire            DAC_SYNC_OUTn, 
   output  wire            DAC_SYNC_OUTp, 
   output  wire            EXT_CLK_CSn, 
   output  wire            EXT_CLK_FUNC, 
   output  wire            EXT_CLK_SCLK, 
   output  wire            EXT_CLK_SDO, 
   output  wire            I2C_BUS_SELECT, 
   inout   wire            I2C_SCLK, 
   inout   wire            I2C_SDATA 
);

supply0 GND;
wire resetn;
wire clk200Mhz;
wire a2dClk;
wire lcbClk;
wire user_clk;
wire dacClk;
wire lcb_resetn;
wire dac_reset;
wire a2d_clk_reset;
wire adcISync;
wire dacISync;
wire adcSyncOut;
wire dacSyncOut;
wire adcSyncDisable;
wire dacSyncDisable;
wire [31:0] lsiDataOut;
wire [7:0] lsiAddress;
wire waveGenEnable;
wire waveGenTrigger;
wire waveGenTrigOut;
wire waveGenTrigPulseOut;

// Clock Control Module
clockControl clockControl1 (
   .A2D_CLKn(A2D_CLKn),
   .A2D_CLKp(A2D_CLKp),
   .DAC_GDATACLKn(DAC_GDATACLKn),
   .DAC_GDATACLKp(DAC_GDATACLKp),
   .LVCLK_200n(LVCLK_200n),
   .LVCLK_200p(LVCLK_200p),
   .MGT_REFCLK_n(MGT_REFCLK_n),
   .MGT_REFCLK_p(MGT_REFCLK_p),
   .PCIE_REFCLK_n(PCIE_REFCLK_n),
   .PCIE_REFCLK_p(PCIE_REFCLK_p),
   .a2d_clk_reset(a2d_clk_reset),
   .dac_reset(dac_reset),
   .user_clk(user_clk),
   .a2dClk(a2dClk),
   .clk200Mhz(clk200Mhz),
   .dacClk(dacClk),
   .lcbClk(lcbClk),
   .lcb_resetn(lcb_resetn)
);

// ADC Synchronization
ls_sync_controller adc_sync (
   .lcbClk(lcbClk),
   .resetn(lcb_resetn),
   .syncClk(a2dClk),
   .syncIn(adcSyncOut),
   .extSyncDisable(adcSyncDisable),
   .iSync(adcISync),
   .syncOut(adcSyncOut)
);

// DAC Synchronization
ls_sync_controller dac_sync (
   .lcbClk(lcbClk),
   .resetn(lcb_resetn),
   .syncClk(dacClk),
   .syncIn(dacSyncOut),
   .extSyncDisable(dacSyncDisable),
   .iSync(dacISync),
   .syncOut(dacSyncOut)
);

// Wave Generator
waveGen wavegen1 (
   .clk(user_clk),
   .enable(waveGenEnable),
   .lcbClk(lcbClk),
   .lcbDataIn(lsiDataOut),
   .resetn(lcb_resetn),
   .trigIn(waveGenTrigger),
   .trigOut(waveGenTrigOut)
);

// ADC Buffer
IBUFDS_LVDS_25 adc_sync_ibuf (
   .O(adcSyncOut),
   .I(ADC_SYNC_INp),
   .IB(ADC_SYNC_INn)
);

// DAC Buffer
IBUFDS_LVDS_25 dac_sync_ibuf (
   .O(dacSyncOut),
   .I(DAC_SYNC_INp),
   .IB(DAC_SYNC_INn)
);

// Output Buffers
OBUFDS_LVDS_25 adc_sync_dis_obuf (
   .O(ADC_SYNC_DISABLEp),
   .OB(ADC_SYNC_DISABLEn),
   .I(adcSyncDisable)
);

OBUFDS_LVDS_25 adc_sync_obuf (
   .O(ADC_SYNC_OUTp),
   .OB(ADC_SYNC_OUTn),
   .I(adcSyncOut)
);

OBUFDS_LVDS_25 dac_sync_dis_obuf (
   .O(DAC_SYNC_DISABLEp),
   .OB(DAC_SYNC_DISABLEn),
   .I(dacSyncDisable)
);

OBUFDS_LVDS_25 dac_sync_obuf (
   .O(DAC_SYNC_OUTp),
   .OB(DAC_SYNC_OUTn),
   .I(dacSyncOut)
);

endmodule