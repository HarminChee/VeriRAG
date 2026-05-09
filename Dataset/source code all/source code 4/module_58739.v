module Test (
   out,
   clk, in
   );
   input clk;
   input [31:0] in;
   output wire [31:0] out;
   reg [31:0] 	     stage [3:0];
   genvar 	     g;
   generate
      for (g=0; g<4; g++) begin
	 always_comb begin
	    if (g==0) stage[g] = in;
	    else stage[g] = {stage[g-1][30:0],1'b1};
	 end
      end
   endgenerate
   assign out = stage[3];
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc = 0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [31:0]  in = crc[31:0];
   wire [31:0]		out;			
   Test test (
	      .out			(out[31:0]),
	      .clk			(clk),
	      .in			(in[31:0]));
   wire [63:0] result = {32'h0, out};
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n", $time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63] ^ crc[2] ^ crc[0]};
      sum <= result ^ {sum[62:0], sum[63] ^ sum[2] ^ sum[0]};
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
	 $write("[%0t] cyc==%0d crc=%x sum=%x\n", $time, cyc, crc, sum);
	 if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'h458c2de282e30f8b
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
   input [31:0] in;
   output wire [31:0] out;
   reg [31:0] 	     stage [3:0];
   genvar 	     g;
   generate
      for (g=0; g<4; g++) begin
	 always_comb begin
	    if (g==0) stage[g] = in;
	    else stage[g] = {stage[g-1][30:0],1'b1};
	 end
      end
   endgenerate
   assign out = stage[3];
endmodule
