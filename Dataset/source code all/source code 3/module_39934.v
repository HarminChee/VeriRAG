module sub1 (
   clk, rst_both_l, rst_sync_l, d
   );
   input clk;
   input rst_both_l;
   input rst_sync_l;
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
endmodule
module sub2 (
   clk, rst_both_l, rst_async_l, d
   );
   input clk;
   input rst_both_l;
   input rst_async_l;
   input d;
   reg   q1;
   reg   q2;
   reg   q3;
   always @(posedge clk or negedge rst_async_l) begin
      if (~rst_async_l) begin
         q1 <= 1'h0;
      end else begin
         q1 <= d;
      end
   end
   always @(posedge clk or negedge rst_both_l) begin
      q2 <= (~rst_both_l) ? 1'b0 : d;
   end
   always @(posedge clk or negedge rst_both_l) begin
      q3 <= (~rst_both_l) ? 1'b0 : d;
      if (0 && q1 && q2 && q3) ;
   end
endmodule
module t (
   rst_sync_l, rst_both_l, rst_async_l, d, clk
   );
   input                clk;                    
   input                d;                      
   input                rst_async_l;            
   input                rst_both_l;             
   input                rst_sync_l;             
   sub1 sub1 (
              .clk                      (clk),
              .rst_both_l               (rst_both_l),
              .rst_sync_l               (rst_sync_l),
              .d                        (d));
   sub2 sub2 (
              .clk                      (clk),
              .rst_both_l               (rst_both_l),
              .rst_async_l              (rst_async_l),
              .d                        (d));
endmodule
module sub1 (
   clk, rst_both_l, rst_sync_l, d
   );
   input clk;
   input rst_both_l;
   input rst_sync_l;
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
endmodule
module sub2 (
   clk, rst_both_l, rst_async_l, d
   );
   input clk;
   input rst_both_l;
   input rst_async_l;
   input d;
   reg   q1;
   reg   q2;
   reg   q3;
   always @(posedge clk or negedge rst_async_l) begin
      if (~rst_async_l) begin
         q1 <= 1'h0;
      end else begin
         q1 <= d;
      end
   end
   always @(posedge clk or negedge rst_both_l) begin
      q2 <= (~rst_both_l) ? 1'b0 : d;
   end
   always @(posedge clk or negedge rst_both_l) begin
      q3 <= (~rst_both_l) ? 1'b0 : d;
      if (0 && q1 && q2 && q3) ;
   end
endmodule
