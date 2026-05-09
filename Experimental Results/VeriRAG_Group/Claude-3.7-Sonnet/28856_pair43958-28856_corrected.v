`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_compiler_0 (
                          test_i,
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
                       )
;
// ... existing code ...
  wire             dft_clk_out_buf,clk_out_buf;
  input test_i;
  assign dft_clk_out_buf = test_i ? refclk : clk_out_buf;
// ... existing code ...
  always @(posedge dft_clk_out_buf or negedge npor)
    begin
      if (npor == 0)
        begin
          npor_r <= 0;
          npor_rr <= 0;
        end
      else 
        begin
          npor_r <= 1;
          npor_rr <= npor_r;
        end
    end
  always @(posedge dft_clk_out_buf or negedge any_rstn_rr)
    begin
      if (any_rstn_rr == 0)
        begin
          alive_cnt <= 0;
          alive_led <= 0;
          comp_led <= 0;
          L0_led <= 0;
          lane_active_led <= 0;
        end
      else 
        begin
          alive_cnt <= alive_cnt +1;
          alive_led <= alive_cnt[24];
          comp_led <= ~(test_out_icm[4 : 0] == 5'b00011);
          L0_led <= ~(test_out_icm[4 : 0] == 5'b01111);
          lane_active_led[3 : 0] <= ~(test_out_icm[8 : 5]);
        end
    end
  always @(posedge dft_clk_out_buf or negedge any_rstn_rr)
    begin
      if (any_rstn_rr == 0)
          gen2_led <= 0;
      else 
        gen2_led <= ~gen2_speed;
    end
// ... existing code ...
endmodule