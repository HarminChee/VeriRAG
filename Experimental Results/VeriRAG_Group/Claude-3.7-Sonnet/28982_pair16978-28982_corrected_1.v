`define simu 
`define simu 
module TOP_SYS(  
input test_i,
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
VID_D_P
);

wire dft_clk;
wire clk400;
wire clk200;
wire clk_pix;
wire locked;
wire rstn_ddr;
reg PhyClk50Mhz;

assign dft_clk = test_i ? i_100MHz_P : clk400;

freq_man ifreq_man (
.clk_in1_p(i_100MHz_P),
.clk_in1_n(i_100MHz_N),
.clk_out1(clk400),
.clk_out2(clk200),
.clk_out3(clk_pix),
.locked(locked)
);

always @(posedge dft_clk or negedge rstn_ddr) begin
  if (!rstn_ddr)
    PhyClk50Mhz <= 1'b0;
  else 
    PhyClk50Mhz <= ~PhyClk50Mhz;
end

endmodule