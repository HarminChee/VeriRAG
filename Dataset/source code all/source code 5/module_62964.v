module swap (
             inout wire [31:0] a,
             inout wire [31:0] b
             );
   alias {a[7:0],a[15:8],a[23:16],a[31:24]} = b;
endmodule
module t (
   clk
   );
   input clk;
   wire [31:0] x_fwd = 32'hdeadbeef;
   wire [31:0] y_fwd;
   wire [31:0] x_bwd;
   wire [31:0] y_bwd = 32'hfeedface;
   swap swap_fwd_i (.a (x_fwd),
                    .b (y_fwd));
   swap swap_bwd_i (.a (x_bwd),
                    .b (y_bwd));
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write ("x_fwd = %x, y_fwd = %x\n", x_fwd, y_fwd);
      $write ("x_bwd = %x, y_bwd = %x\n", x_bwd, y_bwd);
`endif
      if (y_fwd != 32'hefbeadde) $stop;
      if (x_bwd == 32'hcefaedfe) $stop;
      $write("*-* All Finished *-*\n");
      $finish;
   end
endmodule
module swap (
             inout wire [31:0] a,
             inout wire [31:0] b
             );
   alias {a[7:0],a[15:8],a[23:16],a[31:24]} = b;
endmodule
