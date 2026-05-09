`timescale 1ps/1ps
module example_top #
  (
   parameter BEGIN_ADDRESS         = 32'h00000000,
   parameter END_ADDRESS           = 32'h00ffffff,
   parameter PRBS_EADDR_MASK_POS   = 32'hff000000,
   parameter ENFORCE_RD_WR         = 0,
   parameter ENFORCE_RD_WR_CMD     = 8'h11,
   parameter ENFORCE_RD_WR_PATTERN = 3'b000,
   parameter C_EN_WRAP_TRANS       = 0,
   parameter C_AXI_NBURST_TEST     = 0,
   parameter BANK_WIDTH            = 3,
   parameter COL_WIDTH             = 10,
   parameter CS_WIDTH              = 1,
   parameter DQ_WIDTH              = 16,
   parameter DQS_WIDTH             = 2,
   parameter DQS_CNT_WIDTH         = 1,
   parameter DRAM_WIDTH            = 8,
   parameter ECC                   = "OFF",
   parameter ECC_TEST              = "OFF",
   parameter nBANK_MACHS           = 4,
   parameter RANKS                 = 1,
   parameter ROW_WIDTH             = 13,
   parameter ADDR_WIDTH            = 27,
   parameter BURST_MODE            = "8",
   parameter SIMULATION            = "FALSE",
   parameter TCQ                   = 100,
   parameter nCK_PER_CLK           = 2,
   parameter UI_EXTRA_CLOCKS = "FALSE",
   parameter C_S_AXI_ID_WIDTH              = 4,
   parameter C_S_AXI_ADDR_WIDTH            = 32,
   parameter C_S_AXI_DATA_WIDTH            = 32,
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 0,
   parameter C_S_AXI_CTRL_ADDR_WIDTH       = 32,
   parameter C_S_AXI_CTRL_DATA_WIDTH       = 32,
   parameter DEBUG_PORT            = "OFF"
   )
  (
   input                                        test_i,
   input                                        scan_chain_rst,
   inout [15:0]                         ddr2_dq,
   inout [1:0]                        ddr2_dqs_n,
   inout [1:0]                        ddr2_dqs_p,
   output [12:0]                       ddr2_addr,
   output [2:0]                      ddr2_ba,
   output                                       ddr2_ras_n,
   output                                       ddr2_cas_n,
   output                                       ddr2_we_n,
   output [0:0]                        ddr2_ck_p,
   output [0:0]                        ddr2_ck_n,
   output [0:0]                       ddr2_cke,
   output [0:0]           ddr2_cs_n,
   output [1:0]                        ddr2_dm,
   output [0:0]                       ddr2_odt,
   input                                        sys_clk_i,
   output                                       tg_compare_error,
   output                                       init_calib_complete,
   input  [11:0]                                device_temp_i,
   input                                        sys_rst
   );

  wire clk_dft, rst_dft;
  assign clk_dft = test_i ? sys_clk_i : clk;
  assign rst_dft = test_i ? scan_chain_rst : rst;

  reg aresetn;
  always @(posedge clk_dft or posedge rst_dft) begin
    if (rst_dft)
      aresetn <= 1'b0;
    else  
      aresetn <= ~rst;
  end

endmodule