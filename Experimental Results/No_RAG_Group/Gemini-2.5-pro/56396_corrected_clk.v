`timescale 1ns / 1ps
// 1_corrected_clk.v
module u2plus
  (
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
   input flash_miso,

   // DFT Inputs
   input test_mode, // Scan enable signal
   input test_clk   // Scan clock signal
   );

   wire  CLK_TO_MAC_int, CLK_TO_MAC_int2;
   IBUFG phyclk (.O(CLK_TO_MAC_int), .I(CLK_TO_MAC));
   BUFG phyclk2 (.O(CLK_TO_MAC_int2), .I(CLK_TO_MAC_int));

   wire 	clk_fpga, dsp_clk, clk_div, dcm_out, wb_clk, clock_ready;
   wire     clk270_100, LOCKED_OUT, clk270_100_buf; // Added missing declarations

   IBUFGDS clk_fpga_pin (.O(clk_fpga),.I(CLK_FPGA_P),.IB(CLK_FPGA_N));
   defparam 	clk_fpga_pin.IOSTANDARD = "LVPECL_25";

   wire 	exp_time_in;
   IBUFDS exp_time_in_pin (.O(exp_time_in),.I(exp_time_in_p),.IB(exp_time_in_n));
   defparam 	exp_time_in_pin.IOSTANDARD = "LVDS_25";

   wire 	exp_time_out;
   OBUFDS exp_time_out_pin (.O(exp_time_out_p),.OB(exp_time_out_n),.I(exp_time_out));
   defparam 	exp_time_out_pin.IOSTANDARD  = "LVDS_25";

   wire 	exp_user_in;
   IBUFDS exp_user_in_pin (.O(exp_user_in),.I(exp_user_in_p),.IB(exp_user_in_n));
   defparam 	exp_user_in_pin.IOSTANDARD = "LVDS_25";

   wire 	exp_user_out;
   OBUFDS exp_user_out_pin (.O(exp_user_out_p),.OB(exp_user_out_n),.I(exp_user_out));
   defparam 	exp_user_out_pin.IOSTANDARD  = "LVDS_25";

   reg [5:0] 	clock_ready_d;
   // Clock for clock_ready_d is clk_fpga, derived from primary inputs, generally OK for DFT.
   always @(posedge clk_fpga)
     clock_ready_d[5:0] <= {clock_ready_d[4:0],clock_ready};

   wire 	dcm_rst = ~&clock_ready_d & |clock_ready_d;

`ifdef LVDS
   wire [13:0] 	adc_a, adc_a_inv, adc_b;
   // Assuming capture_ddrlvds handles DFT internally or uses dsp_clk which will be muxed
   capture_ddrlvds #(.WIDTH(14)) capture_ddrlvds
     (.clk(dsp_clk), .ssclk_p(ADC_clkout_p), .ssclk_n(ADC_clkout_n),
      .in_p({{ADCA_12_p, ADCA_10_p, ADCA_8_p, ADCA_6_p, ADCA_4_p, ADCA_2_p, ADCA_0_p},
	     {ADCB_12_p, ADCB_10_p, ADCB_8_p, ADCB_6_p, ADCB_4_p, ADCB_2_p, ADCB_0_p}}),
      .in_n({{ADCA_12_n, ADCA_10_n, ADCA_8_n, ADCA_6_n, ADCA_4_n, ADCA_2_n, ADCA_0_n},
	     {ADCB_12_n, ADCB_10_n, ADCB_8_n, ADCB_6_n, ADCB_4_n, ADCB_2_n, ADCB_0_n}}),
      .out({adc_a_inv,adc_b}));
   assign adc_a = ~adc_a_inv;
