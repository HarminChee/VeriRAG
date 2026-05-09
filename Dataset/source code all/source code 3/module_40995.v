module value_membank(
	clk,
	nrst,
	wren,
	rdaddr,
	wraddr,
	start_init,
	done_init,
	c0_in,
	c1_in,
	c2_in,
	c3_in,
	c4_in,
	c5_in,
	c6_in,
	c7_in,
	c8_in,
	c9_in,
	c10_in,
	c11_in,
	c12_in,
	c13_in,
	c14_in,
	c15_in,
	c16_in,
	c17_in,
	c18_in,
	c19_in,
	c20_in,
	c21_in,
	c22_in,
	c23_in,
	c24_in,
	c25_in,
	c26_in,
	c27_in,
	c28_in,
	c29_in,
	c30_in,
	c31_in,
	c0_out,
	c1_out,
	c2_out,
	c3_out,
	c4_out,
	c5_out,
	c6_out,
	c7_out,
	c8_out,
	c9_out,
	c10_out,
	c11_out,
	c12_out,
	c13_out,
	c14_out,
	c15_out,
	c16_out,
	c17_out,
	c18_out,
	c19_out,
	c20_out,
	c21_out,
	c22_out,
	c23_out,
	c24_out,
	c25_out,
	c26_out,
	c27_out,
	c28_out,
	c29_out,
	c30_out,
	c31_out
);
input  clk;
input  nrst;
input  wren;
input  start_init; 
input  [10:0] rdaddr;
input  [10:0] wraddr;
input  [63:0] c0_in;
input  [63:0] c1_in;
input  [63:0] c2_in;
input  [63:0] c3_in;
input  [63:0] c4_in;
input  [63:0] c5_in;
input  [63:0] c6_in;
input  [63:0] c7_in;
input  [63:0] c8_in;
input  [63:0] c9_in;
input  [63:0] c10_in;
input  [63:0] c11_in;
input  [63:0] c12_in;
input  [63:0] c13_in;
input  [63:0] c14_in;
input  [63:0] c15_in;
input  [63:0] c16_in;
input  [63:0] c17_in;
input  [63:0] c18_in;
input  [63:0] c19_in;
input  [63:0] c20_in;
input  [63:0] c21_in;
input  [63:0] c22_in;
input  [63:0] c23_in;
input  [63:0] c24_in;
input  [63:0] c25_in;
input  [63:0] c26_in;
input  [63:0] c27_in;
input  [63:0] c28_in;
input  [63:0] c29_in;
input  [63:0] c30_in;
input  [63:0] c31_in;
output  [63:0] c0_out;
output  [63:0] c1_out;
output  [63:0] c2_out;
output  [63:0] c3_out;
output  [63:0] c4_out;
output  [63:0] c5_out;
output  [63:0] c6_out;
output  [63:0] c7_out;
output  [63:0] c8_out;
output  [63:0] c9_out;
output  [63:0] c10_out;
output  [63:0] c11_out;
output  [63:0] c12_out;
output  [63:0] c13_out;
output  [63:0] c14_out;
output  [63:0] c15_out;
output  [63:0] c16_out;
output  [63:0] c17_out;
output  [63:0] c18_out;
output  [63:0] c19_out;
output  [63:0] c20_out;
output  [63:0] c21_out;
output  [63:0] c22_out;
output  [63:0] c23_out;
output  [63:0] c24_out;
output  [63:0] c25_out;
output  [63:0] c26_out;
output  [63:0] c27_out;
output  [63:0] c28_out;
output  [63:0] c29_out;
output  [63:0] c30_out;
output  [63:0] c31_out;
output done_init;  
reg [11:0] timer1;
reg [1:0] state;
wire t1_expire = timer1[10];
wire init = !t1_expire;
wire [10:0] mem_wraddr = init ? timer1[10:0] : wraddr;
wire mem_wren = init || wren;
wire done_init = state[1];
mem_1k c0_mem_1k(
  .data(init ? 64'd0 : c0_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c0_out)
);
mem_1k c1_mem_1k(
  .data(init ? 64'd0 : c1_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c1_out)
);
mem_1k c2_mem_1k(
  .rdclock(clk),
  .data(init ? 64'd0 : c2_in),
  .rdaddress(rdaddr),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c2_out)
);
mem_1k c3_mem_1k(
  .data(init ? 64'd0 : c3_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c3_out)
);
mem_1k c4_mem_1k(
  .data(init ? 64'd0 : c4_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c4_out)
);
mem_1k c5_mem_1k(
  .data(init ? 64'd0 : c5_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c5_out)
);
mem_1k c6_mem_1k(
  .data(init ? 64'd0 : c6_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c6_out)
);
mem_1k c7_mem_1k(
  .data(init ? 64'd0 : c7_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c7_out)
);
mem_1k c8_mem_1k(
  .data(init ? 64'd0 : c8_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c8_out)
);
mem_1k c9_mem_1k(
  .data(init ? 64'd0 : c9_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c9_out)
);
mem_1k c10_mem_1k(
  .data(init ? 64'd0 : c10_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c10_out)
);
mem_1k c11_mem_1k(
  .data(init ? 64'd0 : c11_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c11_out)
);
mem_1k c12_mem_1k(
  .data(init ? 64'd0 : c12_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c12_out)
);
mem_1k c13_mem_1k(
  .data(init ? 64'd0 : c13_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c13_out)
);
mem_1k c14_mem_1k(
  .data(init ? 64'd0 : c14_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c14_out)
);
mem_1k c15_mem_1k(
  .data(init ? 64'd0 : c15_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c15_out)
);
mem_1k c16_mem_1k(
  .data(init ? 64'd0 : c16_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c16_out)
);
mem_1k c17_mem_1k(
  .data(init ? 64'd0 : c17_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c17_out)
);
mem_1k c18_mem_1k(
  .data(init ? 64'd0 : c18_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c18_out)
);
mem_1k c19_mem_1k(
  .data(init ? 64'd0 : c19_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c19_out)
);
mem_1k c20_mem_1k(
  .data(init ? 64'd0 : c20_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c20_out)
);
mem_1k c21_mem_1k(
  .data(init ? 64'd0 : c21_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c21_out)
);
mem_1k c22_mem_1k(
  .data(init ? 64'd0 : c22_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c22_out)
);
mem_1k c23_mem_1k(
  .data(init ? 64'd0 : c23_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c23_out)
);
mem_1k c24_mem_1k(
  .data(init ? 64'd0 : c24_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c24_out)
);
mem_1k c25_mem_1k(
  .data(init ? 64'd0 : c25_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c25_out)
);
mem_1k c26_mem_1k(
  .data(init ? 64'd0 : c26_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c26_out)
);
mem_1k c27_mem_1k(
  .data(init ? 64'd0 : c27_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c27_out)
);
mem_1k c28_mem_1k(
  .data(init ? 64'd0 : c28_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c28_out)
);
mem_1k c29_mem_1k(
  .data(init ? 64'd0 : c29_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c29_out)
);
mem_1k c30_mem_1k(
  .data(init ? 64'd0 : c30_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c30_out)
);
mem_1k c31_mem_1k(
  .data(init ? 64'd0 : c31_in),
  .rdaddress(rdaddr),
  .rdclock(clk),
  .wraddress(mem_wraddr),
  .wren(mem_wren),
  .wrclock(clk),
  .q(c31_out)
);
always@(posedge clk)
  if(!nrst) timer1 <= -1;
  else if(start_init) timer1 <= 12'b01111111111;
  else if(!t1_expire) timer1 <= timer1 - 1;  
always@(posedge clk)
  if(!nrst) state <= 2'b00;
  else if(start_init) state <= 2'b01;
  else if((state == 2'b01) && t1_expire) state <= 2'b10;
  else if(state == 2'b10) state <= 2'b00;
endmodule
