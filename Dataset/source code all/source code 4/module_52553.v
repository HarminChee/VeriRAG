module t (
   clk
   );
   input clk;
   localparam WA = 4;  
   localparam WB = 4;  
   localparam NO = 11;  
   logic [WA-1:0] [WB-1:0] array_bg;  
   logic [0:WA-1] [0:WB-1] array_lt;  
   integer cnt = 0;
   always @ (posedge clk) begin
      cnt <= cnt + 1;
   end
   always @ (posedge clk)
   if ((cnt[30:2]==(NO-1)) && (cnt[1:0]==2'd3)) begin
      $write("*-* All Finished *-*\n");
      $finish;
   end
   always @ (posedge clk)
   if (cnt[1:0]==2'd0) begin
      if      (cnt[30:2]== 0)  array_bg <= '0;
      else if (cnt[30:2]== 1)  array_bg <= '0;
      else if (cnt[30:2]== 2)  array_bg <= '0;
      else if (cnt[30:2]== 3)  array_bg <= '0;
      else if (cnt[30:2]== 4)  array_bg <= '0;
      else if (cnt[30:2]== 5)  array_bg <= '0;
      else if (cnt[30:2]== 6)  array_bg <= '0;
      else if (cnt[30:2]== 7)  array_bg <= '0;
      else if (cnt[30:2]== 8)  array_bg <= '0;
      else if (cnt[30:2]== 9)  array_bg <= '0;
      else if (cnt[30:2]==10)  array_bg <= '0;
   end else if (cnt[1:0]==2'd1) begin
      if      (cnt[30:2]== 0)  begin end
      else if (cnt[30:2]== 1)  array_bg               <= '{ 3 ,2 ,1, 0 };
      else if (cnt[30:2]== 2)  array_bg               <= '{default:13};
      else if (cnt[30:2]== 3)  array_bg               <= '{0:4, 1:5, 2:6, 3:7};
      else if (cnt[30:2]== 4)  array_bg               <= '{2:15, default:13};
      else if (cnt[30:2]== 5)  array_bg               <= '{WA  {          {WB  {2'b10}}  }};
      else if (cnt[30:2]== 6)  array_bg               <= '{cnt+0, cnt+1, cnt+2, cnt+3};
   end else if (cnt[1:0]==2'd2) begin
      if      (cnt[30:2]== 0)  begin if (array_bg !== 16'b0000000000000000) begin $display("%b", array_bg); $stop(); end end
      else if (cnt[30:2]== 1)  begin if (array_bg !== 16'b0011001000010000) begin $display("%b", array_bg); $stop(); end end
      else if (cnt[30:2]== 2)  begin if (array_bg !== 16'b1101110111011101) begin $display("%b", array_bg); $stop(); end end
      else if (cnt[30:2]== 3)  begin if (array_bg !== 16'b0111011001010100) begin $display("%b", array_bg); $stop(); end end
      else if (cnt[30:2]== 4)  begin if (array_bg !== 16'b1101111111011101) begin $display("%b", array_bg); $stop(); end end
      else if (cnt[30:2]== 5)  begin if (array_bg !== 16'b1010101010101010) begin $display("%b", array_bg); $stop(); end end
      else if (cnt[30:2]== 6)  begin if (array_bg !== 16'b1001101010111100) begin $display("%b", array_bg); $stop(); end end
   end
   always @ (posedge clk)
   if (cnt[1:0]==2'd0) begin
      if      (cnt[30:2]== 0)  array_lt <= '0;
      else if (cnt[30:2]== 1)  array_lt <= '0;
      else if (cnt[30:2]== 2)  array_lt <= '0;
      else if (cnt[30:2]== 3)  array_lt <= '0;
      else if (cnt[30:2]== 4)  array_lt <= '0;
      else if (cnt[30:2]== 5)  array_lt <= '0;
      else if (cnt[30:2]== 6)  array_lt <= '0;
      else if (cnt[30:2]== 7)  array_lt <= '0;
      else if (cnt[30:2]== 8)  array_lt <= '0;
      else if (cnt[30:2]== 9)  array_lt <= '0;
      else if (cnt[30:2]==10)  array_lt <= '0;
   end else if (cnt[1:0]==2'd1) begin
      if      (cnt[30:2]== 0)  begin end
      else if (cnt[30:2]== 1)  array_lt               <= '{ 3 ,2 ,1, 0 };
      else if (cnt[30:2]== 2)  array_lt               <= '{default:13};
      else if (cnt[30:2]== 3)  array_lt               <= '{3:4, 2:5, 1:6, 0:7};
      else if (cnt[30:2]== 4)  array_lt               <= '{1:15, default:13};
      else if (cnt[30:2]== 5)  array_lt               <= '{WA  {          {WB/2  {2'b10}}  }};
      else if (cnt[30:2]==10)  array_lt               <= '{cnt+0, cnt+1, cnt+2, cnt+3};
   end else if (cnt[1:0]==2'd2) begin
      if      (cnt[30:2]== 0)  begin if (array_lt !== 16'b0000000000000000) begin $display("%b", array_lt); $stop(); end end
      else if (cnt[30:2]== 1)  begin if (array_lt !== 16'b0011001000010000) begin $display("%b", array_lt); $stop(); end end
      else if (cnt[30:2]== 2)  begin if (array_lt !== 16'b1101110111011101) begin $display("%b", array_lt); $stop(); end end
      else if (cnt[30:2]== 3)  begin if (array_lt !== 16'b0111011001010100) begin $display("%b", array_lt); $stop(); end end
      else if (cnt[30:2]== 4)  begin if (array_lt !== 16'b1101111111011101) begin $display("%b", array_lt); $stop(); end end
      else if (cnt[30:2]== 5)  begin if (array_lt !== 16'b1010101010101010) begin $display("%b", array_lt); $stop(); end end
      else if (cnt[30:2]==10)  begin if (array_lt !== 16'b1001101010111100) begin $display("%b", array_lt); $stop(); end end
   end
endmodule
