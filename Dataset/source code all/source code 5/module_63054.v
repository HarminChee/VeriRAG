module sub (input clk, input [31:0] i, output [31:0] z);
   logic [31:0] z_tmp ;
   always @(posedge clk)
     z_tmp <= i+1+$c("0");  
   assign z = z_tmp;
endmodule
module t (
   clk
   );
   input clk;
   integer cyc = 0;
   parameter CNT = 5;
   wire [31:0]  w [CNT:0];
   generate
      for (genvar g=0; g<CNT; g++)
        sub sub (.clk(clk), .i(w[g]), .z(w[g+1]));
   endgenerate
   reg [31:0]   w0;
   assign w[0] = w0;
   always @ (posedge clk) begin
      cyc <= cyc + 1;
      if (cyc==0) begin
         w0 = 32'h1234;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
`define EXPECTED_SUM 32'h1239
`ifdef TEST_VERBOSE
         $write("[%0t] cyc==%0d  sum=%x\n", $time, cyc, w[CNT]);
`endif
         if (w[CNT] !== `EXPECTED_SUM) $stop;
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
module sub (input clk, input [31:0] i, output [31:0] z);
   logic [31:0] z_tmp ;
   always @(posedge clk)
     z_tmp <= i+1+$c("0");  
   assign z = z_tmp;
endmodule
