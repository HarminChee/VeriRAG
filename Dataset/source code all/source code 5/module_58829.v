module Test
  (
   input logic 			  pick1,
   input logic [13:0] [1:0] 	  data1, 
   input logic [ 3:0] [2:0] [1:0] data2, 
   output logic [15:0] [1:0] 	  datao   
   );
   always_comb datao[13: 0]  
     = (pick1)
       ? {data1}  
       : {'0, data2};  
   always_comb datao[15:14] = '0;
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc = 0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire 	pick1 = crc[0];
   wire [13:0][1:0] data1 = crc[27+1:1];
   wire [3:0][2:0][1:0] data2 = crc[23+29:29];
   logic [15:0] [1:0]	datao;			
   Test test (
	      .datao			(datao),
	      .pick1			(pick1),
	      .data1			(data1),
	      .data2			(data2));
   wire [63:0] result = {32'h0, datao};
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
`define EXPECTED_SUM 64'h3ff4bf0e6407b281
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
module Test
  (
   input logic 			  pick1,
   input logic [13:0] [1:0] 	  data1, 
   input logic [ 3:0] [2:0] [1:0] data2, 
   output logic [15:0] [1:0] 	  datao   
   );
   always_comb datao[13: 0]  
     = (pick1)
       ? {data1}  
       : {'0, data2};  
   always_comb datao[15:14] = '0;
endmodule
