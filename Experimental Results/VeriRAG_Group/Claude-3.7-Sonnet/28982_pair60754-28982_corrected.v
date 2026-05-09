`define simu 
`define simu 
module TOP_SYS(  
input wire test_i,
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

// ... existing code ...

wire clk400, dft_clk400;
assign dft_clk400 = test_i ? i_100MHz_P : clk400;

freq_man ifreq_man (
.clk_in1_p(i_100MHz_P),
.clk_in1_n(i_100MHz_N),
.clk_out1(clk400),
.clk_out2(clk200),
.clk_out3(clk_pix),
.locked(locked)
);

// ... existing code ...

ddr_axi i_ddr_axi (
   // ... existing ports ...
   .sys_clk_i(dft_clk400),
   // ... existing ports ...
);

// ... existing code ...

wire dft_PhyClk50Mhz;
assign dft_PhyClk50Mhz = test_i ? i_100MHz_P : PhyClk50Mhz;

always @(posedge dft_clk50m_bufg) if (rstn_ddr == 0) PhyClk50Mhz <=0; else PhyClk50Mhz <=~PhyClk50Mhz;

// ... existing code ...

mii_to_rmii_0 mii_to_rmii_i (
    .rst_n(PhyRstn),
    .ref_clk(dft_PhyClk50Mhz),
    // ... existing ports ...
);

// ... rest of existing code ...

endmodule