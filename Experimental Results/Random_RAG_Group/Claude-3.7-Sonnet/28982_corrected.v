module TOP_SYS(  
test_i,
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

input test_i;
wire [2:0] dbg;
input            i_100MHz_P,i_100MHz_N;
input            rstn;
output           TXD;
wire      [6:0] gpio_in;
output [2:0] VID_D_N,VID_D_P;
output VID_CLK_N,VID_CLK_P;
inout wire [15:0]  DDR3DQ;
inout wire [1:0]   DDR3DQS_N;
inout wire [1:0]   DDR3DQS_P;
output wire [13:0] DDR3ADDR;
output wire [2:0]  DDR3BA;
output wire        DDR3RAS_N;
output wire        DDR3CAS_N;
output wire        DDR3WE_N;
output wire        DDR3CK_P;
output wire        DDR3CK_N;
output wire        DDR3CKE;
output wire        DDR3RST_N;
output wire [1:0]  DDR3DM;
output wire        DDR3ODT;
input            RXD;
output           sdout,sdcs;
input            sdin;
inout     [7:0]  gpioA;

// ... existing code ...

wire clk_pix_int;
wire clk_pix_test;
assign clk_pix_test = test_i ? i_100MHz_P : clk_pix_int;

freq_man ifreq_man (
.clk_in1_p(i_100MHz_P),
.clk_in1_n(i_100MHz_N),
.clk_out1(clk400),
.clk_out2(clk200),
.clk_out3(clk_pix_int),
.locked(locked)
);

HDMI_test ihdmi(
.rstn(rstn),
.pixclk(clk_pix_test),  
.TMDSp(VID_D_P), 
.TMDSn(VID_D_N),
.TMDSp_clock(VID_CLK_P), 
.TMDSn_clock(VID_CLK_N)
);

// ... existing code ...

endmodule