module pcie_compiler_0 (
                          AvlClk_i,
                          CraAddress_i,
                          CraByteEnable_i,
                          CraChipSelect_i,
                          CraRead,
                          CraWrite,
                          CraWriteData_i,
                          RxmIrqNum_i,
                          RxmIrq_i,
                          RxmReadDataValid_i,
                          RxmReadData_i,
                          RxmWaitRequest_i,
                          TxsAddress_i,
                          TxsBurstCount_i,
                          TxsByteEnable_i,
                          TxsChipSelect_i,
                          TxsRead_i,
                          TxsWriteData_i,
                          TxsWrite_i,
                          busy_altgxb_reconfig,
                          cal_blk_clk,
                          fixedclk_serdes,
                          gxb_powerdown,
                          pcie_rstn,
                          phystatus_ext,
                          pipe_mode,
                          pll_powerdown,
                          reconfig_clk,
                          reconfig_togxb,
                          refclk,
                          reset_n,
                          rx_in0,
                          rxdata0_ext,
                          rxdatak0_ext,
                          rxelecidle0_ext,
                          rxstatus0_ext,
                          rxvalid0_ext,
                          test_in,
                          test_mode_i,
                          CraIrq_o,
                          CraReadData_o,
                          CraWaitRequest_o,
                          RxmAddress_o,
                          RxmBurstCount_o,
                          RxmByteEnable_o,
                          RxmRead_o,
                          RxmResetRequest_o,
                          RxmWriteData_o,
                          RxmWrite_o,
                          TxsReadDataValid_o,
                          TxsReadData_o,
                          TxsWaitRequest_o,
                          clk125_out,
                          clk250_out,
                          clk500_out,
                          lane_act,
                          ltssm,
                          powerdown_ext,
                          rate_ext,
                          rc_pll_locked,
                          rc_rx_digitalreset,
                          reconfig_fromgxb,
                          reset_status,
                          rxpolarity0_ext,
                          suc_spd_neg,
                          test_out,
                          tl_cfg_add,
                          tl_cfg_ctl,
                          tl_cfg_ctl_wr,
                          tl_cfg_sts,
                          tl_cfg_sts_wr,
                          tx_out0,
                          txcompl0_ext,
                          txdata0_ext,
                          txdatak0_ext,
                          txdetectrx_ext,
                          txelecidle0_ext,
                          iCLK_18_4,
                          iRST_N,
                          oAUD_BCK
                       );

input AvlClk_i;
input [11:0] CraAddress_i;
input [3:0] CraByteEnable_i;
input CraChipSelect_i;
input CraRead;
input CraWrite;
input [31:0] CraWriteData_i;
input [4:0] RxmIrqNum_i;
input RxmIrq_i;
input RxmReadDataValid_i;
input [63:0] RxmReadData_i;
input RxmWaitRequest_i;
input [63:0] TxsAddress_i;
input [6:0] TxsBurstCount_i;
input [7:0] TxsByteEnable_i;
input TxsChipSelect_i;
input TxsRead_i;
input [63:0] TxsWriteData_i;
input TxsWrite_i;
input busy_altgxb_reconfig;
input cal_blk_clk;
input fixedclk_serdes;
input gxb_powerdown;
input pcie_rstn;
input phystatus_ext;
input pipe_mode;
input pll_powerdown;
input reconfig_clk;
input [3:0] reconfig_togxb;
input refclk;
input reset_n;
input rx_in0;
input [7:0] rxdata0_ext;
input rxdatak0_ext;
input rxelecidle0_ext;
input [2:0] rxstatus0_ext;
input rxvalid0_ext;
input [39:0] test_in;
input test_mode_i;
output CraIrq_o;
output [31:0] CraReadData_o;
output CraWaitRequest_o;
output [63:0] RxmAddress_o;
output [6:0] RxmBurstCount_o;
output [7:0] RxmByteEnable_o;
output RxmRead_o;
output RxmResetRequest_o;
output [63:0] RxmWriteData_o;
output RxmWrite_o;
output TxsReadDataValid_o;
output [63:0] TxsReadData_o;
output TxsWaitRequest_o;
output clk125_out;
output clk250_out;
output clk500_out;
output lane_act;
output [4:0] ltssm;
output [1:0] powerdown_ext;
output rate_ext;
output rc_pll_locked;
output rc_rx_digitalreset;
output [4:0] reconfig_fromgxb;
output reset_status;
output rxpolarity0_ext;
output suc_spd_neg;
output [39:0] test_out;
output [3:0] tl_cfg_add;
output [31:0] tl_cfg_ctl;
output tl_cfg_ctl_wr;
output [12:0] tl_cfg_sts;
output tl_cfg_sts_wr;
output tx_out0;
output txcompl0_ext;
output [7:0] txdata0_ext;
output txdatak0_ext;
output txdetectrx_ext;
output txelecidle0_ext;
input iCLK_18_4;
input iRST_N;
output oAUD_BCK;

reg oAUD_BCK;
reg [3:0] SEL_Cont;
wire dftoAUD_BCK;

assign dftoAUD_BCK = test_mode_i ? iCLK_18_4 : oAUD_BCK;

always@(posedge iCLK_18_4 or negedge iRST_N)
begin
  if(!iRST_N)
    SEL_Cont <= 0;
  else
    SEL_Cont <= SEL_Cont+1;
end

endmodule