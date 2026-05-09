module onehot (clk, resetb, a, b, x, y);
input clk;
input resetb;
input [7:0] a;
input [7:0] b;
output [7:0] x;
output [7:0] y;
reg [15:0] state, next_state;
reg [7:0] x, x_in;
reg [7:0] y, y_in;
always @(posedge clk or negedge resetb) begin
   if (~resetb) state = 0;
   else begin
      if (next_state == 0) begin
         state = 16'h0001;
      end
      else begin
         state = next_state;
      end
   end
end
always @(posedge clk or negedge resetb) begin
   if (~resetb) x = 0;
   else         x = x_in;
end
always @(posedge clk or negedge resetb) begin
   if (~resetb) y = 0;
   else         y = y_in;
end
always @(state or a or b or x or y) begin
   x_in = x;
   y_in = y;
   next_state = 0;
   case (1'b1) 
      state[0]:
         begin
            x_in = 8'd20;
            y_in = 8'd100;
            next_state[1] = 1'b1;
         end
      state[1]: next_state[2] = 1'b1;
      state[2]: next_state[3] = 1'b1;
      state[3]: next_state[4] = 1'b1;
      state[4]: next_state[5] = 1'b1;
      state[5]: next_state[6] = 1'b1;
      state[6]: next_state[7] = 1'b1;
      state[7]:
         begin
            if (a == 1) begin
               y_in = y - 1;
               next_state[1] = 1'b1;
            end
            else begin
               next_state[8] = 1'b1;
            end
         end
      state[8]: next_state[9]   = 1'b1;
      state[9]: next_state[10]  = 1'b1;
      state[10]: next_state[11] = 1'b1;
      state[11]:
         begin
            if (b == 1) begin
               x_in = x + 1;
               next_state[1] = 1'b1;
            end
            else begin
               next_state[12] = 1'b1;
            end
         end
      state[12]: next_state[13] = 1'b1;
      state[13]: next_state[14] = 1'b1;
      state[14]: next_state[15] = 1'b1;
      state[15]: next_state[1]  = 1'b1; 
    endcase
end
endmodule
