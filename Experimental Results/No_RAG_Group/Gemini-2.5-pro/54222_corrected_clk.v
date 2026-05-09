`timescale 1 ps / 1 ps
module onetswitch_top_corrected_clk (
   inout [14:0]         DDR_addr,
   inout [2:0]          DDR_ba,
   inout                DDR_cas_n,
   inout                DDR_ck_n,
   inout                DDR_ck_p,
   inout                DDR_cke,
   inout                DDR_cs_n,
   inout [3:0]          DDR_dm,
   inout [31:0]         DDR_dq,
   inout [3:0]          DDR_dqs_n,
   inout [3:0]          DDR_dqs_p,
   inout                DDR_odt,
   inout                DDR_ras_n,
   inout                DDR_reset_n,
   inout                DDR_we_n,
   inout                FIXED_IO_ddr_vrn,
   inout                FIXED_IO_ddr_vrp,
   inout [53:0]         FIXED_IO_mio,
   inout                FIXED_IO_ps_clk,
   inout                FIXED_IO_ps_porb,
   inout                FIXED_IO_ps_srstb,
   input                sgmii_refclk_p,
   input                sgmii_refclk_n,
   input [3:0]          sgmii_rxn,
   input [3:0]          sgmii_rxp,
   output [3:0]         sgmii_txn,
   output [3:0]         sgmii_txp,
   output               mdio_mdc,
   inout                mdio_mdio,
   output [1:0]         pl_led,
   output [1:0]         pl_pmod,
   input                pl_btn,

   // DFT Inputs
   input                test_clk,       // Test clock input
   input                scan_enable,    // Scan enable signal
   input                test_rst_n      // Test reset input (active low)
);
   wire bd_fclk0_125m ;
   wire bd_fclk1_75m  ;
   wire bd_fclk2_200m ;
   wire bd_aresetn ;

   // DFT Clock and Reset Muxing
   wire clk_mux_0;
   wire clk_mux_1;
   wire clk_mux_2;
   wire rst_n_mux;

   assign clk_mux_0 = scan_enable ? test_clk : bd_fclk0_125m;
   assign clk_mux_1 = scan_enable ? test_clk : bd_fclk1_75m;
   assign clk_mux_2 = scan_enable ? test_clk : bd_fclk2_200m;
   assign rst_n_mux = scan_enable ? test_rst_n : bd_aresetn; // Mux between test reset and functional reset

   reg [23:0] cnt_0;
   reg [23:0] cnt_1;
   reg [23:0] cnt_2;
   reg [23:0] cnt_3;

   // Modified counters with muxed clock and synchronous reset
   always @(posedge clk_mux_0 or negedge rst_n_mux) begin
     if (!rst_n_mux) begin
       cnt_0 <= 24'b0;
     end else begin
       cnt_0 <= cnt_0 + 1'b1;
     end
   end

   always @(posedge clk_mux_1 or negedge rst_n_mux) begin
     if (!rst_n_mux) begin
       cnt_1 <= 24'b0;
     end else begin
       cnt_1 <= cnt_1 + 1'b1;
     end
   end

   always @(posedge clk_mux_2 or negedge rst_n_mux) begin
     if (!rst_n_mux) begin
       cnt_2 <= 24'b0;
     end else begin
       cnt_2 <= cnt_2 + 1'b1;
     end
   end

   always @(posedge clk_mux_2 or negedge rst_n_mux) begin
     if (!rst_n_mux) begin
       cnt_3 <= 24'b0;
     end else begin
       cnt_3 <= cnt_3 + 1'b1;
     end
   end

   assign pl_led[0]  = cnt_0[23];
   assign pl_led[1]  = cnt_1[23];
   assign pl_pmod[0] = cnt_3[23];
   // Assigning the muxed reset to pl_pmod[1] for observability during test/functional mode if needed,
   // or connect it to a test point. Original connected bd_aresetn directly.
   // Connecting rst_n_mux maintains similar behavior but reflects the controllable reset.
   assign pl_pmod[1] = rst_n_mux;

   // Assuming onets_bd_wrapper is a pre-compiled or synthesized block
   // It does not need modification here, but its internal clocks drive the bd_fclk* wires
   onets_bd_wrapper i_onets_bd_wrapper(
      .DDR_addr               (DDR_addr),
      .DDR_ba                 (DDR_ba),
      .DDR_cas_n              (DDR_cas_n),
      .DDR_ck_n               (DDR_ck_n),
      .DDR_ck_p               (DDR_ck_p),
      .DDR_cke                (DDR_cke),
      .DDR_cs_n               (DDR_cs_n),
      .DDR_dm                 (DDR_dm),
      .DDR_dq                 (DDR_dq),
      .DDR_dqs_n              (DDR_dqs_n),
      .DDR_dqs_p              (DDR_dqs_p),
      .DDR_odt                (DDR_odt),
      .DDR_ras_n              (DDR_ras_n),
      .DDR_reset_n            (DDR_reset_n),
      .DDR_we_n               (DDR_we_n),
      .FIXED_IO_ddr_vrn       (FIXED_IO_ddr_vrn),
      .FIXED_IO_ddr_vrp       (FIXED_IO_ddr_vrp),
      .FIXED_IO_mio           (FIXED_IO_mio),
      .FIXED_IO_ps_clk        (FIXED_IO_ps_clk),
      .FIXED_IO_ps_porb       (FIXED_IO_ps_porb),
      .FIXED_IO_ps_srstb      (FIXED_IO_ps_srstb),
      .mdio_mdc               (mdio_mdc   ),
      .mdio_mdio_io           (mdio_mdio  ),
      .ref_clk_125_n          (sgmii_refclk_n ),
      .ref_clk_125_p          (sgmii_refclk_p ),
      .sgmii_0_rxn            (sgmii_rxn[0]  ),
      .sgmii_0_rxp            (sgmii_rxp[0]  ),
      .sgmii_0_txn            (sgmii_txn[0]  ),
      .sgmii_0_txp            (sgmii_txp[0]  ),
      .sgmii_1_rxn            (sgmii_rxn[1]  ),
      .sgmii_1_rxp            (sgmii_rxp[1]  ),
      .sgmii_1_txn            (sgmii_txn[1]  ),
      .sgmii_1_txp            (sgmii_txp[1]  ),
      .sgmii_2_rxn            (sgmii_rxn[2]  ),
      .sgmii_2_rxp            (sgmii_rxp[2]  ),
      .sgmii_2_txn            (sgmii_txn[2]  ),
      .sgmii_2_txp            (sgmii_txp[2]  ),
      .sgmii_3_rxn            (sgmii_rxn[3]  ),
      .sgmii_3_rxp            (sgmii_rxp[3]  ),
      .sgmii_3_txn            (sgmii_txn[3]  ),
      .sgmii_3_txp            (sgmii_txp[3]  ),
      .bd_fclk0_125m          ( bd_fclk0_125m   ), // Functional clock output from wrapper
      .bd_fclk1_75m           ( bd_fclk1_75m    ), // Functional clock output from wrapper
      .bd_fclk2_200m          ( bd_fclk2_200m   ), // Functional clock output from wrapper
      .bd_aresetn             ( bd_aresetn      ), // Functional reset output from wrapper
      .ext_rst                ( pl_btn )
   );
endmodule