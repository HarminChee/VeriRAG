`define simu 
`define simu 
module TOP_SYS(  
input wire test_i,
input wire i_100MHz_P,
input wire i_100MHz_N,
input wire rstn,
input wire TXD,
input wire RXD,
inout wire [15:0] DDR3DQ,
inout wire [1:0] DDR3DQS_N,
inout wire [1:0] DDR3DQS_P,
output wire [13:0] DDR3ADDR,
output wire [2:0] DDR3BA,
output wire DDR3RAS_N,
output wire DDR3CAS_N,
output wire DDR3WE_N,
output wire DDR3CK_P,
output wire DDR3CK_N,
output wire DDR3CKE,
output wire DDR3RST_N,
output wire [1:0] DDR3DM,
output wire DDR3ODT,
input wire sdin,
output wire sdout,
output wire sdcs,
inout wire [31:0] gpioA,
input wire VID_CLK_N,
input wire VID_CLK_P,
input wire [3:0] VID_D_N,
input wire [3:0] VID_D_P
);

wire clk400, clk200, clk_pix;
wire locked;
wire rstn_ddr;
wire PhyRstn;
reg PhyClk50Mhz;
wire clk50m_bufg;

wire dft_clk400;
assign dft_clk400 = test_i ? i_100MHz_P : clk400;

freq_man ifreq_man (
.clk_in1_p(i_100MHz_P),
.clk_in1_n(i_100MHz_N),
.clk_out1(clk400),
.clk_out2(clk200),
.clk_out3(clk_pix),
.locked(locked)
);

ddr_axi i_ddr_axi (
   .sys_clk_i(dft_clk400),
   .ddr3_dq(DDR3DQ),
   .ddr3_dqs_n(DDR3DQS_N),
   .ddr3_dqs_p(DDR3DQS_P),
   .ddr3_addr(DDR3ADDR),
   .ddr3_ba(DDR3BA),
   .ddr3_ras_n(DDR3RAS_N),
   .ddr3_cas_n(DDR3CAS_N),
   .ddr3_we_n(DDR3WE_N),
   .ddr3_ck_p(DDR3CK_P),
   .ddr3_ck_n(DDR3CK_N),
   .ddr3_cke(DDR3CKE),
   .ddr3_reset_n(DDR3RST_N),
   .ddr3_dm(DDR3DM),
   .ddr3_odt(DDR3ODT)
);

wire dft_PhyClk50Mhz;
assign dft_PhyClk50Mhz = test_i ? i_100MHz_P : PhyClk50Mhz;

always @(posedge clk50m_bufg) 
  if (!rstn_ddr) 
    PhyClk50Mhz <= 1'b0;
  else
    PhyClk50Mhz <= ~PhyClk50Mhz;

mii_to_rmii_0 mii_to_rmii_i (
    .rst_n(PhyRstn),
    .ref_clk(dft_PhyClk50Mhz),
    .mac2rmii_tx_en(TXD),
    .rmii2mac_rx_er(RXD)
);

endmodule