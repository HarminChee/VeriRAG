`define simu 
`define simu 
module TOP_SYS(  
i_100MHz_P,
i_100MHz_N,
rstn,
TXD,RXD,
DDR3DQ,
DDR3DQS_N,
DDR3DQS_P,
DDR3ADDR,
DDR3BA,
DDR3RAS_N,
DDR3CAS_N,
DDR3WE_N,
DDR3CK_P,
DDR3CK_N,
DDR3CKE,
DDR3RST_N,
DDR3DM,
DDR3ODT,
sdin,sdout,sdcs,
gpioA,
VID_CLK_N,
VID_CLK_P,
VID_D_N,
VID_D_P,
test_mode_i,
clk_out_buf,
refclk,
any_rstn
);

input test_mode_i;
input clk_out_buf;
input refclk;
input any_rstn;
input i_100MHz_P;
input i_100MHz_N;
input rstn;
input TXD;
output RXD;
inout [63:0] DDR3DQ;
inout [7:0] DDR3DQS_N;
inout [7:0] DDR3DQS_P;
output [13:0] DDR3ADDR;
output [2:0] DDR3BA;
output DDR3RAS_N;
output DDR3CAS_N;
output DDR3WE_N;
output DDR3CK_P;
output DDR3CK_N;
output DDR3CKE;
output DDR3RST_N;
output [7:0] DDR3DM;
output DDR3ODT;
input sdin;
output sdout;
output sdcs;
inout [31:0] gpioA;
input VID_CLK_N;
input VID_CLK_P;
input [3:0] VID_D_N;
input [3:0] VID_D_P;

wire dft_clk;
reg any_rstn_r;
reg any_rstn_rr;
reg [24:0] alive_cnt;
reg alive_led;
reg comp_led;
reg L0_led;
reg [3:0] lane_active_led;
wire gen2_speed;
reg gen2_led;
wire [8:0] test_out_icm;

assign dft_clk = test_mode_i ? refclk : clk_out_buf;

always @(posedge dft_clk or negedge any_rstn)
  begin
    if (!any_rstn)
      begin
        any_rstn_r <= 1'b0;
        any_rstn_rr <= 1'b0;
      end
    else 
      begin
        any_rstn_r <= 1'b1;
        any_rstn_rr <= any_rstn_r;
      end
  end

always @(posedge dft_clk or negedge any_rstn_rr)
  begin
    if (!any_rstn_rr)
      begin
        alive_cnt <= 25'b0;
        alive_led <= 1'b0;
        comp_led <= 1'b0;
        L0_led <= 1'b0;
        lane_active_led <= 4'b0;
      end
    else 
      begin
        alive_cnt <= alive_cnt + 1'b1;
        alive_led <= alive_cnt[24];
        comp_led <= ~(test_out_icm[4:0] == 5'b00011);
        L0_led <= ~(test_out_icm[4:0] == 5'b01111);
        lane_active_led[3:0] <= ~(test_out_icm[8:5]);
      end
  end

always @(posedge dft_clk or negedge any_rstn_rr)
  begin
    if (!any_rstn_rr)
        gen2_led <= 1'b0;
    else 
      gen2_led <= ~gen2_speed;
  end

endmodule