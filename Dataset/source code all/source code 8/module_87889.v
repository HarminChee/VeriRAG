module Test (
    input input_signal,
    output output_signal
    );
   wire    some_signal[1:0][1:0];
   assign some_signal[0][0] = input_signal;
   assign some_signal[0][1] = some_signal[0][0];
   assign some_signal[1][0] = some_signal[0][1];
   assign some_signal[1][1] = some_signal[1][0];
   assign output_signal = some_signal[1][1];
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc=0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire   input_signal = crc[0];
   wire			output_signal;		
   Test test (
	      .output_signal		(output_signal),
	      .input_signal		(input_signal));
   wire [63:0] result = {63'h0, output_signal};
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
`define EXPECTED_SUM 64'h765b2e12b25ec97b
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
module Test (
    input input_signal,
    output output_signal
    );
   wire    some_signal[1:0][1:0];
   assign some_signal[0][0] = input_signal;
   assign some_signal[0][1] = some_signal[0][0];
   assign some_signal[1][0] = some_signal[0][1];
   assign some_signal[1][1] = some_signal[1][0];
   assign output_signal = some_signal[1][1];
endmodule
