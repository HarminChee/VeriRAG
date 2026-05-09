module sub
  (
   input clk,
   input fastclk,
   input reset_l
   );
   reg [31:0] count_f;
   always_ff @ (posedge fastclk) begin
      if (!reset_l) begin
         count_f <= 32'h0;
      end
      else begin
         count_f <= count_f + 1;
      end
   end
   reg [31:0] count_c;
   always_ff @ (posedge clk) begin
      if (!reset_l) begin
         count_c <= 32'h0;
      end
      else begin
         count_c <= count_c + 1;
         if (count_c >= 3) begin
            $display("[%0t] fastclk is %0d times faster than clk\n",
                     $time, count_f/count_c);
            $write("*-* All Finished *-*\n");
            $finish;
         end
      end
   end
   always_ff @ (posedge clk) begin
      AssertionExample: assert(!reset_l || count_c<100);
   end
   cover property (@(posedge clk) count_c==3);
endmodule
