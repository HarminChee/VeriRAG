module Test (
   next,
   cnt, decr
   );
   input [3:0] cnt;
   input signed [6:0] decr;
   output reg [3:0]         next;
   always_comb begin
      reg signed [6:0] tmp;
      tmp = 0;
      tmp = ($signed({1'b0, cnt}) - decr);
      if ((tmp > 15)) begin
         next = 15;
      end
      else if ((tmp < 0)) begin
         next = 0;
      end
      else begin
         next = tmp[3:0];
      end
   end
endmodule
module t (
   clk
   );
   input clk;
   integer      cyc = 0;
   reg [63:0]   crc;
   reg [63:0]   sum;
   wire [3:0]  cnt = crc[3:0];
   wire [6:0]  decr = crc[14:8];
   wire [3:0]           next;                   
   Test test (
              .next                     (next[3:0]),
              .cnt                      (cnt[3:0]),
              .decr                     (decr[6:0]));
   wire [63:0] result = {60'h0, next};
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n", $time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63] ^ crc[2] ^ crc[0]};
      sum <= result ^ {sum[62:0], sum[63] ^ sum[2] ^ sum[0]};
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
         $write("[%0t] cyc==%0d crc=%x sum=%x\n", $time, cyc, crc, sum);
         if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'h7cd85c944415d2ef
         if (sum !== `EXPECTED_SUM) $stop;
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
module Test (
   next,
   cnt, decr
   );
   input [3:0] cnt;
   input signed [6:0] decr;
   output reg [3:0]         next;
   always_comb begin
      reg signed [6:0] tmp;
      tmp = 0;
      tmp = ($signed({1'b0, cnt}) - decr);
      if ((tmp > 15)) begin
         next = 15;
      end
      else if ((tmp < 0)) begin
         next = 0;
      end
      else begin
         next = tmp[3:0];
      end
   end
endmodule
