module Test1 (output [7:0] au);
   wire [7:0] 		b;
   wire signed [3:0] 	c;
   assign c=-1;  
   assign b=3;   
   assign au=b+c; 
endmodule
module Test2 (output [7:0] as);
   wire signed [7:0] 	b;
   wire signed [3:0] 	c;
   assign c=-1;  
   assign b=3;   
   assign as=b+c; 
endmodule
module t (
   clk
   );
   input clk;
   wire [7:0] au;
   wire [7:0] as;
   Test1 test1 (.au);
   Test2 test2 (.as);
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] result=%x %x\n", $time, au, as);
`endif
      if (au != 'h12) $stop;
      if (as != 'h02) $stop;
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
module Test1 (output [7:0] au);
   wire [7:0] 		b;
   wire signed [3:0] 	c;
   assign c=-1;  
   assign b=3;   
   assign au=b+c; 
endmodule
module Test2 (output [7:0] as);
   wire signed [7:0] 	b;
   wire signed [3:0] 	c;
   assign c=-1;  
   assign b=3;   
   assign as=b+c; 
endmodule
