module Test (
   out,
   clk, in
   );
   input clk;
   input  [31:0] in;
   output [3:0] out;
   assign 	out[0] = in[3:0] ==? 4'b1001;
   assign 	out[1] = in[3:0] !=? 4'b1001;
   assign 	out[2] = in[3:0] ==? 4'bx01x;
   assign 	out[3] = in[3:0] !=? 4'bx01x;
   wire signed [3:0] ins = in[3:0];
   wire signed [3:0] outs;
   assign 	outs[0] = ins ==? 4'sb1001;
   assign 	outs[1] = ins !=? 4'sb1001;
   assign 	outs[2] = ins ==? 4'sbx01x;
   assign 	outs[3] = ins !=? 4'sbx01x;
   always_comb if (out != outs) $stop;
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc = 0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [31:0]  in = crc[31:0];
   wire [3:0]		out;			
   Test test (
	      .out			(out[3:0]),
	      .clk			(clk),
	      .in			(in[31:0]));
   wire [63:0] result = {60'h0, out};
`define EXPECTED_SUM 64'h1a0d07009b6a30d2
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n", $time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63] ^ crc[2] ^ crc[0]};
      sum <= result ^ {sum[62:0], sum[63] ^ sum[2] ^ sum[0]};
      if (cyc==0) begin
	 crc <= 64'h5aef0c8d_d70a4497;
      end
      else if (cyc<10) begin
	 sum <= 64'h0;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
	 $write("[%0t] cyc==%0d crc=%x sum=%x\n", $time, cyc, crc, sum);
	 if (crc !== 64'hc77bb9b3784ea091) $stop;
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
module Test (
   out,
   clk, in
   );
   input clk;
   input  [31:0] in;
   output [3:0] out;
   assign 	out[0] = in[3:0] ==? 4'b1001;
   assign 	out[1] = in[3:0] !=? 4'b1001;
   assign 	out[2] = in[3:0] ==? 4'bx01x;
   assign 	out[3] = in[3:0] !=? 4'bx01x;
   wire signed [3:0] ins = in[3:0];
   wire signed [3:0] outs;
   assign 	outs[0] = ins ==? 4'sb1001;
   assign 	outs[1] = ins !=? 4'sb1001;
   assign 	outs[2] = ins ==? 4'sbx01x;
   assign 	outs[3] = ins !=? 4'sbx01x;
   always_comb if (out != outs) $stop;
endmodule
