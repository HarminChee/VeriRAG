module Test (
   out1, out2,
   in
   );
   input [106:0]    in;
   output [7:0]     out1, out2;
   wire [7:0] 	    out1 = (in >>> 99) & 255;
   wire [7:0] 	    out2 = in[106:99];
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc=0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [106:0]  in = {~crc[42:0], crc[63:0]};
   wire [7:0]		out1;			
   wire [7:0]		out2;			
   Test test (
	      .out1			(out1[7:0]),
	      .out2			(out2[7:0]),
	      .in			(in[106:0]));
   wire [63:0] result = {48'h0, out1, out1};
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n",$time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63]^crc[2]^crc[0]};
      sum <= result ^ {sum[62:0],sum[63]^sum[2]^sum[0]};
      if (cyc==0) begin
	 crc <= 64'h5aef0c8d_d70a4497;
	 sum <= '0;
      end
      else if (cyc<10) begin
	 sum <= '0;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
	 $write("[%0t] cyc==%0d crc=%x sum=%x\n",$time, cyc, crc, sum);
	 if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'hc746017202a24ecc
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
module Test (
   out1, out2,
   in
   );
   input [106:0]    in;
   output [7:0]     out1, out2;
   wire [7:0] 	    out1 = (in >>> 99) & 255;
   wire [7:0] 	    out2 = in[106:99];
endmodule
