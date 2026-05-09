module t (
   clk
   );
   input clk;
   struct packed {
      logic       e0;
      logic [1:0] e1;
      logic [3:0] e2;
      logic [7:0] e3;
   } struct_bg;  
   struct packed {
      logic       e0;
      logic [0:1] e1;
      logic [0:3] e2;
      logic [0:7] e3;
   } struct_lt;  
   integer cnt = 0;
   always @ (posedge clk)
   begin
      cnt <= cnt + 1;
   end
   always @ (posedge clk)
   if (cnt==2) begin
      $write("*-* All Finished *-*\n");
      $finish;
   end
   always @ (posedge clk)
   if (cnt==1) begin
      if ($bits (struct_bg   ) != 15) $stop;
      if ($bits (struct_bg.e0) !=  1) $stop;
      if ($bits (struct_bg.e1) !=  2) $stop;
      if ($bits (struct_bg.e2) !=  4) $stop;
      if ($bits (struct_bg.e3) !=  8) $stop;
      if ($increment (struct_bg, 1) !=  1) $stop;
      if ($bits (struct_lt   ) != 15) $stop;
      if ($bits (struct_lt.e0) !=  1) $stop;
      if ($bits (struct_lt.e1) !=  2) $stop;
      if ($bits (struct_lt.e2) !=  4) $stop;
      if ($bits (struct_lt.e3) !=  8) $stop;
      if ($increment (struct_lt, 1) != 1) $stop;  
   end
endmodule
