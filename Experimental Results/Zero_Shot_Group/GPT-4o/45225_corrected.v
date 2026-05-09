module parallella_7020_top (
    input processing_system7_0_PS_SRSTB_pin,
    input processing_system7_0_PS_CLK_pin,
    input processing_system7_0_PS_PORB_pin,
    output processing_system7_0_DDR_WEB_pin,
    inout [53:0] processing_system7_0_MIO,
    inout processing_system7_0_DDR_Clk,
    inout processing_system7_0_DDR_Clk_n,
    inout processing_system7_0_DDR_CKE,
    inout processing_system7_0_DDR_CS_n,
    inout processing_system7_0_DDR_RAS_n,
    inout processing_system7_0_DDR_CAS_n,
    inout [2:0] processing_system7_0_DDR_BankAddr,
    inout [14:0] processing_system7_0_DDR_Addr,
    inout processing_system7_0_DDR_ODT,
    inout processing_system7_0_DDR_DRSTB,
    inout [31:0] processing_system7_0_DDR_DQ,
    inout [3:0] processing_system7_0_DDR_DM,
    inout [3:0] processing_system7_0_DDR_DQS,
    inout [3:0] processing_system7_0_DDR_DQS_n,
    inout processing_system7_0_DDR_VRN,
    inout processing_system7_0_DDR_VRP,
    output HDMI_D23,
    output HDMI_D22,
    output HDMI_D21,
    output HDMI_D20,
    output HDMI_D19,
    output HDMI_D18,
    output HDMI_D17,
    output HDMI_D16,
    output HDMI_D15,
    output HDMI_D14,
    output HDMI_D13,
    output HDMI_D12,
    output HDMI_D11,
    output HDMI_D10,
    output HDMI_D9,
    output HDMI_D8,
    output HDMI_CLK,
    output HDMI_HSYNC,
    output HDMI_VSYNC,
    output HDMI_DE,
    inout PS_I2C_SCL,
    inout PS_I2C_SDA,
    input DSP_FLAG,
    output DSP_RESET_N
);

    wire sys_clk;
    wire esaxi_areset;
    wire fpga_reset;
    wire por_reset;
    wire pbr_reset;
    reg [19:0] por_cnt;
    reg [31:0] counter_reg;
    wire [15:0] hdmi_data;
    wire hdmi_clk;
    wire hdmi_hsync;
    wire hdmi_vsync;
    wire hdmi_data_e;

    always @(posedge sys_clk) begin
        if (por_cnt == 20'hFF13F) begin
            por_reset <= 1'b0;
        end else begin
            por_reset <= 1'b1;
            por_cnt <= por_cnt + 1'b1;
        end
    end

    always @(posedge sys_clk or posedge fpga_reset) begin
        if (fpga_reset)
            counter_reg <= 32'b0;
        else
            counter_reg <= counter_reg + 1'b1;
    end

    assign fpga_reset = por_reset | pbr_reset | esaxi_areset;
    assign sys_clk = processing_system7_0_PS_CLK_pin;
    assign esaxi_areset = ~processing_system7_0_PS_SRSTB_pin;
    
    assign HDMI_D8 = hdmi_data[0];
    assign HDMI_D9 = hdmi_data[1];
    assign HDMI_D10 = hdmi_data[2];
    assign HDMI_D11 = hdmi_data[3];
    assign HDMI_D12 = hdmi_data[4];
    assign HDMI_D13 = hdmi_data[5];
    assign HDMI_D14 = hdmi_data[6];
    assign HDMI_D15 = hdmi_data[7];
    assign HDMI_D16 = hdmi_data[8];
    assign HDMI_D17 = hdmi_data[9];
    assign HDMI_D18 = hdmi_data[10];
    assign HDMI_D19 = hdmi_data[11];
    assign HDMI_D20 = hdmi_data[12];
    assign HDMI_D21 = hdmi_data[13];
    assign HDMI_D22 = hdmi_data[14];
    assign HDMI_D23 = hdmi_data[15];
    assign HDMI_CLK = hdmi_clk;
    assign HDMI_HSYNC = hdmi_hsync;
    assign HDMI_VSYNC = hdmi_vsync;
    assign HDMI_DE = hdmi_data_e;

    assign DSP_RESET_N = ~fpga_reset;

endmodule