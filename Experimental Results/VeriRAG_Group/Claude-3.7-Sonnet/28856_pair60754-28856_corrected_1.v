`timescale 1ns / 1ps
module pcie_compiler_0 (
                          input wire AvlClk_i,
                          input wire [11:0] CraAddress_i,
                          input wire [3:0] CraByteEnable_i,
                          input wire CraChipSelect_i,
                          input wire CraRead,
                          input wire CraWrite,
                          input wire [31:0] CraWriteData_i,
                          input wire [3:0] RxmIrqNum_i,
                          input wire RxmIrq_i,
                          input wire RxmReadDataValid_i,
                          input wire [63:0] RxmReadData_i,
                          input wire RxmWaitRequest_i,
                          input wire [63:0] TxsAddress_i,
                          input wire [3:0] TxsBurstCount_i,
                          input wire [7:0] TxsByteEnable_i,
                          input wire TxsChipSelect_i,
                          input wire TxsRead_i,
                          input wire [63:0] TxsWriteData_i,
                          input wire TxsWrite_i,
                          input wire busy_altgxb_reconfig,
                          input wire cal_blk_clk,
                          input wire fixedclk_serdes,
                          input wire gxb_powerdown,
                          input wire pcie_rstn,
                          input wire phystatus_ext,
                          input wire pipe_mode,
                          input wire pll_powerdown,
                          input wire reconfig_clk,
                          input wire [3:0] reconfig_togxb,
                          input wire refclk,
                          input wire reset_n,
                          input wire rx_in0,
                          input wire [7:0] rxdata0_ext,
                          input wire rxdatak0_ext,
                          input wire rxelecidle0_ext,
                          input wire [2:0] rxstatus0_ext,
                          input wire rxvalid0_ext,
                          input wire [37:0] test_in,
                          output wire CraIrq_o,
                          output wire [31:0] CraReadData_o,
                          output wire CraWaitRequest_o,
                          output wire [63:0] RxmAddress_o,
                          output wire [3:0] RxmBurstCount_o,
                          output wire [7:0] RxmByteEnable_o,
                          output wire RxmRead_o,
                          output wire RxmResetRequest_o,
                          output wire [63:0] RxmWriteData_o,
                          output wire RxmWrite_o,
                          output wire TxsReadDataValid_o,
                          output wire [63:0] TxsReadData_o,
                          output wire TxsWaitRequest_o,
                          output wire clk125_out,
                          output wire clk250_out,
                          output wire clk500_out,
                          output wire lane_act,
                          output wire [4:0] ltssm,
                          output wire [1:0] powerdown_ext,
                          output wire rate_ext,
                          output wire rc_pll_locked,
                          output wire rc_rx_digitalreset,
                          output wire [4:0] reconfig_fromgxb,
                          output wire reset_status,
                          output wire rxpolarity0_ext,
                          output wire suc_spd_neg,
                          output wire [37:0] test_out,
                          output wire [3:0] tl_cfg_add,
                          output wire [31:0] tl_cfg_ctl,
                          output wire tl_cfg_ctl_wr,
                          output wire [12:0] tl_cfg_sts,
                          output wire tl_cfg_sts_wr,
                          output wire tx_out0,
                          output wire txcompl0_ext,
                          output wire [7:0] txdata0_ext,
                          output wire txdatak0_ext,
                          output wire txdetectrx_ext,
                          output wire txelecidle0_ext
                       );

reg reset_n_r;
reg reset_n_rr;
reg [3:0] rsnt_cntn;
reg srst;
reg crst;
wire pld_clk;
wire rx_in;
wire tx_out;
wire pipe_mode_int;
wire [1:0] pll_locked;
wire gxb_powerdown_int;
wire pll_powerdown_int;
wire rc_areset;
wire npor;
wire pclk_central;
wire pclk_central_serdes;
wire pclk_ch0;
wire pclk_ch0_serdes;
wire pclk_in;
wire rate_int;
wire rateswitch;
wire rateswitchbaseclock;
wire pll_fixed_clk;
wire pll_fixed_clk_serdes;
wire rc_inclk_eq_125mhz;
wire [1:0] rx_cruclk;

always @(posedge pld_clk or negedge reset_n)
begin
  if (reset_n == 1'b0) begin
    reset_n_r <= 1'b0;
    reset_n_rr <= 1'b0;
  end
  else begin
    reset_n_r <= 1'b1;
    reset_n_rr <= reset_n_r;
  end
end

always @(posedge pld_clk or negedge reset_n_rr)
begin
  if (reset_n_rr == 1'b0)
    rsnt_cntn <= 4'h0;
  else if (rsnt_cntn != 4'hf)
    rsnt_cntn <= rsnt_cntn + 4'h1;
end

always @(posedge pld_clk or negedge reset_n_rr)
begin
  if (reset_n_rr == 1'b0) begin
    srst <= 1'b1;
    crst <= 1'b1;
  end
  else if (rsnt_cntn == 4'hf) begin
    srst <= 1'b0;
    crst <= 1'b0;
  end
end

assign rx_in = rx_in0;
assign tx_out0 = tx_out;
assign rc_inclk_eq_125mhz = 1'b1;
assign pclk_central_serdes = 1'b0;
assign pll_fixed_clk_serdes = rateswitchbaseclock;
assign rc_pll_locked = (pipe_mode_int == 1'b1) ? 1'b1 : &pll_locked;
assign gxb_powerdown_int = (pipe_mode_int == 1'b1) ? 1'b1 : gxb_powerdown;
assign pll_powerdown_int = (pipe_mode_int == 1'b1) ? 1'b1 : pll_powerdown;
assign rx_cruclk = {2{refclk}};
assign rc_areset = pipe_mode_int | ~npor | busy_altgxb_reconfig;
assign pclk_central = (pipe_mode_int == 1'b1) ? pclk_in : pclk_central_serdes;
assign pclk_ch0 = (pipe_mode_int == 1'b1) ? pclk_in : pclk_ch0_serdes;
assign rateswitch = rate_int;
assign rate_ext = pipe_mode_int ? rate_int : 1'b0;
assign pll_fixed_clk = (pipe_mode_int == 1'b1) ? clk250_out : pll_fixed_clk_serdes;
assign pclk_in = (rate_ext == 1'b1) ? clk500_out : clk250_out;

endmodule