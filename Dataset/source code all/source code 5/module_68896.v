module SelFlop(
   out,
   clk, in, n
   );
   input clk;
   input [7:0] in;
   input [2:0]  n;
   output reg out;
   always @(posedge clk) begin
      out <= in[n];
   end
endmodule
module t(
   clk
   );
   input clk;
   integer cyc = 0;
   reg [63:0] crc;
   reg [63:0] sum;
   wire [7:0] in = crc[7:0];
   wire        out0;
   wire        out1;
   wire        out2;
   wire        out3;
   wire        out4;
   wire        out5;
   wire        out6;
   wire        out7;
   SelFlop selflop0(
                    .out                (out0),                  
                    .clk                (clk),
                    .in                 (in[7:0]),
                    .n                  (0));                     
   SelFlop selflop1(
                    .out                (out1),                  
                    .clk                (clk),
                    .in                 (in[7:0]),
                    .n                  (1));                     
   SelFlop selflop2(
                    .out                (out2),                  
                    .clk                (clk),
                    .in                 (in[7:0]),
                    .n                  (2));                     
   SelFlop selflop3(
                    .out                (out3),                  
                    .clk                (clk),
                    .in                 (in[7:0]),
                    .n                  (3));                     
   wire        outo = out0|out1|out2|out3;
   wire        outa = out0&out1&out2&out3;
   wire        outx = out0^out1^out2^out3;
   wire [63:0] result = {61'h0, outo, outa, outx};
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n", $time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63] ^ crc[2] ^ crc[0]};
      sum <= result ^ {sum[62:0], sum[63] ^ sum[2] ^ sum[0]};
      if (cyc == 0) begin
         crc <= 64'h5aef0c8d_d70a4497;
         sum <= '0;
      end
      else if (cyc < 10) begin
         sum <= '0;
      end
      else if (cyc < 90) begin
      end
      else if (cyc == 99) begin
         $write("[%0t] cyc==%0d crc=%x sum=%x\n", $time, cyc, crc, sum);
         if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'h118c5809c7856d78
         if (sum !== `EXPECTED_SUM) $stop;
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
module SelFlop(
   out,
   clk, in, n
   );
   input clk;
   input [7:0] in;
   input [2:0]  n;
   output reg out;
   always @(posedge clk) begin
      out <= in[n];
   end
endmodule
