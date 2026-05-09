`define START 8
`define SIZE  4
`define END   (`START + `SIZE)
module foo(output wire [`END-1:0] y,
	   input wire [`END-1:0] x,
	   input wire 		 clk);
   function peek_bar;
      peek_bar = bar_inst[`START].i_bar.r;       
      peek_bar = bar_inst[`START + 1].i_bar.r;   
   endfunction
   genvar g;
   generate
      for (g = `START; g < `END; g = g + 1) begin: bar_inst
         bar i_bar(.x   (x[g]),
		   .y   (y[g]),
		   .clk (clk));
      end
   endgenerate
endmodule : foo
module bar(output wire y,
	   input wire x,
	   input wire clk);
   reg r = 0;
   assign y = r;
   always @(posedge clk) begin
      r = x ? ~x : y;
   end
endmodule : bar
`define START 8
`define SIZE  4
`define END   (`START + `SIZE)
module t (
   clk
   );
   input clk;
   reg [`END-1:0]   y;
   wire [`END-1:0]  x;
   foo foo_i (.y   (y),
	      .x   (x),
	      .clk (clk));
   always @(posedge clk) begin
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule 
module foo(output wire [`END-1:0] y,
	   input wire [`END-1:0] x,
	   input wire 		 clk);
   function peek_bar;
      peek_bar = bar_inst[`START].i_bar.r;       
      peek_bar = bar_inst[`START + 1].i_bar.r;   
   endfunction
   genvar g;
   generate
      for (g = `START; g < `END; g = g + 1) begin: bar_inst
         bar i_bar(.x   (x[g]),
		   .y   (y[g]),
		   .clk (clk));
      end
   endgenerate
endmodule : foo
module bar(output wire y,
	   input wire x,
	   input wire clk);
   reg r = 0;
   assign y = r;
   always @(posedge clk) begin
      r = x ? ~x : y;
   end
endmodule : bar
