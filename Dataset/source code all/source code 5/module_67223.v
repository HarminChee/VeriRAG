module dut
    #(parameter W = 1,
      parameter D = 1)
    (input logic clk,
     input logic [W-1:0] foo[D-1:0]);
    genvar i, j;
    generate
       for (j = 0; j < D; j++) begin
          for (i = 0; i < W; i++) begin
             suba ua(.clk(clk), .foo(foo[j][i]));
          end
       end
    endgenerate
endmodule
module suba
  (input logic clk,
   input logic foo);
   always @(posedge clk) begin
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
module t (
   clk
   );
   input clk;
   logic [6-1:0] foo[4-1:0];
   dut #(.W(6),
         .D(4)) udut(.clk(clk),
                     .foo(foo[4-1:0]));
endmodule
module dut
    #(parameter W = 1,
      parameter D = 1)
    (input logic clk,
     input logic [W-1:0] foo[D-1:0]);
    genvar i, j;
    generate
       for (j = 0; j < D; j++) begin
          for (i = 0; i < W; i++) begin
             suba ua(.clk(clk), .foo(foo[j][i]));
          end
       end
    endgenerate
endmodule
module suba
  (input logic clk,
   input logic foo);
   always @(posedge clk) begin
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
