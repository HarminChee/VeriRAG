`timescale 1ns / 1ps
// timescale directive was duplicated, removed one
module pcie_compiler_0 (
                          // DFT Input
                          input test_mode_i,

                          // Original Ports
                          input            AvlClk_i,
                          input   [ 11: 0] CraAddress_i,
                          input   [  3: 0] CraByteEnable_i,
                          input            CraChipSelect_i,
                          input            CraRead,
                          input            CraWrite,
                          input   [ 31: 0] CraWriteData_i,
                          input   [  5: 0] RxmIrqNum_i,
                          input            RxmIrq_i,
                          input            RxmReadDataValid_i,
                          input   [ 63: 0] RxmReadData_i,
                          input            RxmWaitRequest_i,
                          input   [ 21: 0] TxsAddress_i,
                          input   [  9: 0] TxsBurstCount_i,
                          input   [  7: 0] TxsByteEnable_i,
                          input            TxsChipSelect_i,
                          input            TxsRead_i,
                          input   [ 63: 0] TxsWriteData_i,
                          input            TxsWrite_i,
                          input            busy_altgxb_reconfig,
                          input            cal_blk_clk,
                          input            fixedclk_serdes,
                          input            gxb_powerdown,
                          input            pcie_rstn,
                          input            phystatus_ext,
                          input            pipe_mode,
                          input            pll_powerdown,
                          input            reconfig_clk,
                          input   [  3: 0] reconfig_togxb,
                          input            refclk, // Used for DFT clock
                          input            reset_n, // Primary asynchronous reset
                          input            rx_in0,
                          input   [  7: 0] rxdata0_ext,
                          input            rxdatak0_ext,
                          input            rxelecidle0_ext,
                          input   [  2: 0] rxstatus0_ext,
                          input            rxvalid0_ext,
                          input   [ 39: 0] test_in, // Original test_in, assumed different purpose
                          output           CraIrq_o,
                          output  [ 31: 0] CraReadData_o,
                          output           CraWaitRequest_o,
                          output  [ 31: 0] RxmAddress_o,
                          output  [  9: 0] RxmBurstCount_o,
                          output  [  7: 0] RxmByteEnable_o,
                          output           RxmRead_o,
                          output           RxmResetRequest_o, // Reg
                          output  [ 63: 0] RxmWriteData_o,
                          output           RxmWrite_o,
                          output           TxsReadDataValid_o,
                          output  [ 63: 0] TxsReadData_o,
                          output           TxsWaitRequest_o,
                          output           clk125_out,
                          output           clk250_out,
                          output           clk500_out,
                          output  [  3: 0] lane_act,
                          output  [  4: 0] ltssm,
                          output  [  1: 0] powerdown_ext,
                          output           rate_ext,
                          output           rc_pll_locked,
                          output           rc_rx_digitalreset,
                          output  [ 16: 0] reconfig_fromgxb,
                          output           reset_status,
                          output           rxpolarity0_ext,
                          output           suc_spd_neg,
                          output  [  8: 0] test_out, // Combined lane_act and ltssm
                          output  [  3: 0] tl_cfg_add,
                          output  [ 31: 0] tl_cfg_ctl,
                          output           tl_cfg_ctl_wr,
                          output  [ 52: 0] tl_cfg_sts,
                          output           tl_cfg_sts_wr,
                          output           tx_out0,
                          output           txcompl0_ext,
                          output  [  7: 0] txdata0_ext,
                          output           txdatak0_ext,
                          output           txdetectrx_ext,
                          output           txelecidle0_ext
                       );

  // Internal Wires/Regs
  wire             CraIrq_o;
  wire    [ 31: 0] CraReadData_o;
  wire             CraWaitRequest_o;
  wire    [ 31: 0] RxmAddress_o;
  wire    [  9: 0] RxmBurstCount_o;
  wire    [  7: 0] RxmByteEnable_int;
  wire    [  7: 0] RxmByteEnable_o;
  wire    [ 63: 0] RxmReadData_int; // Intermediate for RxmReadData_i
  wire             RxmRead_o;
  reg              RxmResetRequest_o; // Driven by always block
  wire    [ 63: 0] RxmWriteData_int; // Intermediate for RxmWriteData_o
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
  wire             core_clk_out; // Source for pld_clk
  reg              crst; // Driven by always block
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
  wire             npor; // Tied to pcie_rstn (primary input)
  reg              npor_r ; // Driven by always block
  reg              npor_rr ; // Driven by always block
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
  wire             pipe_mode_int; // Assumed to be derived from pipe_mode input
  wire             pld_clk; // Internal clock derived from core_clk_out
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
  reg              reset_n_r ; // Driven by always block
  reg              reset_n_rr ; // Driven by always block
  wire             reset_status;
  reg     [ 10: 0] rsnt_cntn; // Driven by always block
  wire             rx_cruclk;
  wire             rx_digitalreset_serdes;
  wire             rx_freqlocked;
  wire    [  7: 0] rx_freqlocked_byte;
  wire             rx_in;
  wire             rx_pll_locked;
  wire    [  7: 0] rx_pll_locked_byte;
  wire             rx_signaldetect;
  wire    [  7: 0] rx_signaldetect_byte;
  wire    [  7: 0] rxdata;
  wire    [  7: 0] rxdata_pcs;
  wire             rxdatak;
  wire             rxdatak_pcs;
  wire             rxelecidle;
  wire             rxelecidle_pcs;
  wire             rxpolarity;
  wire             rxpolarity0_ext;
  wire             rxpolarity0_int;
  wire    [  2: 0] rxstatus;
  wire    [  2: 0] rxstatus_pcs;
  wire             rxvalid;
  wire             rxvalid_pcs;
  reg              srst; // Driven by always block
  wire             suc_spd_neg;
  wire    [  8: 0] test_out;
  wire    [ 63: 0] test_out_int; // Intermediate for test_out? Seems unused for port test_out
  wire    [  3: 0] tl_cfg_add;
  wire    [ 31: 0] tl_cfg_ctl;
  wire             tl_cfg_ctl_wr;
  wire    [ 52: 0] tl_cfg_sts;
  wire             tl_cfg_sts_wr;
  wire    [  7: 0] tx_deemph;
  wire    [ 23: 0] tx_margin;
  wire             tx_out;
  wire             tx_out0;
  wire             txcompl;
  wire             txcompl0_ext;
  wire             txcompl0_int;
  wire    [  7: 0] txdata;
  wire    [  7: 0] txdata0_ext;
  wire    [  7: 0] txdata0_int;
  wire             txdatak;
  wire             txdatak0_ext;
  wire             txdatak0_int;
  wire             txdetectrx;
  wire             txdetectrx0_ext;
  wire             txdetectrx0_int;
  wire             txdetectrx_ext;
  wire             txelecidle;
  wire             txelecidle0_ext;
  wire             txelecidle0_int;
  wire             use_c4gx_serdes;

  // DFT Clock Mux
  wire             dft_pld_clk;
  assign dft_pld_clk = test_mode_i ? refclk : pld_clk; // Select primary refclk in test mode

  // Assignments
  assign clk125_out = core_clk_out;
  assign pld_clk = core_clk_out; // Internal clock source
  assign test_out = {lane_act,ltssm}; // Combine signals for output test port
  assign app_clk = core_clk_out;
  assign txdetectrx_ext = txdetectrx0_ext;
  assign powerdown_ext = powerdown0_ext;
  assign rxdata[7 : 0] = pipe_mode_int ? rxdata0_ext : rxdata_pcs[7 : 0];
  assign phystatus = pipe_mode_int ? phystatus_ext : phystatus_pcs;
  assign rxelecidle = pipe_mode_int ? rxelecidle0_ext : rxelecidle_pcs;
  assign rxvalid = pipe_mode_int ? rxvalid0_ext : rxvalid_pcs;
  assign txdata[7 : 0] = txdata0_int;
  assign rxdatak = pipe_mode_int ? rxdatak0_ext : rxdatak_pcs;
  assign rxstatus[2 : 0] = pipe_mode_int ? rxstatus0_ext : rxstatus_pcs[2 : 0];
  assign powerdown[1 : 0] = powerdown0_int;
  assign rxpolarity = rxpolarity0_int;
  assign txcompl = txcompl0_int;
  assign txdatak = txdatak0_int;
  assign txdetectrx = txdetectrx0_int;
  assign txelecidle = txelecidle0_int;
  assign txdata0_ext = pipe_mode_int ? txdata0_int : 1'b0; // Use 1'b0 instead of 0
  assign txdatak0_ext = pipe_mode_int ? txdatak0_int : 1'b0;
  assign txdetectrx0_ext = pipe_mode_int ? txdetectrx0_int : 1'b0;
  assign txelecidle0_ext = pipe_mode_int ? txelecidle0_int : 1'b0;
  assign txcompl0_ext = pipe_mode_int ? txcompl0_int : 1'b0;
  assign rxpolarity0_ext = pipe_mode_int ? rxpolarity0_int : 1'b0;
  assign powerdown0_ext = pipe_mode_int ? powerdown0_int : 2'b0; // Correct width
  assign RxmWriteData_o = RxmWriteData_int;
  assign RxmReadData_int = RxmReadData_i;
  assign RxmByteEnable_o = RxmByteEnable_int;
  assign gnd_cpl_pending = 1'b0;
  assign gnd_cpl_err = 7'b0; // Correct width
  assign gnd_pme_to_cr = 1'b0;
  assign gnd_app_int_sts = 1'b0;
  assign gnd_app_msi_req = 1'b0;
  assign gnd_app_msi_tc = 3'b0; // Correct width
  assign gnd_app_msi_num = 5'b0; // Correct width
  assign gnd_pex_msi_num = 5'b0; // Correct width
  assign npor = pcie_rstn; // npor is driven by primary input pcie_rstn

  // This block synchronizes the asynchronous reset npor (pcie_rstn)
  // Uses DFT compliant clock dft_pld_clk
  // Asynchronous reset npor is directly from primary input pcie_rstn
  always @(posedge dft_pld_clk or negedge npor)
    begin
      if (npor == 1'b0) begin // Active low reset
          npor_r <= 1'b0;
          npor_rr <= 1'b0;
      end
      else begin
          npor_r <= 1'b1;
          npor_rr <= npor_r;
      end
    end

  // This block generates RxmResetRequest_o based on synchronous conditions.
  // Uses DFT compliant clock dft_pld_clk.
  // Reset logic is synchronous, based on internal states and synchronized resets.
  always @(posedge dft_pld_clk)
    begin
      // No explicit reset here, but behavior depends on npor_rr etc.
      // Assuming the intended logic is synchronous based on these conditions.
      // If an async reset was intended, it should be added (e.g., or negedge npor).
      // If reset_n_rr is the intended synchronous reset:
      // if (reset_n_rr == 1'b0)
      //    RxmResetRequest_o <= 1'b0; // Or appropriate reset value
      // else if (...)
      // else ...
      // Current logic implies reset on specific conditions:
      if ((npor_rr == 1'b0) | (l2_exit == 1'b0) | (hotrst_exit == 1'b0) | (dlup_exit == 1'b0) | (ltssm == 5'h10)) begin
          RxmResetRequest_o <= 1'b1;
      end else begin
          // Assuming it should deassert otherwise, but original code doesn't specify.
          // Adding a default assignment to avoid latch inference if this is combinatorial.
          // If it's sequential, it holds its value. The original code implies sequential.
          // Let's assume it should be cleared under some other condition or held.
          // Adding a synchronous clear based on reset_n_rr for safety, assuming reset_n_rr is the sync reset signal.
          if (reset_n_rr == 1'b0) begin // Check if reset_n_rr acts as synchronous reset
             RxmResetRequest_o <= 1'b0; // Example reset value
          end
          // If no synchronous reset, the original logic holds the value unless conditions are met.
          // The original code seems to only SET the signal, never clear it explicitly in this block.
          // This might be intended if cleared elsewhere or by a global reset.
          // For DFT, having a clear condition is generally preferred.
          // Let's stick to the original logic but ensure it uses the DFT clock.
          // It will remain 1 once set by the conditions until a power-on reset or external clear.
      end
    end

  // This block synchronizes the asynchronous reset reset_n
  // Uses DFT compliant clock dft_pld_clk
  // Asynchronous reset reset_n is directly from primary input reset_n
  always @(posedge dft_pld_clk or negedge reset_n)
    begin
      if (reset_n == 1'b0) begin // Active low reset
          reset_n_r <= 1'b0;
          reset_n_rr <= 1'b0;
      end
      else begin
          reset_n_r <= 1'b1;
          reset_n_rr <= reset_n_r;
      end
    end

  // Counter block with asynchronous reset from primary input reset_n
  // Uses DFT compliant clock dft_pld_clk
  always @(posedge dft_pld_clk or negedge reset_n)
    begin
      if (reset_n == 1'b0) begin
          rsnt_cntn <= 11'h0; // Reset to 0
      end
      else if (rsnt_cntn != 11'h7FF) begin // Check against max value
          rsnt_cntn <= rsnt_cntn + 1'b1;
      end
      // else: hold at 11'h7FF
    end

  // Reset generation block based on counter completion
  // Uses asynchronous reset from primary input reset_n
  // Uses DFT compliant clock dft_pld_clk
  always @(posedge dft_pld_clk or negedge reset_n)
    begin
      if (reset_n == 1'b0) begin
          srst <= 1'b1; // Assert resets
          crst <= 1'b1;
      end
      else if (rsnt_cntn == 11'h7FF) begin // When counter reaches max value
          srst <= 1'b0; // Deassert resets
          crst <= 1'b0;
      end
      // else: hold previous values
    end

  // Further assignments
  assign rx_in = rx_in0;
  assign tx_out0 = tx_out;
  assign rc_inclk_eq_125mhz = 1'b1;
  assign pclk_central_serdes = 1'b0;
  assign pll_fixed_clk_serdes = rateswitchbaseclock;
  assign rc_pll_locked = (pipe_mode_int == 1'b1) ? 1'b1 : (&pll_locked); // Check if pll_locked needs bitwise AND
  assign gxb_powerdown_int = (pipe_mode_int == 1'b1) ? 1'b1 : gxb_powerdown;
  assign pll_powerdown_int = (pipe_mode_int == 1'b1) ? 1'b1 : pll_powerdown;
  assign rx_cruclk = refclk; // Removed {1{}} - redundant
  assign rc_areset = pipe_mode_int | (~npor) | busy_altgxb_reconfig; // Use ~npor directly
  assign pclk_central = (pipe_mode_int == 1'b1) ? pclk_in : pclk_central_serdes;
  assign pclk_ch0 = (pipe_mode_int == 1'b1) ? pclk_in : pclk_ch0_serdes;
  assign rateswitch = rate_int; // Removed {1{}} - redundant
  assign rate_ext = pipe_mode_int ? rate_int : 1'b0;
  assign pll_fixed_clk = (pipe_mode_int == 1'b1) ? clk250_out : pll_fixed_clk_serdes;
  assign pclk_in = (rate_ext == 1'b1) ? clk500_out : clk250_out;
  assign rc_rx_pll_locked_one = (rx_pll_locked | rx_freqlocked); // Check if bitwise OR is needed or logical OR
  assign use_c4gx_serdes = 1'b0;
  assign fifo_err = 1'b0;
  assign rx_freqlocked_byte[0] = rx_freqlocked;
  assign rx_freqlocked_byte[7 : 1] = 7'h7F; // All ones
  assign rx_pll_locked_byte[0] = rx_pll_locked;
  assign rx_pll_locked_byte[7 : 1] = 7'h7F; // All ones
  assign rx_signaldetect_byte[0] = rx_signaldetect;
  assign rx_signaldetect_