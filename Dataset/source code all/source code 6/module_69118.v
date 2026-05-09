module testbench(
   clk
   );
   input clk;
   int   cnt = 0;
   export "DPI-C" function set_cnt;
   function void set_cnt(int val);
      cnt = val;
   endfunction;
   export "DPI-C" function get_cnt;
   function int get_cnt();
      return cnt;
   endfunction;
   always @(posedge clk) cnt += 1;
   wire  dependent_clk = cnt == 2;
   int   n = 0;
   always @(posedge dependent_clk) begin
      $display("t=%t n=%d", $time, n);
      if ($time != (8*n+3) * 500) $stop;
      if (n == 20) begin
         $write("*-* All Finished *-*\n");
         $finish;
      end
      n += 1;
   end
endmodule
