module t (
   clk
   );
   input clk;
   localparam NO = 7;  
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
   if ((cnt[30:2]==(NO-1)) && (cnt[1:0]==2'd3)) begin
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
      else if (cnt[30:2]==6)  struct_bg <= {WS{1'bx}};
   end else if (cnt[1:0]==2'd1) begin
      if      (cnt[30:2]==0)  begin end
      else if (cnt[30:2]==1)  struct_bg <= '{0 ,1 , 2, 3};
      else if (cnt[30:2]==2)  struct_bg <= '{e0:1, e1:2, e2:3, e3:4};
      else if (cnt[30:2]==3)  struct_bg <= '{e3:6, e2:4, e1:2, e0:0};
      else if (cnt[30:2]==4)  struct_bg <= '{default:13};
      else if (cnt[30:2]==5)  struct_bg <= '{e2:8'haa, default:1};
      else if (cnt[30:2]==6)  struct_bg <= '{cnt+0 ,cnt+1 , cnt+2, cnt+3};
   end else if (cnt[1:0]==2'd2) begin
      if      (cnt[30:2]==0)  begin if (struct_bg !== 15'bx_xx_xxxx_xxxxxxxx) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==1)  begin if (struct_bg !== 15'b0_01_0010_00000011) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==2)  begin if (struct_bg !== 15'b1_10_0011_00000100) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==3)  begin if (struct_bg !== 15'b0_10_0100_00000110) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==4)  begin if (struct_bg !== 15'b1_01_1101_00001101) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==5)  begin if (struct_bg !== 15'b1_01_1010_00000001) begin $display("%b", struct_bg); $stop(); end end
      else if (cnt[30:2]==6)  begin if (struct_bg !== 15'b1_10_1011_00011100) begin $display("%b", struct_bg); $stop(); end end
   end
   always @ (posedge clk)
   if (cnt[1:0]==2'd0) begin
      if      (cnt[30:2]==0)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==1)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==2)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==3)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==4)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==5)  struct_lt <= {WS{1'bx}};
      else if (cnt[30:2]==6)  struct_lt <= {WS{1'bx}};
   end else if (cnt[1:0]==2'd1) begin
      if      (cnt[30:2]==0)  begin end
      else if (cnt[30:2]==1)  struct_lt <= '{0 ,1 , 2, 3};
      else if (cnt[30:2]==2)  struct_lt <= '{e0:1, e1:2, e2:3, e3:4};
      else if (cnt[30:2]==3)  struct_lt <= '{e3:6, e2:4, e1:2, e0:0};
      else if (cnt[30:2]==4)  struct_lt <= '{default:13};
      else if (cnt[30:2]==5)  struct_lt <= '{e2:8'haa, default:1};
      else if (cnt[30:2]==6)  struct_lt <= '{cnt+0 ,cnt+1 , cnt+2, cnt+3};
   end else if (cnt[1:0]==2'd2) begin
      if      (cnt[30:2]==0)  begin if (struct_lt !== 15'bx_xx_xxxx_xxxxxxxx) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==1)  begin if (struct_lt !== 15'b0_01_0010_00000011) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==2)  begin if (struct_lt !== 15'b1_10_0011_00000100) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==3)  begin if (struct_lt !== 15'b0_10_0100_00000110) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==4)  begin if (struct_lt !== 15'b1_01_1101_00001101) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==5)  begin if (struct_lt !== 15'b1_01_1010_00000001) begin $display("%b", struct_lt); $stop(); end end
      else if (cnt[30:2]==6)  begin if (struct_lt !== 15'b1_10_1011_00011100) begin $display("%b", struct_lt); $stop(); end end
   end
endmodule
