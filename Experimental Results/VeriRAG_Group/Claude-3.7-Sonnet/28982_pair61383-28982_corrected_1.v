module TOP_SYS(  
input test_i,
input scan_chain_rst,
input i_100MHz_P,
input i_100MHz_N,
input rstn,
output TXD,
input RXD,
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
output sdout,
output sdcs,
input sdin,
inout [7:0] gpioA,
output [2:0] VID_D_N,
output [2:0] VID_D_P,
output VID_CLK_N,
output VID_CLK_P
);

// ... existing code ...

wire clk, clk_dft;
wire clk400, clk200, clk_pix;
wire locked;
wire rstn_ddr;
reg PhyClk50Mhz;

assign clk_dft = test_i ? i_100MHz_P : clk;
wire rstn_dft;
assign rstn_dft = test_i ? scan_chain_rst : rstn_ddr;

// ... existing code ...

freq_man ifreq_man (
.clk_in1_p(i_100MHz_P),
.clk_in1_n(i_100MHz_N), 
.clk_out1(clk400),
.clk_out2(clk200),
.clk_out3(clk_pix),
.locked(locked)
);

// ... existing code ...

always @(posedge clk_dft or negedge rstn_dft)
begin
  if (!rstn_dft) 
    PhyClk50Mhz <= 1'b0;
  else
    PhyClk50Mhz <= ~PhyClk50Mhz;
end

// ... existing code ...

endmodule