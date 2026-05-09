`timescale 1 ns / 1 ps 
`timescale 1 ns / 1 ps 
module adder (
        s_axi_AXI_CTRL_AWVALID,
        s_axi_AXI_CTRL_AWREADY,
        s_axi_AXI_CTRL_AWADDR,
        s_axi_AXI_CTRL_WVALID,
        s_axi_AXI_CTRL_WREADY,
        s_axi_AXI_CTRL_WDATA,
        s_axi_AXI_CTRL_WSTRB,
        s_axi_AXI_CTRL_ARVALID,
        s_axi_AXI_CTRL_ARREADY,
        s_axi_AXI_CTRL_ARADDR,
        s_axi_AXI_CTRL_RVALID,
        s_axi_AXI_CTRL_RREADY,
        s_axi_AXI_CTRL_RDATA,
        s_axi_AXI_CTRL_RRESP,
        s_axi_AXI_CTRL_BVALID,
        s_axi_AXI_CTRL_BREADY,
        s_axi_AXI_CTRL_BRESP,
        ap_clk,
        ap_rst_n,
        interrupt
);
parameter    ap_const_logic_1 = 1'b1;
parameter    C_S_AXI_AXI_CTRL_DATA_WIDTH = 32;
parameter    ap_const_int64_8 = 8;
parameter    C_S_AXI_AXI_CTRL_ADDR_WIDTH = 6;
parameter    C_DATA_WIDTH = 32;
parameter    ap_const_logic_0 = 1'b0;
parameter    ap_true = 1'b1;
parameter    C_S_AXI_AXI_CTRL_WSTRB_WIDTH = (C_S_AXI_AXI_CTRL_DATA_WIDTH / ap_const_int64_8);
parameter    C_WSTRB_WIDTH = (C_DATA_WIDTH / ap_const_int64_8);
input   s_axi_AXI_CTRL_AWVALID;
output   s_axi_AXI_CTRL_AWREADY;
input  [C_S_AXI_AXI_CTRL_ADDR_WIDTH - 1 : 0] s_axi_AXI_CTRL_AWADDR;
input   s_axi_AXI_CTRL_WVALID;
output   s_axi_AXI_CTRL_WREADY;
input  [C_S_AXI_AXI_CTRL_DATA_WIDTH - 1 : 0] s_axi_AXI_CTRL_WDATA;
input  [C_S_AXI_AXI_CTRL_WSTRB_WIDTH - 1 : 0] s_axi_AXI_CTRL_WSTRB;
input   s_axi_AXI_CTRL_ARVALID;
output   s_axi_AXI_CTRL_ARREADY;
input  [C_S_AXI_AXI_CTRL_ADDR_WIDTH - 1 : 0] s_axi_AXI_CTRL_ARADDR;
output   s_axi_AXI_CTRL_RVALID;
input   s_axi_AXI_CTRL_RREADY;
output  [C_S_AXI_AXI_CTRL_DATA_WIDTH - 1 : 0] s_axi_AXI_CTRL_RDATA;
output  [1:0] s_axi_AXI_CTRL_RRESP;
output   s_axi_AXI_CTRL_BVALID;
input   s_axi_AXI_CTRL_BREADY;
output  [1:0] s_axi_AXI_CTRL_BRESP;
input   ap_clk;
input   ap_rst_n;
output   interrupt;
wire    ap_start;
wire    ap_done;
wire    ap_idle;
wire    ap_ready;
wire   [31:0] a;
wire   [31:0] b;
wire   [31:0] c;
reg    c_ap_vld;
reg    ap_rst_n_inv;
wire    adder_AXI_CTRL_s_axi_U_ap_dummy_ce;
adder_AXI_CTRL_s_axi #(
    .C_ADDR_WIDTH( C_S_AXI_AXI_CTRL_ADDR_WIDTH ),
    .C_DATA_WIDTH( C_S_AXI_AXI_CTRL_DATA_WIDTH ))
adder_AXI_CTRL_s_axi_U(
    .AWVALID( s_axi_AXI_CTRL_AWVALID ),
    .AWREADY( s_axi_AXI_CTRL_AWREADY ),
    .AWADDR( s_axi_AXI_CTRL_AWADDR ),
    .WVALID( s_axi_AXI_CTRL_WVALID ),
    .WREADY( s_axi_AXI_CTRL_WREADY ),
    .WDATA( s_axi_AXI_CTRL_WDATA ),
    .WSTRB( s_axi_AXI_CTRL_WSTRB ),
    .ARVALID( s_axi_AXI_CTRL_ARVALID ),
    .ARREADY( s_axi_AXI_CTRL_ARREADY ),
    .ARADDR( s_axi_AXI_CTRL_ARADDR ),
    .RVALID( s_axi_AXI_CTRL_RVALID ),
    .RREADY( s_axi_AXI_CTRL_RREADY ),
    .RDATA( s_axi_AXI_CTRL_RDATA ),
    .RRESP( s_axi_AXI_CTRL_RRESP ),
    .BVALID( s_axi_AXI_CTRL_BVALID ),
    .BREADY( s_axi_AXI_CTRL_BREADY ),
    .BRESP( s_axi_AXI_CTRL_BRESP ),
    .ACLK( ap_clk ),
    .ARESET( ap_rst_n_inv ),
    .ACLK_EN( adder_AXI_CTRL_s_axi_U_ap_dummy_ce ),
    .ap_start( ap_start ),
    .interrupt( interrupt ),
    .ap_ready( ap_ready ),
    .ap_done( ap_done ),
    .ap_idle( ap_idle ),
    .a( a ),
    .b( b ),
    .c( c ),
    .c_ap_vld( c_ap_vld )
);
always @ (ap_start)
begin
    if (~(ap_start == ap_const_logic_0)) begin
        c_ap_vld = ap_const_logic_1;
    end else begin
        c_ap_vld = ap_const_logic_0;
    end
end
assign adder_AXI_CTRL_s_axi_U_ap_dummy_ce = ap_const_logic_1;
assign ap_done = ap_start;
assign ap_idle = ap_const_logic_1;
assign ap_ready = ap_start;
always @ (ap_rst_n)
begin
    ap_rst_n_inv = ~ap_rst_n;
end
assign c = (b + a);
endmodule 
