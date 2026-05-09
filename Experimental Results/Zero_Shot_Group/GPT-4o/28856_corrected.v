`timescale 1ns / 1ps

module pcie_compiler_0 (
    input AvlClk_i,
    input [11:0] CraAddress_i,
    input [3:0] CraByteEnable_i,
    input CraChipSelect_i,
    input CraRead,
    input CraWrite,
    input [31:0] CraWriteData_i,
    input [5:0] RxmIrqNum_i,
    input RxmIrq_i,
    input RxmReadDataValid_i,
    input [63:0] RxmReadData_i,
    input RxmWaitRequest_i,
    input [21:0] TxsAddress_i,
    input [9:0] TxsBurstCount_i,
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
    output CraIrq_o,
    output [31:0] CraReadData_o,
    output CraWaitRequest_o,
    output [31:0] RxmAddress_o,
    output [9:0] RxmBurstCount_o,
    output [7:0] RxmByteEnable_o,
    output RxmRead_o,
    output RxmResetRequest_o,
    output [63:0] RxmWriteData_o,
    output RxmWrite_o,
    output TxsReadDataValid_o,
    output [63:0] TxsReadData_o,
    output TxsWaitRequest_o,
    output clk125_out,
    output clk250_out,
    output clk500_out,
    output [3:0] lane_act,
    output [4:0] ltssm,
    output [1:0] powerdown_ext,
    output rate_ext,
    output rc_pll_locked,
    output rc_rx_digitalreset,
    output [16:0] reconfig_fromgxb,
    output reset_status,
    output rxpolarity0_ext,
    output suc_spd_neg,
    output [8:0] test_out,
    output [3:0] tl_cfg_add,
    output [31:0] tl_cfg_ctl,
    output tl_cfg_ctl_wr,
    output [52:0] tl_cfg_sts,
    output tl_cfg_sts_wr,
    output tx_out0,
    output txcompl0_ext,
    output [7:0] txdata0_ext,
    output txdatak0_ext,
    output txdetectrx_ext,
    output txelecidle0_ext
);

reg npor_r, npor_rr;
reg reset_n_r, reset_n_rr;
reg [10:0] rsnt_cntn;
reg srst, crst;
reg RxmResetRequest_o;

assign clk125_out = core_clk_out;
assign test_out = {lane_act, ltssm};
assign app_clk = core_clk_out;
assign txdetectrx_ext = txdetectrx0_ext;
assign powerdown_ext = powerdown0_ext;

always @(posedge pld_clk or negedge npor) begin
    if (!npor) begin
        npor_r <= 0;
        npor_rr <= 0;
    end else begin
        npor_r <= 1;
        npor_rr <= npor_r;
    end
end

always @(posedge pld_clk) begin
    if (!reset_n_rr)
        RxmResetRequest_o <= 0;
    else if (!npor_rr || !l2_exit || !hotrst_exit || !dlup_exit || ltssm == 5'h10)
        RxmResetRequest_o <= 1;
end

always @(posedge pld_clk or negedge reset_n) begin
    if (!reset_n) begin
        reset_n_r <= 0;
        reset_n_rr <= 0;
    end else begin
        reset_n_r <= 1;
        reset_n_rr <= reset_n_r;
    end
end

always @(posedge pld_clk or negedge reset_n_rr) begin
    if (!reset_n_rr)
        rsnt_cntn <= 0;
    else if (rsnt_cntn != 4'hf)
        rsnt_cntn <= rsnt_cntn + 1;
end

always @(posedge pld_clk or negedge reset_n_rr) begin
    if (!reset_n_rr) begin
        srst <= 1;
        crst <= 1;
    end else if (rsnt_cntn == 4'hf) begin
        srst <= 0;
        crst <= 0;
    end
end

assign rc_pll_locked = (pipe_mode_int == 1'b1) ? 1'b1 : pll_locked;
assign gxb_powerdown_int = (pipe_mode_int == 1'b1) ? 1'b1 : gxb_powerdown;
assign pll_powerdown_int = (pipe_mode_int == 1'b1) ? 1'b1 : pll_powerdown;

pcie_compiler_0_core wrapper (
    .AvlClk_i(AvlClk_i),
    .CraAddress_i(CraAddress_i),
    .CraByteEnable_i(CraByteEnable_i),
    .CraChipSelect_i(CraChipSelect_i),
    .CraIrq_o(CraIrq_o),
    .CraRead(CraRead),
    .CraReadData_o(CraReadData_o),
    .CraWaitRequest_o(CraWaitRequest_o),
    .CraWrite(CraWrite),
    .CraWriteData_i(CraWriteData_i),
    .Rstn_i(reset_n),
    .RxmAddress_o(RxmAddress_o),
    .RxmBurstCount_o(RxmBurstCount_o),
    .RxmByteEnable_o(RxmByteEnable_o),
    .RxmIrqNum_i(RxmIrqNum_i),
    .RxmIrq_i(RxmIrq_i),
    .RxmReadDataValid_i(RxmReadDataValid_i),
    .RxmReadData_i(RxmReadData_i),
    .RxmRead_o(RxmRead_o),
    .RxmWaitRequest_i(RxmWaitRequest_i),
    .RxmWriteData_o(RxmWriteData_o),
    .RxmWrite_o(RxmWrite_o),
    .TxsAddress_i(TxsAddress_i),
    .TxsBurstCount_i(TxsBurstCount_i),
    .TxsByteEnable_i(TxsByteEnable_i),
    .TxsChipSelect_i(TxsChipSelect_i),
    .TxsReadDataValid_o(TxsReadDataValid_o),
    .TxsReadData_o(TxsReadData_o),
    .TxsRead_i(TxsRead_i),
    .TxsWaitRequest_o(TxsWaitRequest_o),
    .TxsWriteData_i(TxsWriteData_i),
    .TxsWrite_i(TxsWrite_i),
    .core_clk_out(core_clk_out),
    .ltssm(ltssm),
    .lane_act(lane_act),
    .reset_status(reset_status),
    .tx_out0(tx_out0),
    .txcompl0_ext(txcompl0_ext),
    .txdata0_ext(txdata0_ext),
    .txdatak0_ext(txdatak0_ext),
    .txdetectrx_ext(txdetectrx_ext),
    .txelecidle0_ext(txelecidle0_ext)
);

altpcie_pll_100_250 refclk_to_250mhz (
    .areset(1'b0),
    .c0(clk250_out),
    .inclk0(refclk)
);

altpcie_pll_125_250 pll_250mhz_to_500mhz (
    .areset(1'b0),
    .c0(clk500_out),
    .inclk0(clk250_out)
);

endmodule