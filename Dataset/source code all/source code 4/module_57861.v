module t_format_wide_decimal(
   clk
   );
   input clk;
   int   cycle = 0;
   bit [1023:0] x = '1;
   always @(posedge clk) begin
      if (cycle == 0) begin
         $display("%d", 1024'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
      end else begin
         $display("%d", x);
      end
      cycle <= cycle + 1;
      x <= x >> 1;
      if (cycle == 2) begin
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
