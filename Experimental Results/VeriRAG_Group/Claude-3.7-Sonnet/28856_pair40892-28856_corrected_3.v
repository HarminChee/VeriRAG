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
  input test_mode,
  input test_clk,
  input l2_exit,
  input hotrst_exit,
  input dlup_exit,

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

wire pld_clk;
wire core_clk_out;
wire pipe_mode_int;
wire [7:0] rxdata_pcs;
wire phystatus_pcs;
wire rxelecidle_pcs;
wire rxvalid_pcs;
wire rxdatak_pcs;
wire [2:0] rxstatus_pcs;
wire [7:0] txdata0_int;
wire txdatak0_int;
wire txdetectrx0_int;
wire txelecidle0_int;
wire txcompl0_int;
wire rxpolarity0_int;
wire [1:0] powerdown0_int;
wire [63:0] RxmWriteData_int;
wire [7:0] RxmByteEnable_int;
wire npor;
reg npor_r;
reg npor_rr;
reg reset_n_r;
reg reset_n_rr;
reg [10:0] rsnt_cntn;
reg srst;
reg crst;
reg RxmResetRequest_o;
reg [4:0] ltssm_reg;

assign ltssm = ltssm_reg;

// Clock mux for test mode
wire clk_mux;
assign clk_mux = test_mode ? test_clk : pld_clk;

// Reset synchronization
always @(posedge clk_mux or negedge reset_n) begin
  if (!reset_n) begin
    npor_r <= 1'b0;
    npor_rr <= 1'b0;
  end
  else begin
    npor_r <= 1'b1;
    npor_rr <= npor_r;
  end
end

always @(posedge clk_mux or negedge reset_n) begin
  if (!reset_n) begin
    reset_n_r <= 1'b0;
    reset_n_rr <= 1'b0;
  end
  else begin
    reset_n_r <= 1'b1;
    reset_n_rr <= reset_n_r;
  end
end

// Reset counter
always @(posedge clk_mux or negedge reset_n) begin
  if (!reset_n)
    rsnt_cntn <= 11'h0;
  else if (rsnt_cntn != 11'h7ff)
    rsnt_cntn <= rsnt_cntn + 11'h1;
end

// Reset generation
always @(posedge clk_mux or negedge reset_n) begin
  if (!reset_n) begin
    srst <= 1'b1;
    crst <= 1'b1;
  end
  else if (rsnt_cntn == 11'h7ff) begin
    srst <= 1'b0;
    crst <= 1'b0;
  end
end

// Reset request generation
always @(posedge clk_mux or negedge reset_n) begin
  if (!reset_n)
    RxmResetRequest_o <= 1'b0;
  else if (!npor_rr || !l2_exit || !hotrst_exit || !dlup_exit || ltssm_reg == 5'h10)
    RxmResetRequest_o <= 1'b1;
  else
    RxmResetRequest_o <= 1'b0;
end

// LTSSM register
always @(posedge clk_mux or negedge reset_n) begin
  if (!reset_n)
    ltssm_reg <= 5'h0;
  else
    ltssm_reg <= 5'h10;
end

endmodule