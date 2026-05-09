module array_test
  #( parameter
     LEFT  = 5,
     RIGHT = 55)
 (
   clk
   );
   input clk;
   reg [7:0] a [LEFT:RIGHT];
   integer   l;
   integer   r;
   integer   s;
   always @(posedge clk) begin
      l = $left (a);
      r = $right (a);
      s = $size (a);
`ifdef TEST_VERBOSE
      $write ("$left (a) = %d, $right (a) = %d, $size (a) = %d\n", l, r, s);
`endif
      if ((l != LEFT) || (r != RIGHT) || (s != (RIGHT - LEFT + 1))) $stop;
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
module t (
   clk
   );
   input clk;
   wire  a = clk;
   wire  b = 1'b0;
   reg   c;
   array_test array_test_i (
			    .clk		(clk));
endmodule
module array_test
  #( parameter
     LEFT  = 5,
     RIGHT = 55)
 (
   clk
   );
   input clk;
   reg [7:0] a [LEFT:RIGHT];
   integer   l;
   integer   r;
   integer   s;
   always @(posedge clk) begin
      l = $left (a);
      r = $right (a);
      s = $size (a);
`ifdef TEST_VERBOSE
      $write ("$left (a) = %d, $right (a) = %d, $size (a) = %d\n", l, r, s);
`endif
      if ((l != LEFT) || (r != RIGHT) || (s != (RIGHT - LEFT + 1))) $stop;
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
