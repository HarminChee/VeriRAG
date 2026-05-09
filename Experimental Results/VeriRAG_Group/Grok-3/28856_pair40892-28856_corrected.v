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
  output           CraIrq_o;
  output  [ 31: 0] CraReadData_o;
  output           CraWaitRequest_o;
  output  [ 31: 0] RxmAddress_o;
  output  [  9: 0] RxmBurstCount_o;
  output  [  7: 0] RxmByteEnable_o;
  output           RxmRead_o;
  output           RxmResetRequest_o;
  output  [ 63: 0] RxmWriteData_o;
  output           RxmWrite_o;
  output           TxsReadDataValid_o;
  output  [ 63: 0] TxsReadData_o;
  output           TxsWaitRequest_o;
  output           clk125_out;
  output           clk250_out;
  output           clk500_out;
  output  [  3: 0] lane_act;
  output  [  4: 0] ltssm;
  output  [  1: 0] powerdown_ext;
  output           rate_ext;
  output           rc_pll_locked;
  output           rc_rx_digitalreset;
  output  [ 16: 0] reconfig_fromgxb;
  output           reset_status;
  output           rxpolarity0_ext;
  output           suc_spd_neg;
  output  [  8: 0] test_out;
  output  [  3: 0] tl_cfg_add;
  output  [ 31: 0] tl_cfg_ctl;
  output           tl_cfg_ctl_wr;
  output  [ 52: 0] tl_cfg_sts;
  output           tl_cfg_sts_wr;
  output           tx_out0;
  output           txcompl0_ext;
  output  [  7: 0] txdata0_ext;
  output           txdatak0_ext;
  output           txdetectrx_ext;
  output           txelecidle0_ext;
  input            test_i;
  input            AvlClk_i;
  input   [ 11: 0] CraAddress_i;
  input   [  3: 0] CraByteEnable_i;
  input            CraChipSelect_i;
  input            CraRead;
  input            CraWrite;
  input   [ 31: 0] CraWriteData_i;
  input   [  5: 0] RxmIrqNum_i;
  input            RxmIrq_i;
  input            RxmReadDataValid_i;
  input   [ 63: 0] RxmReadData_i;
  input            RxmWaitRequest_i;
  input   [ 21: 0] TxsAddress_i;
  input   [  9: 0] TxsBurstCount_i;
  input   [  7: 0] TxsByteEnable_i;
  input            TxsChipSelect_i;
  input            TxsRead_i;
  input   [ 63: 0] TxsWriteData_i;
  input            TxsWrite_i;
  input            busy_altgxb_reconfig;
  input            cal_blk_clk;
  input            fixedclk_serdes;
  input            gxb_powerdown;
  input            pcie_rstn;
  input            phystatus_ext;
  input            pipe_mode;
  input            pll_powerdown;
  input            reconfig_clk;
  input   [  3: 0] reconfig_togxb;
  input            refclk;
  input            reset_n;
  input            rx_in0;
  input   [  7: 0] rxdata0_ext;
  input            rxdatak0_ext;
  input            rxelecidle0_ext;
  input   [  2: 0] rxstatus0_ext;
  input            rxvalid0_ext;
  input   [ 39: 0] test_in;
  wire             CraIrq_o;
  wire    [ 31: 0] CraReadData_o;
  wire             CraWaitRequest_o;
  wire    [ 31: 0] RxmAddress_o;
  wire    [  9: 0] RxmBurstCount_o;
  wire    [  7: 0] RxmByteEnable_int;
  wire    [  7: 0] RxmByteEnable_o;
  wire    [ 63: 0] RxmReadData_int;
  wire             RxmRead_o;
  reg              RxmResetRequest_o;
  wire    [ 63: 0] RxmWriteData_int;
  wire    [ 63: 0] RxmWriteData_o;
  wire             RxmWrite_o;
  wire             TxsReadDataValid_o;
  wire    [ 63: 0] TxsReadData_o;
  wire             TxsWaitRequest_o;
  wire             app_clk;
  wire             clk125_out;
  wire             clk250_out;
  wire             clk500_out;
  wire             core_clk_in;
  wire             core_clk_out;
  reg              crst;
  wire             detect_mask_rxdrst;
  wire             dlup_exit;
  wire    [ 23: 0] eidle_infer_sel;
  wire             fifo_err;
  wire             gnd_app_int_sts;
  wire    [  4: 0] gnd_app_msi_num;
  wire             gnd_app_msi_req;
  wire    [  2: 0] gnd_app_msi_tc;
  wire    [  6: 0] gnd_cpl_err;
  wire             gnd_cpl_pending;
  wire    [  4: 0] gnd_pex_msi_num;
  wire             gnd_pme_to_cr;
  wire             gnd_rx_st_mask0;
  wire             gnd_rx_st_ready0;
  wire    [ 63: 0] gnd_tx_st_data0;
  wire             gnd_tx_st_eop0;
  wire             gnd_tx_st_err0;
  wire             gnd_tx_st_sop0;
  wire             gnd_tx_st_valid0;
  wire             gxb_powerdown_int;
  wire    [  1: 0] hip_extraclkout;
  wire             hotrst_exit;
  wire             l2_exit;
  wire    [  3: 0] lane_act;
  wire    [  4: 0] ltssm;
  wire             npor;
  reg              npor_r ;
  reg              npor_rr ;
  wire             open_app_int_ack;
  wire             open_app_msi_ack;
  wire             open_gxb_powerdown;
  wire             open_pme_to_sr;
  wire             open_rc_rx_analogreset;
  wire             open_rc_tx_digitalreset;
  wire             open_rx_fifo_empty0;
  wire             open_rx_fifo_full0;
  wire    [  7: 0] open_rx_st_bardec0;
  wire    [  7: 0] open_rx_st_be0;
  wire    [ 63: 0] open_rx_st_data0;
  wire             open_rx_st_eop0;
  wire             open_rx_st_err0;
  wire             open_rx_st_sop0;
  wire             open_rx_st_valid0;
  wire             open_tx_fifo_empty0;
  wire             open_tx_fifo_full0;
  wire    [  3: 0] open_tx_fifo_rdptr0;
  wire    [  3: 0] open_tx_fifo_wrptr0;
  wire             open_tx_st_ready0;
  wire             pclk_central;
  wire             pclk_central_serdes;
  wire             pclk_ch0;
  wire             pclk_ch0_serdes;
  wire             pclk_in;
  wire             phystatus;
  wire             phystatus_pcs;
  wire             pipe_mode_int;
  wire             pld_clk;
  wire             pll_fixed_clk;
  wire             pll_fixed_clk_serdes;
  wire             pll_locked;
  wire             pll_powerdown_int;
  wire    [  1: 0] powerdown;
  wire    [  1: 0] powerdown0_ext;
  wire    [  1: 0] powerdown0_int;
  wire    [  1: 0] powerdown_ext;
  wire             rate_ext;
  wire             rate_int;
  wire             rateswitch;
  wire             rateswitchbaseclock;
  wire             rc_areset;
  wire             rc_inclk_eq_125mhz;
  wire             rc_pll_locked;
  wire             rc_rx_analogreset;
  wire             rc_rx_digitalreset;
  wire             rc_rx_pll_locked_one;
  wire             rc_tx_digitalreset;
  wire    [ 16: 0] reconfig_fromgxb;
  reg              reset_n_r ;
  reg              reset_n_rr ;
  wire             reset_status;
  reg     [ 10: 0] rsnt_cntn;
  wire             rx_cruclk;
  wire             rx_digitalreset_serdes;
  wire             rx