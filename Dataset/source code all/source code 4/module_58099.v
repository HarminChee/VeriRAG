module t(
   clk
   );
   input clk;
   int cyc = 0;
   always @ (posedge clk) begin
      cyc <= cyc + 1;
      if (cyc == 10) begin
         $strobe("[%0t] cyc=%0d", $time, cyc);
         $strobe("[%0t] cyc=%0d also", $time, cyc);
      end
      else if (cyc == 17) begin
         $strobeb(cyc, "b");
      end
      else if (cyc == 18) begin
         $strobeh(cyc, "h");
      end
      else if (cyc == 19) begin
         $strobeo(cyc, "o");
      end
      else if (cyc == 22) begin
         $strobe("[%0t] cyc=%0d new-strobe", $time, cyc);
      end
      else if (cyc == 24) begin
         $monitoroff;
      end
      else if (cyc == 26) begin
         $monitoron;
      end
      else if (cyc == 30) begin
         $write("*-* All Finished *-*\n");
         $finish;
      end
   end
endmodule
