`timescale 1ns / 1ps
`timescale 1ns / 1ps
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
                          txelecidle0_ext
                       );

// ... existing code ...

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

// ... existing code ...

endmodule