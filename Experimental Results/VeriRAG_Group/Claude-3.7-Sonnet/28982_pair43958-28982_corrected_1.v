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
test_mode_i
);

input test_mode_i;
wire dft_clk_out_buf;
wire dft_clk;

assign dft_clk = test_mode_i ? refclk : clk_out_buf;

always @(posedge dft_clk or negedge any_rstn)
  begin
    if (any_rstn == 0)
      begin
        any_rstn_r <= 0;
        any_rstn_rr <= 0;
      end
    else 
      begin
        any_rstn_r <= 1;
        any_rstn_rr <= any_rstn_r;
      end
  end

always @(posedge dft_clk or negedge any_rstn_rr)
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

always @(posedge dft_clk or negedge any_rstn_rr)
  begin
    if (any_rstn_rr == 0)
        gen2_led <= 0;
    else 
      gen2_led <= ~gen2_speed;
  end

endmodule