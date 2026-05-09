`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module onetswitch_top(
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
   input                pl_btn
);
   wire bd_fclk0_125m ;
   wire bd_fclk1_75m  ;
   wire bd_fclk2_200m ;
   wire bd_aresetn ;
   reg [23:0] cnt_0;
   reg [23:0] cnt_1;
   reg [23:0] cnt_2;
   reg [23:0] cnt_3;
   
   wire test_i; // Added test mode signal
   wire scan_clk0, scan_clk1, scan_clk2; // Added scan clock signals
   
   assign test_i = 1'b0; // Default test mode signal
   
   always @(posedge (test_i ? scan_clk0 : bd_fclk0_125m) or negedge bd_aresetn) begin
     if (!bd_aresetn)
       cnt_0 <= 24'b0;
     else
       cnt_0 <= cnt_0 + 1'b1;
   end
   
   always @(posedge (test_i ? scan_clk1 : bd_fclk1_75m) or negedge bd_aresetn) begin
     if (!bd_aresetn)
       cnt_1 <= 24'b0;
     else
       cnt_1 <= cnt_1 + 1'b1;
   end
   
   always @(posedge (test_i ? scan_clk2 : bd_fclk2_200m) or negedge bd_aresetn) begin
     if (!bd_aresetn) begin
       cnt_2 <= 24'b0;
       cnt_3 <= 24'b0;
     end else begin
       cnt_2 <= cnt_2 + 1'b1;
       cnt_3 <= cnt_3 + 1'b1;
     end
   end
   
   assign pl_led[0]  = cnt_0[23];
   assign pl_led[1]  = cnt_1[23];
   assign pl_pmod[0] = cnt_3[23];
   assign pl_pmod[1] = bd_aresetn;

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
   .bd_fclk0_125m       ( bd_fclk0_125m   ),
   .bd_fclk1_75m        ( bd_fclk1_75m    ),
   .bd_fclk2_200m       ( bd_fclk2_200m   ),
   .bd_aresetn          ( bd_aresetn      ),
   .ext_rst             ( pl_btn )
);
endmodule