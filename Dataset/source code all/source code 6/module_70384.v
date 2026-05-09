module Test (
   out,
   in
   );
   input [1:0] in;
   output reg [1:0] out;
   always @* begin
      case (in[1:0])
	2'd0, 2'd1, 2'd2, 2'd3: begin
	   out = in;
	end
      endcase
   end
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc = 0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [1:0]  in = crc[1:0];
   wire [1:0]		out;			
   Test test (
	      .out			(out[1:0]),
	      .in			(in[1:0]));
   wire [63:0] result = {62'h0, out};
`define EXPECTED_SUM 64'hbb2d9709592f64bd
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
   in
   );
   input [1:0] in;
   output reg [1:0] out;
   always @* begin
      case (in[1:0])
	2'd0, 2'd1, 2'd2, 2'd3: begin
	   out = in;
	end
      endcase
   end
endmodule
