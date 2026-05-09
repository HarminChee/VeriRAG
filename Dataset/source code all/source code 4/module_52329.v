module t (
   clk
   );
   input clk;
   localparam WA = 8;  
   localparam WB = 8;  
   localparam NO = 10;  
   logic [WA-1:0] [WB-1:0] array_bg;  
   logic [0:WA-1] [0:WB-1] array_lt;  
   integer cnt = 0;
   always @ (posedge clk) begin
      cnt <= cnt + 1;
   end
   always @ (posedge clk)
     if ((cnt[30:2]==NO) && (cnt[1:0]==2'd0)) begin
	$write("*-* All Finished *-*\n");
	$finish;
     end
   always @ (posedge clk)
     if (cnt[1:0]==2'd0) begin
	if      (cnt[30:2]==0)  array_bg <=  {WA  *WB{1'bx}   };
	else if (cnt[30:2]==1)  array_bg <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==2)  array_bg <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==3)  array_bg <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==4)  array_bg <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==5)  array_bg <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==6)  array_bg <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==7)  array_bg <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==8)  array_bg <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==9)  array_bg <=  {WA{ {WB{1'bx}} }};
     end else if (cnt[1:0]==2'd1) begin
	if      (cnt[30:2]==0)  begin end
	else if (cnt[30:2]==1)  array_bg                            = {WA  *WB  +0{1'b1}};
	else if (cnt[30:2]==2)  array_bg [WA/2-1:0   ]              = {WA/2*WB  +0{1'b1}};
	else if (cnt[30:2]==3)  array_bg [WA  -1:WA/2]              = {WA/2*WB  +0{1'b1}};
	else if (cnt[30:2]==4)  array_bg [       0   ]              = {1   *WB  +0{1'b1}};
	else if (cnt[30:2]==5)  array_bg [WA  -1     ]              = {1   *WB  +0{1'b1}};
	else if (cnt[30:2]==6)  array_bg [       0   ][WB/2-1:0   ] = {1   *WB/2+0{1'b1}};
	else if (cnt[30:2]==7)  array_bg [WA  -1     ][WB  -1:WB/2] = {1   *WB/2+0{1'b1}};
	else if (cnt[30:2]==8)  array_bg [       0   ][       0   ] = {1   *1   +0{1'b1}};
	else if (cnt[30:2]==9)  array_bg [WA  -1     ][WB  -1     ] = {1   *1   +0{1'b1}};
     end else if (cnt[1:0]==2'd2) begin
	if      (cnt[30:2]==0)  begin if (array_bg !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==1)  begin if (array_bg !== 64'b1111111111111111111111111111111111111111111111111111111111111111) $stop(); end
	else if (cnt[30:2]==2)  begin if (array_bg !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx11111111111111111111111111111111) $stop(); end
	else if (cnt[30:2]==3)  begin if (array_bg !== 64'b11111111111111111111111111111111xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==4)  begin if (array_bg !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx11111111) $stop(); end
	else if (cnt[30:2]==5)  begin if (array_bg !== 64'b11111111xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==6)  begin if (array_bg !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1111) $stop(); end
	else if (cnt[30:2]==7)  begin if (array_bg !== 64'b1111xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==8)  begin if (array_bg !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1) $stop(); end
	else if (cnt[30:2]==9)  begin if (array_bg !== 64'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
     end else if (cnt[1:0]==2'd3) begin
	if      (cnt[30:2]==0)  begin if (array_bg                            !== {WA  *WB    {1'bx}}) $stop(); end
	else if (cnt[30:2]==1)  begin if (array_bg                            !== {WA  *WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==2)  begin if (array_bg [WA/2-1:0   ]              !== {WA/2*WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==3)  begin if (array_bg [WA  -1:WA/2]              !== {WA/2*WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==4)  begin if (array_bg [       0   ]              !== {1   *WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==5)  begin if (array_bg [WA  -1     ]              !== {1   *WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==6)  begin if (array_bg [       0   ][WB/2-1:0   ] !== {1   *WB/2+0{1'b1}}) $stop(); end
	else if (cnt[30:2]==7)  begin if (array_bg [WA  -1     ][WB  -1:WB/2] !== {1   *WB/2+0{1'b1}}) $stop(); end
	else if (cnt[30:2]==8)  begin if (array_bg [       0   ][       0   ] !== {1   *1   +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==9)  begin if (array_bg [WA  -1     ][WB  -1     ] !== {1   *1   +0{1'b1}}) $stop(); end
     end
   always @ (posedge clk)
     if (cnt[1:0]==2'd0) begin
	if      (cnt[30:2]==0)  array_lt <=  {WA  *WB{1'bx}   };
	else if (cnt[30:2]==1)  array_lt <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==2)  array_lt <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==3)  array_lt <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==4)  array_lt <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==5)  array_lt <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==6)  array_lt <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==7)  array_lt <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==8)  array_lt <=  {WA{ {WB{1'bx}} }};
	else if (cnt[30:2]==9)  array_lt <=  {WA{ {WB{1'bx}} }};
     end else if (cnt[1:0]==2'd1) begin
	if      (cnt[30:2]==0)  begin end
	else if (cnt[30:2]==1)  array_lt                            = {WA  *WB  +0{1'b1}};
	else if (cnt[30:2]==2)  array_lt [0   :WA/2-1]              = {WA/2*WB  +0{1'b1}};
	else if (cnt[30:2]==3)  array_lt [WA/2:WA  -1]              = {WA/2*WB  +0{1'b1}};
	else if (cnt[30:2]==4)  array_lt [0          ]              = {1   *WB  +0{1'b1}};
	else if (cnt[30:2]==5)  array_lt [     WA  -1]              = {1   *WB  +0{1'b1}};
	else if (cnt[30:2]==6)  array_lt [0          ][0   :WB/2-1] = {1   *WB/2+0{1'b1}};
	else if (cnt[30:2]==7)  array_lt [     WA  -1][WB/2:WB  -1] = {1   *WB/2+0{1'b1}};
	else if (cnt[30:2]==8)  array_lt [0          ][0          ] = {1   *1   +0{1'b1}};
	else if (cnt[30:2]==9)  array_lt [     WA  -1][     WB  -1] = {1   *1   +0{1'b1}};
     end else if (cnt[1:0]==2'd2) begin
	if      (cnt[30:2]==0)  begin if (array_lt !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==1)  begin if (array_lt !== 64'b1111111111111111111111111111111111111111111111111111111111111111) $stop(); end
	else if (cnt[30:2]==2)  begin if (array_lt !== 64'b11111111111111111111111111111111xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==3)  begin if (array_lt !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx11111111111111111111111111111111) $stop(); end
	else if (cnt[30:2]==4)  begin if (array_lt !== 64'b11111111xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==5)  begin if (array_lt !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx11111111) $stop(); end
	else if (cnt[30:2]==6)  begin if (array_lt !== 64'b1111xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==7)  begin if (array_lt !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1111) $stop(); end
	else if (cnt[30:2]==8)  begin if (array_lt !== 64'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx) $stop(); end
	else if (cnt[30:2]==9)  begin if (array_lt !== 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1) $stop(); end
     end else if (cnt[1:0]==2'd3) begin
	if      (cnt[30:2]==0)  begin if (array_lt                            !== {WA  *WB    {1'bx}}) $stop(); end
	else if (cnt[30:2]==1)  begin if (array_lt                            !== {WA  *WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==2)  begin if (array_lt [0   :WA/2-1]              !== {WA/2*WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==3)  begin if (array_lt [WA/2:WA  -1]              !== {WA/2*WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==4)  begin if (array_lt [0          ]              !== {1   *WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==5)  begin if (array_lt [     WA  -1]              !== {1   *WB  +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==6)  begin if (array_lt [0          ][0   :WB/2-1] !== {1   *WB/2+0{1'b1}}) $stop(); end
	else if (cnt[30:2]==7)  begin if (array_lt [     WA  -1][WB/2:WB  -1] !== {1   *WB/2+0{1'b1}}) $stop(); end
	else if (cnt[30:2]==8)  begin if (array_lt [0          ][0          ] !== {1   *1   +0{1'b1}}) $stop(); end
	else if (cnt[30:2]==9)  begin if (array_lt [     WA  -1][     WB  -1] !== {1   *1   +0{1'b1}}) $stop(); end
     end
endmodule
