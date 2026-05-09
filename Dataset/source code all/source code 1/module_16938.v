module t (
   clk
   );
   input clk;
   localparam NO = 10;  
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
   localparam WS = 15;  
   integer cnt = 0;
   always @ (posedge clk)
   begin
      cnt <= cnt + 1;
   end
   always @ (posedge clk)
   if ((cnt[30:2]==NO) && (cnt[1:0]==2'd0)) begin
      $write("*-* All Finished *-*\n");
      $finish;
   end
   always @ (posedge clk)
   if (cnt[1:0]==2'd0) begin
      if      (cnt[30:2]==0)  struct_bg <= {WS{1'bx}};
      else if (cnt[30:2]==1)  struct_bg <= {WS{1'bx}};
      else if (cnt[30:2]==2)  struct_bg <= {WS{1'bx}};
      else if (cnt[30:2]==3)  struct_bg <= {WS{1'bx}};
      else if (cnt[30:2]==4)  struct_bg <= {WS{1'bx}};
      else if (cnt[30:2]==5)  struct_bg <= {WS{1'bx}};
   end else if (cnt[1:0]==2'd1) begin
      if      (cnt[30:2]==0)  begin end
      else if (cnt[30:2]==1)  struct_bg    <= {WS{1'b1}};
      else if (cnt[30:2]==2)  struct_bg.e0 <= {WS{1'b1}};
      else if (cnt[30:2]==3)  struct_bg.e1 <= {WS{1'b1}};
      else if (cnt[30:2]==4)  struct_bg.e2 <= {WS{1'b1}};
      else if (cnt[30:2]==5)  struct_bg.e3 <= {WS{1'b1}};
   end else if (cnt[1:0]==2'd2) begin
      if      (cnt[30:2]==0)  begin if (struct_bg !== 15'bxxxxxxxxxxxxxxx) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==1)  begin if (struct_bg !== 15'b111111111111111) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==2)  begin if (struct_bg !== 15'b1xxxxxxxxxxxxxx) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==3)  begin if (struct_bg !== 15'bx11xxxxxxxxxxxx) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==4)  begin if (struct_bg !== 15'bxxx1111xxxxxxxx) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==5)  begin if (struct_bg !== 15'bxxxxxxx11111111) begin $display("%b", struct_bg); $stop(); end end
   end else if (cnt[1:0]==2'd3) begin
      if      (cnt[30:2]==0)  begin if (struct_bg    !== {WS{1'bx}}) $stop(); end
      else if (cnt[30:2]==1)  begin if (struct_bg    !== {WS{1'b1}}) $stop(); end
      else if (cnt[30:2]==2)  begin if (struct_bg.e0 !== { 1{1'b1}}) $stop(); end
      else if (cnt[30:2]==3)  begin if (struct_bg.e1 !== { 2{1'b1}}) $stop(); end
      else if (cnt[30:2]==4)  begin if (struct_bg.e2 !== { 4{1'b1}}) $stop(); end
      else if (cnt[30:2]==5)  begin if (struct_bg.e3 !== { 8{1'b1}}) $stop(); end
   end
   always @ (posedge clk)
   if (cnt[1:0]==2'd0) begin
      if      (cnt[30:2]==0)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==1)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==2)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==3)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==4)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==5)  struct_lt <= {WS{1'bx}};
   end else if (cnt[1:0]==2'd1) begin
      if      (cnt[30:2]==0)  begin end
      else if (cnt[30:2]==1)  struct_lt    <= {WS{1'b1}};
      else if (cnt[30:2]==2)  struct_lt.e0 <= {WS{1'b1}};
      else if (cnt[30:2]==3)  struct_lt.e1 <= {WS{1'b1}};
      else if (cnt[30:2]==4)  struct_lt.e2 <= {WS{1'b1}};
      else if (cnt[30:2]==5)  struct_lt.e3 <= {WS{1'b1}};
   end else if (cnt[1:0]==2'd2) begin
      if      (cnt[30:2]==0)  begin if (struct_lt !== 15'bxxxxxxxxxxxxxxx) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==1)  begin if (struct_lt !== 15'b111111111111111) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==2)  begin if (struct_lt !== 15'b1xxxxxxxxxxxxxx) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==3)  begin if (struct_lt !== 15'bx11xxxxxxxxxxxx) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==4)  begin if (struct_lt !== 15'bxxx1111xxxxxxxx) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==5)  begin if (struct_lt !== 15'bxxxxxxx11111111) begin $display("%b", struct_lt); $stop(); end end
   end else if (cnt[1:0]==2'd3) begin
      if      (cnt[30:2]==0)  begin if (struct_lt    !== {WS{1'bx}}) $stop(); end
      else if (cnt[30:2]==1)  begin if (struct_lt    !== {WS{1'b1}}) $stop(); end
      else if (cnt[30:2]==2)  begin if (struct_lt.e0 !== { 1{1'b1}}) $stop(); end
      else if (cnt[30:2]==3)  begin if (struct_lt.e1 !== { 2{1'b1}}) $stop(); end
      else if (cnt[30:2]==4)  begin if (struct_lt.e2 !== { 4{1'b1}}) $stop(); end
      else if (cnt[30:2]==5)  begin if (struct_lt.e3 !== { 8{1'b1}}) $stop(); end
   end
endmodule