`else
   reg [13:0] 	adc_a, adc_b, adc_a_pre, adc_b_pre;
   // Mux the clock for these FFs
   wire func_dsp_clk = test_mode ? test_clk : dsp_clk;
   always @(posedge func_dsp_clk)
     begin
	adc_a_pre <= {ADCA_12_p,ADCA_12_n, ADCA_10_p,ADCA_10_n, ADCA_8_p,ADCA_8_n, ADCA_6_p,ADCA_6_n,
		   ADCA_4_p,ADCA_4_n, ADCA_2_p,ADCA_2_n, ADCA_0_p,ADCA_0_n };
	adc_b_pre <= {ADCB_12_p,ADCB_12_n, ADCB_10_p,ADCB_10_n, ADCB_8_p,ADCB_8_n, ADCB_6_p,ADCB_6_n,
		   ADCB_4_p,ADCB_4_n, ADCB_2_p,ADCB_2_n, ADCB_0_p,ADCB_0_n };
	adc_a <= ~adc_a_pre;
	adc_b <= adc_b_pre;
     end
`endif

   // DCM generates internal clocks (dsp_clk, clk_div, clk270_100) - these cause CLKNPI violations
   DCM DCM_INST (.CLKFB(dsp_clk), // Feedback path needs careful consideration in DFT
                 .CLKIN(clk_fpga),
                 .DSSEN(1'b0),
                 .PSCLK(1'b0),
                 .PSEN(1'b0),
                 .PSINCDEC(1'b0),
                 .RST(dcm_rst),
                 .CLKDV(clk_div),
                 .CLKFX(),
                 .CLKFX180(),
                 .CLK0(dcm_out),
                 .CLK2X(),
                 .CLK2X180(),
                 .CLK90(),
                 .CLK180(),
                 .CLK270(clk270_100),
                 .LOCKED(LOCKED_OUT),
                 .PSDONE(),
                 .STATUS());
   defparam DCM_INST.CLK_FEEDBACK = "1X";
   defparam DCM_INST.CLKDV_DIVIDE = 2.0;
   defparam DCM_INST.CLKFX_DIVIDE = 1;
   defparam DCM_INST.CLKFX_MULTIPLY = 4;
   defparam DCM_INST.CLKIN_DIVIDE_BY_2 = "FALSE";
   defparam DCM_INST.CLKIN_PERIOD = 10.000;
   defparam DCM_INST.CLKOUT_PHASE_SHIFT = "NONE";
   defparam DCM_INST.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
   defparam DCM_INST.DFS_FREQUENCY_MODE = "LOW";
   defparam DCM_INST.DLL_FREQUENCY_MODE = "LOW";
   defparam DCM_INST.DUTY_CYCLE_CORRECTION = "TRUE";
   defparam DCM_INST.FACTORY_JF = 16'h8080;
   defparam DCM_INST.PHASE_SHIFT = 0;
   defparam DCM_INST.STARTUP_WAIT = "FALSE";

   BUFG dspclk_BUFG (.I(dcm_out), .O(dsp_clk));
   BUFG wbclk_BUFG (.I(clk_div), .O(wb_clk)); // wb_clk is also internally generated

   // Mux the clock for RAM_CLK generation
   wire func_clk270_100_buf = test_mode ? test_clk : clk270_100_buf;
   BUFG  clk270_100_buf_i1 (.I(clk270_100),
			    .O(clk270_100_buf));
   OFDDRRSE RAM_CLK_i1 (.Q(RAM_CLK),
			.C0(func_clk270_100_buf),             // Muxed clock
			.C1(test_mode ? 1'b0 : ~clk270_100_buf), // Use only C0 during test
			.CE(1'b1), // Ensure CE active during test (original was 1'b1)
			.D0(1'b1),
			.D1(1'b0),
			.R(1'b0),
			.S(1'b0));

   // Need to declare IOBUF outputs/inputs
   wire scl_pad_i, scl_pad_o, scl_pad_oen_o;
   wire sda_pad_i, sda_pad_o, sda_pad_oen_o;
   IOBUF scl_pin(.O(scl_pad_i), .IO(SCL), .I(scl_pad_o), .T(scl_pad_oen_o));
   IOBUF sda_pin(.O(sda_pad_i), .IO(SDA), .I(sda_pad_o), .T(sda_pad_oen_o));

   wire [5:0] leds_int;
   assign     {ETH_LED,leds} = {6'b011111 ^ leds_int};

   wire       miso, mosi, sclk;
   assign 	{SCLK_CLK,MOSI_CLK} 	   = ~SEN_CLK ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_DAC,MOSI_DAC} 	   = ~SEN_DAC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_ADC,MOSI_ADC} 	   = ~SEN_ADC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_TX_DB,MOSI_TX_DB}    = ~SEN_TX_DB ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_TX_DAC,MOSI_TX_DAC}  = ~SEN_TX_DAC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_TX_ADC,MOSI_TX_ADC}  = ~SEN_TX_ADC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_RX_DB,MOSI_RX_DB}    = ~SEN_RX_DB ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_RX_DAC,MOSI_RX_DAC}  = ~SEN_RX_DAC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_RX_ADC,MOSI_RX_ADC}  = ~SEN_RX_ADC ? {sclk,mosi} : 2'B0;
   assign 	miso 			   = (~SEN_CLK & MISO_CLK) | (~SEN_DAC & MISO_DAC) |
					     (~SEN_TX_DB & MISO_TX_DB) | (~SEN_TX_ADC & MISO_TX_ADC) |
					     (~SEN_RX_DB & MISO_RX_DB) | (~SEN_RX_ADC & MISO_RX_ADC);

   wire 	GMII_TX_EN_unreg, GMII_TX_ER_unreg;
   wire [7:0] 	GMII_TXD_unreg;
   wire 	GMII_GTX_CLK_int; // Internally generated clock from u2plus_core

   // Mux the clock for GMII TX registers
   wire func_GMII_GTX_CLK_int = test_mode ? test_clk : GMII_GTX_CLK_int;
   always @(posedge func_GMII_GTX_CLK_int)
     begin
	GMII_TX_EN <= GMII_TX_EN_unreg;
	GMII_TX_ER <= GMII_TX_ER_unreg;
	GMII_TXD <= GMII_TXD_unreg;
     end

   // Mux the clock for GMII GTX CLK output FF
   OFDDRRSE OFDDRRSE_gmii_inst
     (.Q(GMII_GTX_CLK),
      .C0(func_GMII_GTX_CLK_int),             // Muxed clock
      .C1(test_mode ? 1'b0 : ~GMII_GTX_CLK_int), // Use only C0 during test
      .CE(1'b1), // Ensure CE active during test (original was 1)
      .D0(1'b0), // Corrected D0 based on likely intent (0->1)
      .D1(1'b1), // Corrected D1 based on likely intent (0->1)
      .R(1'b0),
      .S(1'b0)
      );

   wire ser_tklsb_unreg, ser_tkmsb_unreg;
   wire [15:0] ser_t_unreg;
   wire        ser_tx_clk_int; // Internally generated clock from u2plus_core

   // Mux the clock for ser TX registers
   wire func_ser_tx_clk_int = test_mode ? test_clk : ser_tx_clk_int;
   always @(posedge func_ser_tx_clk_int)
     begin
	ser_tklsb <= ser_tklsb_unreg;
	ser_tkmsb <= ser_tkmsb_unreg;
	ser_t <= ser_t_unreg;
     end

   // ser_tx_clk output is assigned clk_fpga, which is derived from primary inputs. OK.
   assign ser_tx_clk = clk_fpga;

   reg [15:0] ser_r_int;
   reg 	      ser_rklsb_int, ser_rkmsb_int;
   // Clock ser_rx_clk is a primary input. OK.
   always @(posedge ser_rx_clk)
     begin
	ser_r_int <= ser_r;
	ser_rklsb_int <= ser_rklsb;
	ser_rkmsb_int <= ser_rkmsb;
     end

   wire [35:0] RAM_D_pi;
   wire [35:0] RAM_D_po;
   wire        RAM_D_poe;
   genvar      i;
   generate
      for (i=0;i<36;i=i+1)
        begin : gen_RAM_D_IO
	   IOBUF #(
		   .DRIVE(12),
		   .IOSTANDARD("LVCMOS25"),
		   .SLEW("FAST")
		   )
	     RAM_D_i (
		      .O(RAM_D_pi[i]),
		      .I(RAM_D_po[i]),
		      .IO(RAM_D[i]),
		      .T(RAM_D_poe)
		      );
	end
   endgenerate

   wire [15:0] dac_a_int, dac_b_int;
   // Mux the clock for DAC registers (using the same muxed clock as positive edge FFs)
   // Note: Negedge clocks are generally discouraged in DFT.
   // A better fix might involve redesigning to use posedge only.
   // For this fix, we mux the clock source.
   wire func_dsp_clk_neg = test_mode ? test_clk : dsp_clk;
   always @(negedge func_dsp_clk_neg) DACA <= ~dac_b_int;
   always @(negedge func_dsp_clk_neg) DACB <= dac_a_int;

   wire 	pps;
   assign pps = PPS_IN ^ PPS2_IN;

   // Need to declare missing ports from core if they exist
   wire RAM_CE1n; // Assuming this comes from the core

   // Pass DFT signals into the core assuming it's DFT-aware
   u2plus_core u2p_c(
             // DFT Ports
             .test_mode         (test_mode),
             .test_clk          (test_clk),

             // Original Ports
             .dsp_clk           (dsp_clk),         // Core might need internal muxing for this
		     .wb_clk            (wb_clk),          // Core might need internal muxing for this
		     .clock_ready       (clock_ready),
		     .clk_to_mac	(CLK_TO_MAC_int2), // Derived from primary input CLK_TO_MAC
		     .pps_in		(pps),
		     .leds		(leds_int),
		     .debug