module rxtx( 
   input   wire            test_i,
   input   wire            A2D_CLKn, 
   input   wire            A2D_CLKp, 
   input   wire            ADC_SYNC_INn, 
   input   wire            ADC_SYNC_INp, 
   input   wire            CH1_A2D_CLKn, 
   input   wire            CH1_A2D_CLKp, 
   input   wire            CH1_A2D_DATAn, 
   input   wire            CH1_A2D_DATAp, 
   input   wire            CH1_HV_OF, 
   input   wire            CH1_LV_OF, 
   input   wire            CH2_A2D_CLKn, 
   input   wire            CH2_A2D_CLKp, 
   input   wire            CH2_A2D_DATAn, 
   input   wire            CH2_A2D_DATAp, 
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

// ... existing code ...

wire dft_clk;
assign dft_clk = test_i ? PCIE_REFCLK_p : user_clk;

always @(posedge dft_clk or posedge reset)
begin
    if (reset == 1'b1)
    begin
        d2_user_rst <= 1'b1;
        d1_user_rst <= 1'b1;
        user_rst    <= 1'b1;
    end
    else
    begin
        d2_user_rst <= 1'b0;
        d1_user_rst <= d2_user_rst;
        user_rst    <= d1_user_rst;
    end
end

// ... existing code ...

wire dft_clk_div2;
assign dft_clk_div2 = test_i ? PCIE_REFCLK_p : user_clk_div2;

always @(posedge dft_clk_div2 or posedge reset)
begin
    if (reset == 1'b1)
    begin
        d2_user_rst_div2 <= 1'b1;
        d1_user_rst_div2 <= 1'b1;
        user_rst_div2    <= 1'b1;
    end
    else
    begin
        d2_user_rst_div2 <= 1'b0;
        d1_user_rst_div2 <= d2_user_rst_div2;
        user_rst_div2    <= d1_user_rst_div2;
    end
end

// ... existing code ...

wire dft_lcb_clk;
assign dft_lcb_clk = test_i ? PCIE_REFCLK_p : lcbClk;

always @(posedge dft_lcb_clk or posedge reset)
begin
    if (reset == 1'b1)
    begin
        d2_lcb_rst <= 1'b1;
        d1_lcb_rst <= 1'b1;
        lcb_rst    <= 1'b1;
    end
    else
    begin
        d2_lcb_rst <= 1'b0;
        d1_lcb_rst <= d2_lcb_rst;
        lcb_rst    <= d1_lcb_rst;
    end
end

// ... existing code ...

endmodule