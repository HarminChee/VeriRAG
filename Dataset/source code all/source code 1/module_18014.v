module Test (
   line0, line1, out,
   clk, in
   );
   input clk;
   input [89:0] in;
   output reg [44:0]	line0;
   output reg [44:0]	line1;
   output reg [89:0]	out;
   assign  {line0,line1} = in;
   always @(posedge clk) begin
      out <= {line0,line1};
   end
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc=0;
   reg [89:0]	in;
   wire [89:0] 		out;			
   wire [44:0] 		line0;
   wire [44:0] 		line1;
   Test test (
	      .out			(out[89:0]),
	      .line0			(line0[44:0]),
	      .line1			(line1[44:0]),
	      .clk			(clk),
	      .in			(in[89:0]));
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d in=%x out=%x\n",$time, cyc, in, out);
`endif
      cyc <= cyc + 1;
      if (cyc==0) begin
	 in <= 90'h3FFFFFFFFFFFFFFFFFFFFFF;
      end
      else if (cyc==10) begin
         if (in==out) begin
	    $write("*-* All Finished *-*\n");
	    $finish;
	 end
	 else begin
	   $write("*-* Failed!! *-*\n");
	    $finish;
	 end
      end
   end
endmodule
module Test (
   line0, line1, out,
   clk, in
   );
   input clk;
   input [89:0] in;
   output reg [44:0]	line0;
   output reg [44:0]	line1;
   output reg [89:0]	out;
   assign  {line0,line1} = in;
   always @(posedge clk) begin
      out <= {line0,line1};
   end
endmodule
