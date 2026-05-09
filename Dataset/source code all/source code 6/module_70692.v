module Test (
	     output wire out1 = 1'b1,
	     output integer out18 = 32'h18,
	     output var out1b = 1'b1,
	     output var logic out19 = 1'b1
	     );
endmodule
module t (
   clk
   );
   input clk;
   integer  out18;
   wire			out1;			
   wire			out19;			
   wire			out1b;			
   Test test (
	      .out1			(out1),
	      .out18			(out18),
	      .out1b			(out1b),
	      .out19			(out19));
   always @ (posedge clk) begin
      if (out1 !== 1'b1) $stop;
      if (out18 !== 32'h18) $stop;
      if (out1b !== 1'b1) $stop;
      if (out19 !== 1'b1) $stop;
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
module Test (
	     output wire out1 = 1'b1,
	     output integer out18 = 32'h18,
	     output var out1b = 1'b1,
	     output var logic out19 = 1'b1
	     );
endmodule
