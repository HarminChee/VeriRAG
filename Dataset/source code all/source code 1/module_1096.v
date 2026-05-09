`timescale 1ps/1ps
`timescale 1ps/1ps
module gtwizard_ultrascale_v1_7_1_gtye4_delay_powergood # (
  parameter C_USER_GTPOWERGOOD_DELAY_EN = 0,
  parameter C_PCIE_ENABLE = "FALSE"
)(
  input wire GT_TXOUTCLKPCS,
  input wire GT_GTPOWERGOOD,
  input wire [2:0] USER_TXRATE,
  input wire USER_TXRATEMODE,
  input wire USER_GTTXRESET,
  input wire USER_TXPMARESET,
  input wire USER_TXPISOPD,
  output wire USER_GTPOWERGOOD,
  output wire [2:0] GT_TXRATE,
  output wire GT_TXRATEMODE,
  output wire GT_GTTXRESET,
  output wire GT_TXPMARESET,
  output wire GT_TXPISOPD
);
generate if (C_PCIE_ENABLE || (C_USER_GTPOWERGOOD_DELAY_EN == 0))
begin : gen_powergood_nodelay
  assign GT_TXPISOPD      = USER_TXPISOPD;
  assign GT_GTTXRESET     = USER_GTTXRESET;
  assign GT_TXPMARESET    = USER_TXPMARESET;
  assign GT_TXRATE        = USER_TXRATE;
  assign GT_TXRATEMODE    = USER_TXRATEMODE;
  assign USER_GTPOWERGOOD = GT_GTPOWERGOOD;
end
else
begin: gen_powergood_delay
  (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *) reg [4:0] intclk_rrst_n_r;
  reg [3:0] wait_cnt;
  (* KEEP = "TRUE" *) reg pwr_on_fsm = 1'b0;
  wire intclk_rrst_n;
  wire gt_intclk;
  and and1(gt_intclk, GT_TXOUTCLKPCS, !pwr_on_fsm);
  localparam PWR_ON_WAIT_CNT           = 4'd0;
  localparam PWR_ON_DONE               = 4'd1; 
  always @ (posedge gt_intclk or negedge GT_GTPOWERGOOD)
  begin
      if (!GT_GTPOWERGOOD)
          intclk_rrst_n_r <= 5'd0;
      else
          intclk_rrst_n_r <= {intclk_rrst_n_r[3:0], 1'd1}; 
  end
  assign intclk_rrst_n = intclk_rrst_n_r[4];
  always @ (posedge gt_intclk)
  begin
    if (!intclk_rrst_n)
    	wait_cnt <= 4'd0;
    else begin
    	if (pwr_on_fsm == PWR_ON_WAIT_CNT)
    		wait_cnt <= wait_cnt + 4'd1;
    	else
    		wait_cnt <= 4'd0;
    end
  end
  always @ (posedge gt_intclk or negedge GT_GTPOWERGOOD)
  begin
    if (!GT_GTPOWERGOOD)
    begin
      pwr_on_fsm <= PWR_ON_WAIT_CNT;
    end
    else begin
      case (pwr_on_fsm)
        PWR_ON_WAIT_CNT :
          begin
            pwr_on_fsm <= (wait_cnt[3] == 1'b1) ? PWR_ON_DONE : PWR_ON_WAIT_CNT;
          end 
        PWR_ON_DONE :
          begin
            pwr_on_fsm <= PWR_ON_DONE;
          end
        default :
        begin
          pwr_on_fsm <= PWR_ON_WAIT_CNT;
        end
      endcase
    end
  end
  assign GT_TXPISOPD      = pwr_on_fsm ? USER_TXPISOPD : 1'b1;
  assign GT_GTTXRESET     = pwr_on_fsm ? USER_GTTXRESET : !GT_GTPOWERGOOD;
  assign GT_TXPMARESET    = pwr_on_fsm ? USER_TXPMARESET : 1'b0;
  assign GT_TXRATE        = pwr_on_fsm ? USER_TXRATE : 3'b001;
  assign GT_TXRATEMODE    = pwr_on_fsm ? USER_TXRATEMODE : 1'b1;
  assign USER_GTPOWERGOOD = pwr_on_fsm; 
end
endgenerate
endmodule
