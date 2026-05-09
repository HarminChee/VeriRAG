// 1_corrected_clk.v
`define EP64          1
`define IOSTND        "PPDS_25"
`define CLKEDGE       "SAME_EDGE"
`define PHYS_EXT_MEM  4'h3
`define EP64          1
`define IOSTND        "PPDS_25"
`define CLKEDGE       "SAME_EDGE"
`define PHYS_EXT_MEM  4'h3
module top_parallella64_prototype (
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
   aafm_i2c_sda, user_pb,
   // DFT inputs
   scan_enable, test_clk
   );
   parameter SIDW = 12;
   parameter SAW  = 32;
   parameter SDW  = 32;
   parameter MIDW = 6;
   parameter MAW  = 32;
   parameter MDW  = 64;
   parameter STW  = 8;
   parameter DPW  = 20;
   inout [53:0] processing_system7_0_MIO;
   input 	processing_system7_0_PS_SRSTB;
   input 	processing_system7_0_PS_CLK;
   input 	processing_system7_0_PS_PORB;
   inout 	processing_system7_0_DDR_Clk;
   inout 	processing_system7_0_DDR_Clk_n;
   inout 	processing_system7_0_DDR_CKE;
   inout 	processing_system7_0_DDR_CS_n;
   inout 	processing_system7_0_DDR_RAS_n;
   inout 	processing_system7_0_DDR_CAS_n;
   output 	processing_system7_0_DDR_WEB_pin;
   inout [2:0] 	processing_system7_0_DDR_BankAddr;
   inout [14:0] processing_system7_0_DDR_Addr;
   inout 	processing_system7_0_DDR_ODT;
   inout 	processing_system7_0_DDR_DRSTB;
   inout [31:0] processing_system7_0_DDR_DQ;
   inout [3:0] 	processing_system7_0_DDR_DM;
   inout [3:0] 	processing_system7_0_DDR_DQS;
   inout [3:0] 	processing_system7_0_DDR_DQS_n;
   inout 	processing_system7_0_DDR_VRN;
   inout 	processing_system7_0_DDR_VRP;
   input [7:0] 	   rxi_data_p;
   input [7:0] 	   rxi_data_n;
   input 	   rxi_frame_p;
   input 	   rxi_frame_n;
   input 	   rxi_lclk_p;
   input 	   rxi_lclk_n;
   input 	   txo_wr_wait_p;
   input 	   txo_wr_wait_n;
   input 	   txo_rd_wait_p;
   input 	   txo_rd_wait_n;
   output [7:0]    txo_data_p;
   output [7:0]    txo_data_n;
   output 	   txo_frame_p;
   output 	   txo_frame_n;
   output 	   txo_lclk_p;
   output 	   txo_lclk_n;
   output 	   rxi_wr_wait_p;
   output 	   rxi_wr_wait_n;
   output 	   rxi_rd_wait_p;
   output 	   rxi_rd_wait_n;
   output 	   aafm_resetn;
   output [2:0]    aafm_ctrl;
   output 	   aafm_xid0;
   output 	   aafm_xid1;
   output 	   aafm_xid2;
   output 	   aafm_i2c_scl;
   input 	   aafm_flag0;
   input 	   aafm_flag1;
   input 	   aafm_flag2;
   input 	   aafm_flag3;
   input 	   aafm_yid0;
   input 	   aafm_yid1;
   input 	   aafm_yid2;
   input [3:0] 	   aafm_misc;
   input 	   aafm_i2c_sda;
   output [7:0]    user_led;
   input [1:0] 	   user_pb;
   // DFT inputs
   input           scan_enable; // Scan mode control
   input           test_clk;    // Clock input for scan

   wire			cactive;
   wire			csysack;
   wire			processing_system7_0_FCLK_CLK0_pin;
   wire			processing_system7_0_FCLK_CLK3_pin;
   wire [31:0]		processing_system7_0_M_AXI_GP1_ARADDR_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_ARBURST_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_ARCACHE_pin;
   wire			processing_system7_0_M_AXI_GP1_ARESETN_pin;
   wire [11:0]		processing_system7_0_M_AXI_GP1_ARID_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_ARLEN_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_ARLOCK_pin;
   wire [2:0]		processing_system7_0_M_AXI_GP1_ARPROT_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_ARQOS_pin;
   wire			processing_system7_0_M_AXI_GP1_ARREADY_pin;
   wire [2:0]		processing_system7_0_M_AXI_GP1_ARSIZE_pin;
   wire			processing_system7_0_M_AXI_GP1_ARVALID_pin;
   wire [31:0]		processing_system7_0_M_AXI_GP1_AWADDR_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_AWBURST_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_AWCACHE_pin;
   wire [11:0]		processing_system7_0_M_AXI_GP1_AWID_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_AWLEN_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_AWLOCK_pin;
   wire [2:0]		processing_system7_0_M_AXI_GP1_AWPROT_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_AWQOS_pin;
   wire			processing_system7_0_M_AXI_GP1_AWREADY_pin;
   wire [2:0]		processing_system7_0_M_AXI_GP1_AWSIZE_pin;
   wire			processing_system7_0_M_AXI_GP1_AWVALID_pin;
   wire [SIDW-1:0]	processing_system7_0_M_AXI_GP1_BID_pin;
   wire			processing_system7_0_M_AXI_GP1_BREADY_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_BRESP_pin;
   wire			processing_system7_0_M_AXI_GP1_BVALID_pin;
   wire [SDW-1:0]	processing_system7_0_M_AXI_GP1_RDATA_pin;
   wire [SIDW-1:0]	processing_system7_0_M_AXI_GP1_RID_pin;
   wire			processing_system7_0_M_AXI_GP1_RLAST_pin;
   wire			processing_system7_0_M_AXI_GP1_RREADY_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_RRESP_pin;
   wire			processing_system7_0_M_AXI_GP1_RVALID_pin;
   wire [31:0]		processing_system7_0_M_AXI_GP1_WDATA_pin;
   wire [11:0]		processing_system7_0_M_AXI_GP1_WID_pin;
   wire			processing_system7_0_M_AXI_GP1_WLAST_pin;
   wire			processing_system7_0_M_AXI_GP1_WREADY_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_WSTRB_pin;
   wire			processing_system7_0_M_AXI_GP1_WVALID_pin;
   wire [MAW-1:0]	processing_system7_0_S_AXI_HP1_ARADDR_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_ARBURST_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_ARCACHE_pin;
   wire			processing_system7_0_S_AXI_HP1_ARESETN_pin;
   wire [MIDW-1:0]	processing_system7_0_S_AXI_HP1_ARID_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_ARLEN_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_ARLOCK_pin;
   wire [2:0]		processing_system7_0_S_AXI_HP1_ARPROT_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_ARQOS_pin;
   wire			processing_system7_0_S_AXI_HP1_ARREADY_pin;
   wire [2:0]		processing_system7_0_S_AXI_HP1_ARSIZE_pin;
   wire			processing_system7_0_S_AXI_HP1_ARVALID_pin;
   wire [MAW-1:0]	processing_system7_0_S_AXI_HP1_AWADDR_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_AWBURST_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_AWCACHE_pin;
   wire [MIDW-1:0]	processing_system7_0_S_AXI_HP1_AWID_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_AWLEN_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_AWLOCK_pin;
   wire [2:0]		processing_system7_0_S_AXI_HP1_AWPROT_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_AWQOS_pin;
   wire			processing_system7_0_S_AXI_HP1_AWREADY_pin;
   wire [2:0]		processing_system7_0_S_AXI_HP1_AWSIZE_pin;
   wire			processing_system7_0_S_AXI_HP1_AWVALID_pin;
   wire [5:0]		processing_system7_0_S_AXI_HP1_BID_pin;
   wire			processing_system7_0_S_AXI_HP1_BREADY_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_BRESP_pin;
   wire			processing_system7_0_S_AXI_HP1_BVALID_pin;
   wire [63:0]		processing_system7_0_S_AXI_HP1_RDATA_pin;
   wire [5:0]		processing_system7_0_S_AXI_HP1_RID_pin;
   wire			processing_system7_0_S_AXI_HP1_RLAST_pin;
   wire			processing_system7_0_S_AXI_HP1_RREADY_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_RRESP_pin;
   wire			processing_system7_0_S_AXI_HP1_RVALID_pin;
   wire [MDW-1:0]	processing_system7_0_S_AXI_HP1_WDATA_pin;
   wire [MIDW-1:0]	processing_system7_0_S_AXI_HP1_WID_pin;
   wire			processing_system7_0_S_AXI_HP1_WLAST_pin;
   wire			processing_system7_0_S_AXI_HP1_WREADY_pin;
   wire [STW-1:0]	processing_system7_0_S_AXI_HP1_WSTRB_pin;
   wire			processing_system7_0_S_AXI_HP1_WVALID_pin;
   wire			reset_chip;
   wire			reset_fpga;
   reg [19:0]    por_cnt;
   reg           por_reset;
   reg [1:0] 	 user_pb_clean_reg;
   reg [31:0]    counter_reg;
   wire 	 sys_clk;
   wire 	 esaxi_areset;
   wire 	 fpga_reset;
   wire 	 pbr_reset;
   wire [1:0] 	 user_pb_clean;
   wire          dft_clk; // Clock signal selected for DFT/functional mode

   assign sys_clk      =  processing_system7_0_FCLK_CLK3_pin;
   assign esaxi_areset = ~processing_system7_0_M_AXI_GP1_ARESETN_pin;
   assign aafm_ctrl[2:0] = 3'b000;
   assign aafm_xid0      = 1'b0;
   assign aafm_xid1      = 1'b1;
   assign aafm_xid2      = 1'b0;
   assign aafm_i2c_scl   = 1'b0;

   // DFT Clock Mux: Select test_clk during scan_enable, otherwise use functional sys_clk
   assign dft_clk = scan_enable ? test_clk : sys_clk;

   genvar   k;
   generate
      for(k=0;k<2;k=k+1) begin : gen_debounce
         // Use dft_clk for the debouncer module
         debouncer #(DPW) debouncer (.clean_out   (user_pb_clean[k]),
                                     .clk         (dft_clk),
                                     .noisy_in    (user_pb[k]));
      end
   endgenerate

   // Use dft_clk for this register
   always @(posedge dft_clk)
      user_pb_clean_reg[1:0] <= user_pb_clean[1:0];

   // Use dft_clk for this register. Added async reset for better DFT.
   always @ (posedge dft_clk or posedge processing_system7_0_PS_SRSTB) // Assuming PS_SRSTB is a valid global reset
     begin
        if (processing_system7_0_PS_SRSTB) begin // Use an active high reset
             por_reset     <= 1'b1;
             por_cnt[19:0] <= 20'd0;
        end else begin
             if (por_cnt[19:0] == 20'hff13f)
               begin
                  por_reset     <= 1'b0;
                  por_cnt[19:0] <= por_cnt[19:0];
               end
             else
               begin
                  por_reset     <= 1'b1;
                  por_cnt[19:0] <= por_cnt[19:0] + 1'b1;
               end
        end
     end

   assign pbr_reset     =  user_pb_clean[0];
   assign user_led[7:0] = ~counter_reg[30:23];

   // Use dft_clk for this register. Keep existing async reset fpga_reset.
   always @ (posedge dft_clk or posedge fpga_reset)
     if(fpga_reset)
       counter_reg[31:0] <= 32'b0;
     else
       counter_reg[31:0] <= counter_reg[31:0] + 1'b1;

   // Note: por_reset is now synchronous to dft_clk (with async reset)
   // Ensure fpga_reset logic considers timing if por_reset changes clock domain.
   // For simplicity here, we keep the combinational assignment, but this might need review in a real design.
   assign fpga_reset = por_reset | pbr_reset | esaxi_areset | reset_fpga;
   assign aafm_resetn = ~(por_reset | pbr_reset | reset_chip); // Also depends on por_reset timing


   parallella parallella(
			 .csysack		(csysack),
			 .cactive		(cactive),
			 .reset_chip		(reset_chip),
			 .reset_fpga		(reset_fpga),
			 .txo_data_p		(txo_data_p[7:0]),
			 .txo_data_n		(txo_data_n[7:0]),
			 .txo_frame_p		(txo_frame_p),
			 .txo_frame_n		(txo_frame_n),
			 .txo_lclk_p		(txo_lclk_p),
			 .txo_lclk_n		(txo_lclk_n),
			 .rxi_wr_wait_p		(rxi_wr_wait_p),
			 .rxi_wr_wait_n		(rxi_wr_wait_n),
			 .rxi_rd_wait_p		(rxi_rd_wait_p),
			 .rxi_rd_wait_n		(rxi_rd_wait_n),
			 .rxi_cclk_p		(),
			 .rxi_cclk_n		(),
			 .emaxi_awid		(processing_system7_0_S_AXI_HP1_AWID_pin[MIDW-1:0]),
			 .emaxi_awaddr		(processing_system7_0_S_AXI_HP1_AWADDR_pin[MAW-1:0]),
			 .emaxi_awlen		(processing_system7_0_S_AXI_HP1_AWLEN_pin[3:0]),
			 .emaxi_awsize		(processing_system7_0_S_AXI_HP1_AWSIZE_pin[2:0]),
			 .emaxi_awburst		(processing_system7_0_S_AXI_HP1_AWBURST_pin[1:0]),
			 .emaxi_awlock		(processing_system7_0_S_AXI_HP1_AWLOCK_pin[1:0]),
			 .emaxi_awcache		(processing_system7_0_S_AXI_HP1_AWCACHE_pin[3:0]),
			 .emaxi_awprot		(processing_system7_0_S_AXI_HP1_AWPROT_pin[2:0]),
			 .emaxi_awvalid		(processing_system7_0_S_AXI_HP1_AWVALID_pin),
			 .esaxi_awready		(processing_system7_0_M_AXI_GP1_AWREADY_pin),
			 .emaxi_wid		(processing_system7_0_S_AXI_HP1_WID_pin[MIDW-1:0]),
			 .emaxi_wdata		(processing_system7_0_S_AXI_HP1_WDATA_pin[MDW-1:0]),
			 .emaxi_wstrb		(processing_system7_0_S_AXI_HP1_WSTRB_pin[STW-1:0]),
			 .emaxi_wlast		(processing_system7_0_S_AXI_HP1_WLAST_pin),
			 .emaxi_wvalid		(processing_system7_0_S_AXI_HP1_WVALID_pin),
			 .esaxi_wready		(processing_system7_0_M_AXI_GP1_WREADY_pin),
			 .emaxi_bready		(processing_system7_0_S_AXI_HP1_BREADY_pin),
			 .esaxi_bid		(processing_system7_0_M_AXI_GP1_BID_pin[SIDW-1:0