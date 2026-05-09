module t (
   clk, rst_both_l, rst_sync_l, rst_async_l, d
   );
   input clk;
   input rst_both_l;
   input rst_sync_l;
   input rst_async_l;
   input d;
   reg q1;
   reg q2;
   always @(posedge clk) begin
      if (~rst_sync_l) begin
         q1 <= 1'h0;
      end else begin
         q1 <= d;
      end
   end
   always @(posedge clk) begin
      q2 <= (rst_both_l) ? d : 1'b0;
      if (0 && q1 && q2) ;
   end
   reg   q3;
   always @(posedge clk or negedge rst_async_l) begin
      if (~rst_async_l) begin
         q3 <= 1'h0;
      end else begin
         q3 <= d;
      end
   end
   reg q4;
   always @(posedge clk or negedge rst_both_l) begin
      q4 <= (~rst_both_l) ? 1'b0 : d;
   end
   reg q5;
   always @(posedge clk or negedge rst_both_l) begin
      q5 <= (~rst_both_l) ? 1'b0 : d;
      if (0 && q3 && q4 && q5) ;
   end
endmodule
