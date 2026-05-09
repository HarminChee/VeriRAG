module subimp(o,oe);
   output [31:0] o;
   assign o = 32'h12345679;
   output [31:0] oe;
   assign oe = 32'hab345679;
endmodule
module Test(o,oe);
   output [31:0] o;
   output [31:0] oe;
   wire [31:0] 	 xe;
   assign xe[31:1] = 0;
   subimp subimp(x,	 
		 xe[0]); 
   assign o = x;
   assign oe = xe;
endmodule
module t (
   clk
   );
   input clk;
   wire [31:0] o;
   wire [31:0] oe;
   Test test (
	      .o			(o[31:0]),
	      .oe			(oe[31:0]));
   always @ (posedge clk) begin
      if (o  !== 32'h00000001) $stop;
      if (oe !== 32'h00000001) $stop;
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
module subimp(o,oe);
   output [31:0] o;
   assign o = 32'h12345679;
   output [31:0] oe;
   assign oe = 32'hab345679;
endmodule
module Test(o,oe);
   output [31:0] o;
   output [31:0] oe;
   wire [31:0] 	 xe;
   assign xe[31:1] = 0;
   subimp subimp(x,	 
		 xe[0]); 
   assign o = x;
   assign oe = xe;
endmodule
