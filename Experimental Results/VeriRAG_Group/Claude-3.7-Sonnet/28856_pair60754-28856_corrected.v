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

always @(posedge pld_clk or negedge reset_n)
begin
  if (reset_n == 0) begin
    reset_n_r <= 0;
    reset_n_rr <= 0;
  end
  else begin
    reset_n_r <= 1;
    reset_n_rr <= reset_n_r;
  end
end

always @(posedge pld_clk or negedge reset_n_rr)
begin
  if (reset_n_rr == 0)
    rsnt_cntn <= 0;
  else if (rsnt_cntn != 4'hf)
    rsnt_cntn <= rsnt_cntn + 1;
end

always @(posedge pld_clk or negedge reset_n_rr)
begin
  if (reset_n_rr == 0) begin
    srst <= 1;
    crst <= 1;
  end
  else if (rsnt_cntn == 4'hf) begin
    srst <= 0;
    crst <= 0;
  end
end

// ... existing code ...

assign rx_in = rx_in0;
assign tx_out0 = tx_out;
assign rc_inclk_eq_125mhz = 1;
assign pclk_central_serdes = 0;
assign pll_fixed_clk_serdes = rateswitchbaseclock;
assign rc_pll_locked = (pipe_mode_int == 1'b1) ? 1'b1 : &pll_locked;
assign gxb_powerdown_int = (pipe_mode_int == 1'b1) ? 1'b1 : gxb_powerdown;
assign pll_powerdown_int = (pipe_mode_int == 1'b1) ? 1'b1 : pll_powerdown;
assign rx_cruclk = refclk;
assign rc_areset = pipe_mode_int | ~npor | busy_altgxb_reconfig;
assign pclk_central = (pipe_mode_int == 1'b1) ? pclk_in : pclk_central_serdes;
assign pclk_ch0 = (pipe_mode_int == 1'b1) ? pclk_in : pclk_ch0_serdes;
assign rateswitch = rate_int;
assign rate_ext = pipe_mode_int ? rate_int : 0;
assign pll_fixed_clk = (pipe_mode_int == 1'b1) ? clk250_out : pll_fixed_clk_serdes;
assign pclk_in = (rate_ext == 1'b1) ? clk500_out : clk250_out;

// ... existing code ...

endmodule