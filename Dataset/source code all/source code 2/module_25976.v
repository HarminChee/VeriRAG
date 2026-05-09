module dut_dummy( 
  input wire xbus_req_master_0,
  output reg xbus_gnt_master_0,
  input wire xbus_req_master_1,
  output reg xbus_gnt_master_1,
  input wire xbus_clock,
  input wire xbus_reset,
  input wire [15:0] xbus_addr,
  input wire [1:0] xbus_size,
  output reg xbus_read,
  output reg xbus_write,
  output reg  xbus_start,
  input wire xbus_bip,
  inout wire [7:0] xbus_data,
  input wire xbus_wait,
  input wire xbus_error);
  bit[2:0]   st;
   always @(posedge xbus_clock or posedge xbus_reset) begin
     if(xbus_reset) begin
       xbus_start <= 1'b0;
       st<=3'h0;
     end
       else
         case(st)
         0: begin 
             xbus_start <= 1'b1;
             st<=3'h3;
         end
         3: begin 
             xbus_start <= 1'b0;
             if((xbus_gnt_master_0==0) && (xbus_gnt_master_1==0)) begin
                 st<=3'h4;
             end
             else
                 st<=3'h1;
         end
         4: begin 
             xbus_start <= 1'b1;
             st<=3'h3;
         end
         1: begin 
             st<=3'h2;
             xbus_start <= 1'b0;
         end
         2: begin 
             if((xbus_error==1) || ((xbus_bip==0) && (xbus_wait==0))) begin
                 st<=3'h3;
                 xbus_start <= 1'b1;
             end
             else begin
                 st<=3'h2;
                 xbus_start <= 1'b0;
             end
         end
         endcase
     end
   always @(negedge xbus_clock or posedge xbus_reset) begin
     if(xbus_reset == 1'b1) begin
       xbus_gnt_master_0 <= 0;
       xbus_gnt_master_1 <= 0;
     end
     else begin
       if(xbus_start && xbus_req_master_0) begin
         xbus_gnt_master_0 <= 1;
         xbus_gnt_master_1 <= 0;
       end
       else if(xbus_start && !xbus_req_master_0 && xbus_req_master_1) begin
         xbus_gnt_master_0 <= 0;
         xbus_gnt_master_1 <= 1;
       end
       else begin
         xbus_gnt_master_0 <= 0;
         xbus_gnt_master_1 <= 0;
       end
     end
   end
   always @(posedge xbus_clock or posedge xbus_reset) begin
     if(xbus_reset) begin
       xbus_read <= 1'bZ;
       xbus_write <= 1'bZ;
     end
     else if(xbus_start && !xbus_gnt_master_0 && !xbus_gnt_master_1) begin
       xbus_read <= 1'b0;
       xbus_write <= 1'b0;
     end
     else begin
       xbus_read <= 1'bZ;
       xbus_write <= 1'bZ;
     end
   end
endmodule
