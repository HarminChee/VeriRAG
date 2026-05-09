module t (
   clk
   );
   input clk;
   localparam WA = 8;  
   localparam NO = 6;  
   logic [WA-1:0] vector_bg;  
   logic [0:WA-1] vector_lt;  
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
      if      (cnt[30:2]==0)  vector_bg <= 'x;
      else if (cnt[30:2]==1)  vector_bg <= 'x;
      else if (cnt[30:2]==2)  vector_bg <= 'x;
      else if (cnt[30:2]==3)  vector_bg <= 'x;
      else if (cnt[30:2]==4)  vector_bg <= 'x;
      else if (cnt[30:2]==5)  vector_bg <= 'x;
   end else if (cnt[1:0]==2'd1) begin
      if      (cnt[30:2]==0)  begin end
      else if (cnt[30:2]==1)  vector_bg <= '{ 3, 2, 1, 0, '0, '1, 1'b1, 1'b0};
      else if (cnt[30:2]==2)  vector_bg <= '{0:3, 1:2, 2:1, 3:0, 4:'0, 5:'1, 6:1'b1, 7:1'b0};
      else if (cnt[30:2]==3)  vector_bg <= '{default:'1};
      else if (cnt[30:2]==4)  vector_bg <= '{2:'1, default:'0};
      else if (cnt[30:2]==5)  vector_bg <= '{cnt+0, cnt+1, cnt+2, cnt+3, cnt+4, cnt+5, cnt+6, cnt+7};
   end else if (cnt[1:0]==2'd2) begin
      if      (cnt[30:2]==0)  begin if (vector_bg !== 8'bxxxxxxxx) begin $display("%b", vector_bg); $stop(); end end
      else if (cnt[30:2]==1)  begin if (vector_bg !== 8'b10100110) begin $display("%b", vector_bg); $stop(); end end
      else if (cnt[30:2]==2)  begin if (vector_bg !== 8'b01100101) begin $display("%b", vector_bg); $stop(); end end
      else if (cnt[30:2]==3)  begin if (vector_bg !== 8'b11111111) begin $display("%b", vector_bg); $stop(); end end
      else if (cnt[30:2]==4)  begin if (vector_bg !== 8'b00000100) begin $display("%b", vector_bg); $stop(); end end
      else if (cnt[30:2]==5)  begin if (vector_bg !== 8'b10101010) begin $display("%b", vector_bg); $stop(); end end
   end
   always @ (posedge clk)
   if (cnt[1:0]==2'd0) begin
      if      (cnt[30:2]==0)  vector_lt <= 'x;
      else if (cnt[30:2]==1)  vector_lt <= 'x;
      else if (cnt[30:2]==2)  vector_lt <= 'x;
      else if (cnt[30:2]==3)  vector_lt <= 'x;
      else if (cnt[30:2]==4)  vector_lt <= 'x;
      else if (cnt[30:2]==5)  vector_lt <= 'x;
   end else if (cnt[1:0]==2'd1) begin
      if      (cnt[30:2]==0)  begin end
      else if (cnt[30:2]==1)  vector_lt <= '{ 3, 2, 1, 0, '0, '1, 1'b1, 1'b0};
      else if (cnt[30:2]==2)  vector_lt <= '{0:3, 1:2, 2:1, 3:0, 4:'0, 5:'1, 6:1'b1, 7:1'b0};
      else if (cnt[30:2]==3)  vector_lt <= '{default:'1};
      else if (cnt[30:2]==4)  vector_lt <= '{2:'1, default:'0};
      else if (cnt[30:2]==5)  vector_lt <= '{cnt+0, cnt+1, cnt+2, cnt+3, cnt+4, cnt+5, cnt+6, cnt+7};
   end else if (cnt[1:0]==2'd2) begin
      if      (cnt[30:2]==0)  begin if (vector_lt !== 8'bxxxxxxxx) begin $display("%b", vector_lt); $stop(); end end
      else if (cnt[30:2]==1)  begin if (vector_lt !== 8'b10100110) begin $display("%b", vector_lt); $stop(); end end
      else if (cnt[30:2]==2)  begin if (vector_lt !== 8'b10100110) begin $display("%b", vector_lt); $stop(); end end
      else if (cnt[30:2]==3)  begin if (vector_lt !== 8'b11111111) begin $display("%b", vector_lt); $stop(); end end
      else if (cnt[30:2]==4)  begin if (vector_lt !== 8'b00100000) begin $display("%b", vector_lt); $stop(); end end
      else if (cnt[30:2]==5)  begin if (vector_lt !== 8'b10101010) begin $display("%b", vector_lt); $stop(); end end
   end
endmodule
