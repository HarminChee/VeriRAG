module pcie_compiler_0 (
                          input test_i,
                          input scan_chain_rst,
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

// ... existing code ...

wire clk_dft;
wire rst_dft;
assign clk_dft = test_i ? AvlClk_i : pld_clk;
assign rst_dft = test_i ? scan_chain_rst : reset_n_rr;

always @(posedge clk_dft or posedge rst_dft)
begin
  if (rst_dft == 1'b1)
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

always @(posedge clk_dft or posedge rst_dft)
begin
  if (rst_dft == 1'b1)
  begin
    reset_n_r <= 0;
    reset_n_rr <= 0;
  end
  else 
  begin
    reset_n_r <= 1;
    reset_n_rr <= reset_n_r;
  end
end

always @(posedge clk_dft or posedge rst_dft)
begin
  if (rst_dft == 1'b1)
    rsnt_cntn <= 0;
  else if (rsnt_cntn != 4'hf)
    rsnt_cntn <= rsnt_cntn + 1;
end

always @(posedge clk_dft or posedge rst_dft)
begin
  if (rst_dft == 1'b1)
  begin
    srst <= 1;
    crst <= 1;
  end
  else if (rsnt_cntn == 4'hf)
  begin
    srst <= 0;
    crst <= 0;
  end
end

// ... existing code ...

endmodule