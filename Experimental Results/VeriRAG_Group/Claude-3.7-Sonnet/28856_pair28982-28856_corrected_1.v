`timescale 1ns / 1ps
module pcie_compiler_0 (
                          input AvlClk_i,
                          input [11:0] CraAddress_i,
                          input [3:0] CraByteEnable_i, 
                          input CraChipSelect_i,
                          input CraRead,
                          input CraWrite,
                          input [31:0] CraWriteData_i,
                          input [3:0] RxmIrqNum_i,
                          input RxmIrq_i,
                          input RxmReadDataValid_i,
                          input [63:0] RxmReadData_i,
                          input RxmWaitRequest_i,
                          input [63:0] TxsAddress_i,
                          input [6:0] TxsBurstCount_i,
                          input [7:0] TxsByteEnable_i,
                          input TxsChipSelect_i,
                          input TxsRead_i,
                          input [63:0] TxsWriteData_i,
                          input TxsWrite_i,
                          input busy_altgxb_reconfig,
                          input cal_blk_clk,
                          input fixedclk_serdes,
                          input gxb_powerdown,
                          input pcie_rstn,
                          input phystatus_ext,
                          input pipe_mode,
                          input pll_powerdown,
                          input reconfig_clk,
                          input [3:0] reconfig_togxb,
                          input refclk,
                          input reset_n,
                          input rx_in0,
                          input [7:0] rxdata0_ext,
                          input rxdatak0_ext,
                          input rxelecidle0_ext,
                          input [2:0] rxstatus0_ext,
                          input rxvalid0_ext,
                          input [39:0] test_in,
                          output reg CraIrq_o,
                          output reg [31:0] CraReadData_o,
                          output reg CraWaitRequest_o,
                          output reg [63:0] RxmAddress_o,
                          output reg [6:0] RxmBurstCount_o,
                          output reg [7:0] RxmByteEnable_o,
                          output reg RxmRead_o,
                          output reg RxmResetRequest_o,
                          output reg [63:0] RxmWriteData_o,
                          output reg RxmWrite_o,
                          output reg TxsReadDataValid_o,
                          output reg [63:0] TxsReadData_o,
                          output reg TxsWaitRequest_o,
                          output reg clk125_out,
                          output reg clk250_out,
                          output reg clk500_out,
                          output reg lane_act,
                          output reg [4:0] ltssm,
                          output reg [1:0] powerdown_ext,
                          output reg rate_ext,
                          output reg rc_pll_locked,
                          output reg rc_rx_digitalreset,
                          output reg [4:0] reconfig_fromgxb,
                          output reg reset_status,
                          output reg rxpolarity0_ext,
                          output reg suc_spd_neg,
                          output reg [39:0] test_out,
                          output reg [3:0] tl_cfg_add,
                          output reg [31:0] tl_cfg_ctl,
                          output reg tl_cfg_ctl_wr,
                          output reg [12:0] tl_cfg_sts,
                          output reg tl_cfg_sts_wr,
                          output reg tx_out0,
                          output reg txcompl0_ext,
                          output reg [7:0] txdata0_ext,
                          output reg txdatak0_ext,
                          output reg txdetectrx_ext,
                          output reg txelecidle0_ext
                       );

reg reset_n_r;
reg reset_n_rr;
reg [10:0] rsnt_cntn;
reg srst;
reg crst;
reg pld_clk;

always @(posedge pld_clk or negedge reset_n) begin
  if (!reset_n) begin
    reset_n_r <= 1'b0;
    reset_n_rr <= 1'b0;
  end
  else begin
    reset_n_r <= 1'b1;
    reset_n_rr <= reset_n_r;
  end
end

always @(posedge pld_clk or negedge reset_n_rr) begin
  if (!reset_n_rr) begin
    rsnt_cntn <= 11'h0;
  end
  else if (rsnt_cntn != 11'h7ff) begin
    rsnt_cntn <= rsnt_cntn + 11'h1;
  end
end

always @(posedge pld_clk or negedge reset_n_rr) begin
  if (!reset_n_rr) begin
    srst <= 1'b1;
    crst <= 1'b1;
  end
  else if (rsnt_cntn == 11'h7ff) begin
    srst <= 1'b0;
    crst <= 1'b0;
  end
end

endmodule