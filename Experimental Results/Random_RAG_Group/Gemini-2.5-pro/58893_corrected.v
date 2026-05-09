module de10_nano_top(
    input               test_i,         // Added for DFT
    input               reset_n,        // Added for DFT (as the controllable test reset)
    input               FPGA_CLK1_50,
    input               FPGA_CLK2_50,
    input               FPGA_CLK3_50,
    inout               HPS_CONV_USB_N,
    output   [14: 0]    HPS_DDR3_ADDR,
    output   [ 2: 0]    HPS_DDR3_BA,
    output              HPS_DDR3_CAS_N,
    output              HPS_DDR3_CK_N,
    output              HPS_DDR3_CK_P,
    output              HPS_DDR3_CKE,
    output              HPS_DDR3_CS_N,
    output   [ 3: 0]    HPS_DDR3_DM,
    inout    [31: 0]    HPS_DDR3_DQ,
    inout    [ 3: 0]    HPS_DDR3_DQS_N,
    inout    [ 3: 0]    HPS_DDR3_DQS_P,
    output              HPS_DDR3_ODT,
    output              HPS_DDR3_RAS_N,
    output              HPS_DDR3_RESET_N,
    input               HPS_DDR3_RZQ,
    output              HPS_DDR3_WE_N,
    output   [ 7: 0]    LED
);
wire hps_fpga_reset_n;
wire                fpga_clk_50;
assign fpga_clk_50 = FPGA_CLK1_50;

// DFT Modification: Muxed reset signal for ACNCPI violation
wire dft_hps_fpga_reset_n;
assign dft_hps_fpga_reset_n = test_i ? reset_n : hps_fpga_reset_n;

soc_system u0(
               .clk_clk(FPGA_CLK1_50),
               // Apply muxed reset to the soc_system input as well for DFT consistency
               .reset_reset_n(dft_hps_fpga_reset_n),
               .memory_mem_a(HPS_DDR3_ADDR),
               .memory_mem_ba(HPS_DDR3_BA),
               .memory_mem_ck(HPS_DDR3_CK_P),
               .memory_mem_ck_n(HPS_DDR3_CK_N),
               .memory_mem_cke(HPS_DDR3_CKE),
               .memory_mem_cs_n(HPS_DDR3_CS_N),
               .memory_mem_ras_n(HPS_DDR3_RAS_N),
               .memory_mem_cas_n(HPS_DDR3_CAS_N),
               .memory_mem_we_n(HPS_DDR3_WE_N),
               .memory_mem_reset_n(HPS_DDR3_RESET_N),
               .memory_mem_dq(HPS_DDR3_DQ),
               .memory_mem_dqs(HPS_DDR3_DQS_P),
               .memory_mem_dqs_n(HPS_DDR3_DQS_N),
               .memory_mem_odt(HPS_DDR3_ODT),
               .memory_mem_dm(HPS_DDR3_DM),
               .memory_oct_rzqin(HPS_DDR3_RZQ),
               // This output drives the functional part of the muxed reset
               .hps_0_h2f_reset_reset_n(hps_fpga_reset_n)
           );
reg [25: 0] counter;
reg led_level;

// DFT Modification: Use muxed reset in sensitivity list and condition
always @(posedge fpga_clk_50 or negedge dft_hps_fpga_reset_n) begin
    if (~dft_hps_fpga_reset_n) begin // Use the muxed reset signal here
        counter <= 0;
        led_level <= 0;
    end
    else if (counter == 24999999) begin
        counter <= 0;
        led_level <= ~led_level;
    end
    else
        counter <= counter + 1'b1;
end
assign LED[0] = led_level;
// Assign remaining LEDs - Assume they should be tied low if unused
assign LED[7:1] = 7'b0;

endmodule