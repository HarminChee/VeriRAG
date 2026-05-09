module Test (
   out,
   clk, a, b
   );
   input clk;
   input [7:0] a;
   input [7:0] b;
   output reg [63:0] out;
   and  u0[7:0] (out[7:0],   a[7:0], b[7:0]);
   and  u1[7:0] (out[15:8],  a[0],  b[7:0]);
   and  u2[7:0] (out[23:16], a[0],  b[0]);
   nand u3[7:0] (out[31:24], a[0],  b[7:0]);
   or   u4[7:0] (out[39:32], a[0],  b[7:0]);
   nor  u5[7:0] (out[47:40], a[0],  b[7:0]);
   xor  u6[7:0] (out[55:48], a[0],  b[7:0]);
   xnor u7[7:0] (out[63:56], a[0],  b[7:0]);
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc=0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [7:0]  a = crc[7:0];
   wire [7:0]  b = crc[15:8];
   wire [63:0]		out;			
   Test test (
	      .out			(out[63:0]),
	      .clk			(clk),
	      .a			(a[7:0]),
	      .b			(b[7:0]));
   wire [63:0] result = {out};
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
`define EXPECTED_SUM 64'h0908a1f2194d24ee
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
module Test (
   out,
   clk, a, b
   );
   input clk;
   input [7:0] a;
   input [7:0] b;
   output reg [63:0] out;
   and  u0[7:0] (out[7:0],   a[7:0], b[7:0]);
   and  u1[7:0] (out[15:8],  a[0],  b[7:0]);
   and  u2[7:0] (out[23:16], a[0],  b[0]);
   nand u3[7:0] (out[31:24], a[0],  b[7:0]);
   or   u4[7:0] (out[39:32], a[0],  b[7:0]);
   nor  u5[7:0] (out[47:40], a[0],  b[7:0]);
   xor  u6[7:0] (out[55:48], a[0],  b[7:0]);
   xnor u7[7:0] (out[63:56], a[0],  b[7:0]);
endmodule
