module Test (
   out32, out10,
   in
   );
   input  [1:0] in;
   output [1:0] out32;
   output [1:0] out10;
   assign out32 = in[3:2];
   assign out10 = in[1:0];
endmodule
module t (
   clk
   );
   input clk;
   reg [1:0] in;
   wire [1:0]           out10;                  
   wire [1:0]           out32;                  
   Test test (
              .out32                    (out32[1:0]),
              .out10                    (out10[1:0]),
              .in                       (in[1:0]));
   always @ (posedge clk) begin
      in <= in + 1;
`ifdef TEST_VERBOSE
      $write("[%0t] in=%d out32=%d out10=%d\n",$time, in, out32, out10);
`endif
      if (in==3) begin
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
module Test (
   out32, out10,
   in
   );
   input  [1:0] in;
   output [1:0] out32;
   output [1:0] out10;
   assign out32 = in[3:2];
   assign out10 = in[1:0];
endmodule
