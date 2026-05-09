module Test (
   out,
   clk, in
   );
   input clk;
   input logic [4:0] in;
   output logic out;
   always @(posedge clk) begin
      out <= in inside {5'b1_1?1?};
   end
endmodule 
module t (
   clk
   );
   input clk;
   integer 	cyc=0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [4:0] in = crc[4:0];
   logic		out;			
   Test test (
	      .out			(out),
	      .clk			(clk),
	      .in			(in[4:0]));
   wire [63:0] result = {63'h0, out};
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
`define EXPECTED_SUM 64'h7a7bd4ee927e7cc3
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
   input logic [4:0] in;
   output logic out;
   always @(posedge clk) begin
      out <= in inside {5'b1_1?1?};
   end
endmodule 
