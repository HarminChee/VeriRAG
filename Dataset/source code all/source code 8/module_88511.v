module Test (
   muxed,
   clk, in
   );
   input clk;
   input [31:0] in;
   output [71:0] muxed;
   wire [71:0] 	     a = {in[7:0],~in[31:0],in[31:0]};
   wire [71:0] 	     b = {~in[7:0],in[31:0],~in[31:0]};
   Muxer muxer (
		.sa	(0),
		.sb	(in[0]),
		.muxed			(muxed[71:0]),
		.a			(a[71:0]),
		.b			(b[71:0]));
endmodule
module Muxer (
   muxed,
   sa, sb, a, b
   );
   input 	 sa;
   input 	 sb;
   output wire [71:0] 	 muxed;
   input [71:0]  a;
   input [71:0]  b;
   assign	muxed = (({72{sa}} & a)
			 | ({72{sb}} & b));
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc=0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [31:0]  in = crc[31:0];
   wire [71:0]		muxed;			
   Test test (
	      .muxed			(muxed[71:0]),
	      .clk			(clk),
	      .in			(in[31:0]));
   wire [63:0] result = {muxed[63:0]};
   wire [5:0]  width_check = cyc[5:0] + 1;
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n",$time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63]^crc[2]^crc[0]};
      sum <= result ^ {sum[62:0],sum[63]^sum[2]^sum[0]};
      if (cyc==0) begin
	 crc <= 64'h5aef0c8d_d70a4497;
	 sum <= 64'h0;
      end
      else if (cyc<10) begin
	 sum <= 64'h0;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
	 $write("[%0t] cyc==%0d crc=%x sum=%x\n",$time, cyc, crc, sum);
	 if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'h20050a66e7b253d1
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
module Test (
   muxed,
   clk, in
   );
   input clk;
   input [31:0] in;
   output [71:0] muxed;
   wire [71:0] 	     a = {in[7:0],~in[31:0],in[31:0]};
   wire [71:0] 	     b = {~in[7:0],in[31:0],~in[31:0]};
   Muxer muxer (
		.sa	(0),
		.sb	(in[0]),
		.muxed			(muxed[71:0]),
		.a			(a[71:0]),
		.b			(b[71:0]));
endmodule
module Muxer (
   muxed,
   sa, sb, a, b
   );
   input 	 sa;
   input 	 sb;
   output wire [71:0] 	 muxed;
   input [71:0]  a;
   input [71:0]  b;
   assign	muxed = (({72{sa}} & a)
			 | ({72{sb}} & b));
endmodule
